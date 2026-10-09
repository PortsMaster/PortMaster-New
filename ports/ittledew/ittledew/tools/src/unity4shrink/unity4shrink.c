/*
 * unity4shrink: the setup's texture tool for Ittle Dew's Unity 4 (version 9) serialized files, in place.
 *
 * usage: unity4shrink [-q] -l 1|2 FILE...    halve / quarter the large DXT1/DXT5 textures (larger side > 512, no
 *                                             mipmaps, DXT1 without 1-bit alpha): gl4es decodes DXT into RAM, so
 *                                             smaller sprite sheets fit 1 GB devices
 *        unity4shrink [-q] -a [-M] FILE...   re-encode every DXT5 texture (every mip level) as ASTC 4x4 and KEEP the
 *                                             DXT5 label: both take 16 bytes per 4x4 block, and the Unity 4 player has
 *                                             no ASTC upload of its own, so glxsdl relabels DXT5 uploads as ASTC
 *                                             (GLXSDL_DXT5_ASTC). Never twice on a file: it would decode ASTC as DXT5.
 *                                             -M: every texture gets a full mip chain instead (marked as mipmapped),
 *                                             ready-made levels instead of gl4es generating them at load.
 *        -q: no line for files without work. Exit 1 when a file failed or had a DXT5 layout it did not recognise.
 *
 * Texture2D layout: name (int len, bytes, align 4) | width height completeImageSize format | mipMap isReadable
 * readAllowed pad | imageCount dimension | filter aniso mipBias wrap | lightmapFormat colorSpace | image data (int
 * size, bytes). Reductions average 2x2 (4x4) pixels with alpha-weighted colour (transparent pixels do not bleed into
 * edges); shrinks are re-encoded with stb_dxt, ASTC with ARM's astcenc (astc_glue.cpp). The object table is found by
 * scanning the metadata for a count whose 20-byte entries tile the data section (8-byte aligned); the file is written
 * to <file>.tmp with every object in table order and replaces <file> when complete.
 */
#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

#define STB_DXT_IMPLEMENTATION
#define STB_DXT_STATIC
#include "stb_dxt.h"

#define CLASS_TEXTURE2D 28
#define FMT_DXT1 10
#define FMT_DXT5 12
#define UNRECOGNISED " (some DXT5 layouts not recognised!)"

int astc_init(unsigned threads);                              /* astc_glue.cpp */
int astc_encode(uint8_t *rgba, int w, int h, uint8_t *out);

static int levels, astc, mips, quiet;

typedef struct { int w, h, mip, f, bs, todo; size_t q, len; } tex_t;   /* bs: bytes per 4x4 block */   /* q: offset of the width; image data at q + 56 */

static uint32_t be32(const uint8_t *p) { return (uint32_t)p[0] << 24 | p[1] << 16 | p[2] << 8 | p[3]; }
static void put_be32(uint8_t *p, uint32_t v) { p[0] = v >> 24; p[1] = v >> 16; p[2] = v >> 8; p[3] = v; }
static uint32_t le32(const uint8_t *p) { return p[0] | p[1] << 8 | p[2] << 16 | (uint32_t)p[3] << 24; }
static void put_le32(uint8_t *p, uint32_t v) { p[0] = v; p[1] = v >> 8; p[2] = v >> 16; p[3] = v >> 24; }
static int half(int v) { return v > 1 ? v / 2 : 1; }
static size_t level_len(int w, int h) { return (size_t)((w + 3) / 4) * ((h + 3) / 4) * 16; }
static size_t chain_len(int w, int h)
{
    size_t n = level_len(w, h);
    while (w > 1 || h > 1) { w = half(w); h = half(h); n += level_len(w, h); }
    return n;
}

