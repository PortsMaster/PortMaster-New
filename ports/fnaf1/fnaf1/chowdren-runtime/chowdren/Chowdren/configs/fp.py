from chowdren.key import convert_key
import os

def init(converter):
    converter.add_define('CHOWDREN_IS_FP')
    converter.add_define('CHOWDREN_QUICK_SCALE')
    converter.add_define('CHOWDREN_POINT_FILTER')
    converter.add_define('CHOWDREN_OBSTACLE_IMAGE')
    converter.add_define('CHOWDREN_STEAM_APPID', 248310)
    # converter.add_define('CHOWDREN_JOYSTICK2_CONTROLLER')
    converter.add_define('CHOWDREN_TEXTURE_GC')
    converter.add_define('CHOWDREN_FORCE_REMOTE')

    frameitems = converter.game.frameItems
    for item in frameitems.itemDict.itervalues():
        name = item.name
        if name.startswith('Hazard_ScanLaser'):
            print 'Fixing collisionbox for', item.name
            flags = item.properties.loader.newFlags
            flags['CollisionBox'] = False
        elif name == 'Icon_Joypad':
            values = item.properties.loader.values.items # 1, 3, 2, 8
            values[4] = 1
            values[5] = 3
            values[6] = 2
            values[7] = 7
        elif name == 'Icon_Keyboard':
            values = item.properties.loader.values.items
            for index in xrange(len(values)):
                values[index] = convert_key(values[index])

    values = converter.game.globalValues.items

    basename = os.path.basename(converter.games[0].filename)
    if 'e3' in basename or 'expo' in basename:
        converter.add_define('CHOWDREN_DISABLE_WRITE')
        converter.add_define('CHOWDREN_IS_DEMO')
    # values[0] = 1
    # values[1] = 4
    # values[4] = 1

# def get_frames(converter, game, frames):
#     new_frames = {}
#     # indexes = (0, 1, 2, 3, 7, 8, 14, 83, 20, 21, 22, 23, 76, 82)
#     # indexes = (72, 87, 85, 3, 8, 9, 10)
#     for index in indexes:
#         new_frames[index] = frames[index]
#     return new_frames

def fix_light_rays(converter, instances):
    new_instances = []
    rays = []
    for item in instances:
        frameitem = item[1]
        obj = (frameitem.handle, frameitem.objectType)
        writer = converter.get_object_writer(obj)
        if writer.data.name.startswith('Light ray'):
            rays.append(item)
        else:
            new_instances.append(item)

    return new_instances + rays

order_fixers = {
    'Relic Maze 5': fix_light_rays
}

def get_startup_instances(converter, instances):
    f = order_fixers.get(converter.current_frame.name, None)
    if f is None:
        return instances
    return f(converter, instances)

def write_frame_post(converter, writer):
    if converter.current_frame.name != 'Scene - Dragon Valley':
        return
    # need to force levelcard fader behind everything else, since we do not
    # implement z-saving (which is super stupid anyway)
    for item in converter.startup_instances:
        frameitem = item[1]
        if frameitem.name == 'LevelCard_Fade 2':
            break
    handle = (frameitem.handle, frameitem.objectType, converter.game_index)

    writer.add_member('bool startup_hack', 'false')
    writer.putln('if (startup_hack == false) {')
    writer.indent()
    writer.putln('startup_hack = true;')
    with converter.iterate_object(handle, writer, copy=False): 
        writer.putlnc('%s->move_back();', converter.get_object(handle))
    writer.end_brace()

def use_safe_create(converter):
    return True

def use_global_int(converter, expression):
    index = expression.data.loader.value
    # 3: LevelTimer
    return index in (3,)

def use_deferred_collisions(converter):
    return True

global_objects = [
    'GlobalInputData',
    'Player_Others',
    'Master_Level',
    'Controller.Music',
    'GUI_Rings',
    'GUI_Crystal',
    'GUI_Energy',
    'GUI_ScoreTimeRings',
    'GUI_Air',
    'GUI_PowerCard'
]

def use_global_alterables(converter, obj):
    check_name = obj.data.name
    for name in global_objects:
        if check_name.startswith(name):
            return True
    return False

def use_single_global_alterables(converter, obj):
    return True

