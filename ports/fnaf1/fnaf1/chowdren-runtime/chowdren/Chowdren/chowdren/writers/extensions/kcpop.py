from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, StaticActionWriter,
    StaticConditionWriter, StaticExpressionWriter, make_table,
    FalseCondition)

class PopupObject(ObjectWriter):
    class_name = 'PopupObject'
    static = True

    def write_init(self, writer):
        pass

actions = make_table(StaticActionWriter, {
})

conditions = make_table(StaticConditionWriter, {
    0 : FalseCondition, # ok button clicked
    2 : FalseCondition, # yes button clicked
    3 : FalseCondition # no button clicked
})

expressions = make_table(StaticExpressionWriter, {
})

def get_object():
    return PopupObject