/* bw x bh DXT1 (bs 8) or DXT5 (bs 16) blocks -> RGBA pixels in rows of 4 * bw */
static void rgb565(unsigned c, uint8_t *o)
{
    int r = c >> 11 & 31, g = c >> 5 & 63, b = c & 31;
    o[0] = (r << 3) | (r >> 2); o[1] = (g << 2) | (g >> 4); o[2] = (b << 3) | (b >> 2);
}
static void decode(const uint8_t *b, int bw, int bh, int bs, uint8_t *rgba)
{
    for (int by = 0; by < bh; by++)
        for (int bx = 0; bx < bw; bx++, b += bs) {
            const uint8_t *c = b + bs - 8;                    /* colour part; DXT5 has the alpha part first */
            unsigned c0 = c[0] | c[1] << 8, c1 = c[2] | c[3] << 8, four = bs == 16 || c0 > c1;
            uint8_t pal[4][4] = { [0][3] = 255, [1][3] = 255, [2][3] = 255, [3][3] = four ? 255 : 0 }, a[8] = { b[0], b[1] };
            rgb565(c0, pal[0]); rgb565(c1, pal[1]);
            for (int k = 0; k < 3; k++) {
                pal[2][k] = four ? (2 * pal[0][k] + pal[1][k]) / 3 : (pal[0][k] + pal[1][k]) / 2;
                pal[3][k] = four ? (pal[0][k] + 2 * pal[1][k]) / 3 : 0;
            }
            if (a[0] > a[1]) for (int i = 1; i < 7; i++) a[i + 1] = ((7 - i) * a[0] + i * a[1]) / 7;
            else { for (int i = 1; i < 5; i++) a[i + 1] = ((5 - i) * a[0] + i * a[1]) / 5; a[6] = 0; a[7] = 255; }
            uint64_t ai = 0;
            for (int i = 0; i < 6; i++) ai |= (uint64_t)b[2 + i] << (8 * i);
            uint32_t ci = le32(c + 4);
            for (int i = 0; i < 16; i++) {
                uint8_t *p = rgba + ((size_t)(4 * by + i / 4) * bw * 4 + 4 * bx + i % 4) * 4;
                memcpy(p, pal[ci >> (2 * i) & 3], 4);
                if (bs == 16) p[3] = a[ai >> (3 * i) & 7];
            }
        }
}

/* does a DXT1 image use 1-bit alpha anywhere (a 3-colour block with index 3)? */
static int dxt1_alpha(const uint8_t *d, size_t nblocks)
{
    for (; nblocks--; d += 8)
        if ((d[0] | d[1] << 8) <= (d[2] | d[3] << 8))
            for (int k = 0; k < 16; k++) if ((le32(d + 4) >> (2 * k) & 3) == 3) return 1;
    return 0;
}

/* one pixel of a reduced image: f x f pixels from (x, y) on (step 0 repeats a 1-pixel edge), colour weighted by alpha */
static void avg(const uint8_t *img, size_t stride, int x, int y, int f, int sx, int sy, uint8_t *o)
{
    unsigned a = 0, c[3] = { 0, 0, 0 }, cs[3] = { 0, 0, 0 }, n = f * f;
    for (int dy = 0; dy < f; dy++)
        for (int dx = 0; dx < f; dx++) {
            const uint8_t *p = img + ((size_t)(y + dy * sy) * stride + x + dx * sx) * 4;
            a += p[3];
            for (int k = 0; k < 3; k++) { c[k] += p[k] * p[3]; cs[k] += p[k]; }
        }
    for (int k = 0; k < 3; k++) o[k] = a ? (c[k] + a / 2) / a : (cs[k] + n / 2) / n;
    o[3] = (a + n / 2) / n;
}

/* w x h DXT -> (w/f) x (h/f) DXT, in strips of f block rows so 4096x4096 textures need little memory; one step for
   a quarter avoids a second round of DXT quantisation */
