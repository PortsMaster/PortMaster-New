function receive_gamepad_input()
{
    if (gamepad_is_connected(0))
    {
        a_pressed[0] = gamepad_button_check_pressed(0, gp_face1);
        b_pressed[0] = gamepad_button_check_pressed(0, gp_face2);
        x_pressed[0] = gamepad_button_check_pressed(0, gp_face3);
        y_pressed[0] = gamepad_button_check_pressed(0, gp_face4);
        start_pressed[0] = gamepad_button_check_pressed(0, gp_start);
        select_pressed[0] = gamepad_button_check_pressed(0, gp_select);
        lt_pressed[0] = gamepad_button_check_pressed(0, gp_shoulderlb) || gamepad_button_check_pressed(0, gp_shoulderl);
        rt_pressed[0] = gamepad_button_check_pressed(0, gp_shoulderrb) || gamepad_button_check_pressed(0, gp_shoulderr);
        a_held[0] = gamepad_button_check(0, gp_face1);
        b_held[0] = gamepad_button_check(0, gp_face2);
        x_held[0] = gamepad_button_check(0, gp_face3);
        y_held[0] = gamepad_button_check(0, gp_face4);
        start_held[0] = gamepad_button_check(0, gp_start);
        select_held[0] = gamepad_button_check(0, gp_select);
        lt_held[0] = gamepad_button_check(0, gp_shoulderlb);
        rt_held[0] = gamepad_button_check(0, gp_shoulderrb);
        a_release[0] = gamepad_button_check_released(0, gp_face1);
        b_release[0] = gamepad_button_check_released(0, gp_face2);
        x_release[0] = gamepad_button_check_released(0, gp_face3);
        y_release[0] = gamepad_button_check_released(0, gp_face4);
        start_release[0] = gamepad_button_check_released(0, gp_start);
        select_release[0] = gamepad_button_check_released(0, gp_select);
        lt_release[0] = gamepad_button_check_released(0, gp_shoulderlb) || gamepad_button_check_released(0, gp_shoulderl);
        rt_release[0] = gamepad_button_check_released(0, gp_shoulderrb) || gamepad_button_check_released(0, gp_shoulderr);
        var up_input = gamepad_axis_value(0, gp_axislv) <= -threshold || gamepad_button_check(0, gp_padu);
        
        if (!up_held[0] && up_input)
        {
            up_held[0] = true;
            up_pressed[0] = true;
            up_release[0] = false;
            time_source_start(ts_gamepad0_resume_dir);
        }
        else if (up_held[0] && !up_input)
        {
            up_held[0] = false;
            up_pressed[0] = false;
            up_release[0] = true;
            time_source_start(ts_gamepad0_resume_dir);
        }
        
        var down_input = gamepad_axis_value(0, gp_axislv) >= threshold || gamepad_button_check(0, gp_padd);
        
        if (!down_held[0] && down_input)
        {
            down_held[0] = true;
            down_pressed[0] = true;
            down_release[0] = false;
            time_source_start(ts_gamepad0_resume_dir);
        }
        else if (down_held[0] && !down_input)
        {
            down_held[0] = false;
            down_pressed[0] = false;
            down_release[0] = true;
            time_source_start(ts_gamepad0_resume_dir);
        }
        
        var left_input = gamepad_axis_value(0, gp_axislh) <= -threshold || gamepad_button_check(0, gp_padl);
        
        if (!left_held[0] && left_input)
        {
            left_held[0] = true;
            left_pressed[0] = true;
            left_release[0] = false;
            time_source_start(ts_gamepad0_resume_dir);
        }
        else if (left_held[0] && !left_input)
        {
            left_held[0] = false;
            left_pressed[0] = false;
            left_release[0] = true;
            time_source_start(ts_gamepad0_resume_dir);
        }
        
        var right_input = gamepad_axis_value(0, gp_axislh) >= threshold || gamepad_button_check(0, gp_padr);
        
        if (!right_held[0] && right_input)
        {
            right_held[0] = true;
            right_pressed[0] = true;
            right_release[0] = false;
            time_source_start(ts_gamepad0_resume_dir);
        }
        else if (right_held[0] && !right_input)
        {
            right_held[0] = false;
            right_pressed[0] = false;
            right_release[0] = true;
            time_source_start(ts_gamepad0_resume_dir);
        }
    }
    
    if (gamepad_is_connected(1))
    {
        a_pressed[1] = gamepad_button_check_pressed(1, gp_face1);
        b_pressed[1] = gamepad_button_check_pressed(1, gp_face2);
        x_pressed[1] = gamepad_button_check_pressed(1, gp_face3);
        y_pressed[1] = gamepad_button_check_pressed(1, gp_face4);
        start_pressed[1] = gamepad_button_check_pressed(1, gp_start);
        select_pressed[1] = gamepad_button_check_pressed(1, gp_select);
        lt_pressed[1] = gamepad_button_check_pressed(1, gp_shoulderlb);
        rt_pressed[1] = gamepad_button_check_pressed(1, gp_shoulderrb);
        a_held[1] = gamepad_button_check(1, gp_face1);
        b_held[1] = gamepad_button_check(1, gp_face2);
        x_held[1] = gamepad_button_check(1, gp_face3);
        y_held[1] = gamepad_button_check(1, gp_face4);
        start_held[1] = gamepad_button_check(1, gp_start);
        select_held[1] = gamepad_button_check(1, gp_select);
        lt_held[1] = gamepad_button_check(1, gp_shoulderlb);
        rt_held[1] = gamepad_button_check(1, gp_shoulderrb);
        a_release[1] = gamepad_button_check_released(1, gp_face1);
        b_release[1] = gamepad_button_check_released(1, gp_face2);
        x_release[1] = gamepad_button_check_released(1, gp_face3);
        y_release[1] = gamepad_button_check_released(1, gp_face4);
        start_release[1] = gamepad_button_check_released(1, gp_start);
        select_release[1] = gamepad_button_check_released(1, gp_select);
        lt_release[1] = gamepad_button_check_released(1, gp_shoulderlb);
        rt_release[1] = gamepad_button_check_released(1, gp_shoulderrb);
        var up_input = gamepad_axis_value(1, gp_axislv) <= -threshold || gamepad_button_check(1, gp_padu);
        
        if (!up_held[1] && up_input)
        {
            up_held[1] = true;
            up_pressed[1] = true;
            up_release[1] = false;
            time_source_start(ts_gamepad1_resume_dir);
        }
        else if (up_held[1] && !up_input)
        {
            up_held[1] = false;
            up_pressed[1] = false;
            up_release[1] = true;
            time_source_start(ts_gamepad1_resume_dir);
        }
        
        var down_input = gamepad_axis_value(1, gp_axislv) >= threshold || gamepad_button_check(1, gp_padd);
        
        if (!down_held[1] && down_input)
        {
            down_held[1] = true;
            down_pressed[1] = true;
            down_release[1] = false;
            time_source_start(ts_gamepad1_resume_dir);
        }
        else if (down_held[1] && !down_input)
        {
            down_held[1] = false;
            down_pressed[1] = false;
            down_release[1] = true;
            time_source_start(ts_gamepad1_resume_dir);
        }
        
        var left_input = gamepad_axis_value(1, gp_axislh) <= -threshold || gamepad_button_check(1, gp_padl);
        
        if (!left_held[1] && left_input)
        {
            left_held[1] = true;
            left_pressed[1] = true;
            left_release[1] = false;
            time_source_start(ts_gamepad1_resume_dir);
        }
        else if (left_held[1] && !left_input)
        {
            left_held[1] = false;
            left_pressed[1] = false;
            left_release[1] = true;
            time_source_start(ts_gamepad1_resume_dir);
        }
        
        var right_input = gamepad_axis_value(1, gp_axislh) >= threshold || gamepad_button_check(1, gp_padr);
        
        if (!right_held[1] && right_input)
        {
            right_held[1] = true;
            right_pressed[1] = true;
            right_release[1] = false;
            time_source_start(ts_gamepad1_resume_dir);
        }
        else if (right_held[1] && !right_input)
        {
            right_held[1] = false;
            right_pressed[1] = false;
            right_release[1] = true;
            time_source_start(ts_gamepad1_resume_dir);
        }
    }
}
