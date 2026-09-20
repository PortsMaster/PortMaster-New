from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

def fix_string(v):
    new = ''
    for c in v:
        if ord(c) < 10:
            break
        new += c
    return new

ANIMATION_NAMES = {
    0 : 'None',
    1 : 'Marquee',
    2 : 'Sin Wave',
    3 : 'Sin Scroller',
    4 : 'Cos Scroller',
    5 : 'Tan Scroller'
}

ANIM_NONE = 0
ANIM_MARQUEE = 1
ANIM_FLAG = 2
ANIM_SINSCROLL = 3
ANIM_COSSCROLL = 4
ANIM_TANSCROLL = 5

FLAGS_CALLBACK = 2048
FLAGS_CALLBACK_ONBEGIN = 4096
FLAGS_CALLBACK_ONEND = 8192
FLAGS_CALLBACK_ONBEGINL = 16384
FLAGS_CALLBACK_ONENDL = 32768
FLAGS_CALLBACK_ONCHAR = 65536
FLAGS_BALLOON = 131072
FLAGS_BALLOON_HINVERT = 262144
FLAGS_BALLOON_KEEPSCREEN = 524288
FLAGS_ANIM_EDGEFADE = 1
FLAGS_TRANSPARENT = 1
FLAGS_USETEXTFUNCS = 2
FLAGS_DRAWVERTICLE = 4
FLAGS_DEBUGON = 8
FLAGS_DRAWCHARINTERUPT = 16
FLAGS_WORDWRAPPING = 32
FLAGS_MULTILINE = 64
FLAGS_NOREDRAW = 128
FLAGS_VARIABLEWIDTH = 256
FLAGS_EDGEFADE = 1024

CHAR_CALLBACK_CONDITION = 8

