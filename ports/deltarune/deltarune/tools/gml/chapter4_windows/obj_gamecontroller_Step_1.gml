if (os_type == os_windows || os_type == os_linux || os_type == os_macosx)
{
    var controllerUpdate = -1;
    if (gamepad_active == 0)
    {
        for (var r = 0; r < gamepad_get_device_count(); r++)
        {
            if (gamepad_is_connected(r))
            {
                controllerUpdate = r;
                break;
            }
        }
    }
    for (var i = 0; i < gamepad_get_device_count(); i++)
    {
        if (gamepad_is_connected(i) && i != gamepad_id)
        {
            if (gamepad_button_check(i, gp_face1) || gamepad_button_check(i, gp_face2) || gamepad_button_check(i, gp_face3) || gamepad_button_check(i, gp_face4) || gamepad_button_check(i, gp_padd) || gamepad_button_check(i, gp_padr) || gamepad_button_check(i, gp_padu) || gamepad_button_check(i, gp_padl) || abs(gamepad_axis_value(i, gp_axislh)) > 0.8 || abs(gamepad_axis_value(i, gp_axislv)) > 0.8)
            {
                if (gamepad_get_description(i) != gamepad_get_description(gamepad_id) && gamepad_get_guid(i) != gamepad_get_guid(gamepad_id))
                {
                    controllerUpdate = i;
                }
                break;
            }
        }
    }
    if (controllerUpdate != -1)
    {
        gamepad_id = controllerUpdate;
        gamepad_active = 1;
        var gamepad_description = gamepad_get_description(gamepad_id);
        if (gamepad_get_guid(gamepad_id) == "4c05e60c000000000000504944564944")
        {
            show_debug_message("***** Remap controller: " + gamepad_description + " to " + "DualSense Wireless Controller");
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
    }
}
