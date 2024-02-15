#ifdef USE_LIGHTS

#define LIGHT_OMNI 0
#define LIGHT_OMNINORMAL 1
#define LIGHT_SPOT 2
#define LIGHT_SPOTNORMAL 3
#define LIGHT_SHADOW 4

// lights
BeginBlock(Lights)
_uniform int numLights;
_uniform vec4 lightPos[MAX_LIGHTS];
_uniform vec4 lightParams[MAX_LIGHTS];
_uniform vec4 lightDir[MAX_LIGHTS];
EndBlock

#ifdef SHADOW_BOX
// shadow box
BeginBlock(ShadowBox)
_uniform int numShadows;
_uniform vec4 shadowPos[MAX_SHADOWS];
_uniform vec4 shadowParams[MAX_SHADOWS];
_uniform mat3 shadowDir[MAX_SHADOWS];
EndBlock
#endif  // SHADOW_BOX

void ProcessLight(int i)
{
  vec3 delta = lightPos[i].xyz - inPosition.xyz;
  float reach = lightPos[i].w;
  float dist = dot(delta, delta);
  if (dist < reach) {
    vec3 color = lightParams[i].xyz;
    int type = int(lightParams[i].w);
    float scale = 1.0 - (dist / reach);
    dist = sqrt(dist);

    // calc angle from normal if needed
    if (type == LIGHT_OMNINORMAL || type == LIGHT_SPOTNORMAL) {
      float ang = dot(delta, inNormal);
      ang = clamp(ang / dist, 0.0, 1.0);
      scale *= ang;
    }

    // calc cone adjustment if needed
    if (type == LIGHT_SPOT || type == LIGHT_SPOTNORMAL) {
      float cone = -dot(lightDir[i].xyz, delta) / dist - 1.0;
      float conemul = lightDir[i].w;
      cone = cone * conemul + 1.0;
      cone = clamp(cone, 0.0, 1.0);
      scale *= cone;
    }

    varColor.rgb += mix(vec3(0.0), color, scale);
  }
}

#ifdef SHADOW_BOX
int ProcessShadow(int i)
{
  vec3 delta = shadowPos[i].xyz - inPosition.xyz;
  vec3 dist = delta * shadowDir[i];
  vec3 size = shadowParams[i].xyz;
  return int(
      all(greaterThan(dist, -size)) && 
      all(lessThan(dist, size)));
}
#endif  // SHADOW_BOX

void ProcessLights(void)
{
  for (int i = 0; i < MAX_LIGHTS; ++i) {
    if (i < numLights) {
      ProcessLight(i);
    } else {
      break;
    }
  }

  #ifdef SHADOW_BOX
  int shadowFlag = 0;
  for (int i = 0; i < MAX_SHADOWS; ++i) {
    if (i < numShadows) {
      shadowFlag += ProcessShadow(i);
    } else {
      break;
    }
  }
  if (shadowFlag > 0) {
    varColor.rgb += shadowColor;
  }
  #endif  // SHADOW_BOX
}
#endif  // USE_LIGHTS
