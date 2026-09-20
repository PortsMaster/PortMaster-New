from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, StaticActionWriter,
    StaticConditionWriter, StaticExpressionWriter, make_table, EmptyAction)

class FontEmbed(ObjectWriter):
    class_name = 'FontEmbed'
    static = True

    def write_init(self, writer):
        pass

actions = make_table(StaticActionWriter, {
    0 : EmptyAction
})

conditions = make_table(StaticConditionWriter, {
})

expressions = make_table(StaticExpressionWriter, {
})

def get_object():
    return FontEmbed
