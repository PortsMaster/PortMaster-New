VERTEX:
#version 330
#include Partials/Methods.gl

uniform mat4 u_mvp;
uniform mat4 u_model;

layout(location=0) in vec3 a_position;
layout(location=1) in vec2 a_tex;
layout(location=2) in vec3 a_color;
layout(location=3) in vec3 a_normal;
layout(location=4) in vec4 a_joint;
layout(location=5) in vec4 a_weight;

layout(location=6) in mat4 a_instance;

out vec2 v_tex;
out vec3 v_color;
out vec3 v_normal;
out vec3 v_world;

void main(void)
{
	// instanced draws are always static geometry, so there is no skinning here
	mat4 model = u_model * a_instance;
	vec4 pos = vec4(a_position, 1.0);

	gl_Position = u_mvp * a_instance * pos;

	v_tex = a_tex;
    v_color = a_color;
	v_normal = TransformNormal(a_normal, model);
	v_world = vec3(model * pos);
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
uniform float     u_fade_start;

in vec2 v_tex;
in vec3 v_normal;
in vec3 v_color;
in vec3 v_world;

layout(location = 0) out vec4 o_color;

void main(void)
{
	// get texture color
	vec4 src = texture(u_texture, v_tex) * u_color;

	// only enable if you want ModelFlags.Cutout types to work, didn't end up using
	//if (src.a < u_cutout)
	//	discard;

	float depth = LinearizeDepth(gl_FragCoord.z, u_near, u_far);
	float fall = Map(v_world.z, 50.0, 0.0, 0.0, 1.0);
	// u_fade_start of 0 means the caller didn't ask for a distance fade
	float fade = u_fade_start > 0.0 ? Map(depth, u_fade_start, 1.0, 1.0, 0.0) : 1.0;
	vec3  col = src.rgb;

	// Linear depth is written out so the Edge pass has usable precision across the
	// whole view distance. It costs early-Z, but sampling hardware depth instead
	// makes that pass paint false edges along triangle diagonals at range.
	gl_FragDepth = depth;

	// lighten texture color based on normal
	float lighten = max(0.0, -dot(v_normal, u_sun));
	col = mix(col, vec3(1.0, 1.0, 1.0), lighten * 0.10 * u_effects);

	// shadow
	float darken = max(0.0, dot(v_normal, u_sun));
	col = mix(col, vec3(4.0/255.0, 27.0/255.0, 44.0/255.0), darken * 0.80 * u_effects);

	// passthrough mode
	col = mix(col, u_silhouette_color.rgb, u_silhouette);

	// fade bottom to white
	col = mix(col, u_vertical_fog_color.rgb * src.a, fall);

	o_color = vec4(col, src.a) * fade;
}
