gameStart = function()
{
    game_init();
    window_set_size(global.windowWidth, global.windowHeight);
    global.optionsController = instance_create_layer(0, 0, "system_layer", code_players_customizations_controller);
    instance_create_layer(0, 0, "system_layer", obj_music_controller);
    
    if (global.precompileSweep)
        global.devToolRoomSweeper = instance_create_layer(0, 0, "system_layer", obj_precompile_tool_room_sweeper);
    
    alarm[1] = 1;
};

var startDelay = 120;
alarm[0] = startDelay;
global.framecounter = 0;
ini_open("config.ini");
global.frameskip = ini_read_real("Performance", "FrameSkip", 0);
global.IdolSFX = ini_read_real("Performance", "IdolSFX", 1);
ini_close();
