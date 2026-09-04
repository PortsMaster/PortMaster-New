VERTEX:
#version 330

uniform mat4 u_matrix;

layout(location=0) in vec3 a_position;
layout(location=1) in vec2 a_tex;
layout(location=2) in vec4 a_color;

out vec2 v_tex;
out vec4 v_color;

void main(void)
{
	gl_Position = u_matrix * vec4(a_position, 1.0);
	v_tex = a_tex;
	v_color = a_color;
}

FRAGMENT:
#version 330
#include Partials/Methods.gl

uniform sampler2D u_texture;
uniform float u_near;
uniform float u_far;
uniform float u_fade_start;

in vec2 v_tex;
in vec4 v_color;

out vec4 o_color;

void main(void)
{
	// apply color value
	// must match the depth the model shaders write
	float depth = LinearizeDepth(gl_FragCoord.z, u_near, u_far);
	gl_FragDepth = depth;

	// fade out with distance the same way models do, so sprites don't stay solid
	// right up to the far plane. Left at 0 (the skybox) this is a no-op.
	float fade = u_fade_start > 0.0 ? Map(depth, u_fade_start, 1.0, 1.0, 0.0) : 1.0;

	o_color = texture(u_texture, v_tex) * v_color * fade;
}