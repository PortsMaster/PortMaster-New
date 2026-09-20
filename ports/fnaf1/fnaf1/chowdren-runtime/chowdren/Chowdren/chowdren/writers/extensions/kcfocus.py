from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticActionWriter, StaticConditionWriter,
    StaticExpressionWriter, make_table)

class WindowControl(ObjectWriter):
    class_name = 'WindowControl'
    static = True

actions = make_table(StaticActionWriter, {
})

conditions = make_table(StaticConditionWriter, {
    0 : 'has_focus'
})

expressions = make_table(StaticExpressionWriter, {
})

def get_object():
    return WindowControl