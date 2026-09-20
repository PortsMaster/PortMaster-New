from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, StaticActionWriter,
    StaticConditionWriter, StaticExpressionWriter, make_table, EmptyAction)

class ProcessViewer(ObjectWriter):
    class_name = 'ProcessViewer'
    static = True

    def write_init(self, writer):
        pass

actions = make_table(StaticActionWriter, {
    2 : EmptyAction
})

conditions = make_table(StaticConditionWriter, {
})

expressions = make_table(StaticExpressionWriter, {
})

def get_object():
    return ProcessViewer
