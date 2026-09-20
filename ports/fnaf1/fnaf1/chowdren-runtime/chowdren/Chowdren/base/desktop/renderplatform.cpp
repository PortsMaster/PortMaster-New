#include "render.h"
#include "glslshader.h"
#include "fbo.h"

RenderData render_data;

float render_texcoords2[12] = {
    0.0f, 1.0f,
    1.0f, 1.0f,
    1.0f, 0.0f,
    
    1.0f, 0.0f,
    0.0f, 0.0f,
    0.0f, 1.0f
};

#ifdef CHOWDREN_USE_D3D

static LPDIRECT3DVERTEXDECLARATION9 decl_instance = 0;

void d3d_reset_state()
{
    BaseShader::current = NULL;
    render_data.last_sampler = (D3DTEXTUREFILTERTYPE)-1;
    render_data.device->SetVertexDeclaration(decl_instance);
    render_data.device->SetRenderState(D3DRS_SEPARATEALPHABLENDENABLE, TRUE);
    render_data.device->SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
    render_data.device->SetRenderState(D3DRS_ALPHABLENDENABLE, TRUE);

    render_data.device->SetRenderState(D3DRS_SRCBLEND,
                                       D3DBLEND_SRCALPHA);
    render_data.device->SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);

    render_data.device->SetRenderState(D3DRS_SRCBLENDALPHA, D3DBLEND_ONE);
    render_data.device->SetRenderState(D3DRS_DESTBLENDALPHA, D3DBLEND_ONE);

    render_data.device->SetRenderState(D3DRS_ZENABLE, D3DZB_FALSE);
    render_data.device->SetRenderState(D3DRS_LIGHTING, FALSE);

    render_data.device->SetSamplerState(0, D3DSAMP_ADDRESSU,
                                        D3DTADDRESS_CLAMP);
    render_data.device->SetSamplerState(0, D3DSAMP_ADDRESSV,
                                        D3DTADDRESS_CLAMP);
    render_data.device->SetSamplerState(1, D3DSAMP_ADDRESSU,
                                        D3DTADDRESS_CLAMP);
    render_data.device->SetSamplerState(1, D3DSAMP_ADDRESSV,
                                        D3DTADDRESS_CLAMP);
}

void d3d_set_backtex_size(int w, int h)
{
    if (render_data.backtex_width == w && render_data.backtex_height == h)
        return;
    render_data.backtex_width = w;
    render_data.backtex_height = h;
    TextureData & td = render_data.textures[render_data.back_tex];
    if (td.texture != NULL)
        td.texture->Release();
    render_data.device->CreateTexture(w, h, 1, D3DUSAGE_RENDERTARGET,
                                      D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT,
                                      &td.texture, NULL);
}

#else

void set_gl_state()
{
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

    glEnable(GL_BLEND);
    glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE);

    glVertexPointer(2, GL_FLOAT, 0,
                    (void*)&render_data.positions[0]);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, (void*)&render_data.colors[0]);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

    glClientActiveTexture(GL_TEXTURE0);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, (void*)&render_data.texcoord1[0]); 

    glClientActiveTexture(GL_TEXTURE1);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, (void*)&render_texcoords2[0]);

    glClientActiveTexture(GL_TEXTURE0);
}

#endif

