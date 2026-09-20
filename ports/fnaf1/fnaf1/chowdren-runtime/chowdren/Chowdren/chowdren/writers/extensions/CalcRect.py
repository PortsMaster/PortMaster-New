from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, StaticExpressionWriter, make_table, EmptyAction,
    ExpressionMethodWriter)

class CalcRect(ObjectWriter):
    class_name = 'CalcRect'
    filename = 'calcrect'
    static = True

    def write_init(self, writer):
        pass

actions = make_table(StaticActionWriter, {
    0 : 'set_font',
    1 : 'set_text',
    2 : 'set_max_width',
    3 : EmptyAction
})

conditions = make_table(StaticConditionWriter, {
})

expressions = make_table(StaticExpressionWriter, {
    0 : 'get_width()',
    1 : 'get_height()'
})

def get_object():
    return CalcRect
