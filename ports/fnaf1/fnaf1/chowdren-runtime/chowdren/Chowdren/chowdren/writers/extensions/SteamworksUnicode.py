from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ConditionMethodWriter,
    ActionMethodWriter, ExpressionMethodWriter, make_table,
    TrueCondition, FalseCondition, EmptyAction)

from chowdren.writers.events.system import OnceCondition

def get_loop_name(converter):
    return 'steam_ugc_loop_%s' % converter.current_frame_index

def get_download_success_name(converter):
    return 'steam_ugc_download_s_%s' % converter.current_frame_index

def get_download_fail_name(converter):
    return 'steam_ugc_download_f_%s' % converter.current_frame_index

def get_search_success_name(converter):
    return 'steam_ugc_search_s_%s' % converter.current_frame_index

ON_CONNECT = 0
DOWNLOAD_SUCCESS = 83
DOWNLOAD_FAIL = 84
SEARCH_SUCCESS = 55
ON_LOOP = 57
ON_LOOP_FINISH = 58

GROUPS = (
    (DOWNLOAD_SUCCESS, 'download_success'),
    (DOWNLOAD_FAIL, 'download_fail'),
    (ON_LOOP, 'on_loop'),
    (ON_LOOP_FINISH, 'on_loop_finish'),
    (SEARCH_SUCCESS, 'search_success'),
    (ON_CONNECT, 'on_connect')
)

class SteamObject(ObjectWriter):
    class_name = 'SteamObject'
    update = True
    filename = 'steamext'

    def write_frame(self, writer):
        for (cond, name) in GROUPS:
            groups = self.get_conditions(cond)
            func_name = 'steam_%s_%s' % (name,
                                         self.converter.current_frame_index)
            new_name = self.converter.write_generated(func_name, writer,
                                                      groups)
            if func_name != new_name:
                writer.putmeth('void %s' % func_name)
                writer.putlnc('%s();', new_name)
                writer.end_brace()

    @property
    def download_success_name(self):
        return 'steam_download_success_%s' % self.converter.current_frame_index

    @property
    def download_fail_name(self):
        return 'steam_download_fail_%s' % self.converter.current_frame_index

    @property
    def on_loop_name(self):
        return 'steam_on_loop_%s' % self.converter.current_frame_index

    @property
    def on_loop_finish_name(self):
        return 'steam_on_loop_finish_%s' % self.converter.current_frame_index

    @property
    def search_success_name(self):
        return 'steam_search_success_%s' % self.converter.current_frame_index

    @property
    def on_connect_name(self):
        return 'steam_on_connect_%s' % self.converter.current_frame_index

    def write_init(self, writer):
        pass

    def has_sleep(self):
        return False

class SearchSubscribedItems(ActionMethodWriter):
    custom = True

    def write(self, writer):
        obj = self.get_object()
        steam = self.converter.get_object_writer(obj)
        with self.converter.iterate_object(obj, writer, copy=False):
            obj = self.converter.get_object(obj)
            writer.putlnc('%s();', steam.search_success_name)

class LoopResults(ActionMethodWriter):
    custom = True

    def write(self, writer):
        obj = self.get_object()
        steam = self.converter.get_object_writer(obj)
        with self.converter.iterate_object(obj, writer, copy=False):
            obj = self.converter.get_object(obj)
            writer.putlnc('%s->get_subs((EventFunction)&Frames::%s, '
                          '(EventFunction)&Frames::%s);', obj,
                          steam.on_loop_name, steam.on_loop_finish_name)

class DownloadUGC(ActionMethodWriter):
    custom = True

    def write(self, writer):
        obj = self.get_object()
        steam = self.converter.get_object_writer(obj)
        with self.converter.iterate_object(obj, writer, copy=False):
            obj = self.converter.get_object(obj)
            writer.putlnc('%s->download(%s, %s, %s, '
                          '(EventFunction)&Frames::%s, '
                          '(EventFunction)&Frames::%s);', obj,
                          self.convert_index(0),
                          self.convert_index(1),
                          self.convert_index(2),
                          steam.download_success_name,
                          steam.download_fail_name)

actions = make_table(ActionMethodWriter, {
    15 : 'request_user_data',
    16 : 'store_user_data',
    17 : 'set_int',
    22 : 'unlock_achievement',
    26 : 'clear_achievements',
    116 : LoopResults,
    158 : SearchSubscribedItems,
    162 : DownloadUGC
})

class OnConnect(OnceCondition):
    is_always = True

    def write(self, writer):
        obj = self.get_object()
        with self.converter.iterate_object(obj, writer, copy=False):
            obj = self.converter.get_object(obj)
            writer.putlnc('if (!%s->is_ready()) %s', obj,
                          self.converter.event_break)
        OnceCondition.write(self, writer)

conditions = make_table(ConditionMethodWriter, {
    0 : OnConnect,
    21 : 'is_achievement_unlocked',
    7 : 'has_app'
})

def get_sub_expression(value):
    class SubExpression(ExpressionMethodWriter):
        has_object = False
        method = '.get_event_dummy(SteamObject::sub_result.%s, ' % value

    return SubExpression

expressions = make_table(ExpressionMethodWriter, {
    2 : 'get_user_name()',
    1 : 'get_user_id()',
    7 : 'get_int',
    12 : 'get_unlocked',
    57 : get_sub_expression('index'),
    58 : get_sub_expression('publish_id'),
    74 : get_sub_expression('cloud_path')
})

def get_object():
    return SteamObject
