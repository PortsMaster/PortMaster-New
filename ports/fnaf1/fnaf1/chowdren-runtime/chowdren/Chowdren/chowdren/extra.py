# Extra features for Chowdren

from chowdren.writers.events import (ExpressionWriter, ActionWriter,
    ConditionWriter)
from chowdren.common import to_c

SPRITES_STRING = 'Chowdren: Sprites'
PLATFORM_STRING = 'Chowdren: Platform'
# XXX small hack while Sam fixes the MFA
PLATFORM_STRING_TEMP = 'Cowdren: Platform'
PLATFORM_STRINGS = (PLATFORM_STRING, PLATFORM_STRING_TEMP)
FONT_STRING = 'Chowdren: Font'
RESIZE_STRING = 'Chowdren: Window Resize'
SHADERS_STRING = 'Chowdren: Shaders'
SOUNDS_STRING = 'Chowdren: Sounds'
STEAM_STRING = 'Chowdren: Steam'
LANGUAGE_STRING = 'Chowdren: Language'
REMOTE_STRING = 'Chowdren: Remote'
BORDER_STRING = 'Chowdren: Border'
UTF8_STRING = 'Chowdren: UTF8'
UNITTEST_STRING = 'Chowdren: Unittest'

SPECIAL_OBJECTS = set([SPRITES_STRING, PLATFORM_STRING, PLATFORM_STRING_TEMP,
    FONT_STRING, RESIZE_STRING, SHADERS_STRING, SOUNDS_STRING, STEAM_STRING,
    LANGUAGE_STRING, REMOTE_STRING, BORDER_STRING, UTF8_STRING,
    UNITTEST_STRING])

def is_special_object(name):
    return name in SPECIAL_OBJECTS

class GetString(ExpressionWriter):
    has_object = False
    def get_string(self):
        obj = (self.data.objectInfo, self.data.objectType)
        name = self.converter.get_object_writer(obj).data.name
        if name in PLATFORM_STRINGS:
            return 'get_platform()'
        elif name == LANGUAGE_STRING:
            return 'platform_get_language()'
        elif name == REMOTE_STRING:
            return 'platform_get_remote_setting()'
        elif name == UNITTEST_STRING:
            return 'unittest_result'

class SetString(ActionWriter):
    has_object = False
    custom = True

    def write(self, writer):
        obj = (self.data.objectInfo, self.data.objectType)
        name = self.converter.get_object_writer(obj).data.name
        if name in (SPRITES_STRING, FONT_STRING, SHADERS_STRING,
                    SOUNDS_STRING):
            # deprecated
            pass
        elif name == RESIZE_STRING:
            writer.putlnc('set_window_resize(%s);', self.get_bool(0))
        elif name == STEAM_STRING:
            v = self.get_bool(0)
            # writer.put(to_c('SteamObject::set_enabled(%s);', v))
        elif name == REMOTE_STRING:
            v = self.convert_index(0)
            writer.putlnc('platform_set_remote_setting(%s);', v)
        elif name == BORDER_STRING:
            v = self.get_bool(0)
            writer.putlnc('platform_set_border(%s);', v)
        elif name == UNITTEST_STRING:
            v = self.convert_index(0)
            if v == self.converter.strings.get('Finish', None):
                writer.putln('platform_debug("Unittest done");')
                return
            self.group.add_member('std::string unittest_result')
            writer.putlnc('unittest_result = %r;', self.convert_index(0))
            if not self.get_bool(0):
                writer.putln('platform_debug("Unittest failed");')

    def get_bool(self, index):
        value = self.convert_index(0)

        for test in ('Yes', 'Enabled', 'Success'):
            if value == self.converter.strings.get(test, None):
                return True

        for test in ('No', 'Disabled', 'Fail'):
            if value == self.converter.strings.get(test, None):
                return False

        raise NotImplementedError()

actions = {
    'SetString' : SetString
}

conditions = {
}

expressions = {
    'CurrentText' : GetString
}
