from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ConditionMethodWriter,
    ActionMethodWriter, ExpressionMethodWriter, make_table,
    TrueCondition, FalseCondition, EmptyAction)

class SimpleActive(ObjectWriter):
    class_name = 'SteamObject'
    update = False
    filename = 'steamext'

    def write_init(self, writer):
        pass

actions = make_table(ActionMethodWriter, {
})

conditions = make_table(ConditionMethodWriter, {
    0 : 'is_activated'
})

expressions = make_table(ExpressionMethodWriter, {
})

def get_object():
    return SimpleActive