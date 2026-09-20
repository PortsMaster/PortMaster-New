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

from mmfparser import byteflag

class BitDict(object):
    keys = None
    flags = 0

    def __init__(self, *arg):
        if arg[0] is False:
            return
        self.keys = dict([(item, index) for (index, item) in enumerate(arg)])
    
    def __getitem__(self, key):
        return self.flags & (2 ** self.keys[key]) != 0
    
    def __setitem__(self, key, value):
        if value:
            self.flags |= 2**self.keys[key]
        else:
            self.flags &= ~2**self.keys[key]
    
    def iteritems(self):
        for key, index in self.keys.iteritems():
            yield key, self[key]
    
    def setFlags(self, flags):
        self.flags = flags
    
    def getFlags(self):
        return self.flags
    
    def copy(self):
        newDict = BitDict(False)
        newDict.keys = self.keys
        return newDict
    
    def __str__(self):
        actual_dict = {}
        for key in self.keys:
            actual_dict[key] = self[key]
        return '%s' % actual_dict
    
    def __repr__(self):
        return str(self)

def make_bitdict_string(valueDict):
    values = {}
    for k, v in valueDict.iteritems():
        try:
            key, = byteflag.getPositions(v)
        except ValueError:
            continue
        if key in valueDict:
            raise NotImplementedError('key already exists')
        values[key] = k
    values = dict(values)
    max_value = max(values.keys())
    newValues = []
    for i in xrange(max_value + 1):
        try:
            newValues.append(values[i])
        except KeyError:
            newValues.append(None)
    return newValues

if __name__ == '__main__':
    import sys
    if len(sys.argv) == 1:
        values = {}
        while 1:
            name = raw_input('name: ').strip()
            if name == '':
                break
            value = raw_input('value: ').strip()
            if value.startswith('0x'):
                value = int(value, 16)
                values[name] = value
            else:
                print 'invalid!'
    else:
        arg = sys.argv[1:]
        values = {}
        for i in xrange(len(arg) / 2):
            name = arg[i * 2]
            value = arg[i * 2 + 1]
            try:
                value = int(value, 16)
                values[name] = value
            except ValueError:
                continue
    print values
    from mmfparser.player.clipboard import set
    data = make_bitdict_string(values)
    print data
    set('%r' % data)