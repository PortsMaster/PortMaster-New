#ifdef USE_EFFECTS

#define EFFECT_FADE 0
#define EFFECT_GHOST 1
#define EFFECT_SPLASH 2
#define EFFECT_CHROME 3
#define EFFECT_UV 4

#define MESHFX_WATERBOX 0
#define MESHFX_SHOCKWAVE 1
#define MESHFX_BOMB 2

#ifdef MESH_EFFECTS
// effect tables
BeginBlock(EffectTables)
_uniform float wboxSineTable[9];
EndBlock

// mesh effects
BeginBlock(MeshEffects)
_uniform int numMeshFx;
_uniform vec4 meshFxParams1[MAX_MESHFX];
_uniform vec4 meshFxParams2[MAX_MESHFX];
EndBlock
#endif  // MESH_EFFECTS

#ifdef MESH_EFFECTS
void ProcessWaterboxEffect(inout vec4 pos, int i)
{
  vec3 bboxMin = meshFxParams1[i].xyz;
  vec3 bboxMax = meshFxParams2[i].xyz;

  if (all(greaterThan(inPosition.xyz, bboxMin)) && 
      all(lessThan(inPosition.xyz, bboxMax))) {
    int hash = int(abs(inPosition.x * inPosition.z));
    vec3 delta = vec3(
        wboxSineTable[Mod(hash+0, 9)], 
        wboxSineTable[Mod(hash+3, 9)] + 6.0, 
        wboxSineTable[Mod(hash+6, 9)]);
    #ifdef MODEL
    delta *= 0.2;
    #endif  // MODEL
    pos.xyz += delta;
  }
}

void ProcessShockwaveEffect(inout vec4 pos, int i)
{
  vec3 objPos = meshFxParams1[i].xyz;
  float reach = meshFxParams1[i].w;

  vec3 delta = pos.xyz - objPos;
  float dist = dot(delta, delta);
  if (dist < reach * reach) {
    dist = sqrt(dist);
    float pull = (reach - dist) * 0.1;
    pull = min(pull, dist * 0.5);
    pos.xyz -= delta * (pull / dist);
  }
}

void ProcessBombEffect(inout vec4 pos, int i)
{
  vec3 objPos = meshFxParams1[i].xyz;
  float reach = meshFxParams1[i].w;
  float timeStep = meshFxParams2[i].x;

  vec3 delta = pos.xyz - objPos;
  float dist = dot(delta, delta);
  dist = sqrt(dist);
  float scale = (0.5 - timeStep) / 0.5;
  float push = (64.0 - abs(reach - dist)) * scale;
  pos.xyz += delta * (max(push, 0.0) / dist);
}

void ProcessMeshEffect(inout vec4 pos, int i)
{
  int type = int(meshFxParams2[i].w);

  if (type == MESHFX_WATERBOX) {
    ProcessWaterboxEffect(pos, i);
  } else if (type == MESHFX_SHOCKWAVE) {
    ProcessShockwaveEffect(pos, i);
  } else if (type == MESHFX_BOMB) {
    ProcessBombEffect(pos, i);
  }
}
#endif  // MESH_EFFECTS

#ifdef MODEL_EFFECT
#if (MODEL_EFFECT == EFFECT_FADE)
void ProcessFadeEffect(inout vec4 pos)
{
  float timeStep = effectParams.x;
  varColor.a = 1.0 - timeStep;
}

#elif (MODEL_EFFECT == EFFECT_GHOST)
void ProcessGhostEffect(inout vec4 pos)
{
  float ghostPos = effectParams.x;
  float ghostMul = effectParams.y;
  varColor.a = abs((pos.z + ghostPos) * ghostMul);
  varColor.a = 1.0 - varColor.a;
}

#elif (MODEL_EFFECT == EFFECT_SPLASH)
void ProcessSplashEffect(inout vec4 pos)
{
  float timeStep = effectParams.x;
  float frame = inPosition.w * timeStep;
  if (frame < 16.0) {
    float grav = 384.0 * timeStep;
    vec3 vel = inNormal;
    vel.y += grav;
    pos.xyz += vel * timeStep;
    pos.w = 1.0;

    float rgb = (16.0 - frame) / 32.0;
    varColor.rgb = vec3(rgb);
    varTexCoord.s += floor(frame) / 16.0;
  }
}

#elif (MODEL_EFFECT == EFFECT_CHROME)
void ProcessChromeEffect(inout vec4 pos)
{
  varTexCoord.s = dot(inNormal, envMatX) + 0.5;
  varTexCoord.t = dot(inNormal, envMatY) + 0.6;
}

#elif (MODEL_EFFECT == EFFECT_UV)
void ProcessUVEffect(inout vec4 pos)
{
  float timeStep = effectParams.x;
  float time = inTexCoord.s;
  float add = inTexCoord.t;
  time += add * timeStep;

  vec3 texCoord = effectParams.yzw;
  varTexCoord.s = sin(time) * texCoord.s + texCoord.t;
  varTexCoord.t = cos(time) * texCoord.s + texCoord.p;
}
#endif

void ProcessModelEffect(inout vec4 pos)
{
  #if (MODEL_EFFECT == EFFECT_FADE)
  ProcessFadeEffect(pos);
  #elif (MODEL_EFFECT == EFFECT_GHOST)
  ProcessGhostEffect(pos);
  #elif (MODEL_EFFECT == EFFECT_SPLASH)
  ProcessSplashEffect(pos);
  #elif (MODEL_EFFECT == EFFECT_CHROME)
  ProcessChromeEffect(pos);
  #elif (MODEL_EFFECT == EFFECT_UV)
  ProcessUVEffect(pos);
  #endif
}
#endif  // MODEL_EFFECT

void ProcessEffects(inout vec4 pos)
{
  #ifdef MESH_EFFECTS
  for (int i = 0; i < MAX_MESHFX; ++i) {
    if (i < numMeshFx) {
      ProcessMeshEffect(pos, i);
    } else {
      break;
    }
  }
  #endif  // MESH_EFFECTS

  #ifdef MODEL_EFFECT
  ProcessModelEffect(pos);
  #endif  // MODEL_EFFECT
}
#endif  // USE_EFFECTS
