from chowdren.writers.events.system import get_loop_index_name

def use_deferred_collisions(converter):
    return False

def init(converter):
    converter.add_define('CHOWDREN_IS_TE')
    converter.add_define('CHOWDREN_QUICK_SCALE')
    converter.add_define('CHOWDREN_POINT_FILTER')
    converter.add_define('CHOWDREN_OBSTACLE_IMAGE')
    converter.add_define('CHOWDREN_TEXTURE_GC')
    converter.add_define('CHOWDREN_SPECIAL_POINT_FILTER')
    converter.add_define('CHOWDREN_JOYSTICK2_CONTROLLER')
    converter.add_define('CHOWDREN_FORCE_X360')
    converter.add_define('CHOWDREN_FORCE_TRANSPARENT')
    converter.add_define('CHOWDREN_FORCE_TEXT_LAYOUT')
    converter.add_define('CHOWDREN_PASTE_PRECEDENCE')
    converter.add_define('CHOWDREN_STEAM_APPID', 298630)

def use_image_preload(converter):
    return True

def use_image_flush(converter, frame):
    return False

def use_edit_obj(converter):
    return True

alterable_int_objects = [
    ('BASEYou_', [3, 9]),
    ('BASEInmate_', [3, 9]),
    ('BASEGuard_', [3, 9]),
    ('qualifier_13', [3, 9])
]

def get_fonts(converter):
    return ('Escapists',)

def use_alterable_int(converter, expression):
    obj = expression.get_object()
    name = expression.converter.get_object_name(obj)
    for (check_name, alts) in alterable_int_objects:
        if not name.startswith(check_name):
            continue
        if alts is None:
            return True
        index = expression.data.loader.value
        return index in alts
    return False