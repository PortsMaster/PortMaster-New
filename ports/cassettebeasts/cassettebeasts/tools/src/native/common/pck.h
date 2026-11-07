/* Minimal Godot pack (format 1 = Godot 3, format 2 = Godot 4) access for the install-time converters:
 * read the directory, read files, and replace a file by appending new data at the end
 * of the pack and rewriting its directory entry in place (the directory never grows). */
#ifndef DK_PCK_H
#define DK_PCK_H
#include <stdint.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
	char *name;
	long entry_pos; /* file position of offset/size/md5 in the directory */
	uint64_t off, size;
} PckEntry;

typedef struct {
	FILE *f;
	int version;   /* 1 = Godot 3, 2 = Godot 4 */
	uint64_t base; /* 0 for format 1 (absolute offsets) */
	int count;
	PckEntry *entries;
} Pck;

void pck_die(const char *msg, const char *arg);
uint32_t pck_rd32(const uint8_t *p);
void pck_wr32(uint8_t *p, uint32_t v);

/* Opens read/write; exits with a message if the file is not a format 1 or 2 pack. */
void pck_open(Pck *pck, const char *path);
PckEntry *pck_find(Pck *pck, const char *name);
/* Returns a malloc'ed, NUL-terminated copy of the file. */
uint8_t *pck_read(Pck *pck, PckEntry *e);
void pck_replace(Pck *pck, PckEntry *e, const void *data, uint64_t size);

/* For a .import remap text: copies the path="..." value into out and returns 1. */
int pck_import_path(const char *text, char *out, size_t out_size);
/* Rewrites the .import entry imp (whose text is given) so path= points at new_path. */
void pck_repoint_import(Pck *pck, PckEntry *imp, const char *text, const char *new_path);
/* Writes data to dir/file, exits on error. */
void pck_write_file(const char *dir, const char *file, const void *data, size_t size);

#ifdef __cplusplus
}
#endif
#endif
