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

class CurrentText(Expression):
    def get(self, instance):
        return instance.objectPlayer.value

class GetParagraph(Expression):
    def get(self, instance):
        return instance.objectPlayer.get_paragraph_text(
            self.next_argument())

class TextAsNumber(Expression):
    def get(self, instance):
        try:
            return float(instance.objectPlayer.value)
        except ValueError:
            return 0

class CurrentParagraphIndex(Expression):
    def get(self, instance):
        return instance.objectPlayer.currentParagraph + 1

class ParagraphCount(Expression):
    def get(self, instance):
        return len(instance.objectPlayer.loader.text.items)