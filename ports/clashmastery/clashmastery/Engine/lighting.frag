#define MAX_NUM_LIGHTS 32

struct Light {
    vec2 position;
    float intensity;
    bool isActive;
    float radius;
};

// Can't rely on == because of floating point precision
bool colorsAreEqual(vec3 color1, vec3 color2) {
    return all(lessThan(abs(color1 - color2), vec3(0.015)));
}

uniform vec4 ignore_color;
uniform vec4 ignore_color2;
uniform vec4 secondary_color; // this is our 'dark' color, and it should also be ignored from lighting calculations
uniform float base_lighting;
uniform Light lights[MAX_NUM_LIGHTS];
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(tex, texture_coords);
    float current_lighting = base_lighting;
    vec2 norm_coords = screen_coords;
    // wow BIG gotcha here: The color is always 1,1,1,1 because love.graphics.setcolor is 1,1,1,1 right now.
    // the pixel * color is the true color which is our texture (our canvas) times the color being drawn (1,1,1,1)
    vec4 true_color = pixel * color;
    if (colorsAreEqual(true_color.rgb, ignore_color.rgb) || colorsAreEqual(true_color.rgb, ignore_color2.rgb) || colorsAreEqual(true_color.rgb, secondary_color.rgb)) {
        // ignored color ignores lighting
        // for example, red indicators that always need to be seen
        current_lighting = 1.0;
    } else {
        for (int i = 0; i < MAX_NUM_LIGHTS; i++) {
            Light currentLight = lights[i];
            if (currentLight.isActive) {
                float distance = length(currentLight.position - norm_coords);
                if (distance < currentLight.radius) {
                    // so right now we just hardcode the light to be the current lights intensity unless its less than the base lighting
                    // not a terrible strat but not perfect. ideally we'd sum up the intensities of nearby lights to produce a composite light value
                    current_lighting = base_lighting < currentLight.intensity ? currentLight.intensity : base_lighting;
                }
            }
        }
    }
    // Wisdom: We can't just do color * current_lighting, cause that also multiplies the alpha value.
    // We want our alpha value uncorrupted. We only want the rgb to be multiplied by our lighting
    // color = color * vec4(current_lighting, current_lighting, current_lighting, 1.0); // This would work if we didn't support non-black darkness colors

    // However, since our darkness might not be black due to multiple color palettes, we
    // can't simply multiply our color by our lighting, because our "darkness" color might
    // not be black (even though it is obviously black in real life). Therefore, 
    // our darkness color is simply our 'secondary_color', so we must interpolate between our primary and
    // secondary color based on the lighting value to get the color of a pixel.
    // color = mix(secondary_color, color, current_lighting);
    // return pixel * color;
    // AND YET, THIS IS STILL WRONG!
    // This is only the "color" value, not the actual color of the pixel, which is pixel*color!
    // So we shouldn't be operating on 'color', we should be operating on 'true_color'!

    // And so, this is our true solution. Take the color of darkness, and blend it with the true color of the pixel based on the lighting intensity
    // and there is your color of the pixel!!
    true_color = mix(secondary_color, true_color, current_lighting);
    return true_color;
}