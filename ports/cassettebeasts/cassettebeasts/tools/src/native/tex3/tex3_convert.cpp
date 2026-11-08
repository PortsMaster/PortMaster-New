/*
 * tex3_convert: shrink the imported textures (.stex) of a Godot 3 pack for a GLES3 handheld
 * (Mali: ETC2, no S3TC). Two conversions:
 *   - (near-)lossless, any texture: grey ones (R, G, B within 2 on visible pixels) become L8 when opaque, else
 *     LA8 (1 or 2 bytes per pixel instead of 4 once decoded);
 *   - ETC2, only textures under the res:// folders listed in -e <file> (illustrations, not
 *     palette-swapped sprites): ETC2_RGB8 when opaque (0.5 B/px), else ETC2_RGBA8 (1 B/px),
 *     if the result stays at or above MIN_PSNR on the visible pixels and on alpha.
 * Inputs: WebP stex (any mipmap count; PNG stex are skipped), raw RGB8/RGBA8, DXT1/DXT5
 * (Steam packs hold some textures only as S3TC, which Mali cannot sample).
 *
 * Converted textures are written to <out_dir>; each texture's .import remap inside the pack
 * is repointed to <target_dir>/<file> (appended at the end of the pack, the directory entry
 * rewritten in place). The original data stays in the pack. Remaps must have a plain path=
 * (run fix_remaps.py first on packs with path.s3tc/path.etc2 remaps).
 *
 * -x <file>: res:// source paths (or folders ending in '/') never to touch (pixels read by
 * scripts). -n: dry run (statistics only, pack unchanged).
 *
 * usage: tex3_convert [-v] [-n] [-e etc2_folders.txt] [-x keep.txt] <pck> <out_dir> <target_dir>
 * From Cassette Beasts (ETC2 path from Dome Keeper's tex_etc2). License: 0BSD.
 */
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <set>
#include <string>
#include <sys/stat.h>
#include <vector>

#include "../common/pck.h"
#include "Decode.hpp"
#include "ProcessRGB.hpp"
#include "bcdec.h"
#include "webp/decode.h"

// Godot 3 Image::Format and StreamTexture format bits
enum { F_L8 = 0, F_LA8 = 1, F_RGB8 = 4, F_RGBA8 = 5, F_DXT1 = 17, F_DXT5 = 19, F_ETC2_RGB8 = 34, F_ETC2_RGBA8 = 35 };
static const uint32_t BIT_PNG = 1u << 20, BIT_WEBP = 1u << 21, BIT_STREAM = 1u << 22, BIT_MIPMAPS = 1u << 23;
static const uint32_t DETECT_BITS = 7u << 24; // detect 3D / sRGB / normal: editor hints, kept as they are
static const int HEADER = 20;                  // GDST, w, w_custom, h, h_custom (u16), flags, format

static const double MIN_PSNR = 30.0;
static const int GREY_TOL = 2;
static int verbose, dry_run;

struct Level {
	uint32_t w, h;
	std::vector<uint8_t> rgba;
};

struct Stats {
	int l8 = 0, la8 = 0, etc2 = 0, kept = 0, remaps = 0;
	uint64_t in_bytes = 0, out_bytes = 0; // decoded RGBA8 vs new in-memory size
};

static void skip(const char *name, const char *why) {
	if (verbose)
		fprintf(stderr, "keep: %s (%s)\n", name, why);
}

// Image::_get_dst_image_size of Godot 3 (mipmaps down to 1x1, each level padded to whole blocks)
static uint64_t level_size(uint32_t w, uint32_t h, int bytes_num, int bytes_shift, int block) {
	uint32_t bw = (w + block - 1) / block * block, bh = (h + block - 1) / block * block;
	return ((uint64_t)bw * bh * bytes_num) >> bytes_shift;
}

static int full_chain(uint32_t w, uint32_t h) {
	int n = 1;
	while (w > 1 || h > 1) {
		w = w > 1 ? w >> 1 : 1;
		h = h > 1 ? h >> 1 : 1;
		n++;
	}
	return n;
}

