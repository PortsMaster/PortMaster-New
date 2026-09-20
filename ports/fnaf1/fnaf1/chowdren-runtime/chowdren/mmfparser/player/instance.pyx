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

cdef extern from "math.h":
    bint isnan(double x)
    double NAN

cimport cython

from mmfparser.player.collision cimport collides
from mmfparser.data.chunkloaders.frame import NONE_PARENT
from mmfparser.player.movements import make_direction
from mmfparser.player.common import get_color_number

from mmfparser.player.objects.all import (QuickBackdrop, Backdrop, Active,
    Text, Counter, Scores, Lives, SubApplication, Question)
    
from mmfparser.data.chunkloaders.objectinfo import (QUICKBACKDROP, BACKDROP,
    ACTIVE, TEXT, COUNTER, SCORE, LIVES, SUBAPPLICATION, EXTENSION_BASE, 
    NONE_EFFECT, SEMITRANSPARENT_EFFECT, INVERTED_EFFECT, XOR_EFFECT, 
    AND_EFFECT, OR_EFFECT, MONOCHROME_EFFECT, ADD_EFFECT, SUBTRACT_EFFECT,
    HWA_EFFECT, SHADER_EFFECT, QUESTION)

from mmfparser.data.chunkloaders.shaders import INT, FLOAT, INT_FLOAT4, IMAGE

from pyglet.gl import (glTexEnvi, GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE,
    GL_COMBINE, GL_SRC0_RGB, GL_TEXTURE, GL_OPERAND0_RGB, GL_ONE_MINUS_SRC_COLOR,
    GL_COMBINE_RGB, GL_REPLACE, glLogicOp, glEnable, GL_COLOR_LOGIC_OP,
    GL_XOR, GL_AND, GL_OR, glColorMask, glBlendFunc, GL_SRC_ALPHA, GL_MODULATE,
    GL_ONE, GL_FUNC_REVERSE_SUBTRACT, glDisable, GL_ONE_MINUS_SRC_ALPHA,
    glBlendEquation, GL_FUNC_ADD, glUseProgram, glBlendEquationSeparate,
    GL_FUNC_SUBTRACT, GL_DST_COLOR)

from mmfparser.player.shaders import MONOCHROME_SHADER, load_shader

cdef int XBORDER = 480
cdef int YBORDER = 300

cdef dict MOVEMENT_PLAYERS = None
cdef inline void initialize_movements():
    if MOVEMENT_PLAYERS is None:
        global MOVEMENT_PLAYERS
        from mmfparser.player.movements.all import MOVEMENT_PLAYERS

cdef double nan = float('nan')

cdef class InkEffect:
    def __init__(self, effect, parameter = None):
        self.effect = effect
        if effect == 'shaders':
            self.shaders = parameter
    
    cdef void begin(self):
        if self.shaders is not None:
            if self.parameters:
                shader = self.shaders[0]
                shader.bind()
                for parameter in self.parameters.values():
                    type = parameter.type
                    value = parameter.value
                    name = parameter.name
                    if value is None:
                        continue
                    if type == INT:
                        shader.uniformi(name, value)
                    elif type == FLOAT:
                        shader.uniformf(name, value)
                    elif type == INT_FLOAT4:
                        if not isinstance(value, tuple):
                            # print 'invalid parameter:', type, value, name
                            continue
                        shader.uniformf(name, *value)
                    elif type == IMAGE:
                        continue
                shader.unbind()
            return
        elif self.effect in (NONE_EFFECT, SEMITRANSPARENT_EFFECT):
            return
        elif self.effect == INVERTED_EFFECT:
            glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE)
            glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_TEXTURE)
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_ONE_MINUS_SRC_COLOR)
            glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_REPLACE)
        elif self.effect in (XOR_EFFECT, AND_EFFECT, OR_EFFECT):
            glEnable(GL_COLOR_LOGIC_OP)
            if self.effect == XOR_EFFECT:
                glLogicOp(GL_XOR)
            elif self.effect == AND_EFFECT:
                glColorMask(True, True, True, False)
                glLogicOp(GL_AND)
            elif self.effect == OR_EFFECT:
                glLogicOp(GL_OR)
        elif self.effect in (ADD_EFFECT, SUBTRACT_EFFECT):
            if self.effect == ADD_EFFECT:
                glBlendFunc(GL_SRC_ALPHA, GL_ONE)
            elif self.effect == SUBTRACT_EFFECT:
                glBlendEquationSeparate(GL_FUNC_REVERSE_SUBTRACT, GL_FUNC_ADD)
                glBlendFunc(GL_DST_COLOR, GL_ONE)
    
    cdef void end(self):
        if self.shaders is not None:
            return
        elif self.effect in (NONE_EFFECT, SEMITRANSPARENT_EFFECT):
            return
        elif self.effect == INVERTED_EFFECT:
            glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE)
        elif self.effect in (XOR_EFFECT, AND_EFFECT, OR_EFFECT):
            glDisable(GL_COLOR_LOGIC_OP)
        elif self.effect in (ADD_EFFECT, SUBTRACT_EFFECT):
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
            glBlendEquation(GL_FUNC_ADD)

