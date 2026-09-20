from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)
from mmfparser.data.font import LogFont


class SurfaceObject(ObjectWriter):
    class_name = 'SurfaceObject'
    filename = 'surface'
    use_alterables = True
    update = True

    def write_init(self, writer):
        data = self.get_data()
        width = data.readShort()
        height = data.readShort()
        writer.putlnc('width = %s;', width)
        writer.putlnc('height = %s;', height)
        width_def = data.readShort()
        height_def = data.readShort()

        images = []
        for _ in xrange(16):
            images.append(data.readShort())

        image_count = data.readShort()
        images = images[:image_count]

        load_first = data.readByte() != 0 # always true!
        use_abs = data.readByte() != 0
        threaded_io = data.readByte() != 0 # unused (I bet)
        keep_points = data.readByte() != 0 # unused
        multi_imgs = data.readByte() != 0
        disp_target = data.readByte() != 0
        select_last = data.readByte() != 0 # always false!

        data.skipBytes(3) # what is this

        font = LogFont(data)
        color = data.readColor()
        flags = data.readInt()

        writer.putlnc('display_selected = %s;', disp_target)
        writer.putlnc('use_abs_coords = %s;', use_abs)

        image_names = [self.converter.get_image(image) for image in images]

        if multi_imgs:
            if image_count == 0:
                writer.putln('images.resize(1);')
                writer.putln('images[0].reset(width, height);')
            else:
                writer.putlnc('images.resize(%s);', image_count)

            for i, image in enumerate(images):
                # non-blank images
                if image != -1:
                    writer.putlnc('images[%s].set_image(%s);', i,
                                  image_names[i])
                else:
                    writer.putlnc('images[%s].reset();', i)
        else:
            writer.putln('images.resize(1);')
            # single image
            if image_count > 0 and images[0] != -1:
                writer.putlnc('images[0].set_image(%s);', image_names[0])
            else:
                writer.putlnc('images[0].reset(width, height);')
        # load_first always true -> there will always be an image 0
        writer.putln('set_edit_image(0, true);')

class RGBOperation(ActionMethodWriter):
    custom = True

    def write(self, writer):
        exp = self.data.items[0].loader.items
        op = self.converter.convert_static_expression(exp)
        if op != '':
            raise NotImplementedError()

class ReverseColor(ExpressionMethodWriter):
    has_object = False
    method = 'reverse_color'

class LoadSuccess(ConditionMethodWriter):
    is_always = True
    method = '.load_failed'
    in_place = True

    def is_negated(self):
        return not ConditionMethodWriter.is_negated(self)

class LoadFailed(ConditionMethodWriter):
    is_always = True
    method = '.load_failed'
    in_place = True

actions = make_table(ActionMethodWriter, {
    1 : 'set_display_image',
    3 : 'clear',
    4 : 'create_alpha',
    6 : 'clear_alpha',
    10 : 'draw_line',
    13 : 'resize',
    15 : 'load',
    14 : 'save',
    19 : 'blit_alpha',
    21 : 'reverse_x',
    24 : 'set_transparent_color',
    26 : RGBOperation,
    29 : 'set_edit_image',
    30 : 'draw_polygon',
    31 : 'insert_point',
    38 : 'set_alpha_mode',
    39 : 'blend_color.set_semi_transparency(%s)',
    40 : 'set_effect', # by index
    41 : 'set_dest_pos',
    49 : 'blit',
    61 : 'apply_matrix',
    62 : 'blit_background',
    63 : 'blit_image',
    66 : 'set_dest_size',
    78 : 'resize_canvas',
    90 : 'blit', # blit external surface
    93 : 'scroll',
    115 : 'set_src_size',
    116 : 'set_stretch_mode',
    17 : 'add_image',
    119 : 'draw_rect',
    153 : 'load'
})

conditions = make_table(ConditionMethodWriter, {
    2 : LoadFailed,
    4 : LoadSuccess
})

expressions = make_table(ExpressionMethodWriter, {
    4 : 'get_edit_width()',
    5 : 'get_edit_height()',
    15 : 'get_image_width',
    25 : ReverseColor
})

def get_object():
    return SurfaceObject
