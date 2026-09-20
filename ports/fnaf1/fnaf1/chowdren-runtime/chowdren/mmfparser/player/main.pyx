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

DEF PROFILE = 0
DEF PROFILE_LOAD = 0

import time
import os
import sys

from mmfparser.data.chunkloaders import objects
from mmfparser.player.fullscreen import FixedResolutionViewport
from mmfparser.player.media import MediaPlayer
from mmfparser.player.players import Players
from mmfparser.player.event.player cimport EventPlayer
from mmfparser.player.alterables cimport Globals
from mmfparser.player.files import FileManager
from mmfparser.player.sprite import Sprite, CreatedFrame
from mmfparser.player.mouse import Mouse
from mmfparser.player.extensions import get_extension, get_movement
from mmfparser.player.frame cimport Frame, Layer
from mmfparser.player.instance cimport Instance
from mmfparser.player.collision cimport intersect
from mmfparser.player.common cimport replace_color
from mmfparser.player.common import make_image
from mmfparser.player.fbo import FBO

import pyglet
from pyglet.window import key
from pyglet.window.key import user_key
from pyglet.text import Label
from mmfparser.player.win32.winkey import keymap
from pyglet.gl import (GLint, glGetIntegerv, glClearColor, 
    GL_SCISSOR_BOX, glLoadIdentity, glClear, GL_COLOR_BUFFER_BIT, 
    GL_DEPTH_BUFFER_BIT, glTranslatef, glEnable,
    GL_SCISSOR_TEST, glDisable, Config, glClear, glColor4f, glBlendFunc,
    GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, glTexEnvf, GL_TEXTURE_ENV,
    GL_TEXTURE_ENV_MODE, GL_MODULATE, GL_BLEND, glPushMatrix, glPopMatrix,
    glPushAttrib, glPopAttrib, glViewport, glMatrixMode, GL_PROJECTION,
    glOrtho, GL_MODELVIEW)
    
try:
    pyglet.font.add_directory('fonts')
except OSError:
    pass

# monkey patch so there's no forced redrawing
from pyglet.app.base import EventLoop
def idle(self):
    dt = self.clock.update_time()
    self.clock.call_scheduled_functions(dt)
    sleep_time = self.clock.get_sleep_time(True)
    return sleep_time
import types
EventLoop.idle = types.UnboundMethodType(idle, None, EventLoop)

# twisted/internet features
import pygletreactor
pygletreactor.install()
from twisted.internet import reactor

    
cdef bint DEBUG = not hasattr(sys, 'frozen')
cdef bint SHOW_FPS = os.getenv('ANACONDA_SHOW_FPS', None) is not None or DEBUG

cdef int SLEEP_XBORDER = 64
cdef int SLEEP_YBORDER = 16

class Keyboard(dict):
    def attach(self, window):
        window.push_handlers(
            on_key_press = self.on_key_press,
            on_key_release = self.on_key_release
        )
        
    def convert(self, vk):
        try:
            return keymap[vk]
        except KeyError:
            return None
            
    def on_key_press(self, symbol, modifiers):
        self[symbol] = True
        
    def on_key_release(self, symbol, modifiers):
        self[symbol] = False
        
    def __getitem__(self, key):
        return self.get(key, False)

from pyglet import clock

class Window(pyglet.window.Window):
    def get_mouse_visible(self):
        return self._mouse_visible and not self._mouse_exclusive
    
    def on_key_press(self, button, modifiers):
        return
    
    def on_close(self):
        return
    
    def on_resize(self, width, height):
        return

