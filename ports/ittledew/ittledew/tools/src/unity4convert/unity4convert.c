/* unity4convert: rewrite a Unity 4.x game's data folder in place to Unity 4.7.2's serialized format, so the kit's
 * donor (a Unity 4.7.2 Linux player) runs games built with any Unity 4 version. C port of u4convert.py (the PC
 * reference in Shared/unity4kit/donor/u4convert; both must write the same bytes).
 *
 *  usage: unity4convert [-n] [--donor <donor mainData>] <game _Data folder>        -n: report only, write nothing
 *
 * Engine objects: a class whose layout differs between the game's version and 4.7.2 (the layout reference
 * u4layouts.inc, from AssetRipper's TypeTreeDumps) is read with the old layout and written with the new one: fields
 * copied by name, new fields from DEFAULTS, else the donor's value (global managers), else zero / empty. Script
 * objects (MonoBehaviour): layouts generated from the game's assemblies (the .dll files in Managed) with each version's rules
 * ([Serializable] structs saved from 4.5.0, sbyte from 4.6.2; measured with a probe built by eleven editors); a
 * script whose layouts differ is rewritten the same way. Every rewritten object is read back with the new layout and
 * must use exactly its own bytes. Files: levelN, *.assets, Resources/unity_builtin_extra, then mainData last;
 * files already marked 4.7.2f1 are skipped, so an
 * interrupted run carries on. Every file's version string becomes 4.7.2f1.
 * Exit 0 = done, 1 = error (message on stderr). Own code, 0BSD. */
#define _GNU_SOURCE
#include <dirent.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>

#define TARGET "4.7.2"
#define TARGET_FULL "4.7.2f1"
#define MAX_DEPTH 10
static const int STRUCTS_FROM[3] = {4, 5, 0}, SBYTE_FROM[3] = {4, 6, 2}, RULES_SAME_FROM[3] = {4, 6, 2};

static void die(const char *fmt, ...)
{
    va_list a;
    va_start(a, fmt);
    fprintf(stderr, "unity4convert: ");
    vfprintf(stderr, fmt, a);
    fprintf(stderr, "\n");
    va_end(a);
    exit(1);
}
static void *xcalloc(size_t n, size_t s) { void *p = calloc(n ? n : 1, s); if (!p) die("out of memory"); return p; }
static char *xstrdup(const char *s) { char *p = strdup(s); if (!p) die("out of memory"); return p; }
static uint32_t le32(const uint8_t *p) { return p[0] | p[1] << 8 | p[2] << 16 | (uint32_t)p[3] << 24; }
static uint16_t le16(const uint8_t *p) { return p[0] | p[1] << 8; }
static uint32_t be32(const uint8_t *p) { return (uint32_t)p[0] << 24 | p[1] << 16 | p[2] << 8 | p[3]; }

/* ---------------------------------------------------------------------------------------------- layout nodes */
typedef struct Node {
    const char *type, *name;
    int size, align, nkids;
    struct Node **kids;
} Node;

static Node *mk(const char *type, const char *name, int size, int align, int nkids, ...)
{
    Node *n = xcalloc(1, sizeof *n);
    n->type = type; n->name = name; n->size = size; n->align = align; n->nkids = nkids;
    n->kids = xcalloc(nkids, sizeof(Node *));
    va_list a;
    va_start(a, nkids);
    for (int i = 0; i < nkids; i++) n->kids[i] = va_arg(a, Node *);
    va_end(a);
    return n;
}
static Node *mk_kids(const char *type, const char *name, int size, int align, Node **kids, int nkids)
{
    Node *n = mk(type, name, size, align, 0);
    n->kids = kids; n->nkids = nkids;
    return n;
}
static int tree_eq(const Node *a, const Node *b)      /* u4convert.py flat(a) == flat(b) */
{
    if (a == b) return 1;
    if (strcmp(a->type, b->type) || strcmp(a->name, b->name) || a->align != b->align || a->nkids != b->nkids) return 0;
    for (int i = 0; i < a->nkids; i++) if (!tree_eq(a->kids[i], b->kids[i])) return 0;
    return 1;
}
static int kid_index(const Node *n, const char *name)
{
    for (int i = 0; i < n->nkids; i++) if (!strcmp(n->kids[i]->name, name)) return i;
    return -1;
}

/* the reference: u4layouts.inc */
static const uint8_t U4L[] = {
#include "u4layouts.inc"
};
static int nver;
static char vers[64][16];
static Node *ref_nodes;
typedef struct { int id, nlay; uint64_t *mask; Node **root; } RefClass;
static RefClass *ref_cls;
static int nref_cls;

static void load_reference(void)
{
    const uint8_t *p = U4L;
    if (memcmp(p, "U4L1", 4)) die("bad layout reference");
    p += 4;
    nver = le16(p); p += 2;
    for (int i = 0; i < nver; i++) { int l = *p++; memcpy(vers[i], p, l); vers[i][l] = 0; p += l; }
    uint32_t ns = le32(p); p += 4;
    char **str = xcalloc(ns, sizeof(char *));
    for (uint32_t i = 0; i < ns; i++) { int l = le16(p); p += 2; str[i] = xcalloc(l + 1, 1); memcpy(str[i], p, l); p += l; }
    uint32_t nn = le32(p); p += 4;
    ref_nodes = xcalloc(nn, sizeof(Node));
    const uint8_t *nodes = p;
    p += nn * 19;
    uint32_t nk = le32(p); p += 4;
    const uint8_t *kidl = p;
    p += nk * 4;
    for (uint32_t i = 0; i < nn; i++) {
        const uint8_t *r = nodes + i * 19;
        Node *n = &ref_nodes[i];
        n->type = str[le32(r)]; n->name = str[le32(r + 4)]; n->size = (int32_t)le32(r + 8); n->align = r[12];
        n->nkids = le16(r + 13);
        n->kids = xcalloc(n->nkids, sizeof(Node *));
        uint32_t first = le32(r + 15);
        for (int k = 0; k < n->nkids; k++) n->kids[k] = &ref_nodes[le32(kidl + 4 * (first + k))];
    }
    nref_cls = le32(p); p += 4;
    ref_cls = xcalloc(nref_cls, sizeof(RefClass));
    for (int i = 0; i < nref_cls; i++) {
        RefClass *c = &ref_cls[i];
        c->id = (int32_t)le32(p); c->nlay = le16(p + 4); p += 6;
        c->mask = xcalloc(c->nlay, 8); c->root = xcalloc(c->nlay, sizeof(Node *));
        for (int k = 0; k < c->nlay; k++) {
            uint64_t m = 0;
            for (int b = 0; b < 8; b++) m |= (uint64_t)p[b] << (8 * b);
            c->mask[k] = m; c->root[k] = &ref_nodes[le32(p + 8)]; p += 12;
        }
    }
}
static int version_index(const char *v)
{
    for (int i = 0; i < nver; i++) if (!strcmp(vers[i], v)) return i;
    return -1;
}
static Node *ref_tree(int cid, int vi)
{
    for (int i = 0; i < nref_cls; i++)
        if (ref_cls[i].id == cid)
            for (int k = 0; k < ref_cls[i].nlay; k++) if (ref_cls[i].mask[k] >> vi & 1) return ref_cls[i].root[k];
    return NULL;
}

/* ---------------------------------------------------------------------------------------------- values */
enum { V_NUM, V_BYTES, V_ARRAY, V_STRUCT };
typedef struct Value {
    int kind, n;                 /* V_BYTES: n bytes; V_ARRAY / V_STRUCT: n items */
    int64_t i;                   /* integers and bool */
    double f;                    /* float / double read or set as a number */
    uint64_t raw; int has_raw;   /* the bits as read (written back unchanged when the type is the same) */
    const char *ptype;           /* primitive type it was read as */
    uint8_t *b;
    struct Value **items;
    const Node *node;            /* V_STRUCT: names of the items */
} Value;

typedef struct { char type[16]; int size; char kind; } Prim;   /* kind: i signed, u unsigned, f float, b bool */
static const Prim PRIMS[] = {
    {"bool", 1, 'b'}, {"char", 1, 'i'}, {"UInt8", 1, 'u'}, {"SInt8", 1, 'i'}, {"SInt16", 2, 'i'}, {"UInt16", 2, 'u'},
    {"int", 4, 'i'}, {"unsigned int", 4, 'u'}, {"float", 4, 'f'}, {"double", 8, 'f'}, {"SInt64", 8, 'i'},
    {"UInt64", 8, 'u'}};
