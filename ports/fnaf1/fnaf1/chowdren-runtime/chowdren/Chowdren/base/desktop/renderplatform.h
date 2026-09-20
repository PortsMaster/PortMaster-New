#ifndef CHOWDREN_RENDERPLATFORM_H
#define CHOWDREN_RENDERPLATFORM_H

#include "include_gl.h"
#include "shadercommon.h"
#include "mathcommon.h"
#include <string.h>
#include "glslshader.h"

// XXX consider merging drawcalls
#define RENDER_BUFFER 1

#ifdef CHOWDREN_USE_D3D
struct TextureData
{
    IDirect3DTexture9 * texture;
    D3DTEXTUREFILTERTYPE sampler;
};

#define MAX_TEX 25000
#endif

struct RenderData
{
#ifdef CHOWDREN_USE_D3D
    IDirect3D9 * d3d;
    IDirect3DDevice9 * device;
    IDirect3DSurface9 * default_target;
    TextureData textures[MAX_TEX];

    struct Vertex
    {
        float pos[2];
        unsigned int color;
        float texcoord1[2];
        float texcoord2[2];
    };

    Vertex vertices[6];
    D3DTEXTUREFILTERTYPE last_sampler;
    bool has_sse2;
    int backtex_width, backtex_height;
#else
    float positions[(RENDER_BUFFER * 3) * 6];
    unsigned int colors[RENDER_BUFFER * 6];
    float texcoord1[(RENDER_BUFFER * 2) * 6];
#endif
    Texture last_tex, white_tex, back_tex;
    int effect;
    float adjust_x, adjust_y;
    float trans_x, trans_y;
    float pos_x, pos_y;
    int viewport[4];
};

extern RenderData render_data;

inline float transform_x(float x)
{
    return (x + render_data.pos_x) * render_data.trans_x;
}

inline float transform_y(float y)
{
    return (y + render_data.pos_y) * render_data.trans_y;
}

#ifndef CHOWDREN_USE_D3D
inline void set_tex(Texture t)
{
    if (render_data.last_tex != t) {
        glBindTexture(GL_TEXTURE_2D, t);
        render_data.last_tex = t;
    }
}
#endif

inline void Render::set_offset(int x, int y)
{
    offset[0] = x;
    offset[1] = y;
    render_data.pos_x = x + render_data.adjust_x;
    render_data.pos_y = y + render_data.adjust_y;
}

inline void Render::set_view(int x, int y, int w, int h)
{
#ifdef CHOWDREN_USE_D3D
    D3DVIEWPORT9 viewport;
    viewport.X = x;
    viewport.Y = y;
    viewport.Width = w;
    viewport.Height = h;
    viewport.MinZ = 0.0f;
    viewport.MaxZ = 1.0f;
    render_data.device->SetViewport(&viewport);
    render_data.adjust_x = -(w + 1) / 2.0f;
    render_data.adjust_y = -(h - 1) / 2.0f;
    render_data.trans_x = 2.0f / w;
    render_data.trans_y = 2.0f / h;
#else
    glViewport(x, y, w, h);
    render_data.adjust_x = -w / 2.0f;
    render_data.adjust_y = -h / 2.0f;
    render_data.trans_x = 2.0f / w;
    render_data.trans_y = -2.0f / h;
#endif
    set_offset(offset[0], offset[1]);
    render_data.viewport[0] = x;
    render_data.viewport[1] = y;
    render_data.viewport[2] = w;
    render_data.viewport[3] = h;
}

inline void Render::clear(Color c)
{
#ifdef CHOWDREN_USE_D3D
    render_data.device->Clear(0, NULL, D3DCLEAR_TARGET,
                              D3DCOLOR_ARGB(c.a, c.r, c.g, c.b),
                              0.0f, 0);
#else
    glClearColor(c.r / 255.0f, c.g / 255.0f, c.b / 255.0f, c.a / 255.0f);
    glClear(GL_COLOR_BUFFER_BIT);
#endif
}

inline void Render::set_filter(Texture tex, bool linear)
{
#ifdef CHOWDREN_USE_D3D
    TextureData & t = render_data.textures[tex];
    if (linear)
        t.sampler = D3DTEXF_LINEAR;
    else
        t.sampler = D3DTEXF_POINT;
#else
    set_tex(tex);
    if (linear) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    } else {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    }
