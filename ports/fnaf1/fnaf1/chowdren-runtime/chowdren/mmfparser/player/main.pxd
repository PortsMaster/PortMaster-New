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

cdef class GamePlayer

from mmfparser.player.clock cimport Clock
from mmfparser.player.event.player cimport EventPlayer
from mmfparser.player.frame cimport Frame
from mmfparser.player.alterables cimport Globals
from mmfparser.player.common cimport PlayerChild

cdef class GamePlayer:
    cdef public:
        PlayerChild parent
        object gameData
        object window
        object players
        double sinceLast
        double multiplier
        list updaters
        int frameIndex
        int nextFrame
        list frameHandles
        Frame frame
        object frameLoader
        EventPlayer eventPlayer
        object fps_display
        int height
        int realHeight
        int width
        int realWidth
        object viewport
        object files
        object media
        object keyboard
        object mouse
        bint fading
        Clock clock
        double time
        double timeOffset
        double addX, addY
        int offsetX, offsetY
        int x1, y1, x2, y2
        int sleepX1, sleepY1, sleepX2, sleepY2
        Globals globals
        int frameRate
        bint paused
        int resumeKey
        double pauseTime
        double awayTime
        dict debug
        bint finished
        dict changedFrames
        int desiredFrameRate
        dict extensions
        dict extensionStorage
        object fbo
        bint focus
        tuple borderColor
    
    cdef void get_window_coordinates(self, double x, double y, double * glX,
                                     double * glY)
    cpdef tuple get_real_coordinates(self, double x, double y)
    cpdef tuple get_window_rect(self)
    cpdef double get_time(self)
    cpdef draw(self, bint draw_window = ?)
    cdef void update_window_rect(self)
    cdef PlayerChild new(self, type typeClass)
    cdef object get_extension(self, item)
    cdef object get_movement(self, item)