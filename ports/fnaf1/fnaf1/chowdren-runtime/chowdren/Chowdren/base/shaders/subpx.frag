#version 120

varying vec2 texture_coordinate;
uniform sampler2D texture;
uniform vec2 texture_size;
uniform float x, y;
uniform bool limit;

void main()
{
    vec2 pos = vec2(x, y);
    if (limit)
        pos -= floor(pos * 1.05);
    pos = texture_coordinate - pos*texture_size;
    // need this for Surface (may break other things?)
    vec4 color = vec4(0.0);
    color = texture2D(texture, pos);
    // if (pos.x >= 0 && pos.x <=1 && pos.y >= 0 && pos.y <= 1)
    //     color = texture2D(texture, pos);
    gl_FragColor = color * gl_Color;
}