static bool decode_dxt(const uint8_t *src, uint32_t w, uint32_t h, int fmt, Level &lv) {
	uint32_t bw = (w + 3) / 4, bh = (h + 3) / 4;
	std::vector<uint8_t> pad((size_t)bw * 4 * bh * 4 * 4);
	int bs = fmt == F_DXT1 ? BCDEC_BC1_BLOCK_SIZE : BCDEC_BC3_BLOCK_SIZE;
	for (uint32_t by = 0; by < bh; by++)
		for (uint32_t bx = 0; bx < bw; bx++) {
			uint8_t *dst = &pad[((size_t)by * 4 * bw * 4 + bx * 4) * 4];
			if (fmt == F_DXT1)
				bcdec_bc1(src, dst, bw * 4 * 4);
			else
				bcdec_bc3(src, dst, bw * 4 * 4);
			src += bs;
		}
	lv.w = w;
	lv.h = h;
	lv.rgba.resize((size_t)w * h * 4);
	for (uint32_t y = 0; y < h; y++)
		memcpy(&lv.rgba[(size_t)y * w * 4], &pad[(size_t)y * bw * 4 * 4], (size_t)w * 4);
	return true;
}

// All stored levels as RGBA8, or empty when the texture is of a kind left alone.
static std::vector<Level> decode(const char *name, const uint8_t *b, size_t size, uint32_t &fmtword) {
	std::vector<Level> levels;
	if (size < HEADER + 4 || memcmp(b, "GDST", 4)) {
		skip(name, "not GDST");
		return {};
	}
	uint32_t w = b[4] | b[5] << 8, h = b[8] | b[9] << 8;
	fmtword = pck_rd32(b + 16);
	uint32_t fmt = fmtword & 0xFFFFF;
	if (fmtword & BIT_PNG || fmtword & BIT_STREAM) {
		skip(name, "PNG or streamed");
		return {};
	}
	if (fmtword & BIT_WEBP) {
		const uint8_t *p = b + HEADER, *end = b + size;
		uint32_t mmc = pck_rd32(p);
		p += 4;
		for (uint32_t i = 0; i < mmc; i++) {
			if (p + 8 > end)
				return {};
			uint32_t len = pck_rd32(p);
			p += 4;
			if (p + len > end || len < 4 || memcmp(p, "WEBP", 4))
				return {};
			int dw, dh;
			uint8_t *rgba = WebPDecodeRGBA(p + 4, len - 4, &dw, &dh);
			if (!rgba)
				return {};
			Level lv{(uint32_t)dw, (uint32_t)dh, std::vector<uint8_t>(rgba, rgba + (size_t)dw * dh * 4)};
			WebPFree(rgba);
			levels.push_back(std::move(lv));
			p += len;
		}
		if (levels.empty() || levels[0].w != w || levels[0].h != h ||
				(levels.size() > 1 && (int)levels.size() != full_chain(w, h))) {
			skip(name, "unexpected WebP levels");
			return {};
		}
		return levels;
	}
	int n = fmtword & BIT_MIPMAPS ? full_chain(w, h) : 1;
	const uint8_t *p = b + HEADER, *end = b + size;
	uint32_t lw = w, lh = h;
	for (int i = 0; i < n; i++) {
		Level lv{lw, lh, {}};
		uint64_t sz;
		if (fmt == F_RGBA8 || fmt == F_RGB8) {
			int bpp = fmt == F_RGBA8 ? 4 : 3;
			sz = (uint64_t)lw * lh * bpp;
			if (p + sz > end)
				return {};
			lv.rgba.resize((size_t)lw * lh * 4);
			for (size_t j = 0; j < (size_t)lw * lh; j++) {
				memcpy(&lv.rgba[j * 4], p + j * bpp, 3);
				lv.rgba[j * 4 + 3] = bpp == 4 ? p[j * 4 + 3] : 255;
			}
		} else if (fmt == F_DXT1 || fmt == F_DXT5) {
			sz = level_size(lw, lh, 1, fmt == F_DXT1 ? 1 : 0, 4);
			if (p + sz > end)
				return {};
			decode_dxt(p, lw, lh, fmt, lv);
		} else {
			skip(name, "raw format not handled");
			return {};
		}
		levels.push_back(std::move(lv));
		p += sz;
		lw = lw > 1 ? lw >> 1 : 1;
		lh = lh > 1 ? lh >> 1 : 1;
	}
	return levels;
}

