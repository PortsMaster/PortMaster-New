from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ActionMethodWriter, ConditionMethodWriter,
    ExpressionMethodWriter, make_table)

class VitalizePlugin(ObjectWriter):
    class_name = 'VitalizePlugin'
    static = True

actions = make_table(ActionMethodWriter, {
    4 : 'open_url(%s)'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
})

def get_object():
    return VitalizePlugin