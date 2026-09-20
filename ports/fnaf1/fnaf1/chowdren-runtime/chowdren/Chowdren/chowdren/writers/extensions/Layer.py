from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ConditionMethodWriter,
    ExpressionMethodWriter, ActionMethodWriter, make_table, ExpressionWriter)

from chowdren.writers.events import system

class Layer(ObjectWriter):
    class_name = 'LayerObject'
    filename = 'layerext'

def get_layer(converter, name):
    frame = converter.current_frame
    for index, layer in enumerate(frame.layers.items):
        if layer.name != name:
            continue
        break
    else:
        raise NotImplementedError()
    return index, layer

class MoveBehind(system.MoveBehind):
    single = True

    def get_other(self):
        return (self.parameters[1].loader.objectInfo,
                self.parameters[1].loader.objectType)

    def get_object(self):
        parameter = self.parameters[0].loader
        return (parameter.objectInfo, parameter.objectType)

class MoveAbove(system.MoveInFront):
    single = True

    def get_other(self):
        return (self.parameters[1].loader.objectInfo,
                self.parameters[1].loader.objectType)

    def get_object(self):
        parameter = self.parameters[0].loader
        return (parameter.objectInfo, parameter.objectType)

class MoveBack(ActionMethodWriter):
    def write(self, writer):
        writer.putc('move_back();')

    def get_object(self):
        parameter = self.parameters[0].loader
        return (parameter.objectInfo, parameter.objectType)

class MoveObject(ActionMethodWriter):
    custom = True
    def write(self, writer):
        converter = self.converter
        items = self.parameters[1].loader.items

        # hacks for HFA
        if items[2].getName() == 'Multiply':
            self.multiply_case(writer)
            return
        elif items[3].getName() == 'Minus':
            self.minus_case(writer)
            return
        elif items[0].getName() == 'Min':
            self.min_case(writer)
            return
        else:
        # elif items[0].getName() is None:
            # exp_writer = self.converter.get_expression_writer(items[0])
            # from ValueAdd import GetValue
            # if isinstance(exp_writer, GetValue):
            # give up - maybe we can optimize using FrameObject pointers
            # in the future
            self.slow_case(writer)
            return

        import code
        code.interact(local=locals())
        raise NotImplementedError()

    def slow_case(self, writer):
        converter = self.converter
        with converter.iterate_object(self.get_object(), writer, copy=False):
            set_obj = converter.get_object(self.get_object())
            writer.putlnc('%s->set_level(%s);', set_obj, self.convert_index(1))

    def minus_case(self, writer):
        converter = self.converter
        items = self.parameters[1].loader.items

        obj1 = items[1]
        if obj1.getName() != 'FixedValue':
            raise NotImplementedError()

        if items[2].getName() != 'EndParenthesis':
            raise NotImplementedError()

        minus_exp = items[3]
        if minus_exp.getName() != 'Minus':
            raise NotImplementedError()

        value_exp = items[4]
        if value_exp.getName() != 'Long':
            raise NotImplementedError()

        offset = -value_exp.loader.value

        obj1 = converter.get_object((obj1.objectInfo,
                                     obj1.objectType))
        with converter.iterate_object(self.get_object(), writer, copy=False):
            set_obj = converter.get_object(self.get_object())
            writer.putlnc('%s->move_relative(%s, %s);', set_obj, obj1, offset)

    def min_case(self, writer):
        converter = self.converter
        items = self.parameters[1].loader.items

        obj1 = items[2]
        if obj1.getName() != 'FixedValue':
            raise NotImplementedError()

        if items[3].getName() != 'EndParenthesis':
            raise NotImplementedError()

        if items[4].getName() == 'Minus':
            direction = -1
        # elif items[4].getName() == 'Plus':
        #     direction = 1
        else:
            raise NotImplementedError()

        if items[5].getName() != 'Long':
            raise NotImplementedError()

        offset = items[5].loader.value * direction

        if items[6].getName() != 'Virgule':
            raise NotImplementedError()

        obj2 = items[8]
        if obj2.getName() != 'FixedValue':
            raise NotImplementedError()

        if items[9].getName() != 'EndParenthesis':
            raise NotImplementedError()

        if items[10].getName() != 'EndParenthesis':
            raise NotImplementedError()

        obj1 = converter.get_object((obj1.objectInfo,
                                     obj1.objectType))
        obj2 = converter.get_object((obj2.objectInfo,
                                     obj2.objectType))
        with converter.iterate_object(self.get_object(), writer, copy=False):
            set_obj = converter.get_object(self.get_object())
            writer.putlnc('%s->move_relative(%s, %s);', set_obj, obj1, offset)
            writer.putlnc('%s->move_back(%s);', set_obj, obj2)

    def multiply_case(self, writer):
        converter = self.converter
        items = self.parameters[1].loader.items

        fixed_exp = items[1]
        if fixed_exp.getName() != 'FixedValue':
            print self.convert_index(1)
            raise NotImplementedError()

        last_exp = items[2]
        if last_exp.getName() != 'Multiply':
            raise NotImplementedError()

        alt_exp = items[3]
        if alt_exp.getName() != 'AlterableValue':
            raise NotImplementedError()

        if items[4].getName() != 'EndParenthesis':
            raise NotImplementedError()

        if items[5].getName() == 'Minus':
            direction = -1
        elif items[5].getName() == 'Plus':
            direction = 1
        else:
            raise NotImplementedError()

        value_exp = items[6]
        if value_exp.getName() != 'Long':
            raise NotImplementedError()

        relative = value_exp.loader.value * direction

        obj = converter.get_object((fixed_exp.objectInfo,
                                    fixed_exp.objectType))

        # don't try this at home kids
        # very hacky, expect for the alt + end paranthesis to follow
        obj2 = converter.get_object((alt_exp.objectInfo,
                                     alt_exp.objectType))
        alt = '%s->alterables->values.get(%s)' % (obj2, alt_exp.loader.value)

        with converter.iterate_object(self.get_object(), writer, copy=False):
            set_obj = converter.get_object(self.get_object())
            writer.putlnc('%s->move_relative(%s != 0.0 ? %s : NULL, %s);',
                          set_obj, alt, obj, relative)

    def get_object(self):
        parameter = self.parameters[0].loader
        return (parameter.objectInfo, parameter.objectType)

