#ifndef CHOWDREN_GLSLSHADER_H
#define CHOWDREN_GLSLSHADER_H

#include "include_gl.h"
#include "fileio.h"

class FrameObject;

class BaseShader
{
public:
    static BaseShader * current;

#ifdef CHOWDREN_USE_D3D
    int tex_sampler;
    int back_sampler;
    int tex_param_sampler;
    int size_uniform;
    IDirect3DVertexShader9 * vert_shader;
    IDirect3DPixelShader9 * frag_shader;
#else
    GLuint program;
    GLint size_uniform;
    GLuint attach_source(FSFile & fp, GLenum type);
#endif
    bool initialized;
    unsigned int id;
    int flags;
    const char * texture_parameter;

    BaseShader(unsigned int id, int flags = 0,
               const char * texture_parameter = NULL);
    void initialize();
    int get_uniform(const char * value);
    virtual void initialize_parameters();
    void begin(FrameObject * instance, int width, int height);
    static void set_int(FrameObject * instance, int src, int uniform);
    static void set_float(FrameObject * instance, int src, int uniform);
    static void set_vec4(FrameObject * instance, int src, int uniform);
    static void set_image(FrameObject * instance, int src);
};

void set_scale_uniform(float width, float height,
                       float x_scale, float y_scale);

#endif // CHOWDREN_GLSLSHADER_H
