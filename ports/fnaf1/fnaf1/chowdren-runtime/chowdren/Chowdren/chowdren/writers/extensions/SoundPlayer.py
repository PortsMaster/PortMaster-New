from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ActionMethodWriter, ConditionMethodWriter,
    ExpressionMethodWriter, make_table)

class Util(ObjectWriter):
    class_name = 'Utility'
    static = True

    def write_init(self, writer):
        pass

actions = make_table(ActionMethodWriter, {
    0 : 'media.play_name(%s, %s-1, %s)',
    1 : 'media.play_name(%s, %s-1)',
    3 : 'media.add_file'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
})

def get_object():
    return Util