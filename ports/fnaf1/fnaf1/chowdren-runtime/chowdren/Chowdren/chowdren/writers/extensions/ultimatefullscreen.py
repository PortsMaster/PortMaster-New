from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ActionMethodWriter, ConditionMethodWriter,
    ExpressionMethodWriter, make_table, ActionWriter, EmptyAction)

class UltimateFullcsreen(ObjectWriter):
    class_name = 'Fullscreen'
    static = True

class Action(ActionMethodWriter):
    has_object = False

actions = make_table(Action, {
    1 : 'manager.set_window(false)',
    0 : 'manager.set_window(true)',
    5 : 'manager.set_window_scale',
    4 : 'manager.set_scale_type',
    # 11 : 'manager.set_rectangle_width',
    # 12 : 'manager.set_rectangle_height',
    # 13 : 'manager.refresh_rect'
    11 : EmptyAction,
    12 : EmptyAction,
    13 : EmptyAction
})

conditions = make_table(ConditionMethodWriter, {
    1 : '!manager.is_fullscreen()'
})

expressions = make_table(ExpressionMethodWriter, {
    0 : 'WindowControl::get_x',
    1 : 'WindowControl::get_y'
})

def get_object():
    return UltimateFullcsreen