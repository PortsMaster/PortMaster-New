from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table, EmptyAction)
import collections

class AssociateArray(ObjectWriter):
    key_count = 0
    class_name = 'AssociateArray'
    filename = 'assarray'
    default_instance = 'default_assarray_instance'

    def write_init(self, writer):
        data = self.get_data()
        data.skipBytes(4)
        data.skipBytes(4) # width, height
        is_global = data.readByte() != 0
        self.write_assarray(writer, is_global)

    def write_assarray(self, writer, is_global):
        if is_global:
            writer.putln('map = &global_map;')
        else:
            writer.putln('map = new ArrayMap();')

    @staticmethod
    def write_application(converter):
        converter.add_define('CHOWDREN_ASSARRAY_STORE',
                             max(1, AssociateArray.key_count))

objects = collections.defaultdict(dict)

def create_key_action(value):
    class NewAction(ActionMethodWriter):
        method = value
        def write(self, writer):
            items = self.parameters[0].loader.items
            key = self.converter.convert_static_expression(items)
            if key is None:
                ActionMethodWriter.write(self, writer)
                return
            keys = objects[self.get_object()]
            index = keys.get(key, None)
            if index is None:
                index = len(keys)
                keys[key] = index
                AssociateArray.key_count = max(len(keys),
                                               AssociateArray.key_count)
            self.method = '%s(%s, %%s, %%s)' % (value, index)
            ActionMethodWriter.write(self, writer)
    return NewAction

actions = make_table(ActionMethodWriter, {
    0 : create_key_action('set_value'),
    1 : create_key_action('set_string'),
    2 : 'remove_key',
    3 : 'clear',
    8 : 'save',
    42 : 'save_encrypted',
    43 : 'load_encrypted',
    44 : 'set_key',
    25 : EmptyAction, # set_file_saving_interval
    24 : EmptyAction, # set_file_loading_interval
    26 : EmptyAction, # file_progress_set_to_load_entire_file_all_at_once
    28 : create_key_action('add_value'),
    29 : create_key_action('sub_value')
})

def create_key_condition(value):
    class NewCondition(ConditionMethodWriter):
        method = value
        def write(self, writer):
            items = self.parameters[0].loader.items
            key = self.converter.convert_static_expression(items)
            if key is None:
                ConditionMethodWriter.write(self, writer)
                return
            keys = objects[self.get_object()]
            index = keys.get(key, None)
            if index is None:
                index = len(keys)
                keys[key] = index
                AssociateArray.key_count = max(len(keys),
                                               AssociateArray.key_count)
            self.method = '%s(%s, %%s)' % (value, index)
            ConditionMethodWriter.write(self, writer)
    return NewCondition

conditions = make_table(ConditionMethodWriter, {
    0 : create_key_condition('has_key'),
    4 : 'count_prefix'
})

def create_key_expression(value):
    class NewExpression(ExpressionMethodWriter):
        method = value
        def get_string(self):
            converter = self.converter
            items = converter.expression_items
            str_exp = items[converter.item_index + 1]
            last_exp = items[converter.item_index + 2]
            if (last_exp.getName() != 'EndParenthesis' or
                    str_exp.getName() != 'String'):
                return ExpressionMethodWriter.get_string(self)
            key = str_exp.loader.value
            keys = objects[self.get_object()]
            index = keys.get(key, None)
            if index is None:
                index = len(keys)
                keys[key] = index
                AssociateArray.key_count = max(len(keys),
                                               AssociateArray.key_count)
            self.method = '.%s(%s, ' % (value, index)
            return ExpressionMethodWriter.get_string(self)
    return NewExpression

expressions = make_table(ExpressionMethodWriter, {
    0 : create_key_expression('get_value'),
    1 : create_key_expression('get_string'),
    10 : 'get_key',
    13 : 'get_first',
    15 : 'count_prefix',
    18 : 'get_prefix'
})

def get_object():
    return AssociateArray
