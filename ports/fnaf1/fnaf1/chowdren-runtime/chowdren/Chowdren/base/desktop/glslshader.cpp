#include "shadercommon.h"
#include "glslshader.h"
#include "frameobject.h"
#include "manager.h"
#include "chowconfig.h"
#include "fileio.h"
#include "image.h"
#include "collision.h"
#include "datastream.h"
#include "assetfile.h"
#include "render.h"

#ifdef CHOWDREN_USE_D3D
#include "d3dconstant.h"
static ConstantTable constant_table;
#endif

BaseShader * BaseShader::current = NULL;

BaseShader::BaseShader(unsigned int id, int flags,
                       const char * texture_parameter)
: initialized(false), id(id), flags(flags),
  texture_parameter(texture_parameter)
{
}

static AssetFile fp;

void BaseShader::initialize()
{
    if (!fp.is_open())
        fp.open();

    fp.set_item(id, AssetFile::SHADER_DATA);

#ifdef CHOWDREN_USE_D3D
    FileStream stream(fp);
    unsigned int size;
    char * data;

    size = stream.read_uint32();
    data = new char[size];
    stream.read(data, size);
    render_data.device->CreateVertexShader((DWORD*)data, &vert_shader);

    size = stream.read_uint32();
    data = new char[size];
    stream.read(data, size);
    render_data.device->CreatePixelShader((DWORD*)data, &frag_shader);

    constant_table.read(data);

    tex_sampler = get_uniform(TEXTURE_SAMPLER_NAME);

    if (flags & SHADER_HAS_BACK)
        back_sampler = get_uniform(BACKTEX_SAMPLER_NAME);
    if (flags & SHADER_HAS_TEX_SIZE)
        size_uniform = get_uniform(SIZE_UNIFORM_NAME);
    if (texture_parameter != NULL)
        tex_param_sampler = get_uniform(texture_parameter);
#else
    program = glCreateProgramObject();
    GLuint vert_shader = attach_source(fp, GL_VERTEX_SHADER);
    GLuint frag_shader = attach_source(fp, GL_FRAGMENT_SHADER);

#ifndef CHOWDREN_USE_GL
    glBindAttribLocation(program, POSITION_ATTRIB_IDX, POSITION_ATTRIB_NAME);
    glBindAttribLocation(program, TEXCOORD1_ATTRIB_IDX, TEXCOORD1_ATTRIB_NAME);
    glBindAttribLocation(program, TEXCOORD2_ATTRIB_IDX, TEXCOORD2_ATTRIB_NAME);
    glBindAttribLocation(program, COLOR_ATTRIB_IDX, COLOR_ATTRIB_NAME);
#endif

    glLinkProgram(program);

    GLint status;
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        GLint info_len;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &info_len);
        GLchar * info_log = new GLchar[info_len + 1];
        glGetProgramInfoLog(program, info_len, NULL, info_log);
        std::cout << "Linker failure: " << info_log << std::endl;
        delete[] info_log;
    }

    glDetachObject(program, vert_shader);
    glDetachObject(program, frag_shader);

    glUseProgramObject(program);

    // setup uniforms
    glUniform1i((GLint)get_uniform(TEXTURE_SAMPLER_NAME), 0);

    if (flags & SHADER_HAS_BACK)
        glUniform1i((GLint)get_uniform(BACKTEX_SAMPLER_NAME), 1);
    if (flags & SHADER_HAS_TEX_SIZE)
        size_uniform = (GLint)get_uniform(SIZE_UNIFORM_NAME);

    if (texture_parameter != NULL) {
        glUniform1i((GLint)get_uniform(texture_parameter), 2);
    }
#endif

    current = NULL;
    initialize_parameters();
    initialized = true;
}

void BaseShader::initialize_parameters()
{
}

#ifndef CHOWDREN_USE_D3D
GLuint BaseShader::attach_source(FSFile & fp, GLenum type)
{
    GLuint shader = glCreateShaderObject(type);

    FileStream stream(fp);
    size_t size = stream.read_uint32();
    GLchar * data = new GLchar[size];
    stream.read(data, size);

    GLint len = size;
    glShaderSource(shader, 1, (const GLchar**)&data, &len);
    delete[] data;
    glCompileShader(shader);

    GLint status;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    GLint info_len = 0;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &info_len);
    if (info_len > 1) {
        GLchar * info_log = new GLchar[info_len + 1];
        glGetShaderInfoLog(shader, info_len, NULL, info_log);
        std::cerr << "[shader compile " << (status == GL_FALSE ? "FAIL" : "warn")
                  << " type=" << type << "]\n" << info_log << std::endl;
        delete[] info_log;
    }
    if (status != GL_FALSE)
        glAttachObject(program, shader);
    return shader;
}
#endif

void BaseShader::begin(FrameObject * instance, int width, int height)
{
    if (!initialized)
        initialize();

#ifdef CHOWDREN_USE_D3D
    if (flags & SHADER_HAS_BACK) {
        int box[4];
        instance->get_screen_aabb(box);
        Texture t = Render::copy_rect(box[0], box[1], box[2], box[3]);
        TextureData & td = render_data.textures[t];
        render_data.device->SetTexture(back_sampler, td.texture);
    }

    if (current != this) {
        render_data.device->SetPixelShader(frag_shader);
        render_data.device->SetVertexShader(vert_shader);
        current = this;
    }

    if (flags & SHADER_HAS_TEX_SIZE) {
        float v[4] = {1.0f / width, 1.0f / height, 0.0f, 0.0f};
        render_data.device->SetPixelShaderConstantF(size_uniform, &v[0], 1);
    }
#else
    if (flags & SHADER_HAS_BACK) {
        int box[4];
        instance->get_screen_aabb(box);
        Texture t = Render::copy_rect(box[0], box[1], box[2], box[3]);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, t);
        glActiveTexture(GL_TEXTURE0);
    }

    if (current != this) {
        glUseProgramObject(program);
        current = this;
    }

    if (flags & SHADER_HAS_TEX_SIZE) {
        glUniform2f(size_uniform, 1.0f / width, 1.0f / height);
    }
