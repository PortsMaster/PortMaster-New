/*
 * jk_astc_patch - convert Jump King's uncompressed MonoGame XNB textures to
 * ASTC 4x4 blocks so the port can load them through an ASTC-capable gl4es.
 *
 * Runs on the device at first launch.  Only Texture2D assets in the
 * uncompressed XNBw format with SurfaceFormat.Color and exactly one mip level
 * are touched; everything else is left byte-for-byte alone, so a partial run
 * is always safe (MonoGame loads RGBA and ASTC textures side by side).
 *
 * Encoding is done by an external astcenc binary, one texture at a time.
 *
 * usage: jk_astc_patch <content-dir> <astcenc> [quality] [threads]
 */
#define _GNU_SOURCE
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <strings.h>
#include <unistd.h>

#define ASTC_4X4_RGBA 96
#define ASTC_BLOCK_BYTES 16
#define PREFIX_BYTES 2048

static int g_converted, g_kept, g_failed, g_skipped, g_encoder_broken;

static uint32_t rd32(const unsigned char *p)
{
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) |
           ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

static void wr32(unsigned char *p, uint32_t v)
{
    p[0] = (unsigned char)(v & 0xff);
    p[1] = (unsigned char)((v >> 8) & 0xff);
    p[2] = (unsigned char)((v >> 16) & 0xff);
    p[3] = (unsigned char)((v >> 24) & 0xff);
}

static int read7(const unsigned char *d, size_t size, size_t *off, uint32_t *out)
{
    uint32_t v = 0;
    int shift = 0;
    for (;;) {
        if (*off >= size || shift > 28)
            return -1;
        unsigned char b = d[(*off)++];
        v |= (uint32_t)(b & 0x7f) << shift;
        if (!(b & 0x80)) {
            *out = v;
            return 0;
        }
        shift += 7;
    }
}

static unsigned char *read_file(const char *path, size_t max_size, size_t *out_size)
{
    struct stat st;
    if (stat(path, &st) != 0 || !S_ISREG(st.st_mode))
        return NULL;
    size_t size = (size_t)st.st_size;
    if (size < 10 || size > max_size)
        return NULL;
    FILE *f = fopen(path, "rb");
    if (!f)
        return NULL;
    unsigned char *buf = malloc(size);
    if (!buf) {
        fclose(f);
        return NULL;
    }
    if (fread(buf, 1, size, f) != size) {
        free(buf);
        fclose(f);
        return NULL;
    }
    fclose(f);
    *out_size = size;
    return buf;
}

static unsigned char *read_prefix(const char *path, size_t *out_size)
{
    FILE *f = fopen(path, "rb");
    if (!f)
        return NULL;
    unsigned char *buf = malloc(PREFIX_BYTES);
    if (!buf) {
        fclose(f);
        return NULL;
    }
    size_t n = fread(buf, 1, PREFIX_BYTES, f);
    fclose(f);
    *out_size = n;
    return buf;
}

static int write_file_atomic(const char *path, const unsigned char *data, size_t size)
{
    char tmp[PATH_MAX];
    if (snprintf(tmp, sizeof(tmp), "%s.tmp", path) >= (int)sizeof(tmp))
        return -1;
    int fd = open(tmp, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0)
        return -1;
    size_t done = 0;
    while (done < size) {
        ssize_t n = write(fd, data + done, size - done);
        if (n <= 0) {
            close(fd);
            unlink(tmp);
            return -1;
        }
        done += (size_t)n;
    }
    fsync(fd);
    close(fd);
    if (rename(tmp, path) != 0) {
        unlink(tmp);
        return -1;
    }
    return 0;
}

static int ends_with_xnb(const char *name)
{
    size_t n = strlen(name);
    if (n < 4)
        return 0;
    const char *e = name + n - 4;
    return e[0] == '.' && (e[1] == 'x' || e[1] == 'X') &&
           (e[2] == 'n' || e[2] == 'N') && (e[3] == 'b' || e[3] == 'B');
}

/*
 * Jump King reads the level collision texture back on the CPU with
 * Texture2D.GetData<Color>(), which only works for uncompressed surfaces.
 * Keep level.xnb as RGBA; it is one file and the game needs its pixels.
 */
static int must_stay_rgba(const char *name)
{
    return strcasecmp(name, "level.xnb") == 0;
}

