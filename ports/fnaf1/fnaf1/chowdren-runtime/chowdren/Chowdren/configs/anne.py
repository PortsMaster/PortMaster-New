def init(converter):
    converter.add_define('CHOWDREN_SNES_CONTROLLER')
    converter.add_define('CHOWDREN_FORCE_REMOTE')
    converter.add_define('CHOWDREN_QUICK_SCALE')

def use_iteration_index(converter):
    return False

alterable_int_objects = [
    'MenuMainMapObject_',
    'MiniMapObject_',
    'MenuMainController'
]

def use_alterable_int(expression):
    obj = expression.get_object()
    name = expression.converter.get_object_name(obj)
    for check in alterable_int_objects:
        if name.startswith(check):
            return True
    return False

def use_safe_division(converter):
    return False

def use_safe_create(converter):
    return True

def use_update_filtering(converter):
    return True
