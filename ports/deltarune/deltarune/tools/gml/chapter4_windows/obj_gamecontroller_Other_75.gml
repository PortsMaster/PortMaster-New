show_debug_message("***** Event = " + string(ds_map_find_value(async_load, "event_type")));
switch (ds_map_find_value(async_load, "event_type"))
{
    case "gamepad discovered":
        var pad = ds_map_find_value(async_load, "pad_index");
        if (is_connecting_controller == 1)
        {
            exit;
        }
        if (gamepad_is_connected(pad))
        {
            gamepad_id = pad;
            if (scr_is_switch_os() && is_connecting_controller < 2)
            {
                is_connecting_controller = 1;
                if (switch_controller_support_show() == 0)
                {
                    gamepad_active = 1;
                    alarm[0] = 1;
                    gamepad_id = switch_controller_support_get_selected_id();
                }
                else
                {
                    gamepad_active = 0;
                    alarm[0] = 1;
                    global.gamepad_type = "N/A";
                    exit;
                }
            }
            alarm[0] = 1;
            gamepad_active = 1;
            var gamepad_description = gamepad_get_description(gamepad_id);
            show_debug_message("***** Connected controller: " + string(gamepad_type) + " | " + string(gamepad_description));
            if (gamepad_get_guid(gamepad_id) == "4c05e60c000000000000504944564944")
            {
                show_debug_message("***** Remap controller: " + string(gamepad_description) + " to " + "DualSense Wireless Controller");
                var mapping = "a:b1,b:b2,x:b0,y:b3,back:b8,start:b9,leftstick:b10,rightstick:b11,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a2,righty:a5,lefttrigger:a3,righttrigger:a4,";
                gamepad_test_mapping(gamepad_id, "4c05e60c000000000000504944564944," + gamepad_description + "," + mapping);
                gamepad_description = "DualSense Wireless Controller";
            }
            gamepad_type = gamepad_description;
            if (gamepad_type != global.gamepad_type)
            {
                global.gamepad_type = gamepad_type;
                scr_controls_default();
                if (_load_enabled)
                {
                    if (ossafe_file_exists("keyconfig_" + string(global.filechoice) + ".ini"))
                    {
                        ossafe_ini_open("keyconfig_" + string(global.filechoice) + ".ini");
                        for (var i = 0; i < 10; i++)
                        {
                            readval = ini_read_real("KEYBOARD_CONTROLS", string(i), -1);
                            if (readval != -1)
                            {
                                global.input_k[i] = readval;
                            }
                        }
                        for (var i = 0; i < 10; i++)
                        {
                            readval = ini_read_real("GAMEPAD_CONTROLS", string(i), -1);
                            if (readval != -1)
                            {
                                global.input_g[i] = readval;
                            }
                        }
                        var readval = ini_read_real("SHOULDERLB_REASSIGN", "SHOULDERLB_REASSIGN", gamepad_shoulderlb_reassign);
                        if (readval != -1)
                        {
                            gamepad_shoulderlb_reassign = readval;
                        }
                        global.button0 = global.input_g[4];
                        global.button1 = global.input_g[5];
                        global.button2 = global.input_g[6];
                        ossafe_ini_close();
                    }
                }
            }
            with (obj_event_manager)
            {
                load_trophies(pad);
            }
        }
        break;
    case "gamepad lost":
        var pad = ds_map_find_value(async_load, "pad_index");
        if (pad != gamepad_id)
        {
            exit;
        }
        if (is_connecting_controller > 0)
        {
            exit;
        }
        gamepad_active = 0;
        if (scr_is_switch_os())
        {
            if (switch_controller_support_show() == 0)
            {
                gamepad_active = 1;
                gamepad_id = switch_controller_support_get_selected_id();
                is_connecting_controller = 2;
                alarm[0] = 2;
            }
        }
        global.gamepad_type = "N/A";
        break;
}
