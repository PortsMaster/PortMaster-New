if (!global.canDoShaders)
    exit;

var window_is_fullscreen = window_get_fullscreen();
var global_scale = global.scale;
var global_scanlines = global.scanlines;
var buffer_surfaces = global.bufferSurface;
display_set_gui_size(window_get_height() * 1.7777777777777777, window_get_height());

if (window_is_fullscreen)
    display_set_gui_maximize(1, 1, 0, 0);

var window_width = window_get_width();
window_width ??= 384;
var window_height = window_get_height();
window_height ??= 216;
var surface_width = surface_get_width(buffer_surfaces[0]);
var surface_height = surface_get_height(buffer_surfaces[0]);
var _scale = clamp(global_scale, 1, 8);
var _window_width_limit = (global_scale == 1) ? 384 : clamp(window_width, 384, 384 * _scale);
var _window_height_limit = (global_scale == 1) ? 216 : clamp(window_height, 216, 216 * _scale);

for (var i = 0; i < 2; i++)
{
    if (surface_exists(buffer_surfaces[i]))
    {
        if (surface_width != _window_width_limit || surface_height != _window_height_limit)
            surface_resize(buffer_surfaces[i], _window_width_limit, _window_height_limit);
    }
    else
    {
        buffer_surfaces[i] = surface_create(_window_width_limit, _window_height_limit, 6);
    }
}

if (do_screen && surface_exists(buffer_surfaces[0]) && surface_exists(buffer_surfaces[1]))
{
    gpu_set_tex_filter(false);
    draw_clear(c_black);
    var _plainScaleX = global_scanlines ? 1 : (surface_get_width(buffer_surfaces[0]) / 384);
    var _plainScaleY = global_scanlines ? 1 : (surface_get_height(buffer_surfaces[0]) / 216);
    surface_set_target(buffer_surfaces[0]);
    draw_clear_alpha(c_black, 0);

    if (pal_bright <= 1)
    {
        shader_set(shd_pal);
        shader_set_uniform_f(u_bri, pal_bright);
    }
    else
    {
        shader_set(shd_pal_brighten);
        shader_set_uniform_f(u_brighten_bri, pal_bright);
    }

    draw_surface_ext(application_surface, 0, 0, _plainScaleX, _plainScaleY, 0, c_white, 1);
    shader_reset();
    surface_reset_target();

    if (global.dispBordered)
    {
        var _scaleFactor = ((window_width / window_height) > 1.7777777777777777) ? (window_height / 216) : (window_width / 384);

        if (global.integerScale)
            _scaleFactor = max(floor(_scaleFactor), 1);

        screenWidth = 384 * _scaleFactor;
        screenHeight = 216 * _scaleFactor;
        screenX = (window_width - screenWidth) * 0.5;
        screenY = (window_height - screenHeight) * 0.5;
    }
    else
    {
        screenX = 0;
        screenY = 0;
        screenWidth = window_width;
        screenHeight = window_height;
    }

    if (global_scanlines && global_scale > 1)
    {
        if (global_scale == 2)
            scrDrawCRT_2xScale(buffer_surfaces, global_scanlines);
        else
            scrDrawCRT_NxScale(buffer_surfaces, global_scanlines, _scale);
    }
    else
    {
        gpu_set_tex_filter(global.dispFilter);
        draw_surface_stretched(buffer_surfaces[0], screenX, screenY, screenWidth, screenHeight);
        gpu_set_tex_filter(false);
    }
}
else
{
    do_screen = true;
}
