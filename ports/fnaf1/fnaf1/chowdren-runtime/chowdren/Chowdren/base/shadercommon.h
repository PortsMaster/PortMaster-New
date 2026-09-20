#ifndef CHOWDREN_SHADERCOMMON_H
#define CHOWDREN_SHADERCOMMON_H

#include <string>

// GLES attrib indexes
#define MAX_ATTRIB 4
#define POSITION_ATTRIB_IDX 0
#define POSITION_ATTRIB_NAME "in_pos"
#define COLOR_ATTRIB_IDX 1
#define COLOR_ATTRIB_NAME "in_blend_color"
#define TEXCOORD1_ATTRIB_IDX 2
#define TEXCOORD1_ATTRIB_NAME "in_tex_coord1"
#define TEXCOORD2_ATTRIB_IDX 3
#define TEXCOORD2_ATTRIB_NAME "in_tex_coord2"
#define TEXTURE_SAMPLER_NAME "texture"
#define BACKTEX_SAMPLER_NAME "background_texture"
#define SIZE_UNIFORM_NAME "texture_size"

// shader flags
enum ShaderFlags
{
    SHADER_HAS_BACK = (1 << 0),
    SHADER_HAS_TEX_SIZE = (1 << 1)
};

class FrameObject;

void convert_vec4(int value, float & a, float & b, float & c, float & d);

void shader_set_effect(int effect, FrameObject * obj, int width, int height);
void shader_set_texture();

#endif // CHOWDREN_SHADERCOMMON_H
