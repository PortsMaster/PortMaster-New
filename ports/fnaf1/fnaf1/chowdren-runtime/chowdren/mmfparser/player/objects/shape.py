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

import math

from pyglet import graphics
from pyglet.gl import (glPushMatrix, glPushAttrib, GL_STENCIL_BUFFER_BIT, 
    glClear, glTranslatef, glDisable, GL_TEXTURE_2D, glEnable, GL_LINE_SMOOTH,
    glLineWidth, glPointSize, GL_POINTS, GL_LINES, glColorMask, GL_FALSE, 
    GL_TRUE, glStencilFunc, GL_ALWAYS, GL_REPLACE, GL_QUADS, glStencilOp, 
    GL_STENCIL_TEST, GL_EQUAL, GL_TRIANGLES, glPopAttrib, glPopMatrix,
    GL_POINT_SMOOTH)

from pyglet.sprite import Sprite
from pyglet.image import Texture

from mmfparser.player.common import PlayerChild, make_ellipse_vertices

from mmfparser.data.chunkloaders.objects import (LINE_SHAPE,
    RECTANGLE_SHAPE, ELLIPSE_SHAPE, NONE_FILL, SOLID_FILL, GRADIENT_FILL,
    MOTIF_FILL, HORIZONTAL_GRADIENT, VERTICAL_GRADIENT, NONE_OBSTACLE,
    FINE_COLLISION, BOX_COLLISION)