static const Prim *prim(const char *t)
{
    for (size_t k = 0; k < sizeof PRIMS / sizeof *PRIMS; k++) if (!strcmp(PRIMS[k].type, t)) return &PRIMS[k];
    return NULL;
}
static int is_array_node(const Node *n, const Node **arr)
{
    if (!strcmp(n->type, "Array")) { *arr = n; return 1; }
    if (n->nkids == 1 && !strcmp(n->kids[0]->type, "Array")) { *arr = n->kids[0]; return 1; }
    return 0;
}
static Value *vnew(int kind) { Value *v = xcalloc(1, sizeof *v); v->kind = kind; return v; }
static Value *vnum(int64_t i) { Value *v = vnew(V_NUM); v->i = i; v->f = (double)i; return v; }
static Value *vfloat(double f) { Value *v = vnew(V_NUM); v->f = f; v->i = (int64_t)f; return v; }

typedef struct { const uint8_t *b; size_t len, p; int err; } Reader;
static void r_align(Reader *r) { r->p = (r->p + 3) & ~(size_t)3; }

static Value *rd(Reader *r, const Node *n)
{
    if (r->err) return NULL;
    const Prim *pr = n->nkids ? NULL : prim(n->type);
    const Node *arr;
    Value *v;
    if (pr) {
        if (r->p + pr->size > r->len) { r->err = 1; return NULL; }
        const uint8_t *q = r->b + r->p;
        uint64_t raw = 0;
        for (int k = 0; k < pr->size; k++) raw |= (uint64_t)q[k] << (8 * k);
        v = vnew(V_NUM); v->raw = raw; v->has_raw = 1; v->ptype = pr->type;
        if (pr->kind == 'f') {
            if (pr->size == 4) { float f; uint32_t u = (uint32_t)raw; memcpy(&f, &u, 4); v->f = f; }
            else { double d; memcpy(&d, &raw, 8); v->f = d; }
            v->i = (int64_t)v->f;
        } else if (pr->kind == 'i') {
            int sh = 64 - 8 * pr->size;
            v->i = (int64_t)(raw << sh) >> sh; v->f = (double)v->i;
        } else {
            v->i = (int64_t)raw; v->f = (double)raw;
        }
        r->p += pr->size;
    } else if (!strcmp(n->type, "string") || !strcmp(n->type, "TypelessData")) {
        if (r->p + 4 > r->len) { r->err = 1; return NULL; }
        int32_t size = (int32_t)le32(r->b + r->p);
        if (size < 0 || r->p + 4 + (size_t)size > r->len) { r->err = 1; return NULL; }
        v = vnew(V_BYTES); v->n = size; v->b = xcalloc(size, 1); memcpy(v->b, r->b + r->p + 4, size);
        r->p += 4 + size;
        if (!strcmp(n->type, "string") && n->nkids && n->kids[0]->align) r_align(r);
    } else if (is_array_node(n, &arr)) {
        if (r->p + 4 > r->len) { r->err = 1; return NULL; }
        int32_t size = (int32_t)le32(r->b + r->p);
        if (size < 0 || (size_t)size > r->len) { r->err = 1; return NULL; }
        r->p += 4;
        v = vnew(V_ARRAY); v->n = size; v->items = xcalloc(size, sizeof(Value *));
        for (int k = 0; k < size && !r->err; k++) v->items[k] = rd(r, arr->kids[1]);
        if (arr != n && arr->align) r_align(r);
    } else {
        v = vnew(V_STRUCT); v->node = n; v->n = n->nkids; v->items = xcalloc(n->nkids, sizeof(Value *));
        for (int k = 0; k < n->nkids && !r->err; k++) v->items[k] = rd(r, n->kids[k]);
    }
    if (r->err) return NULL;
    if (n->align) r_align(r);
    return v;
}

typedef struct { uint8_t *b; size_t len, cap; } Buf;
static void put(Buf *w, const void *d, size_t n)
{
    if (w->len + n > w->cap) { w->cap = (w->len + n) * 2 + 256; w->b = realloc(w->b, w->cap); if (!w->b) die("out of memory"); }
    memcpy(w->b + w->len, d, n);
    w->len += n;
}
static void w_align(Buf *w) { static const uint8_t z[4]; put(w, z, (4 - w->len % 4) % 4); }
static void put_le(Buf *w, uint64_t v, int size) { uint8_t t[8]; for (int k = 0; k < size; k++) t[k] = v >> (8 * k); put(w, t, size); }

static int wr(Buf *w, const Node *n, const Value *v)
{
    const Prim *pr = n->nkids ? NULL : prim(n->type);
    const Node *arr;
    if (!v) return 0;
    if (pr) {
        if (v->kind != V_NUM) return 0;
        if (v->has_raw && v->ptype && !strcmp(v->ptype, pr->type)) put_le(w, v->raw, pr->size);
        else if (pr->kind == 'f' && pr->size == 4) { float f = (float)v->f; uint32_t u; memcpy(&u, &f, 4); put_le(w, u, 4); }
        else if (pr->kind == 'f') { double d = v->f; uint64_t u; memcpy(&u, &d, 8); put_le(w, u, 8); }
        else if (pr->kind == 'b') put_le(w, v->i ? 1 : 0, 1);
        else put_le(w, (uint64_t)v->i, pr->size);
    } else if (!strcmp(n->type, "string") || !strcmp(n->type, "TypelessData")) {
        if (v->kind != V_BYTES) return 0;
        put_le(w, (uint32_t)v->n, 4);
        put(w, v->b, v->n);
        if (!strcmp(n->type, "string") && n->nkids && n->kids[0]->align) w_align(w);
    } else if (is_array_node(n, &arr)) {
        if (v->kind != V_ARRAY) return 0;
        put_le(w, (uint32_t)v->n, 4);
        for (int k = 0; k < v->n; k++) if (!wr(w, arr->kids[1], v->items[k])) return 0;
        if (arr != n && arr->align) w_align(w);
    } else {
        if (v->kind != V_STRUCT) return 0;
        for (int k = 0; k < n->nkids; k++) {
            int j = v->node == n ? k : kid_index(v->node, n->kids[k]->name);
            if (j < 0 || !wr(w, n->kids[k], v->items[j])) return 0;
        }
    }
    if (n->align) w_align(w);
    return 1;
}

static Value *defval(const Node *n)
{
    const Prim *pr = n->nkids ? NULL : prim(n->type);
    const Node *arr;
    if (pr) return vnum(0);
    if (!strcmp(n->type, "string") || !strcmp(n->type, "TypelessData")) return vnew(V_BYTES);
    if (is_array_node(n, &arr)) return vnew(V_ARRAY);
    Value *v = vnew(V_STRUCT);
    v->node = n; v->n = n->nkids; v->items = xcalloc(n->nkids, sizeof(Value *));
    for (int k = 0; k < n->nkids; k++) v->items[k] = defval(n->kids[k]);
    return v;
}
static Value *field(const Value *v, const char *name)
{
    if (!v || v->kind != V_STRUCT) return NULL;
    int j = kid_index(v->node, name);
    return j < 0 ? NULL : v->items[j];
}

/* new fields where 0 would change behaviour (Unity's own defaults) */
static const struct { const char *path; double v; } DEFAULTS[] = {
    {"Camera/m_StereoConvergence", 10.0}, {"Camera/m_StereoSeparation", 0.022}};
static uint32_t *sorting_ids;
static int nsorting = 1;
static uint32_t sorting_default = 0;

static Value *special(const char *f, const Value *old)
{
    Value *o;
    if (!strcmp(f, "m_SortingLayerID") && (o = field(old, "m_SortingLayer"))) {   /* before 4.5: index into TagManager */
        int64_t i = o->i;
        return vnum(i >= 0 && i < nsorting ? (sorting_ids ? sorting_ids[i] : 0) : 0);
    }
    if (!strcmp(f, "m_UpdateMode") && (o = field(old, "m_AnimatePhysics"))) return vnum(o->i ? 1 : 0);
    return NULL;
}

static Value *convert(const Node *on, Value *ov, const Node *nn, const char *path, const Value *donor)
{
    if (tree_eq(on, nn)) return ov;
    if (!nn->nkids && !on->nkids && nn->size == 0 && on->size == 0) {          /* empty in both, only renamed */
        Value *v = vnew(V_STRUCT); v->node = nn; return v;
    }
    if (nn->nkids && !on->nkids && (!ov || (ov->kind == V_STRUCT && ov->n == 0))) {   /* an empty old object */
        Node *empty = xcalloc(1, sizeof *empty);
        *empty = *on; empty->nkids = 0; on = empty;
        ov = vnew(V_STRUCT); ov->node = on;
    }
    if (!nn->nkids || !ov || ov->kind != V_STRUCT) return NULL;
    if ((!strcmp(nn->type, "Array")) != (!strcmp(on->type, "Array")) || (!strcmp(nn->type, "string")) != (!strcmp(on->type, "string")))
        return NULL;
    Value *out = vnew(V_STRUCT);
    out->node = nn; out->n = nn->nkids; out->items = xcalloc(nn->nkids, sizeof(Value *));
    for (int k = 0; k < nn->nkids; k++) {
        const Node *c = nn->kids[k];
        char p[512];
        snprintf(p, sizeof p, "%s/%s", path, c->name);
        const Value *dv = field(donor, c->name);
        int j = kid_index(on, c->name);
        if (j >= 0 && ov->node && kid_index(ov->node, c->name) >= 0) {
            Value *v = convert(on->kids[j], ov->items[kid_index(ov->node, c->name)], c, p, dv);
            if (v) { out->items[k] = v; continue; }
        }
        Value *sp = special(c->name, ov);
        if (sp) { out->items[k] = sp; continue; }
        const char *tail = strchr(p, '/') ? strchr(p, '/') + 1 : p;
        int d = -1;
        for (size_t q = 0; q < sizeof DEFAULTS / sizeof *DEFAULTS; q++)
            if (!strcmp(DEFAULTS[q].path, tail) || !strcmp(DEFAULTS[q].path, p)) d = (int)q;
        if (d >= 0) out->items[k] = vfloat(DEFAULTS[d].v);
        else if (dv) out->items[k] = (Value *)dv;
        else out->items[k] = defval(c);
    }
    return out;
}

