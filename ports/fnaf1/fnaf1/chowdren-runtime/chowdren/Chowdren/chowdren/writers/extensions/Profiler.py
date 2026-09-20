from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ComparisonWriter, StaticActionWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

class ProfilerObject(ObjectWriter):
    class_name = 'ProfilerObject'
    filename = 'profilerext'
    static = True

actions = make_table(StaticActionWriter, {
    0 : 'start',
    1 : 'start_additive',
    2 : 'stop',
    3 : 'save'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
})

def get_object():
    return ProfilerObject
