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

from mmfparser.player.event.conditions.common import Condition

class AnswerTrue(Condition):
    def created(self):
        self.add_handlers(
            answer_true = self.answer_true)
    
    def answer_true(self, instance):
        self.generate()

    def check(self, instance):
        return self.isTriggered

class AnswerFalse(Condition):
    def created(self):
        self.add_handlers(
            answer_false = self.answer_false)
    
    def answer_false(self, instance):
        self.generate()

    def check(self, instance):
        return self.isTriggered

class AnswerMatches(Condition):
    def created(self):
        self.add_handlers(
            answered = self.answered)
    
    def answered(self, instance, value):
        if self.evaluate_index(0) != value:
            return
        self.generate()

    def check(self, instance):
        return self.isTriggered