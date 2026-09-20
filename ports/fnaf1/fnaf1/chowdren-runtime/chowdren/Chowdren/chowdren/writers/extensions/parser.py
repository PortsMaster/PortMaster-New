from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

class StringParser(ObjectWriter):
    class_name = 'StringParser'
    filename = 'stringparser'

    def write_init(self, writer):
        pass

actions = make_table(ActionMethodWriter, {
    0 : 'set',
    2 : 'load',
    5 : 'reset_delimiters',
    6 : 'add_delimiter'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    0 : '.value',
    1 : '.value.size()',
    9 : 'remove',
    10 : 'replace',
    24 : 'get_count()',
    25 : 'set_element',
    29 : 'get_element',
    30 : 'get_element(1)',
    31 : 'get_last_element()',
    41 : 'get_md5()'
})

def get_object():
    return StringParser
