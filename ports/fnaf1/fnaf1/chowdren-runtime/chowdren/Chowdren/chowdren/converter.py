import os
import sys
import shutil
import contextlib
from mmfparser.data.exe import ExecutableData
from mmfparser.data.gamedata import GameData
from mmfparser.bytereader import ByteReader
from mmfparser.data.chunkloaders.objectinfo import (PLAYER, KEYBOARD, CREATE,
    TIMER, GAME, SPEAKER, SYSTEM, QUICKBACKDROP, BACKDROP, ACTIVE, TEXT,
    QUESTION, SCORE, LIVES, COUNTER, RTF, SUBAPPLICATION, EXTENSION_BASE,
    NONE_EFFECT, SEMITRANSPARENT_EFFECT, INVERTED_EFFECT,
    XOR_EFFECT, AND_EFFECT, OR_EFFECT, MONOCHROME_EFFECT, ADD_EFFECT,
    SUBTRACT_EFFECT, HWA_EFFECT, SHADER_EFFECT, getObjectType)
from mmfparser.data.chunkloaders.shaders import INT, FLOAT, INT_FLOAT4, IMAGE
from mmfparser.data.chunkloaders.frame import NONE_PARENT
from mmfparser.bitdict import BitDict
from cStringIO import StringIO
import textwrap
from PIL import Image
from mmfparser.data.font import LogFont
import string
import functools
import itertools
from collections import defaultdict, Counter
from chowdren.writers.events import default_writers
from chowdren.writers.events import system as system_writers
from chowdren.writers.events.system import SystemObject
from chowdren.writers.objects.system import system_objects
from chowdren.common import (get_method_name, get_class_name, check_digits,
    to_c, make_color, parse_direction, get_base_path, get_root_path, makedirs,
    is_qualifier, get_qualifier, TEMPORARY_GROUP_ID, get_color_tuple)
from chowdren.writers.extensions import load_extension_module
from chowdren.key import VK_TO_SDL, VK_TO_NAME, convert_key, KEY_TO_NAME
from chowdren import extra
from chowdren import shader
from chowdren.shader import INK_EFFECTS, get_shader_programs
from chowdren.config import ConfigurationFile
from chowdren.idpool import get_id
from chowdren.codewriter import CodeWriter
from chowdren.platforms import classes as platform_classes
from chowdren.assets import Assets
from mmfparser import texpack
import platform
import math
import wave
import audioop
import struct
import hashlib
import cPickle
import multiprocessing
from chowdren.local import write_locals
from chowdren import transition

WRITE_SOUNDS = True
PROFILE = False
PROFILE_GROUPS = PROFILE and True
PROFILE_DRAW = PROFILE and False
PROFILE_EVENTS = PROFILE and False
PROFILE_OBJECTS = PROFILE and False

# enabled for porting
NATIVE_EXTENSIONS = True

if NATIVE_EXTENSIONS and sys.platform == 'win32':
    from mmfparser.extension import loadLibrary, LoadedExtension

LICENSE = ("""\
// Copyright (c) Mathias Kaerlev 2012.
//
// This file is part of Chowdren.
//
// Chowdren is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Chowdren is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Chowdren.  If not, see <http://www.gnu.org/licenses/>.\
""")

def get_hash(data):
    return hashlib.md5(data).digest()

def is_file_changed(src, dst):
    return True
    if not os.path.exists(dst):
        return True
    diff = os.stat(src).st_mtime - os.stat(dst).st_mtime
    return math.fabs(diff) > 0.01

def copytree(src, dst, excludes=[]):
    try:
        os.makedirs(dst)
    except OSError:
        pass
    errors = []
    for name in os.listdir(src):
        if name in excludes:
            continue
        srcname = os.path.join(src, name)
        dstname = os.path.join(dst, name)
        if os.path.isdir(srcname):
            copytree(srcname, dstname, excludes)
        elif is_file_changed(srcname, dstname):
            shutil.copy2(srcname, dstname)
    try:
        shutil.copystat(src, dst)
    except OSError, why:
        if WindowsError is not None and isinstance(why, WindowsError):
            # Copying file access times may fail on Windows
            pass
        else:
            errors.extend((src, dst, str(why)))
    if errors:
        raise shutil.Error, errors

native_extension_cache = {}

MMF_BASE = ''

if sys.platform == 'win32':
    def get_install_path():
        try:
            import _winreg
        except ImportError:
            return None
        for (name, utf16) in (('Multimedia Fusion Developer 2', False),
                              ('Fusion Developer 2.5', True)):
            reg_name = 'Software\\Clickteam\\%s\\Settings' % name
            try:
                reg_key = _winreg.OpenKey(_winreg.HKEY_CURRENT_USER, reg_name)
            except WindowsError:
                continue
            data = _winreg.QueryValueEx(reg_key, 'ObjLibs')[0]
            if utf16:
                pos = 35
                size = ord(data[35]) * 2
                path = data[36:36+size].decode('utf-16')
            else:
                size = ord(data[16])
                path = data[17:17+size]
            return os.path.realpath(os.path.join(path, '..', '..'))
        return None

    MMF_BASE = get_install_path() or ''

MMF_PATH = os.path.join(MMF_BASE, 'Extensions')
MMF_UNICODE_PATH = os.path.join(MMF_BASE, 'Extensions', 'Unicode')
MMF_RUNTIME = os.path.join(MMF_BASE, 'Data', 'Runtime', 'Unicode')
MMF_EXT = '.mfx'

EXTENSION_ALIAS = {
    'INI++15' : 'INI++'
}

IGNORE_EXTENSIONS = set([
    'kcwctrl', 'SteamChowdren', 'ChowdrenFont', 'INI++', 'MMKPathPlanner',
    'Layer'
])

if sys.platform == 'win32':
    paths = ';'.join((MMF_RUNTIME,))
    os.environ['PATH'] += ';' + paths

def load_native_extension(name):
    if not NATIVE_EXTENSIONS or sys.platform != 'win32' or not MMF_BASE:
        return None
    name = EXTENSION_ALIAS.get(name, name)
    if name in IGNORE_EXTENSIONS:
        return None
    try:
        return native_extension_cache[name]
    except KeyError:
        pass
    cwd = os.getcwd()
    os.chdir(MMF_BASE)
    for path in (MMF_PATH, MMF_UNICODE_PATH):
        path = os.path.join(path, name + MMF_EXT)
        if os.path.isfile(path):
            break
    library = loadLibrary(path)
    os.chdir(cwd)
    if library is None:
        print 'could not load', name
        native_extension_cache[name] = None
        return None
    print 'Loading', name
    extension = LoadedExtension(library, False)
    native_extension_cache[name] = extension
    return extension

key_flags = BitDict(
    'Up',
    'Down',
    'Left',
    'Right',
    'Fire1',
    'Fire2',
    'Fire3',
    'Fire4'
)

DEFAULT_CHARMAP = ''.join([chr(item) for item in xrange(32, 256)])

class EventContainer(object):
    is_static = None
    def __init__(self, name, inactive, parent, converter):
        self.name = name
        if parent is None:
            self.tree = [self]
        else:
            self.tree = parent.tree + [self]
        names = [item.name for item in self.tree]
        names = '_'.join(names)
        names = get_method_name(names)
        converter.container_ids[names] += 1
        container_id = converter.container_ids[names]
        self.container_id = container_id

        self.code_name = 'group_%s_%s' % (names, container_id)
        self.inactive = inactive
        self.parent = parent
        self.children = []
        self.end_label = '%s_end' % self.code_name
        self.check_ids = itertools.count()
        converter.config.init_container(self)

    def add_child(self, child):
        self.children.append(child)

    def get_all_children(self):
        children = set()
        for child in self.children:
            children.add(child)
            children.update(child.get_all_children())
        return list(children)

class ContainerMark(object):
    is_container_mark = True
    conditions = ()

    def __init__(self, container, mark):
        self.container = container
        self.mark = mark

def fix_conditions(conditions):
    return conditions
    # this is a nasty hack based on very odd MMF2 behaviour
    names = [c.data.getName() for c in conditions]
    if names == ['Never', 'OnCollision']:
        conditions.pop(0)
    return conditions

class EventGroup(object):
    global_id = None
    local_id = None
    generated = False
    or_generated = False
    or_exit = None
    is_container_mark = False
    or_first = False
    or_save = False
    or_final = False
    or_type = None
    event_name = None
    ids = None
    written = False
    write_callbacks = None
    data_hash = None
    in_place = False
    pre_event = False
    post_event = False
    precedence = 0

    def __init__(self, converter, conditions, actions, container, global_id,
                 or_index, not_always, or_type):
        self.converter = converter
        self.conditions = fix_conditions(conditions)
        self.actions = actions
        for ace_list in (conditions, actions):
            for ace in ace_list:
                ace.group = self
        self.container = container
        self.config = {}
        self.global_id = global_id
        self.not_always = not_always
        self.or_index = or_index
        self.or_type = or_type
        self.force_multiple = set()
        self.ids = {}

    def get_id(self, obj):
        key = hash(obj)
        try:
            return self.ids[key]
        except KeyError:
            pass
        new_id = '%s_%s' % (TEMPORARY_GROUP_ID, len(self.ids))
        self.ids[key] = new_id
        return new_id

    def set_groups(self, converter, groups):
        is_simple = converter.config.use_simple_or()
        if len(groups) == 1:
            self.name = 'event_%s' % TEMPORARY_GROUP_ID
            self.unique_id = TEMPORARY_GROUP_ID
            return
        self.unique_id = '%s_%s' % (TEMPORARY_GROUP_ID, self.or_index)
        if is_simple:
            self.name = 'event_or_%s' % self.unique_id
            return
        first_group = None
        last_group = None
        cond = None
        if self.or_generated:
            cond = self.conditions[0].data

        for group in groups:
            if group.or_generated != self.or_generated:
                continue
            if first_group is None:
                first_group = group
            last_group = group
        if last_group is first_group:
            self.name = 'event_or_%s' % self.unique_id
            return
        # use first group as data store
        if first_group is self:
            self.or_first = True
            self.or_selected = {}
            self.or_instance_groups = defaultdict(list)
        else:
            self.or_selected = first_group.or_selected
            self.or_instance_groups = first_group.or_instance_groups

        if last_group is self:
            self.or_final = True
        else:
            self.or_save = True
            self.actions = []
        self.name = self.get_or_name()
        # self.or_exit = 'goto %s_end;' % last_group.get_or_name()
        self.or_result = 'or_result_%s' % TEMPORARY_GROUP_ID
        self.or_temp_result = 'or_temp_result_%s_%s' % (TEMPORARY_GROUP_ID,
                                                        self.or_index)

    def get_or_name(self):
        return 'or_event_%s' % self.unique_id

    def set_generated(self, value):
        self.generated = value

    def set_or_generated(self, value):
        self.or_generated = value

    def add_write_callback(self, f, *arg, **kw):
        if self.written:
            f(*arg, **kw)
            return
        if self.write_callbacks is None:
            self.write_callbacks = []
        self.write_callbacks.append((f, arg, kw))

    def add_member(self, name, default=None):
        self.add_write_callback(self.on_add_member, name, default)

    def on_add_member(self, name, default):
        name = self.filter(name)
        self.converter.event_frame_initializers[self.data_hash].append(
            (name, default))

    def filter(self, data):
        if self.data_hash is None:
            raise NotImplementedError()
        new_id = '%s_%s' % (self.global_id, self.converter.current_frame_index)
        data = data.replace(TEMPORARY_GROUP_ID, new_id)
        return data

    def fire_write_callbacks(self):
        self.written = True
        if not self.write_callbacks:
            return
        for (f, arg, kw) in self.write_callbacks:
            f(*arg, **kw)
        self.write_callbacks = None

class ObjectFileWriter(CodeWriter):
    index = 1
    object_count = 0

    def __init__(self, converter, max_count=100):
        self.sources = []
        self.max_count = max_count
        self.converter = converter
        self.open_next()

    def open_next(self):
        filename = 'objects%s.cpp' % self.index
        self.sources.append(filename)
        filename = self.converter.get_filename(filename)
        if self.fp:
            CodeWriter.close(self)
        self.open(filename)
        self.putln('#include "objects.h"')
        self.putln('#include "common.h"')
        self.putln('#include "fonts.h"')
        self.putln('#include "font.h"')
        self.putln('#include "lists.h"')
        self.putln('')
        self.index += 1

    def next(self):
        self.object_count += 1
        if self.object_count >= self.max_count:
            self.object_count = 0
            self.open_next()


