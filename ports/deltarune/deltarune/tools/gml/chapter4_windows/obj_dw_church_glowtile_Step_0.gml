var colconfig = 0;
doripple = false;
if (instance_exists(obj_church_ripple_area_manager))
{
    image_alpha = 1;
    if (obj_church_ripple_area_manager.active == true)
    {
        image_alpha = 0;
        doripple = true;
        actsound = 3;
    }
}
if (instance_exists(obj_dw_churchc_encounter2))
{
    actsound = 3;
    colconfig = 0;
}
if (instance_exists(obj_dw_church_rippleworship))
{
    doripple = false;
    actsound = 0;
}
if (instance_exists(obj_dw_churchc_treasurechest) || room == room_dw_churchc_treasurechest)
{
    doripple = false;
    actsound = -1;
}
if (instance_exists(obj_dw_church_waterfallroom))
{
    if (extflag == "endswitch")
    {
        doripple = false;
        actsound = 0;
        colconfig = 1;
    }
}
event_inherited();
siner++;
sprite_index = spr_dw_church_glowtile;
var col1 = 16756046;
with (obj_church_ripple_area_manager)
{
    if (active)
    {
        colconfig = 2;
    }
}
if (extflag == "endswitch")
{
    colconfig = 1;
}
if (colconfig == 2)
{
    col1 = 16777215;
    sprite_index = spr_dw_church_glowtileyellow;
}
if (glow && (floor(siner) % 3) != 0 && scr_onscreen_tolerance(id, 80))
{
    with (instance_create(x, y, obj_marker_darkness_unlit))
    {
        sprite_index = other.sprite_index;
        image_speed = 0;
        var scale = 2 + abs(sin(other.siner / 30) * 0.2);
        scr_size(scale, scale);
        var lifetime = 12 - other.pressed;
        scr_lerpvar("image_xscale", scale, (scale / 2) + (sin(other.siner / 6) * 0.1), lifetime, 2, "in");
        scr_lerpvar("image_yscale", scale, (scale / 2) + (sin(other.siner / 4) * 0.1), lifetime, 2, "in");
        scr_lerpvar("image_alpha", clamp((0.35 + (sin(other.siner / 20) * 0.125)) - other.pressed, 0.05, 0.5), 0, lifetime);
        image_blend = col1;
        direction = other.siner * 12;
        if (i_ex(obj_darkness_overlay))
        {
            depth = 100000000;
        }
        else
        {
            depth = other.depth - 1;
        }
        gravity = -0.7;
        vspeed = 1.5;
        scr_doom(id, lifetime);
    }
}
