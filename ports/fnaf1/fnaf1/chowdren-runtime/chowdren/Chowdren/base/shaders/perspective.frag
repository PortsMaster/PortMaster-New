#version 120
#define HORIZONTAL false
#define VERTICAL true
#define PANORAMA 0
#define PERSPECTIVE 1
#define SINEWAVE 2
#define SINEOFFSET 3
#define CUSTOM 4
#define CUSTOMOFFSET 5
#define LEFTRIGHTTOPBOTTOM false
#define RIGHTLEFTBOTTOMTOP true
#define delta (3.141592/180.0)

varying vec2 texture_coordinate;
uniform sampler2D texture;
uniform vec2 texture_size;
uniform int effect;
uniform bool direction, perspective_dir;
uniform int zoom, offset;
uniform int sine_waves;

void main()
{
    // For some weird reason, the wave number calculation always uses the
    // image height, no matter what the orientation is
    float wave_increment = (float(sine_waves) * 360.0) / (texture_size.x /
                                                          texture_size.y);

    vec2 In = texture_coordinate;

    // What to use as input
    float pixel = (direction == VERTICAL) ? texture_size.y : texture_size.x;
    float i = ((direction == VERTICAL) ? In.x : In.y);

    // Effect (hardcore optimization: this if is always true for now)
    //if (effect == SINEOFFSET)
    float v = sin((i * wave_increment + float(offset)) * delta) * float(zoom);

    // What to use as output
    if (direction == VERTICAL)
        In.y += v*pixel;
    else
        In.x += v*pixel;

    vec4 col;
    if (In.x < 0.0 || In.x > 1.0 || In.y < 0.0|| In.y > 1.0)
        // This is what the extension does, I guess it's not visible in the
        // game anyway?
        col = vec4(0, 0, 0, 0);
    else
       col = texture2D(texture, In);

    gl_FragColor = col;
}
