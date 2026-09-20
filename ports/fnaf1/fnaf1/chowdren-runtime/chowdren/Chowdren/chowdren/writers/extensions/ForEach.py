from chowdren.writers.objects import ObjectWriter

from chowdren.common import (get_animation_name, to_c, make_color,
                             get_method_name)

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, ExpressionMethodWriter, make_table,
    ActionWriter, make_comparison)

from collections import defaultdict

LOOP_FOR_OBJECT = 4
ON_LOOP = 0

class StartForObject(ActionWriter):
    custom = True
    def write(self, writer):
        self.reorder = self.converter.config.reorder_foreach()
        if self.reorder:
            return
        self.write_foreach(writer)

    def write_foreach(self, writer):
        writer.start_brace()
        eval_name = self.convert_index(0)

        obj_param = self.parameters[1].loader
        obj = (obj_param.objectInfo, obj_param.objectType)
        obj = self.converter.filter_object_type(obj)
        object_class = self.converter.get_object_class(obj[1])
        foreach = self.converter.get_object_writer(self.get_object())
        loop_names = foreach.loop_names
        name = None
        try:
            exp, = self.parameters[0].loader.items[:-1]
            real_name = exp.loader.value
            if real_name not in loop_names:
                print 'invalid foreach loop:', real_name, loop_names
                writer.end_brace()
                return
            name = get_method_name(real_name)
            func_call = loop_names[real_name]
        except ValueError:
            raise NotImplementedError()
            writer.putln('std::string name = %s;' % eval_name)
            func_call = 'call_dynamic_foreach(name, '
            object_class = 'FrameObject*'
        obj_param = self.parameters[1].loader
        obj = (obj_param.objectInfo, obj_param.objectType)
        with self.converter.iterate_object(obj, writer, 'selected'):
            if name is not None:
                selected = self.converter.get_object(obj)
                writer.putlnc('foreach_instance_%s = %s;', name, selected)
            writer.putlnc('%s();', func_call)
        writer.end_brace()

    def write_post(self, writer):
        if not self.reorder:
            return
        self.write_foreach(writer)

# PROFILE_FUNCTIONS = set(['sensor_engines_arms'])
PROFILE_FUNCTIONS = set([])

class ForEach(ObjectWriter):
    class_name = 'ForEach'
    static = True

    def write_frame(self, writer):
        loops = defaultdict(list)
        loop_objects = {}
        for loop in self.get_conditions(LOOP_FOR_OBJECT, ON_LOOP):
            parameters = loop.conditions[0].data.items
            exp, = parameters[0].loader.items[:-1]
            real_name = exp.loader.value
            try:
                object_info = parameters[1].loader.objectInfo
                object_type = parameters[1].loader.objectType
                obj = (object_info, object_type)
                obj = self.converter.filter_object_type(obj)
                loop_objects[real_name] = obj
            except IndexError:
                # for ON_LOOP
                pass
            loops[real_name].append(loop)

        self.loop_names = {}

        self.converter.begin_events()
        for real_name, groups in loops.iteritems():
            obj = loop_objects[real_name]
            name = get_method_name(real_name)
            instance_name = 'foreach_instance_' + name
            writer.add_member('FrameObject * %s' % instance_name)
            name = 'foreach_%s_%s' % (name, self.converter.current_frame_index)
            object_class = self.converter.get_object_class(obj[1])
            self.converter.set_object(obj, '((%s)%s)' % (object_class,
                                                         instance_name))
            name = self.converter.write_generated(name, writer, groups)
            self.loop_names[real_name] = name

class GetForeachFixed(ExpressionMethodWriter):
    def get_string(self):
        converter = self.converter
        name = converter.expression_items[converter.item_index+1].loader.value
        foreach_instance = 'foreach_instance_' + get_method_name(name)
        fixed = foreach_instance + '->get_fixed()'
        converter.item_index += 2
        return fixed

actions = make_table(StaticActionWriter, {
    0 : StartForObject
})

conditions = make_table(StaticConditionWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    0 : GetForeachFixed
})

def get_object():
    return ForEach