class MultiFileWriter(CodeWriter):
    index = 1
    function_count = 0

    def __init__(self, converter, max_count=100):
        self.sources = []
        self.max_count = max_count
        self.converter = converter
        self.members = set()

        self.class_name = self.get_class()

        header_path = '%s.h' % self.get_filename()
        self.header = converter.open_code(header_path)

        self.header.start_guard(self.get_guard())
        self.write_header_includes()
        self.header.putln('')
        self.header.putclass(self.class_name, self.base_class)
        self.header.put_access('public')

        self.open_next()

    def get_guard(self):
        return 'CHOWDREN_%s_H' % self.get_filename().upper()

    def close(self):
        CodeWriter.close(self)
        self.header.end_brace(True)
        self.header.close_guard(self.get_guard())
        self.header.close()

    def add_member(self, name, default=None):
        if name in self.members:
            return False
        self.members.add(name)
        self.header.putlnc('%s;', name)
        return True

    def open_next(self):
        filename = '%s_%s.cpp' % (self.get_filename(), self.index)
        self.sources.append(filename)
        filename = self.converter.get_filename(filename)
        if self.fp:
            CodeWriter.close(self)
        self.open(filename)
        self.write_includes()
        self.putln('')
        self.index += 1

    def putmeth(self, name, *arg, **kw):
        self.function_count += 1
        if self.function_count >= self.max_count:
            self.open_next()
            self.function_count = 0
        fullarg = list(arg)
        prototype = '%s(%s)' % (name, ', '.join(fullarg))
        self.add_member(prototype)
        # add FrameXX::method qualifier
        name = name.split(' ')
        name[-1] = '%s::%s' % (self.class_name, name[-1])
        try:
            name.remove('static')
        except ValueError:
            pass
        name = ' '.join(name)
        CodeWriter.putmeth(self, name, *arg, **kw)

class EventFileWriter(MultiFileWriter):
    base_class = 'Frame'

    def get_filename(self):
        return 'events'

    def get_class(self):
        return 'Frames'

    def add_member(self, name, default=None):
        if default is not None:
            self.converter.frame_initializers[name] = default
        return MultiFileWriter.add_member(self, name, default)

    def write_header_includes(self):
        self.header.putln('#include "frame.h"')

    def write_includes(self):
        self.putln('#include "events.h"')
        self.putln('#include "framedata.h"')
        self.putln('#include "lists.h"')
        self.putln('#include "media.h"')
        self.putln('#include "objects.h"')
        self.putln('#include "bitarray.h"')

class FrameDataWriter(MultiFileWriter):
    base_class = 'FrameData'

    def __init__(self, frame_index, *arg, **kw):
        self.frame_index = frame_index
        MultiFileWriter.__init__(self, *arg, **kw)

    def get_filename(self):
        return 'frame%s' % self.frame_index

    def get_class(self):
        return 'Frame%s' % self.frame_index

    def write_header_includes(self):
        self.header.putln('#include "frame.h"')

    def write_includes(self):
        self.putln('#include "events.h"')
        self.putlnc('#include "%s.h"', self.get_filename())

def fix_sound(data, extension):
    data = str(data)
    if extension != 'wav':
        return data
    wav = wave.open(StringIO(data), 'rb')
    channels, width, rate, frame_count, comptype, compname = wav.getparams()
    if width == 2:
        return data
    frames = wav.readframes(frame_count)
    wav.close()
    if width == 3:
        new_frames = ''
        for i in xrange(frame_count*channels):
            new_frames += frames[i*3+1:i*3+3]
        frames = new_frames
    else:
        if width == 1:
            frames = audioop.bias(frames, 1, 128)
        frames = audioop.lin2lin(frames, width, 2)
    fp = StringIO()
    wav = wave.open(fp, 'wb')
    wav.setparams((channels, 2, rate, frame_count, comptype, compname))
    wav.writeframesraw(frames)
    wav.close()
    return fp.getvalue()