static void shrink(const uint8_t *src, uint8_t *dst, int w, int h, int f, int bs)
{
    int ow = w / f;
    uint8_t *rows = malloc((size_t)w * 16 * f), *out = malloc((size_t)ow * 16), blk[64];
    for (int oby = 0; oby < h / (4 * f); oby++) {
        decode(src + (size_t)oby * f * (w / 4) * bs, w / 4, f, bs, rows);
        for (int y = 0; y < 4; y++)
            for (int x = 0; x < ow; x++) avg(rows, w, f * x, f * y, f, 1, 1, out + ((size_t)y * ow + x) * 4);
        for (int bx = 0; bx < ow / 4; bx++) {
            for (int y = 0; y < 4; y++) memcpy(blk + 16 * y, out + ((size_t)y * ow + 4 * bx) * 4, 16);
            stb_compress_dxt_block(dst + ((size_t)oby * (ow / 4) + bx) * bs, blk, bs == 16, STB_DXT_HIGHQUAL);
        }
    }
    free(rows); free(out);
}

/* level 0 of a w x h DXT5 texture -> ASTC 4x4 chain down to 1x1, each level the 2x2 average of the one above */
static uint8_t *astc_chain(const uint8_t *dxt, int w, int h)
{
    int bw = (w + 3) / 4, bh = (h + 3) / 4, cw = bw * 4;
    uint8_t *out = malloc(chain_len(w, h)), *cur = malloc((size_t)bw * bh * 64), *pad = malloc((size_t)bw * bh * 64);
    decode(dxt, bw, bh, 16, cur);
    for (int lw = w, lh = h, off = 0;;) {
        int qw = (lw + 3) / 4 * 4, qh = (lh + 3) / 4 * 4;
        for (int y = 0; y < qh; y++)                          /* padded to whole blocks by repeating the edge */
            for (int x = 0; x < qw; x++)
                memcpy(pad + ((size_t)y * qw + x) * 4, cur + ((size_t)(y < lh ? y : lh - 1) * cw + (x < lw ? x : lw - 1)) * 4, 4);
        if (astc_encode(pad, qw, qh, out + off)) { free(out); out = NULL; break; }
        off += level_len(lw, lh);
        if (lw == 1 && lh == 1) break;
        int nw = half(lw), nh = half(lh);
        for (int y = 0; y < nh; y++)
            for (int x = 0; x < nw; x++) avg(cur, cw, lw > 1 ? 2 * x : 0, lh > 1 ? 2 * y : 0, 2, lw > 1, lh > 1, pad + ((size_t)y * nw + x) * 4);
        memcpy(cur, pad, (size_t)nw * nh * 4);
        cw = lw = nw; lh = nh;
    }
    free(cur); free(pad);
    return out;
}

/* 1: the mode changes this object (a DXT texture), 0: left alone, -1: DXT5 in a layout not recognised */
static int classify(const uint8_t *o, size_t size, tex_t *t)
{
    if (size < 64) return 0;
    uint32_t nlen = le32(o);
    size_t q = t->q = (4 + (size_t)nlen + 3) & ~(size_t)3;
    uint32_t fmt = nlen > 1024 || q + 60 > size ? 0 : le32(o + q + 12);
    if (!(t->bs = fmt == FMT_DXT5 ? 16 : fmt == FMT_DXT1 && !astc ? 8 : 0)) return 0;
    t->w = (int)le32(o + q); t->h = (int)le32(o + q + 4); t->mip = o[q + 16]; t->len = le32(o + q + 52);
    if (t->w <= 0 || t->h <= 0 || le32(o + q + 20) != 1 || q + 56 + t->len > size ||
        t->len != (t->mip ? chain_len(t->w, t->h) : level_len(t->w, t->h)) / 16 * t->bs) return astc ? -1 : 0;
    if (astc) return 1;
    int k = 0, m = t->w > t->h ? t->w : t->h;
    while (!t->mip && k < levels && (m >> k) > 512 && t->w % (8 << k) == 0 && t->h % (8 << k) == 0) k++;
    t->f = 1 << k;
    return k > 0 && !(t->bs == 8 && dxt1_alpha(o + q + 56, t->len / 8));
}

