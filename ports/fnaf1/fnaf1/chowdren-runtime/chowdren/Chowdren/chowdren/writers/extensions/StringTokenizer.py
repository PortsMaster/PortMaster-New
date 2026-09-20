from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

class StringTokenizer(ObjectWriter):
    class_name = 'StringTokenizer'
    filename = 'stringtokenizer'

actions = make_table(ActionMethodWriter, {
    0 : 'split'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    1 : 'get',
    0 : 'get_count()'
})

def get_object():
    return StringTokenizer