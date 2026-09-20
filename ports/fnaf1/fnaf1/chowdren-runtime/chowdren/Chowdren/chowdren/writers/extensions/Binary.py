from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

class BinaryObject(ObjectWriter):
    class_name = 'BinaryObject'
    filename = 'binaryext'

    def write_init(self, writer):
        pass

actions = make_table(ActionMethodWriter, {
    1 : 'load_file',
    0 : 'save_file',
    16 : 'set_byte',
    75 : 'resize'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    3 : 'get_short',
    2 : 'get_byte'
})

def get_object():
    return BinaryObject