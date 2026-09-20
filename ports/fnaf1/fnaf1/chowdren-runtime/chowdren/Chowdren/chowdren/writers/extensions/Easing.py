from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, StaticExpressionWriter, make_table)

class EasingObject(ObjectWriter):
    filename = 'easing'
    class_name = 'EasingObject'
    static = True

    def initialize(self):
        data = self.get_data()
        overshoot = data.readFloat()
        amplitude = data.readFloat()
        period = data.readFloat()

        if round(overshoot, 4) != 1.5:
            raise NotImplementedError()
        if round(amplitude, 4) != 1.05:
            raise NotImplementedError()
        if round(period, 4) != 0.4:
            raise NotImplementedError()

actions = make_table(StaticActionWriter, {
})

conditions = make_table(StaticConditionWriter, {
})

expressions = make_table(StaticExpressionWriter, {
    7 : 'ease_out'
})

def get_object():
    return EasingObject