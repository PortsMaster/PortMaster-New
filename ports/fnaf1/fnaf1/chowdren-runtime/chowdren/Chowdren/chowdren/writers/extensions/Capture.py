from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, StaticExpressionWriter, make_table)

class CaptureObject(ObjectWriter):
    class_name = 'CaptureObject'
    filename = 'capture'
    static = True
    defines = ['CHOWDREN_USE_CAPTURE']

    def write_init(self, writer):
        pass

actions = make_table(StaticActionWriter, {
    0 : 'set_filename',
    4 : 'capture_window',
    5 : 'capture_frame',
    6 : 'set_origin',
    7 : 'set_size'
})

conditions = make_table(StaticConditionWriter, {
})

expressions = make_table(StaticExpressionWriter, {
})

def get_object():
    return CaptureObject
