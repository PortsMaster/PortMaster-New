from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, StaticExpressionWriter, make_table,
    ConditionMethodWriter, ExpressionMethodWriter, EmptyAction)

class KeyObject(ObjectWriter):
    class_name = 'Keyboard'
    static = True

    def write_init(self, writer):
        pass

class AlwaysCondition(ConditionMethodWriter):
    is_always = True

actions = make_table(StaticActionWriter, {
    1 : EmptyAction,
    0 : EmptyAction
})

conditions = make_table(AlwaysCondition, {
    1 : 'is_key_pressed(translate_string_to_key(%s))',
    # 3 : 'is_key_pressed_once(translate_vk_to_key(%s))',
    # 6 : 'is_key_released_once(translate_vk_to_key(%s))',
    3 : 'is_key_pressed_once(%s)',
    6 : 'is_key_released_once(%s)',
    7 : 'is_key_released_once(translate_string_to_key(%s))'
})

expressions = make_table(ExpressionMethodWriter, {
})

def get_object():
    return KeyObject