#endif
}

#ifndef CHOWDREN_USE_D3D

#ifdef CHOWDREN_RGBA4444_TEXUPLOAD
// Real GPU-side texture memory halving. This is separate from
// CHOWDREN_16BIT_IMAGE, which only affects transparent-color-key
// matching tolerance in image.cpp and never touches what actually
// gets uploaded to the GPU.
//
// RGBA8888 (4 bytes/pixel) is packed down to RGBA4444 (2 bytes/pixel,
// 4 bits per channel) client-side, then uploaded with
// GL_UNSIGNED_SHORT_4_4_4_4. Halves VRAM/texture-memory usage and the
// upload bandwidth per texture, at the cost of 4-bit-per-channel
// color/alpha banding. Valid on both desktop GL and GLES2 - no
// USE_GL/USE_GLES2 branching needed here.
inline unsigned short * pack_rgba4444(const unsigned char * pixels,
                                       int width, int height)
{
    int count = width * height;
    unsigned short * out = new unsigned short[count];
    for (int i = 0; i < count; i++) {
        const unsigned char * p = &pixels[i * 4];
        unsigned short r = p[0] >> 4;
        unsigned short g = p[1] >> 4;
        unsigned short b = p[2] >> 4;
        unsigned short a = p[3] >> 4;
        out[i] = (r << 12) | (g << 8) | (b << 4) | a;
    }
    return out;
}
#endif

inline Texture Render::create_tex(void * pixels, Format f,
                                  int width, int height)
{
    GLuint tex;
    glGenTextures(1, &tex);
    set_tex(tex);

    GLenum format;
    switch (f) {
        case RGBA:
            format = GL_RGBA;
            break;
        case L:
            format = GL_ALPHA;
            break;
    }

#ifdef CHOWDREN_RGBA4444_TEXUPLOAD
    if (f == RGBA) {
        // Font glyphs (L format) are already 1 byte/pixel - only RGBA
        // images are worth halving here.
        std::cout << "Loading RGBA image (4444 packed): " << width << "x"
                   << height << std::endl;
        unsigned short * packed = pack_rgba4444(
            (const unsigned char*)pixels, width, height);
        glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format,
                     GL_UNSIGNED_SHORT_4_4_4_4, packed);
        delete[] packed;
    } else {
        glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format,
                     GL_UNSIGNED_BYTE, pixels);
    }
#else
    glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format,
                 GL_UNSIGNED_BYTE, pixels);
#endif
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    return tex;
}
#endif

inline void Render::delete_tex(Texture tex)
{
#ifdef CHOWDREN_USE_D3D
    TextureData & td = render_data.textures[tex];
    td.texture->Release();
    td.texture = NULL;
#else
    glDeleteTextures(1, &tex);
    if (render_data.last_tex == tex)
        render_data.last_tex = 0;
#endif
}

const float render_texcoords[12] = {
    0.0f, 0.0f,
    1.0f, 0.0f,
    1.0f, 1.0f,

    1.0f, 1.0f,
    0.0f, 1.0f,
    0.0f, 0.0f
};

#ifdef CHOWDREN_USE_D3D

inline void insert_quad(float * p)
{
    RenderData::Vertex * pp = &render_data.vertices[0];

    // triangle 1
    float x1 = transform_x(p[0]);
    pp[0].pos[0] = x1;
    float y1 = transform_y(p[1]);
    pp[0].pos[1] = y1;
    pp[1].pos[0] = transform_x(p[2]);
    pp[1].pos[1] = transform_y(p[3]);

    float x3 = transform_x(p[4]);
    float y3 = transform_y(p[5]);
    pp[2].pos[0] = x3;
    pp[2].pos[1] = y3;

    // triangle 2
    pp[3].pos[0] = x3;
    pp[3].pos[1] = y3;

    pp[4].pos[0] = transform_x(p[6]);
    pp[4].pos[1] = transform_y(p[7]);
    pp[5].pos[0] = x1;
    pp[5].pos[1] = y1;
}

