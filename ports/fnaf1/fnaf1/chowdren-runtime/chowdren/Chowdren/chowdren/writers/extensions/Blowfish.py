from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, StaticExpressionWriter, make_table, EmptyAction,
    ExpressionMethodWriter)

class BlowfishObject(ObjectWriter):
    class_name = 'BlowfishObject'
    filename = 'blowfishext'
    static = True
    defines = ['CHOWDREN_USE_BLOWFISH_CACHE']

    def write_init(self, writer):
        pass

actions = make_table(StaticActionWriter, {
    0 : EmptyAction,
    7 : 'encrypt_file',
    8 : 'decrypt_file'
})

conditions = make_table(StaticConditionWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
})

def get_object():
    return BlowfishObject
