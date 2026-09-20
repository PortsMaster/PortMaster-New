from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, StaticActionWriter,
    StaticConditionWriter, StaticExpressionWriter, make_table)

class GlobalStore(ObjectWriter):
    class_name = 'GlobalStore'
    filename = 'globalstore'
    static = True

    def write_init(self, writer):
        pass

class CompareValue(ComparisonWriter):
    static = True
    value = 'values.get(%s)'

actions = make_table(StaticActionWriter, {
    0 : 'values.set',
    2 : 'strings.set'
})

conditions = make_table(StaticConditionWriter, {
    0 : CompareValue
})

expressions = make_table(StaticExpressionWriter, {
    2 : 'strings.get'
})

def get_object():
    return GlobalStore