/* ---------------------------------------------------------------------------------------------- Unity 4 files */
typedef struct { int32_t path; uint32_t start, size; int32_t type; int16_t cls, destroyed; } Entry;
typedef struct {
    char *path;
    int fd;
    uint8_t *m;
    size_t len, data_off, table;
    int n;
    Entry *e;
} UFile;

static int uf_open(UFile *u, const char *path)
{
    memset(u, 0, sizeof *u);
    u->path = xstrdup(path);
    u->fd = open(path, O_RDONLY);
    struct stat st;
    if (u->fd < 0 || fstat(u->fd, &st) || st.st_size < 32) { if (u->fd >= 0) close(u->fd); return 0; }
    u->len = st.st_size;
    u->m = mmap(NULL, u->len, PROT_READ, MAP_SHARED, u->fd, 0);
    if (u->m == MAP_FAILED) { close(u->fd); return 0; }
    if (be32(u->m + 8) != 9 || u->m[16] != 0 || be32(u->m + 4) != u->len) goto bad;
    u->data_off = be32(u->m + 12);
    size_t data_len = u->len - u->data_off;
    for (size_t p = 20; p + 24 < u->data_off; p += 4) {
        int32_t n = (int32_t)le32(u->m + p);
        if (n <= 0 || p + 4 + 20 * (size_t)n > u->data_off) continue;
        size_t pos = 0;
        int i;
        for (i = 0; i < n; i++) {
            const uint8_t *r = u->m + p + 4 + 20 * i;
            size_t start = le32(r + 4), size = le32(r + 8);
            if (start != (i ? (pos + 7) & ~(size_t)7 : 0)) break;
            pos = start + size;
        }
        if (i == n && pos == data_len) {
            u->table = p; u->n = n; u->e = xcalloc(n, sizeof(Entry));
            for (i = 0; i < n; i++) {
                const uint8_t *r = u->m + p + 4 + 20 * i;
                u->e[i] = (Entry){(int32_t)le32(r), le32(r + 4), le32(r + 8), (int32_t)le32(r + 12),
                                  (int16_t)le16(r + 16), (int16_t)le16(r + 18)};
            }
            return 1;
        }
    }
bad:
    munmap(u->m, u->len); close(u->fd);
    return 0;
}
static void uf_close(UFile *u)
{
    if (u->m) { munmap(u->m, u->len); close(u->fd); u->m = NULL; }
}
static const uint8_t *uf_raw(UFile *u, int i) { return u->m + u->data_off + u->e[i].start; }
static int uf_find(UFile *u, int cls) { for (int i = 0; i < u->n; i++) if (u->e[i].cls == cls) return i; return -1; }

/* externals (file IDs 1..): the metadata after the object table */
static int uf_externals(UFile *u, char ***out)
{
    size_t p = u->table + 4 + 20 * (size_t)u->n;
    int n = (int32_t)le32(u->m + p);
    p += 4;
    char **x = xcalloc(n, sizeof(char *));
    for (int k = 0; k < n; k++) {
        p += strnlen((char *)u->m + p, u->data_off - p) + 1;
        p += 20;
        size_t l = strnlen((char *)u->m + p, u->data_off - p);
        x[k] = xcalloc(l + 1, 1); memcpy(x[k], u->m + p, l);
        p += l + 1;
    }
    *out = x;
    return n;
}

/* the file with objects replaced (new[i] / nlen[i]), streamed to <path>.tmp, then put in place (unity4file.py) */
static void uf_rewrite(UFile *u, uint8_t **nw, size_t *nlen)
{
    uint8_t *head = xcalloc(u->data_off, 1);
    memcpy(head, u->m, u->data_off);
    size_t *start = xcalloc(u->n, sizeof(size_t)), *size = xcalloc(u->n, sizeof(size_t)), pos = 0;
    for (int i = 0; i < u->n; i++) {
        pos = (pos + 7) & ~(size_t)7;
        start[i] = pos;
        size[i] = nw[i] ? nlen[i] : u->e[i].size;
        uint8_t *r = head + u->table + 4 + 20 * i;
        uint32_t s = (uint32_t)pos, z = (uint32_t)size[i];
        memcpy(r + 4, &s, 4); memcpy(r + 8, &z, 4);           /* little-endian hosts only (x86_64, aarch64) */
        pos += size[i];
    }
    uint32_t total = (uint32_t)(u->data_off + pos);
    head[4] = total >> 24; head[5] = total >> 16; head[6] = total >> 8; head[7] = total;
    char tmp[4096];
    snprintf(tmp, sizeof tmp, "%s.tmp", u->path);
    FILE *f = fopen(tmp, "wb");
    if (!f) die("%s: cannot write", tmp);
    fwrite(head, 1, u->data_off, f);
    size_t written = 0;
    static const uint8_t zero[8];
    for (int i = 0; i < u->n; i++) {
        fwrite(zero, 1, start[i] - written, f);
        if (nw[i]) fwrite(nw[i], 1, nlen[i], f);
        else fwrite(uf_raw(u, i), 1, size[i], f);
        written = start[i] + size[i];
    }
    if (fflush(f) || fsync(fileno(f)) || ferror(f)) die("%s: write failed", tmp);
    fclose(f);
    uf_close(u);
    if (rename(tmp, u->path)) die("%s: cannot replace", u->path);
    free(head); free(start); free(size);
}

static int file_version(const char *path, char *ver)  /* the Unity version string in the first 64 bytes */
{
    uint8_t b[64];
    FILE *f = fopen(path, "rb");
    if (!f) return 0;
    size_t n = fread(b, 1, 64, f);
    fclose(f);
    for (size_t p = 0; p + 6 < n; p++) {
        if (b[p] < '0' || b[p] > '9' || b[p + 1] != '.') continue;
        size_t q = p + 2, dots = 1;
        while (q < n && ((b[q] >= '0' && b[q] <= '9') || b[q] == '.')) { if (b[q] == '.') dots++; q++; }
        if (dots != 2 || q >= n || !strchr("abfp", b[q])) continue;
        size_t r = q + 1;
        while (r < n && b[r] >= '0' && b[r] <= '9') r++;
        if (r == q + 1 || r >= n || b[r] != 0) continue;
        memcpy(ver, b + p, r - p); ver[r - p] = 0;
        return (int)p + 1;
    }
    return 0;
}
static void set_version(const char *path)
{
    char v[64];
    int at = file_version(path, v);
    if (!at) return;
    if (strlen(v) != strlen(TARGET_FULL)) die("%s: version %s cannot be rewritten", path, v);
    FILE *f = fopen(path, "r+b");
    if (!f || fseek(f, at - 1, SEEK_SET) || fwrite(TARGET_FULL, 1, strlen(TARGET_FULL), f) != strlen(TARGET_FULL)) die("%s: write failed", path);
    fclose(f);
}

/* ---------------------------------------------------------------------------------------------- .NET metadata */
typedef struct Asm {
    char name[256];
    uint8_t *data; size_t len;
    const uint8_t *strings, *blob, *tables;
    uint32_t rows[64];
    const uint8_t *tab[64];
    int rowsize[64];
    int str4, blob4, guid4;
    uint8_t *serfield;          /* [Field row] = has [SerializeField] */
} Asm;
enum { T_TypeRef = 1, T_TypeDef = 2, T_Field = 4, T_MethodDef = 6, T_MemberRef = 10, T_CustomAttribute = 12, T_TypeSpec = 27 };

