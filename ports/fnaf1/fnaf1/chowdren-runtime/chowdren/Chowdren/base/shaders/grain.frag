#version 120

varying vec2 texture_coordinate;
uniform sampler2D texture;
uniform bool iR, iG, iB, iA, iInvert;
uniform float fSeed, fStrength;
#define M_PI 3.1415926535897932384626433832795

float mccool_rand(vec2 ij)
{
  vec4 a = vec4(pow(M_PI, 4.0),exp(4.0),pow(10.0, M_PI*0.5),sqrt(1997.0));
  vec4 result = vec4(ij.x, ij.y, ij.x, ij.y);

  for(int i = 0; i < 3; i++) {
      result.x = fract(dot(result, a));
      result.y = fract(dot(result, a));
      result.z = fract(dot(result, a));
      result.w = fract(dot(result, a));
  }
  return result.x;
}

void main()
{
    vec4 col = texture2D(texture, texture_coordinate);
    float r = mccool_rand(texture_coordinate+vec2(fSeed))*fStrength;
    r = iInvert ? 1.0-r : r;
    if (iR) col.r *= r;
    if (iG) col.g *= r;
    if (iB) col.b *= r;
    if (iA) col.a *= r;
    gl_FragColor = col * gl_Color;
}