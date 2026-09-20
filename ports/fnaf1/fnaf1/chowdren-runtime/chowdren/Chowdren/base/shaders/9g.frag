#version 120

varying vec2 texture_coordinate;
uniform sampler2D texture;
uniform vec2 texture_size;

uniform float xScale;
uniform float yScale;
uniform vec4 fArgb;
uniform float fAa;
uniform vec4 fBrgb;
uniform float fBa;
uniform float fOffset;
// uniform float coeff;
// uniform float fade;

void main()
{
    vec4 color;
    float orig_width = (1.0/texture_size[0]) / xScale;
    float orig_height = (1.0/texture_size[1]) / yScale;
    float chunk_width = orig_width / 3.0;
    float chunk_height = orig_height / 3.0;
    float width = (1.0/texture_size[0]);
    float height = (1.0/texture_size[1]);

    vec2 pos;
    pos.x = texture_coordinate.x * width;
    pos.y = texture_coordinate.y * height;

    vec2 orig_pos;
    orig_pos.x = texture_coordinate.x * xScale;
    orig_pos.y = texture_coordinate.y * yScale;

    float dx = (orig_width - chunk_width + pos.x - (width-chunk_width));
    float dy = (orig_height - chunk_height + pos.y - (height-chunk_height));
    vec2 slice_pos = vec2((texture_coordinate.x+1.0)/3.0, (texture_coordinate.y+1.0)/3.0);

    // top
    if (pos.y < chunk_height) {
        slice_pos.y = orig_pos.y;
    }

    // bottom
    if (pos.y > height-chunk_height) {
        slice_pos.y = dy/height * yScale;
    }

    // left
    if (pos.x< chunk_width) {
        slice_pos.x = orig_pos.x;
    }

    // right
    if (pos.x> width-chunk_width) {
        slice_pos.x = dx/width * xScale;
    }

    color = texture2D(texture, slice_pos);

    // Output pixel
    vec4 gradient = vec4(0.0);
    float f = (texture_coordinate.x*(1.0-texture_coordinate.y));
    f = max(0.0, min(1.0, f+fOffset));
    gradient.a = fAa + (fBa - fAa) * f;
    gradient.rgb = mix(fArgb, fBrgb, f).rgb;
    color.a *= gradient.a * gl_Color.a;
    color.rgb = gradient.rgb;
    gl_FragColor = color;
}
