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

from mmfparser.player.event.expressions.common import Expression

class TimerExpression(Expression):
    def get_time(self):
        return self.player.get_offset_time() - self.player.frame.startTime

class TimerValue(TimerExpression):
    def get(self):
        return int(self.get_time() * 1000)

class TimerHundreds(TimerExpression):
    def get(self):
        return int(self.get_time() * 100) % 100

class TimerSeconds(TimerExpression):
    def get(self):
        return int(self.get_time()) % 60

class TimerMinutes(TimerExpression):
    def get(self):
        return int(self.get_time() / 60.0) % 60

class TimerHours(TimerExpression):
    def get(self):
        return int(self.get_time() / 60.0 / 60.0)