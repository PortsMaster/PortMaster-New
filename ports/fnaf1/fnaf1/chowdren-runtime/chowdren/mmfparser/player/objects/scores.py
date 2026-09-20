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
from mmfparser.player.objects.counter import Counter

class Scores(ObjectPlayer):
    counter = None
    
    def created(self):
        self.counter = self.parent.new(Counter)
        self.counter.initialize_object(self.loader, self.frame)
        self.set_transparency = self.counter.set_transparency
        self.draw = self.counter.draw
        
        player = self.player.players.items[self.loader.counters.player - 1]
        self.counter.set(player.score)
        player.push_handlers(
            score_changed = self.score_changed)
    
    def set_position(self, x, y):
        self.counter.x = x
        self.counter.y = y
        self.counter.set_position(x, y)
    
    def score_changed(self, value):
        self.counter.set(value)
        
__all__ = ['Scores']