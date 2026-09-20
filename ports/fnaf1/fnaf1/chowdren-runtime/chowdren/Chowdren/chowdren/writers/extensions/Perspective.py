from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

class Perspective(ObjectWriter):
    class_name = 'PerspectiveObject'
    filename = 'perspective'

    def write_init(self, writer):
        data = self.get_data()
        data.skipBytes(4) # sx, sy - unused
        writer.putlnc('width = %s;', data.readShort())
        writer.putlnc('height = %s;', data.readShort())
        writer.putlnc('set_shader_parameter("effect", %s);', data.readByte())
        writer.putlnc('set_shader_parameter("direction", %s);',
                      data.readByte() != 0)
        data.skipBytes(2) # padding
        writer.putlnc('set_shader_parameter("zoom", %s);', data.readInt())
        writer.putlnc('set_shader_parameter("offset", %s);', data.readInt())
        writer.putlnc('set_shader_parameter("sine_waves", %s);', data.readInt())
        # writer.putlnc('set_shader_parameter("perspective_dir", %s);',
        #               data.readByte() != 0)

actions = make_table(ActionMethodWriter, {
    0 : 'set_zoom',
    5 : 'set_waves',
    6 : 'set_offset',
    12 : 'set_width'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    0 : '.get_shader_parameter("zoom")',
    1 : '.get_shader_parameter("offset")'
})
def get_object():
    return Perspective
