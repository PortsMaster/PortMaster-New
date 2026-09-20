deactivate_containers = []

def init(converter):
    converter.add_define('CHOWDREN_QUICK_SCALE')
    converter.add_define('CHOWDREN_STARTUP_WINDOW')
    converter.add_define('CHOWDREN_POINT_FILTER')
    converter.add_define('CHOWDREN_RESTORE_ANIMATIONS')
    converter.add_define('CHOWDREN_INI_FILTER_QUOTES')
    converter.add_define('CHOWDREN_INI_KEEP_ORDER')
    converter.add_define('CHOWDREN_FORCE_TRANSPARENT')
    converter.add_define('CHOWDREN_16BIT_IMAGE')
    converter.add_define('CHOWDREN_VSYNC')
    converter.add_define('CHOWDREN_IS_HFA')
    converter.add_define('CHOWDREN_OBSTACLE_IMAGE')
    converter.add_define('CHOWDREN_DISABLE_DISPLAY0_EXT')
    converter.add_define('CHOWDREN_AUTOSAVE_ON_CHANGE') # this is stupid
    converter.add_define('CHOWDREN_SAVE_PATH', 'data/savegames')
    converter.add_define('CHOWDREN_USE_CRASHDUMP')

    # hack to turn on high-resolution lighting system images
    values = converter.game.globalValues.items
    values[191] = 1 # lights max resolution
    values[194] = 1 # turn off adaptive lights
    values[195] = 1 # lights min resolution
    values[196] = 1 # force small images off

    if converter.platform_name == '3ds':
        # converter.add_define('CHOWDREN_BACKGROUND_FBO')
        deactivate_containers.extend([
            'Dynamic Lighting System (no qualifiers) hwa',
            'New Lights',
            'Enemies'
        ])

    if converter.platform_name != 'generic':
        # turn off tester stuff
        deactivate_containers.extend([
            'BETA TESTER SHIT -- TURN OFF WITH FINAL RELEASE',
            'DEBUG -- turn off!'
        ])

    if converter.platform_name == 'ps4':
        converter.add_define('CHOWDREN_PRELOAD_ALL')

def init_container(converter, container):
    for name in deactivate_containers:
        if container.name == name:
            container.inactive = True
            return

def init_frame(converter, frame):
    if converter.current_frame_index != 0:
        return
    frame.fadeIn = None
    # frame.fadeOut = None

def use_image_flush(converter, frame):
    return False

def use_image_preload(converter):
    return False
    return converter.platform_name in ('ps4',)

global_objects = [
    'Scrolling',
    'Map_MainObject',
    'joy2key'
]

def use_global_alterables(converter, obj):
    for name in global_objects:
        if obj.data.name.startswith(name):
            return True
    return False

def use_single_global_alterables(converter, obj):
    return True

def use_global_int(converter, expression):
    index = expression.data.loader.value
    return index in (428,)

alterable_int_objects = [
    'MapMainObject',
    'CellFG',
    'CellBG',
    'Treasurebox',
    'Confirmtext_',
    'Loadslots_',
    'InventoryItemsACCESSORY',
    'InventoryACCESS'
]

def use_alterable_int(converter, expression):
    obj = expression.get_object()
    name = expression.converter.get_object_name(obj)
    for check in alterable_int_objects:
        if name.startswith(check):
            return True
    return False

def get_startup_instances(converter, instances):
    if converter.current_frame_index == 0:
        # bug in Text Blitter object, need to move them to front
        new_instances = []
        text_blitters = []
        for item in instances:
            frameitem = item[1]
            obj = (frameitem.handle, frameitem.objectType)
            writer = converter.get_object_writer(obj)
            if writer.class_name == 'TextBlitter':
                text_blitters.append(item)
            else:
                new_instances.append(item)

        new_instances += text_blitters
        return new_instances
    elif converter.current_frame_index == 26:
        # remove Active 10
        new_instances = []
        for item in instances:
            frameitem = item[1]
            obj = (frameitem.handle, frameitem.objectType)
            writer = converter.get_object_writer(obj)
            if writer.data.name == 'Active 10':
                converter.multiple_instances.add(obj)
                continue
            new_instances.append(item)
        return new_instances
    return instances

def find_obj(converter, name):
    for item in converter.startup_instances:
        frameitem = item[1]
        if frameitem.name == name:
            break
    else:
        raise KeyError()
    handle = (frameitem.handle, frameitem.objectType, converter.game_index)
    return handle

def write_frame_post(converter, writer):
    if converter.current_frame_index != 26:
        return

    active_4 = find_obj(converter, 'Active 4')
    writer.putlnc('%s->move_front();', converter.get_object(active_4))

    # Layer:
    # big_light: 1
    # Active 5: 2
    # Active 6: 3
    # Active 7: 4
    # Active 8: 5
    # Demo fade out: 6
    # FG Bloom: 7
    # Demo fade out 2: 8
    # Active 9: 10
    # Active 11: 11
    # light: 12
    # Demo fade out main menu: 14

    # need to fix order because of stupid MMF reordering
    fg_bloom = find_obj(converter, 'FG Bloom effect')
    demo_fade_out = find_obj(converter, 'Demo fade out')

    writer.putlnc('%s->move_front(%s);', converter.get_object(fg_bloom),
                  converter.get_object(demo_fade_out))


def use_safe_create(converter):
    return True

def get_fonts(converter):
    return ('SmallFonts',)

def get_frames(converter, game, frames):
    new_frames = {}
    if game.index == 0:
        indexes = (0, 1, 3, 4, 6, 10, 15, 16, 21, 22, 23, 24, 25, 26, 27, 28,
                   29, 31, 32, 33, 35, 36, 37, 39, 40, 41, 42, 43, 44, 45, 46,
                   47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61,
                   62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72)
        if converter.platform_name == 'generic':
            indexes = indexes + (77,)
        # indexes = (6,)
    else:
        indexes = (0, 1, 2, 3, 4, 5, 6, 7, 8)
    for index in indexes:
        new_frames[index] = frames[index]
    return new_frames

def use_condition_expression_iterator(converter):
    return False

def use_blitter_callback(converter, obj):
    if obj.data.name != 'Text Dialogue':
        return False
    if obj.text.count('1234567890123456789012345678901234567890') <= 0:
        return False
    frame_index = converter.current_frame_index
    return frame_index in (None, 6)

def get_string(converter, value):
    value = value.replace('controls.ini', 'controls_final.ini')
    return value

scale_objs = (
    ('Active', 1262, 1233),
    ('Active 5', 274, 231),
    ('Active 10', 100, 100)
)

def get_scale_method(converter, obj):
    if obj.game_index != 0:
        return None
    bank = converter.games[0].images
    images = obj.get_images()
    for (scale_name, img_w, img_h) in scale_objs:
        if obj.data.name != scale_name:
            continue
        for image in images:
            image = bank.itemDict[image]
            if image.width != img_w:
                break
            if image.height != img_h:
                break
            return True
    return None