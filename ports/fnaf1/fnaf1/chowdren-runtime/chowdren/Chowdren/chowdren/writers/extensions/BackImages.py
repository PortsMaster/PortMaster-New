from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ConditionMethodWriter,
    ActionMethodWriter, ExpressionMethodWriter, make_table, EmptyAction)

class BackImages(ObjectWriter):
    class_name = 'BackImages'
    filename = 'backimages'
    use_alterables = True
    default_instance = 'default_backimages_instance'

    def is_background(self):
        return False

    def write_init(self, writer):
        # XXX load x offset
        pass

actions = make_table(ActionMethodWriter, {
    6 : 'set_x',
    7 : 'set_y',
    8 : '.width = %s',
    9 : '.height = %s',
    16 : '.pattern = true',
    35 : 'set_visible(false)',
    36 : 'set_visible(true)',
    39  : 'blend_color.set_semi_transparency(%s)',
    50 : '.x_off = %s',
    51 : '.y_off = %s'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    2 : 'get_width',
    3 : 'get_x()',
    4 : 'get_y()',
    5 : '.width',
    6 : '.height',
    14 : '.x_off',
    15 : '.y_off'
})

def get_object():
    return BackImages
