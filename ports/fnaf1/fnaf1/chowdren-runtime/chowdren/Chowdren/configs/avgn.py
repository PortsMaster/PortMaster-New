from chowdren.key import convert_key

def init(converter):
    # hack to set default keyboard keys
    # 72 - 82
    values = converter.game.globalValues.items
    for i in xrange(71, 82):
        values[i] = convert_key(values[i])

    converter.add_define('CHOWDREN_FORCE_REMOTE')
    converter.add_define('CHOWDREN_QUICK_SCALE')
    converter.add_define('CHOWDREN_STARTUP_WINDOW')
    converter.add_define('CHOWDREN_POINT_FILTER')
    converter.add_define('CHOWDREN_PERSISTENT_FIXED_STRING')
    converter.add_define('CHOWDREN_LAYER_WRAP')
    converter.add_define('CHOWDREN_RESTORE_ANIMATIONS')
    converter.add_define('CHOWDREN_WIIU_USE_COMMON')
    converter.add_define('CHOWDREN_SCREEN2_WIDTH', 240)
    converter.add_define('CHOWDREN_SCREEN2_HEIGHT', 180)
    converter.add_define('CHOWDREN_IS_AVGN')

    if converter.platform_name == 'wiiu':
        converter.add_define('CHOWDREN_PRELOAD_ALL')


alterable_int_objects = [
    'FireShark',
    'Cog',
]

def use_global_int(converter, expression):
    index = expression.data.loader.value
    return index in (0, 1)

def use_alterable_int(converter, expression):
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

def use_image_flush(converter, frame):
    if converter.platform_name != '3ds':
        return False
    # for 3DS primarily (maybe Vita as well)
    return frame.name in ('Level Select',)

def use_image_preload(converter):
    return converter.platform_name in ('3ds', 'wiiu')

def get_depth(converter, layer):
    if converter.platform_name != '3ds':
        return None
    if converter.current_frame.name in ('Intro', 'Ending'):
        return 0.0
    if layer.name in ('HUD', 'Untitled', 'Foreground Parallax'):
        return 0.0

    if layer.name == 'Bullets':
        coeff = 1.0
    else:
        coeff = layer.xCoefficient
    if coeff == 0.0:
        return 1.0
    depth = 1.0 - coeff
    depth = 0.15 + depth * (1.0 - 0.15)
    return max(0.0, min(1.0, depth))

def get_object_depth(converter, obj):
    if converter.platform_name != '3ds':
        return None
    name = obj.data.name
    if name == 'Particle':
        return 'alterables->values.get(1) * -0.01f'
    elif name == 'SMDC2000':
        return '(x_scale - 1.0f) * -0.5f'
    elif name == 'Glitch Gremlin':
        return '-0.1f'

def use_webp(converter):
    return False

def use_global_alterables(converter, obj):
    return False
