from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

from mmfparser.bitdict import BitDict
from mmfparser.data.font import LogFont

class KcList(ObjectWriter):
    class_name = 'ListObject'
    filename = 'listext'

    def write_init(self, writer):
        data = self.get_data()
        flags = BitDict(
            'FreeFlag',
            'VerticalScrollbar',
            'Sort',
            'Border',
            'HideOnStart',
            'SystemColor',
            '3DLook',
            'ScrollToNewline'
        )
        width = data.readShort()
        height = data.readShort()
        is_unicode = self.data.settings.get('unicode', False)
        font = self.data.new(LogFont, data, old=not is_unicode)
        font_color = data.readColor()
        self.data.readString(data, 40)
        
        data.skipBytes(16 * 4)
        back_color = data.readColor()
        flags.setFlags(data.readInt())
        line_count = data.readShort(True)
        index_offset = -1 if data.readInt() == 1 else 0
        data.skipBytes(4 * 3)
        lines = []
        for _ in xrange(line_count):
            line = self.data.readString(data)
            writer.putln(to_c('add_line(%r);', line))

        if flags['HideOnStart']:
            writer.putln('set_visible(false);')

        if flags['Sort']:
            writer.putln('list_flags |= SORT_LIST;')

        writer.putlnc('index_offset = current_line = %s;', index_offset)

actions = make_table(ActionMethodWriter, {
    0 : 'load_file',
    5 : 'clear',
    6 : 'add_line',
    8 : 'delete_line',
    9 : '.current_line = %s',
    21 : 'disable_focus',
    30 : 'set_line(%s, %s)'
})

conditions = make_table(ConditionMethodWriter, {
    4 : 'get_focus'
})

expressions = make_table(ExpressionMethodWriter, {
    0 : '.current_line',
    1 : 'get_current_line()',
    4 : 'get_line',
    7 : 'get_count()',
    14 : 'find_string',
    15 : 'find_string_exact'
})

def get_object():
    return KcList