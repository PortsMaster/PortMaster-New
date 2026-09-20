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

keys = [
    1, 0, 2, 2, 4, 1, 27, 27, 13, 10, 
    16, 16, 17, 17, 18, 18, 32, 32, 37, 37, 
    38, 38, 39, 39, 40, 40, 144, 144, 111, 111, 
    106, 106, 109, 109, 107, 107, 110, 110, 226, 92, 
    221, 91, 186, 93, 219, 522, 187, 61, 8, 8, 
    45, 155, 36, 36, 46, 127, 35, 35, 33, 33, 
    34, 34, 9, 9, 112, 112, 113, 113, 114, 114, 
    115, 115, 116, 116, 117, 117, 118, 118, 119, 119, 
    120, 120, 121, 121, 122, 122, 123, 123, 124, -4096, 
    125, -4095, 126, -4094, 127, -4093, 128, -4092, 129, -4091, 
    130, -4090, 131, -4089, 132, -4088, 133, -4087, 134, -4086, 
    135, -4085, 48, 48, 49, 49, 50, 50, 51, 51, 
    52, 52, 53, 53, 54, 54, 55, 55, 56, 56, 
    57, 57, 65, 65, 66, 66, 67, 67, 68, 68, 
    69, 69, 70, 70, 71, 71, 72, 72, 73, 73, 
    74, 74, 75, 75, 76, 76, 77, 77, 78, 78, 
    79, 79, 80, 80, 81, 81, 82, 82, 83, 83, 
    84, 84, 85, 85, 86, 86, 87, 87, 88, 88, 
    89, 89, 90, 90, 96, 96, 97, 97, 98, 98, 
    99, 99, 100, 100, 101, 101, 102, 102, 103, 103, 
    104, 104, 105, 105, -1
]

keyNames = [
    "LButton", "MButton", "RButton", "Escape", "Return", "Shift", "Control", "Alt", "Space", "Left", 
    "Up", "Right", "Down", "Numlock", "Divide", "Multiply", "Subtract", "Add", "Decimal", "Key1", 
    "Key2", "Key3", "Close bracket", "Equal", "Backspace", "Insert", "Home", "Delete", "End", "Previous page", 
    "Next page", "Tab", "Unknown"
]

NB_SPECIAL_KEYS = 29

def getKeyText(keyNumber):
        keyText = 'Virtual Key %s' % keyNumber
        if keyNumber in xrange(96, 106):
            keyText = 'Numpad ' + str(keyNumber - 96)
        elif keyNumber in xrange(112, 61452):
            keyText = 'F' + str(keyNumber - 111)
        elif keyNumber in xrange(48, 58):
            # numbers
            keyText = str(keyNumber - 48)
        elif keyNumber in xrange(65, 91):
            # characters
            keyText = chr(keyNumber)
        else:
            try:
                index = keys.index(keyNumber)
                keyText = keyNames[index/2]
            except ValueError:
                pass
        return keyText