void Render::init()
{
#ifdef CHOWDREN_USE_D3D
    int info[4];
    __cpuid(info, 0);
    render_data.has_sse2 = false;
    if (info[0] >= 1) {
        __cpuid(info, 1);
        render_data.has_sse2 = (info[3] >> 26) & 1;
    }

    D3DVERTEXELEMENT9 decl[] = {
        {0, 0, D3DDECLTYPE_FLOAT2, D3DDECLMETHOD_DEFAULT,
         D3DDECLUSAGE_POSITION, 0},
        {0, 8, D3DDECLTYPE_D3DCOLOR, D3DDECLMETHOD_DEFAULT,
         D3DDECLUSAGE_COLOR, 0},
        {0, 8+4, D3DDECLTYPE_FLOAT2, D3DDECLMETHOD_DEFAULT,
         D3DDECLUSAGE_TEXCOORD, 0},
        {0, 8+4+8, D3DDECLTYPE_FLOAT2, D3DDECLMETHOD_DEFAULT,
         D3DDECLUSAGE_TEXCOORD, 1},
         D3DDECL_END()
    };
    render_data.device->CreateVertexDeclaration(decl, &decl_instance);

    d3d_reset_state();

    for (int i = 0; i < MAX_TEX; ++i) {
        if (render_data.textures[i].texture == NULL) {
            render_data.back_tex = i;
            break;
        }
    }

#ifdef CHOWDREN_QUICK_SCALE
    render_data.textures[render_data.back_tex].sampler = D3DTEXF_POINT;
#else
    render_data.textures[render_data.back_tex].sampler = D3DTEXF_LINEAR;
#endif

    d3d_set_backtex_size(1, 1);

    const float back_texcoords[12] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,

        1.0f, 0.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
    };

    for (int i = 0; i < 6; ++i) {
        render_data.vertices[i].texcoord2[0] = back_texcoords[i*2];
        render_data.vertices[i].texcoord2[1] = back_texcoords[i*2+1];
    }
#else
    set_gl_state();

    // glBindBuffer(GL_ARRAY_BUFFER, 0);
    // glEnableVertexAttribArray(POSITION_ATTRIB_IDX);
    // glVertexAttribPointer(POSITION_ATTRIB_IDX, 3, GL_FLOAT, GL_FALSE, 0,
    //                       (void*)&render_data.positions[0]);
    // glEnableVertexAttribArray(COLOR_ATTRIB_IDX);
    // glVertexAttribPointer(COLOR_ATTRIB_IDX, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0,
    //                       (void*)&render_data.colors[0]);

    // glVertexAttribPointer(TEXCOORD1_ATTRIB_IDX, 2, GL_FLOAT, GL_FALSE, 0,
    //                       (void*)&render_data.texcoords[0]);

    // glVertexAttribPointer(TEXCOORD2_ATTRIB_IDX, 2, GL_FLOAT, GL_FALSE, 0,
    //                       (void*)&render_data.texcoords[1]);


    glGenTextures(1, &render_data.back_tex);
    set_tex(render_data.back_tex);
#ifdef CHOWDREN_QUICK_SCALE
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
#else
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
#endif
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
#endif

    unsigned int white = 0xFFFFFFFF;
    render_data.white_tex = Render::create_tex(&white, RGBA, 1, 1);
    render_data.last_tex = 0;
}

#ifdef CHOWDREN_USE_D3D

#include <emmintrin.h>

static void load_bgra_sse(int width, int height,
                          unsigned char *input,
                          unsigned char *output, int output_pitch)
{
    __m128i brMask = _mm_set1_epi32(0x00ff00ff);

    unsigned int * source = (unsigned int*)input;

    for (int y = 0; y < height; y++) {
        unsigned int *dest = (unsigned int*)&output[y * output_pitch];

        int x = 0;

        for (; ((intptr_t(&dest[x]) & 15) != 0) && x < width; x++) {
            unsigned int rgba = source[x];
            dest[x] = (_rotl(rgba, 16) & 0x00ff00ff) | (rgba & 0xff00ff00);
        }

        for (; x + 3 < width; x += 4) {
            __m128i sourceData = _mm_loadu_si128((const __m128i*)&source[x]);
            __m128i gaComponents = _mm_andnot_si128(brMask, sourceData);
            __m128i brComponents = _mm_and_si128(sourceData, brMask);
            __m128i brSwapped = _mm_shufflehi_epi16(
                _mm_shufflelo_epi16(brComponents,
                                    _MM_SHUFFLE(2, 3, 0, 1)),
                                    _MM_SHUFFLE(2, 3, 0, 1));
            __m128i result = _mm_or_si128(gaComponents, brSwapped);
            _mm_store_si128((__m128i*)&dest[x], result);
        }

        for (; x < width; x++) {
            unsigned int rgba = source[x];
            dest[x] = (_rotl(rgba, 16) & 0x00ff00ff) | (rgba & 0xff00ff00);
        }

        source += width;
    }
}

