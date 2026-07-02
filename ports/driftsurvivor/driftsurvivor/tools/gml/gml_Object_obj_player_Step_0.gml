if (!active)
{
    pause_ts_all();
    exit;
}
else
{
    resume_ts_all();
}

if (global.input_type == UnknownEnum.Value_0)
{
    key_acc = keyboard_check(vk_up) || keyboard_check(ord("W"));
    key_acc_tap = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
    key_brake = keyboard_check(vk_down) || keyboard_check(ord("S"));
    key_brake_tap = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
    key_fire = keyboard_check_pressed(vk_alt);
    key_dash = keyboard_check_pressed(vk_space);
}
else
{
    key_acc = gamepad_button_check(0, gp_shoulderrb) || gamepad_button_check(0, gp_shoulderr);
    key_acc_tap = gamepad_button_check_pressed(0, gp_shoulderrb) || gamepad_button_check_pressed(0, gp_shoulderr);
    key_brake = gamepad_button_check(0, gp_shoulderlb) || gamepad_button_check(0, gp_shoulderl);
    key_brake_tap = gamepad_button_check_pressed(0, gp_shoulderlb) || gamepad_button_check_pressed(0, gp_shoulderl);
    key_fire = gamepad_button_check_pressed(0, gp_face1);
    key_dash = gamepad_button_check_pressed(0, gp_face3);
}

x_input = obj_input.right_held[0] - obj_input.left_held[0];
x_input_pressed = obj_input.right_pressed[0] - obj_input.left_pressed[0];
script_execute(state_script[state]);

enum UnknownEnum
{
    Value_0
}