/*
 * Parse just enough of an uncompressed XNB to know whether it is a plain
 * single-mip Texture2D.  Returns 1 for yes, 0 for "not our business",
 * -1 for a malformed/truncated header (counted as skipped).
 */
static int parse_texture_header(const unsigned char *d, size_t size,
                                size_t *payload_off, int32_t *w, int32_t *h,
                                int32_t *mips, uint32_t *data_size)
{
    if (size < 14 || memcmp(d, "XNBw", 4) != 0 || d[4] != 5 || (d[5] & 0x80))
        return 0;

    size_t off = 10;
    uint32_t readers = 0;
    if (read7(d, size, &off, &readers) != 0 || readers == 0 || readers > 64)
        return -1;

    char reader[512];
    reader[0] = 0;
    for (uint32_t i = 0; i < readers; i++) {
        uint32_t len = 0;
        if (read7(d, size, &off, &len) != 0 || len >= sizeof(reader) ||
            off + len + 4 > size)
            return -1;
        if (i == 0) {
            memcpy(reader, d + off, len);
            reader[len] = 0;
        }
        off += len + 4;
    }

    uint32_t shared = 0, root = 0;
    if (read7(d, size, &off, &shared) != 0 || read7(d, size, &off, &root) != 0)
        return -1;
    if (root != 1 || shared != 0)
        return 0;
    if (strstr(reader, "Texture2DReader") == NULL)
        return 0;
    if (off + 20 > size)
        return -1;

    int32_t format = (int32_t)rd32(d + off);
    *w = (int32_t)rd32(d + off + 4);
    *h = (int32_t)rd32(d + off + 8);
    *mips = (int32_t)rd32(d + off + 12);
    *data_size = rd32(d + off + 16);
    *payload_off = off;

    if (format == ASTC_4X4_RGBA)
        return 0;
    if (format != 0)
        return 0;
    return 1;
}

/* --- astcenc ------------------------------------------------------------ */

static int write_tga(const char *path, const unsigned char *rgba, int w, int h)
{
    FILE *f = fopen(path, "wb");
    if (!f)
        return -1;
    unsigned char hdr[18];
    memset(hdr, 0, sizeof(hdr));
    hdr[2] = 2;                  /* uncompressed true colour */
    hdr[12] = (unsigned char)(w & 0xff);
    hdr[13] = (unsigned char)((w >> 8) & 0xff);
    hdr[14] = (unsigned char)(h & 0xff);
    hdr[15] = (unsigned char)((h >> 8) & 0xff);
    hdr[16] = 32;                /* BGRA */
    hdr[17] = 0x28;              /* 8 alpha bits, top-left origin */
    if (fwrite(hdr, 1, sizeof(hdr), f) != sizeof(hdr)) {
        fclose(f);
        return -1;
    }
    unsigned char *row = malloc((size_t)w * 4);
    if (!row) {
        fclose(f);
        return -1;
    }
    for (int y = 0; y < h; y++) {
        const unsigned char *src = rgba + (size_t)y * (size_t)w * 4;
        for (int x = 0; x < w; x++) {
            row[x * 4 + 0] = src[x * 4 + 2];
            row[x * 4 + 1] = src[x * 4 + 1];
            row[x * 4 + 2] = src[x * 4 + 0];
            row[x * 4 + 3] = src[x * 4 + 3];
        }
        if (fwrite(row, 4, (size_t)w, f) != (size_t)w) {
            free(row);
            fclose(f);
            return -1;
        }
    }
    free(row);
    fclose(f);
    return 0;
}

/* 0 ok, -1 astcenc failed, -2 could not execute astcenc */
static int run_astcenc(const char *astcenc, const char *quality,
                       const char *threads, const char *in, const char *out)
{
    pid_t pid = fork();
    if (pid < 0)
        return -2;
    if (pid == 0) {
        int devnull = open("/dev/null", O_WRONLY);
        if (devnull >= 0) {
            dup2(devnull, 1);
            dup2(devnull, 2);
        }
        char *argv[10];
        int n = 0;
        argv[n++] = (char *)astcenc;
        argv[n++] = (char *)"-cl";
        argv[n++] = (char *)in;
        argv[n++] = (char *)out;
        argv[n++] = (char *)"4x4";
        argv[n++] = (char *)quality;
        argv[n++] = (char *)"-silent";
        argv[n++] = (char *)"-j";
        argv[n++] = (char *)threads;
        argv[n] = NULL;
        execv(astcenc, argv);
        _exit(127);
    }
    int status = 0;
    while (waitpid(pid, &status, 0) < 0) {
        if (errno != EINTR)
            return -2;
    }
    if (!WIFEXITED(status))
        return -1;
    if (WEXITSTATUS(status) == 127)
        return -2;
    return WEXITSTATUS(status) == 0 ? 0 : -1;
}

