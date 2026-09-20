from chowdren.writers.objects import ObjectWriter
from chowdren.common import (get_animation_name, to_c,
    make_color, get_color_tuple)
from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table, EmptyAction)
from mmfparser.data.font import LogFont
from mmfparser.bitdict import BitDict

COLORS = {
    0 : (0xC8, 0xC8, 0xC8),
    1 : (0x00,0x00,0x00),
    2 : (0x99,0xb4,0xd1),
    3 : (0xbf,0xcd,0xdb), #SystemColor.activeCaptionBorder,
    4 : (0xf0,0xf0,0xf0),
    5 : (0xff,0xff,0xff),
    6 : (0x64,0x64,0x64), #SystemColor.inactiveCaptionBorder,
    7 : (0x00,0x00,0x00),
    8 : (0x00,0x00,0x00),
    9 : (0x00,0x00,0x00),
    10 : (0xb4,0xb4,0xb4), #new
    11 : (0xf4,0xf7,0xfc), #new
    12 : (0xab,0xab,0xab), #mdi one, doesn't quite match. There is no java mdi background colour./ AppWorksapce
    13 : (0x33,0x99,0xff), #SystemColor.textText,
    14 : (0xff,0xff,0xff),  #new  #SystemColor.textHighlight,
    15 : (0xf0,0xf0,0xf0), #SystemColor.textHighlightText,
    16 : (0xa0,0xa0,0xa0), #SystemColor.textInactiveText,
    17 : (0x80,0x80,0x80),
    18 : (0x00,0x00,0x00),
    19 : (0x43,0x4e,0x54),
    20 : (0xff,0xff,0xff),
    21 : (0x69,0x69,0x69),
    22 : (0xe3,0xe3,0xe3),
    23 : (0x00,0x00,0x00),
    24 : (0xff,0xff,0xe1),
}

def get_system_color(index):
    if index == 0xFFFF:
        return None
    if index & (1 << 31) != 0:
        return get_color_tuple(index)
    try:
        return COLORS[index]
    except KeyError:
        return (0, 0, 0)

def read_system_color(reader):
    return get_system_color(reader.readInt(True))

FLAGS = BitDict(
    'AlignTop',
    'AlignVerticalCenter',
    'AlignBottom',
    None,
    'AlignLeft',
    'AlignHorizontalCenter',
    'AlignRight',
    None,
    'Multiline',
    'NoPrefix',
    'EndEllipsis',
    'PathEllipsis',
    'Container',
    'Contained',
    'Hyperlink',
    None,
    'AlignImageTopLeft',
    'AlignImageCenter',
    'AlignImagePattern',
    None,
    'Button',
    'Checkbox',
    'ShowButtonBorder',
    'ImageCheckbox',
    'HideImage',
    'ForceClipping',
    None,
    None,
    'ButtonPressed',
    'ButtonHighlighted',
    'Disabled'
)

NONE, HYPERLINK, BUTTON, CHECKBOX = xrange(4)

class SystemBox(ObjectWriter):
    class_name = 'SystemBox'
    filename = 'systembox'
    use_alterables = True
    default_instance = 'default_systembox_instance'

    def write_init(self, writer):
        data = self.get_data()
        # data.skipBytes(4)

        width = data.readShort(True)
        height = data.readShort(True)
        writer.putlnc('width = %s;', width)
        writer.putlnc('height = %s;', height)

        flags = FLAGS.copy()
        flags.setFlags(data.readInt())
        self.show_border = flags['ShowButtonBorder']
        self.image_checkbox = flags['ImageCheckbox']
        if flags['Hyperlink']:
            display_type = HYPERLINK
        elif flags['Button']:
            if flags['Checkbox']:
                display_type = CHECKBOX
            else:
                display_type = BUTTON
        else:
            display_type = NONE
        align_top_left = flags['AlignImageTopLeft']
        align_center = flags['AlignImageCenter']
        pattern = flags['AlignImagePattern']
        fill = read_system_color(data)
        border1 = read_system_color(data)
        border2 = read_system_color(data)
        self.image = data.readShort()

        if self.image == -1:
            writer.putln('image = NULL;')
            writer.putlnc('blend_color = %s;', make_color(fill))
        else:
            writer.putln('image = %s;' % self.converter.get_image(self.image))
            if pattern:
                writer.putln('type = PATTERN_IMAGE;')
            elif align_center:
                writer.putln('type = CENTER_IMAGE;')
            elif align_top_left:
                writer.putln('type = TOPLEFT_IMAGE;')
            else:
                raise NotImplementedError()

        data.skipBytes(2) # rData_wFree
        text_color = read_system_color(data)
        margin_left = data.readShort()
        margin_top = data.readShort()
        margin_right = data.readShort()
        margin_bottom = data.readShort()

        font = LogFont(data, old=True)
        data.skipBytes(40) # file.readStringSize(40)
        data.adjust(8)
        text = data.readReader(data.readInt(True)).readString().rsplit('\\n',
                                                                       1)
        if len(text) == 1:
            text, = text
            tooltip = None
        else:
            text, tooltip = text
        new_width = width - margin_left - margin_right
        new_height = height - margin_top - margin_bottom

        if text:
            writer.putlnc('text = %r;', text)

        if flags['AlignTop']:
            y_align = 'top'
        elif flags['AlignVerticalCenter']:
            y_align = 'center'
        elif flags['AlignBottom']:
            y_align = 'bottom'

        if flags['AlignLeft']:
            x_align = 'left'
        elif flags['AlignHorizontalCenter']:
            x_align = 'center'
        elif flags['AlignRight']:
            x_align = 'right'

        version = data.readInt()
        hyperlink_color = read_system_color(data)

    def get_images(self):
        if self.image == -1:
            return ()
        return (self.image,)

actions = make_table(ActionMethodWriter, {
    0 : 'set_size',
    1 : 'set_global_position',
    6 : 'hide_fill',
    22 : 'hide_border_1',
    31 : 'hide_border_2',
    # actually system colors
    51 : 'set_fill(Color(%s))',
    52 : 'set_border_1(Color(%s))',
    53 : 'set_border_2(Color(%s))',
    54 : EmptyAction, # set text color, other
    55 : 'set_text',
    62 : 'set_visible(true)',
    63 : 'set_visible(false)'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    29 : '.text',
    31 : '.width',
    32 : '.height',
    34 : 'get_x()',
    35 : 'get_y()'
})

def get_object():
    return SystemBox