inline void insert_quad(int x1, int y1, int x2, int y2)
{
    float fx1 = transform_x(x1);
    float fx2 = transform_x(x2);
    float fy1 = transform_y(y1);
    float fy2 = transform_y(y2);

    RenderData::Vertex * p = &render_data.vertices[0];

    // 1
    p[0].pos[0] = fx1; p[0].pos[1] = fy1;
    p[1].pos[0] = fx2; p[1].pos[1] = fy1;
    p[2].pos[0] = fx2; p[2].pos[1] = fy2;

    // 2
    p[3].pos[0] = fx2; p[3].pos[1] = fy2;
    p[4].pos[0] = fx1; p[4].pos[1] = fy2;
    p[5].pos[0] = fx1; p[5].pos[1] = fy1;
}

inline void insert_color(Color c)
{
    unsigned int cc = D3DCOLOR_ARGB(c.a, c.r, c.g, c.b);

    RenderData::Vertex * p = &render_data.vertices[0];
    for (int i = 0; i < 6; ++i)
        p[i].color = cc;
}

inline void insert_horizontal_color(Color c1, Color c2)
{
    unsigned int cc1 = D3DCOLOR_ARGB(c1.a, c1.r, c1.g, c1.b);
    unsigned int cc2 = D3DCOLOR_ARGB(c2.a, c2.r, c2.g, c2.b);

    RenderData::Vertex * p = &render_data.vertices[0];
    p[0].color = cc1;
    p[1].color = cc2;
    p[2].color = cc2;
    p[3].color = cc2;
    p[4].color = cc1;
    p[5].color = cc1;
}

inline void insert_vertical_color(Color c1, Color c2)
{
    unsigned int cc1 = D3DCOLOR_ARGB(c1.a, c1.r, c1.g, c1.b);
    unsigned int cc2 = D3DCOLOR_ARGB(c2.a, c2.r, c2.g, c2.b);

    RenderData::Vertex * p = &render_data.vertices[0];
    p[0].color = cc1;
    p[1].color = cc1;
    p[2].color = cc2;

    p[3].color = cc2;
    p[4].color = cc2;
    p[5].color = cc1;
}

inline void insert_texcoord1()
{
    RenderData::Vertex * p = &render_data.vertices[0];
    for (int i = 0; i < 6; ++i) {
        p[i].texcoord1[0] = render_texcoords[i*2];
        p[i].texcoord1[1] = render_texcoords[i*2+1];
    }
}

inline void insert_texcoord1(float fx1, float fy1, float fx2, float fy2)
{
    RenderData::Vertex * p = &render_data.vertices[0];

    // 1
    p->texcoord1[0] = fx1; p->texcoord1[1] = fy1; p++;
    p->texcoord1[0] = fx2; p->texcoord1[1] = fy1; p++;
    p->texcoord1[0] = fx2; p->texcoord1[1] = fy2; p++;

    // 2
    p->texcoord1[0] = fx2; p->texcoord1[1] = fy2; p++;
    p->texcoord1[0] = fx1; p->texcoord1[1] = fy2; p++;
    p->texcoord1[0] = fx1; p->texcoord1[1] = fy1; p++;
}

#else

inline void insert_quad(float * p)
{
    float * pp = &render_data.positions[0];

    // triangle 1
    float x1 = transform_x(p[0]);
    *pp++ = x1;
    float y1 = transform_y(p[1]);
    *pp++ = y1;
    *pp++ = transform_x(p[2]);
    *pp++ = transform_y(p[3]);

    float x3 = transform_x(p[4]);
    float y3 = transform_y(p[5]);
    *pp++ = x3;
    *pp++ = y3;

    // triangle 2
    *pp++ = x3;
    *pp++ = y3;

    *pp++ = transform_x(p[6]);
    *pp++ = transform_y(p[7]);
    *pp++ = x1;
    *pp++ = y1;
}

inline void insert_quad(int x1, int y1, int x2, int y2)
{
    float fx1 = transform_x(x1);
    float fx2 = transform_x(x2);
    float fy1 = transform_y(y1);
    float fy2 = transform_y(y2);

    float * p = &render_data.positions[0];

    // 1
    *p++ = fx1; *p++ = fy1;
    *p++ = fx2; *p++ = fy1;
    *p++ = fx2; *p++ = fy2;

    // 2
    *p++ = fx2; *p++ = fy2;
    *p++ = fx1; *p++ = fy2;
    *p++ = fx1; *p++ = fy1;
}