OBJECT_PLAYERS = {
    QUICKBACKDROP : QuickBackdrop,
    BACKDROP : Backdrop,
    ACTIVE : Active,
    TEXT : Text,
    COUNTER : Counter,
    SCORE: Scores,
    LIVES : Lives,
    SUBAPPLICATION : SubApplication,
    QUESTION : Question
}

cdef int get_leaving_corners(Frame frame, int x1, int y1, int x2, int y2):
    cdef int leaving = 0
    if x1 < 0:
        leaving |= 4
    if y1 < 0:
        leaving |= 1
    if x2 > frame.virtualWidth:
        leaving |= 8
    if y2 > frame.virtualHeight:
        leaving |= 2
    return leaving

cdef int get_entering_corners(Frame frame, int x1, int y1, int x2, int y2):
    cdef int entering = 15
    if x1 < frame.virtualWidth:
        entering &= ~8
    if y1 < frame.virtualHeight:
        entering &= ~2
    if x2 > 0:
        entering &= ~4
    if y2 > 0:
        entering &= ~1
    return entering

cdef inline void update_player_position(Instance self):
    cdef BaseObject objectPlayer = self.objectPlayer
    cdef double glX, glY
    self.player.get_window_coordinates(self.x, self.y, &glX, &glY)

    if glX != objectPlayer.x or glY != objectPlayer.y:
        objectPlayer.x = glX
        objectPlayer.y = glY
        objectPlayer.set_position(glX, glY)