/* column kinds: 'h' u16, 'w' u32, 'b' u8, 's' string, 'g' guid, 'B' blob, digit/letter = simple index / coded */
static const char *SCHEMA[45] = {
    /* 0 Module */ "hsggg", /* 1 TypeRef */ "Rss", /* 2 TypeDef */ "wssTFM", /* 3 FieldPtr */ "F", /* 4 Field */ "hsB",
    /* 5 MethodPtr */ "M", /* 6 MethodDef */ "whhsBP", /* 7 ParamPtr */ "P", /* 8 Param */ "hhs", /* 9 InterfaceImpl */ "DT",
    /* 10 MemberRef */ "XsB", /* 11 Constant */ "bbCB", /* 12 CustomAttribute */ "AYB", /* 13 FieldMarshal */ "ZB",
    /* 14 DeclSecurity */ "hSB", /* 15 ClassLayout */ "hwD", /* 16 FieldLayout */ "wF", /* 17 StandAloneSig */ "B",
    /* 18 EventMap */ "DE", /* 19 EventPtr */ "E", /* 20 Event */ "hsT", /* 21 PropertyMap */ "DQ", /* 22 PropertyPtr */ "Q",
    /* 23 Property */ "hsB", /* 24 MethodSemantics */ "hMG", /* 25 MethodImpl */ "DOO", /* 26 ModuleRef */ "s",
    /* 27 TypeSpec */ "B", /* 28 ImplMap */ "hKsU", /* 29 FieldRVA */ "wF", /* 30 EncLog */ "ww", /* 31 EncMap */ "w",
    /* 32 Assembly */ "whhhhwBss", /* 33 AssemblyProcessor */ "w", /* 34 AssemblyOS */ "www",
    /* 35 AssemblyRef */ "hhhhwBssB", /* 36 AssemblyRefProcessor */ "wN", /* 37 AssemblyRefOS */ "wwwN",
    /* 38 File */ "wsB", /* 39 ExportedType */ "wwssI", /* 40 ManifestResource */ "wwsI", /* 41 NestedClass */ "DD",
    /* 42 GenericParam */ "hhVs", /* 43 MethodSpec */ "OB", /* 44 GenericParamConstraint */ "WT"};
/* coded indexes: tag bits + tables (-1 = unused slot) */
typedef struct { char c; int bits, n; int t[24]; } Coded;
static const Coded CODED[] = {
    {'T', 2, 3, {2, 1, 27}},                                  /* TypeDefOrRef */
    {'R', 2, 4, {0, 26, 35, 1}},                              /* ResolutionScope */
    {'X', 3, 5, {2, 1, 26, 6, 27}},                           /* MemberRefParent */
    {'C', 2, 3, {4, 8, 23}},                                  /* HasConstant */
    {'A', 5, 22, {6, 4, 1, 2, 8, 9, 10, 0, 14, 23, 20, 17, 26, 27, 32, 35, 38, 39, 40, 42, 44, 43}},   /* HasCustomAttribute */
    {'Y', 3, 5, {-1, -1, 6, 10, -1}},                         /* CustomAttributeType */
    {'Z', 1, 2, {4, 8}},                                      /* HasFieldMarshal */
    {'S', 2, 3, {2, 6, 32}},                                  /* HasDeclSecurity */
    {'G', 1, 2, {20, 23}},                                    /* HasSemantics */
    {'O', 1, 2, {6, 10}},                                     /* MethodDefOrRef */
    {'K', 1, 2, {4, 6}},                                      /* MemberForwarded */
    {'I', 2, 3, {38, 35, 39}},                                /* Implementation */
    {'V', 1, 2, {2, 6}},                                      /* TypeOrMethodDef */
};
static const struct { char c; int t; } SIMPLE[] = {{'F', 4}, {'M', 6}, {'P', 8}, {'D', 2}, {'E', 20}, {'Q', 23}, {'U', 26},
                                                   {'N', 35}, {'W', 42}};

static int col_size(const Asm *a, char c)
{
    switch (c) {
    case 'h': return 2; case 'w': return 4; case 'b': return 1;
    case 's': return a->str4 ? 4 : 2; case 'g': return a->guid4 ? 4 : 2; case 'B': return a->blob4 ? 4 : 2;
    }
    for (size_t k = 0; k < sizeof SIMPLE / sizeof *SIMPLE; k++)
        if (SIMPLE[k].c == c) return a->rows[SIMPLE[k].t] < 65536 ? 2 : 4;
    for (size_t k = 0; k < sizeof CODED / sizeof *CODED; k++)
        if (CODED[k].c == c) {
            uint32_t mx = 0;
            for (int j = 0; j < CODED[k].n; j++) if (CODED[k].t[j] >= 0 && a->rows[CODED[k].t[j]] > mx) mx = a->rows[CODED[k].t[j]];
            return mx < (1u << (16 - CODED[k].bits)) ? 2 : 4;
        }
    die("schema column %c", c);
    return 0;
}
static uint32_t col(const Asm *a, int table, uint32_t row, int column)   /* row 1-based */
{
    const uint8_t *r = a->tab[table] + (size_t)(row - 1) * a->rowsize[table];
    const char *s = SCHEMA[table];
    for (int k = 0; k < column; k++) r += col_size(a, s[k]);
    return col_size(a, s[column]) == 2 ? le16(r) : col_size(a, s[column]) == 1 ? *r : le32(r);
}
static const char *str_at(const Asm *a, uint32_t i) { return (const char *)a->strings + i; }
static const uint8_t *blob_at(const Asm *a, uint32_t i, uint32_t *len)
{
    const uint8_t *p = a->blob + i;
    uint32_t l;
    if (!(p[0] & 0x80)) { l = p[0]; p += 1; }
    else if ((p[0] & 0xC0) == 0x80) { l = (p[0] & 0x3F) << 8 | p[1]; p += 2; }
    else { l = (uint32_t)(p[0] & 0x1F) << 24 | p[1] << 16 | p[2] << 8 | p[3]; p += 4; }
    *len = l;
    return p;
}
static uint32_t rva_off(const uint8_t *d, size_t len, uint32_t rva)
{
    uint32_t pe = le32(d + 0x3C);
    int nsec = le16(d + pe + 6), opt = le16(d + pe + 20);
    const uint8_t *sec = d + pe + 24 + opt;
    for (int k = 0; k < nsec; k++, sec += 40) {
        uint32_t va = le32(sec + 12), vs = le32(sec + 8), raw = le32(sec + 20), rs = le32(sec + 16);
        if (rva >= va && rva < va + (vs > rs ? vs : rs)) return raw + (rva - va) < len ? raw + (rva - va) : 0;
    }
    return 0;
}
static int asm_load(Asm *a, const char *path)
{
    FILE *f = fopen(path, "rb");
    if (!f) return 0;
    fseek(f, 0, SEEK_END); a->len = ftell(f); fseek(f, 0, SEEK_SET);
    a->data = xcalloc(a->len + 16, 1);
    if (fread(a->data, 1, a->len, f) != a->len) { fclose(f); return 0; }
    fclose(f);
    const uint8_t *d = a->data;
    if (a->len < 0x200 || d[0] != 'M' || d[1] != 'Z') return 0;
    uint32_t pe = le32(d + 0x3C);
    if (pe + 24 > a->len || memcmp(d + pe, "PE\0\0", 4)) return 0;
    const uint8_t *opt = d + pe + 24;
    int dd = le16(opt) == 0x20b ? 112 : 96;                    /* PE32+ / PE32 data directories */
    uint32_t cli_rva = le32(opt + dd + 14 * 8);
    if (!cli_rva) return 0;
    uint32_t cli = rva_off(d, a->len, cli_rva);
    if (!cli) return 0;
    uint32_t md = rva_off(d, a->len, le32(d + cli + 8));
    if (!md || le32(d + md) != 0x424A5342) return 0;
    uint32_t vlen = le32(d + md + 12);
    const uint8_t *p = d + md + 16 + vlen;
    int nstreams = le16(p + 2);
    p += 4;
    for (int k = 0; k < nstreams; k++) {
        uint32_t off = le32(p), size = le32(p + 4);
        const char *nm = (const char *)p + 8;
        if (!strcmp(nm, "#~") || !strcmp(nm, "#-")) a->tables = d + md + off;
        else if (!strcmp(nm, "#Strings")) a->strings = d + md + off;
        else if (!strcmp(nm, "#Blob")) a->blob = d + md + off;
        (void)size;
        p += 8 + ((strlen(nm) + 4) & ~3u);
    }
    if (!a->tables || !a->strings) return 0;
    uint8_t hs = a->tables[6];
    a->str4 = hs & 1; a->guid4 = hs & 2; a->blob4 = hs & 4;
    uint64_t valid = 0;
    for (int b = 0; b < 8; b++) valid |= (uint64_t)a->tables[8 + b] << (8 * b);
    const uint8_t *q = a->tables + 24;
    for (int t = 0; t < 64; t++) if (valid >> t & 1) { a->rows[t] = le32(q); q += 4; }
    if (hs & 0x40) q += 4;
    for (int t = 0; t < 64; t++) {
        if (!(valid >> t & 1)) continue;
        if (t >= 45) return 0;
        int rs = 0;
        for (const char *s = SCHEMA[t]; *s; s++) rs += col_size(a, *s);
        a->rowsize[t] = rs;
        a->tab[t] = q;
        q += (size_t)rs * a->rows[t];
    }
    /* fields with [SerializeField]: CustomAttribute rows whose parent is a Field and whose constructor is a MemberRef
       of a TypeRef / TypeDef named SerializeField */
    a->serfield = xcalloc(a->rows[T_Field] + 2, 1);
    for (uint32_t r = 1; r <= a->rows[T_CustomAttribute]; r++) {
        uint32_t parent = col(a, T_CustomAttribute, r, 0), type = col(a, T_CustomAttribute, r, 1);
        if ((parent & 31) != 1 || (type & 7) != 3) continue;
        uint32_t mr = type >> 3, cls = col(a, T_MemberRef, mr, 0);
        uint32_t tag = cls & 7, idx = cls >> 3;
        const char *nm = tag == 0 ? str_at(a, col(a, T_TypeDef, idx, 1)) : tag == 1 ? str_at(a, col(a, T_TypeRef, idx, 1)) : "";
        if (!strcmp(nm, "SerializeField") && (parent >> 5) <= a->rows[T_Field]) a->serfield[parent >> 5] = 1;
    }
    return 1;
}
static void qname(const Asm *a, int table, uint32_t row, char *out, size_t sz)
{
    int ncol = table == T_TypeDef ? 1 : 1;
    const char *nm = str_at(a, col(a, table, row, ncol)), *ns = str_at(a, col(a, table, row, ncol + 1));
    if (*ns) snprintf(out, sz, "%s.%s", ns, nm); else snprintf(out, sz, "%s", nm);
}

