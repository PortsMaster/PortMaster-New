from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (StaticConditionWriter, StaticActionWriter,
                                     StaticExpressionWriter, ExpressionWriter,
                                     make_table)

class ImageManipulator(ObjectWriter):
    class_name = 'ImageManipulator'
    filename = 'imageconv'
    static = True

    def write_init(self, writer):
        pass

actions = make_table(StaticActionWriter, {
    4 : 'save',
    7 : 'load',
    23 : 'apply_gauss_blur'
})

conditions = make_table(StaticConditionWriter, {
})

expressions = make_table(StaticExpressionWriter, {
})

def get_object():
    return ImageManipulator
