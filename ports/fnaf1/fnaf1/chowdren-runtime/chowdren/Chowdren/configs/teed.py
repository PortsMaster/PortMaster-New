from chowdren.writers.events.system import get_loop_index_name

def use_deferred_collisions(converter):
    return False

def init(converter):
    converter.add_define('CHOWDREN_IS_TE')
    converter.add_define('CHOWDREN_IS_TEED')
    converter.add_define('CHOWDREN_QUICK_SCALE')
    converter.add_define('CHOWDREN_POINT_FILTER')
    converter.add_define('CHOWDREN_OBSTACLE_IMAGE')
    converter.add_define('CHOWDREN_TEXTURE_GC')
    converter.add_define('CHOWDREN_SPECIAL_POINT_FILTER')
    converter.add_define('CHOWDREN_JOYSTICK2_CONTROLLER')
    converter.add_define('CHOWDREN_FORCE_X360')
    converter.add_define('CHOWDREN_FORCE_TRANSPARENT')
    converter.add_define('CHOWDREN_FORCE_TEXT_LAYOUT')

def use_image_preload(converter):
    return True

def use_image_flush(converter, frame):
    return False

def use_edit_obj(converter):
    return True
