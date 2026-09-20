from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, StaticExpressionWriter, make_table,
    ActionWriter, ActionMethodWriter, ConditionMethodWriter,
    ExpressionMethodWriter, EmptyAction)

class DialogBox(ObjectWriter):
    class_name = 'DialogBox'
    static = True

    def write_init(self, writer):
        pass

actions = make_table(ActionMethodWriter, {
    0 : EmptyAction,
    11 : 'std::cout << ({1}) << std::endl'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
})

def get_object():
    return DialogBox
