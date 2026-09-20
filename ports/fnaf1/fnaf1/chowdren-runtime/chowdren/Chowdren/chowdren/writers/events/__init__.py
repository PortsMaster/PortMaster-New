from chowdren.writers import BaseWriter
from collections import defaultdict, Counter
from chowdren.common import COMPARISONS

class EventWriter(BaseWriter):
    static = False
    custom = False
    has_object = True
    container = None
    group = None
    prefix = ''
    ignore_static = False

    def __init__(self, *arg, **kw):
        BaseWriter.__init__(self, *arg, **kw)
        self.convert_parameter = self.converter.convert_parameter

    def convert_index(self, index, *arg, **kw):
        return self.convert_parameter(self.parameters[index], *arg, **kw)

    def get_object(self):
        if not self.data.hasObjectInfo() or self.static or not self.has_object:
            return None, self.data.objectType
        return self.data.objectInfo, self.data.objectType

    def get_object_writer(self, obj=None):
        if obj is None:
            obj = self.get_object()
        return self.converter.get_object_writer(obj)

    def get_id(self, obj):
        return self.group.get_id(obj)

class ACBase(EventWriter):
    def __init__(self, *arg, **kw):
        EventWriter.__init__(self, *arg, **kw)
        self.parameters = self.data.items

    iterate_objects = None

    def get_objects(self):
        return ()

    def write_pre(self, writer):
        for obj in self.get_objects():
            self.converter.create_list(obj, writer)

class ActionWriter(ACBase):
    def write(self, writer):
        raise NotImplementedError()

    def write_post(self, writer):
        pass

class ConditionWriter(ACBase):
    is_always = None
    in_place = False
    pre_event = None
    post_event = None
    precedence = 0

    def write(self, writer):
        raise NotImplementedError()

    def is_negated(self):
        return self.data.otherFlags['Not']

    def get_comparison(self):
        return COMPARISONS[self.parameters[-1].loader.comparison]

class ExpressionWriter(EventWriter):
    use_default = True

    def get_string(self):
        raise NotImplementedError()

# helper writers

class EmptyAction(ActionWriter):
    has_object = False

    def write(self, writer):
        pass

class TrueCondition(ConditionWriter):
    has_object = False

    def write(self, writer):
        writer.put('true')

class FalseCondition(ConditionWriter):
    has_object = False

    def write(self, writer):
        writer.put('false')

class ComparisonWriter(ConditionWriter):
    prefix = '('

    def write(self, writer):
        comparison = self.get_comparison()
        parameters = [str(self.convert_parameter(parameter))
            for parameter in self.get_parameters()]
        value = self.get_comparison_value()
        if len(parameters) == 1:
            value1 = value
            value2, = parameters
        elif len(parameters) == 2:
            value1 = value % parameters[0]
            value2 = parameters[1]
        else:
            raise NotImplementedError
        writer.put('%s) %s (%s)' % (value1, comparison, value2))

    def get_parameters(self):
        return self.parameters

    def get_comparison_value(self):
        return self.value

# debug writers

def print_parameters(ace):
    print [parameter.getName() for parameter in ace.items]

def write_default(self, name, type, writer):
    if name not in self.checked:
        print ('%s %r not implemented' % (type, name)),
        print_parameters(self.data)
    self.checked[name] += 1
    debug_parameters = [str(self.convert_parameter(parameter))
        for parameter in self.parameters]
    debug_name = '%s(%s)' % (name, ', '.join(debug_parameters))
    if type == 'action':
        debug_name += ';'
    writer.put(debug_name)

class DefaultAction(ActionWriter):
    checked = Counter()
    def write(self, writer):
        name = self.converter.get_action_name(self.data)
        write_default(self, name, 'action', writer)

class DefaultCondition(ConditionWriter):
    checked = Counter()
    def write(self, writer):
        name = self.converter.get_condition_name(self.data)
        write_default(self, name, 'condition', writer)

class DefaultExpression(ExpressionWriter):
    checked = Counter()
    def get_string(self):
        name = self.converter.get_expression_name(self.data)
        if name not in self.checked:
            print 'expression not implemented:', name, self.data.loader
        self.checked[name] += 1
        return '%s(' % name

# method writers

def get_method_out(writer):
    parameters = tuple([str(writer.convert_parameter(item))
        for item in writer.parameters])
    meth = writer.method

    if meth.count('%s'):
        if meth.startswith('.'):
            meth = meth[1:]
        return meth % parameters
    elif meth.count('{'):
        return meth.format(*parameters)
    elif not parameters and meth.endswith(')'):
        out = '%s' % meth
    elif not parameters and meth.startswith('.'):
        out = meth[1:]
    else:
        out = '%s(%s)' % (meth, ', '.join(parameters))
    return out

class ActionMethodWriter(ActionWriter):
    def write(self, writer):
        try:
            writer.put(get_method_out(self) + ';')
        except TypeError, e:
            print 'meth:', self.method
            raise e

class ConditionMethodWriter(ConditionWriter):
    def write(self, writer):
        writer.put(get_method_out(self))

class ExpressionMethodWriter(ExpressionWriter):
    def get_string(self):
        if self.method.startswith('.'):
            return self.method[1:]
        elif self.method.count(')'):
            return self.method
        return '%s(' % self.method

class StaticActionWriter(ActionMethodWriter):
    static = True

class StaticConditionWriter(ConditionMethodWriter):
    static = True

class StaticExpressionWriter(ExpressionMethodWriter):
    static = True

def make_expression(value):
    class NewExpression(ExpressionWriter):
        def get_string(self):
            return value
    return NewExpression

def make_static_expression(v):
    class NewExpression(StaticExpressionWriter):
        method = v
    return NewExpression

def make_comparison(v):
    class NewCondition(ComparisonWriter):
        value = v
    return NewCondition

def make_table(method_writer, table):
    new_table = {}
    for k, v in table.iteritems():
        if isinstance(v, str):
            class NewWriter(method_writer):
                method = v
            v = NewWriter
        new_table[k] = v
    return new_table

default_writers = {
    'actions' : DefaultAction,
    'conditions' : DefaultCondition,
    'expressions' : DefaultExpression
}