/* ---------------------------------------------------------------------------------------------- script layouts */
static Asm *asms;
static int nasm;
typedef struct { char *name; int asm_i; uint32_t row; } TypeKey;
static TypeKey *types;
static int ntypes, captypes;
static int rules[3];

static int find_type(const char *full, int *ai, uint32_t *row)
{
    int lo = 0, hi = ntypes - 1;
    while (lo <= hi) {
        int m = (lo + hi) / 2, c = strcmp(types[m].name, full);
        if (!c) { *ai = types[m].asm_i; *row = types[m].row; return 1; }
        if (c < 0) lo = m + 1; else hi = m - 1;
    }
    return 0;
}
static int key_cmp(const void *x, const void *y)
{
    const TypeKey *a = x, *b = y;
    int c = strcmp(a->name, b->name);
    if (c) return c;
    if (a->asm_i != b->asm_i) return a->asm_i - b->asm_i;        /* first assembly (by file name) wins */
    return (int)a->row - (int)b->row;
}
static int cmpstr(const void *a, const void *b) { return strcmp(*(char *const *)a, *(char *const *)b); }
static void world_load(const char *managed, const char *version)
{
    sscanf(version, "%d.%d.%d", &rules[0], &rules[1], &rules[2]);
    if (asms) return;
    DIR *d = opendir(managed);
    if (!d) die("%s: cannot open", managed);
    char **names = NULL;
    int nn = 0;
    struct dirent *e;
    while ((e = readdir(d))) {
        size_t l = strlen(e->d_name);
        if (l > 4 && !strcmp(e->d_name + l - 4, ".dll")) { names = realloc(names, (nn + 1) * sizeof(char *)); names[nn++] = xstrdup(e->d_name); }
    }
    closedir(d);
    qsort(names, nn, sizeof(char *), cmpstr);
    asms = xcalloc(nn, sizeof(Asm));
    for (int k = 0; k < nn; k++) {
        char p[4096];
        snprintf(p, sizeof p, "%s/%s", managed, names[k]);
        Asm *a = &asms[nasm];
        if (!asm_load(a, p) || !a->rows[T_TypeDef]) { memset(a, 0, sizeof *a); continue; }
        snprintf(a->name, sizeof a->name, "%.*s", (int)strlen(names[k]) - 4, names[k]);
        for (uint32_t r = 1; r <= a->rows[T_TypeDef]; r++) {
            char full[1024];
            qname(a, T_TypeDef, r, full, sizeof full);
            if (ntypes == captypes) { captypes = captypes * 2 + 256; types = realloc(types, captypes * sizeof(TypeKey)); }
            types[ntypes++] = (TypeKey){xstrdup(full), nasm, r};
        }
        nasm++;
    }
    qsort(types, ntypes, sizeof(TypeKey), key_cmp);
    int w = 0;                                                     /* keep the first of each name */
    for (int k = 0; k < ntypes; k++) if (!w || strcmp(types[w - 1].name, types[k].name)) types[w++] = types[k];
    ntypes = w;
}
static int rules_ge(const int v[3]) { for (int k = 0; k < 3; k++) if (rules[k] != v[k]) return rules[k] > v[k]; return 1; }

static uint32_t uncompress(const uint8_t *b, uint32_t *p)
{
    uint8_t x = b[*p];
    if (!(x & 0x80)) { *p += 1; return x; }
    if ((x & 0xC0) == 0x80) { uint32_t v = (x & 0x3F) << 8 | b[*p + 1]; *p += 2; return v; }
    uint32_t v = (uint32_t)(x & 0x1F) << 24 | b[*p + 1] << 16 | b[*p + 2] << 8 | b[*p + 3];
    *p += 4;
    return v;
}
/* a type: (asm, TypeDef row), or only a name (an unresolved TypeRef), or a TypeSpec */
typedef struct { int kind; int ai; uint32_t row; char name[512]; } TRef;     /* kind: 1 def, 2 name, 3 spec, 0 none */
static TRef resolve(int ai, uint32_t tag, uint32_t idx)
{
    TRef t = {0};
    if (tag == 0) { t.kind = 1; t.ai = ai; t.row = idx; }
    else if (tag == 1) {
        qname(&asms[ai], T_TypeRef, idx, t.name, sizeof t.name);
        if (find_type(t.name, &t.ai, &t.row)) t.kind = 1; else t.kind = 2;
    } else { t.kind = 3; t.ai = ai; t.row = idx; }
    return t;
}
static void name_of(int ai, uint32_t row, char *out, size_t sz) { qname(&asms[ai], T_TypeDef, row, out, sz); }
static TRef base_of(int ai, uint32_t row)
{
    uint32_t ext = col(&asms[ai], T_TypeDef, row, 3);
    TRef t = {0};
    if (!(ext >> 2)) return t;
    return resolve(ai, ext & 3, ext >> 2);
}
typedef struct { int ai; const uint8_t *sig; uint32_t len; } GArg;
static int spec_generic(int ai, uint32_t si, int *gai, uint32_t *grow, GArg *args, int *nargs);
static uint32_t skip_type(const uint8_t *b, uint32_t p)
{
    uint8_t e = b[p++];
    if (e == 0x11 || e == 0x12) uncompress(b, &p);
    else if (e == 0x1D || e == 0x0F || e == 0x10) p = skip_type(b, p);
    else if (e == 0x15) {
        p = skip_type(b, p);
        uint32_t n = uncompress(b, &p);
        for (uint32_t k = 0; k < n; k++) p = skip_type(b, p);
    } else if (e == 0x13 || e == 0x1E) uncompress(b, &p);
    else if (e == 0x14) {
        p = skip_type(b, p);
        uncompress(b, &p);
        uint32_t ns = uncompress(b, &p);
        for (uint32_t k = 0; k < ns; k++) uncompress(b, &p);
        uint32_t nl = uncompress(b, &p);
        for (uint32_t k = 0; k < nl; k++) uncompress(b, &p);
    }
    return p;
}
static int spec_generic(int ai, uint32_t si, int *gai, uint32_t *grow, GArg *args, int *nargs)
{
    uint32_t len;
    const uint8_t *b = blob_at(&asms[ai], col(&asms[ai], T_TypeSpec, si, 0), &len);
    if (b[0] != 0x15) return 0;
    uint32_t p = 2, c = uncompress(b, &p);
    TRef r = resolve(ai, c & 3, c >> 2);
    if (r.kind != 1) return 0;
    uint32_t n = uncompress(b, &p);
    *nargs = 0;
    for (uint32_t k = 0; k < n && k < 16; k++) {
        uint32_t start = p;
        p = skip_type(b, p);
        args[k] = (GArg){ai, b + start, p - start};
        (*nargs)++;
    }
    *gai = r.ai; *grow = r.row;
    return 1;
}
static int is_subclass(int ai, uint32_t row, const char *target)
{
    char nm[1024];
    for (int seen = 0; seen < 40; seen++) {
        name_of(ai, row, nm, sizeof nm);
        if (!strcmp(nm, target)) return 1;
        TRef b = base_of(ai, row);
        if (b.kind == 0) return 0;
        if (b.kind == 2) return !strcmp(b.name, target);
        if (b.kind == 3) {
            GArg args[16]; int na;
            if (!spec_generic(b.ai, b.row, &ai, &row, args, &na)) return 0;
            continue;
        }
        ai = b.ai; row = b.row;
    }
    return 0;
}

