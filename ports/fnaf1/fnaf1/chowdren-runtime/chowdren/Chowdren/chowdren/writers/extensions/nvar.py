from chowdren.writers.objects import ObjectWriter
from mmfparser.bitdict import BitDict

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

from chowdren.writers.extensions.AssArray import (AssociateArray,   
                                                  create_key_action,
                                                  create_key_expression)

class NamedVariables(AssociateArray):
    use_alterables = True

    def write_init(self, writer):
        data = self.get_data()
        data.skipBytes(4)
        data.skipBytes(4) # width, height
        is_global = data.readInt() != 0
        case_insensitive = data.readInt() != 0
        if case_insensitive:
            raise NotImplementedError()
        self.write_assarray(writer, is_global)

actions = make_table(ActionMethodWriter, {
    0 : create_key_action('set_value'),
    1 : create_key_action('add_value'),
    2 : create_key_action('sub_value'),
    8 : create_key_action('set_string'),
    11 : 'clear'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    0 : create_key_expression('get_value'),
    1 : create_key_expression('get_string')
})

def get_object():
    return NamedVariables