class Converter(object):
    debug = False

    def __init__(self, args):
        self.outdir = args.outdir

        # DLL architecture
        self.use_dlls = args.dlls
        self.event_hash_id = 0

        self.clear_selection()
        self.container_tree = []
        self.collision_objects = set()
        self.iterated_index = self.iterated_object = self.iterated_name = None
        self.in_actions = self.in_condition_expression = False
        self.strings = {}
        self.event_functions = {}
        self.event_wrappers = {}
        self.objs_to_qualifier = {}
        self.event_frame_initializers = defaultdict(list)
        self.class_names = set(['FrameObject'])
        self.defines = set()
        self.current_group = None
        self.event_settings = {}
        self.current_frame_index = None

        self.games = []

        for game_index, filename in enumerate(args.filenames):
            fp = open(filename, 'rb')
            if filename.endswith('.exe'):
                # loadImages=False: ImageItem.read() defaults loadImages to
                # True, which fully decompresses every image in the game
                # (RGB + alpha) right here, before create_assets() even
                # runs. For a FNAF-sized game (lots of full-frame camera/
                # jumpscare images), that's 605 decompressed buffers all
                # resident at once - the peak actually happens here, not in
                # create_assets(). With this False, ImageItem just stores a
                # (reader, pos) reference into the shared image-bank
                # ByteReader until something calls image.load() on demand.
                exe = ExecutableData(ByteReader(fp), loadFrames = False,
                                     loadImages = False)
                game = exe.gameData
            elif filename.endswith('.ccn'):
                game = GameData(ByteReader(fp))
            elif filename.endswith('.ccj'):
                game = GameData(ByteReader(fp), java = True)
            else:
                raise NotImplementedError('invalid extension')
            game.index = game_index
            game.filename = filename
            self.games.append(game)

        self.game = self.games[0]
        self.is_unicode = self.game.settings.get('unicode', False)

        if args.ico is not None:
            shutil.copy(args.ico, self.get_filename('icon.ico'))
        if args.icns is not None:
            shutil.copy(args.icns, self.get_filename('icon.icns'))

        # set up directory structure
        makedirs(self.outdir)
        self.build_dir = os.path.join(self.outdir, 'build')
        makedirs(self.build_dir)
        makedirs(os.path.join(self.outdir, 'image_cache'))

        # application info
        def fix_quotes(value):
            if value is None:
                return None
            return value.replace('"', '')

        company = fix_quotes(args.company or game.author)
        version = args.version or '1.0.0.0'
        version_number = ', '.join(version.split('.'))
        copyright = fix_quotes(args.copyright or game.author)
        self.build = game.productBuild
        self.base_path = get_base_path()
        self.root_path = get_root_path()
        self.platform_name = args.platform or 'generic'
        self.info_dict = dict(company=company, version=version,
                              copyright=copyright, description=game.name,
                              version_number=version_number, name=game.name,
                              platform=self.platform_name)

        base_path = self.base_path
        if args.copy_base:
            new_base = os.path.join(self.outdir, 'base')
            shutil.rmtree(new_base, ignore_errors=True)
            shutil.copytree(self.base_path, new_base)
            base_path = '${CMAKE_CURRENT_SOURCE_DIR}/base'
        else:
            base_path = self.base_path.replace('\\', '/')
        self.info_dict['base_path'] = base_path

        # assets, platform and config
        self.config = ConfigurationFile(self, args.config)
        self.config.init()
        self.assets = Assets(self, args.skipassets)
        self.platform = platform_classes[self.platform_name](self)

        self.frame_map = {}
        self.image_frames = defaultdict(set)
        self.frame_images = {}

        max_index = 0
        for game in self.games:
            game.frame_offset = max_index
            for frame_index, frame in enumerate(game.frames):
                new_frame_index = frame_index + max_index
                frame.offset_index = new_frame_index
                self.frame_map[(game.filename, frame_index)] = new_frame_index
            max_index += len(game.frames)

        # fonts
        fonts_header = self.open_code('fonts.h')
        fonts_header.putln('#include "common.h"')
        fonts_header.start_guard('CHOWDREN_FONTS_H')

        fonts_file = self.open_code('fonts.cpp')
        fonts_file.putln('#include "fonts.h"')
        font_cache = set()
        self.fonts = {}
        for game in self.games:
            if not game.fonts:
                continue
            for font in game.fonts.items:
                logfont = font.value
                font_name = 'font%s' % font.handle
                font_line = to_c('Font %s = Font(%r, %s, %s, %s, %s);',
                                  font_name, logfont.faceName,
                                  logfont.getSize(),
                                  logfont.isBold(), bool(logfont.italic),
                                  bool(logfont.underline), cpp=False)
                self.fonts[font.handle] = logfont
                if font_line in font_cache:
                    continue
                font_cache.add(font_line)
                fonts_file.putln(font_line)
                fonts_header.putln('extern Font %s;' % font_name)
        fonts_header.close_guard('FONTS_H')
        fonts_file.close()
        fonts_header.close()

        # images
        if self.assets.skip:
            with open(self.get_filename('cache.dat'), 'rb') as fp:
                cache = cPickle.load(fp)
            self.assets.load_cache(cache)
            self.solid_images = cache['solid']
            self.image_indexes = cache['indexes']
            self.image_count = cache['count']
            del cache
        else:
            cache = {}
            self.create_assets(cache)
            with open(self.get_filename('cache.dat'), 'wb') as fp:
                cPickle.dump(cache, fp, protocol=2)
            del cache

        objects_header = self.open_code('objects.h')
        objects_header.start_guard('CHOWDREN_OBJECTS_H')
        objects_header.putln('#include "common.h"')
        objects_header.putln('')

        self.global_object_header = CodeWriter()
        self.global_object_code = CodeWriter()

        objects_file = ObjectFileWriter(self)

        lists_header = self.open_code('lists.h')
        lists_header.start_guard('CHOWDREN_LISTS_H')
        lists_header.putln('#include "objects.h"')
        lists_header.putln('void global_object_update();')

        lists_file = self.open_code('lists.cpp')
        lists_file.putln('#include "lists.h"')
        lists_file.putln('#include "manager.h"')
        lists_file.putln('#include "frameobject.h"')
        lists_file.putln('#include "common.h"')

        # these are game-specific
        self.object_names = {}
        self.object_class_index = 0
        self.all_objects = {}
        self.name_to_item = {}
        self.object_types = {}
        self.object_list_ids = {}
        self.object_lists = {}
        self.object_cache = {}
        self.global_object_data = {}
        self.back_ids = {}

        self.extension_includes = set()
        self.extension_sources = set()
        self.event_callback_ids = itertools.count()
        self.application_writers = set()

        self.type_ids = itertools.count(2)

        for game_index, game in enumerate(self.games):
            self.game_index = game_index
            self.game = game
            self.write_objects(game.frameItems.items, objects_file,
                               objects_header, lists_header)

        self.max_type_id = self.type_ids.next()

        for class_name in self.class_names:
            objects_file.putlnc('FRAMEOBJECT_IMPL(%s)', class_name)

        objects_header.putcode(self.global_object_header)
        objects_file.putcode(self.global_object_code)

        objects_header.close_guard('CHOWDREN_OBJECTS_H')
        objects_file.close()
        objects_header.close()

        extensions_header = self.open_code('extensions.h')
        extensions_header.start_guard('CHOWDREN_EXTENSIONS_H')
        for include in self.extension_includes:
            extensions_header.putln('#include "%s"' % include)
        extensions_header.close_guard('CHOWDREN_EXTENSIONS_H')
        extensions_header.close()

        event_file = EventFileWriter(self)

        self.processed_frames = []
        self.frame_srcs = []

        for game in self.games:
            self.frame_index_offset = game.frame_offset
            self.game = game
            self.game_index = game.index
            frame_dict = dict(enumerate(game.frames))
            frame_dict = self.config.get_frames(game, frame_dict)
            for frame in frame_dict.itervalues():
                self.write_frame(frame.offset_index, frame, event_file,
                                 lists_file, lists_header)

        # write object updates
        update_calls = defaultdict(list)
        updated_objs = set()
        updaters = {}
        for handle, writer in self.all_objects.iteritems():
            self.game_index = handle[2]
            self.game = self.games[self.game_index]
            handle = handle[:-1]
            if not self.is_valid_object(handle):
                continue
            has_updates = writer.has_updates()
            has_movements = writer.has_movements()
            has_sleep = writer.has_sleep()
            has_kill = writer.has_kill()
            if not has_updates and not has_movements:
                continue
            list_name = self.get_object_list(handle)
            if list_name in updated_objs:
                continue
            updated_objs.add(list_name)

            func_name = 'update_%s_%s' % (writer.class_name.lower(),
                                          len(updaters))
            key = (writer.class_name, has_updates, has_movements, has_sleep,
                   has_kill)
            func_name = updaters.get(key, None)
            has_func = func_name is not None
            if not has_func:
                func_name = 'update_%s_%s' % (writer.class_name.lower(),
                                              len(updaters))

            update_calls[func_name].append(list_name)

            if has_func:
                continue

            updaters[key] = func_name

            event_file.putlnc('static void %s(ObjectList ** lists, int count)',
                              func_name)
            event_file.start_brace()
            event_file.putln('ObjectList::iterator it;')
            event_file.putlnc('for (int i = 0; i < count; i++) {')
            event_file.indent()
            event_file.putln('ObjectList & list = *lists[i];')
            event_file.putlnc('for (it = list.begin(); '
                              'it != list.end(); ++it) {')
            event_file.indent()
            event_file.putln('FrameObject * instance = it->obj;')
            event_file.putln('if (instance->flags & DESTROYING)')
            event_file.indent()
            event_file.putln('continue;')
            event_file.dedent()
            if has_kill:
                event_file.putln('instance->update_kill();')
            elif has_sleep:
                event_file.putln('instance->update_inactive();')

            if has_sleep:
                event_file.putln('if (instance->flags & INACTIVE)')
                event_file.indent()
                event_file.putln('continue;')
                event_file.dedent()
            if has_updates:
                event_file.putlnc('((%s*)instance)->update();',
                                  writer.class_name)
            if has_movements:
                event_file.putln('if (instance->movement)')
                event_file.indent()
                event_file.putln('instance->movement->update();')
                event_file.dedent()
            event_file.end_brace()
            event_file.end_brace()

            event_file.end_brace()

        event_file.putmeth('void update_objects')
        for func_name, lists in update_calls.iteritems():
            event_file.add_member('ObjectList * %s_list[%s]' % (func_name,
                                                                len(lists)))
            event_file.putlnc('%s(%s_list, %s);', func_name, func_name,
                              len(lists))
        event_file.end_brace()

        event_file.putmeth('Frames', init_list=['Frame()'])
        for func_name, lists in update_calls.iteritems():
            lists_name = '%s_list' % func_name
            for list_index, list_name in enumerate(lists):
                event_file.putlnc('%s[%s] = &%s;', lists_name, list_index,
                                  list_name)
        event_file.end_brace()

        event_file.putmeth('void set_index', 'int index')
        for frame_index in self.processed_frames:
            event_file.putlnc('static Frame%s frame%s;', frame_index,
                              frame_index)
        event_file.putln('switch (index) {')
        event_file.indent()
        for frame_index in self.processed_frames:
            event_file.putlnc('case %s:', frame_index - 1)
            event_file.indent()
            event_file.putlnc('data = &frame%s;', frame_index)
            event_file.putln('break;')
            event_file.dedent()
        event_file.putln('default:')
        event_file.indent()
        event_file.putln('data = NULL;')
        event_file.putln('break;')
        event_file.dedent()
        event_file.end_brace()
        event_file.putln('data->frame = this;')
        event_file.end_brace()

        if not self.assets.skip:
            handles = []
            for handle, frames in sorted(self.image_frames.iteritems(),
                                         key=lambda (k, v): len(v),
                                         reverse=True):
                handles.append(handle)

            self.assets.write_preload(handles)

        if self.config.use_image_preload():
            for frame_index in self.processed_frames:
                images = self.frame_images.get(frame_index - 1, ())
                event_file.putmeth('void load_frame_%s_images' % frame_index)
                for image in images:
                    event_file.putlnc('get_internal_image(%s)->'
                                      'upload_texture();', image)
                event_file.end_brace()

        event_file.close()

        lists_header.close_guard('CHOWDREN_LISTS_H')
        lists_header.close()

        lists_file.close()

        game = self.games[0]
        header = game.header

        frames_file = self.open_code('framedata.h')
        frames_file.putln('#include "common.h"')
        for frame_index in self.processed_frames:
            frames_file.putlnc('#include "frame%s.h"', frame_index)
        frames_file.putln('')

        frames_file.putmeth('inline void setup_globals',
            'GlobalValues * values', 'GlobalStrings * strings')
        if game.globalValues:
            for index, value in enumerate(game.globalValues.items):
                frames_file.putln('values->set(%s, %s);' % (index, value))
        if game.globalStrings:
            for index, value in enumerate(game.globalStrings.items):
                frames_file.putln(to_c('strings->set(%s, %r);', index,
                    value))
        frames_file.end_brace()

        frames_file.putmeth('inline void setup_keys', 'GameManager * manager')
        controls = game.header.controls.items[0]
        is_keyboard = controls.getControlType() == 'Keyboard'

        if is_keyboard:
            frames_file.putln('manager->control_type = CONTROL_KEYBOARD;')
        else:
            frames_file.putln('manager->control_type = CONTROL_JOYSTICK1;')

        for name in ('up', 'down', 'left', 'right', 'button1', 'button2',
                     'button3', 'button4'):
            key = getattr(controls.keys, name)
            key = convert_key(key.getValue())
            frames_file.putlnc('manager->%s = %s;', name, key)

        frames_file.end_brace()

        frames_file.close()

        strings_file = self.open_code('intern.cpp')
        strings_header = self.open_code('intern.h')
        strings_header.start_guard('CHOWDREN_STRINGS_H')
        strings_header.putln('#include <string>')
        for value, name in self.strings.iteritems():
            strings_file.putlnc('std::string %s(%r, %s);', name, value,
                                len(value), cpp=False)
            strings_header.putlnc('extern std::string %s;', name)

        local_dict = self.config.get_locals()
        write_locals(local_dict, strings_file, strings_header, self)

        strings_header.close_guard('CHOWDREN_STRINGS_H')
        strings_file.close()
        strings_header.close()

        for writer in self.application_writers:
            writer(self)

        # general configuration
        # this is the last thing we should do
        config_file = self.open_code('chowconfig.h')
        config_file.start_guard("CHOWDREN_CONFIG_H")

        # small hack to make applications with Ultimate Fullscreen not open
        # a window before "Make Fullscreen" or "Make Windowed" are called
        # explicitly.
        extension_names = set([item.name for item in  game.extensions.items])
        if 'ultimatefullscreen' not in extension_names:
            config_file.putdefine('CHOWDREN_STARTUP_WINDOW')

        config_file.putdefine('NAME', game.name)
        config_file.putdefine('COPYRIGHT', game.copyright)
        config_file.putdefine('ABOUT', game.aboutText)
        config_file.putdefine('AUTHOR', game.author)
        config_file.putdefine('WINDOW_WIDTH', header.windowWidth)
        config_file.putdefine('WINDOW_HEIGHT', header.windowHeight)
        config_file.putdefine('FRAMERATE', header.frameRate)
        config_file.putdefine('MAX_OBJECT_ID', self.max_type_id)
        config_file.putdefine('MAX_BACK_ID', len(self.back_ids))
        config_file.putdefine('CHOWDREN_FUSION_BUILD', self.build)
        if header.newFlags['SamplesOverFrames']:
            config_file.putln('#define CHOWDREN_SAMPLES_OVER_FRAMES')
        if header.newFlags['VSync']:
            config_file.putdefine('CHOWDREN_VSYNC')
        if PROFILE:
            config_file.putdefine('CHOWDREN_USE_PROFILER')

        # write all options/extension defines
        if self.config.use_iteration_index():
            config_file.putdefine('CHOWDREN_ITER_INDEX')
        if self.config.use_image_preload():
            config_file.putdefine('CHOWDREN_PRELOAD_IMAGES')
        if self.config.use_deferred_collisions():
            config_file.putdefine('CHOWDREN_DEFER_COLLISIONS')

        for (name, value) in self.defines:
            if value is None:
                value = ''
            config_file.putdefine(name, value)

        config_file.close_guard("CHOWDREN_CONFIG_H")
        config_file.close()

        fp.close()

        # format config
        def get_cmake_list(name, sources):
            data = 'set(%s\n' % name
            for filename in sources:
                data += '    %s\n' % filename
            data += ')'
            return data

        self.format_file('resource.rc')

        ext_srcs = ['${CHOWDREN_BASE_DIR}/%s' % item
                   for item in self.extension_sources]
        ext_srcs.sort()

        cmake_defines = []
        for (name, value) in self.defines:
            if value is None:
                value = '1'
            cmake_defines.append('set(%s %s)' % (name, value))

        cmake_defines = '\n'.join(cmake_defines)

        self.format_file('Application.cmake', 'CMakeLists.txt',
                         event_srcs=get_cmake_list('EVENTSRCS',
                                                   event_file.sources),
                         frame_srcs=get_cmake_list('FRAMESRCS',
                                                   self.frame_srcs),
                         object_srcs=get_cmake_list('OBJECTSRCS',
                                                    objects_file.sources),
                         extension_srcs=get_cmake_list('EXTSRCS', ext_srcs),
                         defines=cmake_defines,
                         use_dlls=repr(self.use_dlls).upper())
        self.copy_file('icon.icns', overwrite=False)
        self.info_dict['event_srcs'] = event_file.sources
        self.info_dict['frame_srcs'] = self.frame_srcs
        self.info_dict['object_srcs'] = objects_file.sources
        self.info_dict['ext_srcs'] = list(self.extension_sources)

        with open(self.get_filename('strings.py'), 'wb') as fp:
            fp.write(repr(self.strings.keys()))

        if not self.assets.skip:
            self.write_config(self.info_dict, 'config.py')
            self.assets.write_code()
            self.assets.close()
            self.platform.install()

        # post-mortem stats
        print ''
        print 'stats:'
        print 'ACTIONS'
        print default_writers['actions'].checked.most_common()
        print ''
        print 'CONDITIONS'
        print default_writers['conditions'].checked.most_common()
        print ''
        print 'EXPRESSIONS'
        print default_writers['expressions'].checked.most_common()

    def add_define(self, name, value=None):
        self.defines.add((name, value))

    def create_assets(self, cache):
        self.solid_images = {}
        self.image_indexes = {}
        image_hashes = {}
        new_entries = []
        image_index = 0

        # --- OOM fix (1GB devices) ---
        # Old code decoded every image in the game into an RGBA PIL.Image
        # and kept the WHOLE list (maxrects_images) resident until every
        # worker finished - for a FNAF-sized game (lots of full-frame
        # camera/jumpscare images) that alone blew past 1GB, and it
        # happened before any worker even spawned, so CHOWDREN_WORKERS
        # never helped. The atlas-packing this list was originally for is
        # dead code (see the commented-out texpack.pack_images call below),
        # so nothing downstream actually needs the whole list at once.
        #
        # Fix: spawn workers FIRST, then decode/hash/enqueue one image at a
        # time in a single pass. Each pil_image falls out of scope at the
        # end of its loop iteration instead of being appended anywhere, so
        # it's free to be garbage collected. Combined with loadImages=False
        # on the ExecutableData() call (see __init__), images now only get
        # decompressed right here, one at a time, instead of all upfront.
        from chowdren.imageworker import worker
        # Was hardcoded to 8 regardless of CHOWDREN_WORKERS - on a 1GB device
        # that's 8 concurrent Image.frombytes + astcenc-native subprocess
        # invocations, which OOMs before conversion ever reaches cmake.
        # chowdren-build already computes and exports a RAM-appropriate value;
        # this just has to actually respect it.
        worker_count = int(os.environ.get('CHOWDREN_WORKERS', 8))
        # Bounded queue: without maxsize, if this loop decodes faster than
        # the workers can drain the queue (likely - decode is cheap, ASTC
        # encode isn't), the queue's own internal buffer becomes the new
        # maxrects_images. maxsize forces put() to block once there are
        # worker_count*2 undrained jobs, capping images-in-flight instead.
        in_queue = multiprocessing.Queue(maxsize=worker_count * 2)
        workers = []
        for _ in xrange(worker_count):
            p = multiprocessing.Process(target=worker, args=(in_queue,))
            p.start()
            workers.append(p)

        def get_image_path(image_hash):
            image_hash = image_hash.encode('hex')
            return self.get_filename('image_cache', '%s.dat' % image_hash)

        for game_index, game in enumerate(self.games):
            if not game.images:
                continue
            for image in game.images.itemDict.itervalues():
                # No-op if already loaded; decompresses on demand if
                # loadImages=False left it unloaded. getImageData() below
                # already calls image.unload() internally after this, so
                # the raw buffer never outlives this one iteration.
                image.load()
                pil_image = Image.frombytes('RGBA', (image.width,
                    image.height), image.getImageData())

                handle = (image.handle, game_index)
                colors = pil_image.getcolors(1)
                if colors is not None:
                    color, = colors
                    self.solid_images[handle] = color[1]

                extra_hash = [image.xHotspot, image.yHotspot,
                              image.actionX, image.actionY,
                              image.width, image.height]
                extra_hash = [str(item) for item in extra_hash]
                image_hash = get_hash(pil_image.tobytes() +
                                      '&'.join(extra_hash))

                try:
                    alias = image_hashes[image_hash]
                    self.image_indexes[handle] = alias
                    continue
                except KeyError:
                    pass

                self.image_indexes[handle] = image_index
                image_hashes[image_hash] = image_index
                new_entries.append((image, image_hash))

                cache_path = get_image_path(image_hash)
                if not os.path.isfile(cache_path):
                    p = (image_index * 100) / max(1, len(new_entries))
                    in_queue.put((pil_image.tobytes(), image_index, p,
                                  cache_path, pil_image.size))
                # pil_image (and its raw bytes) fall out of scope here -
                # nothing keeps a reference to it past this iteration.

                image_index += 1

        for i in xrange(worker_count):
            in_queue.put(None)

        for w in workers:
            w.join()

        for i, (image, image_hash) in enumerate(new_entries):
            cache_path = get_image_path(image_hash)
            temp = open(cache_path, 'rb').read()
            arg = (image.width, image.height,
                   image.xHotspot, image.yHotspot,
                   image.actionX, image.actionY, temp)
            self.assets.add_image(*arg)

        self.image_count = image_index

       # sounds
        sound_set = set()
        for game in self.games:
            if not game.sounds:
                continue
            for sound in game.sounds.items:
                if sound.name in sound_set:
                    continue
                sound_set.add(sound.name)
                sound_type = sound.getType()
                extension = {'OGG' : 'ogg', 'WAV' : 'wav', 'MOD' : 'mp3'}[
                    sound_type]
                filename = '%s.%s' % (sound.name, extension)
                data = fix_sound(sound.data, extension)
                filename, data = self.platform.get_sound(filename, data)
                new_extension = os.path.splitext(filename)[1].lower()[1:]
                self.assets.add_sound(sound.name, new_extension, data)

        # files
        for game in self.games:
            files = game.files
            if not files:
                continue
            for packfile in files.items:
                data = str(packfile.data)
                name = packfile.name.replace('\\', '/').split('/')[-1]
                print 'filename:', name
                self.assets.add_file(name, data)

        # shaders
        shader_path = os.path.join(self.base_path, 'shaders')
        for shader in get_shader_programs():
            print 'Adding shader', shader
            vert_path = os.path.join(shader_path, '%s.vert' % shader)
            frag_path = os.path.join(shader_path, '%s.frag' % shader)

            with open(vert_path, 'rb') as fp:
                vert = fp.read()
            with open(frag_path, 'rb') as fp:
                frag = fp.read()

            data = self.platform.get_shader(shader, vert, frag)
            self.assets.add_shader(shader, data)

        for font in self.config.get_fonts():
            path = os.path.join(self.root_path, 'fonts', '%s.dat' % font)
            with open(path, 'rb') as fp:
                data = fp.read()
            self.assets.add_font(font, data)

        self.assets.write_data()

        cache['solid'] = self.solid_images
        cache['indexes'] = self.image_indexes
        cache['count'] = self.image_count
        self.assets.write_cache(cache)

    def write_frame(self, frame_index, frame, event_file, lists_file,
                    lists_header):
        events_ref = '((Frames*)frame)->'
        self.frame_initializers = {}
        self.event_callbacks = {}
        self.container_ids = Counter()
        frame_file = FrameDataWriter(frame_index+1, self)
        frame_class_name = self.frame_class = frame_file.class_name
        frame.load()
        self.current_frame = frame
        self.current_frame_index = frame_index
        self.config.init_frame(frame)
        self.processed_frames.append(frame_index + 1)

        startup_instances = []
        self.multiple_instances = set()
        all_startup_infos = set()
        startup_set = set()
        self.static_instances = {}
        object_writers = []

        self.system_object = SystemObject(self)
        object_writers.append(self.system_object)

        for instance in getattr(frame.instances, 'items', ()):
            frameitem = instance.getObjectInfo(self.game.frameItems)
            obj = (frameitem.handle, frameitem.objectType)
            all_startup_infos.add(obj)
            try:
                object_writer = self.get_object_writer(obj)
                if object_writer not in object_writers:
                    object_writers.append(object_writer)
                if object_writer.static:
                    self.static_instances[object_writer] = instance
            except KeyError:
                print 'could not get obj', obj
                continue
            if object_writer.static:
                continue
            if not self.is_valid_object(obj):
                continue
            common = frameitem.properties.loader
            try:
                create_startup = not common.flags['DoNotCreateAtStart']
            except AttributeError:
                create_startup = True
            if create_startup and instance.parentType == NONE_PARENT:
                if frameitem in startup_set:
                    self.multiple_instances.add(obj)
                startup_set.add(frameitem)
                startup_instances.append((instance, frameitem))
            if not create_startup:
                self.multiple_instances.add(obj)
            elif object_writer.has_autodestruct():
                self.multiple_instances.add(obj)

        events = frame.events

        self.qualifier_names = {}
        self.qualifiers = {}
        self.qualifier_types = {}
        qualifier_setup = {}
        for qualifier in events.qualifier_list:
            qual_obj = (qualifier.objectInfo, qualifier.type)
            object_infos = qualifier.resolve_objects(self.game.frameItems)
            object_infos = tuple(
                [self.filter_object_type((info, qualifier.type))
                for info in object_infos])
            self.qualifiers[qual_obj] = object_infos
            self.qualifier_types[qual_obj] = qualifier.type

            instances = set()
            setup_instances = []
            for obj in object_infos:
                obj_list = '&' + self.get_object_list(obj)
                instances.add(obj_list)
                if obj not in all_startup_infos:
                    continue
                setup_instances.append(obj_list)
            instances = list(instances)
            instances.sort()
            instances = tuple(instances)

            if instances in self.objs_to_qualifier:
                name = self.objs_to_qualifier[instances]
            else:
                name = 'qualifier_%s' % len(self.objs_to_qualifier)
                self.objs_to_qualifier[instances] = name
                event_file.add_member('QualifierList %s' % name)

            qualifier_setup[name] = setup_instances
            self.qualifier_names[qual_obj] = name

        generated_groups = self.generated_groups = defaultdict(list)
        always_groups = []
        always_groups_dict = self.always_groups_dict = defaultdict(list)
        action_dict = self.action_dict = defaultdict(list)
        current_container = None
        self.containers = containers = {}
        changed_containers = set()

        event_items = events.items

        group_index = 1
        for group in event_items:
            first_condition = group.conditions[0]
            name = self.get_condition_name(first_condition)
            if name == 'NewGroup':
                group_loader = first_condition.items[0].loader
                new_container = EventContainer(group_loader.name,
                    group_loader.flags['Inactive'], current_container,
                    self)
                if current_container:
                    current_container.add_child(new_container)
                current_container = new_container
                containers[group_loader.offset] = current_container
                always_groups.append(ContainerMark(current_container, name))
                continue
            elif name == 'GroupEnd':
                always_groups.append(ContainerMark(current_container, name))
                current_container = current_container.parent
                continue

            # or groups
            condition_groups = []
            conditions = []
            is_never = False
            not_always = None
            or_type = None
            for condition in (group.conditions + [None]):
                if condition is None:
                    name = 'End'
                else:
                    name = condition.getName()
                if name == 'Never':
                    is_never = True
                if name in ('OrFiltered', 'OrLogical', 'End'):
                    if name != 'End':
                        or_type = name
                    if not_always:
                        conditions.append(not_always)
                        not_always = None
                    if not is_never:
                        condition_groups.append(conditions)
                    conditions = []
                    is_never = False
                else:
                    condition_writer = self.get_condition_writer(condition)
                    condition_writer.container = current_container
                    condition_writer.group = group
                    if name == 'NotAlways':
                        # move NotAlways to end of condition list
                        not_always = condition_writer
                    else:
                        conditions.append(condition_writer)

            actions = []
            for action in group.actions:
                action_writer = self.get_action_writer(action)
                action_writer.container = current_container
                actions.append(action_writer)

                action_name = self.get_action_name(action)
                action_dict[action_name].append(action_writer)
                if action_name in ('CreateObject', 'Shoot', 'ShootToward',
                                   'DisplayText', 'Destroy'):
                    if action_name == 'Destroy':
                        create_info = (action.objectInfo,
                                       action.objectType)
                    else:
                        info = (action.items[0].loader.objectInfo, None)
                        create_info = self.filter_object_type(info)
                    if create_info[0] == 0xFFFF:
                        # the case for DisplayText
                        create_info = (action.objectInfo,
                                       action.objectType)
                    create_infos = self.resolve_qualifier(create_info)
                    for create_info in create_infos:
                        if self.get_object_writer(create_info).static:
                            continue
                        self.multiple_instances.add(create_info)
                elif action_name in ('DeactivateGroup',
                                     'ActivateGroup'):
                    pointer = action.items[0].loader.pointer
                    changed_containers.add(pointer)

            always_group_index = None
            generated_group_index = None
            new_always_groups = []
            all_groups = []
            for or_index, conditions in enumerate(condition_groups):
                if not conditions:
                    continue
                first_writer = conditions[0]
                first_condition = first_writer.data

                is_always = first_condition.flags['Always']
                force_always = (first_writer.is_always is not None and
                                first_writer.is_always)

                if is_always:
                    if always_group_index is None:
                        always_group_index = group_index
                        group_index += 1
                    new_group_index = always_group_index
                else:
                    if generated_group_index is None:
                        generated_group_index = group_index
                        group_index += 1
                    new_group_index = generated_group_index

                new_group = EventGroup(self, conditions, actions,
                    current_container, new_group_index,
                    or_index, not_always, or_type)
                all_groups.append(new_group)
                name = self.get_condition_name(first_condition)

                new_group.set_or_generated(not is_always)
                new_group.in_place = first_writer.in_place
                new_group.pre_event = first_writer.pre_event
                new_group.post_event = first_writer.post_event
                new_group.precedence = first_writer.precedence

                if is_always or force_always:
                    new_always_groups.append(new_group)
                    new_group.local_id = len(always_groups_dict[name])+1

                    for cond in new_group.conditions:
                        name = self.get_condition_name(cond.data)
                        always_groups_dict[name].append(new_group)
                else:
                    new_group.set_generated(True)
                    key = None
                    if first_condition.getType() == EXTENSION_BASE:
                        num = first_condition.getExtensionNum()
                        if num >= 0:
                            key = (first_condition.objectType, num)
                    if key is None:
                        key = name
                    new_group.local_id = len(generated_groups[key])+1
                    generated_groups[key].append(new_group)

            new_always_groups.sort(key=lambda x: x.global_id)
            always_groups.extend(new_always_groups)


        for obj in all_startup_infos:
            if obj in self.multiple_instances:
                continue
            self.get_object_writer(obj).disable_kill = True

        for k, v in containers.iteritems():
            if k in changed_containers:
                v.is_static = False
                continue
            if v.inactive:
                # never activated!
                continue
            if v.is_static is not None:
                continue
            v.is_static = True

        for container in containers.values():
            if container.is_static:
                continue
            event_file.add_member('bool %s' % container.code_name,
                                  not container.inactive)

        # since fire_write_callbacks can be called whenever, we need to
        # keep an initialization writer handy
        start_name = 'on_frame_%s_init' % (frame_index + 1)
        start_writer = self.start_writer = CodeWriter()
        start_writer.add_member = event_file.add_member

        frame_file.putmeth(frame_class_name, init_list=['FrameData()'])
        frame_file.putlnc('name = %r;', frame.name)
        frame_file.end_brace()

        # object writer custom stuff
        startup_images = set()
        for object_writer in object_writers:
            object_writer.write_frame(event_file)
            for image in object_writer.get_images():
                handle = self.get_image_handle(
                    image, game_index=object_writer.game_index)
                startup_images.add(handle)
                self.image_frames[handle].add(frame_index)

        self.frame_images[frame_index] = startup_images

        frame_file.putmeth('void init')
        frame_file.putlnc('%s%s();', events_ref, start_name)
        frame_file.end_brace()

        # frame setup
        frame_width = frame.width
        frame_height = frame.height
        virtual_right = frame.right
        if virtual_right == -1:
            virtual_right = 0x7FFFF000
        virtual_bottom = frame.bottom
        if virtual_bottom == -1:
            virtual_bottom = 0x7FFFF000
        virtual_width = virtual_right - frame.left
        virtual_height = virtual_bottom - frame.top
        # if virtual_width not in (0x7FFFF000, frame_width):
        #     raise NotImplementedError()
        # if virtual_height not in (0x7FFFF000, frame_height):
        #     print virtual_height, frame_height
        #     raise NotImplementedError()
        start_writer.putlnc('index = %s;', frame_index)
        start_writer.putlnc('width = %s;', frame_width)
        start_writer.putlnc('height = %s;', frame_height)
        start_writer.putlnc('virtual_width = %s;', virtual_width)
        start_writer.putlnc('virtual_height = %s;', virtual_height)
        start_writer.putlnc('background_color = %s;',
                            make_color(frame.background))
        if frame.flags['TimedMovements']:
            timer_base = frame.movementTimer
        else:
            timer_base = 0
        start_writer.putln('timer_base = %s;' % timer_base)

        # load images on startup
        if self.config.use_image_flush(frame):
            start_writer.putlnc('reset_image_cache();')

        if self.config.use_image_preload():
            start_writer.putlnc('load_frame_%s_images();', frame_index + 1)

        if self.config.use_image_flush(frame):
            start_writer.putlnc('flush_image_cache();')

        start_writer.putlnc('layers.resize(%s);', len(frame.layers.items))

        for layer_index, layer in enumerate(frame.layers.items):
            visible = not layer.flags['ToHide']
            wrap_horizontal = layer.flags['WrapHorizontally']
            wrap_vertical = layer.flags['WrapVertically']
            start_writer.putlnc('layers[%s].init(%s, %s, %s, %s, %s, %s);',
                                layer_index, layer_index,
                                layer.xCoefficient, layer.yCoefficient,
                                visible, wrap_horizontal, wrap_vertical)

        start_writer.putraw('#ifdef CHOWDREN_HAS_MRT')
        for layer_index, layer in enumerate(frame.layers.items):
            if layer.name.endswith('(DRC)'):
                remote_type = 'CHOWDREN_REMOTE_TARGET'
            elif layer.name.endswith('(Hybrid)'):
                remote_type = 'CHOWDREN_HYBRID_TARGET'
            else:
                continue
            start_writer.putlnc('layers[%s].set_remote(%s);', layer_index,
                                remote_type)
        start_writer.putraw('#endif')

        start_writer.putraw('#ifdef CHOWDREN_IS_3DS')
        for layer_index, layer in enumerate(frame.layers.items):
            depth = self.config.get_depth(layer)
            if depth is None:
                continue
            start_writer.putlnc('layers[%s].depth = float(%s);', layer_index,
                                depth)
        start_writer.putraw('#endif')

        # set up qualifiers
        for name, instances in qualifier_setup.iteritems():
            start_writer.putlnc('static ObjectList* '
                                '%s_instances[] = {%s, NULL};',
                                name, ', '.join(instances))
            start_writer.putlnc('%s.set(%s, &%s_instances[0]);', name,
                                len(instances), name)

        startup_instances = self.config.get_startup_instances(
            startup_instances)
        self.startup_instances = startup_instances

        for instance, frameitem in startup_instances:
            obj = (frameitem.handle, frameitem.objectType)
            object_writer = self.get_object_writer(obj)
            if object_writer.is_background():
                method = 'add_background_object'
                object_func = 'create_%s' % get_method_name(
                    self.get_object_name(obj))
                start_writer.putlnc('%s(%s(%s, %s), %s);',
                                    method, object_func, instance.x,
                                    instance.y, instance.layer)
                continue
            self.create_object(obj, instance.x, instance.y,
                               instance.layer, None, start_writer)

        for object_writer in object_writers:
            object_writer.write_start(start_writer)

        frame_end_groups = generated_groups.pop('EndOfFrame', None)

        if frame_end_groups:
            end_name = 'on_frame_%s_end' % (frame_index + 1)
            end_name = self.write_generated(end_name, event_file,
                                            frame_end_groups)

        frame_file.putmeth('void on_end')
        if frame_end_groups:
            frame_file.putlnc('%s%s();', events_ref, end_name)
        frame_file.putlnc('%sreset();', events_ref)
        frame_file.end_brace()

        app_end_groups = generated_groups.pop('EndOfApplication', None)
        if app_end_groups:
            end_name = 'on_app_%s_end' % (frame_index + 1)
            end_name = self.write_generated(end_name, event_file,
                                            app_end_groups)

            frame_file.putmeth('void on_app_end')
            frame_file.putlnc('%s%s();', events_ref, end_name)
            frame_file.end_brace()

        # write event callbacks
        frame_file.putmeth('void event_callback', 'int id')
        if self.event_callbacks:
            frame_file.putln('switch (id) {')
            frame_file.indent()
            for event_id, name in self.event_callbacks.iteritems():
                frame_file.putln('case %s:' % event_id)
                frame_file.indent()
                frame_file.putlnc('%s%s();', events_ref, name)
                frame_file.putln('break;')
                frame_file.dedent()
            frame_file.end_brace()
        frame_file.end_brace()

        # write 'always' event subfunctions
        group_index = 0
        call_groups = []
        first_groups = []
        last_groups = []
        pre_groups = []

        while True:
            try:
                group = always_groups[group_index]
            except IndexError:
                break

            if (not group.is_container_mark and group.or_generated and not
                    group.in_place):
                if group.pre_event:
                    pre_groups.append(group)
                elif group.post_event:
                    last_groups.append(group)
                else:
                    first_groups.append(group)
            else:
                call_groups.append(group)

            if group.is_container_mark:
                group_index += 1
                continue

            or_groups = []
            while True:
                try:
                    new_group = always_groups[group_index]
                except IndexError:
                    break
                if (new_group.is_container_mark or
                        new_group.global_id != group.global_id):
                    break

                or_groups.append(new_group)
                group_index += 1

            self.write_event_function(event_file, or_groups)

        # write main 'always' handler
        handle_name = 'handle_frame_%s_events' % (frame_index+1)
        frame_file.putmeth('void handle_events')
        frame_file.putlnc('%s%s();', events_ref, handle_name)
        frame_file.end_brace()

        event_file.putmeth('void %s' % handle_name)
        event_file.putlnc('test_collisions_%s();', frame_index)

        end_markers = []

        def cmp_group(a, b):
            v = cmp(a.precedence, b.precedence)
            if v != 0:
                return v
            return cmp(a.global_id, b.global_id)

        for group_list in (first_groups, last_groups, pre_groups):
            group_list.sort(cmp=cmp_group)
        call_groups = first_groups + ['check'] + call_groups + last_groups

        if PROFILE_GROUPS:
            prof_ids = defaultdict(int)

        for group in call_groups:
            if group == 'check':
                event_file.putlnc('if (next_frame != -1) return;')
                continue
            if group.is_container_mark:
                container = group.container
                if container.is_static:
                    continue
                if group.mark == 'NewGroup':
                    if PROFILE_GROUPS:
                        prof = get_method_name(container.name)
                        prof_ids[prof] += 1
                        prof = '%s_%s' % (prof, prof_ids[prof])
                        event_file.putlnc('PROFILE_BEGIN(%s);', prof)

                    event_file.putln('if (!%s) goto %s;' % (
                        container.code_name, container.end_label))
                    end_markers.insert(0, container.end_label)
                    self.container_tree.insert(0, container)
                elif group.mark == 'GroupEnd':
                    end_markers.remove(container.end_label)
                    event_file.put_label(container.end_label)
                    self.container_tree.remove(container)

                    if PROFILE_GROUPS:
                        event_file.putlnc('PROFILE_END();')
                continue
            event_file.putlnc('%s();', group.event_name)
        for end_marker in end_markers:
            event_file.put_label(end_marker)

        self.config.write_frame_post(event_file)

        event_file.end_brace()

        # pre-events
        handle_name = 'handle_frame_%s_pre_events' % (frame_index+1)
        frame_file.putmeth('void handle_pre_events')
        frame_file.putlnc('%s%s();', events_ref, handle_name)
        frame_file.end_brace()

        event_file.putmeth('void %s' % handle_name)

        for group in pre_groups:
            event_file.putlnc('%s();', group.event_name)

        event_file.end_brace()

        # start of frame
        event_start_name = None
        start_groups = generated_groups.pop('StartOfFrame', None)
        if start_groups:
            event_start_name = 'on_frame_%s_start_events'
            event_start_name = event_start_name % (frame_index + 1)
            event_start_name = self.write_generated(event_start_name,
                                                    event_file,
                                                    start_groups)
            frame_file.putmeth('void on_start')
            frame_file.putlnc('%s%s();', events_ref, event_start_name)
            frame_file.end_brace()

        # write any added defaults
        for name, default in self.frame_initializers.iteritems():
            event_file.add_member(name)
            if default is None:
                continue
            name = name.rsplit(' ', 1)[-1]
            start_writer.putlnc('%s = %s;', name, default)

        fade = frame.fadeIn
        if fade:
            if fade.duration == 0:
                print 'invalid fade duration:', fade.duration
            else:
                transition.write(start_writer, fade, False)

        event_file.putmeth('void %s' % start_name)
        event_file.putcode(start_writer)
        event_file.end_brace()

        frame_file.close()
        frame.close()

        if generated_groups:
            missing_groups = []
            for k, v in generated_groups.iteritems():
                if isinstance(k, str):
                    missing_groups.append(k)
                    continue
                object_type, num = k
                object_class = self.get_object_class(object_type)
                name = self.get_condition_name(v[0].conditions[0].data)
                missing_groups.append((object_class, num, name))
            print 'unimplemented generated groups in %r: %r' % (
                frame.name, missing_groups)

        self.frame_srcs.extend(frame_file.sources)

    def write_objects(self, items, objects_file, objects_header,
                      lists_header):
        for frameitem in items:
            self.current_write_object = frameitem
            name = frameitem.name
            self.name_to_item[(name, self.game_index)] = frameitem
            handle = (frameitem.handle, frameitem.objectType, self.game_index)
            if name is None:
                class_name = 'Object%s' % handle[0]
            else:
                class_name = (get_class_name(name) + '_' +
                              str(self.object_class_index))
            self.object_class_index += 1
            object_type = frameitem.properties.objectType
            try:
                object_writer = self.get_object_impl(object_type)(
                    self, frameitem)
            except (KeyError, AttributeError, NotImplementedError):
                print 'not implemented:', repr(frameitem.name), object_type,
                print handle
                continue
            object_writer.new_class_name = class_name
            object_writer.object_type = object_type
            object_writer.handle = handle
            for define in object_writer.defines:
                self.add_define(define)
            self.application_writers.add(object_writer.write_application)
            self.all_objects[handle] = object_writer
            type_handle = (handle[0], self.game_index)
            self.object_types[type_handle] = object_type
            if extra.is_special_object(name):
                continue
            self.extension_includes.update(object_writer.get_includes())
            self.extension_sources.update(object_writer.get_sources())
            if object_writer.static or object_writer.class_name == 'Undefined':
                continue

            if object_writer.is_static_background():
                object_type_id = 'BACKGROUND_TYPE'
            else:
                object_type_id = '%s_type' % class_name

            object_writer.type_id = object_type_id
            object_writer.game_index = self.game_index

            self.config.init_obj(object_writer)
            object_code = self.write_object(object_writer).get_data()

            object_hash_data = object_code.replace(class_name, '')
            object_hash_data = object_hash_data.replace(class_name.lower(), '')
            object_hash = get_hash(object_hash_data)

            try:
                other = self.object_cache[object_hash]
                class_name = other.new_class_name
                self.all_objects[handle] = other
                self.object_types[type_handle] = other.object_type
                self.object_names[handle] = class_name

                try:
                    self.object_lists[handle] = self.object_lists[other.handle]
                except KeyError:
                    pass
                continue
            except KeyError:
                pass

            self.object_cache[object_hash] = object_writer

            for line in object_code.splitlines():
                objects_file.putln(line)

            self.object_names[handle] = class_name

            if not object_writer.is_static_background():
                list_id = object_writer.get_list_id()
                if list_id in self.object_list_ids:
                    type_int, type_list = self.object_list_ids[list_id]
                    self.object_lists[handle] = type_list
                else:
                    type_int = self.type_ids.next()
                    type_list = get_method_name(class_name) + '_instances'
                    self.object_list_ids[list_id] = (type_int, type_list)
                    self.object_lists[handle] = type_list
                    list_ref = 'instances.items[%s]' % object_type_id
                    lists_header.putlnc('#define %s %s', type_list, list_ref)

                objects_header.putlnc('#define %s %s',
                                      object_type_id, type_int)

            object_func = 'create_%s' % get_method_name(class_name)

            objects_header.putln('FrameObject * %s(int x, int y);'
                                 % object_func)
            objects_file.putmeth('FrameObject * %s' % object_func,
                                 'int x', 'int y')
            objects_file.putlnc('return new (%s::pool.create()) %s(x, y);',
                                object_writer.class_name, class_name)
            objects_file.end_brace()

            objects_file.next()

            self.class_names.add(object_writer.class_name)

    def write_object(self, object_writer):
        class_name = object_writer.new_class_name
        object_type_id = object_writer.type_id
        frameitem = object_writer.data
        common = object_writer.common
        subclass = object_writer.class_name
        objects_file = CodeWriter()
        object_writer.write_pre(objects_file)
        objects_file.putclass(class_name, subclass)
        objects_file.put_access('public')
        object_writer.write_constants(objects_file)
        parameters = ['x', 'y', object_type_id]
        extra_parameters = [str(item)
            for item in object_writer.get_parameters()]
        parameters = ', '.join(extra_parameters + parameters)
        init_list = [to_c('%s(%s)', subclass, parameters)]
        for name, value in object_writer.get_init_list():
            init_list.append(to_c('%s(%r)', name, value))
        init_list = ', '.join(init_list)
        objects_file.putln(to_c('%s(int x, int y) : %s', class_name,
            init_list))
        objects_file.start_brace()

        # write qualifiers in comments so the object aliases properly
        try:
            qualifiers = common.qualifiers[:]
            qualifiers.sort()
            qualifiers = [str(item) for item in qualifiers]
            qualifiers = ', '.join(qualifiers)
            objects_file.putlnc('// qualifiers: %s', qualifiers)
        except AttributeError:
            pass

        objects_file.putraw('#ifndef NDEBUG')
        objects_file.putln(to_c('name = %r;', frameitem.name))
        objects_file.putraw('#endif')

        if object_writer.is_background():
            objects_file.putln('flags |= BACKGROUND;')
            if object_writer.is_background_collider():
                objects_file.putln('flags |= BACKGROUND_COL;')

        if not object_writer.is_visible():
            objects_file.putln('set_visible(false);')

        if not object_writer.is_scrolling():
            objects_file.putln('flags &= ~SCROLL;')

        object_writer.write_init(objects_file)

        shader_name = None
        if frameitem.shaderId is not None:
            ink_effect = SHADER_EFFECT
        else:
            ink_effect = frameitem.inkEffect
        if ink_effect:
            if ink_effect & HWA_EFFECT or ink_effect == SHADER_EFFECT:
                parameter = frameitem.inkEffectValue
                b, g, r = get_color_tuple(parameter)
                a = (parameter & 0xFF000000) >> 24
                if object_writer.has_color:
                    objects_file.putlnc('blend_color.a = %s;', a)
                else:
                    objects_file.putln('blend_color = %s;' % make_color(
                        (r, g, b, a)))
                ink_effect &= ~HWA_EFFECT
            if ink_effect == NONE_EFFECT:
                pass
            elif ink_effect == SHADER_EFFECT:
                shader_data = self.game.shaders.items[frameitem.shaderId]
                shader_name = shader_data.name
            elif ink_effect == SEMITRANSPARENT_EFFECT:
                a = min(255, (128 - frameitem.inkEffectValue) * 2)
                if object_writer.has_color:
                    objects_file.putlnc('blend_color.a = %s;', a)
                else:
                    objects_file.putlnc('blend_color = %s;', make_color(
                        (255, 255, 255, a)))
            elif ink_effect in INK_EFFECTS:
                shader_name = INK_EFFECTS[ink_effect]
            elif shader_name is None:
                raise NotImplementedError(
                    'unknown inkeffect: %s' % ink_effect)
        if shader_name is not None:
            objects_file.putln('set_shader(%s);' % shader.get_name(
                shader_name))
        if ink_effect == SHADER_EFFECT:
            shader_data = self.game.shaders.items[frameitem.shaderId]
            parameters = shader_data.get_parameters()
            values = frameitem.items
            if shader_data.parameters is not None:
                for index, parameter in enumerate(shader_data.parameters):
                    try:
                        reader = values[index]
                        reader.seek(0)
                        if parameter.type == INT:
                            value = reader.readInt()
                        elif parameter.type == FLOAT:
                            value = reader.readFloat()
                        elif parameter.type == INT_FLOAT4:
                            value = make_color((reader.readByte(True),
                                reader.readByte(True),
                                reader.readByte(True),
                                reader.readByte(True)))
                        elif parameter.type == IMAGE:
                            value = self.get_image(reader.readShort(), False)
                        else:
                            print 'shader parameter type not supported:',
                            print parameter.type
                            continue
                            raise NotImplementedError
                    except IndexError:
                        # happens for e.g. DropShadow.fx
                        value = 0
                    parameters[parameter.name].value = value
            for name, value in parameters.iteritems():
                objects_file.putln(to_c('set_shader_parameter(%r, %s);',
                    name, value.value))

        if hasattr(common, 'movements') and common.movements:
            movements = common.movements.items
            self.write_movements(objects_file, object_writer, movements)

        object_writer.load_alterables(objects_file)
        objects_file.end_brace()

        object_writer.write_class(objects_file)
        object_writer.write_internal_class(objects_file)
        # write event callbacks
        if object_writer.event_callbacks:
            for v in object_writer.event_callbacks.iteritems():
                name, event_id = v
                objects_file.putmeth('void %s' % name)
                objects_file.putln('frame->event_callback(%s);' % event_id)
                objects_file.end_brace()

        dtor = object_writer.has_dtor()
        internal_dtor = object_writer.has_internal_dtor()
        has_dtor = dtor or internal_dtor

        if has_dtor:
            objects_file.putmeth('~%s' % class_name)

            if dtor:
                object_writer.write_dtor(objects_file)

            if internal_dtor:
                object_writer.write_internal_dtor(objects_file)
            objects_file.end_brace()

            objects_file.putmeth('void dealloc')
            objects_file.putlnc('this->%s::~%s();', class_name, class_name)
            objects_file.putlnc('%s::pool.destroy(this);', subclass)
            objects_file.end_brace()

        if PROFILE_OBJECTS:
            if object_writer.update:
                objects_file.putmeth('void update')
                objects_file.putlnc('PROFILE_BLOCK(%s_update);',
                                    class_name)
                objects_file.putlnc('%s::update();', subclass)
                objects_file.end_brace()

        depth = self.config.get_object_depth(object_writer)
        if depth is not None or PROFILE_DRAW:
            objects_file.putmeth('void draw')
            if PROFILE:
                objects_file.putlnc('PROFILE_BLOCK(%s_draw);', class_name)
            if depth is not None:
                objects_file.putlnc('Render::set_depth(%s);', depth)
            objects_file.putlnc('%s::draw();', subclass)
            if depth is not None:
                objects_file.putlnc('Render::set_depth(0.0f);')
            objects_file.end_brace()

        objects_file.end_brace(True)

        object_writer.write_post(objects_file)
        object_writer.write_internal_post(objects_file)

        return objects_file

    def get_solid_image(self, value):
        return self.solid_images[(value, self.game_index)]

    def get_image(self, value, pointer=True, game_index=None):
        value = self.get_image_handle(value, game_index)
        func = 'get_internal_image'
        ret = '%s(%s)' % (func, value)
        if not pointer:
            ret = '(*%s)' % ret
        return ret

    def get_image_handle(self, value, game_index=None):
        if game_index is None:
            game_index = self.game_index
        value = (value, game_index)
        try:
            return self.image_indexes[value]
        except KeyError:
            return self.config.get_missing_image(value)

    def iterate_groups(self, groups):
        index = 0

        while True:
            try:
                group = groups[index]
            except IndexError:
                break

            if group.is_container_mark:
                index += 1
                continue

            or_groups = []
            while True:
                try:
                    new_group = groups[index]
                except IndexError:
                    break
                if (new_group.is_container_mark or
                        new_group.global_id != group.global_id):
                    break

                or_groups.append(new_group)
                index += 1

            yield or_groups

    def get_iter_type(self, obj):
        if obj in self.saved_selections:
            return 'SavedIterator'
        if is_qualifier(obj[0]):
            return 'QualifierIterator'
        return 'ObjectIterator'

    @contextlib.contextmanager
    def iterate_object(self, *arg, **kw):
        self.start_object_iteration(*arg, **kw)
        yield
        self.end_object_iteration(*arg, **kw)

    def start_object_iteration(self, object_info, writer, name='it',
                               copy=True):
        if (self.has_single(object_info)
                or not self.has_multiple_instances(object_info)):
            writer.start_brace()
            return
        getter = self.create_list(object_info, writer)
        if copy:
            list_name = 'extra_%s' % self.get_object_list(object_info)
            writer.putlnc('SavedSelection %s(%s);', list_name, getter)
            iter_type = 'SavedIterator'
        else:
            list_name = getter
            iter_type = self.get_iter_type(object_info)
        self.set_iterator(object_info, list_name, '*' + name)
        writer.putlnc('for (%s %s(%s); !%s.end(); ++%s) {',
                      iter_type, name, list_name, name, name)
        writer.indent()

    def end_object_iteration(self, object_info, writer, name = 'it',
                             copy=True):
        writer.end_brace()
        self.set_iterator(None)

    def start_flat_iteration(self, object_info, writer, name='it'):
        if (self.has_single(object_info)
                or not self.has_multiple_instances(object_info)):
            writer.start_brace()
            return
        
        list_name = self.get_object_list(object_info)
        is_qual = is_qualifier(object_info[0])
        if is_qual:
            writer.putlnc('for (int i = 0; i < %s.count; i++)', list_name)
            list_name = '(*%s.items[i])' % list_name
        writer.putlnc('for (ObjectList::iterator %s = %s.begin(); '
                      '%s != %s.end(); ++%s) {',
                      name, list_name, name, list_name, name)
        self.set_iterator(object_info, list_name, '%s->obj' % name)
        writer.indent()

    def end_flat_iteration(self, object_info, writer, name='it'):
        writer.end_brace()
        self.set_iterator(None)

    def set_iterator(self, object_info, object_list=None, name='*it'):
        self.iterated_object = object_info
        # self.iterated_list = object_list
        if object_info is None:
            self.iterated_name = None
            self.iterated_index = None
            return
        self.iterated_name = name
        if object_list is None:
            self.iterated_index = '0'
        else:
            it = name.replace('*', '')
            self.iterated_index = '%s.current_index' % it

    def create_object(self, obj, x, y, layer, object_name, writer):
        name = self.get_object_name(obj)
        obj_create_func = 'create_%s' % get_method_name(name)
        arguments = [str(x), str(y)]
        if object_name:
            prefix = '%s = ' % object_name
        else:
            prefix = ''
        writer.putlnc('%sadd_object(%s(%s), %s);', prefix,
                      obj_create_func, ', '.join(arguments), layer)

    def begin_events(self):
        pass

    def set_object(self, obj, name):
        self.has_single_selection[obj] = name

    def set_list(self, obj, name):
        self.has_selection[obj] = name

    def clear_selection(self):
        self.has_selection = {}
        self.has_single_selection = {}
        self.saved_selections = set()

    def write_container_check(self, group, writer):
        container = group.container
        if group.generated or not container:
            return
        for item in container.tree:
            if item.is_static:
                continue
            writer.putln('if (!%s) goto %s;' % (
                item.code_name, item.end_label))

    def get_container_check(self, container):
        groups = []
        for item in container.tree:
            if item.is_static:
                continue
            groups.append(item.code_name)
        if not groups:
            return 'true'
        return ' && '.join(groups)

    def write_movements(self, writer, obj, movements):
        count = len(movements)
        has_list = count > 1
        if has_list:
            writer.putlnc('movement_count = %s;', count)
            writer.putlnc('movements = new Movement*[%s];', count)
        has_init = False
        global_move_start = True
        for movement_index, movement in enumerate(movements):
            def set_start_dir(direction):
                if movement_index != 0 or not direction:
                    return
                writer.putlnc('set_direction(%s);',
                              parse_direction(direction))

            movement_name = movement.getName()
            move_start = movement.movingAtStart != 0
            if movement_name == 'Extension':
                movement_name = movement.loader.name.lower()
            elif movement_index == 0:
                global_move_start = move_start
            set_start_dir(movement.directionAtStart)
            sets = {}
            extra = []
            if movement_name == 'Ball':
                movement_class = 'BallMovement'
                sets['max_speed'] = movement.loader.speed
                sets['deceleration'] = movement.loader.deceleration
                extra.append('randomizer = %s' % movement.loader.randomizer)
            elif movement_name == 'Path':
                movement_class = 'PathMovement'
                path = movement.loader
                loop = bool(path.loop)
                reposition = bool(path.repositionAtEnd)
                reverse = bool(path.reverseAtEnd)
                end_x = end_y = 0
                for i, step in enumerate(path.steps):
                    if reposition:
                        end_x += step.destinationX
                        end_y += step.destinationY
                    args = []
                    args.append(step.speed)
                    args.append(step.destinationX)
                    args.append(step.destinationY)
                    args.append(step.cosinus)
                    args.append(step.sinus)
                    args.append(step.length)
                    args.append(step.direction)
                    args.append(step.pause)
                    args = [to_c('%r', arg) for arg in args]
                    extra.append('add_node(%s)' % ', '.join(args))
                    if step.name:
                        extra.append(to_c('add_named_node(%s, %r)', i,
                                          step.name))
                sets['path'] = to_c('%s, %s, %s, %s', loop, reverse,
                                    end_x, end_y)
            elif movement_name == 'EightDirections':
                movement_class = 'EightDirections'
                sets['max_speed'] = movement.loader.speed
                sets['deceleration'] = movement.loader.deceleration
                sets['acceleration'] = movement.loader.acceleration
            elif movement_name == 'pinball':
                movement_class = 'PinballMovement'
                data = movement.loader.data
                data.skipBytes(1)
                speed = data.readInt()
                deceleration = data.readInt()
                gravity = data.readInt()
                set_start_dir(data.readInt())
                flags = data.readInt()
                sets['max_speed'] = speed
                sets['deceleration'] = deceleration
                sets['gravity'] = gravity
            elif movement_name == 'clickteam-vector':
                movement_class = 'VectorMovement'
                data = movement.loader.data
                data.skipBytes(1)

                flags = data.readInt(True)
                stopped = (flags & 1) == 0
                handle_direction = (flags & 2) != 0
                speed = data.readInt(True)
                angle = data.readInt(True)
                gravity = data.readInt(True)
                gravity_angle = data.readInt(True)
            else:
                if movement_name != 'Static':
                    print 'movement', movement_name, 'not implemented for',
                    print obj.data.name
                if not has_list:
                    break
                movement_class = 'StaticMovement'
            if has_list:
                name = 'movements[%s]' % movement_index
            else:
                name = 'movement'
            has_init = True
            writer.putlnc('%s = new %s(this);', name, movement_class)
            writer.putlnc('%s->index = %s;', name, movement_index)
            if move_start:
                writer.putlnc('%s->flags |= Movement::MOVE_AT_START;',
                              name)
            name = '((%s*)%s)' % (movement_class, name)
            for k, v in sets.iteritems():
                writer.putlnc('%s->set_%s(%s);', name, k, v)
            for line in extra:
                writer.putlnc('%s->%s;', name, line)

        if has_init:
            if has_list:
                writer.putlnc('set_movement(0);')
            else:
                writer.putlnc('((%s*)movement)->init();', movement_class)
            obj.movement_count = count
        else:
            obj.movement_count = 0

    def add_frame_members(self, event_hash):
        try:
            members = self.event_frame_initializers[event_hash]
        except KeyError:
            return
        for k, v in members:
            self.frame_initializers[k] = v

    def get_event_hash(self, data):
        if self.use_dlls:
            event_hash = self.event_hash_id
            self.event_hash_id += 1
        else:
            event_hash = get_hash(data)
        return event_hash

    def write_event(self, writer, group, triggered=False):
        """
        XXX deprecated, use write_events instead (for OR groups)
        """
        self.current_groups = [group]
        data = self.get_event_code(group, triggered)
        group.data_hash = self.get_event_hash(data)
        group.fire_write_callbacks()
        data = group.filter(data)

        for line in data.splitlines():
            writer.putln(line)

    def write_event_function(self, writer, groups, triggered=False):
        selections = self.has_single_selection
        self.current_groups = groups
        data = ''
        for group in groups:
            self.has_single_selection = selections.copy()
            data += self.get_event_code(group, triggered)

        event_hash = self.get_event_hash(data)

        for group in groups:
            group.data_hash = event_hash

        if not self.use_dlls:
            try:
                event_name = self.event_functions[event_hash]
                self.add_frame_members(event_hash)
                groups[0].event_name = event_name
                return event_name
            except KeyError:
                pass

        for group in groups:
            group.fire_write_callbacks()

        self.add_frame_members(event_hash)

        data = group.filter(data)

        event_name = 'event_func_%s' % (len(self.event_functions) + 1)
        groups[0].event_name = event_name
        self.event_functions[event_hash] = event_name

        writer.putmeth('void %s' % event_name)
        for line in data.splitlines():
            writer.putln(line)
        writer.end_brace()
        return event_name

    def write_events(self, name, writer, groups, triggered=False,
                     pre_calls=None, post_calls=None):
        names = pre_calls or []
        selections = self.has_single_selection
        col_objs = self.collision_objects
        for new_groups in self.iterate_groups(groups):
            self.has_single_selection = selections
            self.collision_objects = col_objs
            names.append(self.write_event_function(writer, new_groups,
                                                   triggered))

        if post_calls is not None:
            names.extend(post_calls)

        if not self.use_dlls:
            wrapper_hash = get_hash(''.join(names))
            try:
                return self.event_wrappers[wrapper_hash]
            except KeyError:
                pass
            self.event_wrappers[wrapper_hash] = name

        writer.putmeth('void %s' % name)
        for event_name in names:
            writer.putlnc('%s();', event_name)
        writer.end_brace()
        return name

    def write_generated(self, name, writer, groups, pre_calls=None,
                        post_calls=None):
        return self.write_events(name, writer, groups, True, pre_calls,
                                 post_calls)

    def get_event_code(self, group, triggered=False):
        group.set_groups(self, self.current_groups)
        self.is_triggered = triggered
        self.current_group = group
        self.current_event_id = group.global_id
        actions = group.actions
        container = group.container
        has_container_check = False
        if container:
            is_static = all([item.is_static for item in container.tree])
            has_container_check = not is_static
        writer = CodeWriter()
        writer.putln('// event %s' % TEMPORARY_GROUP_ID)
        event_break = self.event_break = 'goto %s_end;' % group.name

        # need to save single selection now so we can use it later
        if group.or_final:
            single_save = self.has_single_selection.copy()

        if group.or_first:
            writer.putln('bool %s = false;' % group.or_result)
        if group.or_first or group.or_save or group.or_final:
            writer.putln('bool %s = false;' % group.or_temp_result)

        writer.start_brace() # new scope

        if PROFILE_EVENTS:
            writer.putlnc('PROFILE_BLOCK(event_%s);', group.global_id)

        self.config.write_pre(writer, group)

        conditions = group.conditions
        if triggered:
            conditions = conditions[1:]

        if conditions or has_container_check:
            if has_container_check:
                condition = self.get_container_check(container)
                writer.putln('if (!(%s)) %s' % (condition, event_break))
            elif container:
                writer.putln('// group: %s' % container.name)

            condition_index = -1
            while condition_index < len(conditions) - 1:
                condition_index += 1
                condition_writer = conditions[condition_index]

                if condition_writer.custom:
                    condition_writer.write(writer)
                    continue
                condition_writer.write_pre(writer)
                object_name = None
                has_multiple = False
                obj = condition_writer.get_object()
                object_info, object_type = obj
                if object_info is not None:
                    try:
                        object_name = self.get_object(obj)
                    except KeyError:
                        pass
                write_conditions = [condition_writer]
                if obj in self.has_single_selection:
                    object_name = self.has_single_selection[obj]
                    self.set_iterator(obj, None, object_name)
                elif object_name is not None and self.has_multiple_instances(
                        obj):
                    if condition_writer.iterate_objects is not False:
                        # OPTIMIZATION: merge similar conditions into one
                        # iteration
                        start_index = condition_index
                        while condition_index < len(conditions) - 1:
                            next_cond = conditions[condition_index+1]
                            if next_cond.get_object() != obj:
                                break
                            if next_cond.custom:
                                break
                            if next_cond.iterate_objects is False:
                                break
                            condition_index += 1

                        write_conditions = conditions[start_index:
                                                      condition_index+1]

                        selected_name = self.create_list(obj, writer)
                        has_multiple = True
                        self.set_iterator(obj, selected_name)
                        iter_type = self.get_iter_type(obj)
                        writer.putlnc('for (%s it(%s); !it.end(); '
                                      '++it) {', iter_type, selected_name)
                        writer.indent()
                        object_name = '(*it)'

                for write_condition in write_conditions:
                    negated = not write_condition.is_negated()
                    writer.putindent()
                    if negated:
                        writer.put('if (!(')
                    else:
                        writer.put('if (')
                    writer.put(write_condition.prefix)
                    if object_name is None:
                        if write_condition.static:
                            writer.put('%s::' % self.get_object_class(
                                object_type, star = False))
                    elif write_condition.iterate_objects is not False:
                        if has_multiple:
                            obj = '((%s)%s)' % (self.get_object_class(
                                object_type), object_name)
                        else:
                            obj = object_name
                        obj += '->'
                        writer.put(obj)

                    write_condition.write(writer)
                    if negated:
                        writer.put(')')
                    if has_multiple:
                        writer.put(') { it.deselect(); continue; }\n')

                if has_multiple:
                    writer.end_brace()
                    writer.indented = False
                    writer.putlnc('if (!%s.has_selection()) %s',
                                  selected_name, event_break)
                else:
                    writer.put(') %s\n' % event_break)
                self.set_iterator(None)

        if group.or_final:
            writer.putlnc('%s = true;', group.or_result)
            writer.putlnc('%s = true;', group.or_temp_result)
            writer.putlnc('%s_end: ;', group.name)
            # writer.end_brace()
            self.write_instance_save(group, writer)
            writer.putlnc('if (!%s) goto or_final_%s_end;', group.or_result,
                          group.name)
            self.clear_selection()
            new_selection = {}

            is_logical = group.or_type == 'OrLogical'

            or_lists = set()
            for obj, or_bools in group.or_instance_groups.iteritems():
                list_name = self.get_object_list(obj)
                or_lists.add(list_name)

            for list_name in or_lists:
                if is_logical:
                    writer.putlnc('%s.clear_selection();', list_name)
                else:
                    writer.putlnc('%s.empty_selection();', list_name)

            for obj, or_bools in group.or_instance_groups.iteritems():
                for other in self.resolve_qualifier(obj):
                    if other == obj:
                        continue
                    list_name = self.get_object_list(other)
                    new_selection[other] = list_name

                list_name = self.get_object_list(obj)
                new_selection[obj] = list_name

                check = '%s' % (' || '.join(or_bools))
                writer.putlnc('if (%s) {', check)
                writer.indent()
                writer.putlnc('%s.restore_selection();', list_name)
                writer.end_brace()

            # writer.start_brace()
            self.has_selection = new_selection # group.or_selected
            self.has_single_selection = single_save

        self.in_actions = True

        action_index = -1
        while action_index < len(actions) - 1:
            action_index += 1
            action_writer = actions[action_index]
            if action_writer.custom:
                action_writer.write(writer)
                continue
            action_writer.write_pre(writer)
            has_multiple = False
            has_single = False
            obj = action_writer.get_object()
            object_info, object_type = obj
            if object_info is not None and not is_qualifier(object_info):
                is_static = self.get_object_writer(obj).static
                if is_static and action_writer.ignore_static:
                    continue
            if object_info is not None:
                if obj in self.has_single_selection:
                    has_single = True
                elif self.has_multiple_instances(obj):
                    has_multiple = True
                elif not self.is_valid_object(obj):
                    object_info = None
            if action_writer.iterate_objects is False:
                has_multiple = False
                object_info = None
            object_name = None
            write_actions = [action_writer]
            if has_single:
                object_name = self.has_single_selection[obj]
            elif has_multiple:
                # OPTIMIZATION: merge similar actions into one iteration
                start_index = action_index
                while action_index < len(actions) - 1:
                    next_action = actions[action_index+1]
                    if next_action.get_object() != obj:
                        break
                    if next_action.custom:
                        break
                    if next_action.iterate_objects is False:
                        break
                    action_index += 1

                write_actions = actions[start_index:action_index+1]
                list_name = self.create_list(obj, writer)
                iter_type = self.get_iter_type(obj)
                writer.putlnc('for (%s it(%s); !it.end(); '
                              '++it) {', iter_type, list_name)
                writer.indent()
                self.set_iterator(obj, list_name)
                object_name = '*it'
            elif object_info is not None:
                writer.putindent()
                writer.put('%s->' % self.get_object(obj))
            elif action_writer.static:
                writer.put('%s::' % self.get_object_class(object_type,
                    star = False))
            else:
                writer.putindent()

            for write_action in write_actions:
                if object_name is not None:
                    writer.putindent()
                    writer.put('((%s)%s)->' % (self.get_object_class(
                        object_type), object_name))
                write_action.write(writer)
                writer.put('\n')

            if has_multiple:
                writer.end_brace()
                self.set_iterator(None)

        for action_writer in actions:
            action_writer.write_post(writer)
        # if group.or_exit:
        #     writer.putln(group.or_exit)

        self.in_actions = False

        if group.or_save:
            writer.putlnc('%s = true;', group.or_result)
            writer.putlnc('%s = true;', group.or_temp_result)

        writer.end_brace()
        if group.or_final:
            writer.putln('or_final_%s_end: ;' % group.name)
        else:
            writer.putln('%s_end: ;' % group.name)

        if group.or_save:
            self.write_instance_save(group, writer)

        self.set_iterator(None)
        self.clear_selection()
        self.collision_objects = set()
        self.current_group = None
        self.current_event_id = None

        return writer.get_data()

    def write_instance_save(self, group, writer):
        if not self.has_selection:
            return

        objs = set(self.has_selection.iterkeys())
        # objs += set(self.has_single_selection.iterkeys())

        # look for qualifiers first
        has_qualifier = set()
        for obj in objs:
            if not is_qualifier(obj[0]):
                continue
            for other in self.resolve_qualifier(obj):
                has_qualifier.add(other)

        for obj in objs:
            if obj in has_qualifier:
                continue
            group.or_instance_groups[obj].append(group.or_temp_result)
            if obj in group.or_selected:
                continue
            list_name = self.get_object_list(obj, True)
            group.or_selected[obj] = list_name
            writer.putlnc('%s.clear_saved_selection();', list_name)

        writer.putlnc('if (%s) {', group.or_temp_result)
        writer.indent()

        # save all single instances
        # for obj, obj_name in self.has_single_selection.iteritems():
        #     list_name = self.get_object_list(obj, True)

        for obj, list_name in self.has_selection.iteritems():
            if obj in has_qualifier:
                continue
            writer.putlnc('%s.save_selection();', list_name)

        writer.end_brace()

    def convert_static_expression(self, items, start=0, end=-1):
        expressions = items[start:end]
        out = ''
        for item in expressions:
            name = item.getName()
            if name == 'String':
                out += self.config.get_string(item.loader.value)
            elif name == 'Long':
                out += str(item.loader.value)
            elif name == 'Plus':
                continue
            # elif name == 'AlterableString':
            #     object_info = (item.objectInfo, item.objectType)
            #     index = item.loader.value
            #     writer = self.get_object_writer(object_info)
            #     value = writer.common.strings.items[index]
            #     out += value
            else:
                return None
        return out

    def get_string_expressions(self, parameter):
        loader = parameter.loader
        strings = []
        for item in loader.items:
            if item.getName() != 'String':
                continue
            strings.append(self.config.get_string(item.loader.value))
        return strings

    def convert_parameter(self, container):
        loader = container.loader
        out = ''
        self.start_clauses = self.end_clauses = 0
        parameter_type = container.getName()

        if loader.isExpression:
            if not self.config.use_condition_expression_iterator():
                self.in_condition_expression = not self.in_actions
            self.expression_items = loader.items[:-1]
            self.item_index = 0
            while self.item_index < len(self.expression_items):
                item = self.expression_items[self.item_index]
                expression_writer = self.get_expression_writer(item)
                obj = expression_writer.get_object()
                object_info, object_type = obj
                if expression_writer.static:
                    out += '%s::' % self.get_object_class(object_type,
                        star = False)
                elif object_info is not None:
                    use_def = expression_writer.use_default
                    try:
                        out += '%s->' % self.get_object(obj,
                                                        use_default=use_def)
                    except KeyError:
                        pass
                self.last_out = out
                out += expression_writer.get_string()
                self.item_index += 1

            if parameter_type == 'VARGLOBAL_EXP':
                out = '-1 + ' + out
            if parameter_type == 'AlterableValueExpression':
                # A.N.N.E hack for invalid commas in alt. val expression
                if ')' not in out and '(' not in out and ', ' in out:
                    out = out.split(',')[0]
            self.in_condition_expression = False
        else:
            parameter_name = type(container.loader).__name__
            if parameter_name == 'Object':
                return self.get_object((loader.objectInfo, loader.objectType))
            elif parameter_name == 'Sample':
                return self.assets.get_sound_id(loader.name)
            elif parameter_name in ('Position', 'Shoot', 'Create'):
                if parameter_name != 'Position':
                    obj = (loader.objectInfo, None)
                    obj = self.filter_object_type(obj)
                    if self.get_object_writer(obj).static:
                        return None
                details = {}
                if parameter_name == 'Position':
                    position = loader
                elif parameter_name == 'Shoot':
                    details['shoot_speed'] = loader.shootSpeed
                    create_info = (loader.objectInfo, None)
                    create_info = self.filter_object_type(create_info)
                    details['shoot_object'] = create_info
                elif parameter_name == 'Create':
                    create_info = (loader.objectInfo, None)
                    create_info = self.filter_object_type(create_info)
                    details['create_object'] = create_info
                if parameter_name in ('Shoot', 'Create'):
                    position = loader.position
                flags = position.flags
                details['direction'] = position.direction
                if flags['Action']:
                    details['use_action_point'] = True
                if flags['Direction']:
                    details['transform_position_direction'] = True
                if flags['InitialDirection']:
                    details['use_direction'] = True
                if flags['DefaultDirection']:
                    details['use_default_direction'] = True
                if position.objectInfoParent != 0xFFFF:
                    details['parent'] = (position.objectInfoParent,
                                         position.typeParent)
                details['layer'] = position.layer
                details['x'] = position.x
                details['y'] = position.y
                return details
            elif parameter_name == 'KeyParameter':
                return convert_key(loader.key.getValue())
            elif parameter_name == 'Zone':
                return repr((loader.x1, loader.y1, loader.x2, loader.y2))
            elif parameter_name == 'Time':
                return repr(loader.timer)
            elif parameter_name == 'CompareTime':
                return repr(loader.timer)
            elif parameter_name == 'Every':
                return repr(loader.delay)
            elif parameter_name == 'Click':
                button = loader.getButton()
                if button == 'Left':
                    return convert_key(1)
                if button == 'Right':
                    return convert_key(2)
                elif button == 'Middle':
                    return convert_key(4)
            elif parameter_name in ('Colour'):
                return make_color(loader.value)
            elif parameter_name in ('Int', 'Short'):
                if parameter_type == 'NEWDIRECTION':
                    return parse_direction(loader.value)
                elif parameter_type == 'TEXTNUMBER':
                    return loader.value + 1
                return loader.value
            elif parameter_name == 'Extension':
                return loader.get_reader()
            elif parameter_name in ('String', 'Filename'):
                # self.start_clauses -= loader.value.count('(')
                # self.end_clauses -= loader.value.count(')')
                return self.intern_string(loader.value)
            elif parameter_name in ('TwoShorts'):
                return to_c('%r, %r', loader.value1, loader.value2)
            else:
                raise NotImplementedError('parameter: %s' % parameter_name)
        self.start_clauses += out.count('(')
        self.end_clauses += out.count(')')
        for _ in xrange(self.start_clauses - self.end_clauses):
            out += ')'

        if self.end_clauses > self.start_clauses:
            # MMF expression bug
            remove = self.end_clauses - self.start_clauses

            if remove != 1:
                print out
                raise NotImplementedError()

            end = len(out)

            print out

            while True:
                end = out.rindex('),', 0, end)
                if out[end-1] != '(':
                    break

            filtered = out[end+1:]
            out = out[:end+1]
            # print 'too many end-clauses, filtered', filtered

        # fix for extranous comma in Odallus
        if out.endswith(', '):
            out = out[:-2]

        return out

    def intern_string(self, value):
        value = self.config.get_string(value)
        if value == '':
            return 'empty_string'
        try:
            return self.strings[value]
        except KeyError:
            pass
        name = 'str_%s_%s' % (get_method_name(value), len(self.strings))
        self.strings[value] = name
        return name

    def get_direction(self, parameter):
        loader = parameter.loader
        if loader.isExpression:
            return self.convert_parameter(parameter)
        else:
            value = loader.value
            directions = []
            for i in xrange(32):
                if value & (1 << i) != 0:
                    directions.append(i)
            if len(directions) > 1:
                return 'random.choice(%r)' % (tuple(directions),)
            else:
                return repr(directions[0])

    def has_multiple_instances(self, handle):
        if not self.current_group:
            return True
        if is_qualifier(handle[0]):
            return True
        if handle in self.multiple_instances:
            return True
        if handle in self.current_group.force_multiple:
            return True
        if self.current_group.or_type == 'OrFiltered':
            return True
        return False

    def create_list(self, object_info, writer):
        single = self.get_single(object_info)
        if single is not None:
            return single
        if object_info in self.has_selection:
            return self.has_selection[object_info]
        list_name = self.get_object_list(object_info)
        # test for qualifier collision
        objs = self.resolve_qualifier(object_info)
        list_name = self.get_object_list(object_info)

        clear_lists = set()

        has_col = False
        for obj in objs:
            if self.has_common_objects(obj, self.has_selection):
                has_col = True
            else:
                if self.has_single(obj):
                    print 'ignoring single for clear list'
                    continue
                clear_lists.add(self.get_object_list(obj))

        if has_col:
            writer.putln('// icache destruction')
        else:
            clear_lists = (list_name,)

        for obj_list in clear_lists:
            writer.putlnc('%s.clear_selection();', obj_list)

        for obj in objs:
            if obj == object_info:
                continue
            self.set_list(obj, self.get_object_list(obj))

        self.set_list(object_info, list_name)

        return list_name

    def has_common_objects(self, obj, objs):
        test_objs = set(self.resolve_qualifier(obj))

        for new_obj in objs:
            other_objs = self.resolve_qualifier(new_obj)
            if not test_objs.isdisjoint(other_objs):
                return True
        return False

    def get_single(self, obj):
        single = self.has_single_selection.get(obj, None)
        if single:
            return single
        elif obj == self.iterated_object:
            return self.iterated_name
        return None

    def has_single(self, obj):
        if obj in self.has_single_selection:
            return True
        elif obj == self.iterated_object:
            return True
        return False

    def get_object(self, obj, as_list=False, use_default=False, index=None):
        handle = obj[0]
        object_type = self.get_object_class(obj[1])
        use_index = (self.config.use_iteration_index() and self.iterated_index
                     and self.in_actions) or index is not None
        index = index or self.iterated_index
        if obj in self.has_single_selection:
            return self.has_single_selection[obj]

        is_it = self.iterated_object == obj
        if is_it and not self.in_condition_expression:
            return '((%s)%s)' % (object_type, self.iterated_name)

        multi = self.has_multiple_instances(obj)
        if not multi:
            use_index = use_default = False

        has_selection = is_it or obj in self.has_selection
        if has_selection and multi:
            ret = self.has_selection[obj]
            if as_list:
                return ret
            args = [ret]
            if use_index:
                args.append(index)
            if use_default:
                default_instance = self.get_default_instance(obj[1])
                if default_instance:
                    args.append(default_instance)
            args = ', '.join(args)
            ret = '((%s)get_single(%s))' % (object_type, args)
            return ret
        else:
            name = self.get_object_list(obj)
            if as_list:
                raise NotImplementedError()
            type_id, is_qual = self.get_object_handle(obj)
            args = [name]
            if use_index:
                args.append(index)

            if use_default:
                default_instance = self.get_default_instance(obj[1])
                if default_instance:
                    args.append(default_instance)

            if is_qual:
                getter_name = 'get_qualifier'
            else:
                getter_name = 'get_instance'

            args = ', '.join(args)
            return '((%s)%s(%s))' % (object_type, getter_name, args)

    def get_default_instance(self, object_type):
        return self.get_object_impl(object_type).default_instance

    def get_object_list(self, obj, allow_single=False):
        if self.has_single(obj) and not allow_single:
            print 'single exception:', self.get_single(obj)
            print obj in self.has_single_selection
            print obj == self.iterated_object
            raise NotImplementedError()
        type_id, is_qual = self.get_object_handle(obj)
        if is_qual:
            return type_id
        obj = self.filter_object_type(obj)
        try:
            return self.object_lists[obj + (self.game_index,)]
        except KeyError:
            import code
            code.interact(local=locals())

    def filter_object_type(self, obj):
        if is_qualifier(obj[0]):
            return obj
        if (obj + (self.game_index,)) in self.all_objects:
            return obj
        obj_type = self.object_types[(obj[0], self.game_index)]
        new_obj = (obj[0], obj_type)
        return new_obj

    def is_valid_object(self, obj):
        obj = obj + (self.game_index,)
        return obj in self.object_names

    def get_object_name(self, obj):
        if is_qualifier(obj[0]):
            return self.qualifier_names[obj]
        obj = self.filter_object_type(obj)
        return self.object_names[obj + (self.game_index,)]

    def get_type_name(self, object_type):
        name = getObjectType(object_type)
        if name == 'Extension':
            ext_index = object_type - EXTENSION_BASE
            ext = self.game.extensions.fromHandle(ext_index)
            name = ext.name
        return name

    def get_object_handle(self, obj):
        if is_qualifier(obj[0]):
            return (self.qualifier_names[obj], True)
        obj = self.filter_object_type(obj)
        try:
            return ('%s_type' % self.get_object_name(obj), False)
        except Exception, e:
            data = self.get_object_writer(obj).data
            name = self.get_type_name(data.objectType)
            # print name
            raise e

    def get_object_class(self, object_type, star=True):
        try:
            ret = self.get_object_impl(object_type).class_name
            if star:
                ret += '*'
            return ret
        except (KeyError, ValueError):
            return None

    def get_extension_module(self, ext):
        if self.is_unicode:
            mod = load_extension_module(ext.name + 'Unicode', False)
            if mod is not None:
                return mod
        return load_extension_module(ext.name, True)

    def get_object_impl(self, object_type):
        if object_type >= EXTENSION_BASE:
            ext = self.game.extensions.fromHandle(object_type - EXTENSION_BASE)
            writer_module = self.get_extension_module(ext)
            return writer_module.get_object()
        else:
            return system_objects[object_type]

    def get_object_writer(self, obj):
        obj = self.filter_object_type(obj)
        return self.all_objects[obj + (self.game_index,)]

    def get_handle_from_name(self, obj):
        item = self.name_to_item[obj + (self.game_index,)]
        return (item.handle, item.objectType)

    def resolve_qualifier(self, obj):
        if not is_qualifier(obj[0]):
            return [obj]
        return self.qualifiers[obj]

    def get_condition_name(self, item):
        return self.get_ace_name(item, 'conditions')

    def get_action_name(self, item):
        return self.get_ace_name(item, 'actions')

    def get_expression_name(self, item):
        return self.get_ace_name(item, 'expressions')

    def get_ace_name(self, item, key):
        if item.getType() == EXTENSION_BASE:
            num = item.getExtensionNum()
            if num >= 0:
                extension = self.get_extension(item)
                extension_name = extension.name
                # print 'getting %r %r %r' % (extension_name, key, num)
                native = load_native_extension(extension_name)
                if native is None:
                    menu_entry = []
                else:
                    menu_name = key[:-1] + 'Menu'
                    menu_dict = getattr(native, menu_name)
                    try:
                        menu_entry = menu_dict[num]
                    except KeyError, e:
                        # print 'could not load menu', num, extension_name, key
                        menu_entry = []
                # print 'unnamed:', extension_name, num, menu_entry, key
                # print '%r' % menu_entry
                full_name = [extension_name] + menu_entry + [str(num)]
                return get_method_name('_'.join(full_name))
        ret = item.getName()
        if ret is None:
            print 'ret:', item.objectType, item.num
            import code
            code.interact(local = locals())
        return ret

    def get_action_writer(self, item, as_klass = False):
        return self.get_ace_writer(item, 'actions', as_klass)

    def get_condition_writer(self, item, as_klass = False):
        return self.get_ace_writer(item, 'conditions', as_klass)

    def get_expression_writer(self, item, as_klass = False):
        return self.get_ace_writer(item, 'expressions', as_klass)

    def get_ace_writer(self, item, ace_type, as_klass = False):
        writer_module = None
        if item.getType() == EXTENSION_BASE:
            num = item.getExtensionNum()
            if num >= 0:
                extension = self.get_extension(item)
                writer_module = self.get_extension_module(extension)
                key = num
        if writer_module is None:
            writer_module = system_writers
            key = item.getName()
        object_name = None
        if item.hasObjectInfo():
            obj = (item.objectInfo, item.objectType)
            try:
                object_writer = self.get_object_writer(obj)
            except KeyError:
                object_writer = None

            if object_writer:
                object_name = object_writer.data.name
        else:
            object_name = None

        if extra.is_special_object(object_name):
            writer_module = extra
        try:
            klass = getattr(writer_module, ace_type)[key]
        except (KeyError, AttributeError):
            klass = default_writers[ace_type]
        if as_klass:
            return klass
        else:
            return klass(self, item)

    def get_extension(self, item):
        return item.getExtension(self.game.extensions)

    def open_code(self, *path):
        return CodeWriter(self.get_filename(*path))

    def open(self, *path):
        return open(self.get_filename(*path), 'wb')

    def write_config(self, data, *path):
        with open(self.get_filename(*path), 'wb') as fp:
            fp.write(repr(data))

    def read_config(self, *path):
        with open(self.get_filename(*path), 'rb') as fp:
            data = fp.read()
        return eval(data)

    def get_filename(self, *path):
        return os.path.join(self.outdir, *path)

    def copy_file(self, src, dst=None, overwrite=True):
        dst = self.get_filename(dst or src)
        src = os.path.join(self.base_path, src)
        if not overwrite and os.path.isfile(dst):
            return
        shutil.copy(src, dst)

    def format_file(self, src, dst=None, **kw):
        dst = self.get_filename(dst or src)
        src = os.path.join(self.base_path, src)
        fp = open(src, 'rb')
        data = fp.read()
        fp.close()
        kw.update(self.info_dict)
        for k, v in kw.iteritems():
            data = data.replace('%%(%s)s' % k, str(v))
        fp = open(dst, 'wb')
        fp.write(data)
        fp.close()
