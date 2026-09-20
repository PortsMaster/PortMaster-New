from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, StaticExpressionWriter, make_table,
    ConditionMethodWriter, ExpressionMethodWriter, EmptyAction,
    StaticConditionWriter, TrueCondition, FalseCondition, ActionMethodWriter)

class ControlsObject(ObjectWriter):
    class_name = 'ControlsObject'
    static = True

    def write_init(self, writer):
        pass

class ActionWriter(ActionMethodWriter):
    has_object = False

actions = make_table(ActionWriter, {
    7 : 'manager.up = translate_string_to_key({1})', # set player up
    8 : 'manager.down = translate_string_to_key({1})', # set player down
    9 : 'manager.left = translate_string_to_key({1})', # set player left
    10 : 'manager.right = translate_string_to_key({1})', # set player right
    11 : 'manager.button1 = translate_string_to_key({1})', # set player fire 1
    12 : 'manager.button2 = translate_string_to_key({1})', # set player fire 2
    # simulate key value down
    33 : 'manager.simulate_key(translate_vk_to_key(%s))',
    38 : 'manager.button3 = translate_string_to_key({1})', # set player fire 3
    39 : 'manager.button4 = translate_string_to_key({1})', # set player fire 4
    15 : EmptyAction, # disable_alt_tab_ctrl_esc_and_ctrl_alt_del
})

conditions = make_table(ConditionMethodWriter, {
    0 : 'is_key_pressed(translate_string_to_key(%s))',
    1 : 'is_key_pressed_once(translate_string_to_key(%s))',
    4 : 'is_any_key_pressed',
    5 : 'is_key_pressed(%s)',
    9 : 'is_any_key_pressed_once'
})


def get_key(name):
    # XXX probably slow. Optimize?
    class GetKey(ExpressionMethodWriter):
        def get_string(self):
            converter = self.converter
            items = converter.expression_items
            next_exp = items[converter.item_index + 1]
            if next_exp.getName() != 'Long':
                raise NotImplementedError()
            last_exp = items[converter.item_index + 2]
            if last_exp.getName() != 'EndParenthesis':
                raise NotImplementedError()
            converter.item_index += 2
            return 'translate_key_to_string(manager.%s)' % name

    return GetKey

expressions = make_table(ExpressionMethodWriter, {
    0 : 'translate_key_to_string(get_last_key_pressed())',
    1 : 'get_last_key_pressed()',
    3 : 'translate_key_to_string',
    4 : get_key('up'),
    5 : get_key('down'),
    6 : get_key('left'),
    7 : get_key('right'),
    8 : get_key('button1'),
    9 : get_key('button2'),
    16 : get_key('button3')
})

def get_object():
    return ControlsObject
