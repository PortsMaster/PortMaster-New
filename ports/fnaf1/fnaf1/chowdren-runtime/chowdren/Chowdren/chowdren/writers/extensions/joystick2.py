from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    ActionMethodWriter, StaticExpressionWriter, make_table,
    ConditionMethodWriter, ExpressionMethodWriter, EmptyAction,
    StaticConditionWriter, TrueCondition, FalseCondition)

class Joystick2(ObjectWriter):
    class_name = 'FrameObject'
    use_alterables = True

    def write_init(self, writer):
        pass

class GlobalActionWriter(ActionMethodWriter):
    def get_object(self):
        return (None, None)

actions = make_table(GlobalActionWriter, {
    0 : EmptyAction, # ignore control
    1 : EmptyAction, # restore control,
    11 : 'create_joystick_rumble',
    12 : 'start_joystick_rumble',
    35 : EmptyAction, # poll for devices, not necessary on SDL2
})

class GlobalConditionWriter(ConditionMethodWriter):
    def get_object(self):
        return (None, None)

conditions = make_table(GlobalConditionWriter, {
    0 : 'is_joystick_pressed', # repeat while
    1 : 'any_joystick_pressed',
    2 : 'is_joystick_attached',
    3 : FalseCondition, # how does this work exactly
    4 : 'is_joystick_pressed_once',
    5 : 'is_joystick_pressed_once', # once
    6 : 'is_joystick_released_once',
    7 : 'any_joystick_pressed_once',
    17 : 'compare_joystick_direction',
    27 : 'is_joystick_direction_changed',
    33 : TrueCondition, # is xbox controller
    26 : TrueCondition, # has point of view
    8 : 'is_joystick_pressed(%s, CHOWDREN_BUTTON_DPAD_UP)',
    9 : 'is_joystick_pressed(%s, CHOWDREN_BUTTON_DPAD_DOWN)',
    10 : 'is_joystick_pressed(%s, CHOWDREN_BUTTON_DPAD_LEFT)',
    11 : 'is_joystick_pressed(%s, CHOWDREN_BUTTON_DPAD_RIGHT)',
})

class GlobalExpressionWriter(ExpressionMethodWriter):
    def get_object(self):
        return (None, None)

expressions = make_table(GlobalExpressionWriter, {
    0 : 'get_joystick_x',
    1 : 'get_joystick_y',
    # on a 360, this is RT analog value
    # joystick2_get_axis_values_raw_z_value_2
    2 : 'get_joystick_z',
    # on a 360, this is the rotation value on the right thumb stick
    # joystick2_get_axis_values_raw_x_rotation_3
    3 : '.get_event_dummy(0.0f, ',
    # joystick2_get_axis_values_raw_y_rotation_4
    4 : '.get_event_dummy(0.0f, ',
    # joystick2_get_axis_values_raw_z_rotation_5
    5 : '.get_event_dummy(0.0f, ',
    6 : 'get_joystick_dpad_degrees',
    # joystick2_min_values_min_x_value_7
    7 : '.get_event_dummy(-1000.0f, ',
    # joystick2_min_values_min_y_value_8
    8 : '.get_event_dummy(-1000.0f, ',
    # joystick2_min_values_min_z_value_9
    9 : '.get_event_dummy(0.0f, ',
    # joystick2_min_values_min_x_rotation_10
    10 : '.get_event_dummy(0.0f, ',
    # joystick2_min_values_min_y_rotation_11
    11 : '.get_event_dummy(0.0f, ',
    # joystick2_min_values_min_z_rotation_12
    12 : '.get_event_dummy(0.0f, ',
    # joystick2_max_values_max_x_value_13
    13 : '.get_event_dummy(1000.0f, ',
    # joystick2_max_values_max_y_value_14
    14 : '.get_event_dummy(1000.0f, ',
    # joystick2_max_values_max_z_value_15
    15 : '.get_event_dummy(0.0f, ',
    # joystick2_max_values_max_x_rotation_16
    16 : '.get_event_dummy(0.0f, ',
    # joystick2_max_values_max_y_rotation_17
    17 : '.get_event_dummy(0.0f, ',
    # joystick2_max_values_max_z_rotation_18
    18 : '.get_event_dummy(0.0f, ',
    22 : 'get_joystick_last_press',
    26 : 'get_joystick_degrees',
    # joystick2_min_values_min_slider_value_29
    29 : '.get_event_dummy(0.0f, ',
    # joystick2_max_values_max_slider_value_30
    30 : '.get_event_dummy(0.0f, ',
    # joystick2_get_axis_values_raw_slider_value_31
    31 : '.get_event_dummy(0.0f, ',
    32 : 'get_joystick_name'
})

def get_object():
    return Joystick2
