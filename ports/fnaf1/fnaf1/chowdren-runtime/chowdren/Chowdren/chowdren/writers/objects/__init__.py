from chowdren.writers import BaseWriter
from mmfparser.bytereader import ByteReader
from chowdren.idpool import get_id
from chowdren.common import get_method_name

class ObjectWriter(BaseWriter):
    common = None
    class_name = 'Undefined'
    static = False
    filename = None
    defines = []
    event_callbacks = None
    use_alterables = False
    has_color = False
    update = False
    movement_count = 0
    has_shoot = False
    default_instance = None
    has_collision_events = False
    disable_kill = False

    def __init__(self, *arg, **kw):
        self.event_callbacks = {}
        BaseWriter.__init__(self, *arg, **kw)
        self.common = self.data.properties.loader
        self.initialize()
        self.init_global_data()

    def initialize(self):
        pass

    def write_pre(self, writer):
        pass

    def write_constants(self, writer):
        pass

    def get_parameters(self):
        return []

    def get_init_list(self):
        return {}

    def write_class(self, writer):
        pass

    def write_start(self, writer):
        pass

    def write_frame(self, writer):
        pass

    def write_init(self, writer):
        pass

    def write_post(self, writer):
        pass

    def get_qualifiers(self):
        try:
            return self.common.qualifiers
        except AttributeError:
            return []

    def get_data(self):
        return ByteReader(self.common.extensionData)

    def has_movements(self):
        return self.movement_count > 0 or self.has_shoot

    def has_sleep(self):
        try:
            if self.common.flags['ManualSleep']:
                if self.common.flags['NeverSleep']:
                    return False
                else:
                    return True
            else:
                # (OnBackgroundCollision && LEF_TOTALCOLMASK) ||
                # (OnCollision || IsOverlapping || LeavingPlayfield ||
                #  EnteringPlayfield)
                return not self.has_collision_events
        except AttributeError:
            pass
        return False

    def has_kill(self):
        if not self.has_sleep() or self.disable_kill:
            return False
        return not self.common.flags['NeverKill']

    def has_updates(self):
        return self.update

    def get_conditions(self, *values):
        groups = []
        for value in values:
            if self.data is None:
                key = value
            else:
                key = (self.data.properties.objectType, value)
            groups.extend(self.converter.generated_groups.pop(key, []))
        groups.sort(key = lambda x: x.global_id)
        return groups

    def get_object_conditions(self, *values):
        object_info = self.data.handle
        groups = []
        for value in values:
            if self.data is None:
                key = value
            else:
                key = (self.data.properties.objectType, value)
            new_groups = self.converter.generated_groups.get(key, None)
            if not new_groups:
                continue
            for group in new_groups[:]:
                first = group.conditions[0]
                other_info = first.data.objectInfo
                if other_info != object_info:
                    continue
                groups.append(group)
                new_groups.remove(group)
            if not new_groups:
                self.converter.generated_groups.pop(key)
        groups.sort(key = lambda x: x.global_id)
        return groups

    def is_visible(self):
        try:
            return self.common.newFlags['VisibleAtStart']
        except (AttributeError, KeyError):
            return True

    def is_scrolling(self):
        try:
            return not self.common.flags['ScrollingIndependant']
        except AttributeError:
            return True

    def is_background(self):
        return self.common.isBackground()

    def is_background_collider(self):
        return self.is_static_background()

    def is_static_background(self):
        return self.is_background()

    def is_global(self):
        if not self.data.flags['Global']:
            return False
        if not self.converter.config.use_global_alterables(self):
            return False
        return True

    def has_single_global(self):
        if not self.is_global():
            return False
        return self.converter.config.use_single_global_alterables(self)

    def get_images(self):
        return []

    def add_event_callback(self, name):
        event_id = self.converter.event_callback_ids.next()
        self.event_callbacks[name] = event_id
        return event_id

    def write_event_callback(self, name, writer, groups):
        wrapper_name = '%s_%s_%s' % (name, get_id(self),
                                     self.converter.current_frame_index)
        event_id = self.event_callbacks[name]
        wrapper_name = self.converter.write_generated(wrapper_name, writer,
                                                      groups)
        self.converter.event_callbacks[event_id] = wrapper_name

    def init_global_data(self):
        if not self.is_global():
            return
        self.global_alt = self.get_global('SavedAlterables')

    def write_internal_class(self, writer):
        pass

    def write_internal_post(self, writer):
        pass

    def has_internal_dtor(self):
        if not self.is_global():
            return False
        if self.has_single_global():
            return False
        return True

    def has_dtor(self):
        return False

    def write_dtor(self, writer):
        pass

    def has_autodestruct(self):
        return False

    def write_internal_dtor(self, writer):
        if not self.is_global():
            return
        if self.has_single_global():
            return
        writer.putlnc('%s.init = true;', self.global_alt)
        writer.putlnc('%s.value.set(*alterables);', self.global_alt)

    def load_alterables(self, writer):
        if not self.use_alterables:
            return

        is_global = self.is_global()
        single = self.has_single_global()

        if not single:
            writer.putln('create_alterables();')

        if is_global:
            alt_name = self.global_alt
            if single:
                writer.putlnc('flags |= GLOBAL;')
                writer.putlnc('alterables = &%s.value;', alt_name)
                writer.putlnc('if (!%s.init) {', alt_name)
            else:
                writer.putlnc('if (%s.init) {', alt_name)
                writer.indent()
                writer.putlnc('alterables->set(%s.value);', alt_name)
                writer.dedent()
                writer.putln('} else {')

            writer.indent()

        common = self.common
        if common.values:
            for index, value in enumerate(common.values.items):
                if value == 0:
                    continue
                writer.putlnc('alterables->values.set(%s, %s);', index, value)
        if common.strings:
            for index, value in enumerate(common.strings.items):
                if value == '':
                    continue
                value = self.converter.intern_string(value)
                writer.putlnc('alterables->strings.set(%s, %s);', index, value)

        if is_global:
            if single:
                writer.putlnc('%s.init = true;', alt_name)
            writer.end_brace()

    def get_base_filename(self):
        if '/' in self.filename:
            return self.filename
        return 'objects/%s' % self.filename

    def get_includes(self):
        if self.filename is None:
            return []
        return ['%s.h' % self.get_base_filename()]

    def get_sources(self):
        if self.filename is None:
            return []
        return ['%s.cpp' % self.get_base_filename()]

    def get_list_id(self):
        list_id = (self.data.name, self.class_name, self.has_updates(),
                   self.has_movements(), self.has_sleep())
        list_id = list_id + tuple(self.get_qualifiers())
        return list_id

    def get_global(self, typ):
        data = self.converter.global_object_data
        key = (self.data.name, self.class_name, typ)
        try:
            return data[key]
        except KeyError:
            pass
        name = 'global_data_%s_%s' % (len(data),
                                      get_method_name(self.data.name))
        data[key] = name
        self.converter.global_object_header.putlnc('extern %s %s;', typ, name)
        self.converter.global_object_code.putlnc('%s %s;', typ, name)
        return name

    @staticmethod
    def write_application(converter):
        pass

class EventCallback(object):
    def __init__(self, base, converter):
        self.base = base
        self.converter = converter

    def __str__(self):
        return '%s_%s' % (self.base, self.converter.current_frame_index)

    def __hash__(self):
        return hash(self.base)