!!permu FRAMEBLEND
!!permu SKELETAL
!!permu FOG

varying vec3 norm;

#ifdef VERTEX_SHADER
#include "sys/skeletal.h"
uniform float e_time;

void main ()
{
	gl_Position = skeletaltransform_n(norm);
}
#endif


#ifdef FRAGMENT_SHADER
#include "sys/fog.h"

void main ()
{
	gl_FragColor = vec4(0,0,0,0);
}
#endif