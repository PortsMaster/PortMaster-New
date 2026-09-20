from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

class Viewport(ObjectWriter):
    class_name = 'Viewport'
    filename = 'viewport'
    defines = ['CHOWDREN_USE_VIEWPORT']
    use_alterables = True

    def write_init(self, writer):
        data = self.get_data()
        data.skipBytes(4)
        width = data.readShort()
        height = data.readShort()
        writer.putln('src_width = width = %s;' % width)
        writer.putln('src_height = height = %s;' % height)
        writer.putln('center_x = x + width / 2;')
        writer.putln('center_y = y + height / 2;')

actions = make_table(ActionMethodWriter, {
    0 : 'set_width',
    1 : 'set_height',
    3 : 'set_source'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
})

def get_object():
    return Viewport