inline void insert_color(Color c)
{
    unsigned int cc;
    // rely on endianness
    memcpy(&cc, &c, sizeof(Color));

    unsigned int * p = &render_data.colors[0];
    for (int i = 0; i < 6; ++i)
        *p++ = cc;
}

inline void insert_horizontal_color(Color c1, Color c2)
{
    unsigned int cc1, cc2;
    // rely on endianness
    memcpy(&cc1, &c1, sizeof(Color));
    memcpy(&cc2, &c2, sizeof(Color));

    unsigned int * p = &render_data.colors[0];
    *p++ = cc1;
    *p++ = cc2;
    *p++ = cc2;
    *p++ = cc2;
    *p++ = cc1;
    *p++ = cc1;
}

inline void insert_vertical_color(Color c1, Color c2)
{
    unsigned int cc1, cc2;
    // rely on endianness
    memcpy(&cc1, &c1, sizeof(Color));
    memcpy(&cc2, &c2, sizeof(Color));

    unsigned int * p = &render_data.colors[0];
    *p++ = cc1;
    *p++ = cc1;
    *p++ = cc2;

    *p++ = cc2;
    *p++ = cc2;
    *p++ = cc1;
}

inline void insert_texcoord1()
{
    memcpy(&render_data.texcoord1[0], &render_texcoords[0],
           sizeof(render_texcoords));
}

inline void insert_texcoord1(float fx1, float fy1, float fx2, float fy2)
{
    float * p = &render_data.texcoord1[0];

    // 1
    *p++ = fx1; *p++ = fy1;
    *p++ = fx2; *p++ = fy1;
    *p++ = fx2; *p++ = fy2;

    // 2
    *p++ = fx2; *p++ = fy2;
    *p++ = fx1; *p++ = fy2;
    *p++ = fx1; *p++ = fy1;
}
#endif

inline void begin_draw(Texture t)
{
    if (render_data.effect == Render::NONE)
        shader_set_texture();

#ifdef CHOWDREN_USE_D3D
    TextureData & td = render_data.textures[t];
    render_data.device->SetTexture(BaseShader::current->tex_sampler,
                                   td.texture);
    if (td.sampler != render_data.last_sampler) {
        render_data.last_sampler = td.sampler;    
        render_data.device->SetSamplerState(0, D3DSAMP_MAGFILTER,
                                            td.sampler);
        render_data.device->SetSamplerState(0, D3DSAMP_MINFILTER,
                                            td.sampler);
    }
#else
    if (render_data.last_tex == t)
        return;
    render_data.last_tex = t;
    glBindTexture(GL_TEXTURE_2D, t);
#endif
}

inline void Render::draw_quad(int x1, int y1, int x2, int y2, Color c)
{
    draw_tex(x1, y1, x2, y2, c, render_data.white_tex);
}

inline void Render::draw_quad(float * p, Color c)
{
    draw_tex(p, c, render_data.white_tex);
}

#ifdef CHOWDREN_USE_D3D
inline void draw_tex_impl(Texture t)
{
    render_data.device->DrawPrimitiveUP(D3DPT_TRIANGLELIST, 2,
                                        &render_data.vertices[0],
                                        sizeof(RenderData::Vertex));
}
#endif

inline void Render::draw_tex(int x1, int y1, int x2, int y2, Color c,
                             Texture t)
{
    begin_draw(t);

    insert_quad(x1, y1, x2, y2);
    insert_color(c);
    insert_texcoord1();

#ifdef CHOWDREN_USE_D3D
    draw_tex_impl(t);
#else
    glDrawArrays(GL_TRIANGLES, 0, 6);
#endif
}

inline void Render::draw_tex(int x1, int y1, int x2, int y2, Color c,
                             Texture t,
                             float tx1, float ty1, float tx2, float ty2)
{
    begin_draw(t);

    insert_quad(x1, y1, x2, y2);
    insert_color(c);
    insert_texcoord1(tx1, ty1, tx2, ty2);

#ifdef CHOWDREN_USE_D3D
    draw_tex_impl(t);
#else
    glDrawArrays(GL_TRIANGLES, 0, 6);
#endif
}

