from chowdren.writers.objects import ObjectWriter
from mmfparser.bitdict import BitDict

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ComparisonWriter, StaticActionWriter,
    StaticConditionWriter, StaticExpressionWriter, make_table)

class MoveIt(ObjectWriter):
    class_name = 'MoveIt'
    filename = 'moveit'
    defines = ['CHOWDREN_USE_MOVEIT']
    update = True

    def write_init(self, writer):
        pass

    def has_sleep(self):
        return False

class StopMovement(StaticActionWriter):
    custom = True

    def write(self, writer):
        obj = (self.parameters[0].loader.objectInfo,
               self.parameters[0].loader.objectType)
        list_name = self.converter.create_list(obj, writer)
        writer.putc('MoveIt::stop(%s);', list_name)

class AddQueue(StaticActionWriter):
    custom = True

    def write(self, writer):
        obj = (self.parameters[0].loader.objectInfo,
               self.parameters[0].loader.objectType)
        for item in self.converter.resolve_qualifier(obj):
            obj_writer = self.converter.get_object_writer(item)
            obj_writer.has_shoot = True
        list_name = self.converter.create_list(obj, writer)
        writer.putc('MoveIt::add_queue(%s);', list_name)

actions = make_table(StaticActionWriter, {
    0 : 'move',
    4 : StopMovement,
    5 : AddQueue,
    6 : 'clear_queue'
})

conditions = make_table(StaticConditionWriter, {
})

expressions = make_table(StaticExpressionWriter, {
})

def get_object():
    return MoveIt