static int load_ktx_blocks(const char *path, int w, int h,
                           unsigned char **out, size_t *out_size)
{
    size_t size = 0;
    unsigned char *d = read_file(path, 16u * 1024u * 1024u, &size);
    if (!d)
        return -1;
    static const unsigned char magic[12] = {
        0xAB, 'K', 'T', 'X', ' ', '1', '1', 0xBB, '\r', '\n', 0x1A, '\n'
    };
    if (size < 64 + 4 || memcmp(d, magic, 12) != 0) {
        free(d);
        return -1;
    }
    uint32_t endian = rd32(d + 12);
    uint32_t mip_count = rd32(d + 12 + 11 * 4);
    uint32_t kv_bytes = rd32(d + 12 + 12 * 4);
    if (endian != 0x04030201 || mip_count < 1) {
        free(d);
        return -1;
    }
    size_t off = 64 + (size_t)kv_bytes;
    if (off + 4 > size) {
        free(d);
        return -1;
    }
    uint32_t image_size = rd32(d + off);
    off += 4;
    size_t want = (size_t)((w + 3) / 4) * (size_t)((h + 3) / 4) * ASTC_BLOCK_BYTES;
    if (image_size != want || off + image_size > size) {
        free(d);
        return -1;
    }
    unsigned char *blocks = malloc(image_size);
    if (!blocks) {
        free(d);
        return -1;
    }
    memcpy(blocks, d + off, image_size);
    free(d);
    *out = blocks;
    *out_size = image_size;
    return 0;
}

/* --- per file ----------------------------------------------------------- */

static int process_xnb(const char *path, const char *astcenc,
                       const char *quality, const char *threads,
                       const char *tmpdir)
{
    size_t prefix_size = 0;
    unsigned char *prefix = read_prefix(path, &prefix_size);
    if (!prefix)
        return -1;

    size_t payload = 0;
    int32_t w = 0, h = 0, mips = 0;
    uint32_t data_size = 0;
    int kind = parse_texture_header(prefix, prefix_size, &payload, &w, &h,
                                    &mips, &data_size);
    free(prefix);
    if (kind <= 0) {
        if (kind == 0)
            g_skipped++;
        else
            g_skipped++;
        return 0;
    }

    if (w <= 0 || h <= 0 || w > 4096 || h > 4096 || mips != 1 ||
        (uint64_t)w * (uint64_t)h * 4u != data_size) {
        g_skipped++;
        return 0;
    }

    size_t astc_len = (size_t)((w + 3) / 4) * (size_t)((h + 3) / 4) * ASTC_BLOCK_BYTES;
    if (astc_len >= data_size) {
        g_kept++;
        return 0;
    }

    size_t size = 0;
    unsigned char *d = read_file(path, 64u * 1024u * 1024u, &size);
    if (!d) {
        g_failed++;
        return -1;
    }
    if (payload + 16 + 4 + data_size != size || payload + 20 > size) {
        free(d);
        g_skipped++;
        return 0;
    }

    char tga[PATH_MAX], ktx[PATH_MAX];
    if (snprintf(tga, sizeof(tga), "%s/in.tga", tmpdir) >= (int)sizeof(tga) ||
        snprintf(ktx, sizeof(ktx), "%s/out.ktx", tmpdir) >= (int)sizeof(ktx)) {
        free(d);
        g_failed++;
        return -1;
    }
    unlink(tga);
    unlink(ktx);
    if (write_tga(tga, d + payload + 20, w, h) != 0) {
        free(d);
        g_failed++;
        return -1;
    }

    int rc = run_astcenc(astcenc, quality, threads, tga, ktx);
    unlink(tga);
    if (rc == -2) {
        unlink(ktx);
        g_encoder_broken = 1;
        free(d);
        g_failed++;
        return -1;
    }
    if (rc != 0) {
        unlink(ktx);
        free(d);
        g_failed++;
        return -1;
    }

    unsigned char *blocks = NULL;
    size_t blocks_len = 0;
    rc = load_ktx_blocks(ktx, w, h, &blocks, &blocks_len);
    unlink(ktx);
    if (rc != 0) {
        free(d);
        g_failed++;
        return -1;
    }

    size_t new_size = payload + 16 + 4 + blocks_len;
    unsigned char *out = malloc(new_size);
    if (!out) {
        free(blocks);
        free(d);
        g_failed++;
        return -1;
    }
    memcpy(out, d, payload);
    wr32(out + 6, (uint32_t)new_size);
    wr32(out + payload, ASTC_4X4_RGBA);
    wr32(out + payload + 4, (uint32_t)w);
    wr32(out + payload + 8, (uint32_t)h);
    wr32(out + payload + 12, 1);
    wr32(out + payload + 16, (uint32_t)blocks_len);
    memcpy(out + payload + 20, blocks, blocks_len);
    free(blocks);
    free(d);

    if (write_file_atomic(path, out, new_size) != 0) {
        free(out);
        g_failed++;
        return -1;
    }
    free(out);
    g_converted++;
    return 1;
}