static Node *N(const char *t, const char *name, int size, int align) { return mk(xstrdup(t), xstrdup(name), size, align, 0); }
static Node *floats(const char *t, const char *name, int n, const char **names)
{
    Node **k = xcalloc(n, sizeof(Node *));
    for (int i = 0; i < n; i++) k[i] = N("float", names[i], 4, 0);
    return mk_kids(xstrdup(t), xstrdup(name), 4 * n, 0, k, n);
}
static Node *pptr(const char *t, const char *name)
{
    char ty[600];
    snprintf(ty, sizeof ty, "PPtr<%s>", t);
    return mk(xstrdup(ty), xstrdup(name), 8, 0, 2, N("int", "m_FileID", 4, 0), N("int", "m_PathID", 4, 0));
}
static Node *vector(const char *name, Node *item)
{
    return mk("vector", xstrdup(name), -1, 1, 1, mk("Array", "Array", -1, 1, 2, N("int", "size", 4, 0), item));
}
static const char *XY[] = {"x", "y"}, *XYZ[] = {"x", "y", "z"}, *XYZW[] = {"x", "y", "z", "w"}, *RGBA[] = {"r", "g", "b", "a"},
                  *RECT[] = {"x", "y", "width", "height"}, *KEY[] = {"time", "value", "inSlope", "outSlope"};
static Node *color(const char *name) { return floats("ColorRGBA", name, 4, RGBA); }
static Node *rectoffset(const char *name)
{
    return mk("RectOffset", xstrdup(name), 16, 0, 4, N("int", "m_Left", 4, 0), N("int", "m_Right", 4, 0), N("int", "m_Top", 4, 0), N("int", "m_Bottom", 4, 0));
}
static Node *unity_value(const char *full, const char *name)
{
    if (!strcmp(full, "UnityEngine.Vector2")) return floats("Vector2f", name, 2, XY);
    if (!strcmp(full, "UnityEngine.Vector3")) return floats("Vector3f", name, 3, XYZ);
    if (!strcmp(full, "UnityEngine.Vector4")) return floats("Vector4f", name, 4, XYZW);
    if (!strcmp(full, "UnityEngine.Quaternion")) return floats("Quaternionf", name, 4, XYZW);
    if (!strcmp(full, "UnityEngine.Color")) return color(name);
    if (!strcmp(full, "UnityEngine.Color32")) return mk("ColorRGBA", xstrdup(name), 4, 0, 1, N("unsigned int", "rgba", 4, 0));
    if (!strcmp(full, "UnityEngine.Rect")) return floats("Rectf", name, 4, RECT);
    if (!strcmp(full, "UnityEngine.Matrix4x4")) {
        static const char *E[16];
        static char e[16][4];
        for (int i = 0; i < 16; i++) { snprintf(e[i], 4, "e%d%d", i / 4, i % 4); E[i] = e[i]; }
        return floats("Matrix4x4f", name, 16, E);
    }
    if (!strcmp(full, "UnityEngine.Bounds"))
        return mk("AABB", xstrdup(name), 24, 0, 2, floats("Vector3f", "m_Center", 3, XYZ), floats("Vector3f", "m_Extent", 3, XYZ));
    if (!strcmp(full, "UnityEngine.LayerMask")) return mk("BitField", xstrdup(name), 4, 0, 1, N("unsigned int", "m_Bits", 4, 0));
    if (!strcmp(full, "UnityEngine.AnimationCurve"))
        return mk("AnimationCurve", xstrdup(name), -1, 0, 3, vector("m_Curve", floats("Keyframe", "data", 4, KEY)),
                  N("int", "m_PreInfinity", 4, 0), N("int", "m_PostInfinity", 4, 0));
    if (!strcmp(full, "UnityEngine.Gradient")) {
        Node **k = xcalloc(26, sizeof(Node *));
        char nm[32];
        for (int i = 0; i < 8; i++) { snprintf(nm, sizeof nm, "key%d", i); k[i] = mk("ColorRGBA", xstrdup(nm), 4, 0, 1, N("unsigned int", "rgba", 4, 0)); }
        for (int i = 0; i < 8; i++) { snprintf(nm, sizeof nm, "ctime%d", i); k[8 + i] = N("UInt16", nm, 2, 0); }
        for (int i = 0; i < 8; i++) { snprintf(nm, sizeof nm, "atime%d", i); k[16 + i] = N("UInt16", nm, 2, 0); }
        k[24] = N("UInt8", "m_NumColorKeys", 1, 0); k[25] = N("UInt8", "m_NumAlphaKeys", 1, 1);
        return mk_kids("Gradient", xstrdup(name), -1, 0, k, 26);
    }
    if (!strcmp(full, "UnityEngine.GUIStyle")) {
        static const char *S[] = {"m_Normal", "m_Hover", "m_Active", "m_Focused", "m_OnNormal", "m_OnHover", "m_OnActive", "m_OnFocused"},
                          *R[] = {"m_Border", "m_Margin", "m_Padding", "m_Overflow"};
        Node **k = xcalloc(27, sizeof(Node *));
        int i = 0;
        k[i++] = mk("string", "m_Name", -1, 1, 1, mk("Array", "Array", -1, 1, 2, N("int", "size", 4, 0), N("char", "data", 1, 0)));
        for (int s = 0; s < 8; s++) k[i++] = mk("GUIStyleState", S[s], -1, 0, 2, pptr("Texture2D", "m_Background"), color("m_TextColor"));
        for (int s = 0; s < 4; s++) k[i++] = rectoffset(R[s]);
        k[i++] = pptr("Font", "m_Font"); k[i++] = N("int", "m_FontSize", 4, 0); k[i++] = N("int", "m_FontStyle", 4, 0);
        k[i++] = N("int", "m_Alignment", 4, 0); k[i++] = N("bool", "m_WordWrap", 1, 0); k[i++] = N("bool", "m_RichText", 1, 1);
        k[i++] = N("int", "m_TextClipping", 4, 0); k[i++] = N("int", "m_ImagePosition", 4, 0);
        k[i++] = floats("Vector2f", "m_ContentOffset", 2, XY); k[i++] = N("float", "m_FixedWidth", 4, 0);
        k[i++] = N("float", "m_FixedHeight", 4, 0); k[i++] = N("bool", "m_StretchWidth", 1, 0); k[i++] = N("bool", "m_StretchHeight", 1, 1);
        return mk_kids("GUIStyle", xstrdup(name), -1, 0, k, i);
    }
    if (!strcmp(full, "UnityEngine.RectOffset")) return rectoffset(name);
    return NULL;
}

