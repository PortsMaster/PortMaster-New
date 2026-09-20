#version 120

varying vec2 texture_coordinate;
uniform sampler2D texture;

void main()
{
    gl_FragColor = texture2D(texture, texture_coordinate);
    // this is default MMF2 behaviour, but we only use it for the subtract
    // effect
    if (gl_FragColor.a <= 0.0)
        discard;
    gl_FragColor *= gl_Color;
    // premultiply the alpha so we can use the original MMF blend function
    gl_FragColor.rgb *= gl_Color.a;
}
