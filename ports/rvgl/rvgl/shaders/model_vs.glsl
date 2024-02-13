#define MODEL

in vec4 inPosition;
in vec4 inColor;
in vec2 inTexCoord;
in float inFogCoord;
in vec3 inNormal;

out _mediump vec4 varColor;
out _mediump vec2 varTexCoord;
#ifdef USE_ENV
out _mediump vec2 varEnvCoord;
#endif  // USE_ENV
#ifdef USE_FOG
out _mediump vec2 varFogCoord;
#endif  // USE_FOG

// constants
BeginBlock(Constants)
_uniform _mediump vec3 shadowColor;
_uniform _mediump vec3 fogColor;
_uniform _mediump vec2 fogParams;
EndBlock

// params
BeginBlock(Params)
_uniform _mediump vec4 modelUpVec;
_uniform _mediump vec4 effectParams;
_uniform _mediump vec3 mirrorParams;
_uniform _mediump float alphaRef;
_uniform _mediump vec3 tint;
_uniform _mediump vec3 envColor;
_uniform _mediump vec3 envMatX;
_uniform _mediump vec3 envMatY;
EndBlock

// projection matrix
BeginBlock(Projection)
_uniform mat4 matViewProj;
_uniform vec3 cameraPos;
_uniform vec3 cameraUpVec;
EndBlock

#ifdef USE_LIGHTS
void ProcessLights(void);
#endif  // USE_LIGHTS
#ifdef USE_EFFECTS
void ProcessEffects(inout vec4 pos);
#endif  // USE_EFFECTS

void main(void)
{
  vec4 pos = inPosition;

  varColor = inColor;
  varTexCoord = inTexCoord;

  #ifdef USE_EFFECTS
  // process effects
  ProcessEffects(pos);
  #endif  // USE_EFFECTS

  // calc position
  gl_Position = pos * matViewProj;

  #ifdef USE_ENV
  // calc env tex coords
  #ifdef GOOD_ENV
  vec3 vecz = normalize(pos.xyz - cameraPos);
  vec3 vecx = cross(cameraUpVec, vecz);
  vec3 vecy = cross(vecz, vecx);
  varEnvCoord.s = dot(inNormal, vecx) * 0.5 + 0.5;
  varEnvCoord.t = dot(inNormal, vecy) * 0.5 + 0.5;
  #else
  varEnvCoord.s = dot(inNormal, envMatX) + 0.5;
  varEnvCoord.t = dot(inNormal, envMatY) + 0.5;
  #endif  // GOOD_ENV
  #endif  // USE_ENV

  #ifdef USE_FOG
  // is it in fog?
  float fogEnd = fogParams.x;
  float fogMul = fogParams.y;
  #ifdef MIRROR_FOG
  float mirrorHeight = mirrorParams.x;
  float mirrorMul = mirrorParams.y;
  float mirrorAdd = mirrorParams.z;
  float vertFog = dot(pos, modelUpVec);
  vertFog = mirrorHeight - vertFog;
  vertFog *= mirrorMul;
  vertFog += mirrorAdd;
  #else
  float vertFog = inFogCoord;
  #endif  // MIRROR_FOG
  varFogCoord.x = (fogEnd - gl_Position.w) * fogMul;
  varFogCoord.y = vertFog;
  #endif  // USE_FOG

  #ifdef USE_LIGHTS
  // process lights
  ProcessLights();
  #endif  // USE_LIGHTS

  #ifdef USE_EFFECTS
  // add any tinting
  varColor.rgb += tint;
  #endif  // USE_EFFECTS

  // clamp the color
  varColor = clamp(varColor, 0.0, 1.0);
}
