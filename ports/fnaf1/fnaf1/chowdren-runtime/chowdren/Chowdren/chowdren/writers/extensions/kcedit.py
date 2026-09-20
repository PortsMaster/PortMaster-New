from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)
from mmfparser.data.font import LogFont
from mmfparser.bitdict import BitDict

EDIT_FLAGS = BitDict(
    'HorizontalScrollbar',
    'HorizontalAutoscroll',
    'VerticalScrollbar',
    'VerticalAutoscroll',
    'ReadOnly',
    'Multiline',
    'Password',
    'Border',
    'HideOnStart',
    'Uppercase',
    'Lowercase',
    'Tabstop',
    'SystemColor',
    '3DLook',
    'Transparent',
    None,
    'AlignCenter',
    'AlignRight'
)

class EditObject(ObjectWriter):
    class_name = 'EditObject'
    filename = 'editext'

    def write_init(self, writer):
        if not self.has_updates():
            return
        data = self.get_data()
        width = data.readShort(True)
        height = data.readShort(True)
        logFont = LogFont(data, old = True)
        data.skipBytes(4 * 16) # custom colors?
        foregroundColor = data.readColor()
        backgroundColor = data.readColor()
        data.skipBytes(40) # text-style?
        flags = EDIT_FLAGS.copy()
        flags.setFlags(data.readInt())

        writer.putlnc('width = %s;', width)
        writer.putlnc('height = %s;', height)
        if flags['Password']:
            writer.putlnc('edit_flags |= PASSWORD;')

    @staticmethod
    def write_application(converter):
        if not converter.config.use_edit_obj():
            return
        converter.add_define('CHOWDREN_USE_EDITOBJ')

    def has_updates(self):
        return self.converter.config.use_edit_obj()

actions = make_table(ActionMethodWriter, {
    4 : 'set_text',
    13 : 'set_visible(false)',
    12 : 'set_visible(true)',
    16 : 'enable_focus',
    23 : 'set_limit',
    30 : 'disable_focus'
})

conditions = make_table(ConditionMethodWriter, {
    4 : 'get_focus'
})

expressions = make_table(ExpressionMethodWriter, {
    0 : 'get_text()'
})

def get_object():
    return EditObject