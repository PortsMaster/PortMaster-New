from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ActionMethodWriter, ConditionMethodWriter,
    ExpressionMethodWriter, make_table, ActionWriter)

class AdvancedDirection(ObjectWriter):
    class_name = 'AdvancedDirection'
    filename = 'advdir'

    def write_init(self, writer):
        pass

class FindClosest(ActionWriter):
    custom = True
    def write(self, writer):
        writer.start_brace()
        object_info = (self.parameters[0].loader.objectInfo,
                       self.parameters[0].loader.objectType)
        instances = self.converter.create_list(object_info, writer)
        details = self.convert_index(1)
        x = str(details['x'])
        y = str(details['y'])
        parent = details.get('parent', None)
        if parent is not None:
            writer.putln('int parent_x, parent_y;')
            writer.putln('FrameObject * parent = %s;' % (
                self.converter.get_object(parent)))
            writer.putln('if (parent == NULL) parent_x = parent_y = 0;')
            writer.putln('else {')
            writer.indent()
            writer.putln('parent_x = parent->x;')
            writer.putln('parent_y = parent->y;')
            writer.end_brace()
            x = 'parent_x + %s' % x
            y = 'parent_y + %s' % y
        object_info = self.get_object()
        obj = self.converter.get_object(object_info)
        writer.put('%s->find_closest(%s, %s, %s);' % (obj, instances, x, y))
        writer.end_brace()

class CompareDistance(ConditionMethodWriter):
    custom = True
    def write(self, writer):
        self.end_label = 'compare_%s_end' % self.get_id(self)

        writer.start_brace()

        writer.putlnc('FrameObject * obj1;')
        writer.putlnc('FrameObject * obj2;')
        writer.putlnc('int x1, y1, x2, y2;')

        pos1 = self.convert_index(0)
        pos2 = self.convert_index(1)

        self.set_pos(pos1, 'obj1', 'x1', 'y1', writer)
        self.set_pos(pos2, 'obj2', 'x2', 'y2', writer)

        check = 'get_distance(x1, y1, x2, y2) <= %s' % self.convert_index(2)
        if not self.is_negated():
            check = '!(%s)' % check

        writer.putlnc('if (%s) %s', check, self.converter.event_break)

        writer.end_brace()
        writer.put_label(self.end_label)

    def set_pos(self, pos, save_obj, x, y, writer):
        if pos.get('use_action_point', False):
            raise NotImplementedError()
        if pos.get('transform_position_direction', False):
            raise NotImplementedError()
        obj = pos.get('parent', None)
        if obj is None:
            raise NotImplementedError()
        writer.putlnc('%s = %s;', save_obj, self.converter.get_object(obj))
        writer.putlnc('if (%s == NULL) goto %s;', save_obj, self.end_label)

        writer.putlnc('%s = %s->get_x() + %s;', x, save_obj, pos['x'])
        writer.putlnc('%s = %s->get_y() + %s;', y, save_obj, pos['y'])

class GetDistance(ExpressionMethodWriter):
    has_object = False
    method = 'get_distance'

class GetDistanceInt(ExpressionMethodWriter):
    has_object = False
    method = 'get_distance_int'

class GetDirection(ExpressionMethodWriter):
    has_object = False
    method = 'get_angle'

class GetDirectionInt(ExpressionMethodWriter):
    has_object = False
    method = 'get_angle_int'

class GetDirDiffAbs(ExpressionMethodWriter):
    has_object = False
    method = 'get_dir_diff_abs'

actions = make_table(ActionMethodWriter, {
    1 : FindClosest
})

conditions = make_table(ConditionMethodWriter, {
    0 : CompareDistance
})

expressions = make_table(ExpressionMethodWriter, {
    1 : GetDirection,
    2 : GetDistance,
    3 : GetDirectionInt,
    4 : GetDistanceInt,
    6 : GetDirDiffAbs,
    8 : 'get_closest'
})

def get_object():
    return AdvancedDirection