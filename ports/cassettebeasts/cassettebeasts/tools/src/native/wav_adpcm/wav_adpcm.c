/*
 * wav_adpcm: convert the 16-bit PCM AudioStreamWAV / AudioStreamSample resources (.sample) of a
 * Godot 4.3 or Godot 3 pack (same binary resource layout for these) to IMA-ADPCM, the way Godot's own WAV importer does with compress/mode=1.
 * Stereo samples whose two channels are identical become mono first.
 *
 * Converted samples are written to <out_dir>; each sample's .wav.import remap inside
 * the pack is repointed to <target_dir>/<file> (appended at the end of the pack, the
 * directory entry rewritten in place). The original PCM data stays in the pack.
 *
 * usage: wav_adpcm [-v] <pck> <out_dir> <target_dir>   (-v: say why a sample is skipped)
 */
#define _FILE_OFFSET_BITS 64
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include "../common/pck.h"

#define VT_NIL 1
#define VT_BOOL 2
#define VT_INT 3
#define VT_RAW 31

static int verbose;
#define SKIP(why) do { if (verbose) fprintf(stderr, "skip: %s\n", why); return NULL; } while (0)

static uint32_t rd32(const uint8_t *p) { return pck_rd32(p); }
static void wr32(uint8_t *p, uint32_t v) { pck_wr32(p, v); }

/* --- IMA-ADPCM, identical to ResourceImporterWAV::_compress_ima_adpcm (Godot 4.3) --- */
static const int16_t step_table[89] = {
	7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66,
	73, 80, 88, 97, 107, 118, 130, 143, 157, 173, 190, 209, 230, 253, 279, 307, 337, 371, 408,
	449, 494, 544, 598, 658, 724, 796, 876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066,
	2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630,
	9493, 10442, 11487, 12635, 13899, 15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767
};
static const int8_t index_table[16] = { -1, -1, -1, -1, 2, 4, 6, 8, -1, -1, -1, -1, 2, 4, 6, 8 };

/* in: n samples of one channel, read with stride; out: n_even/2 + 4 bytes */
static uint32_t ima_encode(const int16_t *in, int stride, uint32_t n, uint8_t *out) {
	uint32_t len = n + (n & 1);
	int step_idx = 0, prev = 0;
	uint8_t *o = out;
	*o++ = 0; *o++ = 0; *o++ = 0; *o++ = 0; /* initial value, table index, unused */
	for (uint32_t i = 0; i < len; i++) {
		int sample = i < n ? in[(size_t)i * stride] : 0;
		int diff = sample - prev;
		uint8_t nibble = 0;
		int step = step_table[step_idx];
		int vpdiff = step >> 3;
		if (diff < 0) {
			nibble = 8;
			diff = -diff;
		}
		for (int mask = 4; mask; mask >>= 1) {
			if (diff >= step) {
				nibble |= mask;
				diff -= step;
				vpdiff += step;
			}
			step >>= 1;
		}
		prev += (nibble & 8) ? -vpdiff : vpdiff;
		prev = prev < -32768 ? -32768 : prev > 32767 ? 32767 : prev;
		step_idx += index_table[nibble];
		step_idx = step_idx < 0 ? 0 : step_idx > 88 ? 88 : step_idx;
		if (i & 1)
			*o++ |= nibble << 4;
		else
			*o = nibble;
	}
	return len / 2 + 4;
}

/* --- AudioStreamWAV binary resource --- */
typedef struct {
	uint32_t name_idx, type;
	int32_t ival;
	const uint8_t *raw;
	uint32_t raw_len;
} Prop;

typedef struct {
	uint8_t *buf;
	size_t len, cap;
} Out;

static void put(Out *o, const void *p, size_t n) {
	if (o->len + n > o->cap) {
		o->cap = (o->len + n) * 2;
		o->buf = realloc(o->buf, o->cap);
	}
	memcpy(o->buf + o->len, p, n);
	o->len += n;
}
static void put32(Out *o, uint32_t v) { uint8_t b[4]; wr32(b, v); put(o, b, 4); }