static void load_bgra(int width, int height, unsigned char * input,
                      unsigned char *output, int output_pitch)
{
    unsigned int * input2 = (unsigned int*)input;

    for (int y = 0; y < height; ++y) {
        unsigned int * output2 = (unsigned int*)&output[y * output_pitch];

        for (int x = 0; x < width; ++x) {
            unsigned int rgba = input2[x];
            output2[x] = (_rotl(rgba, 16) & 0x00ff00ff) | (rgba & 0xff00ff00);
        }

        input2 += width;
    }
}

static void set_rgba_data(void * in_pixels, D3DLOCKED_RECT * rect,
                          int width, int height)
{
    unsigned char * data = (unsigned char*)rect->pBits;
    unsigned char * pixels = (unsigned char*)in_pixels;
    if (render_data.has_sse2)
        load_bgra_sse(width, height, pixels, data, rect->Pitch);
    else
        load_bgra(width, height, pixels, data, rect->Pitch);
}

static void set_alpha_data(void * in_pixels, D3DLOCKED_RECT * rect,
                           int width, int height)
{
    if (rect->Pitch == width) {
        memcpy(rect->pBits, in_pixels, width * height);
        return;
    }
    unsigned char * data = (unsigned char*)rect->pBits;
    unsigned char * pixels = (unsigned char*)in_pixels;
    for (int y = 0; y < height; y++) {
        memcpy(data, pixels, width);
        data += rect->Pitch;
        pixels += width;
    }
}

Texture Render::create_tex(void * pixels, Format f, int width, int height)
{
    Texture tex;
    for (tex = 0; tex < MAX_TEX; ++tex) {
        if (render_data.textures[tex].texture == NULL)
            break;
    }

    if (tex == MAX_TEX)
        return 0;

    D3DFORMAT format;
    switch (f) {
        case RGBA:
            format = D3DFMT_A8R8G8B8;
            break;
        case L:
            format = D3DFMT_A8;
            break;
    }
    TextureData & t = render_data.textures[tex];
    render_data.device->CreateTexture(width, height, 1, 0, format,
                                      D3DPOOL_MANAGED, &t.texture, NULL);

    D3DLOCKED_RECT rect;
    t.texture->LockRect(0, &rect, NULL, 0);
    switch (f) {
        case RGBA:
            set_rgba_data(pixels, &rect, width, height);
            break;
        case L:
            set_alpha_data(pixels, &rect, width, height);
            break;
    }
    t.texture->UnlockRect(0);
    return tex;
}

Texture Render::copy_rect(int x1, int in_y1, int x2, int in_y2)
{
    int y1 = current_fbo->h - in_y2;
    int y2 = current_fbo->h - in_y1;
    int xx1, yy1, xx2, yy2;
    intersect(0, 0, current_fbo->w, current_fbo->h, x1, y1, x2, y2,
              xx1, yy1, xx2, yy2);
    TextureData & tex = render_data.textures[render_data.back_tex];
    int w, h;
    w = x2 - x1;
    h = y2 - y1;

    RECT src = {xx1, yy1, xx2, yy2};
    RECT dst = {xx1 - x1, yy1 - y1, xx2 - x1, yy2 - y1};

    d3d_set_backtex_size(w, h);
    IDirect3DSurface9 * surface;
    TextureData & td = render_data.textures[render_data.back_tex];
    td.texture->GetSurfaceLevel(0, &surface);
    render_data.device->StretchRect(current_fbo->fbo, &src, surface, &dst,
                                    D3DTEXF_NONE);
    surface->Release();
    return render_data.back_tex;
}

#endif
