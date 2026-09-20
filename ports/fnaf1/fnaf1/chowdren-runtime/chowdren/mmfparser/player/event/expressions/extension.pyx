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

from mmfparser.player.event.expressions.common cimport Expression
from mmfparser.player.instance cimport Instance
from mmfparser.player.common cimport make_color_number
cimport cython

cdef class ActionX(Expression):
    cdef object evaluate_instance(self, Instance instance):
        if instance is None:
            return 0
        return <int>instance.objectPlayer.get_action_point()[0]

cdef class ActionY(Expression):
    cdef object evaluate_instance(self, Instance instance):
        if instance is None:
            return 0
        return <int>instance.objectPlayer.get_action_point()[1]

cdef class XPosition(Expression):
    cdef object evaluate_instance(self, Instance instance):
        if instance is None:
            return 0
        return <int>instance.x

cdef class YPosition(Expression):
    cdef object evaluate_instance(self, Instance instance):
        if instance is None:
            return 0
        return <int>instance.y

cdef class Speed(Expression):
    cdef object evaluate_instance(self, Instance instance):
        if instance is None:
            return 0
        return <int>instance.currentMovement.speed

cdef class ObjectLeft(Expression):
    cdef object evaluate_instance(self, Instance instance):
        if instance is None:
            return 0
        return instance.x1

cdef class ObjectTop(Expression):
    cdef object evaluate_instance(self, Instance instance):
        if instance is None:
            return 0
        return instance.y1

cdef class ObjectRight(Expression):
    cdef object evaluate_instance(self, Instance instance):
        if instance is None:
            return 0
        return instance.x2
        
cdef class ObjectBottom(Expression):
    cdef object evaluate_instance(self, Instance instance):
        if instance is None:
            return 0
        return instance.y2

cdef class ObjectLayer(Expression):
    cdef object evaluate_instance(self, Instance instance):
        if instance is None:
            return 0
        return instance.layerIndex + 1

cdef class SemiTransparency(Expression):
    cdef object evaluate_instance(self, Instance instance):
        if instance is None:
            return 0
        return int(128 - instance.transparency)

cdef class GetDirection(Expression):
    cdef object evaluate_instance(self, Instance instance):
        if instance is None:
            return 0
        return instance.get_direction()

cdef class FixedValue(Expression):
    cdef object evaluate_instance(self, Instance instance):
        if instance is None:
            return 0
        return id(instance)

cdef class GetFlag(Expression):
    cdef object evaluate_instance(self, Instance instance):
        if instance is None:
            return 0
        try:
            return instance.alterables.flags[self.next_argument() % 32]
        except KeyError:
            return 0

@cython.final
cdef class AlterableValue(Expression):
    cdef object index

    cdef void created(self):
        self.index = self.loader.loader.value

    cdef object evaluate_instance(self, Instance instance):
        if instance is None:
            return 0
        return instance.alterables.get_value(self.index)

@cython.final
cdef class AlterableString(Expression):
    cdef object index

    cdef void created(self):
        self.index = self.loader.loader.value

    cdef object evaluate_instance(self, Instance instance):
        if instance is None:
            return 0
        return instance.alterables.get_string(self.index)

@cython.final
cdef class AlterableStringIndex(Expression):
    cdef object evaluate_instance(self, Instance instance):
        index = self.next_argument()
        if instance is None:
            return 0
        return instance.alterables.get_string(index)

@cython.final
cdef class AlterableValueIndex(Expression):
    cdef object evaluate_instance(self, Instance instance):
        index = self.next_argument()
        if instance is None:
            return 0
        return instance.alterables.get_value(index)

cdef class ObjectCount(Expression):
    iterateObjects = False

    cdef object evaluate(self):
        return len(self.get_all_instances())

cdef class MovementNumber(Expression):
    cdef object evaluate_instance(self, Instance instance):
        return instance.movementPlayers.index(instance.currentMovement)

cdef class GetGravity(Expression):
    cdef object evaluate_instance(self, Instance instance):
        try:
            return int(instance.currentMovement.gravityAcceleration * 8)
        except AttributeError:
            return 0

cdef class GetDeceleration(Expression):
    cdef object evaluate_instance(self, Instance instance):
        try:
            return instance.currentMovement.decelerationValue
        except AttributeError:
            return 0

cdef class GetAcceleration(Expression):
    cdef object evaluate_instance(self, Instance instance):
        try:
            return instance.currentMovement.accelerationValue
        except AttributeError:
            return 0

cdef class FontName(Expression):
    cdef object evaluate_instance(self, Instance instance):
        return instance.objectPlayer.get_font()[0]
        
cdef class FontSize(Expression):
    cdef object evaluate_instance(self, Instance instance):
        return instance.objectPlayer.get_font()[1]
        
cdef class FontColor(Expression):
    cdef object evaluate_instance(self, Instance instance):
        r, g, b = instance.objectPlayer.get_font()[6]
        return make_color_number(r, g, b)

cdef class AlphaCoefficient(Expression):
    cdef object evaluate_instance(self, Instance instance):
        return int(255 - ((instance.transparency) / 128.0) * 255)

cdef class RGBCoefficient(Expression):
    cdef object evaluate_instance(self, Instance instance):
        if instance.colorCoefficient is None:
            r, g, b = (0, 0, 0)
        else:
            r, g, b = instance.colorCoefficient
        return make_color_number(int(r * 255), int(g * 255), int(b * 255))

cdef class EffectParameter(Expression):
    cdef object evaluate_instance(self, Instance instance):
        name = self.next_argument()
        return instance.inkEffect.parameters[name].value