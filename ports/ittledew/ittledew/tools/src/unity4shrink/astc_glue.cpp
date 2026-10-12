/*
 * astc_glue: RGBA8 image -> ASTC 4x4 LDR blocks with ARM's astcenc (Apache-2.0), "fast" preset, for unity4shrink -a:
 * on an RG Cube XX half the time of "medium" (19 vs 36 s on three sharedassets files) with nearly its quality (PSNR
 * against the DXT5 source 56.6 vs 58.4 dB). One context with N worker threads, reused for every image; C interface so
 * unity4shrink.c stays C.
 */
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include "astcenc.h"

static astcenc_context *ctx;
static unsigned nthreads;

typedef struct { astcenc_image *img; uint8_t *out; size_t len; unsigned id; astcenc_error err; } job_t;

static void *worker(void *a)
{
    job_t *j = (job_t *)a;
    static const astcenc_swizzle swz = { ASTCENC_SWZ_R, ASTCENC_SWZ_G, ASTCENC_SWZ_B, ASTCENC_SWZ_A };
    j->err = astcenc_compress_image(ctx, j->img, &swz, j->out, j->len, j->id);
    return nullptr;
}

extern "C" int astc_init(unsigned threads)
{
    astcenc_config cfg;
    nthreads = threads < 1 ? 1 : threads > 64 ? 64 : threads;
    astcenc_error e = astcenc_config_init(ASTCENC_PRF_LDR, 4, 4, 1, ASTCENC_PRE_FAST, 0, &cfg);
    if (e == ASTCENC_SUCCESS) e = astcenc_context_alloc(&cfg, nthreads, &ctx);
    if (e != ASTCENC_SUCCESS) fprintf(stderr, "astcenc: %s\n", astcenc_get_error_string(e));
    return e != ASTCENC_SUCCESS;
}

/* rgba: w x h pixels (multiples of 4); out: (w/4)*(h/4)*16 bytes. Images under 64 blocks use one thread. */
extern "C" int astc_encode(uint8_t *rgba, int w, int h, uint8_t *out)
{
    void *slices[1] = { rgba };
    astcenc_image img = { (unsigned)w, (unsigned)h, 1, ASTCENC_TYPE_U8, slices };
    size_t blocks = (size_t)(w / 4) * (h / 4);
    unsigned n = blocks >= 64 ? nthreads : 1;
    job_t jobs[64]; pthread_t th[64];
    for (unsigned i = 0; i < n; i++) {
        jobs[i] = job_t{ &img, out, blocks * 16, i, ASTCENC_SUCCESS };
        if (i) pthread_create(&th[i], nullptr, worker, &jobs[i]);
    }
    worker(&jobs[0]);
    for (unsigned i = 1; i < n; i++) pthread_join(th[i], nullptr);
    astcenc_compress_reset(ctx);
    for (unsigned i = 0; i < n; i++)
        if (jobs[i].err != ASTCENC_SUCCESS) { fprintf(stderr, "astcenc: %s\n", astcenc_get_error_string(jobs[i].err)); return -1; }
    return 0;
}
