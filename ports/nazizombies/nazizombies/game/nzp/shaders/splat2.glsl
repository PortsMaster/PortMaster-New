!!permu FRAMEBLEND
!!permu SKELETAL
!!permu FOG

varying vec2 tc;
varying float va;

#ifdef VERTEX_SHADER
#include "sys/skeletal.h"
attribute vec2 v_texcoord;
attribute vec4 v_colour;
uniform vec3 e_eyepos;

void main ()
{
	vec3 n;
	gl_Position = skeletaltransform_n(n);
	tc = v_texcoord;
	va = v_colour.a;
}
#endif


#ifdef FRAGMENT_SHADER
#include "sys/fog.h"
uniform sampler2D s_t0;

void main ()
{
	vec4 col;
	col = texture2D(s_t0, tc);
	col.a -= 1.0 - va;
	if(col.a > 0.1)
		col.a = 1.0;
	else
		col.a = 0.0;
	gl_FragColor = fog4(col);
}
#endif