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

from mmfparser.player.transitions.common import TransitionPlayer
from mmfparser.player.sprite import Sprite
from pyglet import gl

class FadeIn(TransitionPlayer):
    def draw_transition(self, percentage_done):
        if self.destination is None:
            self.source.alpha = 1 - percentage_done
            self.source.render()
        elif self.source is None:
            self.destination.alpha = percentage_done
            self.destination.render()
        elif self.source and self.destination:
            gl.glDisable(gl.GL_BLEND)
            self.source.render()
            gl.glEnable(gl.GL_BLEND)
            self.destination.alpha = percentage_done
            self.destination.render()