/* the converted object (malloc'd), *size updated; NULL when the encoder failed */
static uint8_t *convert(const uint8_t *o, size_t *size, const tex_t *t)
{
    size_t img = t->q + 56, len = !astc ? level_len(t->w / t->f, t->h / t->f) / 16 * t->bs : mips ? chain_len(t->w, t->h) : t->len;
    uint8_t *n = malloc(astc && !mips ? *size : img + len);
    memcpy(n, o, astc && !mips ? *size : img);
    if (!astc) {
        put_le32(n + t->q, t->w / t->f); put_le32(n + t->q + 4, t->h / t->f);
        shrink(o + img, n + img, t->w, t->h, t->f, t->bs);
    } else if (mips) {
        uint8_t *chain = astc_chain(o + img, t->w, t->h);
        if (!chain) { free(n); return NULL; }
        memcpy(n + img, chain, len); free(chain);
        n[t->q + 16] = 1;                                     /* m_MipMap */
    } else {
        for (int lw = t->w, lh = t->h, off = img;; off += level_len(lw, lh), lw = half(lw), lh = half(lh)) {
            int bw = (lw + 3) / 4, bh = (lh + 3) / 4, rc;
            uint8_t *rgba = malloc((size_t)bw * bh * 64);
            decode(o + off, bw, bh, 16, rgba);
            rc = astc_encode(rgba, bw * 4, bh * 4, n + off);
            free(rgba);
            if (rc) { free(n); return NULL; }
            if (!t->mip || (lw == 1 && lh == 1)) break;
        }
        return n;
    }
    put_le32(n + t->q + 8, len); put_le32(n + t->q + 52, len);   /* completeImageSize, image data size */
    *size = img + len;
    return n;
}

static int find_table(const uint8_t *m, size_t data_off, size_t file_size, size_t *table, uint32_t *count)
{
    for (size_t p = 20; p + 24 < data_off; p += 4) {
        int32_t n = (int32_t)le32(m + p);
        if (n <= 0 || p + 4 + 20 * (size_t)n > data_off) continue;
        size_t pos = 0; int32_t i = 0;
        for (; i < n && le32(m + p + 8 + 20 * (size_t)i) == (i ? (pos + 7) & ~(size_t)7 : 0); i++)
            pos = le32(m + p + 8 + 20 * (size_t)i) + (size_t)le32(m + p + 12 + 20 * (size_t)i);
        if (i == n && pos == file_size - data_off) { *table = p; *count = (uint32_t)n; return 0; }
    }
    return -1;
}

static int write_all(int fd, const void *buf, size_t n)
{
    for (const uint8_t *b = buf; n;) {
        ssize_t w = write(fd, b, n > (1 << 22) ? (1 << 22) : n);
        if (w < 0) { if (errno == EINTR) continue; return -1; }
        b += w; n -= (size_t)w;
    }
    return 0;
}

