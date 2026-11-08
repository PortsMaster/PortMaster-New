#define _FILE_OFFSET_BITS 64
#include "pck.h"
#include <stdlib.h>
#include <string.h>

#define HEADER_SIZE_V2 (4 + 16 + 12 + 64) /* magic, version + engine version, flags + base, reserved */
#define HEADER_SIZE_V1 (4 + 16 + 64)      /* magic, version + engine version, reserved */

void pck_die(const char *msg, const char *arg) {
	fprintf(stderr, "error: %s %s\n", msg, arg ? arg : "");
	exit(1);
}

uint32_t pck_rd32(const uint8_t *p) { return p[0] | p[1] << 8 | p[2] << 16 | (uint32_t)p[3] << 24; }

void pck_wr32(uint8_t *p, uint32_t v) {
	p[0] = v;
	p[1] = v >> 8;
	p[2] = v >> 16;
	p[3] = v >> 24;
}

static void rd(void *p, size_t n, FILE *f) {
	if (fread(p, 1, n, f) != n)
		pck_die("truncated pack directory", NULL);
}

void pck_open(Pck *pck, const char *path) {
	pck->f = fopen(path, "r+b");
	if (!pck->f)
		pck_die("cannot open", path);
	uint8_t h[HEADER_SIZE_V2];
	if (fread(h, 1, HEADER_SIZE_V1, pck->f) != HEADER_SIZE_V1 || memcmp(h, "GDPC", 4))
		pck_die("not a Godot pack:", path);
	pck->version = (int)pck_rd32(h + 4);
	if (pck->version == 2) { /* Godot 4: flags, file base; offsets are relative to it */
		rd(h + HEADER_SIZE_V1, HEADER_SIZE_V2 - HEADER_SIZE_V1, pck->f);
		pck->base = pck_rd32(h + 24) | (uint64_t)pck_rd32(h + 28) << 32;
	} else if (pck->version == 1) { /* Godot 3: absolute offsets */
		pck->base = 0;
	} else {
		pck_die("unknown pack format version:", path);
	}
	uint8_t b4[4];
	rd(b4, 4, pck->f);
	pck->count = (int)pck_rd32(b4);
	pck->entries = calloc(pck->count, sizeof(PckEntry));
	for (int i = 0; i < pck->count; i++) {
		PckEntry *e = &pck->entries[i];
		rd(b4, 4, pck->f);
		uint32_t len = pck_rd32(b4);
		e->name = calloc(1, len + 1);
		rd(e->name, len, pck->f);
		e->entry_pos = ftell(pck->f);
		uint8_t d[16 + 16 + 4]; /* offset, size, md5, flags (format 2 only) */
		rd(d, pck->version == 2 ? 36 : 32, pck->f);
		e->off = pck_rd32(d) | (uint64_t)pck_rd32(d + 4) << 32;
		e->size = pck_rd32(d + 8) | (uint64_t)pck_rd32(d + 12) << 32;
	}
}

PckEntry *pck_find(Pck *pck, const char *name) {
	for (int i = 0; i < pck->count; i++)
		if (!strcmp(pck->entries[i].name, name))
			return &pck->entries[i];
	return NULL;
}

uint8_t *pck_read(Pck *pck, PckEntry *e) {
	uint8_t *b = malloc(e->size + 1);
	fseek(pck->f, (long)(pck->base + e->off), SEEK_SET);
	if (fread(b, 1, e->size, pck->f) != e->size)
		pck_die("short read", e->name);
	b[e->size] = 0;
	return b;
}

void pck_replace(Pck *pck, PckEntry *e, const void *data, uint64_t size) {
	static const uint8_t zero[16];
	fseek(pck->f, 0, SEEK_END);
	long end = ftell(pck->f);
	fwrite(zero, 1, (16 - end % 16) % 16, pck->f);
	uint64_t off = (uint64_t)ftell(pck->f) - pck->base;
	if (fwrite(data, 1, size, pck->f) != size)
		pck_die("cannot append to pack", e->name);
	uint8_t d[16 + 16];
	pck_wr32(d, (uint32_t)off);
	pck_wr32(d + 4, (uint32_t)(off >> 32));
	pck_wr32(d + 8, (uint32_t)size);
	pck_wr32(d + 12, (uint32_t)(size >> 32));
	memset(d + 16, 0, 16); /* md5 is not checked by the engine */
	fseek(pck->f, e->entry_pos, SEEK_SET);
	fwrite(d, 1, sizeof d, pck->f);
	e->off = off;
	e->size = size;
}

static const char *path_value(const char *text, const char **end) {
	const char *p = strstr(text, "\npath=\"");
	if (!p)
		return NULL;
	p += 7;
	*end = strchr(p, '"');
	return *end ? p : NULL;
}

int pck_import_path(const char *text, char *out, size_t out_size) {
	const char *end, *p = path_value(text, &end);
	if (!p || (size_t)(end - p) >= out_size)
		return 0;
	memcpy(out, p, end - p);
	out[end - p] = 0;
	return 1;
}

void pck_repoint_import(Pck *pck, PckEntry *imp, const char *text, const char *new_path) {
	const char *end, *p = path_value(text, &end);
	if (!p)
		pck_die("no path= in", imp->name);
	size_t n = strlen(text) + strlen(new_path) + 1;
	char *nt = malloc(n);
	int len = snprintf(nt, n, "%.*s%s%s", (int)(p - text), text, new_path, end);
	pck_replace(pck, imp, nt, (uint64_t)len);
	free(nt);
}

void pck_write_file(const char *dir, const char *file, const void *data, size_t size) {
	char path[4096];
	snprintf(path, sizeof path, "%s/%s", dir, file);
	FILE *f = fopen(path, "wb");
	if (!f || fwrite(data, 1, size, f) != size)
		pck_die("cannot write", path);
	fclose(f);
}