static Node **class_fields(int ai, uint32_t row, int depth, GArg *gargs, int ngargs, int *count);
static Node *type_node(int ai, const uint8_t *b, uint32_t p, const char *name, int depth, GArg *gargs, int ngargs, int in_array)
{
    uint8_t e = b[p];
    static const struct { uint8_t e; const char *t; int size, align; } PR[] = {
        {0x02, "bool", 1, 1}, {0x04, "SInt8", 1, 1}, {0x05, "UInt8", 1, 1}, {0x08, "int", 4, 0}, {0x0C, "float", 4, 0}, {0x0D, "double", 8, 0}};
    for (size_t k = 0; k < sizeof PR / sizeof *PR; k++)
        if (PR[k].e == e) {
            if (e == 0x04 && !rules_ge(SBYTE_FROM)) return NULL;
            return N(PR[k].t, name, PR[k].size, in_array ? 0 : PR[k].align);
        }
    if (e == 0x0E)
        return mk("string", xstrdup(name), -1, 0, 1, mk("Array", "Array", -1, 1, 2, N("int", "size", 4, 0), N("char", "data", 1, 0)));
    if (e == 0x13 && ngargs) {
        uint32_t q = p + 1, n = uncompress(b, &q);
        if ((int)n < ngargs) return type_node(gargs[n].ai, gargs[n].sig, 0, name, depth, NULL, 0, in_array);
        return NULL;
    }
    if (e == 0x1D) {
        if (in_array) return NULL;
        Node *item = type_node(ai, b, p + 1, "data", depth, gargs, ngargs, 1);
        return item ? vector(name, item) : NULL;
    }
    if (e == 0x15) {
        uint32_t q = p + 1;
        if (b[q] != 0x11 && b[q] != 0x12) return NULL;
        q++;
        uint32_t c = uncompress(b, &q);
        TRef r = resolve(ai, c & 3, c >> 2);
        char gname[1024] = "?";
        if (r.kind == 1) name_of(r.ai, r.row, gname, sizeof gname);
        else if (r.kind == 2) snprintf(gname, sizeof gname, "%s", r.name);
        if (strcmp(gname, "System.Collections.Generic.List`1") || in_array) return NULL;
        uncompress(b, &q);
        Node *item = type_node(ai, b, q, "data", depth, gargs, ngargs, 1);
        return item ? vector(name, item) : NULL;
    }
    if (e == 0x11 || e == 0x12) {
        uint32_t q = p + 1, c = uncompress(b, &q);
        TRef r = resolve(ai, c & 3, c >> 2);
        if (r.kind == 0 || r.kind == 3) return NULL;
        if (r.kind == 2) return unity_value(r.name, name);
        char full[1024];
        name_of(r.ai, r.row, full, sizeof full);
        Node *u = unity_value(full, name);
        if (u) return u;
        if (is_subclass(r.ai, r.row, "UnityEngine.Object")) {
            const char *dot = strrchr(full, '.');
            return pptr(dot ? dot + 1 : full, name);
        }
        Asm *a = &asms[r.ai];
        if (is_subclass(r.ai, r.row, "System.Enum")) {
            /* saved as the underlying type: byte enums are one byte (aligned after a single field); 64-bit enums
               are not saved */
            uint32_t f0 = col(a, T_TypeDef, r.row, 4), f1 = r.row < a->rows[T_TypeDef] ? col(a, T_TypeDef, r.row + 1, 4) : a->rows[T_Field] + 1;
            int u8 = 0x08;
            for (uint32_t f = f0; f < f1; f++) {
                if (col(a, T_Field, f, 0) & 0x10) continue;
                uint32_t len;
                const uint8_t *sig = blob_at(a, col(a, T_Field, f, 2), &len);
                u8 = sig[1];
                break;
            }
            if (u8 == 0x0A || u8 == 0x0B) return NULL;
            if (u8 == 0x04) return N("SInt8", name, 1, in_array ? 0 : 1);
            if (u8 == 0x05) return N("UInt8", name, 1, in_array ? 0 : 1);
            if (u8 == 0x06) return N("SInt16", name, 2, in_array ? 0 : 1);
            if (u8 == 0x07) return N("UInt16", name, 2, in_array ? 0 : 1);
            return N("int", name, 4, 0);
        }
        uint32_t flags = col(a, T_TypeDef, r.row, 0);
        if (!(flags & 0x2000) || (flags & 0x80) || (flags & 0x20)) return NULL;     /* Serializable, Abstract, Interface */
        if (strchr(str_at(a, col(a, T_TypeDef, r.row, 1)), '`')) return NULL;
        if (is_subclass(r.ai, r.row, "System.ValueType") && !rules_ge(STRUCTS_FROM)) return NULL;
        if (depth >= MAX_DEPTH) return NULL;
        int n;
        Node **k = class_fields(r.ai, r.row, depth + 1, NULL, 0, &n);
        return mk_kids(xstrdup(full), xstrdup(name), -1, 0, k, n);
    }
    return NULL;
}
static Node **class_fields(int ai, uint32_t row, int depth, GArg *gargs, int ngargs, int *count)
{
    Node **out = NULL;
    int n = 0;
    TRef b = base_of(ai, row);
    char nm[1024];
    if (b.kind == 1) {
        name_of(b.ai, b.row, nm, sizeof nm);
        if (strncmp(nm, "UnityEngine.", 12) && strncmp(nm, "System.", 7)) out = class_fields(b.ai, b.row, depth, NULL, 0, &n);
    } else if (b.kind == 3) {
        GArg args[16]; int na, gai; uint32_t grow;
        if (spec_generic(b.ai, b.row, &gai, &grow, args, &na)) {
            name_of(gai, grow, nm, sizeof nm);
            if (strncmp(nm, "UnityEngine.", 12) && strncmp(nm, "System.", 7)) {
                GArg *keep = xcalloc(na ? na : 1, sizeof(GArg));
                memcpy(keep, args, na * sizeof(GArg));
                out = class_fields(gai, grow, depth, keep, na, &n);
            }
        }
    }
    Asm *a = &asms[ai];
    uint32_t f0 = col(a, T_TypeDef, row, 4), f1 = row < a->rows[T_TypeDef] ? col(a, T_TypeDef, row + 1, 4) : a->rows[T_Field] + 1;
    for (uint32_t f = f0; f < f1 && f <= a->rows[T_Field]; f++) {
        uint32_t fl = col(a, T_Field, f, 0);
        if (fl & (0x10 | 0x40 | 0x20 | 0x80)) continue;          /* static, literal, initonly, NotSerialized */
        if ((fl & 7) != 6 && !a->serfield[f]) continue;            /* public or [SerializeField] */
        uint32_t len;
        const uint8_t *sig = blob_at(a, col(a, T_Field, f, 2), &len);
        Node *node = type_node(ai, sig, 1, str_at(a, col(a, T_Field, f, 1)), depth, gargs, ngargs, 0);
        if (node) { out = realloc(out, (n + 1) * sizeof(Node *)); out[n++] = node; }
    }
    *count = n;
    return out;
}
static Node *script_tree(const Node *base, const char *assembly, const char *full)
{
    int found = 0;
    for (int k = 0; k < nasm; k++) if (!strcmp(asms[k].name, assembly)) found = 1;
    int ai;
    uint32_t row;
    if (!found || !find_type(full, &ai, &row)) return NULL;
    int n;
    Node **k = class_fields(ai, row, 1, NULL, 0, &n);
    Node **all = xcalloc(base->nkids + n, sizeof(Node *));
    memcpy(all, base->kids, base->nkids * sizeof(Node *));
    memcpy(all + base->nkids, k, n * sizeof(Node *));
    return mk_kids(base->type, base->name, base->size, base->align, all, base->nkids + n);
}

/* ---------------------------------------------------------------------------------------------- main */
typedef struct { char *file; int32_t path; char *asm_name, *cls; } Script;
typedef struct { char *asm_name, *cls; Node *old, *nw; int differ; } ScriptTree;
typedef struct { char label[300]; int count; } Count;
static Count counts[4096];
static int ncounts;
static void count(const char *label)
{
    for (int k = 0; k < ncounts; k++) if (!strcmp(counts[k].label, label)) { counts[k].count++; return; }
    if (ncounts < 4096) { snprintf(counts[ncounts].label, sizeof counts[0].label, "%s", label); counts[ncounts++].count = 1; }
}
static int count_cmp(const void *a, const void *b) { return strcmp(((const Count *)a)->label, ((const Count *)b)->label); }
static char *bytes_str(const Value *v)
{
    char *s = xcalloc(v->n + 1, 1);
    memcpy(s, v->b, v->n);
    return s;
}

