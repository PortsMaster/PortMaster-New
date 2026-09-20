from chowdren.writers.objects import ObjectWriter
from chowdren.common import get_animation_name, to_c, make_color
from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table, EmptyAction)

class INI(ObjectWriter):
    class_name = 'INI'
    use_alterables = True
    filename = 'ini'
    defines = ['CHOWDREN_USE_INIPP']

    def write_init(self, writer):
        data = self.get_data()
        data.skipBytes(2)
        filename = data.readString()
        data.seek(3269)
        auto_save = data.readByte() == 1
        data.seek(3429)
        is_global = data.readInt() == 1
        data.skipBytes(1)
        global_key = data.readString()
        data.seek(3271)
        use_compression = data.readByte() == 1
        use_encryption = data.readByte() == 1
        key = data.readString()
        if auto_save:
            writer.putln('auto_save = true;')
        writer.putlnc('is_global = %s;', is_global)
        if is_global:
            writer.putlnc('data = &global_data[%r];', global_key)
        else:
            writer.putln('data = new SectionMap();')
        if not is_global and filename:
            writer.putlnc('load_file(%r);', filename)
        if use_compression:
            writer.putlnc('use_compression = true;')
        if use_encryption:
            writer.putlnc('encrypt_key = %r;', key)

class PerformSearch(ActionMethodWriter):
    def write(self, writer):
        writer.put('search(%s, %s, %s);' % (
            self.convert_index(0),
            self.convert_index(1),
            self.convert_index(2)))

class DeletePattern(ActionMethodWriter):
    def write(self, writer):
        writer.put('delete_pattern(%s, %s, %s);' % (
            self.convert_index(0),
            self.convert_index(1),
            self.convert_index(2)))

class MergeObject(ActionMethodWriter):
    def write(self, writer):
        name = self.parameters[0].loader.data.readString()
        handle = self.converter.get_handle_from_name(name)
        overwrite = self.convert_index(1)
        writer.putc('merge_object(%s, %s);',
                    self.converter.get_object(handle),
                    overwrite)

class MergeGroupObject(ActionMethodWriter):
    def write(self, writer):
        name = self.parameters[0].loader.data.readString()
        handle = self.converter.get_handle_from_name(name)
        src_group = self.convert_index(1)
        dst_group = self.convert_index(2)
        overwrite = self.convert_index(3)
        writer.putc('merge_group(%s, %s, %s, %s);',
                     self.converter.get_object(handle), src_group, dst_group,
                     overwrite)

LOAD_FILE = 0
NO_LOAD = 1

CHANGE_PATH = 0
KEEP_PATH = 1
CHANGE_PATH_EXISTS = 2

CLEAR_DATA = 0
KEEP_DATA = 1
CLEAR_DATA_EXISTS = 2

IMMEDIATE_SAVE = 1
READ_ONLY = 2

class FileOperation(ActionMethodWriter):
    def write(self, writer):
        filename = self.convert_index(0)
        reader = self.parameters[1].loader.get_reader()
        load = reader.readByte()
        path = reader.readByte()
        clear = reader.readByte()
        flags = reader.readByte()
        if load != LOAD_FILE:
            raise NotImplementedError()
        if path != KEEP_PATH:
            print 'inipp15: path %s not implemented' % path
            # raise NotImplementedError()
        if clear not in (CLEAR_DATA, KEEP_DATA):
            print 'inipp15: clear %s not implemented' % clear
            # raise NotImplementedError()
        merge = clear == KEEP_DATA
        if flags & IMMEDIATE_SAVE:
            raise NotImplementedError()
        read_only = (flags & READ_ONLY) != 0
        writer.putc('load_file(%s, %s, %s, true);', filename, read_only,
                    merge)

SORT_BY_VALUE = 0
SORT_BY_NAME = 9
SORT_FIRST_PART = 10
SHUFFLE = 1
REMOVE_FIRST = 2
REMOVE_LAST = 4
CYCLE_UP = 3
CYCLE_DOWN = 5
REVERSE = 6
SWAP = 7
RENUMBER = 8

ALPHANUM_SORT = 0
CASE_INSENSITIVE_SORT = 1
CASE_SENSITIVE_SORT = 2

class SortGroup(ActionMethodWriter):
    def write(self, writer):
        reader = self.parameters[0].loader.get_reader()
        option = reader.readByte(True)
        parameter = reader.readByte(True)
        group = self.convert_index(1)
        if option == SORT_BY_NAME and parameter == ALPHANUM_SORT:
            writer.putc('sort_group_by_name(%s);', group)
        elif option == SORT_BY_VALUE and parameter == CASE_INSENSITIVE_SORT:
            writer.putc('sort_group_by_value(%s);', group)
        else:
            print option, parameter
            raise NotImplementedError

class SearchSuccess(ConditionMethodWriter):
    is_always = True
    method = 'has_search_results'


class GetMD5(ExpressionMethodWriter):
    has_object = False
    method = 'get_md5'

class SetValue(ActionMethodWriter):
    def write(self, writer):
        t = self.parameters[-2]
        t = self.converter.convert_static_expression(t.loader.items)
        t = eval(t)
        if t == 0:
            self.method = 'set_value_int'
        elif t == 1:
            self.method = 'set_value'
        else:
            raise NotImplementedError()
        self.parameters.pop(-2)
        ActionMethodWriter.write(self, writer)

actions = make_table(ActionMethodWriter, {
    0 : 'set_group',
    14 : SetValue, # specified group
    15 : 'set_string', # specified group
    1 : SetValue, # current group
    2 : 'set_string', # current group
    28 : 'delete_group',
    9 : 'delete_group',
    10 : 'delete_item',
    29 : 'delete_item',
    43 : 'load_file',
    44 : 'save_file',
    48 : 'load_string',
    49 : 'set_auto',
    52 : 'read_only = bool(%s)',
    32 : 'reset',
    38 : 'merge_file',
    45 : 'save_file',
    31 : DeletePattern,
    33 : PerformSearch,
    40 : MergeObject,
    41 : MergeGroupObject,
    47 : 'close',
    50 : 'set_compression',
    51 : 'set_encryption_key',
    61 : EmptyAction, # open dialog box
    71 : SortGroup,
    78 : FileOperation
})

conditions = make_table(ConditionMethodWriter, {
    1 : 'has_item',
    4 : 'has_item',
    3 : 'has_group',
    13 : SearchSuccess
    # 8 : OnDialogClose
})

expressions = make_table(ExpressionMethodWriter, {
    17 : 'get_item_count',
    7 : 'get_item_count()',
    16 : 'get_group_count()',
    14 : 'get_string_index',
    6 : 'get_string_index',
    1 : 'get_string_default',
    9 : 'get_string_default',
    0 : 'get_value',
    5 : 'get_value_index',
    13 : 'get_item_name',
    4 : 'get_item_name',
    12 : 'get_group_name',
    8 : 'get_value',
    21 : 'get_search_result_item',
    20 : 'get_search_result_group',
    19 : 'get_search_count',
    37 : 'get_item_part',
    25 : 'as_string()',
    26 : GetMD5
})

def get_object():
    return INI