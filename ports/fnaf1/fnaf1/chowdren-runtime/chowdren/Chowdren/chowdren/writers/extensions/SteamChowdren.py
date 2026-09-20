from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ConditionMethodWriter,
    ActionMethodWriter, ExpressionMethodWriter, make_table)

class SteamObject(ObjectWriter):
    class_name = 'SteamObject'
    filename = 'steamext'
    update = True

    def write_init(self, writer):
        pass

    def has_sleep(self):
        return False

actions = make_table(ActionMethodWriter, {
    0 : 'unlock_achievement'
})

conditions = make_table(ConditionMethodWriter, {
    0 : 'is_achievement_unlocked',
    1 : 'is_ready'
})

expressions = make_table(ExpressionMethodWriter, {
})

def get_object():
    return SteamObject