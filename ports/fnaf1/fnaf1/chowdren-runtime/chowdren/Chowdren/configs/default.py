def init(converter):
    converter.add_define('CHOWDREN_OBSTACLE_IMAGE')
    converter.add_define('CHOWDREN_QUICK_SCALE')
    converter.add_define('CHOWDREN_POINT_FILTER')
    converter.add_define('CHOWDREN_JOYSTICK2_CONTROLLER')
    converter.add_define('CHOWDREN_FORCE_TRANSPARENT')
    converter.add_define('CHOWDREN_16BIT_IMAGE')
    converter.add_define('CHOWDREN_FORCE_TEXT_LAYOUT')
    # Pack RGBA textures to 16-bit (RGBA4444) right before GPU upload.
    # Replaces ASTC (unsupported by gl4es's texture path) as the way to
    # cut GPU texture memory - halves it vs full 32-bit RGBA8888.
    converter.add_define('CHOWDREN_16BIT_TEXUPLOAD')

def init_container(converter, container):
    pass

def init_frame(converter, frame):
    pass

def write_pre(converter, writer, group):
    pass

def write_frame_post(converter, writer):
    pass

def init_obj(converter, obj):
    pass

def get_scale_method(converter, obj):
    # True for linear, False for linear
    return None

def use_simple_or(converter):
    return False

def get_locals(converter):
    return {}

def use_iteration_index(converter):
    return True

def use_global_alterables(converter, obj):
    return True

def use_single_global_alterables(converter, obj):
    return True

def use_global_int(converter, expression):
    return False

def use_alterable_int(converter, expression):
    return False

def use_counter_int(converter, expression):
    return False

def use_safe_division(converter):
    return True

def get_startup_instances(converter, instances):
    return instances

def use_safe_create(converter):
    return False

def use_global_instances(converter):
    return True

def use_update_filtering(converter):
    return False

def use_deferred_collisions(converter):
    return False

def use_repeated_collisions(converter):
    return False

def use_image_flush(converter, frame):
    return True

def use_image_preload(converter):
    return False

def add_defines(converter):
    pass

def get_frames(converter, game, frames):
    return frames

def get_depth(converter, layer):
    return None

def get_object_depth(converter, obj):
    return None

def use_loop_selection_clear(converter):
    return True

def get_loop_name(converter, parameter):
    return None

def get_loop_call_names(converter, name):
    return None

def get_dynamic_loop_call_name(converter, parameter):
    return None

def get_dynamic_loop_index(converter, exp):
    return None

def get_fonts(converter):
    return ('SmallFonts',)

def use_edit_obj(converter):
    return True

def reorder_foreach(converter):
    return False

def use_webp(converter):
    return False

def use_condition_expression_iterator(converter):
    return True

def use_blitter_callback(converter, obj):
    return False

def get_string(converter, value):
    return value

def init_array_set_value(converter, event_writer):
    pass

def get_missing_image(converter, image):
    raise NotImplementedError('invalid image: %s' % repr(image))

def write_loop(converter, loop_name, event_writer, writer):
    pass
