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

from mmfparser.player.event.conditions.common import (TrueCondition, 
    FalseCondition, Condition)
from mmfparser.player import clipboard

class StartOfFrame(TrueCondition):
    pass

class EndOfApplication(TrueCondition):
    pass

class EndOfFrame(TrueCondition):
    pass

class FilesDropped(FalseCondition):
    pass

class CloseSelected(FalseCondition):
    pass

class ApplicationResumed(TrueCondition):
    pass

class ClipboardDataAvailable(Condition):
    def check(self):
        return (len(clipboard.get()) > 0) != self.negated

class VsyncEnabled(Condition):
    def check(self):
        return self.player.window.vsync != self.negated