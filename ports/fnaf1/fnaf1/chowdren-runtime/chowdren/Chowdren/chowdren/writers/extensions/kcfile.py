from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, StaticExpressionWriter, make_table, EmptyAction)

class File(ObjectWriter):
    class_name = 'File'
    static = True

    def write_init(self, writer):
        pass

actions = make_table(StaticActionWriter, {
    0 : 'change_directory',
    2 : 'create_directory',
    5 : 'delete_file',
    6 : 'rename_file',
    8 : 'copy_file',
    10 : 'append_text',
    11 : EmptyAction
})

conditions = make_table(StaticConditionWriter, {
    1 : 'name_exists',
    2 : 'file_readable',
    4 : 'file_exists',
    5 : 'directory_exists'
})

expressions = make_table(StaticExpressionWriter, {
    0 : 'get_size',
    7 : 'get_ext',
    6 : 'get_title',
    27 : 'get_appdata_directory()', # directories_my_documents_directory
    28 : 'get_appdata_directory()'
})

def get_object():
    return File
