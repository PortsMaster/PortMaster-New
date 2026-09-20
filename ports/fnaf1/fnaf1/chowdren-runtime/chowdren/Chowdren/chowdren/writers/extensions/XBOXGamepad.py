from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, StaticExpressionWriter, make_table,
    ConditionMethodWriter, ExpressionMethodWriter, EmptyAction,
    StaticConditionWriter, ActionMethodWriter)

class XBOXGamepad(ObjectWriter):
    class_name = 'Joystick'
    static = True

actions = make_table(ActionMethodWriter, {
    0 : 'joystick_vibrate'
})

conditions = make_table(ConditionMethodWriter, {
    0 : 'is_joystick_attached(%s+1)',
    2 : 'is_joystick_pressed(%s, CHOWDREN_BUTTON_B)',
    1 : 'is_joystick_pressed(%s, CHOWDREN_BUTTON_A)',
    9 : 'is_joystick_pressed(%s, CHOWDREN_BUTTON_RIGHTSHOULDER)',
    3 : 'is_joystick_pressed(%s, CHOWDREN_BUTTON_X)',
    4 : 'is_joystick_pressed(%s, CHOWDREN_BUTTON_Y)',
    5 : 'is_joystick_pressed(%s, CHOWDREN_BUTTON_BACK)',
    7 : 'is_joystick_pressed(%s, CHOWDREN_BUTTON_LEFTSHOULDER)',
    14 : 'is_joystick_pressed(%s, CHOWDREN_BUTTON_DPAD_LEFT)',
    15 : 'is_joystick_pressed(%s, CHOWDREN_BUTTON_DPAD_RIGHT)',
    12 : 'is_joystick_pressed(%s, CHOWDREN_BUTTON_DPAD_UP)',
    11 : 'is_joystick_pressed(%s, CHOWDREN_BUTTON_START)',
    13 : 'is_joystick_pressed(%s, CHOWDREN_BUTTON_DPAD_DOWN)'
})

expressions = make_table(ExpressionMethodWriter, {
    4 : 'get_joystick_lt',
    5 : 'get_joystick_rt'
})

def get_object():
    return XBOXGamepad