in _mediump vec4 varColor;
in _mediump vec2 varTexCoord;

// textures
uniform sampler2D diffuseTexture;

void main(void)
{
  vec4 diffuse = texture(diffuseTexture, varTexCoord);
  #ifdef ALPHA_TEST
  if (diffuse.a < 0.5) {
    discard;
  }
  #endif  // ALPHA_TEST
  outColor = varColor * diffuse;
}
