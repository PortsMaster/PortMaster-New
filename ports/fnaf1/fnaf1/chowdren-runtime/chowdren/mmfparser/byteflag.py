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
Perfom flag operations on numbers.
"""

def listFlag(flaglist):
    """
    Takes a list of bools and returns
    a flagbyte.
    """
    flag = 0
    for index, item in enumerate(flaglist):
        flag = setFlag(flag, index, item)
    return flag

def setFlag(flagbyte, pos, status):
    """
    Sets the bit at 'pos' to 'status', and
    returns the modified flagbyte.
    """
    if status:
        return flagbyte | 2**pos
    else:
        return flagbyte & ~2**pos

def getFlag(flagbyte, pos):
    """
    Returns the bit at 'pos' in 'flagbyte'
    """
    mask = 2**pos
    result = flagbyte & mask
    return (result == mask)

def getPositions(mask):
    """
    Get a list of positions where the specified
    mask has the bit set
    """
    # XXX I don't exactly love this implementation,
    # but it works.
    binaryString = bin(mask)[2:]
    result = []
    for index, c in enumerate(binaryString[::-1]):
        if int(c):
            result.append(index)
    return result
    
def getFlags(flagbyte, *positions):
    """
    Returns the bits specified in the arguments
    """
    return [getFlag(flagbyte, pos) for pos in positions]