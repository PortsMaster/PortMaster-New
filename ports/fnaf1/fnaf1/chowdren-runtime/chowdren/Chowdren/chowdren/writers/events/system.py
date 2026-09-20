from mmfparser.data.chunkloaders.objectinfo import SEMITRANSPARENT_EFFECT
from chowdren.writers.events import (ActionWriter, ConditionWriter,
    ExpressionWriter, ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table,
    make_expression, make_comparison, EmptyAction, FalseCondition)
from chowdren.common import (get_method_name, to_c, make_color,
                             parse_direction, get_flag_direction,
                             TEMPORARY_GROUP_ID, is_qualifier)
from chowdren.writers.objects import ObjectWriter
from chowdren import shader
from collections import defaultdict
from chowdren.key import convert_key
from mmfparser.bitdict import BitDict
from chowdren.idpool import get_id
from chowdren import transition
from chowdren.shader import INK_EFFECTS, NATIVE_SHADERS

def get_loop_running_name(name):
    return 'loop_%s_running' % get_method_name(name)

def get_loop_index_name(name):
    return 'loop_%s_index' % get_method_name(name)

def get_loop_func_name(name, converter):
    return '%s_%s' % (get_method_name(name), converter.current_frame_index)

def get_repeat_name(group):
    return 'repeat_%s' % group.unique_id

def get_restrict_name(group):
    return 'restrict_%s' % group.unique_id

PROFILE_LOOPS = set([])

class SystemObject(ObjectWriter):
    loop_name_warnings = set()

    def __init__(self, converter):
        self.converter = converter
        self.data = None
        self.foreach_names = {}

    def write_frame(self, writer):
        self.write_group_activated(writer)
        self.write_loops(writer)
        self.write_foreach(writer)
        self.write_collisions(writer)

    def write_start(self, writer):
        for name in self.loops.keys():
            running_name = get_loop_running_name(name)
            index_name = get_loop_index_name(name)
            writer.putln('%s = false;' % running_name)
            writer.putln('%s = 0;' % index_name)
        if self.dynamic_loops:
            writer.putln('static DynamicLoops frame_loops;')
            writer.putln('loops = &frame_loops;')
            writer.putln('static bool loops_initialized = false;')
            writer.putln('if (!loops_initialized) {')
            writer.indent()
            for loop in self.dynamic_loops:
                loop_method = 'loop_wrapper_' + get_loop_func_name(
                    loop, self.converter)
                running_name = get_loop_running_name(loop)
                index_name = get_loop_index_name(loop)
                writer.putlnc('frame_loops[%r].set(&%s, &%s, &%s);',
                              loop, loop_method, running_name, index_name)
            writer.putln('loops_initialized = true;')
            writer.end_brace()
        else:
            writer.putln('loops = NULL;')

    def write_group_activated(self, writer):
        self.group_activations = defaultdict(list)
        for group in self.converter.always_groups_dict['OnGroupActivation']:
            for cond in group.conditions:
                if cond.data.getName() == 'OnGroupActivation':
                    break
            container = cond.container
            check_name = cond.get_group_check()
            group.add_member('bool %s' % check_name, 'true')
            self.group_activations[container].append(check_name)

    def write_collisions(self, writer):
        converter = self.converter

        resolve = converter.resolve_qualifier

        col_groups = defaultdict(list)
        real_objs = {}
        col_save = set()
        for group in self.get_conditions('OnCollision'):
            cond = group.conditions[0]
            data = cond.data

            obj1_real = (data.objectInfo, data.objectType)
            obj2_real = (data.items[0].loader.objectInfo,
                         data.items[0].loader.objectType)

            is_qual1 = is_qualifier(obj1_real[0])
            is_qual2 = is_qualifier(obj2_real[0])
            if is_qual1 and not is_qual2:
                key = (obj1_real, obj2_real)
            elif is_qual2 and not is_qual1:
                key = (obj2_real, obj1_real)
            else:
                key = tuple(sorted((obj1_real, obj2_real)))

            if cond.has_collisions(group):
                col_save.add(key)

            group_list = col_groups[key]
            group_list.append(group)

        back_groups = defaultdict(list)
        back_save = set()
        for group in self.get_conditions('OnBackgroundCollision'):
            cond = group.conditions[0]
            real_obj = cond.get_object()
            for obj in resolve(real_obj):
                key = (obj, real_obj)
                back_groups[key].append(group)
                if cond.has_collisions(group):
                    back_save.add(obj)

        col_funcs = {}

        col_index = 0
        for key, groups in col_groups.iteritems():
            object_info, other_info = key
            class1 = self.converter.get_object_class(object_info[1])
            class2 = self.converter.get_object_class(other_info[1])
            self.converter.set_object(object_info,
                                      '((%s)col_instance_1)' % class1)
            self.converter.set_object(other_info,
                                      '((%s)col_instance_2)' % class2)
            name = 'col_%s_%s' % (col_index,
                                  self.converter.current_frame_index)
            self.converter.begin_events()
            for group in groups:
                cond = group.conditions[0]
                cond.add_collision_objects(object_info, other_info)
            name = self.converter.write_generated(name, writer, groups)
            col_funcs[key] = name
            col_index += 1

        back_funcs = {}

        for key, groups in back_groups.iteritems():
            obj, real_obj = key
            obj_class = self.converter.get_object_class(real_obj[1])
            self.converter.set_object(real_obj,
                                      '((%s)col_instance_1)' % obj_class)

            self.converter.begin_events()
            for group in groups:
                cond = group.conditions[0]
                cond.add_collision_objects(obj)

            name = 'col_%s_%s' % (col_index,
                                  self.converter.current_frame_index)
            name = self.converter.write_generated(name, writer, groups)
            back_funcs[key] = name
            col_index += 1


        use_repeated = converter.config.use_repeated_collisions()
        if not use_repeated:
            col_flags = defaultdict(lambda: set(range(32)))

            def get_flag(obj):
                if not is_qualifier(obj[0]):
                    pop = min(col_flags[obj])
                    col_flags[obj].remove(pop)
                    return 1 << pop
                flags = set(range(32))
                objs = converter.resolve_qualifier(obj)
                for obj in objs:
                    flags &= col_flags[obj]
                flag = max(flags)
                for obj in objs:
                    col_flags[obj].remove(flag)
                return 1 << flag

        call_funcs = []

        for col_index, key in enumerate(col_groups.iterkeys()):
            object_info, other_info = key
            name = col_funcs[key]
            list1 = converter.get_object_list(object_info)
            list2 = converter.get_object_list(other_info)
            if not use_repeated:
                try:
                    flag1 = get_flag(object_info)
                    if object_info == other_info:
                        flag2 = flag1
                    else:
                        flag2 = get_flag(other_info)
                except ValueError:
                    import code
                    code.interact(local=locals())

                if key in col_save:
                    func_name = 'test_collisions_save'
                else:
                    func_name = 'test_collisions'


                name = '(EventFunction)&Frames::%s' % name
                call = '%s(%s, %s, %s, %s, %s);' % (func_name, list1, list2,
                                                    flag1, flag2, name)
                call_funcs.append(call)
                continue

            wrap_name = 'collisions_%s_%s' % (col_index,
                                              converter.current_frame_index)
            call_funcs.append('%s();' % wrap_name)
            writer.putmeth('void %s' % wrap_name)

            if not use_repeated:
                flag1 = get_flag(object_info)
                flag2 = get_flag(other_info)
                writer.putlnc('StackBitArray temp = '
                              'CREATE_BITARRAY_ZERO(%s.size());', list2)
                writer.putln('int index;')

            converter.start_flat_iteration(object_info, writer, 'it1')

            writer.putlnc('col_instance_1 = %s;',
                          converter.get_object(object_info))

            converter.start_flat_iteration(other_info, writer, 'it2')
            writer.putlnc('col_instance_2 = %s;',
                          converter.get_object(other_info))

            if key in col_save:
                func_name = 'check_overlap_save'
            else:
                func_name = 'check_overlap'

            writer.putlnc('if (%s(col_instance_1, col_instance_2)) {',
                          func_name)
            writer.indent()

            writer.putlnc('%s();', name)
            
            writer.end_brace()

            if not use_repeated:
                writer.putln('index++;')

            converter.end_flat_iteration(object_info, writer, 'it2')
            converter.end_flat_iteration(object_info, writer, 'it1')

            writer.end_brace()

        name = 'test_collisions_%s' % converter.current_frame_index
        writer.putmeth('void %s' % name)

        for wrap_name in call_funcs:
            writer.putln(wrap_name)

        writer.putln('ObjectList::iterator it1, it2;')

        for key, func in back_funcs.iteritems():
            obj, real_obj = key
            list_name = converter.get_object_list(obj)
            writer.putlnc('for (it1 = %s.begin(); it1 != %s.end(); ++it1) {',
                          list_name, list_name)
            writer.indent()
            writer.putln('col_instance_1 = it1->obj;')
            if obj in back_save:
                test_func = 'overlaps_background_save'
            else:
                test_func = 'overlaps_background'
            writer.putlnc('if (!col_instance_1->%s()) {', test_func)
            writer.indent()
            writer.putlnc('col_instance_1->flags &= ~REPEAT_BACK_COLLISION;')
            writer.putln('continue;')
            writer.end_brace()

            writer.putln('if (col_instance_1->flags & REPEAT_BACK_COLLISION) '
                         'continue;')
            writer.putln('col_instance_1->flags |= REPEAT_BACK_COLLISION;')
            writer.putlnc('%s();', func)
            writer.end_brace()

        writer.end_brace()

    def write_foreach(self, writer):
        loops = defaultdict(list)
        loop_objects = {}
        for loop in self.get_conditions('OnObjectLoop'):
            parameter = loop.conditions[0].data.items[0]
            items = parameter.loader.items
            name = self.converter.convert_static_expression(items)
            loop_objects[name] = loop.conditions[0].get_object()
            loops[name].append(loop)

        self.foreach_names = {}
        self.converter.begin_events()
        for real_name, groups in loops.iteritems():
            obj = loop_objects[real_name]
            name = get_method_name(real_name)
            instance_name = 'foreach_instance_' + name
            writer.add_member('FrameObject * %s' % instance_name)
            object_class = self.converter.get_object_class(obj[1])
            self.converter.set_object(obj, '((%s)%s)' % (object_class,
                                                         instance_name))
            name = 'foreach_%s_%s' % (name, self.converter.current_frame_index)
            name = self.converter.write_generated(name, writer, groups)
            self.foreach_names[real_name] = name

    def write_loops(self, writer):
        self.loop_names = set()
        self.loop_funcs = {}
        self.loop_pos = {}
        loops = self.loops = defaultdict(list)
        self.dynamic_loops = set()

        for loop_group in self.get_conditions('OnLoop'):
            parameter = loop_group.conditions[0].data.items[0]
            items = parameter.loader.items
            name = self.converter.convert_static_expression(items)
            if name is None:
                # try and get config to give us a loop name
                name = self.converter.config.get_loop_name(parameter)
                if hasattr(name, '__iter__'):
                    names = name
                else:
                    names = (name,)
            else:
                names = (name,)

            for name in names:
                if name is None:
                    name = self.converter.convert_parameter(parameter)
                    if name not in self.loop_name_warnings:
                        print 'dynamic "on loop" not implemented:', name
                        self.loop_name_warnings.add(name)
                    continue

                if name == 'Clear Filter':
                    # KU-specific hack
                    continue

                self.loop_names.add(name.lower())
                loops[name].append(loop_group)
                self.loop_pos[name] = loop_group.global_id

        if not loops:
            return

        for name in loops.keys():
            running_name = get_loop_running_name(name)
            index_name = get_loop_index_name(name)
            writer.add_member('bool %s' % running_name)
            writer.add_member('int %s' % index_name)

        for start_loop in self.converter.action_dict['StartLoop']:
            names = start_loop.get_loop_names(loops.keys())
            if names is None:
                continue
            self.dynamic_loops.update(names)

        self.converter.begin_events()

        loop_order = []
        has_call = set()
        defer_loops = defaultdict(set)

        for name, groups in loops.iteritems():
            defer = False
            for group in groups:
                for action in group.actions:
                    if action.data.getName() != 'StartLoop':
                        continue
                    call_name = action.get_name()
                    if call_name == name or call_name not in loops:
                        continue
                    has_call.add(call_name)
                    defer_loops[name].add(call_name)
                    defer = True

            extra_calls = self.converter.config.get_loop_call_names(name)
            if extra_calls is not None:
                defer = True
                for call in extra_calls:
                    has_call.add(call)
                    defer_loops[name].add(call)


            if not defer:
                loop_order.append(name)

        for call_name in has_call:
            try:
                loop_order.remove(call_name)
            except ValueError:
                pass

        def process_name(name):
            if name not in defer_loops:
                if name not in loop_order:
                    loop_order.append(name)
                return
            if name in loop_order:
                return
            call_names = defer_loops[name]
            for call_name in call_names:
                process_name(call_name)
            loop_order.append(name)

        for name in defer_loops.iterkeys():
            process_name(name)

        for name in loop_order:
            groups = loops[name]
            loop_name = 'loop_%s' % get_loop_func_name(name, self.converter)
            self.converter.current_loop_name = name
            self.converter.current_loop_func = loop_name
            extra_calls = self.converter.config.get_loop_call_names(name)
            if extra_calls is None:
                pre_calls = None
                post_calls = None
            else:
                pos = self.loop_pos[name]

                pre_calls = []
                post_calls = []
                for call in extra_calls:
                    other_pos = self.loop_pos[call]
                    func_name = self.loop_funcs[call.lower()]
                    if pos > other_pos:
                        pre_calls.append(func_name)
                    else:
                        post_calls.append(func_name)

            loop_name = self.converter.write_generated(
                loop_name, writer, groups, pre_calls, post_calls)
            self.loop_funcs[name.lower()] = loop_name

        self.converter.current_loop_name = None
        self.converter.current_loop_func = None

        for name in self.dynamic_loops:
            loop_func = self.loop_funcs[name.lower()]
            loop_name = get_loop_func_name(name, self.converter)
            writer.putmeth('static void loop_wrapper_%s' % loop_name,
                           'void * frame')
            writer.putlnc('((Frames*)frame)->%s();', loop_func)
            writer.end_brace()


