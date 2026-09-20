from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

from mmfparser.bitdict import BitDict
from mmfparser.data.font import LogFont

class ScrollbarObject(ObjectWriter):
    class_name = 'ScrollbarObject'
    filename = 'scrollbarext'

    def write_init(self, writer):
        data = self.get_data()
        width = data.readShort(True)
        height = data.readShort(True)
        #hidden = data.readByte() != 0
        #enabled = data.readByte() != 0
        #tab_stop = data.readByte() != 0
        data.skipBytes(3)
        vertical = data.readByte() != 0
        min_val = data.readInt(True)
        max_val = data.readInt(True)
        val = data.readInt(True)
        # Last 4 bytes are always '4 0 0 0' (?)

        writer.putlnc('width = %s;', width)
        writer.putlnc('height = %s;', height)
        writer.putlnc('vertical = %s;', vertical)
        writer.putlnc('min_val = %s;', min_val)
        writer.putlnc('max_val = %s;', max_val)
        writer.putlnc('val = %s;', val)


    def has_updates(self):
        return True


actions = make_table(ActionMethodWriter, {
    1 : 'set_scroll_range',
    9 : 'set_width',
    10 : 'set_height',
    11 : 'set_visible(true)',
    12 : 'set_visible(false)'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    0 : 'get_value'
})

def get_object():
    return ScrollbarObject