class SetAlpha(ActionMethodWriter):
    method = 'set_alpha_coefficient(%s-1, %s)'

class SetEffect(ActionMethodWriter):
    custom = True

    def write(self, writer):
        name = self.parameters[1].loader.value
        if name != '':
            raise NotImplementedError()

class SetByName(ActionMethodWriter):
    def write(self, writer):
        name = self.converter.convert_static_expression(
            self.parameters[0].loader.items)
        index, layer = get_layer(self.converter, name)
        self.write_layer(index, writer)

class SetXByName(SetByName):
    def write_layer(self, layer, writer):
        writer.put('set_x(%s, %s);' % (layer, self.convert_index(1)))

class SetYByName(SetByName):
    def write_layer(self, layer, writer):
        writer.put('set_y(%s, %s);' % (layer, self.convert_index(1)))

class SetAlphaByName(SetByName):
    def write_layer(self, layer, writer):
        writer.put('set_alpha_coefficient(%s, %s);' % (layer,
                                                       self.convert_index(1)))

class ShowByName(SetByName):
    def write_layer(self, layer, writer):
        writer.put('show_layer(%s);' % layer)

class HideByName(SetByName):
    def write_layer(self, layer, writer):
        writer.put('hide_layer(%s);' % layer)

class GetLayerCount(ExpressionWriter):
    has_object = False

    def get_string(self):
        return str(len(self.converter.current_frame.layers.items))

class GetByName(ExpressionMethodWriter):
    def get_string(self):
        converter = self.converter
        items = converter.expression_items
        last_exp = items[converter.item_index + 2]
        if last_exp.getName() != 'EndParenthesis':
            raise NotImplementedError()
        next_exp = items[converter.item_index + 1]
        name = next_exp.loader.value
        converter.item_index += 2
        index, layer = get_layer(self.converter, name)
        return self.get_string_layer(index, layer)

class GetIndexByName(GetByName):
    has_object = False

    def get_string_layer(self, index, layer):
        return str(index+1)

class GetLayerCount(ExpressionWriter):
    has_object = False

    def get_string(self):
        return str(len(self.converter.current_frame.layers.items))

class GetXByName(GetByName):
    has_object = False

    def get_string_layer(self, index, layer):
        return 'layers[%s].x' % index

class GetYByName(GetByName):
    has_object = False

    def get_string_layer(self, index, layer):
        return 'layers[%s].y' % index

class CheckByName(ConditionMethodWriter):
    has_object = False

    def write(self, writer):
        name = self.converter.convert_static_expression(
            self.parameters[0].loader.items)
        index, layer = get_layer(self.converter, name)
        self.write_layer(index, writer)

class IsVisibleByName(CheckByName):
    def write_layer(self, layer, writer):
        writer.putc('layers[%s].visible', layer)

class IsVisible(ConditionMethodWriter):
    has_object = False
    method = 'layers[%s-1].visible'

class GetObjectLevel(ExpressionMethodWriter):
    has_object = False

    def get_string(self):
        converter = self.converter
        items = converter.expression_items
        last_exp = items[converter.item_index + 2]
        next_exp = items[converter.item_index + 1]
        obj = converter.get_object((next_exp.objectInfo, next_exp.objectType))
        converter.item_index += 2
        return '%s->get_level()' % obj

actions = make_table(ActionMethodWriter, {
    20 : MoveBack,
    23 : MoveAbove,
    24 : MoveBehind,
    25 : MoveObject,
    28 : 'set_x(%s-1, %s)',
    29 : 'set_y(%s-1, %s)',
    30 : 'set_position(%s-1, %s, %s)',
    33 : SetXByName,
    34 : SetYByName,
    36 : ShowByName,
    37 : HideByName,
    38 : 'set_layer(%s-1)',
    27 : 'sort_alt_decreasing',
    31 : 'show_layer(%s-1)',
    32 : 'hide_layer(%s-1)',
    44 : SetEffect,
    46 : SetAlpha,
    47 : 'set_rgb(%s-1, %s)',
    50 : SetAlphaByName
})

conditions = make_table(ConditionMethodWriter, {
    10 : IsVisible,
    11 : IsVisibleByName
})

expressions = make_table(ExpressionMethodWriter, {
    6 : GetObjectLevel,
    8 : '.get_x(-1 + ',
    9 : '.get_y(-1 + ',
    12 : GetLayerCount,
    14 : GetIndexByName,
    10 : GetXByName,
    11 : GetYByName,
})

def get_object():
    return Layer