class Shape(PlayerChild):
    loader = None
    vertex = None
    motif_batch = None
    motif_list = None
    motif_stencil = None
    border = None
    counter_stencil = None
    
    color1 = None
    color2 = None
    inverse_gradient = None

    def initialize(self, loader, inverseGradient = False, color1 = None,
                   color2 = None):
        self.loader = loader
        width = self.parent.width
        height = self.parent.height
        x1 = x2 = y1 = y2 = 0
        self.color1 = color1 or loader.color1
        self.color2 = color2 or loader.color2
        self.inverse_gradient = inverseGradient
        if loader.shape == LINE_SHAPE:
            if loader.lineFlags['InverseX']:
                x1 += width
            else:
                x2 += width
            if loader.lineFlags['InverseY']:
                y1 -= height
            else:
                y2 -= height
            
            self.vertex = graphics.vertex_list(2,
                ('v2f', (x1, y1, x2, y2)),
                ('c3B', (loader.borderColor * 2))
                )
        else:
            x2 += width
            y2 -= height
            if loader.fillType == MOTIF_FILL:
                texture = self.parent.make_image_handle(
                    loader.image).create_texture(Texture)
                # texture = Texture(texture_copy.width, texture_copy.height,
                    # texture_copy.target, texture_copy.id)
                texture.anchor_x = 0
                texture.anchor_y = texture.height
            if loader.shape in (RECTANGLE_SHAPE, ELLIPSE_SHAPE):
                if loader.fillType != NONE_FILL:
                    if loader.fillType == SOLID_FILL:
                        colors = (self.color1 + (255,)) * 4
                    elif loader.fillType == GRADIENT_FILL:
                        if inverseGradient:
                            color1 = self.color2 + (255,)
                            color2 = self.color1 + (255,)
                        else:
                            color1 = self.color1 + (255,)
                            color2 = self.color2 + (255,)
                        if loader.gradientFlags == VERTICAL_GRADIENT:
                            colors = (color1 + color2 * 2 + color1)
                        else:
                            colors = color1 * 2 + color2 * 2
                    if loader.fillType == MOTIF_FILL:
                        tex_width = texture.width
                        tex_height = texture.height
                        motif_batch = self.motif_batch = graphics.Batch()
                        motif_list = self.motif_list = []
                        for y in xrange(0, -height, -tex_height):
                            for x in xrange(0, width, tex_width):
                                motif_list.append(Sprite(texture, x = x, y = y, 
                                    batch = motif_batch))
                        if loader.shape == RECTANGLE_SHAPE:
                            self.motif_stencil = graphics.vertex_list(4,
                                ('v2f', (x1, y1, x1, y2, x2, y2, x2, y1)))
                    else:
                        self.vertex = graphics.vertex_list(4,
                            ('v2f', (x1, y1, x1, y2, x2, y2, x2, y1)),
                            ('c4B', colors))
                if loader.shape == RECTANGLE_SHAPE and loader.borderSize > 0:
                    thickness = loader.borderSize
                    self.border = graphics.vertex_list(16, ('v2i', (
                        # top
                        0, 0,
                        width, 0,
                        width, -thickness,
                        0, -thickness,
                        # bottom
                        0, -height + thickness,
                        width, -height + thickness,
                        width, -height,
                        0, -height,
                        # left
                        0, 0,
                        thickness, 0,
                        thickness, -height,
                        0, -height,
                        # right
                        width, 0,
                        width - thickness, 0,
                        width - thickness, -height,
                        width, -height,
                        )), ('c4B', (loader.borderColor + (255,)) * 16))
            if loader.shape == ELLIPSE_SHAPE:
                vertices = make_ellipse_vertices(width, height)
                if loader.fillType != NONE_FILL:
                    fill_vertices = []
                    for i in xrange(len(vertices)-1):
                        fill_vertices += vertices[i]
                        fill_vertices += vertices[i+1]
                        fill_vertices += (width/2,-height/2)
                    self.stencil = graphics.vertex_list(len(fill_vertices) / 2,
                        ('v2f', fill_vertices))
                if loader.borderSize > 0:
                    thickness = loader.borderSize
                    inner_vertices = make_ellipse_vertices(width - thickness * 2,
                        height - thickness * 2)
                    border_vertices = []
                    for i in xrange(len(vertices)-1):
                        border_vertices += vertices[i]
                        border_vertices += vertices[i+1]
                        border_vertices += (inner_vertices[i+1][0] + thickness
                            ), (inner_vertices[i+1][1] - thickness)
                        border_vertices += (inner_vertices[i][0] + thickness
                            ),(inner_vertices[i][1] - thickness)
                    colorTuple = loader.borderColor + (255,)
                    self.border = graphics.vertex_list(
                        len(border_vertices) / 2,
                        ('v2f', border_vertices), 
                        ('c4B', colorTuple * (len(border_vertices) / 2)))
    def draw(self):
        glPushMatrix()
        glPushAttrib(GL_STENCIL_BUFFER_BIT)
        glClear(GL_STENCIL_BUFFER_BIT)
        glTranslatef(self.parent.x, self.parent.y, 0)
        glDisable(GL_TEXTURE_2D)
        loader = self.loader
        if loader.shape == LINE_SHAPE:
            glEnable(GL_LINE_SMOOTH)
            glEnable(GL_POINT_SMOOTH)
            glLineWidth(loader.borderSize)
            glPointSize(loader.borderSize)
            self.vertex.draw(GL_LINES)
            self.vertex.draw(GL_POINTS)
        elif loader.shape == RECTANGLE_SHAPE:
            width = self.parent.width
            height = self.parent.height
            if loader.fillType != NONE_FILL:
                # for counters
                if self.counter_stencil:
                    glEnable(GL_STENCIL_TEST)
                    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE)
                    glStencilFunc(GL_ALWAYS, 1, 1)
                    glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE)
                    self.counter_stencil.draw(GL_QUADS)
                    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE)
                    glStencilFunc(GL_EQUAL, 1, 1)
                    self.draw_rectangle()
                    glDisable(GL_STENCIL_TEST)
                else:
                    self.draw_rectangle()
            if self.border is not None:
                self.border.draw(GL_QUADS)
        elif loader.shape == ELLIPSE_SHAPE:
            if loader.fillType != NONE_FILL:
                glEnable(GL_STENCIL_TEST)
                glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE)
                glStencilFunc(GL_ALWAYS, 1, 1)
                glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE)
                self.stencil.draw(GL_TRIANGLES)
                glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE)
                glStencilFunc(GL_EQUAL, 1, 1)
                self.draw_rectangle(True)
                glDisable(GL_STENCIL_TEST)
            if self.border:
                self.border.draw(GL_QUADS)
        glPopAttrib()
        glPopMatrix()
    
    def set_transparency(self, value):
        alpha_float = value / 128.0
        alpha_byte = int(255 * alpha_float)
        if alpha_byte == 255:
            return
        if self.motif_list is not None:
            for item in self.motif_list:
                item.opacity = alpha_byte
        if self.border is not None:
            self.border.colors = (self.border.colors[:3] + [alpha_byte]) * (
                len(self.border.colors) / 4)
        if self.vertex is not None:
            colors = self.vertex.colors
            for i in xrange(len(colors) / 4):
                colors[i * 4 + 3] = alpha_byte
            self.vertex.colors = colors
    
    def set_offset(self, top, bottom, left, right):
        if not any((top, bottom, left, right)):
            self.counter_stencil = None
            return
        height, width = self.parent.height, self.parent.width
        self.counter_stencil = graphics.vertex_list(4,
            ('v2f', (
            left, -top, left, -height + bottom, width - right, -height + bottom,
            width - right, -top
            )))
    
    def draw_rectangle(self, ellipse = False):
        loader = self.loader
        if loader.fillType == MOTIF_FILL:
            if ellipse:
                self.motif_batch.draw()
            else:
                glEnable(GL_STENCIL_TEST)
                glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE)
                glStencilFunc(GL_ALWAYS, 1, 1)
                glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE)
                self.motif_stencil.draw(GL_QUADS)
                glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE)
                glStencilFunc(GL_EQUAL, 1, 1)
                self.motif_batch.draw()
        else:
            self.vertex.draw(GL_QUADS)