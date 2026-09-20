from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, StaticExpressionWriter, make_table, EmptyAction,
    TrueCondition)

class FileStream(ObjectWriter):
    class_name = 'FileStream'
    static = True

    def write_init(self, writer):
        pass

actions = make_table(StaticActionWriter, {
    0 : EmptyAction, # open filestream
    1 : EmptyAction, # close stream
    2 : EmptyAction, # set byte
})

conditions = make_table(StaticConditionWriter, {
    1 : TrueCondition
})

expressions = make_table(StaticExpressionWriter, {
})

def get_object():
    return FileStream
