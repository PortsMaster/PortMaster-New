function scr_cliffcolour_start()
{
    if (event_type == ev_draw)
    {
        if (event_number == 0)
        {
            with (obj_parallax_cliffs)
                pal_swap_set(cliff_pal, pal_index, false);
        }
    }
}

function scr_cliffcolour_end()
{
    if (event_type == ev_draw)
    {
        if (event_number == 0)
            pal_swap_reset();
    }
}

function scr_sunset_layer_begin()
{
    if (event_type == ev_draw)
    {
        if (event_number == 0)
        {
            with (obj_parallax_cliffs)
            {
                //shader_replace_simple_set_hook(61);
                shader_set_uniform_f(i_idx, sun_colour);
                shader_set_uniform_f(i_width, sprite_get_width(palette));
                shader_set_uniform_f(i_height, sprite_get_height(palette));
                shader_set_uniform_f(i_blend, suny);
                var uvs = sprite_get_uvs(palette, 0);
                shader_set_uniform_f(i_uvs, uvs[0], uvs[1], uvs[2], uvs[3]);
                var t_sampler = shader_get_sampler_index(shd_palettemapper, "iPalette");
                texture_set_stage(t_sampler, sprite_get_texture(palette, 0));
            }
        }
    }
}

function scr_sunset_layer_end()
{
    if (event_type == ev_draw)
    {
        if (event_number == 0)
            shader_replace_simple_reset_hook();
    }
}