# conditions

class CollisionCondition(ConditionWriter):
    save_collision = False
    is_always = True

    def has_collisions(self, group=None):
        if not self.save_collision:
            return False
        group = group or self.group
        actions = group.actions
        for action in actions:
            if action.data.getName() in ('Stop', 'Bounce'):
                return True
        return False

    def add_collision_objects(self, *handles):
        has_col = self.has_collisions()
        for handle in handles:
            infos = self.converter.resolve_qualifier(handle)
            if has_col:
                self.converter.collision_objects.update(infos)
            for obj in infos:
                writer = self.converter.get_object_writer(obj)
                writer.has_collision_events = True
        return has_col

class IsOverlapping(CollisionCondition):
    has_object = False
    custom = True

    def write(self, writer):
        data = self.data
        negated = data.otherFlags['Not']
        object_info = (data.objectInfo, data.objectType)
        other_info = (data.items[0].loader.objectInfo,
                      data.items[0].loader.objectType)
        converter = self.converter
        selected_name = converter.create_list(object_info, writer)
        if negated:
            other_selected = converter.get_object_list(other_info,
                                                       allow_single=True)
            condition = to_c('check_not_overlap(%s, %s)', selected_name,
                             other_selected)
        else:
            other_selected = converter.create_list(other_info, writer)
            has_col = self.add_collision_objects(object_info, other_info)
            if has_col:
                func_name = 'check_overlap_save'
            else:
                func_name = 'check_overlap'
            condition = to_c('%s(%s, %s)', func_name, selected_name,
                             other_selected)
        writer.putlnc('if (!%s) %s', condition, self.converter.event_break)

    def is_negated(self):
        return False

class OnCollision(IsOverlapping):
    save_collision = True
    is_always = False

class OnBackgroundCollision(CollisionCondition):
    is_always = False
    save_collision = True

    def write(self, writer):
        obj = self.get_object()
        has_col = self.add_collision_objects(obj)
        if has_col:
            func_name = 'overlaps_background_save'
        else:
            func_name = 'overlaps_background'
        writer.put('%s()' % func_name)

class ObjectInvisible(ConditionWriter):
    def write(self, writer):
        writer.put('flags & VISIBLE')

    def is_negated(self):
        return True

class MouseOnObject(ConditionWriter):
    def get_object(self):
        data = self.data.items[0].loader
        return data.objectInfo, data.objectType

    def write(self, writer):
        writer.put('mouse_over()')

class Always(ConditionWriter):
    custom = True

    def write(self, writer):
        pass

class MouseClicked(ConditionWriter):
    is_always = True
    pre_event = True

    def write(self, writer):
        writer.put('is_mouse_pressed_once(%s)' % self.convert_index(0))

class ObjectClicked(ConditionWriter):
    is_always = True
    pre_event = True
    precedence = 1

    def get_object(self):
        data = self.data.items[1].loader
        return data.objectInfo, data.objectType

    def write(self, writer):
        writer.put('mouse_over() && '
                   'is_mouse_pressed_once(%s)' % self.convert_index(0))

KEY_FLAGS = BitDict(
    'Up',
    'Down',
    'Left',
    'Right',
    'Button1',
    'Button2',
    'Button3',
    'Button4'
)

class PlayerKeyCondition(ConditionWriter):
    method = None

    def write(self, writer):
        player = self.data.objectInfo + 1
        controls = self.converter.game.header.controls.items[player-1]
        keys = []
        flag_value = self.parameters[0].loader.value

        flags = KEY_FLAGS.copy()
        flags.setFlags(flag_value)
        for k, v in flags.iteritems():
            if not v:
                continue
            keys.append('CONTROL_%s' % k.upper())
        if not keys:
            keys.append('0')
        flag_value = ' | '.join(keys)

        writer.putc('%s(%s, %s)', self.key_method, player, flag_value)

class PlayerKeyDown(PlayerKeyCondition):
    key_method = 'is_player_pressed'

class PlayerKeyPressed(PlayerKeyCondition):
    is_always = True
    pre_event = True
    key_method = 'is_player_pressed_once'

class AnyKeyPressed(ConditionMethodWriter):
    is_always = True
    pre_event = True
    method = 'is_any_key_pressed_once'

class PlayerDied(ConditionMethodWriter):
    is_always = True
    post_event = True
    method = '.manager.player_died'

class TimerEquals(ConditionWriter):
    is_always = True
    custom = True

    def write(self, writer):
        loader = self.parameters[0].loader
        if loader.isExpression:
            seconds = '(%s) / 1000.0' % self.convert_index(0)
        else:
            seconds = self.parameters[0].loader.timer / 1000.0
        writer.putlnc('if (frame_time < %s) %s', seconds,
                      self.converter.event_break)
        write_not_always(writer, self)

class TimerGreater(ConditionWriter):
    is_always = True

    def write(self, writer):
        loader = self.parameters[0].loader
        if loader.isExpression:
            seconds = '(%s) / 1000.0' % self.convert_index(0)
        else:
            seconds = self.parameters[0].loader.timer / 1000.0
        writer.put('frame_time >= %s' % seconds)

class TimerLess(ConditionWriter):
    is_always = True

    def write(self, writer):
        loader = self.parameters[0].loader
        if loader.isExpression:
            seconds = '(%s) / 1000.0' % self.convert_index(0)
        else:
            seconds = self.parameters[0].loader.timer / 1000.0
        writer.put('frame_time <= %s' % seconds)

class TimerEvery(ConditionWriter):
    is_always = True
    custom = True

    def write(self, writer):
        time = self.parameters[0].loader
        time = getattr(time, 'delay', None) or time.timer
        seconds = time / 1000.0
        name = 'every_%s' % TEMPORARY_GROUP_ID
        self.group.add_member('float %s' % name, '0.0f')
        event_break = self.converter.event_break
        writer.putln('%s += manager.dt;' % name)
        writer.putln('if (%s < %s) %s' % (name, seconds, event_break))
        writer.putln('%s -= %s;' % (name, seconds))

class AnimationFinished(ConditionWriter):
    is_always = True

    def write(self, writer):
        generated = self.group.conditions[0] is self
        if generated:
            writer.put('animation_finished == %s' % self.convert_index(0))
            return
        writer.put('is_animation_finished(%s)' % self.convert_index(0))

