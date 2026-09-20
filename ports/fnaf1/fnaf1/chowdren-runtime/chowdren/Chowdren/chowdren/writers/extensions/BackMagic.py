from chowdren.writers.objects import ObjectWriter

from chowdren.common import (get_animation_name, to_c, make_color,
                             get_method_name)

from chowdren.writers.events import (ActionMethodWriter, ConditionMethodWriter,
    ExpressionMethodWriter, make_table, ActionWriter)

ON_BACKDROP = 1

class BackMagic(ObjectWriter):
    class_name = 'BackMagic'
    static = True
    in_loop = False
    defines = ['CHOWDREN_USE_BACKMAGIC']

    def write_frame(self, writer):
        groups = []
        for group in self.get_conditions(ON_BACKDROP):
            groups.append(group)
        name = 'backdrop_%s' % self.converter.current_frame_index
        self.in_loop = True
        name = self.converter.write_generated(name, writer, groups)
        self.in_loop = False
        self.loop_name = name

    def get_list_name(self, name):
        name_id = self.converter.back_ids.get(name.lower(), None)
        if name_id is None:
            name_id = 'BACK_ID_' + get_method_name(name).upper()
            next_id = len(self.converter.back_ids)
            self.converter.back_ids[name] = name_id
            self.converter.add_define(name_id, next_id)
        list_name = 'back_instances[%s]' % name_id
        return list_name

class BackAction(ActionMethodWriter):
    custom = True

    def write(self, writer):
        name = self.converter.convert_static_expression(
            self.parameters[0].loader.items)
        magic = self.converter.get_object_writer(self.get_object())
        list_name = magic.get_list_name(name)
        self.write_action(writer, list_name)

class IterateAction(BackAction):
    def write_action(self, writer, list_name):
        magic = self.converter.get_object_writer(self.get_object())
        writer.start_brace()
        writer.putlnc('FlatObjectList::iterator it;')
        writer.putlnc('for (it = %s.begin(); it != %s.end(); ++it) {',
                      list_name, list_name)
        writer.indent()

        writer.putlnc('back_obj = (Backdrop*)*it;')
        writer.putlnc('%s();', magic.loop_name)

        writer.end_brace()

        writer.end_brace()

class FloatAction(BackAction):
    def write_action(self, writer, list_name):
        writer.start_brace()
        name = self.convert_index(1)
        writer.putlnc('float effect_param = %s;', self.convert_index(2))
        writer.putlnc('FlatObjectList::iterator it;')
        writer.putlnc('for (it = %s.begin(); it != %s.end(); ++it) {',
                      list_name, list_name)
        writer.indent()

        writer.putlnc('(*it)->set_shader_parameter(%s, effect_param);', name)

        writer.end_brace()

        writer.end_brace()

class BackLoopAction(ActionMethodWriter):
    custom = True

    def write(self, writer):
        magic = self.converter.get_object_writer(self.get_object())
        if not magic.in_loop:
            return
        writer.putlnc('back_obj->%s(%s);', self.method, self.convert_index(0))

class SetX(BackLoopAction):
    method = 'set_x'

class SetY(BackLoopAction):
    method = 'set_y'

actions = make_table(BackAction, {
    0 : FloatAction,
    3 : IterateAction,
    4 : SetX,
    5 : SetY
})

conditions = make_table(ConditionMethodWriter, {
})

class BackExpression(ExpressionMethodWriter):
    def get_string(self):
        converter = self.converter
        items = converter.expression_items
        last_exp = items[converter.item_index + 2]
        if last_exp.getName() != 'Virgule':
            raise NotImplementedError()
        next_exp = items[converter.item_index + 1]
        if next_exp.getName() != 'String':
            raise NotImplementedError()
        name = next_exp.loader.value
        converter.item_index += 2
        magic = self.converter.get_object_writer(self.get_object())
        list_name = magic.get_list_name(name)
        return '%s[0]->%s(' % (list_name, self.value)

class BackFloat(BackExpression):
    value = 'get_shader_parameter'

class BackLoopExpression(ExpressionMethodWriter):
    def get_string(self):
        magic = self.converter.get_object_writer(self.get_object())
        if not magic.in_loop:
            return '0'
        return 'back_obj->%s' % self.value

class BackX(BackLoopExpression):
    value = 'get_x()'

class BackY(BackLoopExpression):
    value = 'get_y()'

class OrigX(BackLoopExpression):
    value = 'get_orig_x()'

class OrigY(BackLoopExpression):
    value = 'get_orig_y()'

expressions = make_table(ExpressionMethodWriter, {
    1 : BackFloat,
    2 : BackX,
    3 : BackY,
    5 : OrigX,
    6 : OrigY
})

def get_object():
    return BackMagic
