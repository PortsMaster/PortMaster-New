from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

class GetObject(ObjectWriter):
    class_name = 'HTTPObject'
    filename = 'http'
    update = True

    def write_init(self, writer):
        pass

    def has_sleep(self):
        return False

class AlwaysCondition(ConditionMethodWriter):
    is_always = True

actions = make_table(ActionMethodWriter, {
    0 : 'get',
    1 : 'add_post'
})

conditions = make_table(AlwaysCondition, {
    0 : '.done'
})

expressions = make_table(ExpressionMethodWriter, {
    0 : '.value'
})

def get_object():
    return GetObject