class PathFinished(ConditionMethodWriter):
    is_always = True
    method = 'get_movement()->is_path_finished'

class NodeReached(ConditionMethodWriter):
    is_always = True
    method = 'get_movement()->is_node_reached'

class OnGroupActivation(ConditionWriter):
    custom = True
    check_id = None

    def write(self, writer):
        group_check = self.get_group_check()
        writer.putlnc('if (!%s) %s', group_check, self.converter.event_break)
        writer.putln('%s = false;' % group_check)

    def get_group_check(self):
        if self.check_id is None:
            self.check_id = self.container.check_ids.next()
        return 'group_check_%s_%s' % (self.container.code_name, self.check_id)

class RepeatCondition(ConditionWriter):
    custom = True

    def write(self, writer):
        count = self.convert_index(0)
        name = get_repeat_name(self.group)
        writer.putlnc('if (%s >= %s) %s', name, count,
                      self.converter.event_break)
        writer.putlnc('%s++;', name)
        self.group.add_member('int %s' % name, '0')

class RestrictFor(ConditionWriter):
    custom = True

    def write(self, writer):
        seconds = self.parameters[0].loader.timer / 1000.0
        name = get_restrict_name(self.group)
        writer.putlnc('if (frame_time - %s < %s) %s', name, seconds,
                      self.converter.event_break)
        writer.putlnc('%s = frame_time;', name)
        self.group.add_member('float %s' % name, 'frame_time')

def write_not_always(writer, ace):
    name = 'not_always_%s' % TEMPORARY_GROUP_ID
    ace.group.add_member('unsigned int %s' % name, 'loop_count')
    event_break = ace.converter.event_break
    writer.putln('if (%s > loop_count) {' % (name))
    writer.indent()
    writer.putln('%s = loop_count + 2;' % name)
    writer.putln(event_break)
    writer.end_brace()
    writer.putln('%s = loop_count + 2;' % name)

class NotAlways(ConditionWriter):
    custom = True

    def write(self, writer):
        write_not_always(writer, self)

class OnceCondition(ConditionWriter):
    custom = True
    def write(self, writer):
        event_break = self.converter.event_break
        name = 'once_condition_%s' % TEMPORARY_GROUP_ID
        self.group.add_member('bool %s' % name, 'false')
        writer.putlnc('if (%s) %s', name, event_break)
        writer.putlnc('%s = true;', name)

class GroupActivated(ConditionWriter):
    def write(self, writer):
        container = self.converter.containers[
            self.parameters[0].loader.pointer]
        writer.put(self.converter.get_container_check(container))

class PickRandom(ConditionWriter):
    custom = True
    def write(self, writer):
        obj = self.get_object()
        converter = self.converter
        if converter.has_single(obj):
            return
        selected_name = converter.create_list(obj, writer)
        single_name = 'single_instance_%s' % self.get_id(self)
        class_type = converter.get_object_class(obj[1])
        writer.putlnc('FrameObject * %s; %s = pick_random(%s);',
                      single_name, single_name, selected_name)
        writer.putlnc('if (%s == NULL) %s', single_name,
                      self.converter.event_break)
        converter.set_object(obj, '((%s)%s)' %  (class_type, single_name))

class NumberOfObjects(ComparisonWriter):
    has_object = False
    iterate_objects = False

    def get_comparison_value(self):
        obj = (self.data.objectInfo, self.data.objectType)
        return '%s.size()' % self.converter.get_object_list(obj,
                                                            allow_single=True)

class MouseInZone(ConditionMethodWriter):
    def write(self, writer):
        zone = self.parameters[0].loader
        writer.putc('mouse_in_zone(%s, %s, %s, %s)',
                    zone.x1, zone.y1, zone.x2, zone.y2)

class CompareObjectsInZone(ComparisonWriter):
    has_object = False
    iterate_objects = False

    def get_parameters(self):
        return self.parameters[1:]

    def write_pre(self, writer):
        obj = (self.data.objectInfo, self.data.objectType)
        self.obj_list = self.converter.create_list(obj, writer)

    def get_comparison_value(self):
        zone = self.parameters[0].loader
        return 'objects_in_zone(%s, %s, %s, %s, %s)' % (self.obj_list, zone.x1,
            zone.y1, zone.x2, zone.y2)

class NoObjectsInZone(ConditionWriter):
    has_object = False
    iterate_objects = False

    def get_parameters(self):
        return self.parameters[1:]

    def write(self, writer):
        zone = self.parameters[0].loader
        writer.putc('objects_in_zone(%s, %s, %s, %s, %s) == 0', self.obj_list,
                    zone.x1, zone.y1, zone.x2, zone.y2)

    def write_pre(self, writer):
        obj = (self.data.objectInfo, self.data.objectType)
        self.obj_list = self.converter.create_list(obj, writer)

class AllDestroyed(ConditionWriter):
    is_always = True
    custom = True

    def write(self, writer):
        obj = (self.data.objectInfo, self.data.objectType)
        obj_list = self.converter.create_list(obj, writer)
        writer.putlnc('if (%s.size() != 0) %s', obj_list,
                      self.converter.event_break)
        generated = self is self.group.conditions[0]
        if generated:
            write_not_always(writer, self)

class PickCondition(ConditionWriter):
    custom = True

    def write(self, writer):
        objs = set()


        actions = self.converter.current_groups[-1].actions
        conditions = self.group.conditions
        conditions = conditions[conditions.index(self)+1:]

        lists = (actions, conditions)

        for ace_list in lists:
            for ace in ace_list:
                for parameter in ace.parameters:
                    loader = parameter.loader
                    if not loader.isExpression:
                        continue
                    for item in loader.items:
                        exp = self.converter.get_expression_writer(item)
                        objs.add(exp.get_object())

                objs.add(ace.get_object())

        new_objs = set()

        for obj in objs:
            if obj[0] is None:
                continue
            if (not is_qualifier(obj[0]) and
                    not self.converter.is_valid_object(obj)):
                continue
            if not self.pickable(obj):
                continue
            new_objs.add(obj)
            if self.converter.has_multiple_instances(obj):
                continue
            self.converter.current_group.force_multiple.add(obj)

        self.write_pick(writer, new_objs)

    def pickable(self, obj):
        return True

class PickObjectsInZone(PickCondition):
    def write_pick(self, writer, objs):
        zone = self.parameters[0].loader
        for obj in objs:
            if obj in self.converter.has_single_selection:
                if obj not in self.converter.has_selection:
                    raise NotImplementedError()
                del self.converter.has_single_selection[obj]
            obj_list = self.converter.create_list(obj, writer)
            writer.putlnc('pick_objects_in_zone(%s, %s, %s, %s, %s);',
                          obj_list, zone.x1, zone.y1, zone.x2, zone.y2)

class PickAlterableCondition(PickCondition):
    def pickable(self, obj):
        impl = self.converter.get_object_impl(obj[1])
        return impl.use_alterables

class PickAlterableValue(PickAlterableCondition):
    def write_pick(self, writer, objs):
        comparison = self.get_comparison()
        index = self.convert_index(0)

        writer.start_brace()
        writer.putlnc('double check_value = %s;', self.convert_index(1))

        for obj in objs:
            with self.converter.iterate_object(obj, writer, copy=False):
                obj = self.converter.get_object(obj)
                writer.putlnc('if (!((*it)->alterables->values.get(%s) %s %s))'
                              ' it.deselect();',
                              index, comparison, 'check_value')
        writer.end_brace()

class PickFlagOn(PickAlterableCondition):
    def write_pick(self, writer, objs):
        comparison = self.get_comparison()
        index = self.convert_index(0)

        writer.start_brace()

        for obj in objs:
            with self.converter.iterate_object(obj, writer, copy=False):
                obj = self.converter.get_object(obj)
                writer.putlnc('if (!((*it)->alterables->flags.is_on(%s)))'
                              ' it.deselect();', index)
        writer.end_brace()


class PickFromFixed(PickCondition):
    def write_pick(self, writer, objs):
        writer.start_brace()
        fixed = self.convert_index(0)
        writer.putlnc('FrameObject * fixed = get_object_from_fixed(%s);',
                      fixed)

        for obj in objs:
            with self.converter.iterate_object(obj, writer, copy=False):
                obj = self.converter.get_object(obj)
                writer.putlnc('if ((*it) != fixed) it.deselect();')
        writer.end_brace()

class CompareFixedValue(ConditionWriter):
    custom = True
    force_single = False
    def write(self, writer):
        obj = self.get_object()
        converter = self.converter

        end_label = 'fixed_%s_end' % self.get_id(self)
        value = self.convert_index(0)
        comparison = self.get_comparison()
        is_equal = comparison == '=='
        has_selection = obj in converter.has_selection
        is_instance = value.endswith('get_fixed()')
        test_all = (has_selection or not is_equal or
                    (not is_instance and not self.force_single))
        if is_instance:
            instance_value = value.replace('->get_fixed()', '')
        else:
            instance_value = 'get_object_from_fixed(%s)' % value

        fixed_name = 'fixed_test_%s' % self.get_id(self)

        writer.putln('FrameObject * %s = %s;' % (fixed_name, instance_value))
        is_single = (converter.has_single(obj) or
                     not converter.has_multiple_instances(obj))

        if is_equal or is_single:
            event_break = converter.event_break
        else:
            event_break = 'goto %s;' % end_label

        if not is_instance:
            writer.putln('if (%s == NULL) %s' % (fixed_name, event_break))
        if is_single:
            obj = converter.get_object(obj)
            writer.putlnc('if (%s %s %s) %s', obj, comparison, fixed_name,
                          event_break)
        elif test_all:
            list_name = converter.create_list(obj, writer)
            with converter.iterate_object(obj, writer, copy=False):
                writer.putlnc('if (!((*it) %s %s)) it.deselect();', comparison,
                              fixed_name)
            if not is_equal:
                writer.put_label(end_label)
            writer.putlnc('if (!%s.has_selection()) %s', list_name,
                          converter.event_break)
        else:
            class_name = self.converter.get_object_class(obj[1])
            converter.set_object(obj, '((%s)%s)' % (class_name, fixed_name))

