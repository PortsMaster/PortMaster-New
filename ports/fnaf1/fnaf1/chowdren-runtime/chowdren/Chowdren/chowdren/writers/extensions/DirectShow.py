from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ConditionMethodWriter,
    ActionMethodWriter, ExpressionMethodWriter, make_table, EmptyAction,
    ComparisonWriter, make_comparison)

class DirectShow(ObjectWriter):
    class_name = 'DirectShow'
    filename = 'directshow'
    use_alterables = True

    def write_init(self, writer):
        pass

actions = make_table(ActionMethodWriter, {
    0 : 'load',
    2 : 'play',
    4 : 'set_width',
    5 : 'set_height',
    20 : 'set_visible(true)'
})

conditions = make_table(ConditionMethodWriter, {
    0 : 'is_playing',
    2 : make_comparison('get_time()'),
})

expressions = make_table(ExpressionMethodWriter, {
    2 : 'get_duration()',
    3 : 'get_time()'
})

def get_object():
    return DirectShow