int main(int argc, char **argv)
{
    const char *data = NULL, *donor = NULL;
    int dry = 0;
    for (int k = 1; k < argc; k++) {
        if (!strcmp(argv[k], "-n")) dry = 1;
        else if (!strcmp(argv[k], "--donor") && k + 1 < argc) donor = argv[++k];
        else if (argv[k][0] != '-' && !data) data = argv[k];
        else { fprintf(stderr, "usage: unity4convert [-n] [--donor <donor mainData>] <game _Data folder>\n"); return 1; }
    }
    if (!data) { fprintf(stderr, "usage: unity4convert [-n] [--donor <donor mainData>] <game _Data folder>\n"); return 1; }
    time_t t0 = time(NULL);
    load_reference();
    char path[4096], full_ver[64], src[64];
    snprintf(path, sizeof path, "%s/mainData", data);
    if (!file_version(path, full_ver)) die("%s: no Unity version found", path);
    int a1, a2, a3;
    if (sscanf(full_ver, "%d.%d.%d", &a1, &a2, &a3) != 3) die("bad version %s", full_ver);
    snprintf(src, sizeof src, "%d.%d.%d", a1, a2, a3);
    int vs = version_index(src), vt = version_index(TARGET);
    if (vs < 0) die("Unity %s: no layouts in the reference", full_ver);

    /* engine classes whose layout differs */
    int *eng = xcalloc(nref_cls, sizeof(int)), neng = 0;
    for (int k = 0; k < nref_cls; k++) {
        Node *a = ref_tree(ref_cls[k].id, vs), *b = ref_tree(ref_cls[k].id, vt);
        if (a && b && !tree_eq(a, b)) eng[neng++] = ref_cls[k].id;
    }
    printf("Unity %s -> %s: %d engine classes differ\n", full_ver, TARGET, neng);
#define IS_ENG(c) ({ int _r = 0; for (int _k = 0; _k < neng; _k++) if (eng[_k] == (c)) _r = 1; _r; })

    /* the donor's values of those classes (global managers) */
    Value *donor_val[1024] = {0};
    int donor_cls[1024], ndonor = 0;
    if (donor) {
        UFile d;
        if (!uf_open(&d, donor)) die("%s: not a Unity 4 file", donor);
        for (int i = 0; i < d.n && ndonor < 1024; i++) {
            Node *t = ref_tree(d.e[i].cls, vt);
            if (!t || !IS_ENG(d.e[i].cls)) continue;
            Reader r = {uf_raw(&d, i), d.e[i].size, 0, 0};
            Value *v = rd(&r, t);
            if (!v) continue;
            int k;                                                 /* the last object of a class counts */
            for (k = 0; k < ndonor && donor_cls[k] != d.e[i].cls; k++);
            donor_cls[k] = d.e[i].cls; donor_val[k] = v;
            if (k == ndonor) ndonor++;
        }
    }
#define DONOR(c) ({ Value *_v = NULL; for (int _k = 0; _k < ndonor; _k++) if (donor_cls[_k] == (c)) { _v = donor_val[_k]; break; } _v; })

    /* sorting layers before 4.5: TagManager list index -> uniqueID */
    Node *tm = ref_tree(78, vs);
    if (tm && kid_index(tm, "m_SortingLayers") >= 0) {
        UFile u;
        if (uf_open(&u, path)) {
            int i = uf_find(&u, 78);
            if (i >= 0) {
                Reader r = {uf_raw(&u, i), u.e[i].size, 0, 0};
                Value *v = rd(&r, tm), *l = field(v, "m_SortingLayers");
                if (l && l->kind == V_ARRAY && l->n) {
                    nsorting = l->n; sorting_ids = xcalloc(l->n, sizeof(uint32_t));
                    for (int k = 0; k < l->n; k++) { Value *id = field(l->items[k], "uniqueID"); sorting_ids[k] = id ? (uint32_t)id->i : 0; }
                } else { nsorting = 1; sorting_ids = &sorting_default; }
            }
            uf_close(&u);
        }
    }

    /* the files: levels and .assets in name order, mainData last */
    DIR *dir = opendir(data);
    if (!dir) die("%s: cannot open", data);
    char **files = NULL;
    int nf = 0;
    struct dirent *de;
    while ((de = readdir(dir))) {
        const char *n = de->d_name;
        size_t l = strlen(n);
        if ((!strncmp(n, "level", 5) && !strchr(n, '.')) || (l > 7 && !strcmp(n + l - 7, ".assets"))) {
            files = realloc(files, (nf + 2) * sizeof(char *)); files[nf++] = xstrdup(n);
        }
    }
    closedir(dir);
    qsort(files, nf, sizeof(char *), cmpstr);
    files = realloc(files, (nf + 2) * sizeof(char *));
    snprintf(path, sizeof path, "%s/Resources/unity_builtin_extra", data);    /* the game's built-in materials / shaders */
    if (access(path, F_OK) == 0) files[nf++] = xstrdup("Resources/unity_builtin_extra");
    files[nf++] = xstrdup("mainData");
    int *done = xcalloc(nf, sizeof(int)), ndone = 0;
    for (int k = 0; k < nf; k++) {
        char v[64];
        snprintf(path, sizeof path, "%s/%s", data, files[k]);
        if (file_version(path, v) && !strcmp(v, TARGET_FULL)) { done[k] = 1; ndone++; }
    }
    if (ndone) printf("already converted: %d file(s)\n", ndone);
    int rv[3] = {a1, a2, a3}, rules_same = 1;
    for (int k = 0; k < 3; k++) if (rv[k] != RULES_SAME_FROM[k]) { rules_same = rv[k] > RULES_SAME_FROM[k]; break; }
    if (!neng && rules_same) printf("nothing to convert: Unity %s data reads as %s\n", src, TARGET);

    Node *mb_old = ref_tree(114, vs), *mb_new = ref_tree(114, vt);
    Script *scripts = NULL;
    int nscripts = 0;
    char managed[4096];
    snprintf(managed, sizeof managed, "%s/Managed", data);
    if (!rules_same) {
        for (int k = 0; k < nf; k++) {
            Node *ms = ref_tree(115, done[k] ? vt : vs);
            UFile u;
            snprintf(path, sizeof path, "%s/%s", data, files[k]);
            if (!uf_open(&u, path)) die("%s: not a Unity 4 file", path);
            for (int i = 0; i < u.n; i++) {
                if (u.e[i].cls != 115) continue;
                Reader r = {uf_raw(&u, i), u.e[i].size, 0, 0};
                Value *v = rd(&r, ms);
                if (!v) continue;
                Value *ns = field(v, "m_Namespace"), *cn = field(v, "m_ClassName"), *an = field(v, "m_AssemblyName");
                char *nsS = bytes_str(ns), *cnS = bytes_str(cn), *anS = bytes_str(an), name[1024];
                if (*nsS) snprintf(name, sizeof name, "%s.%s", nsS, cnS); else snprintf(name, sizeof name, "%s", cnS);
                char *dll = strstr(anS, ".dll");
                if (dll) memmove(dll, dll + 4, strlen(dll + 4) + 1);
                scripts = realloc(scripts, (nscripts + 1) * sizeof(Script));
                scripts[nscripts++] = (Script){files[k], u.e[i].path, anS, xstrdup(name)};
            }
            uf_close(&u);
        }
    }
    ScriptTree *trees = NULL;
    int ntrees = 0;
    int total = 0;
    for (int k = 0; k < nf; k++) {
        if (done[k]) continue;
        snprintf(path, sizeof path, "%s/%s", data, files[k]);
        if (!neng && rules_same) { if (!dry) set_version(path); continue; }
        UFile u;
        if (!uf_open(&u, path)) die("%s: not a Unity 4 file", path);
        char **ext;
        int next = uf_externals(&u, &ext);
        uint8_t **nw = xcalloc(u.n, sizeof(uint8_t *));
        size_t *nlen = xcalloc(u.n, sizeof(size_t));
        int changed = 0;
        for (int i = 0; i < u.n; i++) {
            int cls = u.e[i].cls;
            Node *on, *nn;
            char label[300];
            int engine = IS_ENG(cls);
            if (engine) {
                on = ref_tree(cls, vs); nn = ref_tree(cls, vt);
                snprintf(label, sizeof label, "%d", cls);
            } else if (cls == 114 && !rules_same) {
                Reader r = {uf_raw(&u, i), u.e[i].size, 0, 0};
                Value *h = rd(&r, mb_old);
                Value *sp = field(h, "m_Script");
                if (!sp) continue;
                int fid = (int)field(sp, "m_FileID")->i;
                int32_t pid = (int32_t)field(sp, "m_PathID")->i;
                const char *sf = NULL;
                if (fid == 0) sf = files[k];
                else if (fid - 1 < next) { sf = strrchr(ext[fid - 1], '/'); sf = sf ? sf + 1 : ext[fid - 1]; }
                if (!sf) continue;
                Script *s = NULL;
                for (int q = 0; q < nscripts; q++) if (scripts[q].path == pid && !strcmp(scripts[q].file, sf)) { s = &scripts[q]; break; }
                if (!s) continue;
                ScriptTree *st = NULL;
                for (int q = 0; q < ntrees; q++) if (!strcmp(trees[q].asm_name, s->asm_name) && !strcmp(trees[q].cls, s->cls)) { st = &trees[q]; break; }
                if (!st) {
                    trees = realloc(trees, (ntrees + 1) * sizeof(ScriptTree));
                    st = &trees[ntrees++];
                    st->asm_name = s->asm_name; st->cls = s->cls;
                    world_load(managed, src);
                    st->old = script_tree(mb_old, s->asm_name, s->cls);
                    world_load(managed, TARGET);
                    st->nw = script_tree(mb_new, s->asm_name, s->cls);
                    st->differ = st->old && st->nw && !tree_eq(st->old, st->nw);
                }
                if (!st->differ) continue;
                on = st->old; nn = st->nw;
                snprintf(label, sizeof label, "%s", s->cls);
            } else continue;
            Reader r = {uf_raw(&u, i), u.e[i].size, 0, 0};
            Value *v = rd(&r, on);
            if (!v || r.p != u.e[i].size) die("%s path %d (%s): old layout read %zu of %u bytes", files[k], u.e[i].path, label, r.p, u.e[i].size);
            Value *cv = convert(on, v, nn, nn->type, engine ? DONOR(cls) : NULL);
            if (!cv) die("%s path %d (%s): no conversion from %s to %s", files[k], u.e[i].path, label, on->type, nn->type);
            Buf w = {0};
            if (!wr(&w, nn, cv)) die("%s path %d (%s): writing the new layout failed", files[k], u.e[i].path, label);
            Reader chk = {w.b, w.len, 0, 0};
            if (!rd(&chk, nn) || chk.p != w.len) die("%s path %d (%s): the new object does not read back", files[k], u.e[i].path, label);
            nw[i] = w.b; nlen[i] = w.len;
            changed = 1;
            count(label);
            total++;
        }
        if (changed && !dry) uf_rewrite(&u, nw, nlen);
        else uf_close(&u);
        if (!dry) set_version(path);
    }
    qsort(counts, ncounts, sizeof(Count), count_cmp);
    printf("converted:");
    for (int k = 0; k < ncounts; k++) printf("%s %s x%d", k ? "," : "", counts[k].label, counts[k].count);
    printf("\n%d object(s) in %ld s%s\n", total, (long)(time(NULL) - t0), dry ? " (dry run, nothing written)" : "");
    return 0;
}
