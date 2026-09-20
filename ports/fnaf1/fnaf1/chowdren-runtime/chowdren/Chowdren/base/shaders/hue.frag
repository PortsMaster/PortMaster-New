#version 120

varying vec2 texture_coordinate;
uniform sampler2D texture;
uniform float fHue;

void main()
{
    vec4 col = texture2D(texture, texture_coordinate);
    gl_FragColor.a = col.a;
    if(fHue < 1.0)
    {
        gl_FragColor.r = col.r+(col.g-col.r)*fHue;
        gl_FragColor.g = col.g+(col.b-col.g)*fHue;
        gl_FragColor.b = col.b+(col.r-col.b)*fHue;
    }
    else if(fHue >= 1.0 && fHue < 2.0)
    {
        gl_FragColor.r = col.g+(col.b-col.g)*(fHue-1.0);
        gl_FragColor.g = col.b+(col.r-col.b)*(fHue-1.0);
        gl_FragColor.b = col.r+(col.g-col.r)*(fHue-1.0);
    }
    else if(fHue >= 2.0)
    {
        gl_FragColor.r = col.b+(col.r-col.b)*(fHue-2.0);
        gl_FragColor.g = col.r+(col.g-col.r)*(fHue-2.0);
        gl_FragColor.b = col.g+(col.b-col.g)*(fHue-2.0);
    }
    gl_FragColor *= gl_Color;
}