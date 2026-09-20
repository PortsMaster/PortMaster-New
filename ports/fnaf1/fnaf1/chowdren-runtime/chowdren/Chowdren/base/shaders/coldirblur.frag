#version 120

varying vec2 texture_coordinate0;
varying vec2 texture_coordinate1;
uniform sampler2D texture;
uniform sampler2D background_texture;
uniform float rr, rg, rb, gr, gg, gb, br, bg, bb, fAngle, fCoeff;

void main()
{
    // Directional vector of blur kernel
    vec2 v = vec2(cos(fAngle*0.01745), sin(fAngle*0.01745)) * fCoeff;
    vec2 v2 = vec2(cos((fAngle+90.0)*0.01745), sin((fAngle+90.0)*0.01745)) * fCoeff;

    // Input foreground (for colorizer)
    vec2 In = texture_coordinate0;
    vec4 a = texture2D(texture, In);

    //Sample blur
    a += texture2D(texture, In + 0.33*v);
    a += texture2D(texture, In - 0.33*v);
    a += texture2D(texture, In + 0.66*v);
    a += texture2D(texture, In - 0.66*v);
    a += texture2D(texture, In +      v);
    a += texture2D(texture, In -      v);
    a += texture2D(texture, In + 0.33*v2);
    a += texture2D(texture, In - 0.33*v2);
    a += texture2D(texture, In + 0.66*v2);
    a += texture2D(texture, In - 0.66*v2);
    a += texture2D(texture, In +      v2);
    a += texture2D(texture, In -      v2);
    a /= 13.0; // number of "a += " lines above plus one!
    a *= gl_Color;

    // Input background
    vec4 i = texture2D(background_texture, texture_coordinate1);

    // Apply colorizer math
    vec4 o = vec4(1.0);
    o.rgb = vec3(rr, rg, rb)*i.r + vec3(gr, gg, gb)*i.g + vec3(br, bg, bb)*i.b;
    o.rgb = i.rgb + (o.rgb - i.rgb) * a.rgb;
    gl_FragColor = o;
}