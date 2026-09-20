from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ActionMethodWriter, ConditionMethodWriter,
    ExpressionMethodWriter, make_table)

class DirectionCalculator(ObjectWriter):
    class_name = 'DirectionCalculator'
    static = True

class LookAt(ActionMethodWriter):
    method = 'look_at'

    def get_object(self):
        loader = self.parameters[0].loader
        return loader.objectInfo, loader.objectType

    def write(self, writer):
        details = self.convert_index(1)
        if not details.get('parent'):
            raise NotImplementedError()
        obj = self.converter.get_object(details['parent'])
        x = '%s->get_x() + %s' % (obj, details['x'])
        y = '%s->get_y() + %s' % (obj, details['y'])
        writer.put('look_at(%s, %s);' % (x, y))

class RotateToward(ActionMethodWriter):
    method = 'rotate_toward'

    def write(self, writer):
        direction = self.convert_index(0)
        writer.putc('rotate_toward(%s);', direction)

    def get_object(self):
        loader = self.parameters[1].loader
        return loader.objectInfo, loader.objectType

actions = make_table(ActionMethodWriter, {
    1: RotateToward,
    2 : LookAt
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
})

def get_object():
    return DirectionCalculator