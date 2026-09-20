from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter, StaticActionWriter,
                                     StaticExpressionWriter,
                                     ExpressionMethodWriter,
                                     make_table, EmptyAction)

class ClockObject(ObjectWriter):
    class_name = 'ClockObject'
    static = True

    def write_init(self, writer):
        pass

actions = make_table(StaticActionWriter, {
})

conditions = make_table(StaticConditionWriter, {
})

class ClockExpression(ExpressionMethodWriter):
    has_object = False

expressions = make_table(ClockExpression, {
    1 : 'platform_get_datetime().sec',
    2 : 'platform_get_datetime().min',
    3 : 'platform_get_datetime().hour',
    5 : 'platform_get_datetime().mday', # day of month
    6 : 'platform_get_datetime().mon', # month
    7 : 'platform_get_datetime().year' # retrieve year
})

def get_object():
    return ClockObject
