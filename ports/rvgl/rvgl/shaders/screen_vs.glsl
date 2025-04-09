#define SCREEN

in vec4 inPosition;
in vec4 inColor;
in vec2 inTexCoord;

out _mediump vec4 varColor;
out _mediump vec2 varTexCoord;

void main(void)
{
  vec4 pos = inPosition;

  varColor = inColor;
  varTexCoord = inTexCoord;

  // set position
  gl_Position = inPosition;
}
