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

"""
SoundPlayer.mfx
Sound Player - Looki (http://www.authorswebpage.com)
Copyright 2010 Looki

This extension allows you to load and play sounds dynamically (by
specifying their name in expressions).

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression


# Actions

class PlayAction(Action):
    def play(self, instance, name, channel, repeat = 1):
        channel -= 1
        if channel == -1:
            channel = None
        try:
            filename = instance.objectPlayer.sounds[name]
            self.player.media.play_sound_file(filename, repeat, channel)
        except KeyError:
            try:
                item = self.player.gameData.sounds.names[name]
            except (KeyError, AttributeError):
                print '(sound %r not found)' % name
                return
            self.player.media.play_sound(item, repeat, channel)

class Action0(PlayAction):
    """
    Playback->Play and loop

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    1: Channel index (1-32, 0: Free channel) (EXPRESSION, ExpressionParameter)
    2: Repeat count (0: Infinite) (EXPRESSION, ExpressionParameter)
    """
    
    def execute(self, instance):
        name = self.evaluate_index(0)
        channel = self.evaluate_index(1)
        repeat = self.evaluate_index(2)
        self.play(instance, name, channel, repeat)

class Action1(PlayAction):
    """
    Playback->Play

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    1: Channel index (1-32, 0: Free channel) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        name = self.evaluate_index(0)
        channel = self.evaluate_index(1)
        self.play(instance, name, channel)

class Action2(Action):
    """
    Manager->Delete

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action3(Action):
    """
    Manager->Add from file

    Parameters:
    0: Sound name (Leave empty to use the file name) (EXPSTRING, ExpressionParameter)
    1: File (*.wav,*.ogg,*.mod,*.aif) (FILENAME, Filename)
    """

    def execute(self, instance):
        name = self.evaluate_index(0)
        filename = self.get_filename(self.get_parameter(1))
        instance.objectPlayer.sounds[name] = filename

class Action4(Action):
    """
    Manager->Add from memory

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    1: Memory address (EXPRESSION, ExpressionParameter)
    2: File size (bytes) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action5(Action):
    """
    Playback->Pause

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action6(Action):
    """
    Playback->Resume

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action7(Action):
    """
    Playback->Stop

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action8(Action):
    """
    Playback->Set position

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    1: Position (ms) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action9(Action):
    """
    Playback->Set frequency

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    1: Frequency (Hz, 0: Original) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action10(Action):
    """
    Playback->Set volume

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    1: Volume (0-100) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action11(Action):
    """
    Playback->Set pan

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    1: Pan (-100: Left, 0: Center, 100: Right) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action12(Action):
    """
    Manager->Save to file

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    1: File name (FILENAME, Filename)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action13(Action):
    """
    Playback->With parameters->Play

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    1: Channel index (1-32, 0: Free channel) (EXPRESSION, ExpressionParameter)
    2: Volume (0-100) (EXPRESSION, ExpressionParameter)
    3: Pan (-100: Left, 0: Center, 100: Right) (EXPRESSION, ExpressionParameter)
    4: Position (ms) (EXPRESSION, ExpressionParameter)
    5: Frequency (Hz, 0: Original) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Action14(Action):
    """
    Playback->With parameters->Play and loop

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    1: Channel index (1-32, 0: Free channel) (EXPRESSION, ExpressionParameter)
    2: Volume (0-100) (EXPRESSION, ExpressionParameter)
    3: Pan (-100: Left, 0: Center, 100: Right) (EXPRESSION, ExpressionParameter)
    4: Position (ms) (EXPRESSION, ExpressionParameter)
    5: Frequency (Hz, 0: Original) (EXPRESSION, ExpressionParameter)
    6: Repeat count (0: Infinite) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))


# Conditions

class Condition0(Condition):
    """
    Manager->Sound added
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition1(Condition):
    """
    Playback->Is sound playing?

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition2(Condition):
    """
    Playback->Is sound paused?

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition3(Condition):
    """
    Manager->Does sound exist?

    Parameters:
    0: Sound name (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Condition4(Condition):
    """
    Playback->Sound played
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))


# Expressions

class Expression0(Expression):
    """
    Manager->Added sound->Index
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression1(Expression):
    """
    Manager->Name from index

    Parameters:
    0: Sound index (0-based) (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression2(Expression):
    """
    Manager->Index from name

    Parameters:
    0: Sound name (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression3(Expression):
    """
    Playback->Played sound->Name
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression4(Expression):
    """
    Manager->Added sound->Name
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression5(Expression):
    """
    Playback->Played sound->Channel
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression6(Expression):
    """
    Playback->Original frequency

    Parameters:
    0: Sound name (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression7(Expression):
    """
    Manager->Count sounds
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression8(Expression):
    """
    Playback->Memory address

    Parameters:
    0: Sound name (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression9(Expression):
    """
    Playback->Memory size

    Parameters:
    0: Sound name (String)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class Expression10(Expression):
    """
    Playback->Played sound->Index
    Return type: 
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            self.__class__.__name__))

class DefaultObject(HiddenObject):
    def created(self, data):
        storage = self.get_storage()
        if 'sounds' not in storage:
            storage['sounds'] = {}
        self.sounds = storage['sounds']

class SoundPlayer(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
        3 : Action3,
        4 : Action4,
        5 : Action5,
        6 : Action6,
        7 : Action7,
        8 : Action8,
        9 : Action9,
        10 : Action10,
        11 : Action11,
        12 : Action12,
        13 : Action13,
        14 : Action14,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3,
        4 : Condition4,
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
        3 : Expression3,
        4 : Expression4,
        5 : Expression5,
        7 : Expression6,
        8 : Expression7,
        9 : Expression8,
        10 : Expression9,
        37 : Expression10,
    }

extension = SoundPlayer()

def get_extension():
    return extension
