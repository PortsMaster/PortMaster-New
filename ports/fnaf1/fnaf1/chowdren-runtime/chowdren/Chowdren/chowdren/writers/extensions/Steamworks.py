from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ConditionMethodWriter,
    ActionMethodWriter, ExpressionMethodWriter, make_table,
    TrueCondition, FalseCondition, EmptyAction)

class SteamObject(ObjectWriter):
    static = True
    update = True

    def write_init(self, writer):
        pass

    def has_sleep(self):
        return False

actions = make_table(ActionMethodWriter, {
    0 : EmptyAction, # steamworks_set_achievement_0
    1 : EmptyAction, # steamworks_request_statistics_achievements_1
    2 : EmptyAction, # steamworks_set_int_statistic_2
    5 : EmptyAction, # steamworks_store_statistics_achievements_5
})

conditions = make_table(ConditionMethodWriter, {
    0 : FalseCondition,
    1 : TrueCondition
})

expressions = make_table(ExpressionMethodWriter, {
})

def get_object():
    return SteamObject