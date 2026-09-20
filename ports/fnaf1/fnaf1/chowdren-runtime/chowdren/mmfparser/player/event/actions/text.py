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

from mmfparser.player.event.actions.common import Action

class SetParagraph(Action):
    def execute(self, instance):
        paragraph = self.get_fixed_index(self.get_parameter(0))
        instance.objectPlayer.set_paragraph(paragraph)

class NextParagraph(Action):
    def execute(self, instance):
        text = instance.objectPlayer
        text.set_paragraph(text.currentParagraph + 1)

class PreviousParagraph(Action):
    def execute(self, instance):
        text = instance.objectPlayer
        text.set_paragraph(text.currentParagraph - 1)

class SetTextColor(Action):
    def execute(self, instance):
        color = self.get_color(self.get_parameter(0))
        instance.objectPlayer.set_color(color)

class SetFontName(Action):
    def execute(self, instance):
        name = self.evaluate_index(0)
        instance.objectPlayer.set_font(name = name)

class SetFontSize(Action):
    def execute(self, instance):
        value = self.evaluate_index(0)
        resize = bool(self.evaluate_index(1))
        instance.objectPlayer.set_font(size = value)

class SetUnderline(Action):
    def execute(self, instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.set_font(underline = bool(value))

class SetStrikeOut(Action):
    def execute(self, instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.set_font(strikeOut = bool(value))

class SetBold(Action):
    def execute(self, instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.set_font(bold = bool(value))

class SetItalic(Action):
    def execute(self, instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.set_font(italic = bool(value))

class EraseText(Action):
    def execute(self, instance):
        instance.objectPlayer.erase_text()

class SetString(Action):
    def execute(self, instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.set_text(value)

class DisplayText(Action):
    def execute(self, instance):
        createParameter = self.get_parameter(0)
        paragraph = self.get_parameter(1).value
        createdObject = instance.objectInstance
        for x, y, _ in self.get_positions(createParameter.position):
            newItem = self.player.frame.create_instance(createdObject)
            if newItem.detached:
                continue
            newItem.set_position(x, y)
            newItem.objectPlayer.set_paragraph(paragraph)
            instance.objectPlayer.displayedInstances.append(newItem)

class FlashText(Action):
    def execute(self, instance):
        createParameter = self.get_parameter(0)
        paragraph = self.get_parameter(1).value
        seconds = self.get_parameter(2).timer / 1000.0
        createdObject = instance.objectInstance
        for x, y, _ in self.get_positions(createParameter.position):
            newItem = self.player.frame.create_instance(createdObject)
            if newItem.detached:
                continue
            newItem.set_position(x, y)
            newItem.objectPlayer.set_paragraph(paragraph)
            newItem.flash(seconds, True)
            instance.objectPlayer.displayedInstances.append(newItem)

class DisplayAlterableString(Action):
    def execute(self, instance):
        instance.objectPlayer.currentParagraph = -1