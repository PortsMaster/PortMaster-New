#version 120

varying vec2 texture_coordinate;
uniform sampler2D texture;

void main()
{
    gl_FragColor = texture2D(texture, texture_coordinate);
    gl_FragColor.rgb = vec3(1.0);
    gl_FragColor *= gl_Color;
}
