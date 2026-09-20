from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)
from mmfparser.bitdict import BitDict

class ActivePicture(ObjectWriter):
    class_name = 'ActivePicture'
    filename = 'picture'
    use_alterables = True
    default_instance = 'default_picture_instance'

    def write_init(self, writer):
        data = self.get_data()
        width = data.readInt()
        height = data.readInt()
        self.flags = BitDict(
            'Resize',
            'HideOnStart',
            'TransparentBlack',
            'TransparentFirstPixel',
            'FlippedHorizontally',
            'FlippedVertically',
            'Resample',
            'WrapModeOff',
        )
        self.flags.setFlags(data.readInt(True))
        visible = not self.flags['HideOnStart']
        transparent_color = data.readColor()
        if not self.flags['TransparentFirstPixel']:
            writer.putln('set_transparent_color(%s);' %
                         make_color(transparent_color))
        image = data.readString(260) or None
        writer.putlnc('sprite_col.width = width = %s;', width)
        writer.putlnc('sprite_col.height = height = %s;', height)
        # objects_file.putdef('filename', image)

actions = make_table(ActionMethodWriter, {
    0 : 'load',
    2 : 'set_hotspot',
    3 : 'set_size',
    11 : 'set_hotspot_mul(1.0f, 0.5f)',
    9 : 'set_hotspot_mul(0.0f, 0.5f)',
    10 : 'set_hotspot_mul(0.5f, 0.5f)',
    13 : 'set_hotspot_mul(0.5f, 1.0f)',
    26 : 'paste',
    15 : 'flip_horizontal',
    4 : 'set_angle',
    29 : 'set_zoom'
})

conditions = make_table(ConditionMethodWriter, {
    0 : '.image != NULL'
})

expressions = make_table(ExpressionMethodWriter, {
    1 : 'get_width()',
    2 : 'get_height()',
    9 : '.angle',
    13 : 'get_zoom_x()'
})

def get_object():
    return ActivePicture