from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table, TrueCondition)

class SetObject(ActionMethodWriter):
    def write(self, writer):
        object_info = (self.parameters[0].loader.objectInfo,
                       self.parameters[0].loader.objectType)
        writer.put('set_object(%s);' % self.converter.get_object(object_info))

def read_value(reader):
    data = reader.readString(16)
    for i, c in enumerate(data):
        if ord(c) < 10:
            return int(data[:i])
    return int(data)

TEST_OVERLAP_OBSTACLE = 0
TEST_OVERLAP_PLATFORM = 1

class PlatformObject(ObjectWriter):
    class_name = 'PlatformObject'
    filename = 'platformext'
    use_alterables = True
    update = True
    default_instance = 'default_platform_instance'

    def has_sleep(self):
        return False

    def initialize(self):
        self.add_event_callback('call_overlaps_obstacle')
        self.add_event_callback('call_overlaps_platform')

    def write_init(self, writer):
        data = self.get_data()
        data.skipBytes(8)
        writer.putln('max_x_vel = %s;' % read_value(data))
        writer.putln('max_y_vel = %s;' % read_value(data))
        writer.putln('x_accel = %s;' % read_value(data))
        writer.putln('x_decel = %s;' % read_value(data))
        writer.putln('gravity = %s;' % read_value(data))
        writer.putln('jump_strength = %s;' % read_value(data))
        writer.putln('jump_hold_height = %s;' % read_value(data))
        writer.putln('step_up = %s;' % read_value(data))
        writer.putln('slope_correction = %s;' % read_value(data))
        writer.putln(to_c('through_collision_top = %s;', data.readByte() == 1))
        writer.putln(to_c('jump_through = %s;', data.readByte() == 1))

    def write_frame(self, writer):
        self.write_event_callback(
            'call_overlaps_obstacle', writer,
            self.get_object_conditions(TEST_OVERLAP_OBSTACLE))

        self.write_event_callback(
            'call_overlaps_platform', writer,
            self.get_object_conditions(TEST_OVERLAP_PLATFORM))


actions = make_table(ActionMethodWriter, {
    0 : '.obstacle_collision = true',
    1 : '.platform_collision = true',
    2 : SetObject,
    3 : '.right = true',
    4 : '.left = true',
    5 : 'jump',
    6 : '.x_vel = %s',
    # 6 : 'set_x_vel',
    # 7 : '.y_vel = %s',
    7 : 'set_y_vel',
    8 : '.max_x_vel = %s',
    # 8 : 'set_max_x_vel', # for debug
    9 : '.max_y_vel = %s',
    10 : '.x_accel = %s',
    # 10 : 'set_x_accel',
    11 : '.x_decel = %s',
    12 : '.gravity = %s',
    13 : '.jump_strength = %s',
    14 : '.jump_hold_height = %s',
    16 : 'jump_in_air',
    17 : '.paused = true',
    18 : '.paused = false',
    20 : '.add_x_vel = %s',
    21 : 'set_add_y_vel'
    # 21 : '.add_y_vel = %s'

})

conditions = make_table(ConditionMethodWriter, {
    0 : TrueCondition,
    2 : '.on_ground',
    3 : 'is_jumping',
    4 : 'is_falling',
    5 : '.paused',
    6 : 'is_moving'
})

expressions = make_table(ExpressionMethodWriter, {
    0 : '.x_vel',
    1 : '.y_vel',
    2 : '.max_y_vel',
    3 : '.max_x_vel',
    4 : '.x_accel',
    5 : '.x_decel',
    6 : '.gravity',
    7 : '.jump_strength',
    8 : '.jump_hold_height',
    11 : '.add_x_vel',
    12 : '.add_y_vel',


})

def get_object():
    return PlatformObject
