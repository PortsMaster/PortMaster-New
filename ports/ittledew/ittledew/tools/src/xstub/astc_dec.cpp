/*
 * astc_dec: ASTC 4x4 LDR blocks -> RGBA8 with ARM's astcenc (Apache-2.0, decompress-only build), for glxsdl's
 * fallback on GPUs without GL_KHR_texture_compression_astc_ldr. C interface.
 */
#include <stdint.h>
#include <stdio.h>
#include "astcenc.h"

static astcenc_context *dctx;

/* blocks: (w/4)*(h/4) ASTC 4x4 blocks; rgba: w*h*4 bytes; w and h multiples of 4 */
extern "C" int astc_decode(const uint8_t *blocks, int w, int h, uint8_t *rgba)
{
    if (!dctx) {
        astcenc_config cfg;
        if (astcenc_config_init(ASTCENC_PRF_LDR, 4, 4, 1, ASTCENC_PRE_FASTEST, ASTCENC_FLG_DECOMPRESS_ONLY, &cfg) != ASTCENC_SUCCESS ||
            astcenc_context_alloc(&cfg, 1, &dctx) != ASTCENC_SUCCESS) { fprintf(stderr, "[glxsdl] astcenc decoder init failed\n"); return -1; }
    }
    void *slices[1] = { rgba };
    astcenc_image img;
    img.dim_x = (unsigned)w; img.dim_y = (unsigned)h; img.dim_z = 1;
    img.data_type = ASTCENC_TYPE_U8; img.data = slices;
    static const astcenc_swizzle swz = { ASTCENC_SWZ_R, ASTCENC_SWZ_G, ASTCENC_SWZ_B, ASTCENC_SWZ_A };
    astcenc_error e = astcenc_decompress_image(dctx, blocks, (size_t)(w / 4) * (h / 4) * 16, &img, &swz, 0);
    astcenc_decompress_reset(dctx);
    return e == ASTCENC_SUCCESS ? 0 : -1;
}