static int name_index(char **names, uint32_t count, const char *name) {
	for (uint32_t i = 0; i < count; i++)
		if (!strcmp(names[i], name))
			return (int)i;
	return -1;
}

typedef struct { int converted, mono; uint64_t in_bytes, out_bytes; } Stats;

/* Returns a newly built resource, or NULL to leave the sample as it is. */
static uint8_t *convert_sample(const uint8_t *b, size_t size, size_t *out_len, Stats *st) {
	const uint8_t *key = NULL;
	for (size_t i = 0; i + 23 < size; i++)
		if (!memcmp(b + i, "resource_local_to_scene", 23)) { key = b + i; break; }
	if (!key) SKIP("no string table");
	const uint8_t *p = key - 8;
	uint32_t count = rd32(p); p += 4;
	char **names = calloc(count, sizeof(char *));
	for (uint32_t i = 0; i < count; i++) {
		uint32_t l = rd32(p); p += 4;
		names[i] = (char *)p; /* NUL-terminated inside the buffer */
		p += l;
	}
	if (rd32(p) != 0) SKIP("external resources");
	p += 4;
	uint32_t intn = rd32(p); p += 4;
	uint64_t body = 0;
	for (uint32_t i = 0; i < intn; i++) {
		uint32_t l = rd32(p); p += 4 + l;
		body = rd32(p) | (uint64_t)rd32(p + 4) << 32; p += 8;
	}
	if (intn != 1 || body >= size) SKIP("not a single internal resource");
	p = b + body;
	uint32_t tl = rd32(p);
	const uint8_t *type_start = p;
	p += 4 + tl;
	uint32_t pc = rd32(p); p += 4;
	Prop props[32];
	if (pc > 32) SKIP("too many properties");
	int fmt = 0, loop_mode = 0, stereo = 0, i_data = -1, i_fmt = -1, i_stereo = -1;
	for (uint32_t i = 0; i < pc; i++) {
		props[i].name_idx = rd32(p) & 0x7fffffff;
		props[i].type = rd32(p + 4);
		p += 8;
		const char *n = names[props[i].name_idx];
		if (props[i].type == VT_RAW) {
			props[i].raw_len = rd32(p);
			props[i].raw = p + 4;
			p += 4 + props[i].raw_len + (4 - props[i].raw_len % 4) % 4;
			if (!strcmp(n, "data")) i_data = i;
		} else if (props[i].type == VT_INT || props[i].type == VT_BOOL) {
			props[i].ival = (int32_t)rd32(p);
			p += 4;
			if (!strcmp(n, "format")) { fmt = props[i].ival; i_fmt = i; }
			else if (!strcmp(n, "loop_mode")) loop_mode = props[i].ival;
			else if (!strcmp(n, "stereo")) { stereo = props[i].ival; i_stereo = i; }
		} else if (props[i].type == VT_NIL) {
			/* no payload (e.g. script = null) */
		} else {
			SKIP("unknown property type");
		}
	}
	/* 16-bit only; IMA-ADPCM playback supports loop modes disabled (0) and forward (1) */
	if (fmt != 1 || i_data < 0 || loop_mode > 1) SKIP("not 16-bit PCM with a supported loop mode");

	const int16_t *pcm = (const int16_t *)props[i_data].raw; /* little-endian host assumed */
	uint32_t frames = props[i_data].raw_len / (stereo ? 4 : 2);
	int mono = 0;
	if (stereo) {
		mono = 1;
		for (uint32_t i = 0; i < frames && mono; i++)
			mono = pcm[2 * i] == pcm[2 * i + 1];
	}
	int channels = stereo && !mono ? 2 : 1;
	uint32_t chlen = (frames + (frames & 1)) / 2 + 4;
	uint8_t *adpcm = malloc((size_t)chlen * channels);
	if (channels == 1) {
		ima_encode(pcm, stereo ? 2 : 1, frames, adpcm);
	} else {
		uint8_t *l = malloc(chlen), *r = malloc(chlen);
		ima_encode(pcm, 2, frames, l);
		ima_encode(pcm + 1, 2, frames, r);
		for (uint32_t i = 0; i < chlen; i++) {
			adpcm[2 * i] = l[i];
			adpcm[2 * i + 1] = r[i];
		}
		free(l);
		free(r);
	}
	uint32_t adpcm_len = chlen * channels;

	int fmt_name = name_index(names, count, "format");
	if ((i_fmt < 0 && fmt_name < 0) || (stereo && i_stereo < 0)) {
		free(adpcm);
		SKIP("format/stereo property name missing");
	}

	Out o = { 0 };
	put(&o, b, body);
	put(&o, type_start, 4 + tl);
	put32(&o, pc + (i_fmt < 0));
	for (uint32_t i = 0; i < pc; i++) {
		put32(&o, props[i].name_idx);
		put32(&o, props[i].type);
		if ((int)i == i_data) {
			put32(&o, adpcm_len);
			put(&o, adpcm, adpcm_len);
			static const uint8_t pad[4];
			put(&o, pad, (4 - adpcm_len % 4) % 4);
		} else if ((int)i == i_fmt) {
			put32(&o, 2); /* AudioStreamWAV::FORMAT_IMA_ADPCM */
		} else if ((int)i == i_stereo) {
			put32(&o, channels == 2);
		} else if (props[i].type == VT_RAW) {
			put32(&o, props[i].raw_len);
			put(&o, props[i].raw, props[i].raw_len);
			static const uint8_t pad[4];
			put(&o, pad, (4 - props[i].raw_len % 4) % 4);
		} else if (props[i].type != VT_NIL) {
			put32(&o, (uint32_t)props[i].ival);
		}
	}
	if (i_fmt < 0) {
		put32(&o, fmt_name);
		put32(&o, VT_INT);
		put32(&o, 2);
	}
	put(&o, "RSRC", 4);
	free(adpcm);
	free(names);
	st->converted++;
	st->mono += mono;
	st->in_bytes += props[i_data].raw_len;
	st->out_bytes += adpcm_len;
	*out_len = o.len;
	return o.buf;
}

