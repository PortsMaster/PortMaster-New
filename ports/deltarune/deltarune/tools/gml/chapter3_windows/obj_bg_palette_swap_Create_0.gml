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

if (global.chapter == 3)
{
    plot_begin = 340;
    plot_end = 999;
}

/*
if (global.plot >= plot_begin && global.plot < plot_end)
{
	
    pal_swap_layer_init();
    
    for (var i = 0; i < array_length_1d(layer_name); i++)
    {
        pal_swap_enable_layer(layer_name[i]);
        pal_swap_set_layer(palette_sprite, palette_index, layer_name[i], false);
    }
    
    pal_swap_reset();
}
*/