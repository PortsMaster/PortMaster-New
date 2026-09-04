VERTEX:
#version 330

uniform mat4 u_mvp;

layout(location=0) in vec3 a_position;
layout(location=1) in vec2 a_tex;
layout(location=2) in vec3 a_color;
layout(location=3) in vec3 a_normal;

layout(location=6) in mat4 a_instance;
layout(location=10) in mat4 a_normalMat;

out vec2 v_tex;
out vec3 v_color;
out vec3 v_normal;
out vec3 v_world;

void main(void)
{
	vec4 world = a_instance * vec4(a_position, 1.0);
	gl_Position = u_mvp * world;

	v_tex = a_tex;
	v_color = a_color;
	v_normal = normalize(mat3(a_normalMat) * a_normal);
	v_world = world.xyz;
}

FRAGMENT:
#version 330
#include Partials/Methods.gl

uniform sampler2D u_texture;
uniform vec4      u_color;
uniform float     u_near;
uniform float     u_far;
uniform vec3      u_sun;
uniform float     u_effects;
uniform float     u_silhouette;
uniform vec4      u_silhouette_color;
uniform float     u_time;
uniform vec4      u_vertical_fog_color;
uniform float     u_cutout;

in vec2 v_tex;
in vec3 v_normal;
in vec3 v_color;
in vec3 v_world;

layout(location = 0) out vec4 o_color;

void main(void)
{
	// get texture color
	vec4 src = texture(u_texture, v_tex) * u_color;

	float depth = LinearizeDepth(gl_FragCoord.z, u_near, u_far);
	float fall = Map(v_world.z, 50.0, 0.0, 0.0, 1.0);
	float fade = Map(depth, 0.9, 1.0, 1.0, 0.0);
	vec3  col = src.rgb;

	// apply depth values
	gl_FragDepth = depth;

	// lighten texture color based on normal
	float lighten = max(0.0, -dot(v_normal, u_sun));
	col = mix(col, vec3(1,1,1), lighten * 0.10 * u_effects);

	// shadow
	float darken = max(0.0, dot(v_normal, u_sun));
	col = mix(col, vec3(4.0/255.0, 27.0/255.0, 44.0/255.0), darken * 0.80 * u_effects);

	// passthrough mode
	col = mix(col, u_silhouette_color.rgb, u_silhouette);

	// fade bottom to white
	col = mix(col, u_vertical_fog_color.rgb * src.a, fall);

	o_color = vec4(col, src.a) * fade;
}