cdef class GamePlayer:
    def __init__(self, gameData, PlayerChild parent = None):
        # self.debug = {'draw' : True, 'clock' : True, 'events' : True}
        self.parent = parent
        self.gameData = gameData

        data = self.gameData
        self.frameHandles = data.frameHandles
        header = data.header
        extendedHeader = data.extendedHeader
        if parent is None:
            height = header.windowHeight
            width = header.windowWidth
        else:
            width = parent.width
            height = parent.height
        self.height = height
        self.width = width
        
        self.time = 0

        self.clock = Clock(self)
        
        self.media = self.new(MediaPlayer)
        self.media.initialize()
        
        if parent is not None and parent.options['ShareGlobals']:
            self.globals = parent.player.globals
        else:
            self.globals = Globals(gameData.globalValues, 
                gameData.globalStrings)
        
        self.extensions = {}
        self.extensionStorage = {}

        self.files = self.new(FileManager)
        self.files.initialize()
        
        self.borderColor = header.borderColor
        
        if parent is None:
            config = Config(double_buffer = True)
            self.window = Window(height = height, width = width, 
                resizable = not header.newFlags['NoThickFrame'],
                visible = False, config = config, 
                vsync = header.newFlags['VSync'])
            self.window.invalid = False
            self.window.set_vsync(header.newFlags['VSync'])
            # set up the window
            caption = gameData.name or 'Anaconda runtime'
            self.window.set_caption(caption.decode('windows-1252'))
            IF UNAME_SYSNAME != "Darwin":
                if data.icon:
                    self.window.set_icon(data.icon.createDisplay())
            IF UNAME_SYSNAME == "Windows":
                # resolve WGL dependencies
                pyglet.gl.glMultiTexCoord2f.resolve()
        else:
            self.window = parent.player.window
        
        # keyboard
        self.keyboard = Keyboard()
        
        # mouse
        self.mouse = self.new(Mouse)
        self.mouse.initialize()
        
        # register handlers
        self.window.push_handlers(
            on_key_press = self.on_key_press
        )
        self.focus = True
        if parent is None:
            self.window.push_handlers(
                on_resize = self.on_resize,
                on_key_press = self.update_away,
                on_key_release = self.update_away,
                on_close = self.on_close,
                on_deactivate = self.on_deactivate,
                on_activate = self.on_activate
            )
            pyglet.app.event_loop.push_handlers(
                on_exit = self.on_exit
            )
        
        # for debug
        if SHOW_FPS and parent is None:
            font = pyglet.font.load('', 36, bold = True)
            self.fps_display = pyglet.font.Text(font, '', 
                color=(0.5, 0.5, 0.5, 0.5), x = 10, y = 10)
        
        # players
        self.players = self.new(Players)
        self.players.initialize()
        
        self.keyboard.attach(self.window)
        
        self.fbo = FBO(True)
        
        # OpenGL settings

        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE)
        glEnable(GL_BLEND)
        
        # import cherrypy
        # import dowser

        # cherrypy.tree.mount(dowser.Root())
        # cherrypy.config.update({
            # 'environment': 'embedded',
            # 'server.socket_port': 8080
        # })
        # cherrypy.engine.start()
        
        self.updaters = []
        self.changedFrames = {}

        self.on_resize(width, height)

        self.set_fps(header.frameRate)
        
        self.set_frame(0 if parent is None else parent.startFrame)
        
        if parent is None:
            if header.flags['FullscreenAtStart']:
                self.set_fullscreen(True)
            else:
                self.set_viewport()
        
        if parent is None:
            self.window.set_visible(True)
            clock.schedule_interval(self.update_clock, 0.2)
    
    def on_activate(self):
        self.focus = True
    
    def on_deactivate(self):
        self.focus = False
    
    def update_clock(self, dt):
        if self.finished:
            return
        if self.fps_display is not None:
            self.fps_display.text = '%d' % self.clock.get_fps()
    
    cdef PlayerChild new(self, type childClass):
        cdef PlayerChild newChild = childClass.__new__(childClass)
        newChild.init(self, None)
        return newChild
    
    def set_fps(self, value):
        self.desiredFrameRate = value
        if self.parent is not None:
            return
        clock.unschedule(self.update) # just in case
        clock.schedule_interval(self.update, 
            1.0 / self.get_fps())
        
    def on_detach(self):
        for child in self._childs[::]:
            (<PlayerChild>(child())).detach()
        self._childs = None
        
    def start(self):
        reactor.run()
    
    def _update_now(self, sinceLast, index):
        self.set_frame(index, True)
    
    def fade_out_finished(self):
        self.set_frame(self.nextFrame, True)
    
    def set_frame(self, index, forced = False):
        index = max(0, index)
        if self.frame:
            if not forced and not self.fading:
                clock.schedule_once(self._update_now, 0, index)
                return
            if self.frame.fade_out():
                self.nextFrame = index
                return
            self.fading = False
            IF PROFILE_LOAD:
                oldTime = time.clock()
            from mmfparser.player.event.conditions.application import (
                EndOfFrame)
            self.eventPlayer.generate_event(EndOfFrame)
            IF PROFILE_LOAD:
                print 'eventplayer end took', time.clock() - oldTime
                oldTime = time.clock()
            self.frame.detach()
            IF PROFILE_LOAD:
                print 'frame end took', time.clock() - oldTime
                oldTime = time.clock()
            self.eventPlayer.detach()
            IF PROFILE_LOAD:
                print 'eventplayer detach took', time.clock() - oldTime
                oldTime = time.clock()
            self.players.reset(True)
            if not self.gameData.header.newFlags['SamplesOverFrames']:
                self.media.reset()
        # cdef double currentTime = self.time
        # clock.unschedule(self.update)
        self.frameIndex = index
        try:
            frameLoader = self.frameLoader = self.gameData.frames[index]
        except KeyError:
            self.stop()
            return
        frameLoader.load()
        self.realWidth = min(frameLoader.width, self.width)
        self.realHeight = min(frameLoader.height, self.height)
        if self.viewport is not None:
            self.viewport.set_size(self.realWidth, self.realHeight)
        self.offsetX = self.offsetY = 0
        self.update_window_rect()
        self.timeOffset = 0
        IF PROFILE_LOAD:
            oldTime = time.clock()
        self.frame = frame = self.new(Frame)
        frame.initialize(frameLoader)
        IF PROFILE_LOAD:
            print 'frame init took:', (time.clock() - oldTime)
        cdef EventPlayer eventPlayer
        IF PROFILE_LOAD:
            oldTime = time.clock()
        self.eventPlayer = eventPlayer = self.new(EventPlayer)
        eventPlayer.initialize(self.frame.loader.events)
        IF PROFILE_LOAD:
            print 'eventplayer init took:', (time.clock() - oldTime)
        if self.parent is None:
            self.on_resize(self.window.width, self.window.height)
        # self.time = currentTime
        # self.set_fps(self.desiredFrameRate)
    
    def restart(self):
        self.changedFrames = {}
        self.players.reset()
        self.set_frame(0)
    
    def _stop_now(self, dt = None):
        self.window.close()
        self.media.stop()
        reactor.stop()
    
    def stop(self, now = False):
        if self.finished:
            return
        self.finished = True
        self.eventPlayer.quit()
        if self.parent is None:
            if now:
                self._stop_now()
            else:
                clock.schedule_once(self._stop_now, 0)
            
    def on_close(self):
        self.stop(True)
    
    def on_exit(self):
        self.stop(True)
        
    cdef object get_extension(self, item):
        extensionItem = item.getExtension(self.gameData.extensions)
        try:
            extension = self.extensions[extensionItem]
        except KeyError:
            extension = get_extension(extensionItem.name)
            self.extensions[extensionItem] = extension
        return extension

    cdef object get_movement(self, item):
        try:
            movement = self.extensions[item.name]
        except KeyError:
            movement = get_movement(item.name)
            self.extensions[item] = movement
        return movement
    
    cdef void get_window_coordinates(self, double x, double y, double * glX,
                                      double * glY):
        glX[0] = <int>x
        glY[0] = self.realHeight - <int>y
        #return x, self.height - y # subpixel behaviour
    
    def get_window_coordinates_python(self, x, y):
        cdef double glX, glY
        self.get_window_coordinates(x, y, &glX, &glY)
        return glX, glY
    
    cpdef tuple get_real_coordinates(self, double x, double y):
        if self.viewport is not None:
            x, y = self.viewport.convert_coordinates(x, y)
        x = x - self.addX + self.offsetX
        if self.viewport is None:
            y = self.window.height - y - self.addY + self.offsetY
        else:
            y = self.realHeight - y - self.addY + self.offsetY
        return x, y
    
    cpdef tuple get_window_rect(self):
        return self.x1, self.y1, self.x2, self.y2
    
    cdef void update_window_rect(self):
        self.x1 = <int>(self.offsetX)
        self.y1 = <int>(self.offsetY)
        self.x2 = <int>(self.realWidth + self.offsetX)
        self.y2 = <int>(self.realHeight + self.offsetY)
    
    def schedule_loop(self, func, *arg, **kw):
        self.clock.schedule(func, *arg, **kw)
    
    def add_updater(self, meth):
        self.clock.schedule(meth)
    
    def remove_updater(self, meth):
        self.clock.unschedule(meth)
    
    def update(self, double sinceLast):
        if self.finished:
            return
        cdef double firstTime, oldTime
        IF PROFILE:
            firstTime = time.clock()
        self.media.update()
        if not self.paused:
            IF PROFILE:
                print 'FPS:', 1 / sinceLast
            self.sinceLast = sinceLast
            self.awayTime += sinceLast
            self.frameRate = <int>(1.0 / (sinceLast or 1))
            if not self.fading:
                self.time += sinceLast
                if self.frameLoader.flags['TimedMovements']:
                    self.multiplier = sinceLast / (1.0 / self.get_fps(True))
                else:
                    self.multiplier = 1.0
                IF PROFILE:
                    oldTime = time.clock()
                self.frame.update()
                IF PROFILE:
                    print 'frame took: %s,' % (time.clock() - oldTime),
                    oldTime = time.clock()
                self.clock.tick(sinceLast)
                IF PROFILE:
                    print 'clock took: %s,' % (time.clock() - oldTime),
            IF PROFILE:
                oldTime = time.clock()
            self.eventPlayer.loop(sinceLast)
            IF PROFILE:
                print 'events took: %s,' % (time.clock() - oldTime),
            if self.eventPlayer.detached:
                return
        IF PROFILE:
            oldTime = time.clock()
        if self.parent is None and not self.finished:
            window = self.window
            if window.has_exit:
                return
            # window.switch_to()
            self.draw()
            window.flip()
            IF PROFILE:
                print 'drawing took: %s,' % (time.clock() - oldTime),
        IF PROFILE:
            print 'total: %s' % (time.clock() - firstTime)
    
    def update_away(self, *arg, **kw):
        self.awayTime = 0
    
    cpdef double get_time(self):
        return self.time
    
    def get_offset_time(self):
        return self.time - self.frame.startTime + self.timeOffset
    
    def set_time(self, value):
        self.timeOffset = value - self.time + self.frame.startTime
        for func in self.frame.timeChangeHandlers:
            func()
        
    def add_time_change_handler(self, func):
        self.frame.timeChangeHandlers.append(func)
    
    def get_fps(self, forMovements = False):
        if (forMovements and self.frameLoader.flags['TimedMovements']
        and self.frameLoader.movementTimer is not None):
            return self.frameLoader.movementTimer
        else:
            return self.desiredFrameRate

    def on_resize(self, width, height):
        glViewport(0, 0, width, height)
        glMatrixMode(GL_PROJECTION)
        glLoadIdentity()
        glOrtho(0, width, 0, height, -1, 1)
        glMatrixMode(GL_MODELVIEW)
        if self.viewport is None:
            self.addX = (width - self.realWidth) / 2
            self.addY = (height - self.realHeight) / 2
    
    def get_scissor_box(self, i_x, i_y, i_width, i_height):
        cdef int x, y, width, height
        x = <int>(i_x - self.offsetX)
        y = <int>(i_y + self.offsetY)
        width = <int>i_width
        height = <int>i_height
        box = (GLint * 4)()
        glGetIntegerv(GL_SCISSOR_BOX, box)
        cdef int box_x, box_y, box_width, box_height
        box_x = box[0]
        box_y = box[1]
        box_width = box[2]
        box_height = box[3]
        cdef int x1, y1, x2, y2
        intersect(x, y, x + width, y + height,
            box_x, box_y, box_x + box_width, box_y + box_height,
            &x1, &y1, &x2, &y2)
        return x1, y1, x2 - x1, y2 - y1
    
    def set_center(self, x = None, y = None):
        cdef int oldX = <int>self.offsetX
        cdef int oldY = <int>self.offsetY
        cdef int offsetX, offsetY
        if x is not None:
            offsetX = <int>(x - self.realWidth / 2.0)
            self.offsetX = min(max(0, offsetX), 
                self.frame.virtualWidth - self.realWidth)
        if y is not None:
            offsetY = <int>(y - self.realHeight / 2.0)
            self.offsetY = min(max(0, offsetY),
                self.frame.virtualHeight - self.realHeight)
        if oldX == self.offsetX and oldY == self.offsetY:
            return
        cdef int addX = <int>self.offsetX - oldX
        cdef int addY = <int>self.offsetY - oldY
        cdef double newX, newY
        cdef Layer layer
        cdef Instance instance
        cdef bint scrollLayer
        for layer in self.frame.layers:
            scrollLayer = layer.yCoefficient != 1 or layer.xCoefficient != 1
            for instances in (layer.instances, layer.backInstances):
                for instance in instances:
                    if not instance.scroll:
                        newX = instance.x + addX
                        newY = instance.y + addY
                        instance.set_position(newX, newY)
                    elif scrollLayer:
                        newX = instance.x - <int>(addX * (layer.xCoefficient - 1))
                        newY = instance.y - <int>(addY * (layer.yCoefficient - 1))
                        instance.set_position(newX, newY)
        self.mouse.on_screen_scroll(addX, addY)
        self.update_window_rect()
    
    def set_fullscreen(self, fullscreen):
        if fullscreen:
            self.viewport = FixedResolutionViewport(self, True)
            self.viewport.set_size(self.realWidth, self.realHeight)
            self.window.set_fullscreen(True)
        else:
            self.window.set_fullscreen(False)
            self.viewport = None
            self.set_viewport()
    
    def set_viewport(self):
        if self.parent is None and self.gameData.header.flags['Stretch']:
            try:
                keepRatio = self.gameData.extendedHeader.flags[
                    'KeepScreenRatio']
            except AttributeError:
                keepRatio = False
            self.viewport = FixedResolutionViewport(self, keepRatio)
            self.viewport.set_size(self.realWidth, self.realHeight)
    
    def change_active_color(self, objectInfo, color1, color2):
        r1, g1, b1 = color1
        r2, g2, b2 = color2
        item = self.gameData.frameItems.fromHandle(objectInfo)
        loader = item.properties.loader
        cdef dict createdFrames = {}
        for animation in loader.animations.loadedAnimations.values():
            for direction in animation.loadedDirections.values():
                for frameIndex, frame in enumerate(direction.frames):
                    try:
                        currentFrame = self.changedFrames[(direction, frameIndex)]
                    except KeyError:
                        currentFrame = self.gameData.images.fromHandle(frame)
                    if currentFrame in createdFrames:
                        newFrame = createdFrames[currentFrame]
                        if newFrame is None:
                            return
                    else:
                        newImage = make_image(currentFrame, 
                            images = self.gameData.images, frame = self.frame)
                        changedImage = replace_color(newImage, r1, g1, b1, r2, g2, b2)
                        if changedImage is None:
                            createdFrames[currentFrame] = None
                            continue
                        newFrame = CreatedFrame(changedImage, 
                            currentFrame.xHotspot, currentFrame.yHotspot, 
                            currentFrame.actionX, currentFrame.actionY)
                        createdFrames[currentFrame] = newFrame
                    self.changedFrames[(direction, frameIndex)] = newFrame
        cdef Instance instance
        for instance in self.frame.instanceHandles[objectInfo]:
            instance.objectPlayer.update_current_frame()
                
    def change_active_frame(self, objectInfo, animation, direction, frameIndex, 
                            loadedFrame):
        item = self.gameData.frameItems.fromHandle(objectInfo)
        loader = item.properties.loader
        try:
            directionItem = loader.animations.loadedAnimations[animation
                ].directions[direction]
        except (KeyError, IndexError):
            return
        if frameIndex not in xrange(len(directionItem.frames)):
            return
        self.changedFrames[(directionItem, frameIndex)] = loadedFrame
        cdef Instance instance
        for instance in self.frame.instanceHandles[objectInfo]:
            instance.objectPlayer.update_current_frame()
    
    def pause(self, int key = -1):
        self.resumeKey = key
        self.paused = True
        self.pauseTime = self.time
    
    def resume(self, event = True):
        if not self.paused:
            return
        self.time = self.pauseTime
        self.paused = False
        # tell conditions ;)
        if event:
            from mmfparser.player.event.conditions.application import (
                ApplicationResumed)
            self.eventPlayer.generate_event(ApplicationResumed)
    
    cpdef draw(self, bint draw_window = True):
        if self.realWidth == 0 or self.realHeight == 0:
            return
        cdef bint child = self.parent is not None
        glPushMatrix()
        if self.viewport is None:
            r, g, b = self.borderColor
            glClearColor(r / 255.0, g / 255.0, b / 255.0, 1.0)
        else:
            glClearColor(0.0, 0.0, 0.0, 1.0)
        if draw_window and not child:
            glClear(GL_COLOR_BUFFER_BIT)
        self.fbo.start(self.realWidth, self.realHeight)
        glLoadIdentity()
        glTranslatef(-self.offsetX, self.offsetY, 0)
        self.frame.draw(draw_window)
        texture = self.fbo.end()
        glPopMatrix()
        
        if draw_window:
            glColor4f(1.0, 1.0, 1.0, 1.0)
            glDisable(GL_BLEND)
            if self.viewport is not None:
                self.viewport.render(texture)
            else:
                if not child:
                    glLoadIdentity()
                    glTranslatef(self.addX, self.addY, 0)
                texture.blit(0, 0)
            glEnable(GL_BLEND)
        
        if draw_window and not child:
            glLoadIdentity()
            if self.fps_display is not None:
                self.fps_display.draw()
    
    def on_key_press(self, symbol, modifiers):
        if DEBUG and self.parent is None and symbol == user_key(0xDC):
            self.open_debug()
        elif self.paused and not self.resumeKey == -2:
            if self.resumeKey == -1 or symbol == self.resumeKey:
                self.resume()
    
    def open_debug(self):
        import code
        code.interact(local = locals())
    
    def get_effect(self, value):
        return self.gameData.shaders.items[value]