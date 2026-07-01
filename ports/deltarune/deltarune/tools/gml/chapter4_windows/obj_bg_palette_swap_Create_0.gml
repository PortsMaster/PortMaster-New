layer_name = ["BACKGROUND"];

if (room == room_town_north)
    layer_name = ["Compatibility_Tiles_Depth_5000", "Compatibility_Tiles_Depth_950000", "Compatibility_Tiles_Depth_990000", "Compatibility_Tiles_Depth_1000000"];

if (room == room_beach)
    layer_name = ["Compatibility_Instances_Depth_0", "FGTreeLayer_5000", "BGTreeLayer", "GroundLayer", "_oldShoreLine"];

if (room == room_town_krisyard)
    layer_name = ["Compatibility_Tiles_Depth_5000", "Compatibility_Tiles_Depth_950000", "Compatibility_Tiles_Depth_990000", "Compatibility_Tiles_Depth_1000000"];

if (room == room_town_krisyard_dark)
    layer_name = ["Compatibility_Tiles_Depth_5000", "Compatibility_Tiles_Depth_950000", "Compatibility_Tiles_Depth_990000", "Compatibility_Tiles_Depth_1000000"];

if (room == room_town_mid)
    layer_name = ["Compatibility_Tiles_Depth_5000", "Compatibility_Tiles_Depth_990000", "Compatibility_Tiles_Depth_995000", "Compatibility_Tiles_Depth_1000000"];

if (room == room_town_south)
    layer_name = ["Compatibility_Tiles_Depth_5000", "Compatibility_Tiles_Depth_980000", "Compatibility_Tiles_Depth_990000", "Compatibility_Tiles_Depth_995000", "Compatibility_Tiles_Depth_1000000"];

if (room == room_town_school)
    layer_name = ["Compatibility_Tiles_Depth_5000", "Compatibility_Tiles_Depth_950000", "Compatibility_Tiles_Depth_990000", "Compatibility_Tiles_Depth_995000", "Compatibility_Tiles_Depth_1000000"];

if (room == room_town_church)
    layer_name = ["Compatibility_Tiles_Depth_5000", "Compatibility_Tiles_Depth_990000", "Compatibility_Instances_Depth_990000", "Compatibility_Tiles_Depth_995000", "Compatibility_Tiles_Depth_1000000"];

if (room == room_graveyard)
    layer_name = ["Compatibility_Tiles_Depth_5000", "Compatibility_Tiles_Depth_950000", "Compatibility_Tiles_Depth_990000", "Compatibility_Tiles_Depth_995000", "Compatibility_Tiles_Depth_1000000"];

if (room == room_town_shelter)
    layer_name = ["Compatibility_Tiles_Depth_5000", "Compatibility_Instances_Depth_800000", "Compatibility_Tiles_Depth_990000", "Compatibility_Tiles_Depth_992000", "Compatibility_Tiles_Depth_995000", "Compatibility_Tiles_Depth_1000000"];

if (room == room_alphysalley)
    layer_name = ["Compatibility_Background_0_bg_alphysalley"];

plot_begin = 0;
plot_end = 300;

if (global.chapter == 4)
{
    plot_begin = 290;
    plot_end = 330;
    
    if (global.plot >= 290)
    {
        overlay = scr_marker(-10, -10, spr_whitepx_10);
        overlay.image_xscale = (room_width / 10) + 2;
        overlay.image_yscale = (room_height / 10) + 2;
        overlay.image_blend = merge_color(c_black, c_navy, 0.5);
        overlay.image_alpha = 0.6;
        overlay.depth = 990;
        
        if (room == room_graveyard)
        {
            with (obj_backgrounder_sprite)
                image_blend = merge_color(c_black, c_navy, 0.5);
        }
        
        if (room == room_town_krisyard)
        {
            var dark_overlay = scr_marker(-10, -10, spr_whitepx_10);
            dark_overlay.image_xscale = (room_width / 10) + 2;
            dark_overlay.image_yscale = (room_height / 10) + 2;
            dark_overlay.image_blend = c_black;
            dark_overlay.image_alpha = 1;
            dark_overlay.depth = 980;
            scr_doom(dark_overlay, 2);
            
            with (overlay)
                instance_destroy();
            
            var yard_overlay = instance_create(0, 0, obj_krisyard_night_overlay);
        }
        
        if (room == room_town_krisyard_dark)
        {
            var window_pos = [];
            var y_offset = 0;
            window_pos[0][0] = 125;
            window_pos[0][1] = 236 + y_offset;
            window_pos[1][0] = 199;
            window_pos[1][1] = 236 + y_offset;
            overlay.depth = 992;
            
            for (var i = 0; i < array_length(window_pos); i++)
            {
                var _x = window_pos[i][0];
                var _y = window_pos[i][1];
                var _marker = scr_marker(_x, _y, bg_building_krishouse_window_night);
                _marker.depth = overlay.depth - 1;
            }
        }
    }
}

/*if (global.plot >= plot_begin && global.plot < plot_end)
{
    pal_swap_layer_init();
    
    for (var i = 0; i < array_length_1d(layer_name); i++)
    {
        pal_swap_enable_layer(layer_name[i]);
        pal_swap_set_layer(palette_sprite, palette_index, layer_name[i], false);
    }
    
    pal_swap_reset();
}*/