alterable_int_objects = [
    ('FileSaveSlot', None),
    ('MinibossGolem_', [5]),
    ('GachaponWheel_', [0, 2, 3, 4, 5, 6, 7, 8]),
    ('BossGunshipTurbineLeft', None),
    ('BossGunshipTurbineRight', None),
    ('RecordLabel', None),
    ('CrystalCursor', None),
    ('GimmickRisingSwingPiece_', [0, 1, 8]),
    ('BossKujackerTail', None),
    ('HazardOrbitBeam_', None),
    ('BG13Layer1_', None),
    ('BossShadeBeastEye_', [3]),
    ('BossSatelliteArm_', [3])
]

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

counter_int_objects = [
    'MapSelect'
]

def use_counter_int(converter, expression):
    obj = expression.get_object()
    name = expression.converter.get_object_name(obj)
    for check_name in counter_int_objects:
        if name.startswith(check_name):
            return True
    return False

def use_image_preload(converter):
    return True

def use_image_flush(converter, frame):
    if frame.name in ('Update Records', 'Unlocked!', 'Black Load',
                      'Continue?', 'Bonus Stage'):
        return False
    if frame.name.startswith('Scene -'):
        return False
    return True

LOOP_NAMES = (
    'Player01DetectSensorMain',
    'Player01DetectSensorTop',
    'Player01DetectSensorBottom',
    'Player01DetectSensorLeft',
    'Player01DetectSensorRight',
    'Player01DetectSensorSlope',
    'Player01DetectSensorEdges',
    'Player01DetectSensorAngles'
)

def get_loop_name(converter, parameter):
    alt = parameter.loader.items[0]
    if alt.getName() != 'AlterableString':
        raise NotImplementedError()
    return LOOP_NAMES[alt.loader.value]

LOOP_CALLS = {
    'Player01AllSensors' : ("Player01DetectSensorMain",
                            "Player01DetectSensorLeft",
                            "Player01DetectSensorRight",
                            "Player01DetectSensorTop",
                            "Player01DetectSensorBottom",
                            "Player01DetectSensorSlope",
                            "Player01DetectSensorAngles",
                            "Player01DetectSensorEdges"),
    'Player01WallCollision' : ("Player01DetectSensorLeft",
                               "Player01DetectSensorRight"),
    'Player01Up' : ("Player01DetectSensorTop",),
    'Player01WallCollision' : ('Player01DetectSensorLeft',
                               'Player01DetectSensorRight'),
    'Player01Down' : ('Player01DetectSensorBottom',),
    'Player01DetectAngle' : ('Player01DetectSensorAngles',),
    'Player01SlopesDown' : ('Player01DetectSensorMain',
                            'Player01DetectSensorSlope'),
    'Player01SlopesUp' : ('Player01DetectSensorMain',)
}

def get_loop_call_names(converter, name):
    return LOOP_CALLS.get(name, None)


def use_loop_selection_clear(converter):
    return False

def reorder_foreach(converter):
    return True

def use_repeated_collisions(converter):
    return False

def use_condition_expression_iterator(converter):
    return False

def get_string(converter, value):
    value = value.replace('gamepad.cfg', 'control_gamepad.cfg')
    value = value.replace('keyboard.cfg', 'control_keyboard.cfg')
    if converter.platform_name != 'generic':
        value = value.replace('./records.dat',
                              '%s/records.dat' % converter.platform.save_dir)
        value = value.replace('./file',
                              '%s/file' % converter.platform.save_dir)
        value = value.replace('./save',
                              '%s/save' % converter.platform.save_dir)
    return value

def get_missing_image(converter, image):
    print 'bad image, selecting first instead:', image
    print converter.current_write_object.name
    return converter.image_indexes.itervalues().next()

def init_array_set_value(converter, event_writer):
    if event_writer.get_object_writer().data.name != 'MapData':
        return

    convert_index = event_writer.convert_index

    try:
        param = eval(convert_index(1))
        if param not in xrange(1, 9):
            return
        param = eval(convert_index(2))
        if param != 1:
            return
        param = eval(convert_index(3))
        if param != 0:
            return
    except NameError:
        return

    from chowdren.key import convert_key, SDL_KEYS
    first = event_writer.parameters[0].loader.items[0].loader
    value = SDL_KEYS[convert_key(first.value)]
    if isinstance(value, str):
        value = ord(value)
    first.value = value