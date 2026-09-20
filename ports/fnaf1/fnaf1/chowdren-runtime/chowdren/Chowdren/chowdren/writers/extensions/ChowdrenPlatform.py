from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ConditionMethodWriter,
    ActionMethodWriter, ExpressionMethodWriter, make_table)

class ChowdrenPlatform(ObjectWriter):
    class_name = 'ChowdrenPlatform'
    static = True

    def write_init(self, writer):
        pass

class PlatformAction(ActionMethodWriter):
    has_object = False

actions = make_table(PlatformAction, {
    0 : 'platform_set_lightbar',
    1 : 'platform_reset_lightbar',
    2 : 'set_local'
})

conditions = make_table(ConditionMethodWriter,  {
})

expressions = make_table(ExpressionMethodWriter, {
})

def get_object():
    return ChowdrenPlatform
