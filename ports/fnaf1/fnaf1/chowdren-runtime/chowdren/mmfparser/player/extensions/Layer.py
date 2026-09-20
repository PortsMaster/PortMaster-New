# Copyright (c) Mathias Kaerlev 2012.

# This file is part of Anaconda.

# Anaconda is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Anaconda is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Anaconda.  If not, see <http://www.gnu.org/licenses/>.

"""
Layer.mfx
Layer object - Cragmyre (http://www.clickteam.com)

Allows you to change the order of the objects in a frame. Can also
show, hide or move layers.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Select by Fixed Value->Send Object Back One

    Parameters:
    0: Enter Fixed Value (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        fixed = self.evaluate_index(0)
        instance = self.player.frame.get_fixed_object(fixed)
        if instance is None:
            return
        layer = instance.layer
        layer.set_level(instance, layer.get_level(instance) - 1)

class Action1(Action):
    """
    Select by Fixed Value->Bring Object Forward One

    Parameters:
    0: Enter Fixed Value (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        fixed = self.evaluate_index(0)
        instance = self.player.frame.get_fixed_object(fixed)
        if instance is None:
            return
        layer = instance.layer
        layer.set_level(instance, layer.get_level(instance) + 1)

class Action2(Action):
    """
    Select by Fixed Value->Swap two Objects

    Parameters:
    0: Enter Fixed Value (TIME, Time)
    1: Enter Fixed Value (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        fixed1 = self.evaluate_index(0)
        fixed2 = self.evaluate_index(1)
        instance1 = self.player.frame.get_fixed_object(fixed1)
        instance2 = self.player.frame.get_fixed_object(fixed2)
        if None in (instance1, instance2):
            return
        if instance1.layer != instance2.layer:
            return
        layer = instance1.layer
        level1 = layer.get_level(instance1)
        level2 = layer.get_level(instance2)
        layer.set_level(instance1, level2)
        layer.set_level(instance2, level1)

class Action3(Action):
    """
    Select by Object Picker->Store Fixed Value

    Parameters:
    0: Select Object A (OBJECT, Object)
    1:  (OBJECT, Object)
    """

    def execute(self, instance):
        instances = self.get_instances(self.get_parameter(0).objectInfo)
        try:
            instance.objectPlayer.savedFixed = id(instances[0])
        except IndexError:
            return

class Action4(Action):
    """
    Select by Fixed Value->Bring Object to Front

    Parameters:
    0: Enter Fixed Value (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        fixed = self.evaluate_index(0)
        instance = self.player.frame.get_fixed_object(fixed)
        if instance is None:
            return
        layer = instance.layer
        layer.set_level(instance, layer.get_size())

class Action5(Action):
    """
    Select by Fixed Value->Send Object to Back

    Parameters:
    0: Enter Fixed Value (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        fixed = self.evaluate_index(0)
        instance = self.player.frame.get_fixed_object(fixed)
        if instance is None:
            return
        layer = instance.layer
        layer.set_level(instance, 0)

class Action6(Action):
    """
    Select by Fixed Value->Send Object Back N

    Parameters:
    0: Enter Fixed Value (TIME, Time)
    1: How many levels? (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        fixed = self.evaluate_index(0)
        n = self.evaluate_index(1)
        instance = self.player.frame.get_fixed_object(fixed)
        if instance is None:
            return
        layer = instance.layer
        layer.set_level(instance, layer.get_level(instance) - n)

class Action7(Action):
    """
    Select by Fixed Value->Bring Object Forward N

    Parameters:
    0: Enter Fixed Value (TIME, Time)
    1: How many levels? (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        fixed = self.evaluate_index(0)
        n = self.evaluate_index(1)
        instance = self.player.frame.get_fixed_object(fixed)
        if instance is None:
            return
        layer = instance.layer
        layer.set_level(instance, layer.get_level(instance) + n)

class Action8(Action):
    """
    Sort->Reverse all Objects

    Parameters:
    0:  ((unknown 25090))
    """

    def execute(self, instance):
        layer = instance.objectPlayer.get_layer()
        for instance in layer.instances:
            layer.set_level(instance, 0)

class Action9(Action):
    """
    Select by Fixed Value->Move Above Object B

    Parameters:
    0: Enter Fixed Value (TIME, Time)
    1: Enter Fixed Value (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        fixed1 = self.evaluate_index(0)
        fixed2 = self.evaluate_index(1)
        instance1 = self.player.frame.get_fixed_object(fixed1)
        instance2 = self.player.frame.get_fixed_object(fixed2)
        if None in (instance1, instance2):
            return
        if instance1.layer != instance2.layer:
            return
        layer = instance1.layer
        level2 = layer.get_level(instance2)
        layer.set_level(instance1, level2 + 1)

class Action10(Action):
    """
    Select by Fixed Value->Move Below Object B

    Parameters:
    0: Enter Fixed Value (TIME, Time)
    1: Enter Fixed Value (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        fixed1 = self.evaluate_index(0)
        fixed2 = self.evaluate_index(1)
        instance1 = self.player.frame.get_fixed_object(fixed1)
        instance2 = self.player.frame.get_fixed_object(fixed2)
        if None in (instance1, instance2):
            return
        if instance1.layer != instance2.layer:
            return
        layer = instance1.layer
        level2 = layer.get_level(instance2)
        layer.set_level(instance1, level2 - 1)

class Action11(Action):
    """
    Select by Fixed Value->Move To Level N

    Parameters:
    0: Enter Fixed Value (TIME, Time)
    1: Enter Level Number (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        fixed = self.evaluate_index(0)
        n = self.evaluate_index(1)
        instance = self.player.frame.get_fixed_object(fixed)
        if instance is None:
            return
        layer = instance.layer
        layer.set_level(instance, n)

class Action12(Action):
    """
    Sort->By X(Increasing)

    Parameters:
    0:  ((unknown 25130))
    """

    def execute(self, instance):
        instances = []
        for item in instance.objectPlayer.get_layer().instances:
            instances.append((item.x, item))
        instance.objectPlayer.sort(instances, True)

class Action13(Action):
    """
    Sort->By Y(Increasing)

    Parameters:
    0:  ((unknown 25140))
    """

    def execute(self, instance):
        instances = []
        for item in instance.objectPlayer.get_layer().instances:
            instances.append((item.y, item))
        instance.objectPlayer.sort(instances, True)

class Action14(Action):
    """
    Sort->By X(Decreasing)

    Parameters:
    0:  ((unknown 25150))
    """

    def execute(self, instance):
        instances = []
        for item in instance.objectPlayer.get_layer().instances:
            instances.append((item.x, item))
        instance.objectPlayer.sort(instances, False)

class Action15(Action):
    """
    Sort->By Y(Decreasing)

    Parameters:
    0:  ((unknown 25160))
    """

    def execute(self, instance):
        instances = []
        for item in instance.objectPlayer.get_layer().instances:
            instances.append((item.y, item))
        instance.objectPlayer.sort(instances, False)

class Action16(Action):
    """
    Select by Object Picker->Send Object Back One

    Parameters:
    0: Select an Object (OBJECT, Object)
    1:  (OBJECT, Object)
    """

    def execute(self, instance):
        for instance in self.get_instances(self.get_parameter(0).objectInfo):
            layer = instance.layer
            layer.set_level(instance, layer.get_level(instance) - 1)

class Action17(Action):
    """
    Select by Object Picker->Bring Object Forward One

    Parameters:
    0: Select an Object (OBJECT, Object)
    1:  (OBJECT, Object)
    """

    def execute(self, instance):
        for instance in self.get_instances(self.get_parameter(0).objectInfo):
            layer = instance.layer
            layer.set_level(instance, layer.get_level(instance) + 1)

class Action18(Action):
    """
    Select by Object Picker->Swap two Objects

    Parameters:
    0: Select Object A (TIME, Time)
    1: Select Object B (OBJECT, Object)
    """

    def execute(self, instance):
        for instance1 in self.get_instances(self.get_parameter(0).objectInfo):
            for instance2 in self.get_instances(
            self.get_parameter(1).objectInfo):
                if instance1.layer != instance2.layer:
                    continue
                layer = instance1.layer
                level1 = layer.get_level(instance1)
                level2 = layer.get_level(instance2)
                layer.set_level(instance1, level2)
                layer.set_level(instance2, level1)

class Action19(Action):
    """
    Select by Object Picker->Bring Object to Front

    Parameters:
    0: Select an Object (OBJECT, Object)
    1:  (OBJECT, Object)
    """

    def execute(self, instance):
        for instance in self.get_instances(self.get_parameter(0)):
            layer = instance.layer
            layer.set_level(instance, layer.get_size())

class Action20(Action):
    """
    Select by Object Picker->Send Object to Back

    Parameters:
    0: Select an Object (OBJECT, Object)
    1:  (OBJECT, Object)
    """

    def execute(self, instance):
        for instance in self.get_instances(self.get_parameter(0)):
            layer = instance.layer
            layer.set_level(instance, 0)

class Action21(Action):
    """
    Select by Object Picker->Send Object Back N

    Parameters:
    0: Select Object A (TIME, Time)
    1: How many levels? (OBJECT, Object)
    """

    def execute(self, instance):
        n = self.evaluate_index(1)
        for instance in self.get_instances(self.get_parameter(0).objectInfo):
            layer = instance.layer
            layer.set_level(instance, layer.get_level(instance) - n)

class Action22(Action):
    """
    Select by Object Picker->Bring Object Forward N

    Parameters:
    0: Select Object A (TIME, Time)
    1: How many levels? (OBJECT, Object)
    """

    def execute(self, instance):
        n = self.evaluate_index(1)
        for instance in self.get_instances(self.get_parameter(0).objectInfo):
            layer = instance.layer
            layer.set_level(instance, layer.get_level(instance) + n)

class Action23(Action):
    """
    Select by Object Picker->Move Above Object B

    Parameters:
    0: Select Object A (TIME, Time)
    1: Select Object B (OBJECT, Object)
    """

    def execute(self, instance):
        for instance1 in self.get_instances(self.get_parameter(0).objectInfo):
            for instance2 in self.get_instances(
            self.get_parameter(1).objectInfo):
                if instance1.layer != instance2.layer:
                    return
                layer = instance1.layer
                level2 = layer.get_level(instance2)
                layer.set_level(instance1, level2 + 1)

class Action24(Action):
    """
    Select by Object Picker->Move Below Object B

    Parameters:
    0: Select Object A (TIME, Time)
    1: Select Object B (OBJECT, Object)
    """

    def execute(self, instance):
        for instance1 in self.get_instances(self.get_parameter(0).objectInfo):
            for instance2 in self.get_instances(
            self.get_parameter(1).objectInfo):
                if instance1.layer != instance2.layer:
                    return
                layer = instance1.layer
                level2 = layer.get_level(instance2)
                layer.set_level(instance1, level2)

class Action25(Action):
    """
    Select by Object Picker->Move To Level N

    Parameters:
    0: Select Object A (TIME, Time)
    1: Enter Level Number (OBJECT, Object)
    """

    def execute(self, instance):
        n = self.evaluate_index(1)
        for instance in self.get_instances(self.get_parameter(0).objectInfo):
            layer = instance.layer
            layer.set_level(instance, n)

class Action26(Action):
    """
    Sort->By ALT Value(Increasing)

    Parameters:
    0: Select an Alterable Value (TIME, Time)
    1: Default Value to sort by for Objects with no Alterable Value ability (i.e. Counter, String) (AlterableValue, Short)
    """

    def execute(self, instance):
        index = self.get_parameter(0).value
        default = self.evaluate_index(1)
        instances = []
        for item in instance.objectPlayer.get_layer().instances:
            try:
                value = item.alterables.get_value(index)
            except AttributeError:
                value = default
            instances.append((value, item))
        instance.objectPlayer.sort(instances, True)

class Action27(Action):
    """
    Sort->By ALT Value(Decreasing)

    Parameters:
    0: Select an Alterable Value (TIME, Time)
    1: Default Value to sort by for Objects with no Alterable Value ability (i.e. Counter, String) (AlterableValue, Short)
    """

    def execute(self, instance):
        index = self.get_parameter(0).value
        default = self.evaluate_index(1)
        instances = []
        for item in instance.objectPlayer.get_layer().instances:
            try:
                value = item.alterables.get_value(index)
            except AttributeError:
                value = default
            instances.append((value, item))
        instance.objectPlayer.sort(instances, False)

class Action28(Action):
    """
    Layers->By Index->Position->Set X Position

    Parameters:
    0: Layer index (1-based) (TIME, Time)
    1: X Position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0) - 1
        x = self.evaluate_index(1)
        layer = self.player.frame.layers[index]
        layer.set_position(x = x)

class Action29(Action):
    """
    Layers->By Index->Position->Set Y Position

    Parameters:
    0: Layer index (1-based) (TIME, Time)
    1: Y Position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0) - 1
        y = self.evaluate_index(1)
        layer = self.player.frame.layers[index]
        layer.set_position(y = y)

class Action30(Action):
    """
    Layers->By Index->Position->Set Position

    Parameters:
    0: Layer index (1-based) (SHORT, Short)
    1: X Position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0) - 1
        x = self.evaluate_index(1)
        y = self.evaluate_index(2)
        layer = self.player.frame.layers[index]
        layer.set_position(x, y)

class Action31(Action):
    """
    Layers->By Index->Visibility->Show

    Parameters:
    0: Layer index (1-based) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0) - 1
        layer = self.player.frame.layers[index]
        layer.visible = True

class Action32(Action):
    """
    Layers->By Index->Visibility->Hide

    Parameters:
    0: Layer index (1-based) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0) - 1
        layer = self.player.frame.layers[index]
        layer.visible = False

class LayerNameAction(Action):
    def execute(self, instance):
        name = self.evaluate_index(0)
        layer = instance.objectPlayer.find_layer(name)
        if layer is not None:
            self.action(instance, layer)

class Action33(LayerNameAction):
    """
    Layers->By Name->Position->Set X Position

    Parameters:
    0: Layer name (TIME, Time)
    1: X Position (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance, layer):
        value = self.evaluate_index(1)
        layer.set_position(x = value)

class Action34(LayerNameAction):
    """
    Layers->By Name->Position->Set Y Position

    Parameters:
    0: Layer name (TIME, Time)
    1: Y Position (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance, layer):
        value = self.evaluate_index(1)
        layer.set_position(y = value)

class Action35(LayerNameAction):
    """
    Layers->By Name->Position->Set Position

    Parameters:
    0: Layer name (SHORT, Short)
    1: X Position (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance, layer):
        x = self.evaluate_index(1)
        y = self.evaluate_index(2)
        layer.set_position(x = x, y = y)

class Action36(LayerNameAction):
    """
    Layers->By Name->Visibility->Show

    Parameters:
    0: Layer name (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance, layer):
        layer.visible = True

class Action37(LayerNameAction):
    """
    Layers->By Name->Visibility->Hide

    Parameters:
    0: Layer name (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance, layer):
        layer.visible = False

class Action38(Action):
    """
    Layers->By Index->Set Current Layer

    Parameters:
    0: Layer index (1-based) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0) - 1
        instance.objectPlayer.layer = self.player.frame.layers[index]

class Action39(LayerNameAction):
    """
    Layers->By Name->Set Current Layer

    Parameters:
    0: Layer index (1-based) (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance, layer):
        instance.objectPlayer.layer = layer

class Action40(Action):
    """
    Layers->By Index->Scrolling->Set X coefficient

    Parameters:
    0: Layer index (1-based) (TIME, Time)
    1: X coefficient (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0) - 1
        layer = self.player.frame.layers[index]
        layer.xCoefficient = self.evaluate_index(1)

class Action41(Action):
    """
    Layers->By Index->Scrolling->Set Y coefficient

    Parameters:
    0: Layer index (1-based) (TIME, Time)
    1: Y coefficient (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0) - 1
        layer = self.player.frame.layers[index]
        layer.yCoefficient = self.evaluate_index(1)

class Action42(LayerNameAction):
    """
    Layers->By Name->Scrolling->Set X coefficient

    Parameters:
    0: Layer name (TIME, Time)
    1: X coefficient (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance, layer):
        layer.xCoefficient = self.evaluate_index(1)

class Action43(LayerNameAction):
    """
    Layers->By Name->Scrolling->Set Y coefficient

    Parameters:
    0: Layer name (TIME, Time)
    1: Y coefficient (EXPSTRING, ExpressionParameter)
    """

    def action(self, instance, layer):
        layer.yCoefficient = self.evaluate_index(1)

# Conditions

class FixedValueCondition(Condition):
    def check(self, instance):
        fixed_instance = self.player.frame.get_fixed_object(
            self.evaluate_index(0))
        return self.condition(instance, fixed_instance)

class Condition0(FixedValueCondition):
    """
    Select by Fixed Value->Is Object at Back?

    Parameters:
    0: Enter Fixed Value (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def condition(self, instance, fixed_instance):
        layer = instance.objectPlayer.get_layer()
        return layer.get_level(fixed_instance) == 0

class Condition1(FixedValueCondition):
    """
    Select by Fixed Value->Is Object at Front?

    Parameters:
    0: Enter Fixed Value (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def condition(self, instance, fixed_instance):
        layer = instance.objectPlayer.get_layer()
        return layer.get_level(fixed_instance) == len(layer.instances) - 1

class Condition2(Condition):
    """
    Select by Fixed Value->Is Object A above Object B?

    Parameters:
    0: Enter Fixed Value (TIME, Time)
    1: Enter Fixed Value (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        fixed_instance1 = self.player.frame.get_fixed_object(
            self.evaluate_index(0))
        fixed_instance2 = self.player.frame.get_fixed_object(
            self.evaluate_index(0))
        layer = instance.objectPlayer.get_layer()
        level1 = layer.get_level(fixed_instance1)
        level2 = layer.get_level(fixed_instance2)
        return level1 > level2

class Condition3(Condition):
    """
    Select by Fixed Value->Is Object A below Object B?

    Parameters:
    0: Enter Fixed Value (TIME, Time)
    1: Enter Fixed Value (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        fixed_instance1 = self.player.frame.get_fixed_object(
            self.evaluate_index(0))
        fixed_instance2 = self.player.frame.get_fixed_object(
            self.evaluate_index(0))
        layer = instance.objectPlayer.get_layer()
        level1 = layer.get_level(fixed_instance1)
        level2 = layer.get_level(fixed_instance2)
        return level1 < level2

class Condition4(Condition):
    """
    Select by Fixed Value->Is Object A between Object B and C?

    Parameters:
    0: Enter Fixed Value (SHORT, Short)
    1: Enter Fixed Value (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        fixed_instance1 = self.player.frame.get_fixed_object(
            self.evaluate_index(0))
        fixed_instance2 = self.player.frame.get_fixed_object(
            self.evaluate_index(0))
        fixed_instance3 = self.player.frame.get_fixed_object(
            self.evaluate_index(0))
        layer = instance.objectPlayer.get_layer()
        level1 = layer.get_level(fixed_instance1)
        level2 = layer.get_level(fixed_instance2)
        level3 = layer.get_level(fixed_instance3)
        return level1 in xrange(level2, level3)

class ObjectCondition(Condition):
    def check(self, instance):
        objectInfo = self.get_parameter(0).objectInfo
        try:
            otherInfo = self.get_parameter(1).objectInfo
        except (AttributeError, IndexError):
            otherInfo = None
        allInstances = self.get_instances(objectInfo)
        if otherInfo is not None:
            secondInstances = self.get_instances(otherInfo)
        newInstances = []
        for otherInstance in allInstances:
            if otherInfo is not None:
                for secondInstance in secondInstances:
                    if self.condition(instance, otherInstance, secondInstance):
                        newInstances.append(otherInstance)
                        break
            else:
                if self.condition(instance, otherInstance):
                    newInstances.append(otherInstance)
        self.select_instances(newInstances, objectInfo)
        return len(newInstances) > 0

class Condition5(ObjectCondition):
    """
    Select by Object Picker->Is Object at Back?

    Parameters:
    0: Select an Object (OBJECT, Object)
    1:  (OBJECT, Object)
    """

    def condition(self, instance, otherInstance):
        layer = instance.objectPlayer.get_layer()
        return layer.get_level(otherInstance) == 0

class Condition6(ObjectCondition):
    """
    Select by Object Picker->Is Object at Front?

    Parameters:
    0: Select an Object (OBJECT, Object)
    1:  (OBJECT, Object)
    """

    def condition(self, instance, otherInstance):
        layer = instance.objectPlayer.get_layer()
        return layer.get_level(otherInstance) == len(layer.instances) - 1

class Condition7(ObjectCondition):
    """
    Select by Object Picker->Is Object A above Object B?

    Parameters:
    0: Select Object A (TIME, Time)
    1: Select Object B (OBJECT, Object)
    """

    def condition(self, instance, otherInstance, secondInstance):
        layer = instance.objectPlayer.get_layer()
        level1 = layer.get_level(otherInstance)
        level2 = layer.get_level(secondInstance)
        return level1 > level2

class Condition8(Condition):
    """
    Select by Object Picker->Is Object A below Object B?

    Parameters:
    0: Select Object A (TIME, Time)
    1: Select Object B (OBJECT, Object)
    """

    def condition(self, instance, otherInstance, secondInstance):
        layer = instance.objectPlayer.get_layer()
        level1 = layer.get_level(otherInstance)
        level2 = layer.get_level(secondInstance)
        return level1 > level2

class Condition9(Condition):
    """
    Select by Object Picker->Is Object A between Object B and C?

    Parameters:
    0: Select Object A (SHORT, Short)
    1: Select Object B (OBJECT, Object)
    """

    def condition(self, instance, otherInstance):
        info1 = self.get_parameter(0).objectInfo
        info2 = self.get_parameter(1).objectInfo
        info3 = self.get_parameter(2).objectInfo
        layer = instance.objectPlayer.get_layer()
        instances1 = self.get_instances(info1)
        instances2 = self.get_instances(info2)
        instances3 = self.get_instances(info3)
        newInstances = []
        for instance1 in instances1:
            exit = False
            level1 = layer.get_level(instance1)
            for instance2 in instances2:
                level2 = layer.get_level(instance2)
                for instance3 in instances3:
                    level3 = layer.get_level(instance3)
                    if level1 in xrange(level2, level3):
                        newInstances.append(instance1)
                        exit = True
                        break
                if exit:
                    break
        self.select_instances(newInstances, info1)
        return len(newInstances) > 0

class Condition10(Condition):
    """
    Layers->By Index->Is Layer Visible?

    Parameters:
    0: Layer index (1-based) (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        index = self.evaluate_index(0) - 1
        layer = self.player.frame.layers[index].visible
        return layer.visible

class Condition11(Condition):
    """
    Layers->By Name->Is Layer Visible?

    Parameters:
    0: Layer name (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        name = self.evaluate_index(0)
        layer = instance.objectPlayer.find_layer(name)
        return layer.visible

# Expressions

class Expression0(Expression):
    """
    Get Fixed Value

    Parameters:
    0: Object's name (Int)
    1:  (String)
    Return type: Int
    """

    def get(self, instance):
        name = self.next_argument()
        for instance in self.player.frame.instances:
            if instance.objectInfo.name == name:
                return id(instance)
        return 0

class Expression1(Expression):
    """
    Get Fixed Value of Top Object

    Parameters:
    0:  ((unknown 27020))
    Return type: Int
    """

    def get(self, instance):
        layer = instance.objectPlayer.get_layer()
        return id(layer.instances[-1])

class Expression2(Expression):
    """
    Get Fixed Value of Bottom Object

    Parameters:
    0:  ((unknown 27030))
    Return type: Int
    """

    def get(self, instance):
        layer = instance.objectPlayer.get_layer()
        return id(layer.instances[0])

class Expression3(Expression):
    """
    Get Level N Description

    Parameters:
    0: Level number (Int)
    1:  (Int)
    Return type: String
    """

    def get(self, instance):
        level = self.next_argument() - 1
        layer = instance.objectPlayer.get_layer()
        return instance.objectPlayer.get_descriptions([
            layer.instances[level]])

class Expression4(Expression):
    """
    Get 10 Level Descriptions

    Parameters:
    0: Level number (Int)
    1:  (Int)
    Return type: String
    """

    def get(self, instance):
        level = max(0, self.next_argument() - 1)
        layer = instance.objectPlayer.get_layer()
        return instance.objectPlayer.get_descriptions(
            layer.instances[level:level+10])

class Expression5(Expression):
    """
    Get Number of Levels

    Parameters:
    0:  ((unknown 27060))
    Return type: Int
    """

    def get(self, instance):
        layer = instance.objectPlayer.get_layer()
        return len(layer.instances)

class Expression6(Expression):
    """
    Get Object's Level

    Parameters:
    0: Enter Fixed Value (Int)
    1:  (Int)
    Return type: Int
    """

    def get(self, instance):
        fixed = self.next_argument()
        instance = self.player.frame.get_fixed_object(fixed)
        if instance is None:
            return 0
        return instance.layer.get_level(instance) + 1

class Expression7(Expression):
    """
    Get Fixed Value from Level N

    Parameters:
    0: Level number (Int)
    1:  (Int)
    Return type: Int
    """

    def get(self, instance):
        layer = instance.objectPlayer.get_layer()
        return id(layer.instances[self.next_argument()])

class Expression8(Expression):
    """
    Layers->By Index->Get Layer X Position

    Parameters:
    0: Layer index (1-based) (Int)
    1:  (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument() - 1
        layer = self.player.frame.layers[index]
        return layer.x

class Expression9(Expression):
    """
    Layers->By Index->Get Layer Y Position

    Parameters:
    0: Layer index (1-based) (Int)
    1:  (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument() - 1
        layer = self.player.frame.layers[index]
        return layer.y

class Expression10(Expression):
    """
    Layers->By Name->Get Layer X Position

    Parameters:
    0: Layer name (Int)
    1:  (String)
    Return type: Int
    """

    def get(self, instance):
        name = self.next_argument()
        layer = instance.objectPlayer.find_layer(name)
        if layer is not None:
            return layer.x
        return 0

class Expression11(Expression):
    """
    Layers->By Name->Get Layer Y Position

    Parameters:
    0: Layer name (Int)
    1:  (String)
    Return type: Int
    """

    def get(self, instance):
        name = self.next_argument()
        layer = instance.objectPlayer.find_layer(name)
        if layer is not None:
            return layer.y
        return 0

class Expression12(Expression):
    """
    Layers->Get Layer Count

    Parameters:
    0:  ((unknown 27076))
    Return type: Int
    """

    def get(self, instance):
        return len(self.player.frame.layers)

class Expression13(Expression):
    """
    Layers->By Index->Get Layer Name

    Parameters:
    0: Layer index (1-based) (Int)
    1:  (Int)
    Return type: String
    """

    def get(self, instance):
        index = self.next_argument() - 1
        layer = self.player.frame.layers[index]
        return layer.name

class Expression14(Expression):
    """
    Layers->By Name->Get Layer Index

    Parameters:
    0: Layer name (Int)
    1:  (String)
    Return type: Int
    """

    def get(self, instance):
        name = self.next_argument()
        layer = instance.objectPlayer.find_layer(name)
        if layer is None:
            return 0
        return self.player.frame.layers.index(layer) + 1

class Expression15(Expression):
    """
    Layers->Get Current Layer

    Parameters:
    0:  ((unknown 27081))
    Return type: Int
    """

    def get(self, instance):
        layer = instance.objectPlayer.get_layer()
        return self.player.frame.layers.index(layer) + 1

class Expression16(Expression):
    """
    Layers->By Index->Get scrolling X coefficient

    Parameters:
    0: Layer index (1-based) (Int)
    1:  (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument() - 1
        layer = self.player.frame.layers[index]
        return layer.xCoefficient

class Expression17(Expression):
    """
    Layers->By Index->Get scrolling Y coefficient

    Parameters:
    0: Layer index (1-based) (Int)
    1:  (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument() - 1
        layer = self.player.frame.layers[index]
        return layer.yCoefficient

class Expression18(Expression):
    """
    Layers->By Name->Get scrolling X coefficient

    Parameters:
    0: Layer name (Int)
    1:  (String)
    Return type: Int
    """

    def get(self, instance):
        name = self.next_argument()
        layer = instance.objectPlayer.find_layer(name)
        if layer is None:
            return 0
        return layer.xCoefficient

class Expression19(Expression):
    """
    Layers->By Name->Get scrolling Y coefficient

    Parameters:
    0: Layer name (Int)
    1:  (String)
    Return type: Int
    """

    def get(self, instance):
        name = self.next_argument()
        layer = instance.objectPlayer.find_layer(name)
        if layer is None:
            return 0
        return layer.yCoefficient

class DefaultObject(HiddenObject):
    layer = None
    def created(self, data):
        pass
    
    def get_layer(self):
        if self.layer is None:
            self.layer = self.parent.layer
        return self.layer
    
    def sort(self, instanceList, reverse):
        sortedList = sorted(instanceList, key = lambda item: item[0],
            reverse = reverse)
        instances = [item[1] for item in sortedList]
        self.layer.set_instances(instances)
    
    def find_layer(self, name):
        for layer in self.player.frame.layers:
            if layer.name == name:
                return layer
        return None
    
    def get_descriptions(self, instances):
        layer = self.get_layer()
        data = 'Lvl\tName\tFV\n\n'
        for instance in instances:
            level = layer.get_level(instance) + 1
            name = instance.objectInfo.name or ''
            fixed = id(instance)
            data += '%s\t%s\t%s\n' % (level, name, fixed)
        return data

class Layer(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
        3 : Action3,
        4 : Action4,
        5 : Action5,
        6 : Action6,
        7 : Action7,
        8 : Action8,
        9 : Action9,
        10 : Action10,
        11 : Action11,
        12 : Action12,
        13 : Action13,
        14 : Action14,
        15 : Action15,
        16 : Action16,
        17 : Action17,
        18 : Action18,
        19 : Action19,
        20 : Action20,
        21 : Action21,
        22 : Action22,
        23 : Action23,
        24 : Action24,
        25 : Action25,
        26 : Action26,
        27 : Action27,
        28 : Action28,
        29 : Action29,
        30 : Action30,
        31 : Action31,
        32 : Action32,
        33 : Action33,
        34 : Action34,
        35 : Action35,
        36 : Action36,
        37 : Action37,
        38 : Action38,
        39 : Action39,
        40 : Action40,
        41 : Action41,
        42 : Action42,
        43 : Action43,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3,
        4 : Condition4,
        5 : Condition5,
        6 : Condition6,
        7 : Condition7,
        8 : Condition8,
        9 : Condition9,
        10 : Condition10,
        11 : Condition11,
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
        3 : Expression3,
        4 : Expression4,
        5 : Expression5,
        6 : Expression6,
        7 : Expression7,
        8 : Expression8,
        9 : Expression9,
        10 : Expression10,
        11 : Expression11,
        12 : Expression12,
        13 : Expression13,
        14 : Expression14,
        15 : Expression15,
        16 : Expression16,
        17 : Expression17,
        18 : Expression18,
        19 : Expression19,
    }

extension = Layer()

def get_extension():
    return extension