// ETC2 of one level; dec receives the decoded RGBA (unpadded) for the quality check.
static std::vector<uint8_t> etc2_level(const Level &lv, bool opaque, std::vector<uint8_t> *dec_rgba) {
	uint32_t w = lv.w, h = lv.h, pw = (w + 3) & ~3u, ph = (h + 3) & ~3u;
	std::vector<uint32_t> src((size_t)pw * ph), dec((size_t)pw * ph);
	for (uint32_t y = 0; y < ph; y++)
		for (uint32_t x = 0; x < pw; x++) {
			const uint8_t *p = &lv.rgba[((size_t)(y < h ? y : h - 1) * w + (x < w ? x : w - 1)) * 4];
			src[(size_t)y * pw + x] = p[2] | p[1] << 8 | p[0] << 16 | (uint32_t)p[3] << 24; // etcpak: BGRA
		}
	uint32_t blocks = pw / 4 * (ph / 4);
	std::vector<uint64_t> etc(opaque ? blocks : blocks * 2);
	if (opaque)
		CompressEtc2Rgb(src.data(), etc.data(), blocks, pw, true); // true: etcpak mode heuristics
	else
		CompressEtc2Rgba(src.data(), etc.data(), blocks, pw, true); // true: etcpak mode heuristics
	if (dec_rgba) {
		if (opaque)
			DecodeRGB(etc.data(), dec.data(), pw, ph);
		else
			DecodeRGBA(etc.data(), dec.data(), pw, ph);
		dec_rgba->resize((size_t)w * h * 4);
		for (uint32_t y = 0; y < h; y++)
			memcpy(&(*dec_rgba)[(size_t)y * w * 4], &dec[(size_t)y * pw], (size_t)w * 4); // decoder: RGBA words
	}
	const uint8_t *e = (const uint8_t *)etc.data();
	return std::vector<uint8_t>(e, e + etc.size() * 8);
}