#endif
}

void BaseShader::set_int(FrameObject * instance, int src, int uniform)
{
    int val = (int)instance->get_shader_parameter(src);
#ifdef CHOWDREN_USE_D3D
    float v[4] = {val, 0, 0, 0};
    render_data.device->SetPixelShaderConstantF(uniform, &v[0], 1);
#else
    glUniform1i((GLint)uniform, val);
#endif
}

void BaseShader::set_float(FrameObject * instance, int src, int uniform)
{
#ifdef CHOWDREN_USE_D3D
    float v[4] = {instance->get_shader_parameter(src), 0.0f, 0.0f, 0.0f};
    render_data.device->SetPixelShaderConstantF(uniform, &v[0], 1);
#else
    glUniform1f((GLint)uniform, instance->get_shader_parameter(src));
#endif
}

void BaseShader::set_vec4(FrameObject * instance, int src, int uniform)
{
    int val = (int)instance->get_shader_parameter(src);
    float v[4];
    convert_vec4(val, v[0], v[1], v[2], v[3]);
#ifdef CHOWDREN_USE_D3D
    render_data.device->SetPixelShaderConstantF(uniform, &v[0], 1);
#else
    glUniform4f((GLint)uniform, v[0], v[1], v[2], v[3]);
#endif
}

void BaseShader::set_image(FrameObject * instance, int src)
{
#ifdef CHOWDREN_USE_D3D
#else
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, (GLuint)instance->get_shader_parameter(src));
    glActiveTexture(GL_TEXTURE0);
#endif
}

int BaseShader::get_uniform(const char * value)
{
#ifdef CHOWDREN_USE_D3D
    return constant_table.get_constant(value);
#else
    return glGetUniformLocation(program, value);
#endif
}

#ifdef CHOWDREN_USE_D3D

#define EQ_REVERSE_SUBTRACT D3DBLENDOP_REVSUBTRACT
#define EQ_ADD D3DBLENDOP_ADD

#define FUNC_DST_COLOR D3DBLEND_DESTCOLOR
#define FUNC_ONE D3DBLEND_ONE
#define FUNC_SRC_ALPHA D3DBLEND_SRCALPHA
#define FUNC_ONE_MINUS_SRC_ALPHA D3DBLEND_INVSRCALPHA
#define FUNC_ZERO D3DBLEND_ZERO
#define FUNC_SRC_COLOR D3DBLEND_SRCCOLOR

#define set_blend_func_eq(a, b, c, d, e, f) \
    render_data.device->SetRenderState(D3DRS_SRCBLEND, a);\
    render_data.device->SetRenderState(D3DRS_DESTBLEND, b);\
    render_data.device->SetRenderState(D3DRS_SRCBLENDALPHA, c);\
    render_data.device->SetRenderState(D3DRS_DESTBLENDALPHA, d);\
    render_data.device->SetRenderState(D3DRS_BLENDOP, e);\
    render_data.device->SetRenderState(D3DRS_BLENDOPALPHA, f)


#define set_blend_func(a, b, c, d) \
    render_data.device->SetRenderState(D3DRS_SRCBLEND, a);\
    render_data.device->SetRenderState(D3DRS_DESTBLEND, b);\
    render_data.device->SetRenderState(D3DRS_SRCBLENDALPHA, c);\
    render_data.device->SetRenderState(D3DRS_DESTBLENDALPHA, d)

#else

#define EQ_REVERSE_SUBTRACT GL_FUNC_REVERSE_SUBTRACT
#define EQ_ADD GL_FUNC_ADD

#define FUNC_DST_COLOR GL_DST_COLOR
#define FUNC_ONE GL_ONE
#define FUNC_SRC_ALPHA GL_SRC_ALPHA
#define FUNC_ONE_MINUS_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
#define FUNC_ZERO GL_ZERO
#define FUNC_SRC_COLOR GL_SRC_COLOR

#define set_blend_func_eq(a, b, c, d, e, f)\
                                      glBlendFuncSeparate(a, b, c, d);\
                                      glBlendEquationSeparate(e, f)
#define set_blend_func(a, b, c, d) glBlendFuncSeparate(a, b, c, d)
#endif

#define commit_parameters(x)

#include "shadercommon.cpp"

#ifdef CHOWDREN_USE_D3D

void set_scale_uniform(float width, float height, float x_scale, float y_scale)
{
    float v[4];
    v[0] = x_scale;
    render_data.device->SetPixelShaderConstantF(pixelscale_shader.x_scale,
                                                &v[0], 1);
    v[0] = y_scale;
    render_data.device->SetPixelShaderConstantF(pixelscale_shader.y_scale,
                                                &v[0], 1);
    v[0] = width;
    render_data.device->SetPixelShaderConstantF(pixelscale_shader.x_size,
                                                &v[0], 1);
    v[0] = height;
    render_data.device->SetPixelShaderConstantF(pixelscale_shader.y_size,
                                                &v[0], 1);
}

#else

void set_scale_uniform(float width, float height, float x_scale, float y_scale)
{
    glUniform1f(pixelscale_shader.x_scale, x_scale);
    glUniform1f(pixelscale_shader.y_scale, y_scale);
    glUniform1f(pixelscale_shader.x_size, width);
    glUniform1f(pixelscale_shader.y_size, height);
}

#endif