static int g_maxdepth = -1;

static void walk(const char *dir, int depth, const char *astcenc,
                 const char *quality, const char *threads, const char *tmpdir)
{
    if (g_maxdepth >= 0 && depth > g_maxdepth)
        return;
    DIR *d = opendir(dir);
    if (!d)
        return;
    struct dirent *e;
    while ((e = readdir(d)) != NULL) {
        if (strcmp(e->d_name, ".") == 0 || strcmp(e->d_name, "..") == 0)
            continue;
        char path[PATH_MAX];
        if (snprintf(path, sizeof(path), "%s/%s", dir, e->d_name) >= (int)sizeof(path))
            continue;
        struct stat st;
        if (stat(path, &st) != 0)
            continue;
        if (S_ISDIR(st.st_mode)) {
            if (g_maxdepth < 0 || depth < g_maxdepth)
                walk(path, depth + 1, astcenc, quality, threads, tmpdir);
        } else if (S_ISREG(st.st_mode) && ends_with_xnb(e->d_name)) {
            if (must_stay_rgba(e->d_name)) {
                g_kept++;
                continue;
            }
            if (g_encoder_broken) {
                g_failed++;
                continue;
            }
            if (process_xnb(path, astcenc, quality, threads, tmpdir) == 1) {
                printf("[%d] %s\n", g_converted, path);
                fflush(stdout);
            }
        }
    }
    closedir(d);
}

int main(int argc, char **argv)
{
    if (argc < 3) {
        fprintf(stderr, "usage: %s <content-dir> <astcenc> [quality] [threads] [--maxdepth N]\n", argv[0]);
        return 1;
    }
    setvbuf(stdout, NULL, _IOLBF, 0);

    const char *content = argv[1];
    const char *astcenc = argv[2];
    const char *quality = "-medium";
    const char *threads = "2";
    int positional = 0;
    for (int i = 3; i < argc; i++) {
        if (strcmp(argv[i], "--maxdepth") == 0 && i + 1 < argc) {
            g_maxdepth = atoi(argv[++i]);
            if (g_maxdepth < 0)
                g_maxdepth = 0;
        } else if (positional == 0) {
            quality = argv[i];
            positional = 1;
        } else if (positional == 1) {
            threads = argv[i];
            positional = 2;
        }
    }

    struct stat st;
    if (stat(content, &st) != 0 || !S_ISDIR(st.st_mode)) {
        fprintf(stderr, "content directory not found: %s\n", content);
        return 1;
    }
    if (access(astcenc, X_OK) != 0) {
        fprintf(stderr, "astcenc not executable: %s\n", astcenc);
        g_encoder_broken = 1;
    }

    char tmpdir[PATH_MAX] = "/tmp/jk-astc-XXXXXX";
    if (mkdtemp(tmpdir) == NULL) {
        fprintf(stderr, "cannot create temporary directory\n");
        return 1;
    }

    printf("Converting textures in %s\n", content);
    fflush(stdout);
    if (!g_encoder_broken)
        walk(content, 0, astcenc, quality, threads, tmpdir);

    rmdir(tmpdir);

    printf("ASTC conversion finished: %d converted, %d kept RGBA, %d skipped, %d failed\n",
           g_converted, g_kept, g_skipped, g_failed);
    fflush(stdout);

    if (g_encoder_broken)
        return 2;
    if (g_converted == 0 && g_failed > 0)
        return 2;
    return 0;
}