static int process(const char *path)
{
    static const uint8_t zeros[8];
    const char *base = strrchr(path, '/'); base = base ? base + 1 : path;
    char tmp[4096]; snprintf(tmp, sizeof tmp, "%s.tmp", path);
    int fd = open(path, O_RDONLY), out = -1, rc = 1, n = 0, bad = 0;
    struct stat st;
    const uint8_t *m = MAP_FAILED;
    size_t fsize = 0, data_off, table; uint32_t count;
    uint64_t pos = 0, before = 0, after = 0;
    tex_t *t = NULL; uint8_t *head = NULL;
    if (fd < 0 || fstat(fd, &st) || (m = mmap(NULL, fsize = (size_t)st.st_size, PROT_READ, MAP_PRIVATE, fd, 0)) == MAP_FAILED) {
        fprintf(stderr, "%s: %s\n", path, strerror(errno)); goto done;
    }
    data_off = be32(m + 12);
    if (fsize < 32 || be32(m + 8) != 9 || m[16] || be32(m + 4) != fsize || data_off >= fsize || find_table(m, data_off, fsize, &table, &count)) {
        fprintf(stderr, "%s: not a Unity 4 (version 9) serialized file with an object table\n", path); goto done;
    }
    t = calloc(count, sizeof *t);
    for (uint32_t i = 0; i < count; i++) {
        const uint8_t *r = m + table + 4 + 20 * (size_t)i;
        int c = (r[16] | r[17] << 8) == CLASS_TEXTURE2D ? classify(m + data_off + le32(r + 4), le32(r + 8), &t[i]) : 0;
        bad += c < 0; n += t[i].todo = c > 0;
    }
    if (!n) {
        if (!quiet || bad) printf("%s: nothing to do%s\n", base, bad ? UNRECOGNISED : "");
        rc = bad > 0; goto done;
    }
    head = malloc(data_off); memcpy(head, m, data_off);          /* header and table, rewritten once sizes are known */
    if ((out = open(tmp, O_WRONLY | O_CREAT | O_TRUNC, 0644)) < 0 || write_all(out, head, data_off)) goto fail;
    for (uint32_t i = 0; i < count; i++) {
        uint8_t *r = head + table + 4 + 20 * (size_t)i, *nobj = NULL;
        const uint8_t *obj = m + data_off + le32(r + 4);
        size_t size = le32(r + 8);
        if (write_all(out, zeros, (size_t)(((pos + 7) & ~(uint64_t)7) - pos))) goto fail;
        pos = (pos + 7) & ~(uint64_t)7;
        if (t[i].todo) {
            if (!(nobj = convert(obj, &size, &t[i]))) goto fail;
            before += t[i].len; after += le32(nobj + t[i].q + 52);
        }
        int e = write_all(out, nobj ? nobj : obj, size);
        free(nobj);
        if (e) goto fail;
        put_le32(r + 4, (uint32_t)pos); put_le32(r + 8, (uint32_t)size);
        pos += size;
    }
    put_be32(head + 4, (uint32_t)(data_off + pos));
    if (pwrite(out, head, data_off, 0) != (ssize_t)data_off || fsync(out)) goto fail;
    rc = close(out); out = -1;
    munmap((void *)m, fsize); m = MAP_FAILED; close(fd); fd = -1;
    if (rc || rename(tmp, path)) goto fail;
    printf("%s: %d textures %s, %.1f -> %.1f MB%s\n", base, n, !astc ? "shrunk" : mips ? "re-encoded as ASTC 4x4 with mipmaps" :
           "re-encoded as ASTC 4x4", before / 1048576.0, after / 1048576.0, bad ? UNRECOGNISED : "");
    rc = bad > 0; goto done;
fail:
    fprintf(stderr, "%s: %s\n", tmp, strerror(errno));
    if (out >= 0) close(out);
    unlink(tmp); rc = 1;
done:
    free(t); free(head);
    if (m != MAP_FAILED) munmap((void *)m, fsize);
    if (fd >= 0) close(fd);
    return rc;
}

int main(int argc, char **argv)
{
    int i = 1, rc = 0;
    for (; i < argc && argv[i][0] == '-'; i++)
        if (!strcmp(argv[i], "-q")) quiet = 1;
        else if (!strcmp(argv[i], "-a")) astc = 1;
        else if (!strcmp(argv[i], "-M")) mips = 1;
        else if (!strcmp(argv[i], "-l") && i + 1 < argc) levels = atoi(argv[++i]);
        else break;
    if (i == argc || argv[i][0] == '-' || (!astc && (levels < 1 || levels > 2))) {
        fprintf(stderr, "usage: %s [-q] -l 1|2 FILE... | [-q] -a [-M] FILE...\n", argv[0]); return 2;
    }
    setvbuf(stdout, NULL, _IOLBF, 0);
    if (astc && astc_init((unsigned)sysconf(_SC_NPROCESSORS_ONLN))) return 1;
    for (; i < argc; i++) rc |= process(argv[i]);
    return rc;
}
