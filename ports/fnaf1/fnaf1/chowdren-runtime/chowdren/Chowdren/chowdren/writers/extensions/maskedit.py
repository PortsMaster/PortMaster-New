from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ConditionMethodWriter,
    ActionMethodWriter, ExpressionMethodWriter, make_table, EmptyAction)

class MaskedText(ObjectWriter):
    class_name = 'MaskedText'
    filename = 'maskedtext'

    def write_init(self, writer):
        pass

actions = make_table(ActionMethodWriter, {
    8 : EmptyAction, # set focus on
    16 : EmptyAction, # go to pos
    11 : '.text = %s'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    4 : '.text'
})

def get_object():
    return MaskedText
