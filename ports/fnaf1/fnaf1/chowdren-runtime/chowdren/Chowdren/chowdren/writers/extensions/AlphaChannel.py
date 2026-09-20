from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table, EmptyAction,
    make_comparison)

class AlphaImageObject(ObjectWriter):
    class_name = 'AlphaImageObject'
    filename = 'alphaimage'
    use_alterables = True

    def write_init(self, writer):
        data = self.get_data()
        data.skipBytes(4)
        width = data.readShort()
        height = data.readShort()


        pos = data.tell()
        data.seek(4104)
        image_count = data.readShort()
        data.seek(pos)

        images = []
        for _ in xrange(image_count):
            images.append(data.readShort())

        alpha_images = []
        for index, image in enumerate(images[::2]):
            image = self.converter.game.images.itemDict[image]
            width = image.width
            height = image.height
            alpha_images.append('AlphaImage(%s, %s)' % (width, height))

        writer.putlnc('image_count = %s;', len(alpha_images))
        if images:
            writer.putlnc('static AlphaImage static_images[%s] = {%s};',
                          len(alpha_images), ', '.join(alpha_images))
            writer.putln('images = &static_images[0];')
            writer.putlnc('set_image(0);')


actions = make_table(ActionMethodWriter, {
    0 : 'set_image',
    8 : '.anim_frame = %s',
    14 : '.angle = %s',
    32 : 'blend_color.set_alpha',
    33 : EmptyAction, # load image from png
    15 : 'set_width',
    16 : 'set_height',
    17 : 'set_scale_x(%s / 100.0)',
    18 : 'set_scale_y(%s / 100.0)',
    20 : 'set_hotspot'
})

conditions = make_table(ConditionMethodWriter, {
    5 : make_comparison('index')
})

expressions = make_table(ExpressionMethodWriter, {
    0 : '.index',
    8 : '.image->width',
    9 : '.image->height',
    12 : '.angle',
    13 : 'get_width()',
    14 : 'get_height()',
    15 : '.blend_color.a'
})

def get_object():
    return AlphaImageObject
