from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

class BinaryArray(ObjectWriter):
    class_name = 'BinaryArray'
    filename = 'binaryarray'

    def write_init(self, writer):
        pass

actions = make_table(ActionMethodWriter, {
    0 : 'load_file',
    2 : 'load_workspaces',
    12 : 'create_workspace',
    4 : 'switch_workspace',

})

conditions = make_table(ConditionMethodWriter, {
    0 : 'has_workspace'
})

expressions = make_table(ExpressionMethodWriter, {
    10 : 'get_size',
    3 : 'read_string'
})

def get_object():
    return BinaryArray