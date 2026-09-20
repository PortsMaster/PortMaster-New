from kcpica import ActivePicture
from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

class BackgroundPicture(ActivePicture):
    def is_static_background(self):
        return False

    def is_background_collider(self):
        # also:
        # ObstaclePlatform, both ObstaclePlatform and ObstascleSolid: Ladder
        return self.common.newFlags['ObstacleSolid']

actions = make_table(ActionMethodWriter, {
    0 : 'load'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    0 : '.filename'
})

def get_object():
    return BackgroundPicture
