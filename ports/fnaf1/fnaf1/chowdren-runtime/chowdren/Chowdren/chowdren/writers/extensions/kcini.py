from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

APP_DATA = 4

class INI(ObjectWriter):
    class_name = 'INI'
    filename = 'ini'

    def write_init(self, writer):
        data = self.get_data()
        flags = data.readShort(True)
        filename = data.readString()
        writer.putln('auto_save = true;')
        writer.putln('is_global = false;')
        writer.putln('data = new SectionMap();')
        if filename:
            if flags & APP_DATA:
                filename = to_c('platform_get_appdata_dir() + %r',
                                '/' + filename)
            else:
                filename = to_c('%r', filename)
            writer.putlnc('load_file(%s);', filename)

actions = make_table(ActionMethodWriter, {
    1 : 'set_item',
    7 : 'set_value_int',
    9 : 'set_string',
    10 : 'set_string',
    12 : 'delete_item',
    11 : 'delete_item',
    13 : 'delete_group',
    6 : 'load_file',
    8 : 'set_value_int',
    0 : 'set_group'
    # 14 : 'set_value', # specified group
    # 15 : 'set_string', # specified group
    # 1 : 'set_value', # current group
    # 2 : 'set_string', # current group
    # 28 : 'delete_group',
    # 9 : 'delete_group',
    # 10 : 'delete_item',
    # 29 : 'delete_item',
    # 43 : 'load_file',
    # 48 : 'load_string',
    # 32 : 'reset',
    # 38 : 'merge_file',
    # 45 : 'save_file',
    # 31 : DeletePattern,
    # 33 : PerformSearch,
    # 40 : MergeObject,
    # 41 : MergeGroupObject,
    # 71 : SortGroup
})

conditions = make_table(ConditionMethodWriter, {
    # 1 : 'has_item',
    # 4 : 'has_item',
    # 3 : 'has_group'
})

expressions = make_table(ExpressionMethodWriter, {
    2 : 'get_value_int',
    4 : 'get_string',
    5 : 'get_string',
    3 : 'get_value_int'
    # 17 : 'get_item_count',
    # 7 : 'get_item_count()',
    # 16 : 'get_group_count()',
    # 14 : 'get_string_index',
    # 6 : 'get_string_index',
    # 1 : 'get_string',
    # 9 : 'get_string',
    # 0 : 'get_value',
    # 5 : 'get_value_index',
    # 13 : 'get_item_name',
    # 4 : 'get_item_name',
    # 12 : 'get_group_name',
    # 8 : 'get_value',
    # 20 : 'get_search_result_group',
    # 19 : 'get_search_count',
    # 37 : 'get_item_part',
    # 25 : 'as_string()'
})

def get_object():
    return INI