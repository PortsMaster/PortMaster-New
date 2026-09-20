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

from mmfparser.player.movements.eightdirections import EightDirections
from mmfparser.player.movements.ball import Ball
from mmfparser.player.movements.path import Path
from mmfparser.player.movements.platform import Platform
from mmfparser.player.movements.static import Static
from mmfparser.player.movements.race import Race
from mmfparser.player.movements.mouse import Mouse

MOVEMENT_PLAYERS = {
    'Ball' : Ball,
    'Path' : Path,
    'EightDirections' : EightDirections,
    'Platform' : Platform,
    'Static' : Static,
    'Race' : Race,
    'Mouse' : Mouse
}
    
__all__ = ['MOVEMENT_PLAYERS']