static std::vector<uint8_t> convert(const char *name, bool etc2_ok, const uint8_t *b, size_t size, Stats &st) {
	uint32_t fmtword = 0;
	std::vector<Level> levels = decode(name, b, size, fmtword);
	if (levels.empty()) {
		st.kept++;
		return {};
	}
	// grey: channels within GREY_TOL of each other on visible pixels (lossy WebP stores YUV, so
	// its greys decode with R, G, B a step or two apart)
	bool grey = true, opaque = true;
	for (const Level &lv : levels)
		for (size_t j = 0; j < lv.rgba.size() && grey; j += 4) {
			const uint8_t *p = &lv.rgba[j];
			int lo = std::min({p[0], p[1], p[2]}), hi = std::max({p[0], p[1], p[2]});
			grey &= !p[3] || hi - lo <= GREY_TOL;
			opaque &= p[3] == 255;
		}
	uint32_t fmt = fmtword & 0xFFFFF;
	uint64_t rgba_bytes = 0;
	for (const Level &lv : levels)
		rgba_bytes += lv.rgba.size();

	std::vector<uint8_t> data;
	int newfmt;
	if (grey && !(fmt == F_L8 || fmt == F_LA8)) {
		newfmt = opaque ? F_L8 : F_LA8;
		for (const Level &lv : levels)
			for (size_t j = 0; j < lv.rgba.size(); j += 4) {
				data.push_back((lv.rgba[j] + lv.rgba[j + 1] + lv.rgba[j + 2] + 1) / 3);
				if (!opaque)
					data.push_back(lv.rgba[j + 3]);
			}
		(opaque ? st.l8 : st.la8)++;
	} else if (etc2_ok && levels[0].w >= 16 && levels[0].h >= 16) {
		newfmt = opaque ? F_ETC2_RGB8 : F_ETC2_RGBA8;
		std::vector<uint8_t> dec;
		for (size_t i = 0; i < levels.size(); i++) {
			std::vector<uint8_t> e = etc2_level(levels[i], opaque, i == 0 ? &dec : nullptr);
			data.insert(data.end(), e.begin(), e.end());
		}
		const std::vector<uint8_t> &o = levels[0].rgba;
		double se = 0, sea = 0;
		uint64_t visible = 0;
		for (size_t j = 0; j < o.size(); j += 4) {
			int da = (int)o[j + 3] - (opaque ? 255 : dec[j + 3]);
			sea += da * da;
			if (!o[j + 3])
				continue;
			for (int c = 0; c < 3; c++) {
				int d = (int)o[j + c] - dec[j + c];
				se += d * d;
			}
			visible++;
		}
		double mse = visible ? se / (3.0 * visible) : 0, msea = sea / (o.size() / 4);
		double psnr = mse > 0 ? 10 * log10(65025.0 / mse) : 99, psnra = msea > 0 ? 10 * log10(65025.0 / msea) : 99;
		if (psnr < MIN_PSNR || psnra < MIN_PSNR) {
			if (verbose)
				fprintf(stderr, "keep: %s (ETC2 %.1f dB colour, %.1f dB alpha)\n", name, psnr, psnra);
			st.kept++;
			return {};
		}
		st.etc2++;
	} else {
		skip(name, "not grey, not an ETC2 folder");
		st.kept++;
		return {};
	}
	std::vector<uint8_t> out(b, b + 16);
	uint8_t fw[4];
	pck_wr32(fw, newfmt | (levels.size() > 1 ? BIT_MIPMAPS : 0) | (fmtword & DETECT_BITS));
	out.insert(out.end(), fw, fw + 4);
	out.insert(out.end(), data.begin(), data.end());
	st.in_bytes += rgba_bytes;
	st.out_bytes += data.size();
	return out;
}

// Desktop exports list per-GPU variants (path.s3tc=, path.etc2=) but hold only some of them; Godot picks
// the first variant whose feature the GPU has (Mali: etc2) even when that file is missing. Rewrites such
// a remap to a plain path= naming a variant that exists (same as tools/fix_remaps.py). Returns true when
// the remap was rewritten; *text is then the new remap text.
static bool fix_feature_remap(Pck *pck, PckEntry *imp, char **text, bool dry) {
	std::string t(*text), first_ok;
	bool any = false, missing = false;
	std::string out;
	size_t pos = 0;
	while (pos < t.size()) {
		size_t eol = t.find('\n', pos);
		std::string line = t.substr(pos, eol == std::string::npos ? std::string::npos : eol + 1 - pos);
		pos = eol == std::string::npos ? t.size() : eol + 1;
		if (line.compare(0, 5, "path.") == 0 && line.find("=\"") != std::string::npos) {
			any = true;
			size_t a = line.find("=\"") + 2, b = line.find('"', a);
			std::string p = line.substr(a, b - a);
			if (pck_find(pck, p.c_str())) {
				if (first_ok.empty())
					first_ok = p;
			} else {
				missing = true;
			}
			continue; // dropped from the new text
		}
		out += line;
		// (CRLF too: the Epic Games Store pack's imports have Windows line endings, which Godot reads fine but the
		// exact "[remap]\n" match missed, so none of its remaps were fixed)
		if (line == "[remap]\n" || line == "[remap]\r\n")
			out += "\n\x01"; // placeholder for the plain path line
	}
	if (!any || !missing || first_ok.empty())
		return false;
	size_t ph = out.find('\x01');
	if (ph == std::string::npos)
		return false;
	out.replace(ph, 1, "path=\"" + first_ok + "\"\n");
	// collapse the blank line the dropped path lines leave behind
	size_t dbl = out.find("\"\n\n", ph);
	if (dbl != std::string::npos && dbl == ph + 6 + first_ok.size())
		out.erase(dbl + 1, 1);
	if (verbose)
		fprintf(stderr, "remap: %s -> %s\n", imp->name, first_ok.c_str());
	if (!dry)
		pck_replace(pck, imp, out.data(), out.size());
	free(*text);
	*text = strdup(out.c_str());
	return true;
}

