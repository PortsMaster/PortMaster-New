if (!instance_exists(obj_lw_rain_effect))
{
    draw_set_blend_mode(bm_add);
    draw_self();
    draw_set_blend_mode(bm_normal);
}