class FacingInDirection(ConditionWriter):
    def write(self, writer):
        parameter = self.parameters[0].loader
        if parameter.isExpression:
            name = 'test_direction'
            value = self.convert_index(0)
        else:
            name = 'test_directions'
            value = parameter.value & 0xFFFFFFFF
        writer.put('%s(%s)' % (name, value))

class OutsidePlayfield(ConditionMethodWriter):
    method = 'outside_playfield'

class InsidePlayfield(OutsidePlayfield):
    def is_negated(self):
        return not ConditionMethodWriter.is_negated(self)

class LeavingPlayfield(CollisionCondition):
    is_always = True

    def write(self, writer):
        value = self.parameters[0].loader.value
        if value != 15:
            print 'leaving playfield for %s not implemented' % value
            # raise NotImplementedError()
        writer.put('outside_playfield()')
        self.add_collision_objects(self.get_object())

# actions

class CollisionAction(ActionWriter):
    def write(self, writer):
        obj = self.get_object()
        is_col = obj in self.converter.collision_objects
        writer.put(to_c(self.method + ';', is_col))

class StopAction(CollisionAction):
    method = 'get_movement()->stop(%s)'

class BounceAction(CollisionAction):
    method = 'get_movement()->bounce(%s)'

class CreateBase(ActionWriter):
    """
    Cases to consider:

    1) Create object 1
       Use of object 1
       Create object 2
       Use object 1 (right now, we select object 2)

    2) Create object 1
       Create object 2
       Create object 3
       Use object 1, 2, 3

    3) Create object 1
       Create object 2
       Use object 1, 2
       Create object 3
       Use object 1, 2 (right now, we select object 3)

    4) Use object 1, 2
       Create object 3, 4
       Use object 1, 2 (right now, we select object 3, 4)

    5) Create object 4, 5 from parent 2, 3 (1 action)
       Use object 4

    6) Create object 4, 5 from parent 2, 3 (1 action)
       (Do or do not do something irrelevant here)
       Create object 6 from parent 3
       Use object 4, 5, 6
       (we don't want to handle this case)

    7) Create object 2 from parent 1
       Use object 2
       -> All objects are deselected here through e.g. a fastloop
       Create object 3 from parent 1
       Use object 3

    8) Create object 2 from parent 1
       (Do or do not do something irrelevant here)
       Create object 3 from parent 1
       Use object 2, 3
    
    9) Create object 2 from parent 1
       Use object 2
       Create object 3 from parent 1
       Use object 2

    In reality, Fusion only deals with a single instance at a time, iterating
    the action list for each. We try and emulate that here, as this is the
    only place where it makes a difference

    Also, we try and emulate creation order. Cases:

    7) Create object 1 (p3), 2 (p3), 1 (p4), 2(p4) from parent 3, 4

    """
    custom = True
    skip_create = False

    def get_create_info(self):
        object_info = self.parameters[0].loader.objectInfo
        return self.converter.filter_object_type((object_info, None))

    def get_details(self):
        return self.convert_index(0)

    def write_set(self, writer, set_index, parent_info, object_info,
                  create_set, multi):
        if not create_set:
            return
        end_name = 'create_%s_%s_end' % (self.get_id(self), set_index)

        list_name = self.converter.get_object_list(object_info, True)

        has_selection = object_info in self.converter.has_selection
        select_single = (not multi and parent_info is not None
                         and not has_selection)
        single_name = 'single_instance_%s' % self.get_id(self)
        if select_single:
            writer.putlnc('FrameObject * %s; %s = NULL;', single_name,
                          single_name)
        if select_single:
            class_name = self.converter.get_object_class(object_info[1])
            self.converter.set_object(object_info,
                                      '((%s)%s)' % (class_name, single_name))

        if object_info != parent_info and (not has_selection and
                                           not select_single):
            writer.putlnc('%s.empty_selection();', list_name)
            self.converter.set_list(object_info, list_name)

        writer.putlnc('// select single: %s %s %s', select_single,
                      multi, has_selection)

        single_parent = self.converter.get_single(parent_info)
        if parent_info is not None:
            if not single_parent and is_qualifier(parent_info[0]):
                objs = self.converter.resolve_qualifier(parent_info)
                if object_info in objs:
                    # don't know how to resolve this 
                    raise NotImplementedError()

        safe = (select_single and parent_info is not None and not
                single_parent and self.converter.config.use_safe_create())
        safe_name = None

        if single_parent:
            parent = single_parent
        elif parent_info is not None:
            self.converter.start_object_iteration(parent_info, writer, 'p_it',
                                                  copy=False)
            writer.putlnc('FrameObject * parent = %s;',
                          self.converter.get_object(parent_info))
            parent = 'parent'

        for details in create_set:
            is_shoot = self.is_shoot
            x = str(details['x'])
            y = str(details['y'])
            direction = None
            use_direction = details.get('use_direction', False)
            use_action_point = details.get('use_action_point', False)
            if is_shoot:
                if use_action_point and not use_direction:
                    direction = parse_direction(details['direction'])
                else:
                    direction = '-1'

            writer.start_brace()
            if parent_info is not None and not is_shoot:
                if use_action_point:
                    parent_x = 'get_action_x() - %s->layer->off_x' % parent
                    parent_y = 'get_action_y() - %s->layer->off_y' % parent
                else:
                    parent_x = 'x'
                    parent_y = 'y'
                if details.get('transform_position_direction', False):
                    writer.putln('int x_off; x_off = %s;' % x)
                    writer.putln('int y_off; y_off = %s;' % y)
                    writer.putlnc('transform_pos(x_off, y_off, %s);', parent)
                    x = 'x_off'
                    y = 'y_off'
                if use_direction:
                    direction = '%s->direction' % parent
                x = '%s->%s + %s' % (parent, parent_x, x)
                y = '%s->%s + %s' % (parent, parent_y, y)
                layer = '%s->layer' % parent
            elif is_shoot:
                layer = '%s->layer' % parent
            else:
                layer = details['layer']
            writer.putlnc('FrameObject * new_obj;')
            self.converter.create_object(object_info, x, y, layer, 'new_obj',
                                         writer)
            if select_single:
                writer.putlnc('if (%s == NULL)', single_name)
                writer.indent()
                writer.putlnc('%s = new_obj;', single_name)
                writer.dedent()
            else:
                writer.putlnc('%s.add_back();', list_name)
            if is_shoot:
                self.converter.get_object_writer(object_info).has_shoot = True
                writer.putlnc('%s->shoot(new_obj, %s, %s);', parent,
                              details['shoot_speed'], direction)
                # object_class = self.converter.get_object_class(
                #     object_info=parent_info, star=False)
                # print object_class
                # if object_class == 'Active':
                #     parent = '((Active*)%s)' % parent
                #     writer.putlnc('if (%s->has_animation(SHOOTING))', parent)
                #     writer.indent()
                #     writer.putlnc('%s->force_animation(SHOOTING);', parent)
                #     writer.dedent()

            elif direction:
                writer.putln('new_obj->set_direction(%s);' % direction)
            writer.end_brace()

        if parent_info is not None and not single_parent:
            self.converter.end_object_iteration(parent_info, writer, 'p_it',
                                                copy=False)

        if safe:
            writer.putlnc('if (%s == NULL) {', single_name)
            writer.indent()
            self.converter.create_object(object_info, 0, 0, 0, single_name,
                                         writer)
            writer.putlnc('%s->destroy();', single_name)
            writer.end_brace()

        if False: # action_name == 'DisplayText':
            paragraph = parameters[1].loader.value
            if paragraph != 0:
                raise NotImplementedError

    def write(self, writer):
        if self.skip_create:
            return
        details = self.get_details()
        if details is None:
            return
        object_info = self.get_create_info()

        # here are some crazy heuristics to properly emulate the super wonky
        # MMF2 create selection behaviour
        actions = self.converter.current_group.actions
        self_index = actions.index(self)

        create_actions = {self_index: details}

        def get_actions(direction):
            index = self_index
            while True:
                index += direction
                if index < 0:
                    return
                try:
                    action = actions[index]
                except IndexError:
                    return
                if action.data.getName() == 'CreateObject':
                    if action.get_create_info() == object_info:
                        action.skip_create = True
                        create_actions[index] = action.get_details()
                    continue
                if action.get_object() == object_info:
                    return

        get_actions(-1)
        get_actions(1)

        multi = len(create_actions) > 1

        current_parent = None
        current_set = []
        for index in sorted(create_actions):
            details = create_actions[index]
            parent_info = details.get('parent', None)
            if parent_info != current_parent:
                self.write_set(writer, index, current_parent, object_info,
                               current_set, multi)
                current_parent = parent_info
                current_set = []
            current_set.append(details)

        self.write_set(writer, index, current_parent, object_info, current_set,
                       multi)


class CreateObject(CreateBase):
    is_shoot = False

class ShootObject(CreateBase):
    is_shoot = True

class SetPosition(ActionWriter):
    custom = True

    def write(self, writer):
        object_info = self.get_object()

        end_name = 'pos_end_%s' % self.get_id(self)

        details = self.convert_index(0)
        x = str(details['x'])
        y = str(details['y'])
        parent = details.get('parent', None)

        self.converter.start_object_iteration(object_info, writer,
                                              copy=False)
        obj = self.converter.get_object(object_info)

        if parent is not None and not is_qualifier(parent[0]):
            parent_writer = self.converter.get_object_writer(parent)
            if parent_writer.static:
                data = self.converter.static_instances[parent_writer]
                x = '%s+%s' % (x, data.x)
                y = '%s+%s' % (y, data.y)
                parent = None

        if parent is not None:
            parent = self.converter.get_object(parent)
            writer.putln('FrameObject * parent = %s;' % parent)
            writer.putlnc('if (parent == NULL) goto %s;', end_name)
            if details.get('use_action_point', False):
                parent_x = 'get_action_x()'
                parent_y = 'get_action_y()'
            else:
                parent_x = 'get_x()'
                parent_y = 'get_y()'
            if details.get('transform_position_direction', False):
                writer.putln('int x_off; x_off = %s;' % x)
                writer.putln('int y_off; y_off = %s;' % y)
                writer.putln('transform_pos(x_off, y_off, parent);')
                x = 'x_off'
                y = 'y_off'
            if details.get('use_direction', False):
                writer.putlnc('%s->set_direction(parent->direction);', obj)
            x = 'parent->%s + %s' % (parent_x, x)
            y = 'parent->%s + %s' % (parent_y, y)
        arguments = [x, y]
        writer.putlnc('%s->set_global_position(%s);', obj,
                      ', '.join(arguments))
        writer.put_label(end_name)
        self.converter.end_object_iteration(object_info, writer,
                                            copy=False)

