from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table,
    EmptyAction)
from mmfparser.data.font import LogFont


class ColorizerObject(ObjectWriter):
    class_name = 'ColorizerObject'
    filename = 'colorizer'
    use_alterables = True

    def write_init(self, writer):
        pass

actions = make_table(ActionMethodWriter, {
    29 : EmptyAction, # load mask from overlay/surface
    32 : EmptyAction, # change mask mode
    0 : 'set_red', # set red out of old red
    4 : 'set_green', # set green out of old green,
    8 : 'set_blue' # set blue out of old blue
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    2 : '.r', # red out of red,
    6 : '.g', # green out of old green
    10 : '.b' # blue out of old blue
})

def get_object():
    return ColorizerObject
