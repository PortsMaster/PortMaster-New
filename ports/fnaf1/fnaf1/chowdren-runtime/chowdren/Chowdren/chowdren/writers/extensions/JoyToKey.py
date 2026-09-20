from chowdren.writers.objects import ObjectWriter

from chowdren.common import (get_animation_name, to_c, make_color,
                             TEMPORARY_GROUP_ID)

from chowdren.writers.events import (StaticConditionWriter,
    ActionWriter, ActionMethodWriter, StaticExpressionWriter, make_table,
    ConditionMethodWriter, ExpressionMethodWriter, EmptyAction, FalseCondition)

class JoyToKey(ObjectWriter):
    class_name = 'JoyToKey'
    static = True
    defines = ['CHOWDREN_USE_JOYTOKEY']

    def write_init(self, writer):
        pass

class AlwaysCondition(ConditionMethodWriter):
    is_always = True

actions = make_table(ActionMethodWriter, {
    0 : 'manager.map_button',
    1 : 'manager.map_axis',
    5 : 'manager.simulate_key',
    6 : EmptyAction, # detect devices
    7 : 'manager.set_deadzone',
    9 : EmptyAction, # load db
    12 : 'manager.reset_map'
})

class AlwaysFalse(FalseCondition):
    is_always = True

conditions = make_table(AlwaysCondition, {
    4 : 'is_joystick_pressed(1, %s + 1)',
    5 : 'is_joystick_pressed_once(1, %s + 1)',
    6 : FalseCondition, # gamepad just connected
    7 : 'is_joystick_attached(1)',
    8 : '.manager.pad_disconnected',
    10 : '.manager.axis_moved',
    11 : 'any_joystick_pressed_once(1)',
    14 : '.manager.pad_selected',
    17 : FalseCondition, # XXX has profile
    18 : '.loop_count <= 0'
})

DPAD_VALUES = {
    'h0.1': 'CHOWDREN_BUTTON_DPAD_UP',
    'h0.2': 'CHOWDREN_BUTTON_DPAD_RIGHT',
    'h0.4': 'CHOWDREN_BUTTON_DPAD_DOWN',
    'h0.8': 'CHOWDREN_BUTTON_DPAD_LEFT'
}

class InputNameToRaw(ExpressionMethodWriter):
    def get_string(self):
        converter = self.converter
        items = converter.expression_items
        last_exp = items[converter.item_index + 2]
        if last_exp.getName() != 'EndParenthesis':
            raise NotImplementedError()
        next_exp = items[converter.item_index + 1]
        if next_exp.getName() != 'String':
            raise NotImplementedError()
        name = next_exp.loader.value
        converter.item_index += 2
        return '(%s-1)' % DPAD_VALUES[name]

expressions = make_table(ExpressionMethodWriter, {
    3 : 'get_joystick_axis(1, 1 + ',
    6 : 'get_joystick_name(1)',
    9 : '(get_joystick_last_press(1) - 1)',
    10 : '.manager.last_axis',
    12 : 'get_joystick_guid(1)',
    17 : 'get_zero_dummy',
    18 : InputNameToRaw,
    20 : 'get_joytokey_name',
    28 : 'get_zero_dummy',
})

def get_object():
    return JoyToKey