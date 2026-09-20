from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, StaticExpressionWriter, make_table,
    ConditionMethodWriter, ExpressionMethodWriter)

class Keyboard(ObjectWriter):
    class_name = 'Keyboard'
    static = True

    def write_init(self, writer):
        pass

class OnAnyDown(ConditionMethodWriter):
    is_always = True

    def write(self, writer):
        writer.put('last_key != -1')

actions = make_table(StaticActionWriter, {
})

conditions = make_table(ConditionMethodWriter, {
    3 : OnAnyDown,
    2 : 'is_key_pressed',
    0 : 'is_key_pressed_once',
    5 : 'is_any_key_pressed'
})

expressions = make_table(ExpressionMethodWriter, {
    0 : '.last_key',
    2 : 'translate_key_to_string'
})

def get_object():
    return Keyboard