class SwapPosition(ActionWriter):
    custom = True
    def write(self, writer):
        config = self.group.config
        swap_name = config.get('swap_name', None)
        if swap_name is None:
            swap_name = 'swap_%s' % TEMPORARY_GROUP_ID
            config['swap_name'] = swap_name
            writer.putlnc('static FlatObjectList %s;', swap_name)
            writer.putlnc('%s.clear();', swap_name)

        obj = self.get_object()
        with self.converter.iterate_object(obj, writer, copy=False):
            writer.putlnc('%s.push_back(%s);', swap_name,
                          self.converter.get_object(obj))

    def write_post(self, writer):
        config = self.group.config
        if config.get('has_swap', False):
            return
        config['has_swap'] = True
        writer.putlnc('swap_position(%s);', config['swap_name'])

class LookAt(ActionWriter):
    def write(self, writer):
        object_info = self.get_object()
        instance = self.converter.get_object(object_info)
        details = self.convert_index(0)
        x = str(details['x'])
        y = str(details['y'])
        parent = details.get('parent', None)
        if parent:
            parent = self.converter.get_object(parent)
            x = '%s->x + %s' % (parent, x)
            y = '%s->y + %s' % (parent, y)
        writer.put('set_direction(get_direction_int(%s->x, %s->y, %s, %s));'
            % (instance, instance, x, y))

class LayerAction(ActionWriter):
    single = False
    custom = True

    def write(self, writer):
        obj = self.get_object()
        other = self.get_other()

        single = self.single or self.has_single(obj) or self.has_single(other)
        if single:
            obj = self.converter.get_object(obj, use_default=True)
            other = self.converter.get_object(other)
            writer.putlnc('%s->%s(%s);', obj, self.func, other)
            return

        end_label = 'action_%s_end' % self.get_id(self)

        writer.start_brace()
        other_list = self.converter.create_list(other, writer)
        iter_type = self.converter.get_iter_type(other)
        writer.putlnc('%s other_it(%s);', iter_type, other_list)
        with self.converter.iterate_object(obj, writer, copy=False):
            obj = self.converter.get_object(obj)
            writer.putlnc('if (other_it.end()) goto %s;', end_label)
            writer.putlnc('%s->%s(*other_it);', obj, self.func)
            writer.putln('++other_it;')
        writer.end_brace()
        writer.put_label(end_label)

    def has_single(self, obj):
        return (self.converter.has_single(obj) or
                not self.converter.has_multiple_instances(obj))

    def get_other(self):
        return (self.parameters[0].loader.objectInfo,
                self.parameters[0].loader.objectType)

class MoveInFront(LayerAction):
    func = 'move_front'

class MoveBehind(LayerAction):
    func = 'move_back'

class Foreach(ActionWriter):
    custom = True

    def get_name(self):
        parameter = self.parameters[0]
        items = parameter.loader.items
        return self.converter.convert_static_expression(items)

    def write(self, writer):
        self.reorder = self.converter.config.reorder_foreach()
        if self.reorder:
            return
        self.write_foreach(writer)

    def write_post(self, writer):
        if not self.reorder:
            return
        self.write_foreach(writer)

    def write_foreach(self, writer):
        writer.start_brace()
        obj = self.get_object()
        object_class = self.converter.get_object_class(obj[1])
        real_name = self.get_name()
        if real_name is None:
            raise NotImplementedError()
        name = get_method_name(real_name)
        if real_name not in self.converter.system_object.foreach_names:
            writer.putlnc('// nested foreach not implemented: %s',
                          real_name)
            writer.end_brace()
            print 'foreach error! nested foreach not implemented yet'
            return
        func_call = self.converter.system_object.foreach_names[real_name]
        with self.converter.iterate_object(obj, writer):
            selected = self.converter.get_object(obj)
            writer.putlnc('foreach_instance_%s = %s;', name, selected)
            writer.putlnc('%s();', func_call)
        writer.end_brace()

class StartLoop(ActionWriter):
    custom = True
    loop_warnings = set()

    def get_name(self):
        parameter = self.parameters[0]
        items = parameter.loader.items
        name = self.converter.convert_static_expression(items)
        if name is not None:
            return name
        return self.converter.config.get_dynamic_loop_call_name(parameter)

    def get_loop_names(self, loops):
        if self.get_name() is not None:
            return
        strings = self.converter.get_string_expressions(self.parameters[0])
        strings = [v.lower() for v in strings]
        loop_names = set()
        for loop in loops:
            loop_check = loop.lower()
            for substring in strings:
                if substring not in loop_check:
                    continue
                loop_names.add(loop)
                break
        return loop_names

    def write(self, writer):
        real_name = self.get_name()
        if real_name is None:
            func_call = 'dyn_loop.callback(this)'
        else:
            loop_names = self.converter.system_object.loop_names
            if real_name.lower() not in loop_names:
                if real_name == 'Clear Filter':
                    self.converter.clear_selection()
                if real_name not in self.loop_warnings:
                    print 'Could not find loop %r' % real_name
                    print '(ignoring all future instances)'
                    self.loop_warnings.add(real_name)
                return
            loop_funcs = self.converter.system_object.loop_funcs
            if real_name == self.converter.current_loop_name:
                name = self.converter.current_loop_func
            else:
                try:
                    name = loop_funcs[real_name.lower()]
                except KeyError, e:
                    print 'Error: could not find loop instance'
                    print self.converter.current_loop_name
                    print real_name
                    print loop_funcs
                    import code
                    code.interact(local=locals())
                    raise e
            func_call = '%s()' % name

        use_clear = self.converter.config.use_loop_selection_clear()
        if not use_clear:
            used_after = set()

            selection_after = {}

            actions = self.converter.current_group.actions
            self_index = actions.index(self)
            for index, action in enumerate(actions):
                if self_index > index:
                    continue
                obj = action.get_object()
                if obj[0] is None:
                    continue
                if not self.converter.has_multiple_instances(obj):
                    continue
                if not obj in self.converter.has_selection:
                    continue
                used_after.add(obj)

            used_before = set(self.converter.has_selection.iterkeys())
            problem_obj = used_before & used_after

            for obj in problem_obj:
                list_name = self.converter.has_selection[obj]
                new_name = 'extra_%s' % list_name
                selection_after[obj] = new_name
                writer.putlnc('SavedSelection %s(%s);', new_name, list_name)

            if problem_obj:
                writer.putlnc('// Problem objs: %s', problem_obj)

        comparison = None
        times = None
        try:
            exp, = self.parameters[1].loader.items[:-1]
            if exp.getName() == 'Long':
                times = exp.loader.value
                if times == -1:
                    comparison = 'true'
        except ValueError:
            pass
        if times is None:
            times = self.convert_index(1)
        is_infinite = comparison is not None
        is_dynamic = real_name is None
        if is_dynamic:
            running_name = '(*dyn_loop.running)'
            index_name = '(*dyn_loop.index)'
        else:
            running_name = get_loop_running_name(real_name)
            index_name = get_loop_index_name(real_name)
        if not is_infinite:
            comparison = '%s < times' % index_name
        writer.start_brace()
        if is_dynamic:
            dynamic_end = 'dynamic_%s_end' % self.get_id(self)
            writer.putlnc('if (loops == NULL) goto %s;', dynamic_end)
            writer.putlnc('DynamicLoops::iterator dyn_it = '
                          '(*loops).find(%s);', self.convert_index(0))
            writer.putlnc('if (dyn_it == (*loops).end()) goto %s;',
                          dynamic_end)
            writer.putlnc('DynamicLoop & dyn_loop = dyn_it->second;')
        writer.putln('%s = true;' % running_name)
        if not is_infinite:
            writer.putln('int times = int(%s);' % times)

        writer.putln('%s = 0;' % index_name)
        writer.putln('while (%s) {' % comparison)
        writer.indent()

        self.converter.config.write_loop(real_name, self, writer)

        writer.putln('%s;' % func_call)
        writer.putln('if (!%s) break;' % running_name)
        writer.putln('%s++;' % index_name)
        writer.end_brace()
        writer.end_brace()

        # since we have cleared the object selection list, we need to
        # remove and insert a new scope
        # writer.end_brace()
        if is_dynamic:
            writer.put_label(dynamic_end)
        # writer.start_brace()

        if use_clear:
            self.converter.clear_selection()
            self.group.force_multiple = set()
        else:
            writer.putln('// %r' % selection_after)
            self.converter.has_selection.update(selection_after)
            self.converter.saved_selections.update(selection_after.iterkeys())
            writer.putln('// %r' % self.converter.has_selection)


class DeactivateGroup(ActionWriter):
    deactivated_container = None
    def write(self, writer):
        container = self.get_deactivated_container()
        writer.putln('%s = false;' % container.code_name)

    def get_deactivated_container(self):
        if self.deactivated_container is None:
            self.deactivated_container = self.converter.containers[
                self.parameters[0].loader.pointer]
        return self.deactivated_container

class StopLoop(ActionWriter):
    def write(self, writer):
        parameter = self.parameters[0]
        items = parameter.loader.items
        name = self.converter.convert_static_expression(items)
        if name is None:
            name = self.converter.convert_parameter(parameter)
            print 'Could not convert stop loop name for', name
            return
        running_name = get_loop_running_name(name)
        writer.putln('%s = false;' % running_name)

class SetLoopIndex(ActionWriter):
    def write(self, writer):
        exp, = self.parameters[0].loader.items[:-1]
        name = exp.loader.value
        index_name = get_loop_index_name(name)
        value = self.convert_index(1)
        writer.putln('%s = %s;' % (index_name, value))

class ActivateGroup(ActionWriter):
    custom = True

    def write(self, writer):
        container = self.converter.containers[
            self.parameters[0].loader.pointer]
        writer.putlnc('if (!%s) {', container.code_name)
        writer.indent()
        writer.putlnc('%s = true;', container.code_name)
        check_names = set()
        group_activations = self.converter.system_object.group_activations
        for child in ([container] + container.get_all_children()):
            check_names.update(group_activations[child])
        for name in check_names:
            writer.putln('%s = true;' % name)
        writer.end_brace()


