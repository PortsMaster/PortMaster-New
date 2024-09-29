uniform sampler2D u_texture;
uniform sampler2D u_normals;
uniform int u_time;
uniform vec4 u_watercolor;
in vec2 v_texcoord;
in vec4 v_color;
out vec4 o_color;

void main(void) {
	vec2 uv = v_texcoord.xy;
	float offset = u_time / 1000.0 * 0.009;
	uv.x += offset;
	vec4 offsetN = texture2D(u_normals, uv);
	uv = v_texcoord.xy + offsetN.rg * 0.005;
	vec4 color = texture2D(u_texture, uv);
	o_color = vec4(mix(u_watercolor.rgb, color.rgb, u_watercolor.a), 1.0) * v_color;
}
