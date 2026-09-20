from chowdren.writers.objects import ObjectWriter
from mmfparser.bitdict import BitDict

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ComparisonWriter, ActionMethodWriter,
    ConditionMethodWriter, ExpressionMethodWriter, make_table)

class KcArray(ObjectWriter):
    class_name = 'ArrayObject'
    filename = 'arrayext'

    def write_init(self, writer):
        data = self.get_data()
        x_size = max(1, data.readInt())
        y_size = max(1, data.readInt())
        z_size = max(1, data.readInt())
        flags = BitDict('Numeric', 'Text', 'Base1', 'Global')
        flags.setFlags(data.readInt())
        is_numeric = flags['Numeric']
        offset = int(flags['Base1'])

        init = to_c('initialize(%s, %s, %s, %s, %s);',
                    is_numeric, offset, x_size, y_size, z_size)

        if flags['Global']:
            glob = self.get_global('ArrayObject::SavedArray')
            writer.putlnc('global_data = &%s;', glob)
            writer.putlnc('if (!%s.init) {', glob)
            writer.indent()
            writer.putlnc('%s.init = true;', glob)
            writer.putln(init)
            writer.dedent()
            writer.putln('} else {')
            writer.indent()
            writer.putlnc('data = %s.value;', glob)
            writer.end_brace()
        else:
            writer.putln(init)

class SetValue(ActionMethodWriter):
    method = 'set_value'

    def __init__(self, *arg, **kw):
        ActionMethodWriter.__init__(self, *arg, **kw)
        self.converter.config.init_array_set_value(self)

actions = make_table(ActionMethodWriter, {
    0 : '.data.x_pos = %s',
    1 : '.data.y_pos = %s',
    2 : '.data.z_pos = %s',
    3 : '.data.x_pos++',
    4 : '.data.y_pos++',
    6 : 'set_value', # current pos
    7 : 'set_string',
    13 : 'set_value',
    14 : 'set_value',
    15 : SetValue, # xyz
    16 : 'set_string',
    18 : 'set_string', # with xyz
    8 : 'clear',
    9 : 'load',
    11 : 'save'
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
    0 : '.data.x_pos',
    1 : '.data.y_pos',
    2 : '.data.z_pos',
    3 : 'get_value()', # current pos
    4 : 'get_string()', # current pos
    5 : 'get_value',
    6 : 'get_value',
    7 : 'get_value', # xyz
    8 : 'get_string',
    9 : 'get_string', # xy
    10 : 'get_string' # with xyz
})

def get_object():
    return KcArray