int main(int argc, char **argv) {
	if (argc > 1 && !strcmp(argv[1], "-v")) {
		verbose = 1;
		argv++;
		argc--;
	}
	if (argc != 4) {
		fprintf(stderr, "usage: wav_adpcm [-v] <pck> <out_dir> <target_dir>\n");
		return 2;
	}
	Pck pck;
	pck_open(&pck, argv[1]);
	mkdir(argv[2], 0755);
	Stats st = { 0 };
	int skipped = 0;
	for (int i = 0; i < pck.count; i++) {
		PckEntry *imp = &pck.entries[i];
		size_t nl = strlen(imp->name);
		if (nl < 11 || strcmp(imp->name + nl - 11, ".wav.import"))
			continue;
		char *text = (char *)pck_read(&pck, imp);
		char real[1024];
		PckEntry *se = pck_import_path(text, real, sizeof real) ? pck_find(&pck, real) : NULL;
		if (!se) {
			free(text);
			continue;
		}
		uint8_t *sample = pck_read(&pck, se);
		size_t new_len;
		uint8_t *conv = convert_sample(sample, se->size, &new_len, &st);
		if (conv) {
			const char *file = strrchr(real, '/') + 1;
			pck_write_file(argv[2], file, conv, new_len);
			char target[4096];
			snprintf(target, sizeof target, "%s/%s", argv[3], file);
			pck_repoint_import(&pck, imp, text, target);
			free(conv);
		} else {
			skipped++;
		}
		free(sample);
		free(text);
	}
	fclose(pck.f);
	printf("converted %d samples (%d stereo to mono), skipped %d: %.1f MB PCM -> %.1f MB IMA-ADPCM\n",
		st.converted, st.mono, skipped, st.in_bytes / 1048576.0, st.out_bytes / 1048576.0);
	return 0;
}
