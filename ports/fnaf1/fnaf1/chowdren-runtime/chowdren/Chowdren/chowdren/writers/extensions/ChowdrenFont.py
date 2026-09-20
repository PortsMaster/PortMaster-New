from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (StaticConditionWriter,
    StaticActionWriter, StaticExpressionWriter, make_table, ExpressionWriter)

import base64

class FontInfoObject(ObjectWriter):
    class_name = 'FontInfo'
    static = True

    def write_init(self, writer):
        pass

class Base64Decode(ExpressionWriter):
    def get_string(self):
        converter = self.converter
        items = converter.expression_items
        next_exp = items[converter.item_index + 1]
        value = base64.b64decode(next_exp.loader.value)
        converter.item_index += 2
        value = self.converter.intern_string(value)
        return value

actions = make_table(StaticActionWriter, {
    0 : 'set_width',
    1 : 'set_scale'
})

conditions = make_table(StaticConditionWriter, {
})

expressions = make_table(StaticExpressionWriter, {
    0 : 'get_width',
    1 : 'get_height',
    2 : '.vertical_tab',
    3 : Base64Decode
})

def get_object():
    return FontInfoObject