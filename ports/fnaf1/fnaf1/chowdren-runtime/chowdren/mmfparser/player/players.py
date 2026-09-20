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

from pyglet.window.key import user_key
from pyglet.window.mouse import LEFT as MOUSE_LEFT, RIGHT as MOUSE_RIGHT

from mmfparser.player.common import PlayerChild
from mmfparser.player.eventdispatcher import EventDispatcher

DIRECTIONAL_CONTROLS = ('Up', 'Down', 'Left', 'Right')

KEY_LIST = ('Up', 'Down', 'Left', 'Right', 'Button1', 'Button2', 'Button3', 
    'Button4')

UP, DOWN, LEFT, RIGHT, BUTTON1, BUTTON2, BUTTON3, BUTTON4 = xrange(8)

class Player(PlayerChild, EventDispatcher):
    name = ''
    keys = None
    keyList = None
    keyNames = None
    pressed_keys = None
    
    lives = None
    score = None
    
    controls_ignored = False
    use_mouse = False
    def initialize(self, control):
        controlType = control.getControlType()

        if controlType != 'Keyboard':
            raise NotImplementedError(
                'control type %r unsupported' % controlType)
        
        keys = control.keys
        convert = self.player.keyboard.convert
        
        self.keyList = keyList = []
        self.keyNames = keyNames = []
        for key in (keys.up, keys.down, keys.left, keys.right, keys.button1,
                    keys.button2, keys.button3, keys.button4):
            keyList.append(convert(key.getValue()))
            keyNames.append(key.getName())
            
        self.keys = keys = {}
        for index, key in enumerate(KEY_LIST):
            keys[key] = keyList[index]
        
        self.symbol_to_key = dict([(v, k) for k, v in keys.iteritems()])
        
        self.reset()
        
        self.player.window.push_handlers(
            on_key_press = self.key_pressed,
            on_key_release = self.key_released
        )
        
        self.player.mouse.push_handlers(
            on_mouse_press = self.mouse_pressed,
            on_mouse_release = self.mouse_released
        )
    
    def mouse_pressed(self, x, y, symbol, modifiers):
        if self.controls_ignored or not self.use_mouse:
            return
        if symbol == MOUSE_LEFT:
            self.dispatch_event('player_key_pressed', 'Button1')
        elif symbol == MOUSE_RIGHT:
            self.dispatch_event('player_key_pressed', 'Button2')
            
    def mouse_released(self, x, y, symbol, modifiers):
        if self.controls_ignored or not self.use_mouse:
            return
        if symbol == MOUSE_LEFT:
            self.dispatch_event('player_key_released', 'Button1')
        elif symbol == MOUSE_RIGHT:
            self.dispatch_event('player_key_released', 'Button2')
    
    def key_pressed(self, symbol, modifiers):
        if self.controls_ignored:
            return
        try:
            key = self.symbol_to_key[symbol]
            if self.use_mouse and key in ('Button1', 'Button2'):
                return
            self.dispatch_event('player_key_pressed', key)
        except KeyError:
            pass
    
    def key_released(self, symbol, modifiers):
        if self.controls_ignored:
            return
        try:
            key = self.symbol_to_key[symbol]
            if self.use_mouse and key in ('Button1', 'Button2'):
                return
            self.dispatch_event('player_key_released', key)
        except KeyError:
            pass
    
    def is_down(self, key):
        if self.controls_ignored:
            return False
        if self.use_mouse:
            if key == 'Button1':
                return self.player.mouse.left
            elif key == 'Button2':
                return self.player.mouse.right
        return self.player.keyboard[self.keys[key]]
    
    def is_down_index(self, value):
        if self.controls_ignored:
            return False
        if self.use_mouse:
            if value == BUTTON1:
                return self.player.mouse.left
            elif value == BUTTON2:
                return self.player.mouse.right
        return self.player.keyboard[self.keyList[value]]
    
    def set_key(self, index, key):
        code = self.player.keyboard.convert(key.getValue())
        name_key = KEY_LIST[index]
        name = key.getName()
        self.keyList[index] = code
        self.keyNames[index] = name
        self.keys[name_key] = code
        self.symbol_to_key[code] = name_key
    
    def set_score(self, value):
        self.score = value
        self.dispatch_event('score_changed', value)
    
    def set_lives(self, value):
        self.lives = value
        self.dispatch_event('lives_changed', value)
        
    def reset(self, frame = False):
        self.controls_ignored = False
        if frame:
            return
        header = self.player.gameData.header
        self.lives = header.initialLives
        self.score = header.initialScore

Player.register_event_type('player_key_pressed')
Player.register_event_type('player_key_released')
Player.register_event_type('score_changed')
Player.register_event_type('lives_changed')

class Players(PlayerChild):
    items = None
    def initialize(self):
        header = self.player.gameData.header
        
        self.items = items = []
        for control in header.controls.items:
            player = self.new(Player)
            player.initialize(control)
            items.append(player)
    
    def reset(self, frame = False):
        for player in self.items:
            player.reset(frame)