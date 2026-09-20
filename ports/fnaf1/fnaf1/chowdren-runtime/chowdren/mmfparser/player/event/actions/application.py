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

import subprocess

from mmfparser.player.event.actions.common import Action
from mmfparser.bitdict import BitDict
from mmfparser.player import clipboard
import pyglet.app

class EndApplication(Action):
    def execute(self):
        self.player.stop()

class RestartApplication(Action):
    def execute(self):
        if self.player.fading:
            return
        self.player.restart()

class NextFrame(Action):
    def execute(self):
        if self.player.fading:
            return
        self.player.set_frame(self.player.frameIndex + 1)

class PreviousFrame(Action):
    def execute(self):
        if self.player.fading:
            return
        self.player.set_frame(self.player.frameIndex - 1)

class RestartFrame(Action):
    def execute(self):
        if self.player.fading:
            return
        self.player.set_frame(self.player.frameIndex)

class JumpToFrame(Action):
    def execute(self):
        if self.player.fading:
            return
        frameParameter = self.get_parameter(0)
        if frameParameter.isExpression:
            value = self.evaluate_expression(frameParameter) - 1
        else:
            value = self.player.frameHandles[frameParameter.value]
        self.player.set_frame(value)

class PauseApplication(Action):
    def execute(self):
        if self.player.fading:
            return
        self.player.pause()

class PauseApplicationWithKey(Action):
    key = None
    def created(self):
        self.key = self.player.keyboard.convert(
            self.get_parameter(0).key.getValue())

    def execute(self):
        self.player.pause(self.key)

class ResumeApplication(Action):
    def execute(self):
        self.player.resume()

class EnableVsync(Action):
    def execute(self):
        self.player.window.set_vsync(True)

class DisableVsync(Action):
    def execute(self):
        self.player.window.set_vsync(False)

class _ExecuteProgram(Action):
    def run(self, executable, command, hide, wait):
        if hide:
            self.player.window.set_visible(False)
        process = subprocess.Popen([executable, command])
        if wait:
            self.player.pause(-2)
            process.wait()
            self.player.resume()
        if hide:
            self.player.window.set_visible(True)

class ExecuteFixedProgram(_ExecuteProgram):
    def execute(self):
        parameter = self.get_parameter(0)
        executable = parameter.filename
        command = parameter.command
        hide = parameter.flags['Hide']
        wait = parameter.flags['Wait']
        self.run(executable, command, hide, wait)

class ExecuteEvaluatedProgram(_ExecuteProgram):
    def created(self):
        self.flags = BitDict('Wait', 'Hide')
    
    def execute(self):
        executable = self.evaluate_index(0)
        command = self.evaluate_index(1)
        self.flags.setFlags(self.get_parameter(2).value)
        self.run(executable, command, self.flags['Wait'], self.flags['Hide'])

class SetClipboard(Action):
    def execute(self):
        value = self.evaluate_index(0)
        clipboard.set(value)

class ClearClipboard(Action):
    def execute(self):
        clipboard.set('')

class SetFrameRate(Action):
    def execute(self):
        value = self.evaluate_index(0)
        self.player.set_fps(value)