from chowdren.writers.objects import ObjectWriter
from chowdren.common import (get_animation_name, to_c, make_color)
from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table, EmptyAction)

class Parallaxer(ObjectWriter):
    class_name = 'Parallaxer'
    filename = 'parallaxer'

    def write_init(self, writer):
        pass

actions = make_table(ActionMethodWriter, {
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
})

def get_object():
    return Parallaxer