class TextBlitter(ObjectWriter):
    class_name = 'TextBlitter'
    use_alterables = True
    update = True
    defines = ['CHOWDREN_USE_BLITTER']
    default_instance = 'default_blitter_instance'
    filename = 'textblitter'

    def initialize(self):
        self.has_callback = False
        self.read_data()
        if not self.converter.config.use_blitter_callback(self):
            return
        if not self.flags & (FLAGS_CALLBACK | FLAGS_CALLBACK_ONCHAR):
            return
        self.has_callback = True
        self.add_event_callback('call_char_callback')

    def write_frame(self, writer):
        if not self.has_callback:
            return
        if not self.converter.config.use_blitter_callback(self):
            return
        self.write_event_callback(
            'call_char_callback', writer,
            self.get_object_conditions(CHAR_CALLBACK_CONDITION))

    def read_data(self):
        data = self.get_data()
        data.skipBytes(4)
        self.width = data.readShort()
        self.height = data.readShort()
        data.skipBytes(128)
        data.skipBytes(4)
        self.text = fix_string(data.read(1024))
        data.skipBytes(256)
        self.trans_color = data.readColor()
        self.char_size = (data.readInt(), data.readInt())
        self.char_spacing = (data.readInt(), data.readInt())
        self.char_offset = data.readInt() % 255
        self.image_size = (data.readInt(), data.readInt())
        self.image_offset = (data.readInt(), data.readInt())
        self.flags = data.readInt()
        self.tab_width = data.readInt()
        self.image = data.readShort()
        self.character_map = fix_string(data.read(256))
        data.skipBytes(256)
        data.skipBytes(4096)
        data.skipBytes(1024)
        data.skipBytes(2)
        self.left = data.readInt()
        self.top = data.readInt()
        self.right = data.readInt()
        self.bottom = data.readInt()
        self.horizontal_align = data.readInt()
        self.vertical_align = data.readInt()
        data.skipBytes(4)

        # read animation
        self.animation_type = data.readByte()
        data.skipBytes(3)
        self.animation_speed = data.readInt()
        self.speed_count = data.readInt()
        self.param = [data.readInt() for _ in xrange(16)]
        self.options = data.readInt()
        self.p1 = data.readInt()

        self.ball_left = data.readInt()
        self.ball_top = data.readInt()
        self.ball_right = data.readInt()
        self.ball_bottom = data.readInt()
        self.ball_source = (data.readInt(), data.readInt())
        self.ball_min = (data.readInt(), data.readInt())
        self.ball_max = (data.readInt(), data.readInt())

    def write_init(self, writer):
        type_name = ANIMATION_NAMES[self.animation_type]

        if type_name not in ('None', 'Sin Wave'):
            print 'invalid blitter animation: %s' % type_name
            # raise NotImplementedError('invalid blitter animation: %s'
            #                           % type_name)

        if type_name == 'Sin Wave':
            writer.putln('anim_type = BLITTER_ANIMATION_SINWAVE;')
            writer.putlnc('anim_frame = 0;')
            writer.putlnc('anim_speed = %s;', self.animation_speed)
            writer.putlnc('wave_freq = %s;', self.param[1])
            writer.putlnc('wave_height = %s;', self.param[2])

        writer.putln('width = %s;' % self.width)
        writer.putln('height = %s;' % self.height)
        writer.putln('char_width = %s;' % self.char_size[0])
        writer.putln('char_height = %s;' % self.char_size[1])
        writer.putlnc('x_spacing = %s;', self.char_spacing[0])
        writer.putlnc('y_spacing = %s;', self.char_spacing[1])
        writer.putlnc('char_offset = %s;', self.char_offset)
        writer.putlnc('x_off = %s;', self.image_offset[0])
        writer.putlnc('y_off = %s;', self.image_offset[1])
        writer.putln('image = %s;' % self.converter.get_image(self.image))
        writer.putlnc('image_width = %s;', self.image_size[0])
        align_flags = []
        if self.horizontal_align == 0:
            align_flags.append('ALIGN_LEFT')
        elif self.horizontal_align == 1:
            align_flags.append('ALIGN_HCENTER')
        elif self.horizontal_align == 2:
            align_flags.append('ALIGN_RIGHT')
        if self.vertical_align == 0:
            align_flags.append('ALIGN_TOP')
        elif self.vertical_align == 1:
            align_flags.append('ALIGN_VCENTER')
        elif self.vertical_align == 2:
            align_flags.append('ALIGN_BOTTOM')
        if not align_flags:
            align_flags.append('0')
        writer.putln('alignment = %s;' % ' | '.join(align_flags))
        writer.putln('static int charmap[256];')
        writer.putln('static bool initialized = false;')
        writer.putln('this->charmap = &charmap[0];')
        interned_map = self.converter.intern_string(self.character_map)
        writer.putlnc('charmap_str = &%s;', interned_map)
        writer.putln('if (!initialized) {')
        writer.indent()
        writer.putln('initialized = true;')
        writer.putln('initialize(*charmap_str);')
        writer.end_brace()
        # other data
        if self.flags & FLAGS_TRANSPARENT:
            writer.putlnc('transparent_color = %s;',
                          make_color(self.trans_color))

        writer.putlnc('wrap = %s;', bool(self.flags & FLAGS_WORDWRAPPING))
        writer.putlnc('set_text(%r);', self.text)

        writer.putlnc('has_callback = %s;', self.has_callback)

    def is_static_background(self):
        return False


class ASCIIValue(ExpressionMethodWriter):
    has_object = False
    method = 'get_ascii'


actions = make_table(ActionMethodWriter, {
    0 : 'set_text',
    4 : 'set_char_width',
    5 : '.char_height = %s',
    6 : '.char_offset = %s',
    7 : 'set_charmap',
    13 : 'load',
    17 : '.x_off = %s',
    18 : '.y_off = %s',
    19 : '.transparent = true;',
    36 : 'set_x_align',
    37 : 'set_y_align',
    42 : 'set_x_scroll',
    43 : 'set_y_scroll',
    44 : 'set_x_spacing',
    45 : 'set_y_spacing',
    49 : 'append_text',
    50 : 'set_animation_speed',
    51 : 'set_animation_type',
    52 : 'set_animation_parameter',
    56 : 'set_transparent_color',
    57 : 'replace_color',
    58 : 'set_width',
    59 : 'set_height',
    66 : '.callback_transparency = %s'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    0 : 'get_text()',
    1 : '.char_width',
    2 : '.char_height',
    4 : 'get_charmap()',
    5 : '.image->width',
    6 : '.image->height',
    9 : 'get_x_align()',
    10 : 'get_y_align()',
    16 : '.y_scroll',
    17 : '.x_spacing',
    18 : '.y_spacing',
    21 : '.width',
    22 : '.height',
    23 : ASCIIValue,
    32 : 'get_line_count()',
    33 : 'get_line',
    34 : '.x_off',
    35 : '.y_off',
    37 : '.anim_type',
    42 : 'get_map_char',
    43 : '.callback_char',
    44 : '.callback_line',
    46 : '.callback_line_count'
})

def get_object():
    return TextBlitter
