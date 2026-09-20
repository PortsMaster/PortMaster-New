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
from ctypes import byref
from pyglet.image import Texture
import pyglet
_debug_gl = pyglet.options['debug_gl']

fbo_stack = [(0, None)]

_has_packed_ext = None

fbo_textures = {}
screen_textures = {}

def nearest_pow2(v):
    v -= 1
    v |= v >> 1
    v |= v >> 2
    v |= v >> 4
    v |= v >> 8
    v |= v >> 16
    return v + 1

class FBO(object):
    fbo = None
    real_texture = None
    texture = None
    renderbuffer = None
    size = None

    def __init__(self, screen = False):
        global _has_packed_ext
        if _has_packed_ext is None:
            _has_packed_ext = gl_info.have_extension(
                'GL_EXT_packed_depth_stencil')
            if not _has_packed_ext:
                print 'GL_EXT_packed_depth_stencil not supported - ',
                print 'artifacts may appear'
        fbo = GLuint()
        glGenFramebuffersEXT(1, byref(fbo))
        self.fbo = fbo
        self.screen = screen
        if self.screen:
            self.cache = screen_textures
        else:
            self.cache = fbo_textures
        if screen and _has_packed_ext:
            self.renderbuffer = GLuint()
            glGenRenderbuffersEXT(1, byref(self.renderbuffer))
        
    def start(self, w, h):
        # set up viewport
        glPushAttrib(GL_VIEWPORT_BIT | GL_TRANSFORM_BIT | GL_SCISSOR_BIT)
        glViewport(0, 0, w, h)
        glMatrixMode(GL_PROJECTION)
        glPushMatrix()
        glLoadIdentity()
        glOrtho(0, w, 0, h, -1, 1)
        glMatrixMode(GL_MODELVIEW)
        
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, self.fbo)
    
        size = (w, h)
        size_updated = self.size != size
        self.size = size
        
        if self.texture is None or size_updated:
            self.clear_texture()
                
        if self.renderbuffer and size_updated:
            n_w = nearest_pow2(w)
            n_h = nearest_pow2(h)
            id = self.renderbuffer.value
            glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, id)
            glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT,
                GL_DEPTH_STENCIL_EXT, n_w, n_h)
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT,
                GL_STENCIL_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, id)
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT,
                GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, id)
        
        if _debug_gl:
            result = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT)
            if result != GL_FRAMEBUFFER_COMPLETE_EXT:
                print 'framebuffer incomplete:', result
        
        glDisable(GL_SCISSOR_TEST)
        glClearColor(0.0, 0.0, 0.0, 0.0)
        glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
        glEnable(GL_SCISSOR_TEST)
        glScissor(0, 0, w, h)
        fbo_stack.append((self.fbo, self.texture))
    
    def clear_texture(self):
        w, h = self.size
        n_w = nearest_pow2(w)
        n_h = nearest_pow2(h)
        key = (n_w, n_h)
        tex = self.cache.pop(key, None)
        if tex is None:
            tex = Texture.create(n_w, n_h, GL_RGBA)
            tex.key = key
        tex = tex.get_region(0, 0, w, h)
        self.texture = tex
        glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,
            GL_COLOR_ATTACHMENT0_EXT, tex.target, tex.id, 0)
    
    def end(self):
        tex = self.texture.owner
        self.cache[tex.key] = tex
        fbo_stack.pop()
        fbo, tex = fbo_stack[-1]
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo)
        if tex is not None:
            glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,
                GL_COLOR_ATTACHMENT0_EXT, tex.target, tex.id, 0)

        glMatrixMode(GL_PROJECTION)
        glPopMatrix()
        glPopAttrib()
        return self.texture

GLOBAL_FBO = None

def get_fbo():
    global GLOBAL_FBO
    if GLOBAL_FBO is None:
        GLOBAL_FBO = FBO()
    return GLOBAL_FBO