class CenterDisplayX(ActionWriter):
    def write(self, writer):
        writer.put('set_display_center(%s, -1);' % self.convert_index(0))

class CenterDisplayY(ActionWriter):
    def write(self, writer):
        writer.put('set_display_center(-1, %s);' % self.convert_index(0))

class CenterDisplay(ActionWriter):
    custom = True

    def write(self, writer):
        writer.start_brace()

        details = self.convert_index(0)
        x = str(details['x'])
        y = str(details['y'])
        parent = details.get('parent', None)
        if parent is not None:
            parent = self.converter.get_object(parent)
            writer.putln('FrameObject * parent = %s;' % parent)
            if details.get('use_action_point', False):
                parent_x = 'get_action_x()'
                parent_y = 'get_action_y()'
            else:
                parent_x = 'get_x()'
                parent_y = 'get_y()'
            if details.get('transform_position_direction', False):
                writer.putln('int x_off = %s;' % x)
                writer.putln('int y_off = %s;' % y)
                writer.putln('transform_pos(x_off, y_off, parent);')
                x = 'x_off'
                y = 'y_off'
            x = 'parent->%s + %s' % (parent_x, x)
            y = 'parent->%s + %s' % (parent_y, y)
        writer.putlnc('set_display_center(%s, %s);', x, y)
        writer.end_brace()

class EndApplication(ActionWriter):
    def write(self, writer):
        writer.put('has_quit = true;')

class SetFrameAction(ActionWriter):
    def set_frame(self, writer, value):
        writer.putc('next_frame = %s + %s;', value,
                    self.converter.frame_index_offset)
        writer.putln('')
        fade = self.converter.current_frame.fadeOut
        if not fade:
            return
        if fade.duration == 0:
            return
        writer.putln('if (loop_count != 0)')
        writer.indent()
        transition.write(writer, fade, True)
        writer.dedent()

class JumpToFrame(SetFrameAction):
    def write(self, writer):
        try:
            frame = self.parameters[0].loader
            if frame.isExpression:
                value = '%s-1' % self.convert_index(0)
            else:
                value = str(self.converter.game.frameHandles[frame.value])
            self.set_frame(writer, value)
        except IndexError:
            pass

class RestartFrame(SetFrameAction):
    def write(self, writer):
        self.set_frame(writer, 'index')

class NextFrame(SetFrameAction):
    def write(self, writer):
        self.set_frame(writer, 'index + 1')

class PreviousFrame(SetFrameAction):
    def write(self, writer):
        self.set_frame(writer, 'index - 1')

class SetInkEffect(ActionWriter):
    custom = True

    def write(self, writer):
        ink_effect = self.parameters[0].loader.value1
        ink_value = self.parameters[0].loader.value2

        with self.converter.iterate_object(self.get_object(), writer,
                                           copy=False):
            obj = self.converter.get_object(self.get_object())
            if ink_effect in INK_EFFECTS:
                writer.putlnc('%s->set_shader(%s);', obj,
                              shader.get_name(INK_EFFECTS[ink_effect]))
            elif ink_effect == SEMITRANSPARENT_EFFECT:
                writer.putlnc('%s->blend_color.set_semi_transparency(%s);',
                              obj, ink_value)
                writer.putlnc('%s->set_shader(Render::NONE);', obj)
            else:
                print 'unknown set ink effect:', ink_effect

            if ink_effect == SEMITRANSPARENT_EFFECT:
                writer.putlnc('%s->blend_color.set_rgb(255, 255, 255);',
                              obj)
            else:
                writer.putlnc('%s->blend_color.set(255, 255, 255, 255);',
                              obj)

class SetSemiTransparency(ActionWriter):
    custom = True

    def write(self, writer):
        with self.converter.iterate_object(self.get_object(), writer,
                                           copy=False):
            obj = self.converter.get_object(self.get_object())
            value = self.convert_index(0)
            writer.putlnc('%s->blend_color.set_semi_transparency(%s);',
                          obj, value)

class SetEffect(ActionWriter):
    custom = True

    def write(self, writer):
        with self.converter.iterate_object(self.get_object(), writer,
                                           copy=False):
            obj = self.converter.get_object(self.get_object())
            name = self.parameters[0].loader.value
            if name == '':
                name = None
            shader_name = shader.get_name(name)
            writer.putlnc('%s->set_shader(%s);', obj, shader_name)

class SpreadValue(ActionWriter):
    custom = True
    def write(self, writer):
        alt = self.convert_index(0)
        start = self.convert_index(1)
        obj = self.get_object()
        object_list = self.converter.create_list(obj, writer)
        writer.putln('spread_value(%s, %s, %s);' % (object_list, alt, start))

class Destroy(ActionMethodWriter):
    method = 'destroy'
    ignore_static = True

class PlayerAction(ActionMethodWriter):
    def write(self, writer):
        player = self.data.objectInfo + 1
        if player != 1:
            return
        self.write_player(writer)

    def write_player(self, writer):
        return ActionMethodWriter.write(self, writer)

class IgnoreControls(PlayerAction):
    method = '.manager.ignore_controls = true'

class RestoreControls(PlayerAction):
    method = '.manager.ignore_controls = false'

KEY_INDEXES = {
    0 : 'up',
    1 : 'down',
    2 : 'left',
    3 : 'right',
    4 : 'button1',
    5 : 'button2',
    6 : 'button3',
    7 : 'button4'
}

class ChangeInputKey(PlayerAction):
    custom = True

    def write_player(self, writer):
        index = int(self.convert_index(0))
        player_key = KEY_INDEXES[index]
        writer.putlnc('manager.%s = %s;', player_key, self.convert_index(1))

# expressions

class ValueExpression(ExpressionWriter):
    def get_string(self):
        return to_c('%r', self.data.loader.value)

class ConstantExpression(ExpressionWriter):
    def get_string(self):
        return self.value

class StringExpression(ExpressionWriter):
    def get_string(self):
        # self.converter.start_clauses -= self.data.loader.value.count('(')
        # self.converter.end_clauses -= self.data.loader.value.count(')')
        return self.converter.intern_string(self.data.loader.value)

class EndParenthesis(ConstantExpression):
    value = ')'

class PlusExpression(ConstantExpression):
    value = '+'

class MinusExpression(ConstantExpression):
    value = '-'

class MultiplyExpression(ConstantExpression):
    value = '*'

class DivideExpression(ConstantExpression):
    value = '/'

    def get_string(self):
        if self.converter.config.use_safe_division():
            return '/MathHelper()/'
        return self.value

class ModulusExpression(ConstantExpression):
    value = '%'

class ParenthesisExpression(ConstantExpression):
    value = '('

class VirguleExpression(ExpressionWriter):
    def get_string(self):
        out = ''
        if self.converter.last_out[-1] == '(':
            out += ')'
        out += ', '
        return out

class AlterableValueExpression(ExpressionWriter):
    def get_string(self):
        if self.converter.config.use_alterable_int(self):
            func = 'alterables->values.get_int'
        else:
            func = 'alterables->values.get'
        return '%s(%s)' % (func, self.data.loader.value)

class AlterableValueIndexExpression(ExpressionWriter):
    def get_string(self):
        if self.converter.config.use_alterable_int(self):
            func = 'alterables->values.get_int'
        else:
            func = 'alterables->values.get'
        return '%s(' % func

class CounterValue(ExpressionWriter):
    def get_string(self):
        if self.converter.config.use_counter_int(self):
            func = 'get_int()'
        else:
            func = 'value'
        return func

class AlterableStringExpression(ExpressionWriter):
    def get_string(self):
        return 'alterables->strings.get(%s)' % self.data.loader.value

class GlobalValueExpression(ExpressionWriter):
    def get_string(self):
        if self.converter.config.use_global_int(self):
            func = 'global_values->get_int'
        else:
            func = 'global_values->get'
        return '%s(%s)' % (func, self.data.loader.value)

class GlobalStringExpression(ExpressionWriter):
    def get_string(self):
        return 'global_strings->get(%s)' % self.data.loader.value

class ObjectCount(ExpressionWriter):
    has_object = False

    def get_string(self):
        obj = (self.data.objectInfo, self.data.objectType)
        try:
            if self.converter.get_object_writer(obj).static:
                return str(1)
        except KeyError:
            pass
        instances = self.converter.get_object_list(obj, allow_single=True)
        return '%s.size()' % instances

class ToString(ExpressionWriter):
    def get_string(self):
        converter = self.converter
        next = converter.expression_items[converter.item_index + 1].getName()
        if next == 'FixedValue':
            return 'std::string('
        return 'number_to_string('

class GetLoopIndex(ExpressionWriter):
    def get_string(self):
        converter = self.converter
        items = converter.expression_items
        last_exp = items[converter.item_index + 2]
        if last_exp.getName() != 'EndParenthesis':
            name = converter.convert_static_expression(items,
                                                       converter.item_index+1)
            if name is None:
                return 'get_loop_index('
            size = len(items) - 1
        else:
            size = 2
            next_exp = items[converter.item_index + 1]
            if next_exp.getName() != 'String':
                name = converter.config.get_dynamic_loop_index(next_exp)
                if name is None:
                    return 'get_loop_index('
            else:
                name = next_exp.loader.value
        converter.item_index += size
        index_name = get_loop_index_name(name)
        return index_name

class SampleExpression(ExpressionWriter):
    def get_string(self):
        converter = self.converter
        items = converter.expression_items
        last_exp = items[converter.item_index + 2]
        if last_exp.getName() != 'EndParenthesis':
            raise NotImplementedError()
        next_exp = items[converter.item_index + 1]
        name = converter.assets.get_sound_id(next_exp.loader.value)
        converter.item_index += 2
        return '%s(%s)' % (self.value, name)

class GetSampleVolume(SampleExpression):
    value = 'media.get_sample_volume'

class GetSamplePosition(SampleExpression):
    value = 'media.get_sample_position'

class GetSampleDuration(SampleExpression):
    value = 'media.get_sample_duration'

class CurrentFrame(ExpressionWriter):
    def get_string(self):
        return '(index+1-%s)' % self.converter.frame_index_offset

