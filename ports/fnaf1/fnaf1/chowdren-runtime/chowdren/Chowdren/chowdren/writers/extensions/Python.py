from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table,
    make_static_expression)
from collections import defaultdict

ON_FUNCTION = 2

class Python(ObjectWriter):
    class_name = 'PythonInterpreter'
    filename = 'pythonext'

    def write_frame(self, writer):
        writer.add_member('PyObject * python_args')
        writer.add_member('PyObject * python_returns')
        functions = defaultdict(list)
        arguments = {}
        for func in self.get_conditions(ON_FUNCTION):
            parameters = func.conditions[0].data.items
            exp1, = parameters[0].loader.items[:-1]
            name = exp1.loader.value
            exp2, = parameters[1].loader.items[:-1]
            arg_count = exp2.loader.value
            if arguments.get(name, arg_count) != arg_count:
                raise NotImplementedError
            arguments[name] = arg_count
            functions[name].append(func)

        frame_class = self.converter.frame_class
        for name, groups in functions.iteritems():
            writer.putmeth('static PyObject * _python_%s' % name,
                'PyObject * self', 'PyObject * args')
            writer.putln(('return ((%s*)manager.frame)->python_%s('
                          'self, args);') % (frame_class, name))
            writer.end_brace()

            writer.putmeth('PyObject * python_%s' % name,
                'PyObject * self', 'PyObject * args')
            writer.putln('python_args = args;')
            writer.putln('python_returns = PythonInterpreter::get_none();')
            self.converter.begin_events()
            # self.converter.write_container_check(groups[0], writer)
            for group in groups:
                self.converter.write_event(writer, group, True)
            writer.putln('return python_returns;')
            writer.end_brace()

        self.function_names = functions.keys()

    def write_start(self, writer):
        writer.putln('static bool python_initialized = false;')
        writer.putln('if (!python_initialized) {')
        writer.indent()
        writer.putln('python_initialized = true;')
        for name in self.function_names:
            writer.putlnc('%s::add_function(%r, (void*)_python_%s);',
                          self.class_name, name, name, cpp=False)
        writer.end_brace()

class GetArgumentPointer(ExpressionMethodWriter):
    has_object = False
    def get_string(self):
        return 'GET_PYTHON_ARG('

class AddReturn(ActionMethodWriter):
    has_object = False
    method = 'python_returns = PythonInterpreter::to_object(%s)'

class CallGlobal(ActionMethodWriter):
    method = 'call_global'

actions = make_table(ActionMethodWriter, {
    0 : 'run_string({0})',
    3 : AddReturn,
    5 : 'add_parameter',
    8 : CallGlobal
})

conditions = make_table(ConditionMethodWriter, {
})

create_object_expression = make_static_expression('create_object')

expressions = make_table(ExpressionMethodWriter, {
    2 : 'create_object',
    12 : 'create_object',
    13 : create_object_expression,
    15 : 'list_append',
    8 : 'as_string',
    6 : GetArgumentPointer,
    14 : 'create_list',
    0 : 'eval',
    10 : 'as_number'
})

def get_object():
    return Python