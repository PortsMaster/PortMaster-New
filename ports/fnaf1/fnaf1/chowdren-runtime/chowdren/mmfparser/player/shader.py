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

from pyglet.gl import *
from ctypes import *
import time
from pyglet.image import Texture

class CompileError(SystemExit):
    pass

class Shader(object):
    initialized = False
    def __init__(self, vert = [], frag = []):
        self.vert = vert
        self.frag = frag
    
    def initialize(self):
        self.start = time.time()
        self.handle = glCreateProgram()
        self.linked = False
        
        for item in self.vert:
            self.create_shader(item, GL_VERTEX_SHADER)
        
        for item in self.frag:
            self.create_shader(item, GL_FRAGMENT_SHADER)

        self.link()
        self.initialized = True

    def create_shader(self, item, type):
        # create the shader handle
        shader = glCreateShader(type)

        # convert the source strings into a ctypes pointer-to-char array, and upload them
        # this is deep, dark, dangerous black magick - don't try stuff like this at home!
        src = (c_char_p * 1)(item)
        glShaderSource(shader, 1, cast(pointer(src), POINTER(POINTER(c_char))), None)

        # compile the shader
        glCompileShader(shader)

        temp = c_int(0)
        # retrieve the compile status
        glGetShaderiv(shader, GL_COMPILE_STATUS, byref(temp))

        # if compilation failed, print the log
        if not temp:
            # retrieve the log length
            glGetShaderiv(shader, GL_INFO_LOG_LENGTH, byref(temp))
            # create a buffer for the log
            buffer = create_string_buffer(temp.value)
            # retrieve the log text
            glGetShaderInfoLog(shader, temp, None, buffer)
            # print the log to the console
            print 'Shader error: %s' % buffer.value
        else:
            # all is well, so attach the shader to the program
            glAttachShader(self.handle, shader);

    def link(self):
        # link the program
        glLinkProgram(self.handle)

        temp = c_int(0)
        # retrieve the link status
        glGetProgramiv(self.handle, GL_LINK_STATUS, byref(temp))

        # if linking failed, print the log
        if not temp:
            #	retrieve the log length
            glGetProgramiv(self.handle, GL_INFO_LOG_LENGTH, byref(temp))
            # create a buffer for the log
            buffer = create_string_buffer(temp.value)
            # retrieve the log text
            glGetProgramInfoLog(self.handle, temp, None, buffer)
            # print the log to the console
            raise CompileError(buffer.value)
        else:
            # all is well, so we are linked
            self.linked = True

    def bind(self, size = None):
        if not self.initialized:
            self.initialize()
        glUseProgram(self.handle)
        self.uniformi('texture', 0)
        self.uniformi('background_texture', 1)
        if size is not None:
            w, h = size
            self.uniformf('texture_size', w, h)
    
    @staticmethod
    def unbind():
        glUseProgram(0)

    # upload a floating point uniform
    # this program must be currently bound
    def uniformf(self, name, *vals):
        # check there are 1-4 values
        if len(vals) in range(1, 5):
            loc = glGetUniformLocation(self.handle, name)
            # select the correct function
            { 1 : glUniform1f,
                2 : glUniform2f,
                3 : glUniform3f,
                4 : glUniform4f
                # retrieve the uniform location, and set
            }[len(vals)](loc, *vals)

    # upload an integer uniform
    # this program must be currently bound
    def uniformi(self, name, *vals):
        # check there are 1-4 values
        if len(vals) in range(1, 5):
            loc = glGetUniformLocation(self.handle, name)
            # select the correct function
            { 
                1 : glUniform1i,
                2 : glUniform2i,
                3 : glUniform3i,
                4 : glUniform4i
            }[len(vals)](loc, *vals)
            
    def uniform_vec2(self, name, mat):
        # obtian the uniform location
        loc = glGetUniformLocation(self.handle, name)
        glUniformMatrix2fv(loc, 1, False, (c_float * 4)(*mat))

    def uniform_vec3(self, name, mat):
        # obtian the uniform location
        loc = glGetUniformLocation(self.handle, name)
        glUniformMatrix3fv(loc, 1, False, (c_float * 9)(*mat))
        
    def uniform_vec4(self, name, mat):
        # obtian the uniform location
        loc = glGetUniformLocation(self.handle, name)
        glUniformMatrix4fv(loc, 1, False, (c_float * 16)(*mat))