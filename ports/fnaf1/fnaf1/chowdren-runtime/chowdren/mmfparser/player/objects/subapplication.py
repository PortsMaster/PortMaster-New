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

from mmfparser.player.objects.common import ObjectPlayer
from mmfparser.player.main import GamePlayer
from mmfparser.data.gamedata import GameData
from mmfparser.bytereader import ByteReader
from pyglet.gl import (glTranslatef, glEnable, glDisable, 
    GL_SCISSOR_TEST, glPushAttrib, glPopAttrib, glPushMatrix,
    glPopMatrix)

class SubApplication(ObjectPlayer):
    paused = False
    gamePlayer = None
    def created(self):
        loader = self.loader.subApplication
        self.startFrame = loader.startFrame
        self.width = loader.width
        self.height = loader.height
        self.options = loader.options
        self.dockedPosition = loader.getDockedPosition()
        if self.options['Internal'] and self.startFrame != self.player.frameIndex:
            self.gamePlayer = GamePlayer(self.player.gameData, self)
        else:
            self.load_file(loader.name)
        self.player.clock.schedule(self.update)
    
    def load_file(self, name):
        try:
            reader = ByteReader(open(name, 'rb'))
        except IOError:
            return
        
        extension = name.split('.')[-1]
                
        if extension == 'ccn':
            gameData = GameData(reader, loadImages = True,
                delayedLoad = False)
        elif extension == 'ccj':
            gameData = GameData(reader, loadImages = True,
                delayedLoad = False, java = True)
        else:
            return
            
        self.gamePlayer = GamePlayer(gameData, self)
    
    def get_global_string(self, index):
        if self.gamePlayer is None:
            return ''
        return self.gamePlayer.globals.get_string(index - 1)
    
    def get_global_value(self, index):
        if self.gamePlayer is None:
            return 0
        return self.gamePlayer.globals.get_value(index - 1)
        
    def get_frame(self):
        if self.gamePlayer is None:
            return 0
        return self.gamePlayer.frameIndex + 1
    
    def update(self, sinceLast):
        if self.paused or self.gamePlayer is None:
            return
        self.gamePlayer.update(sinceLast)
    
    def restart(self):
        if self.gamePlayer is None:
            return
        self.gamePlayer.set_frame(self.startFrame)
    
    def draw(self):
        if self.gamePlayer is None or self.gamePlayer.finished:
            return
        player = self.player
        glPushMatrix()
        glTranslatef(self.x, self.y - self.height, 0)
        self.gamePlayer.draw()
        glPopMatrix()

__all__ = ['SubApplication']