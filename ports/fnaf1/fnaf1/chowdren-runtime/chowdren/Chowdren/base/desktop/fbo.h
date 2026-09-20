#ifndef CHOWDREN_FBO_H
#define CHOWDREN_FBO_H

#include "include_gl.h"
#include "render.h"

class Framebuffer;
extern Framebuffer * current_fbo;

class Framebuffer
{
public:
    Texture tex;
#ifdef CHOWDREN_USE_D3D
    IDirect3DSurface9 * fbo;
    int fbo_index, w, h;
    static Framebuffer * fbos[32];
#else
    GLuint fbo;
#endif
    Framebuffer * old_fbo;

    Framebuffer(int w, int h);
    Framebuffer();
    ~Framebuffer();
    void init(int w, int h);
    void bind();
    void unbind();
    Texture get_tex();
};

#endif // CHOWDREN_FBO_H
