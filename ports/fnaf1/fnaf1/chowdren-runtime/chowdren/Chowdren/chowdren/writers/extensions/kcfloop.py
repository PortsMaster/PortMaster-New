from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, ExpressionMethodWriter, make_table,
    ActionWriter, make_comparison, ExpressionWriter)

from collections import defaultdict

ON_LOOP = 0

def get_loop_func(value, converter):
    return 'fast_loop_%s_%s_func' % (value, converter.current_frame_index)

def get_loop_index(value):
    return 'fast_loop_%s_index' % value

def get_loop_running(value):
    return 'fast_loop_%s_running' % value

class StartLoop(ActionWriter):
    custom = True

    def write(self, writer):
        parameter = self.parameters[0]
        items = parameter.loader.items
        loop_id = self.converter.convert_static_expression(items)
        if loop_id is None:
            raise NotImplementedError()
        obj_writer = self.get_object_writer()
        func = obj_writer.loop_funcs[loop_id]
        index = get_loop_index(loop_id)

        loops = self.convert_index(1)
        comparison = '%s < times' % index

        writer.start_brace()
        writer.putlnc('int times = %s;', loops)
        writer.putlnc('%s = 0;', index)
        writer.putlnc('while (%s) {', comparison)
        writer.indent()
        writer.putlnc('%s();', func)
        writer.putlnc('%s++;', index)
        writer.end_brace()
        writer.end_brace()

        self.converter.clear_selection()

class GetLoopIndex(ExpressionWriter):
    def get_string(self):
        converter = self.converter
        items = converter.expression_items
        last_exp = items[converter.item_index + 2]
        if last_exp.getName() != 'EndParenthesis':
            raise NotImplementedError()
        else:
            size = 2
            next_exp = items[converter.item_index + 1]
            loop_id = next_exp.loader.value

        converter.item_index += size
        index_name = get_loop_index(loop_id)
        return index_name

class FastLoop(ObjectWriter):
    class_name = 'FastLoop'
    static = True

    def write_frame(self, writer):
        self.loop_funcs = {}
        loops = defaultdict(list)
        loop_objects = {}
        for loop in self.get_conditions(ON_LOOP):
            parameter = loop.conditions[0].parameters[0]
            items = parameter.loader.items
            loop_id = self.converter.convert_static_expression(items)
            loops[loop_id].append(loop)

        for loop_id in loops.keys():
            loop_index = get_loop_index(loop_id)
            writer.add_member('int %s' % loop_index)

        self.converter.begin_events()
        for loop_id, groups in loops.iteritems():
            func = get_loop_func(loop_id, self.converter)
            func = self.converter.write_generated(func, writer, groups)
            self.loop_funcs[loop_id] = func

actions = make_table(StaticActionWriter, {
    0 : StartLoop
})

conditions = make_table(StaticConditionWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    0 : GetLoopIndex
})

def get_object():
    return FastLoop
