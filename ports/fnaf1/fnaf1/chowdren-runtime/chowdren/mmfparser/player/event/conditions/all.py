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

import mmfparser.player.event.conditions.application
import mmfparser.player.event.conditions.system
import mmfparser.player.event.conditions.control
import mmfparser.player.event.conditions.counter
import mmfparser.player.event.conditions.extension
import mmfparser.player.event.conditions.player
import mmfparser.player.event.conditions.time
import mmfparser.player.event.conditions.media
import mmfparser.player.event.conditions.menu
import mmfparser.player.event.conditions.pick
import mmfparser.player.event.conditions.text
import mmfparser.player.event.conditions.subapplication
import mmfparser.player.event.conditions.frame
import mmfparser.player.event.conditions.question

from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.get_subclasses import get_subclasses
CONDITIONS = get_subclasses(Condition)

__all__ = ['CONDITIONS']