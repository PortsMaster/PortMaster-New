//shader_replace_simple_set_hook(61);
shader_set_uniform_f(i_idx, sun_colour);
shader_set_uniform_f(i_width, sprite_get_width(palette));
shader_set_uniform_f(i_height, sprite_get_height(palette));
shader_set_uniform_f(i_blend, suny);
var uvs = sprite_get_uvs(palette, 0);
shader_set_uniform_f(i_uvs, uvs[0], uvs[1], uvs[2], uvs[3]);
var t_sampler = shader_get_sampler_index(shd_palettemapper, "iPalette");
texture_set_stage(t_sampler, sprite_get_texture(palette, 0));
var _mix = 16777215;

for (var i = 0; i < struct_layer_count; i++)
{
    var lay = struct_bgs[i];
    
    for (var n = 0; n < 2; n++)
        draw_sprite_ext(lay.bgid, 0, lay.x + (lay.swidth * n), lay.y, 2, 2, 0, _mix, 1);
}

shader_replace_simple_reset_hook();
