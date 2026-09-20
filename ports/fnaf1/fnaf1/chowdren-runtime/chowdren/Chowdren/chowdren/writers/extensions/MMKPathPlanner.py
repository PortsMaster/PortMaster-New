from chowdren.writers.objects import ObjectWriter
from mmfparser.bitdict import BitDict

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

class PathPlanner(ObjectWriter):
    class_name = 'PathPlanner'
    filename = 'pathplanner'
    defines = ['CHOWDREN_USE_PATHPLANNER']
    update = True

    def has_sleep(self):
        return False

    def write_init(self, writer):
        data = self.get_data()
        tile_size = data.readInt()
        start_x = data.readInt()
        start_y = data.readInt()
        width = data.readInt()
        height = data.readInt()

        writer.putlnc('tile_size = %s;', tile_size)
        writer.putlnc('map_width = %s;', (width / tile_size) + 1)
        writer.putlnc('map_height = %s;', (height / tile_size) + 1)
        writer.putlnc('create_map();')

class ObjectAction(ActionMethodWriter):
    custom = True
    use_planner = True

    def write(self, writer):
        obj = self.converter.get_object(self.get_object())
        writer.start_brace()
        if self.use_planner:
            writer.putlnc('PathPlanner * planner = %s;', obj)

        obj = self.parameters[0].loader
        obj = (obj.objectInfo, obj.objectType)

        with self.converter.iterate_object(obj, writer, copy=False):
            obj = self.converter.get_object(obj)
            if self.use_planner:
                writer.putc('planner->')
            else:
                writer.putc('PathPlanner::')
            self.write_action(writer, obj)

        writer.end_brace()

class AddAgents(ObjectAction):
    def write_action(self, writer, obj):
        writer.putc('add_agent(%s);', obj)

class AddObstacles(ObjectAction):
    def write_action(self, writer, obj):
        writer.putc('add_obstacle(%s);', obj)

class SetDestination(ObjectAction):
    use_planner = False

    def write_action(self, writer, obj):
        x = self.convert_index(1)
        y = self.convert_index(2)
        writer.putc('set_destination(%s, %s, %s);', obj, x, y)

class Orient(ObjectAction):
    use_planner = False

    def write_action(self, writer, obj):
        writer.putc('orient(%s);', obj)

class PlanPath(ObjectAction):
    use_planner = False

    def write_action(self, writer, obj):
        writer.putc('plan_path(%s);', obj)

# mmkpathplanner_3: Add agents
# mmkpathplanner_11: Look at next node
# mmkpathplanner_4: Add obstacle
# mmkpathplanner_6: Set destination
# mmkpathplanner_14: Plan path for single agent

# mmkpathplanner_0: Is agent at destination?
# mmkpathplanner_4: Agent wants to stop
# mmkpathplanner_6: Is agent NOT at destination?

actions = make_table(ActionMethodWriter, {
    3 : AddAgents,
    4 : AddObstacles,
    6 : SetDestination,
    11 : Orient,
    14 : PlanPath
})

class ObjectCondition(ConditionMethodWriter):
    def __init__(self, *arg, **kw):
        ConditionMethodWriter.__init__(self, *arg, **kw)
        self.obj = self.parameters[0].loader
        self.parameters = self.parameters[1:]

    def get_object(self):
        return (self.obj.objectInfo, self.obj.objectType)

conditions = make_table(ObjectCondition, {
    0 : 'agent->at_destination',
    4 : 'agent->is_stopping',
    6 : 'agent->not_at_destination'
})

expressions = make_table(ExpressionMethodWriter, {
})

def get_object():
    return PathPlanner
