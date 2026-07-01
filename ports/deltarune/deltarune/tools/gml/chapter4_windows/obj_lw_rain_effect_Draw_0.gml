if (!active)
{
    exit;
}
if (color_overlay)
{
    gpu_set_colorwriteenable(true, true, true, false);
    draw_set_blend_mode(bm_subtract);
    var _str = build_timer / 120;
    draw_set_color(merge_color(c_black, c_orange, 0.3 * _str));
    ossafe_fill_rectangle(camerax() - 10, cameray() - 10, camerax() + 650, cameray() + 490, false);
    draw_set_blend_mode(bm_add);
    draw_set_color(merge_color(c_black, c_white, 0.1 * _str));
    ossafe_fill_rectangle(camerax() - 10, cameray() - 10, camerax() + 650, cameray() + 490, false);
    draw_set_blend_mode(bm_normal);
    gpu_set_colorwriteenable(true, true, true, true);
}
if (rain_style >= 4)
{
    draw_set_blend_mode(bm_add);
    draw_sprite_tiled_ext(sprite_index, 0, round((timer * xspeed * xdir * speed_mul) / 1) * 1, (timer * yspeed * speed_mul) + (cameray() / 2), 1, 1, merge_color(c_white, c_black, 0.75), 1);
    draw_set_blend_mode(bm_normal);
}
draw_set_blend_mode(bm_add);
with (obj_lw_raindrop)
{
    if (visible)
    {
        draw_self();
    }
}
draw_set_blend_mode(bm_normal);