class FixedValue(ExpressionMethodWriter):
    use_default = False
    def get_string(self):
        items = self.converter.expression_items
        try:
            next_exp = items[self.converter.item_index + 1]
            if next_exp.getName() == 'Modulus':
                return 'get_fixed().get_uint()'
        except IndexError:
            pass
        return 'get_fixed()'

class ApplicationDrive(ExpressionWriter):
    def get_string(self):
        converter = self.converter
        items = converter.expression_items
        next_exp = items[converter.item_index + 1]
        if next_exp.getName() != 'Plus':
            return 'get_app_dir()'
        next_exp = items[converter.item_index + 2]
        if next_exp.getName() != 'ApplicationDirectory':
            return 'get_app_dir()'
        next_exp = items[converter.item_index + 3]
        if next_exp.getName() != 'Plus':
            return 'get_app_dir()'
        next_exp = items[converter.item_index + 4]
        if next_exp.getName() != 'String':
            converter.item_index += 2
            return 'get_app_path()'
        converter.item_index += 3
        next_exp.loader.value = './' + next_exp.loader.value
        return ''

class ApplicationPath(ExpressionWriter):
    def get_string(self):
        converter = self.converter
        items = converter.expression_items
        next_exp = items[converter.item_index + 1]
        if next_exp.getName() != 'Plus':
            return 'get_app_path()'
        next_exp = items[converter.item_index + 2]
        if next_exp.getName() != 'String':
            return 'get_app_path()'
        converter.item_index += 1
        next_exp.loader.value = './' + next_exp.loader.value
        return ''

actions = make_table(ActionMethodWriter, {
    'CreateObject' : CreateObject,
    'Shoot' : ShootObject,
    'StartLoop' : StartLoop,
    'Foreach' : Foreach,
    'StopLoop' : StopLoop,
    'SwapPosition' : SwapPosition,
    'SetX' : 'set_x',
    'SetY' : 'set_y',
    'SetAlterableValue' : 'alterables->values.set',
    'AddToAlterable' : 'alterables->values.add',
    'SpreadValue' : SpreadValue,
    'SubtractFromAlterable' : 'alterables->values.sub',
    'SetAlterableString' : 'alterables->strings.set',
    'AddCounterValue' : 'add',
    'SubtractCounterValue' : 'subtract',
    'SetCounterValue' : 'set',
    'SetMaximumValue' : 'set_max',
    'SetMinimumValue' : 'set_min',
    'SetGlobalString' : 'global_strings->set',
    'SetGlobalValue' : 'global_values->set',
    'AddGlobalValue' : 'global_values->add',
    'AddGlobalValueInt' : 'global_values->add',
    'SubtractGlobalValue' : 'global_values->sub',
    'SetString' : 'set_string',
    'SetBold' : 'set_bold',
    'Hide' : 'set_visible(false)',
    'Show' : 'set_visible(true)',
    'SetParagraph' : 'set_paragraph(%s-1)',
    'LockChannel' : 'media.lock(%s-1)',
    'UnlockChannel' : 'media.unlock(%s-1)',
    'StopChannel' : 'media.stop_channel(%s-1)',
    'ResumeChannel' : 'media.resume_channel(%s-1)',
    'PauseChannel' : 'media.pause_channel(%s-1)',
    'SetChannelPosition' : 'media.set_channel_position(%s-1, %s)',
    'SetChannelPan' : 'media.set_channel_pan(%s-1, %s)',
    'SetChannelVolume' : 'media.set_channel_volume(%s-1, %s)',
    'PlayLoopingChannelFileSample' : 'media.play(%s, %s-1, %s)',
    'PlayChannelFileSample' : 'media.play(%s, %s-1)',
    'PlayChannelSample' : 'media.play_id(%s, %s-1)',
    'PlayLoopingChannelSample' : 'media.play_id(%s, %s-1, %s)',
    'PlayLoopingSample' : 'media.play_id(%s, -1, %s)',
    'PlaySample' : 'media.play_id(%s, -1, 1)',
    'SetChannelFrequency' : 'media.set_channel_frequency(%s-1, %s) ',
    'SetDirection' : 'set_direction',
    'SetRGBCoefficient' : 'set_blend_color',
    'SetAngle' : 'set_angle',
    'DeactivateGroup' : DeactivateGroup,
    'ActivateGroup' : ActivateGroup,
    'CenterDisplayX' : CenterDisplayX,
    'CenterDisplayY' : CenterDisplayY,
    'CenterDisplay' : CenterDisplay,
    'EndApplication' : EndApplication,
    'RestartApplication' : 'restart',
    'LookAt' : LookAt,
    'SetPosition' : SetPosition,
    'ExecuteEvaluatedProgram' : 'open_process',
    'HideCursor' : 'set_cursor_visible(false)',
    'ShowCursor' : 'set_cursor_visible(true)',
    'FullscreenMode' : 'set_fullscreen(true)',
    'NextFrame' : NextFrame,
    'PreviousFrame' : PreviousFrame,
    'MoveToLayer' : 'set_layer(%s-1)',
    'JumpToFrame' : JumpToFrame,
    'RestartFrame' : RestartFrame,
    'SetAlphaCoefficient' : 'blend_color.set_alpha_coefficient(%s)',
    'SetSemiTransparency' : SetSemiTransparency,
    'SetXScale' : 'set_x_scale({0})',
    'SetYScale' : 'set_y_scale({0})',
    'SetScale' : 'set_scale({0})',
    'ForceAnimation' : 'force_animation',
    'RestoreAnimation' : 'restore_animation',
    'ForceFrame' : 'force_frame',
    'ForceSpeed' : 'force_speed',
    'RestoreFrame' : 'restore_frame',
    'SetInkEffect' : SetInkEffect,
    'SetEffect' : SetEffect,
    'AddToDebugger' : EmptyAction,
    'SetFrameRate' : 'manager.set_framerate(%s)',
    'Destroy' : Destroy,
    'BringToBack' : 'move_back',
    'BringToFront' : 'move_front',
    'DeleteAllCreatedBackdrops' : 'layers[%s-1].destroy_backgrounds()',
    'DeleteCreatedBackdrops' : 'layers[%s-1].destroy_backgrounds(%s, %s, %s)',
    'SetEffectParameter' : 'set_shader_parameter',
    'SetEffectImage' : 'set_shader_parameter',
    'SetFrameBackgroundColor' : 'set_background_color',
    'AddBackdrop' : 'paste',
    'PasteActive' : 'paste',
    'MoveInFront' : MoveInFront,
    'MoveBehind' : MoveBehind,
    'ForceDirection' : 'force_direction',
    'RestoreDirection' : 'restore_direction',
    'StopAnimation' : 'stop_animation',
    'StartAnimation' : 'start_animation',
    'RestoreSpeed' : 'restore_speed',
    'SetMainVolume' : 'media.set_main_volume',
    'StopAllSamples' : 'media.stop_samples',
    'PauseAllSounds' : 'media.pause_samples',
    'ResumeAllSounds' : 'media.resume_samples',
    'StopSample' : 'media.stop_sample(%s)',
    'SetSamplePan' : 'media.set_sample_pan(%s, %s)',
    'SetSamplePosition' : 'media.set_sample_position(%s, %s)',
    'SetSampleVolume' : 'media.set_sample_volume(%s, %s)',
    'SetSampleFrequency' : 'media.set_sample_frequency(%s, %s)',
    'NextParagraph' : 'next_paragraph',
    'PauseApplication' : 'pause',
    'SetRandomSeed' : 'set_random_seed',
    'SetTimer' : 'set_timer((%s) / 1000.0)',
    'SetLoopIndex' : SetLoopIndex,
    'IgnoreControls' : IgnoreControls,
    'RestoreControls' : RestoreControls,
    'ChangeControlType' : '.manager.control_type = %s', # XXX fix,
    'FlashDuring' : 'flash((%s) / 1000.0)',
    'SetMaximumSpeed' : 'get_movement()->set_max_speed',
    'SetSpeed' : 'get_movement()->set_speed',
    'SetDeceleration' : 'get_movement()->set_deceleration',
    'Bounce' : BounceAction,
    'Start' : 'get_movement()->start()',
    'Stop': StopAction,
    'SetDirections' : 'get_movement()->set_directions',
    'GoToNode' : 'get_movement()->set_node',
    'SelectMovement' : 'set_movement(%s)',
    'NextMovement' : 'advance_movement(+1)',
    'PreviousMovement' : 'advance_movement(-1)',
    'EnableFlag' : 'alterables->flags.enable',
    'DisableFlag' : 'alterables->flags.disable',
    'ToggleFlag' : 'alterables->flags.toggle',
    'Reverse' : 'get_movement()->reverse()',
    'ReplaceColor' : 'replace_color',
    'SetLives' : 'set_lives',
    'SetScore' : 'set_score',
    'AddScore' : 'set_score(manager.score + (%s))',
    'SubtractLives' : 'set_lives(manager.lives - (%s))',
    'AddLives' : 'set_lives(manager.lives + (%s))',
    'EnableVsync' : 'set_vsync(true)',
    'DisableVsync' : 'set_vsync(false)',
    'SetGravity' : 'get_movement()->set_gravity',
    'LoadActiveFrame' : 'load',
    'SetClipboard' : EmptyAction,
    'SetFrameEffect' : EmptyAction, # XXX fix
    'SetFrameEffectParameter' : EmptyAction, # XXX fix
    'SetFrameAlphaCoefficient' : EmptyAction, # XXX fix
    'PauseDebugger' : EmptyAction, # don't implement
    'JumpSubApplicationFrame' : 'set_next_frame',
    'SetTextColor' : 'blend_color.set(%s)',
    'SetFrameWidth' : 'set_width(%s, true)',
    'SetFrameHeight' : 'set_height(%s, true)',
    # ignore extract/release file actions, we just load directly when using the
    # temporary dir
    'ExtractBinaryFile' : EmptyAction,
    'ReleaseBinaryFile' : EmptyAction,
    'Wrap' : 'wrap_pos',
    'ChangeInputKey' : ChangeInputKey
})

