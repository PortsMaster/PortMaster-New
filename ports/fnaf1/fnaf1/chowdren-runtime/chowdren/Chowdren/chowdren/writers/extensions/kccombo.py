from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

from mmfparser.bitdict import BitDict
from mmfparser.data.font import LogFont

class ComboBox(ObjectWriter):
    class_name = 'ComboBox'
    filename = 'combobox'

    def write_init(self, writer):
        pass

actions = make_table(ActionMethodWriter, {
    5 :  'reset',
    6 : 'add_line',
    9 : 'set_current_line',
    11 : 'set_visible(false)',
    10 : 'set_visible(true)',
    14 : 'dehighlight',
    21 : 'lose_focus'
})

conditions = make_table(ConditionMethodWriter, {
    5 : 'is_list_dropped',
})

expressions = make_table(ExpressionMethodWriter, {
    0 : 'get_current_line_number',
    1 : 'get_current_line',
    4 : 'get_line',
    16 : 'find_string_exact'
})

def get_object():
    return ComboBox
