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

from mmfparser.player.extensions.common import UserExtension

from KcBoxA import KcBoxA

class DefaultObject(KcBoxA.objectPlayer):
    isBackground = True

class KcBoxB(UserExtension):
    objectPlayer = DefaultObject
    actions = KcBoxA.actions
    conditions = KcBoxA.conditions
    expressions = KcBoxA.expressions

extension = KcBoxB()

def get_extension():
    return extension