conditions = make_table(ConditionMethodWriter, {
    'CompareAlterableValue' : make_comparison('alterables->values.get(%s)'),
    'CompareAlterableValueInt' : make_comparison('alterables->values.get(%s)'),
    'CompareAlterableString' : make_comparison('alterables->strings.get(%s)'),
    'CompareGlobalValue' : make_comparison('global_values->get(%s)'),
    'CompareGlobalValueIntEqual' : make_comparison('global_values->get(%s)'),
    'CompareGlobalValueIntNotEqual' : make_comparison('global_values->get(%s)'),
    'CompareGlobalString' : make_comparison('global_strings->get(%s)'),
    'CompareCounter' : make_comparison('value'),
    'CompareX' : make_comparison('get_x()'),
    'CompareY' : make_comparison('get_y()'),
    'Compare' : make_comparison('%s'),
    'IsOverlapping' : IsOverlapping,
    'OnCollision' : OnCollision,
    'ObjectVisible' : '.flags & VISIBLE',
    'ObjectInvisible' : ObjectInvisible,
    'WhileMousePressed' : 'is_mouse_pressed',
    'MouseOnObject' : MouseOnObject,
    'Always' : Always,
    'MouseClicked' : MouseClicked,
    'ObjectClicked' : ObjectClicked,
    'PlayerKeyDown' : PlayerKeyDown,
    'PlayerKeyPressed' : PlayerKeyPressed,
    'KeyDown' : 'is_key_pressed',
    'KeyPressed' : 'is_key_pressed_once(%s)',
    'OnGroupActivation' : OnGroupActivation,
    'FacingInDirection' : FacingInDirection,
    'AnimationPlaying' : 'test_animation',
    'Chance' : 'random_chance',
    'CompareFixedValue' : CompareFixedValue,
    'InsidePlayfield' : InsidePlayfield,
    'OutsidePlayfield' : OutsidePlayfield,
    'IsObstacle' : 'test_obstacle',
    'IsLadder' : 'test_ladder',
    'IsOverlappingBackground' : 'overlaps_background',
    'OnBackgroundCollision' : OnBackgroundCollision,
    'PickRandom' : PickRandom,
    'ObjectsInZone' : CompareObjectsInZone,
    'NoObjectsInZone' : NoObjectsInZone,
    'PickObjectsInZone' : PickObjectsInZone,
    'PickAlterableValue' : PickAlterableValue,
    'PickFlagOn' : PickFlagOn,
    'PickFromFixed' : PickFromFixed,
    'NumberOfObjects' : NumberOfObjects,
    'GroupActivated' : GroupActivated,
    'NotAlways' : NotAlways,
    'AnimationFrame' : make_comparison('get_frame()'),
    'ChannelNotPlaying' : '!media.is_channel_playing(%s-1)',
    'SampleNotPlaying' : '!media.is_sample_playing(%s)',
    'Once' : OnceCondition,
    'Every' : TimerEvery,
    'TimerEquals' : TimerEquals,
    'TimerGreater' : TimerGreater,
    'TimerLess' : TimerLess,
    'IsBold' : 'get_bold',
    'IsItalic' : 'get_italic',
    'MovementStopped' : 'get_movement()->is_stopped()',
    'PathFinished' : PathFinished,
    'NodeReached' : NodeReached,
    'CompareSpeed' : make_comparison('get_movement()->get_speed()'),
    'FlagOn' : 'alterables->flags.is_on',
    'FlagOff' : 'alterables->flags.is_off',
    'NearWindowBorder' : 'is_near_border',
    'AnimationFinished' : AnimationFinished,
    'StartOfFrame' : '.loop_count <= 1',
    'Never' : '.false',
    'NumberOfLives' :  make_comparison('manager.lives'),
    'PlayerDied' : PlayerDied,
    'AnyKeyPressed' : AnyKeyPressed,
    'Repeat' : RepeatCondition,
    'RestrictFor' : RestrictFor,
    # XXX implement this
    'SubApplicationFinished' : '.done',
    'LeavingPlayfield' : LeavingPlayfield,
    # XXX implement
    'MouseWheelDown' : FalseCondition,
    'MouseWheelUp' : FalseCondition,
    'OnLoop' : FalseCondition, # if not a generated group, this is always false
    'VsyncEnabled' : 'platform_get_vsync',
    'AllDestroyed' : AllDestroyed,
    'MouseInZone' : MouseInZone
})

expressions = make_table(ExpressionMethodWriter, {
    'Speed' : 'get_movement()->get_speed()',
    'String' : StringExpression,
    'ToNumber' : 'string_to_number',
    'ToInt' : 'int',
    'Abs' : 'get_abs',
    'ToString' : ToString,
    'GetRGB' : 'make_color_int',
    'Long' : ValueExpression,
    'Double' : ValueExpression,
    'EndParenthesis' : EndParenthesis,
    'Plus' : PlusExpression,
    'Multiply' : MultiplyExpression,
    'Divide' : DivideExpression,
    'Minus' : MinusExpression,
    'Virgule' : VirguleExpression,
    'Parenthesis' : ParenthesisExpression,
    'Modulus' : '.%MathHelper()%',
    'AND' : '.&MathHelper()&',
    'OR' : '.|MathHelper()|',
    'XOR' : '.^MathHelper()^',
    'Random' : 'randrange_event',
    'ApplicationPath' : ApplicationPath,
    'AlterableValue' : AlterableValueExpression,
    'AlterableValueIndex' : AlterableValueIndexExpression,
    'AlterableStringIndex' : 'alterables->strings.get',
    'AlterableString' : AlterableStringExpression,
    'GlobalString' : GlobalStringExpression,
    'GlobalValue' : GlobalValueExpression,
    'GlobalValueExpression' : '.global_values->get(-1 + ',
    'YPosition' : 'get_y()',
    'XPosition' : 'get_x()',
    'ActionX' : 'get_action_x()',
    'ActionY' : 'get_action_y()',
    'GetParagraph' : 'get_paragraph',
    'ParagraphCount' : 'get_count()',
    'CurrentParagraphIndex' : 'get_index()+1',
    'LoopIndex' : GetLoopIndex,
    'CurrentText' : '.text',
    'XMouse' : 'get_mouse_x()',
    'YMouse' : 'get_mouse_y()',
    'Min' : 'get_min',
    'Max' : 'get_max',
    'Sin' : 'sin_deg',
    'Cos' : 'cos_deg',
    'Exp' : 'get_exp',
    'Ln' : 'get_ln',
    'Log' : 'get_log10',
    'GetAngle' : 'get_angle()',
    'FrameHeight' : '.height',
    'FrameWidth' : '.width',
    'GetVirtualWidth' : '.virtual_width',
    'StringLength' : 'string_size',
    'Find' : 'string_find',
    'ReverseFind' : 'string_rfind',
    'LowerString' : 'lowercase_string',
    'UpperString' : 'uppercase_string',
    'RightString' : 'right_string',
    'MidString' : 'mid_string',
    'LeftString' : 'left_string',
    'FixedValue' : FixedValue,
    'AnimationFrame' : 'get_frame()',
    'ObjectLeft' : 'get_box_index(0)',
    'ObjectRight' : 'get_box_index(2)',
    'ObjectTop' : 'get_box_index(1)',
    'ObjectBottom' : 'get_box_index(3)',
    'GetWidth' : 'get_generic_width()',
    'GetHeight' : 'get_generic_height()',
    'GetDirection' : 'get_direction()',
    'GetXScale' : '.x_scale',
    'GetYScale' : '.y_scale',
    'Power' : '.*MathHelper()*',
    'SquareRoot' : 'sqrt',
    'Asin' : 'asin_deg',
    'Atan2' : 'atan2_deg',
    'Atan' : 'atan_deg',
    'AngleBetween' : 'get_angle_int',
    'DistanceBetween' : 'get_distance_int',
    'AlphaCoefficient' : 'blend_color.get_alpha_coefficient()',
    'SemiTransparency' : 'blend_color.get_semi_transparency()',
    'EffectParameter' : 'get_shader_parameter',
    'Floor' : 'get_floor',
    'Round' : 'int_round',
    'AnimationNumber' : '.current_animation',
    'Ceil' : 'get_ceil',
    'GetMainVolume' : 'media.get_main_volume()',
    'GetChannelPosition' : '.media.get_channel_position(-1 +',
    'GetSampleVolume' : GetSampleVolume,
    'GetSamplePosition' : GetSamplePosition,
    'GetSampleDuration' : GetSampleDuration,
    'GetChannelVolume' : '.media.get_channel_volume(-1 +',
    'GetChannelDuration' : '.media.get_channel_duration(-1 + ',
    'GetChannelFrequency' : '.media.get_channel_frequency(-1 + ',
    'GetChannelPan' : '.media.get_channel_pan(-1 + ',
    'ObjectLayer' : '.layer->index+1',
    'NewLine' : '.newline_character',
    'XLeftFrame' : 'frame_left()',
    'XRightFrame' : 'frame_right()',
    'YBottomFrame' : 'frame_bottom()',
    'YTopFrame' : 'frame_top()',
    'ObjectCount' : ObjectCount,
    'CounterMaximumValue' : '.maximum',
    'ApplicationDirectory' : 'get_app_dir()',
    'ApplicationDrive' : ApplicationDrive,
    'TimerValue' : '.(frame_time * 1000.0)',
    'TimerHundreds' : '.(int(frame_time * 100) % 100)',
    'CounterValue': CounterValue,
    'CurrentFrame' : CurrentFrame,
    'GetFlag' : 'alterables->flags.get',
    'GetCommandItem' : 'get_command_arg',
    # 1 (standard), 2 (DirectDraw), 4 (Direct3D8) 8 (Direct3D9)
    'DisplayMode' : '.8',
    'GetClipboard' : '.empty_string',
    'TotalObjectCount' : 'get_instance_count()',
    'FrameRate' : '.manager.fps_limit.framerate',
    'TemporaryPath' : 'get_temp_path()',
    'GetCollisionMask' : 'get_background_mask',
    'FontColor' : 'blend_color.get_int()',
    'FontName' : 'get_font_name',
    'RGBCoefficient' : 'blend_color.get_int()',
    'MovementNumber' : 'get_movement()->index',
    'FrameBackgroundColor' : 'background_color.get_int()',
    'PlayerLives' : '.manager.lives',
    'PlayerScore' : '.manager.score',
    'TemporaryBinaryFilePath' : 'create_temp_file'
})
