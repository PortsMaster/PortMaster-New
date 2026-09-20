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

parameterNames = {
    1 : 'OBJECT',
    2 : 'TIME',
    3 : 'SHORT',
    4 : 'SHORT',
    5 : 'INT',
    6 : 'SAMPLE',
    7 : 'SAMPLE',
    9 : 'CREATE',
    10 : 'SHORT',
    11 : 'SHORT',
    12 : 'SHORT',
    13 : 'Every',
    14 : 'KEY',
    15 : 'EXPRESSION',
    16 : 'POSITION',
    17 : 'JOYDIRECTION',
    18 : 'SHOOT',
    19 : 'ZONE',
    21 : 'SYSCREATE',
    22 : 'EXPRESSION',
    23 : 'COMPARISON',
    24 : 'COLOUR',
    25 : 'BUFFER4',
    26 : 'FRAME',
    27 : 'SAMLOOP',
    28 : 'MUSLOOP',
    29 : 'NEWDIRECTION',
    31 : 'TEXTNUMBER',
    32 : 'Click',
    33 : 'PROGRAM',
    34 : 'OLDPARAM_VARGLO',
    35 : 'CNDSAMPLE',
    36 : 'CNDMUSIC',
    37 : 'REMARK',
    38 : 'GROUP',
    39 : 'GROUPOINTER',
    40 : 'FILENAME',
    41 : 'STRING',
    42 : 'CMPTIME',
    43 : 'PASTE',
    44 : 'VMKEY',
    45 : 'EXPSTRING',
    46 : 'CMPSTRING',
    47 : 'INKEFFECT',
    48 : 'MENU',
    49 : 'GlobalValue',
    50 : 'AlterableValue',
    51 : 'FLAG',
    52 : 'VARGLOBAL_EXP',
    53 : 'AlterableValueExpression',
    54 : 'FLAG_EXP',
    55 : 'EXTENSION',
    56 : '8DIRECTIONS',
    57 : 'MVT',
    58 : 'GlobalString',
    59 : 'STRINGGLOBAL_EXP',
    60 : 'PROGRAM2',
    61 : 'ALTSTRING',
    62 : 'ALTSTRING_EXP',
    63 : 'FILENAME',
    64 : 'FASTLOOPNAME',
    65 : 'CHAR_ENCODING_INPUT',
    66 : 'CHAR_ENCODING_OUTPUT'
}

def getName(id):
    return parameterNames[id]