@cython.final
cdef class Instance(PlayerChild):
    def initialize(self, objectInstance, int layer = -1):
        initialize_movements()

        self.transparency = 128
        self.visible = self.scroll = True
        self.frame = self.parent
        self.handle = objectInstance.objectInfo
        # print 'reading object instance %s' % objectInstance.handle
        self.objectInstance = objectInstance
        self.objectInfo = item = objectInstance.getObjectInfo(
            self.player.gameData.frameItems)
        # print '(objectinfo: %s, name: %r)' % (self.objectInfo.handle,
        #    self.objectInfo.name)
        
        objectType = self.objectType = item.properties.getType()
        
        cdef bint isCommon = item.properties.isCommon
        
        loader = self.loader = item.properties.loader
        
        if objectType == EXTENSION_BASE:
            extension = self.player.get_extension(item)
            if extension is None:
                self.destroyed = True
                return
            objectClass = extension.objectPlayer
        else:
            objectClass = OBJECT_PLAYERS[objectType]
        
        self.objectPlayer = self.new(objectClass)
        self.objectPlayer.initialize(loader, self.frame.loader)

        if self.destroyed:
            return

        if item.shaderId is not None:
            inkEffect = SHADER_EFFECT
        else:
            inkEffect = item.inkEffect
        self.set_effect(inkEffect, item.inkEffectValue)
        
        self.x = self.y = nan
        
        if objectInstance.parentType == NONE_PARENT:
            self.set_position(objectInstance.x, objectInstance.y)
        
        if isCommon:
            if loader.flags['ManualSleep']:
                if not loader.flags['NeverSleep']:
                    self.sleep = True
            elif self.objectType == ACTIVE and not loader.flags['NeverKill']:
                self.outsideKill = True
                
            if loader.flags['ScrollingIndependant']:
                self.scroll = False

            if self.alterables is None and loader.flags['Values']:
                self.alterables = Alterables(loader.values, loader.strings)
            
            if loader.movements:
                self.movementPlayers = movementPlayers = []
                for movement in loader.movements.items:
                    movementName = movement.getName()
                    movementClass = None
                    try:
                        if movementName == 'Extension':
                            movementName = movement.loader.name
                            movementClass = self.player.get_movement(
                                movement.loader)
                        else:
                            movementClass = MOVEMENT_PLAYERS[movementName]
                    except KeyError:
                        pass
                    if movementClass is None:
                        print 'movement %s not implemented' % movementName
                        movementClass = MOVEMENT_PLAYERS['Static']
                    newMovement = self.new(movementClass)
                    newMovement.initialize(movement)
                    movementPlayers.append(newMovement)
                
                currentMovement = movementPlayers[0]
                self.movementIndex = 0
                self.currentMovement = currentMovement
                if not currentMovement.isStatic:
                    self.currentMovement.ready()
        
        if self.movementPlayers and not self.currentMovement.isStatic:
            self.movementEnabled = True
        
        if layer == -1:
            layer = objectInstance.layer

        self.set_layer(layer)
        # print 'created instance', self.objectInfo.name
    
    def set_movement(self, value):
        try:
            movement = self.movementPlayers[value]
        except IndexError:
            return
        oldMovement = self.currentMovement
        self.movementIndex = value
        self.currentMovement = movement
        self.movementEnabled = not self.currentMovement.isStatic
        self.currentMovement.set_speed(0)
        self.currentMovement.created()
        self.currentMovement.set_direction(oldMovement.direction)

    cdef void update(self):
        cdef double glX, glY
        if (self.currentMovement is not None and self.updateEnabled and 
        not (self.sleep and not self.inside_window(-50, -50)) and 
        not self.destroying):
            self.currentMovement.update()

        if self.positionChanged:
            self.positionChanged = False
            if self.outsideKill:
                if (not self.in_playfield(-XBORDER - self.objectPlayer.width, 
                -YBORDER - self.objectPlayer.height) and not (
                self.handle in self.player.frame.noSleepHandles)):
                    self.destroy(True)

            mouse = self.player.mouse
            if self.handle in mouse.enabledInstances:
                mouse.update_over(self)
        
        if not self.destroyed and self.objectPlayer.updateEnabled:
            self.objectPlayer.update()
    
    cdef void update_playfield(self):
        cdef bint up, down, left, right
        cdef int leaving_corners, entering_corners
        leaving_corners = self.get_leaving_corners()
        entering_corners = self.get_entering_corners()
        cdef BaseObject objectPlayer = self.objectPlayer
        cdef Frame frame = self.frame
        # wrapping
        if leaving_corners:
            self.fire_handler('leaving_playfield')

        if entering_corners:
            self.fire_handler('entering_playfield')
        cdef double x, y
        if self.wrap and self.outside_playfield():
            x = self.x
            y = self.y
            up, down, left, right = self.get_outside_corners()
            if self.wrapUp and up:
                y = frame.virtualHeight - objectPlayer.height + objectPlayer.hotspotY
            if self.wrapDown and down:
                y = objectPlayer.hotspotY
            if self.wrapLeft and left:
                x = frame.virtualWidth - objectPlayer.width + objectPlayer.hotspotX
            if self.wrapRight and right:
                x = objectPlayer.hotspotX
            self.set_position(x, y)
    
    cdef void update_bounding_box(self):
        cdef int x, y
        cdef int width, height
        x = <int>self.x
        y = <int>self.y
        width = self.objectPlayer.width
        height = self.objectPlayer.height
        self.x1 = <int>(x - (self.objectPlayer.hotspotX))
        self.y1 = <int>(y - (self.objectPlayer.hotspotY))
        self.x2 = self.x1 + width
        self.y2 = self.y1 + height
    
    cpdef set_position(self, double x, double y, bint fromAction = False):
        if x == self.x and y == self.y:
            return
        self.x = x
        self.y = y
        self.positionChanged = True
        self.update_bounding_box()
        update_player_position(self)
        if fromAction and self.currentMovement:
            self.collisionSet = False
            self.currentMovement.breakMovement = True
    
    cpdef object_changed(self):
        if self.layer is None: # are we initialized yet?
            return
        self.update_bounding_box()
    
    cpdef update_collisions(self, list instances):
        cdef bint looping = self.player.eventPlayer.looping
        if self.currentMovement:
            self.currentMovement.update_collisions(set(instances))
    
    cpdef set_direction(self, int direction, bint force = True):
        direction = direction % 32
        self.direction = direction
        self.objectPlayer.set_direction(direction, force)
        if (self.movementEnabled
        and self.currentMovement.direction != direction):
            self.currentMovement.set_direction(direction)
    
    cpdef inline int get_direction(self):
        return self.direction
    
    cpdef inline bint is_leaving(self):
        return (self.y1 < 0 or
            self.y2 > self.frame.virtualHeight or
            self.x1 < 0 or
            self.x2 > self.frame.virtualWidth)
        
    cpdef inline bint outside_playfield(self):
        cdef int x1, y1, x2, y2
        cdef bint outsideY, outsideX
        x1, y1, x2, y2 = self.x1, self.y1, self.x2, self.y2
        outsideY = y1 > self.frame.virtualHeight or y2 < 0
        outsideX = x1 > self.frame.virtualWidth or x2 < 0
        return outsideX or outsideY
    
    cpdef int get_leaving_corners(self):
        cdef int first = get_leaving_corners(self.player.frame, self.x1, 
            self.y1, self.x2, self.y2)
        cdef int second = get_leaving_corners(self.player.frame,
            self.oldX1, self.oldY1, self.oldX2, self.oldY2)
        return (~second & first)

    cpdef int get_entering_corners(self):
        cdef int second
        cdef int first = get_entering_corners(self.player.frame,
            self.oldX1, self.oldY1, self.oldX2, self.oldY2)
        if first != 0:
            second = get_entering_corners(self.player.frame, self.x1, 
                self.y1, self.x2, self.y2)
            if second == 0:
                return second ^ first
        return 0
    
    cpdef inline tuple get_outside_corners(self):
        cdef int x1, y1, x2, y2
        cdef bint outsideDown, outsideUp, outsideRight, outsideLeft
        x1, y1, x2, y2 = self.x1, self.y1, self.x2, self.y2

        outsideDown = y1 > self.frame.virtualHeight 
        outsideUp = y2 < 0

        outsideRight = x1 > self.frame.virtualWidth 
        outsideLeft = x2 < 0
        return (outsideUp, outsideDown, outsideLeft, outsideRight)

    cpdef inline bint in_playfield(self, int x_border = 0, int y_border = 0):
        return self.inside_zone(x_border, y_border, 
            self.frame.virtualWidth - x_border, 
            self.frame.virtualHeight - y_border)
    
    cpdef inline bint inside_window(self, int x_border = 0, int y_border = 0):
        cdef int x1, y1, x2, y2
        x1 = self.player.x1 + x_border
        x2 = self.player.x2 - x_border
        y1 = self.player.y1 + y_border
        y2 = self.player.y2 - y_border
        return self.inside_zone(x1, y1, x2, y2)
    
    cpdef inline bint inside_zone(self, int xZone, int yZone, int xZone2, 
                              int yZone2):
        cdef int x1, y1, x2, y2
        cdef bint insideY, insideX
        x1, y1, x2, y2 = self.x1, self.y1, self.x2, self.y2
        insideY = y2 <= yZone2 and y1 >= yZone
        insideX = x2 <= xZone2 and x1 >= xZone
        return insideX and insideY
    
    cpdef inline bint in_zone(self, int xZone, int yZone, int xZone2, 
                              int yZone2):
        return collides(<int>self.x, <int>self.y, <int>self.x, <int>self.y,
            xZone, yZone, xZone2, yZone2)
        
    cpdef inline bint mouse_over(self):
        return self in self.player.mouse.over
    
    def fire_handler(self, name, *args):
        self.frame.fire_handler(self, name, *args)
        
    def set_transparency(self, value):
        value = max(0, min(128, value))
        self.transparency = value
        self.objectPlayer.set_transparency(value)
    
    def set_effect(self, effect, parameter = None):
        self.inkEffect = None
        try:
            if effect == SHADER_EFFECT or effect & HWA_EFFECT:
                b, g, r = get_color_number(parameter)
                self.colorCoefficient = (r / 255.0, g / 255.0, b / 255.0)
                alpha = (parameter & 0xFF000000) >> 24
                self.set_transparency((alpha / 255.0) * 128.0)
                effect &= ~HWA_EFFECT
        except TypeError:
            pass
        if effect in (SHADER_EFFECT, MONOCHROME_EFFECT, 'shader'):
            parameters = None
            if effect in (SHADER_EFFECT, 'shader'):
                shaderData = None
                if effect == SHADER_EFFECT:
                    shaderData = self.player.gameData.shaders.items[
                        self.objectInfo.shaderId]
                else:
                    try:
                        shaderData = self.player.gameData.shaders.names[
                            parameter]
                    except AttributeError:
                        print parameter, 'could not be loaded'
                        return
                shader = load_shader(shaderData.name)
                if not shader:
                    print shaderData.name, 'could not be loaded'
                    return
                parameters = shaderData.get_parameters()
                if effect == SHADER_EFFECT:
                    values = self.objectInfo.items
                    for index, parameter in enumerate(shaderData.parameters):
                        reader = values[index]
                        reader.seek(0)
                        if parameter.type == INT:
                            value = reader.readInt()
                        elif parameter.type == FLOAT:
                            value = reader.readFloat()
                        elif parameter.type == INT_FLOAT4:
                            value = (reader.readByte(True) / 255.0, 
                                reader.readByte(True) / 255.0,
                                reader.readByte(True) / 255.0, 
                                reader.readByte(True) / 255.0)
                        else:
                            raise NotImplementedError
                        parameters[parameter.name].value = value
            elif effect == MONOCHROME_EFFECT:
                shader = MONOCHROME_SHADER
            self.inkEffect = InkEffect('shaders', shader)
            self.inkEffect.parameters = parameters
            return
            
        if effect not in (NONE_EFFECT, SEMITRANSPARENT_EFFECT, HWA_EFFECT, None):
            self.inkEffect = InkEffect(effect, parameter)

        if effect == SEMITRANSPARENT_EFFECT:
            self.set_transparency(128 - parameter)
    
    def set_effect_name(self, name, parameters = None):
        if name == 'Sub':
            self.set_effect(SUBTRACT_EFFECT)
        elif name == 'Add':
            self.set_effect(ADD_EFFECT)
        elif name == 'Blend':
            self.set_effect(SEMITRANSPARENT_EFFECT, 0)
        elif name == '':
            self.set_effect(NONE_EFFECT)
        else:
            self.set_effect('shader', name)
    
    def set_visible(self, value):
        self.flash(False)
        self.visible = value
    
    def set_layer(self, index):
        if self.layer is None:
            index = max(0, min(index, len(self.frame.layers) - 1))
        try:
            layer = self.frame.layers[index]
        except IndexError:
            return
        if self.layer is not None:
            self.layer.remove(self)
        self.layerIndex = index
        self.layer = layer
        layer.add(self, self.loader.isBackground())
    
    def set_speed(self, speed):
        cdef MovementPlayer movement
        if self.movementEnabled:
            movement = self.currentMovement
            movement.set_speed(speed)
            self.objectPlayer.update_animation_speed()
        
    def stop(self, colliding = False):
        if not colliding:
            self.objectPlayer.stop()
        if self.movementEnabled:
            self.currentMovement.stop(colliding)
    
    def bounce(self):
        self.objectPlayer.stop()
        if self.movementEnabled:
            self.currentMovement.bounce()
    
    def flash(self, interval, startVisible = False):
        if interval is False:
            self.player.clock.unschedule(self.on_flash)
            self.flashing = False
        else:
            self.player.clock.unschedule(self.on_flash)
            self.player.clock.schedule_interval(self.on_flash, interval)
            if not startVisible:
                self.flashing = True
        
    def on_flash(self, sinceLast = None):
        self.flashing = not self.flashing
    
    def destroy(self, forced = False):
        if self.destroyed:
            return
        self.destroying = True
        if not forced and not self.objectPlayer.destroy():
            return
        self.frame.destroy_instance(self)
        self.layer.remove(self)
        self.detach()
    
    cpdef on_detach(self):
        self.destroyed = True
        self.flash(False)
    
    cdef void draw(self):
        if not self.visible or self.flashing:
            return
        cdef Layer layer = self.layer
        if ((layer.wrapX or layer.wrapY) and self.objectType in (QUICKBACKDROP,
        BACKDROP)) or collides(self.x1, self.y1, self.x2, self.y2, 
        self.player.x1, self.player.y1, self.player.x2, self.player.y2):
                if self.inkEffect is not None:
                    self.inkEffect.begin()
                self.objectPlayer.draw()
                if self.inkEffect is not None:
                    self.inkEffect.end()