static std::set<std::string> read_list(const char *path) {
	std::set<std::string> list;
	FILE *f = fopen(path, "r");
	if (!f)
		pck_die("cannot open", path);
	char line[4096];
	while (fgets(line, sizeof line, f)) {
		line[strcspn(line, "\r\n")] = 0;
		if (line[0] && line[0] != '#')
			list.insert(line);
	}
	fclose(f);
	return list;
}

// A list line names a res:// source path, or a folder when it ends in '/'.
static bool listed(const std::set<std::string> &list, const std::string &src) {
	if (list.count(src))
		return true;
	for (size_t p = src.find('/', 6); p != std::string::npos; p = src.find('/', p + 1))
		if (list.count(src.substr(0, p + 1)))
			return true;
	return false;
}

int main(int argc, char **argv) {
	std::set<std::string> keep, etc2;
	for (;;) {
		if (argc > 1 && !strcmp(argv[1], "-v")) {
			verbose = 1;
			argv++, argc--;
		} else if (argc > 1 && !strcmp(argv[1], "-n")) {
			dry_run = 1;
			argv++, argc--;
		} else if (argc > 2 && !strcmp(argv[1], "-x")) {
			keep = read_list(argv[2]);
			argv += 2, argc -= 2;
		} else if (argc > 2 && !strcmp(argv[1], "-e")) {
			etc2 = read_list(argv[2]);
			argv += 2, argc -= 2;
		} else {
			break;
		}
	}
	if (argc != 4) {
		fprintf(stderr, "usage: tex3_convert [-v] [-n] [-e etc2_folders.txt] [-x keep.txt] <pck> <out_dir> <target_dir>\n");
		return 2;
	}
	Pck pck;
	pck_open(&pck, argv[1]);
	if (pck.version != 1)
		pck_die("not a Godot 3 pack:", argv[1]);
	if (!dry_run)
		mkdir(argv[2], 0755);
	Stats st;
	for (int i = 0; i < pck.count; i++) {
		PckEntry *imp = &pck.entries[i];
		size_t nl = strlen(imp->name);
		if (nl < 7 || strcmp(imp->name + nl - 7, ".import"))
			continue;
		std::string src(imp->name, nl - 7);
		char *text = (char *)pck_read(&pck, imp);
		if (fix_feature_remap(&pck, imp, &text, dry_run))
			st.remaps++;
		char real[1024];
		PckEntry *te = NULL;
		if (strstr(text, "importer=\"texture\"") && pck_import_path(text, real, sizeof real) && strlen(real) > 5 &&
				!strcmp(real + strlen(real) - 5, ".stex"))
			te = pck_find(&pck, real);
		if (!te) {
			free(text);
			continue;
		}
		if (listed(keep, src)) {
			skip(imp->name, "listed in -x");
			st.kept++;
			free(text);
			continue;
		}
		uint8_t *tex = pck_read(&pck, te);
		std::vector<uint8_t> conv = convert(src.c_str(), listed(etc2, src), tex, te->size, st);
		if (!conv.empty() && !dry_run) {
			const char *file = strrchr(real, '/') + 1;
			pck_write_file(argv[2], file, conv.data(), conv.size());
			char target[4096];
			snprintf(target, sizeof target, "%s/%s", argv[3], file);
			pck_repoint_import(&pck, imp, text, target);
		}
		free(tex);
		free(text);
	}
	fclose(pck.f);
	printf("%s%d remaps fixed; %d L8, %d LA8, %d ETC2, %d kept: %.1f MB as RGBA8 -> %.1f MB\n", dry_run ? "dry run: " : "",
		st.remaps, st.l8, st.la8, st.etc2, st.kept, st.in_bytes / 1048576.0, st.out_bytes / 1048576.0);
	return 0;
}
