image_xscale = 2;
image_yscale = 2;
simple = false;
daddy = -4;

with (obj_parallax_cliffs)
    other.daddy = id;

with (obj_parallax_cliffs_simple)
{
    other.daddy = id;
    other.simple = true;
}

sprites = [5377, 522, 6439, 3683, 6592, 7868];
use_shader = [true, false, true, true, false, true];
layer_alpha = [1, 1, 1, 1, 1, 1];
draw_order = [5, 1, 4, 0, 2, 3];

if (simple)
{
    layer_alpha[1] = 0;
    layer_alpha[3] = 0;
}

instance_create_depth(0, 0, depth + 10, obj_parallax_cliffs_moving_layers_back);
u_pal_idx = shader_get_uniform(shd_palettemapper, "paletteIdx");
u_pal_width = shader_get_uniform(shd_palettemapper, "paletteWidth");
u_pal_height = shader_get_uniform(shd_palettemapper, "paletteHeight");
u_pal_uvs = shader_get_uniform(shd_palettemapper, "iUVs");
u_pal_blend = shader_get_uniform(shd_palettemapper, "iBlend");
u_pal_sampler = shader_get_sampler_index(shd_palettemapper, "iPalette");

activate_shader = function()
{
    //shader_replace_simple_set_hook(61);
    var pal = daddy.palette;
    shader_set_uniform_f(u_pal_idx, daddy.sun_colour);
    shader_set_uniform_f(u_pal_width, sprite_get_width(pal));
    shader_set_uniform_f(u_pal_height, sprite_get_height(pal));
    shader_set_uniform_f(u_pal_blend, daddy.suny);
    var uvs = sprite_get_uvs(pal, 0);
    shader_set_uniform_f(u_pal_uvs, uvs[0], uvs[1], uvs[2], uvs[3]);
    texture_set_stage(u_pal_sampler, sprite_get_texture(pal, 0));
};

draw_lay = function(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
{
    if (layer_alpha[arg0] <= 0)
        exit;
    
    var drawx = arg1 + 320;
    var drawy = arg2 + arg6 + (arg5 * arg7);
    
    if (arg0 == 1)
    {
        drawx = arg1 - 200;
    }
    else if (arg0 == 4 || arg0 == 5)
    {
        drawx = arg1 + 320;
        drawy = arg2 - 200;
    }
    
    drawx += arg3;
    drawy += arg4;
    draw_sprite_ext(sprites[arg0], 0, drawx, drawy, image_xscale, image_yscale, 0, c_white, layer_alpha[arg0]);
};
