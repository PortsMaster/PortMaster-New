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

import sys

COMMAND_LINE = ' '.join(sys.argv)
COMMAND_ITEMS = []

for item in sys.argv[1:]:
    if item.startswith('/'):
        COMMAND_ITEMS.append(item[1:])

class GetCommandItem(Expression):
    def get(self):
        value = self.next_argument()
        for item in COMMAND_ITEMS:
            if item.startswith(value):
                return item[len(value):] or 'Empty'
        return ''

class GetCommandLine(Expression):
    def get(self):
        return COMMAND_LINE
