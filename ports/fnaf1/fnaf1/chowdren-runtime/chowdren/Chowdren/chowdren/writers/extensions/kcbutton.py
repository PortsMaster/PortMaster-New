from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table,
    EmptyAction)

class ButtonObject(ObjectWriter):
    class_name = 'ButtonObject'
    filename = 'buttonext'

    def write_init(self, writer):
        pass

actions = make_table(ActionMethodWriter, {
    4 : EmptyAction, # disable
    3 : EmptyAction # enable
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
})

def get_object():
    return ButtonObject