inline void Render::draw_tex(float * p, Color c, Texture t)
{
    begin_draw(t);

    insert_color(c);
    insert_texcoord1();
    insert_quad(p);

#ifdef CHOWDREN_USE_D3D
    draw_tex_impl(t);
#else
    glDrawArrays(GL_TRIANGLES, 0, 6);
#endif
}

inline void Render::draw_horizontal_gradient(int x1, int y1, int x2, int y2,
                                             Color c1, Color c2)
{
    begin_draw(render_data.white_tex);

    insert_quad(x1, y1, x2, y2);
    insert_horizontal_color(c1, c2);
    insert_texcoord1();

#ifdef CHOWDREN_USE_D3D
    draw_tex_impl(render_data.white_tex);
#else
    glDrawArrays(GL_TRIANGLES, 0, 6);
#endif
}

inline void Render::draw_vertical_gradient(int x1, int y1, int x2, int y2,
                                           Color c1, Color c2)
{
    begin_draw(render_data.white_tex);

    insert_quad(x1, y1, x2, y2);
    insert_vertical_color(c1, c2);
    insert_texcoord1();

#ifdef CHOWDREN_USE_D3D
    draw_tex_impl(render_data.white_tex);
#else
    glDrawArrays(GL_TRIANGLES, 0, 6);
#endif
}

inline void Render::set_effect(int effect, FrameObject * obj,
                               int width, int height)
{
    render_data.effect = effect;
    shader_set_effect(effect, obj, width, height);
}

inline void Render::set_effect(int effect)
{
    render_data.effect = effect;
    shader_set_effect(effect, NULL, 0, 0);
}

inline void Render::disable_effect()
{
    render_data.effect = NONE;
}

#ifndef CHOWDREN_USE_D3D

inline Texture Render::copy_rect(int x1, int y1, int x2, int y2)
{
    int width = x2 - x1;
    int height = y2 - y1;

    int y = WINDOW_HEIGHT - y2;
    set_tex(render_data.back_tex);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height,
                 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
    glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, x1, y, width, height);
    return render_data.back_tex;
}

#endif

inline void Render::enable_blend()
{
#ifdef CHOWDREN_USE_D3D
    render_data.device->SetRenderState(D3DRS_ALPHABLENDENABLE, TRUE);
#else
    glEnable(GL_BLEND);
#endif
}

inline void Render::disable_blend()
{
#ifdef CHOWDREN_USE_D3D
    render_data.device->SetRenderState(D3DRS_ALPHABLENDENABLE, FALSE);
#else
    glDisable(GL_BLEND);
#endif
}

inline void Render::enable_scissor(int x, int y, int w, int h)
{
    int w_x1 = int(x + offset[0]);
    int w_y2 = int(WINDOW_HEIGHT - y - offset[1]);
    int w_x2 = w_x1 + w;
    int w_y1 = w_y2 - h;

    w_x1 = int_max(0, int_min(w_x1, WINDOW_WIDTH));
    w_y1 = int_max(0, int_min(w_y1, WINDOW_HEIGHT));
    w_x2 = int_max(0, int_min(w_x2, WINDOW_WIDTH));
    w_y2 = int_max(0, int_min(w_y2, WINDOW_HEIGHT));

#ifdef CHOWDREN_USE_D3D
    RECT r;
    render_data.device->SetRenderState(D3DRS_SCISSORTESTENABLE, TRUE);
    r.left = w_x1;
    r.top = w_y1;
    r.right = w_x2;
    r.bottom = w_y2;
    render_data.device->SetScissorRect(&r);
#else
    glEnable(GL_SCISSOR_TEST);
    glScissor(w_x1, w_y1, w_x2 - w_x1, w_y2 - w_y1);
#endif
}

inline void Render::disable_scissor()
{
#ifdef CHOWDREN_USE_D3D
    render_data.device->SetRenderState(D3DRS_SCISSORTESTENABLE, FALSE);
#else
    glDisable(GL_SCISSOR_TEST);
#endif
}

#endif // CHOWDREN_RENDERPLATFORM_H
