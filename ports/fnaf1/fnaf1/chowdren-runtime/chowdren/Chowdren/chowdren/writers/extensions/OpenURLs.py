from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, StaticActionWriter,
    StaticConditionWriter, StaticExpressionWriter, make_table,
    ActionMethodWriter)

class OpenURL(ObjectWriter):
    class_name = 'OpenURL'
    static = True

    def write_init(self, writer):
        pass

class OpenAction(ActionMethodWriter):
    has_object = False
    method = 'open_url'

actions = make_table(StaticActionWriter, {
    0 : OpenAction
})

conditions = make_table(StaticConditionWriter, {
})

expressions = make_table(StaticExpressionWriter, {
})

def get_object():
    return OpenURL
