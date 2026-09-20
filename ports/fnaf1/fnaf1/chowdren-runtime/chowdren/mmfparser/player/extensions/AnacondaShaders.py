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
AnacondaShaders.mfx
Anaconda shaders for MMF2
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

from mmfparser.player.common import open_file

from mmfparser.player.shader import Shader

# actions

class PushShader(Action):
    def execute(self, instance):
        vertex = self.evaluate_index(0) or None
        fragment = self.evaluate_index(1) or None
        if vertex is not None:
            try:
                vertex = open_file(vertex, 'rb').read()
            except IOError:
                pass
        if fragment is not None:
            try:
                fragment = open_file(fragment, 'rb').read()
            except IOError:
                pass
        instance.objectPlayer.push(vertex, fragment)

class CreateShader(Action):
    def execute(self, instance):
        name = self.evaluate_index(0)
        instance.objectPlayer.create(name)

class SetShader(Action):
    def execute(self, instance):
        objects = self.get_instances(self.get_parameter(0).objectInfo)
        name = self.evaluate_index(1)
        shader = instance.objectPlayer.shaders[name]
        instance.objectPlayer.lastShader = name
        for object in objects:
            object.set_effect('shaders', shader)

class SetUniformFloat(Action):
    def execute(self, instance):
        name = self.evaluate_index(0)
        uniform = self.evaluate_index(1)
        value = self.evaluate_index(2)
        shader = instance.objectPlayer.shaders[name]
        for item in shader:
            item.bind()
            item.uniformf(uniform, value)
        Shader.unbind()

class SetUniformInteger(Action):
    def execute(self, instance):
        name = self.evaluate_index(0)
        uniform = self.evaluate_index(1)
        value = int(self.evaluate_index(2))
        shaders = instance.objectPlayer.shaders[name]
        for item in shaders:
            item.bind()
            item.uniformi(uniform, value)
        Shader.unbind()

class ClearShader(Action):
    def execute(self, instance):
        objects = self.get_instances(self.get_parameter(0).objectInfo)
        for object in objects:
            object.set_effect(None)

# expressions

class GetShaderCount(Expression):
    def get(self, instance):
        return len(instance.objectPlayer.shaders)

class GetLastShaderName(Expression):
    def get(self, instance):
        return instance.objectPlayer.lastShader

# vertex stuff

class GetVertexString(Expression):
    def get(self, instance):
        name = self.next_argument()
        stack = self.next_argument()
        shaders = instance.objectPlayer.shaders[name]
        return shaders[stack].vert[0]

class GetVertexLineCount(Expression):
    def get(self, instance):
        name = self.next_argument()
        stack = self.next_argument()
        shaders = instance.objectPlayer.shaders[name]
        return shaders[stack].vert[0].count('\n')

class GetVertexLine(Expression):
    def get(self, instance):
        name = self.next_argument()
        stack = self.next_argument()
        index = self.next_argument()
        shaders = instance.objectPlayer.shaders[name]
        return shaders[stack].vert[0].splitlines()[index]

# fragment stuff

class GetFragmentString(Expression):
    def get(self, instance):
        name = self.next_argument()
        stack = self.next_argument()
        shaders = instance.objectPlayer.shaders[name]
        return shaders[stack].frag[0]

class GetFragmentLineCount(Expression):
    def get(self, instance):
        name = self.next_argument()
        stack = self.next_argument()
        shaders = instance.objectPlayer.shaders[name]
        return shaders[stack].frag[0].count('\n')

class GetFragmentLine(Expression):
    def get(self, instance):
        name = self.next_argument()
        stack = self.next_argument()
        index = self.next_argument()
        shaders = instance.objectPlayer.shaders[name]
        return shaders[stack].frag[0].splitlines()[index]

class DefaultObject(HiddenObject):
    shaders = None
    stack = None
    lastShader = ''
    def created(self, data):
        self.shaders = {}
        self.stack = []
    
    def push(self, vertex, fragment):
        if vertex is None:
            vertex = []
        else:
            vertex = [vertex]
        if fragment is None:
            fragment = []
        else:
            fragment = [fragment]
        shader = Shader(vertex, fragment)
        shader.initialize()
        self.stack.append(shader)
    
    def create(self, name):
        self.shaders[name] = self.stack
        self.stack = []

class Shaders(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : PushShader,
        1 : CreateShader,
        2 : SetShader,
        3 : SetUniformFloat,
        4 : SetUniformInteger,
        5 : ClearShader
    }
    
    conditions = {
    }
    
    expressions = {
        0 : GetShaderCount,
        1 : GetLastShaderName,
        2 : GetVertexString,
        3 : GetVertexLineCount,
        4 : GetVertexLine,
        5 : GetFragmentString,
        6 : GetFragmentLineCount,
        7 : GetFragmentLine,
    }

extension = Shaders()

def get_extension():
    return extension
