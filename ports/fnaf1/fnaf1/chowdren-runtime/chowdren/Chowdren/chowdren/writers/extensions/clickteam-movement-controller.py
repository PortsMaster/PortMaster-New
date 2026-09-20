from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, StaticExpressionWriter, make_table,
    EmptyAction, ActionMethodWriter, ExpressionMethodWriter)

class AdvancedDirection(ObjectWriter):
    class_name = 'AdvancedDirection'
    filename = 'advdir'

class SetObject(EmptyAction):
    def write(self, writer):
        obj = (self.parameters[0].loader.objectInfo,
               self.parameters[0].loader.objectType)
        self.converter.event_settings['movement_obj'] = obj

class ControllerAction(ActionMethodWriter):
    def get_object(self):
        obj = self.converter.event_settings.get('movement_obj', (None, None))
        return obj

class SetVectorSpeed(ControllerAction):
    method = 'get_movement()->set_speed'

class VectorLookAt(ControllerAction):
    method = 'get_movement()->look_at'

class GetDistance(ExpressionMethodWriter):
    method = 'get_distance'
    has_object = False

actions = make_table(StaticActionWriter, {
    51 : VectorLookAt,
    56 : SetVectorSpeed,
    74 : SetObject
})

conditions = make_table(StaticConditionWriter, {
})

expressions = make_table(StaticExpressionWriter, {
    56 : GetDistance,
    57 : 'get_object_angle'
})

def get_object():
    return AdvancedDirection
