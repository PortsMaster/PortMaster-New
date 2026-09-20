from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, StaticExpressionWriter, make_table, EmptyAction,
    ExpressionMethodWriter)

ON_LOOP = 7
ON_LOOP_FINISH = 8

class FolderObject(ObjectWriter):
    class_name = 'File'
    static = True

    def write_frame(self, writer):
        groups = self.get_conditions(ON_LOOP)
        name = 'folder_search_loop_%s' % self.converter.current_frame_index
        name = self.converter.write_generated(name, writer, groups)
        self.on_loop = name

        add_members = len(groups) > 0

        groups = self.get_conditions(ON_LOOP_FINISH)
        name = 'folder_search_finish_%s' % self.converter.current_frame_index
        name = self.converter.write_generated(name, writer, groups)
        self.on_loop_finish = name

        if len(groups) or add_members:
            writer.add_member('int folder_search_id')
            writer.add_member('std::string folder_search_name')

class StartWalk(StaticActionWriter):
    custom = True

    def write(self, writer):
        obj = (self.data.objectInfo, self.data.objectType)
        folder_obj = self.converter.get_object_writer(obj)

        path = self.convert_index(0)
        search_id = self.convert_index(1)
        writer.putlnc('folder_search_id = %s;', search_id)
        writer.start_brace()
        writer.putlnc('vector<FilesystemItem> items;')
        writer.putlnc('platform_walk_folder(%s, items);', path)
        writer.putlnc('vector<FilesystemItem>::iterator it;')
        writer.putlnc('for (it = items.begin(); it != items.end(); ++it) {')
        writer.indent()
        writer.putlnc('if (it->is_folder()) continue;')
        writer.putlnc('folder_search_name = join_path(%s, it->name);',
                      path)
        writer.putlnc('%s();', folder_obj.on_loop)
        writer.end_brace()

        writer.putlnc('%s();', folder_obj.on_loop_finish)

        writer.end_brace()

actions = make_table(StaticActionWriter, {
    1 : 'delete_folder',
    8 : StartWalk,
    15 : 'create_directory'
})

conditions = make_table(StaticConditionWriter, {
    15 : 'file_exists'
})

expressions = make_table(ExpressionMethodWriter, {
    3 : '.folder_search_name',
    6 : '.folder_search_id'
})

def get_object():
    return FolderObject
