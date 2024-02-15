in _mediump vec4 varColor;
in _mediump vec2 varTexCoord;
#ifdef USE_ENV
in _mediump vec2 varEnvCoord;
#endif  // USE_ENV
#ifdef USE_FOG
in _mediump vec2 varFogCoord;
#endif  // USE_FOG

// textures
uniform sampler2D diffuseTexture;
#ifdef USE_ENV
uniform sampler2D envTexture;
#endif  // USE_ENV

// constants
BeginBlock(Constants)
_uniform _mediump vec3 shadowColor;
_uniform _mediump vec3 fogColor;
_uniform _mediump vec2 fogParams;
EndBlock

// params
BeginBlock(Params)
_uniform _mediump vec3 envColor;
EndBlock

void main(void)
{
  vec4 diffuse = texture(diffuseTexture, varTexCoord);
  #ifdef ALPHA_TEST
  if (diffuse.a < 0.5) {
    discard;
  }
  #endif  // ALPHA_TEST
  outColor = varColor * diffuse;

  #ifdef USE_ENV
  vec3 specular = texture(envTexture, varEnvCoord).rgb;
  outColor.rgb += envColor * specular;
  #endif  // USE_ENV

  #ifdef USE_FOG
  vec2 fog = clamp(varFogCoord, 0.0, 1.0);
  outColor.rgb = mix(fogColor, outColor.rgb, fog.x - fog.y);
  #endif  // USE_FOG
}
