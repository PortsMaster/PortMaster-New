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
parser.mfx

Gives the developer access to powerful parsing and tokenizing
functions to tear apart or put together strings and substrings of
information.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression
from mmfparser.player.common import open_file

# Actions

from retools import convert_pattern, get_pattern

class Action0(Action):
    """
    Set source string

    Parameters:
    0: Set source string (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.value = self.evaluate_expression(
            self.get_parameter(0))

class Action1(Action):
    """
    File->Save to file

    Parameters:
    0: Save to file (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            open_file(filename, 'wb').write(instance.objectPlayer.value)
        except IOError:
            return

class Action2(Action):
    """
    File->Load from file

    Parameters:
    0: Load from file (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            instance.objectPlayer.value = open_file(filename, 'rb').read()
        except IOError:
            return

class Action3(Action):
    """
    File->Append to file

    Parameters:
    0: Append to file (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            open_file(filename, 'a').write(instance.objectPlayer.value)
        except IOError:
            return

class Action4(Action):
    """
    File->Append from file

    Parameters:
    0: Append from file (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            instance.objectPlayer.value += open_file(filename, 'rb').read()
        except IOError:
            return

class Action5(Action):
    """
    List Tokenizing->Delimiters->Reset delimiters
    """

    def execute(self, instance):
        instance.objectPlayer.delimiters = []

class Action6(Action):
    """
    List Tokenizing->Delimiters->Add delimiter

    Parameters:
    0: Add delimiter (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.delimiters.append(value)
        instance.objectPlayer.defaultDelimiter = value

class Action7(Action):
    """
    List Tokenizing->Delimiters->Set delimiter

    Parameters:
    0: Set delimiter (EXPSTRING, ExpressionParameter)
    1: Set delimiter (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0)
        index = self.evaluate_index(1)
        try:
            instance.objectPlayer.delimiters[index] = value
        except IndexError:
            return
        instance.objectPlayer.defaultDelimiter = value

class Action8(Action):
    """
    List Tokenizing->Delimiters->Delete delimiter index

    Parameters:
    0: Delete delimiter index (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(1)
        try:
            del instance.objectPlayer.delimiters[index]
        except IndexError:
            return

class Action9(Action):
    """
    List Tokenizing->Delimiters->Delete delimiter

    Parameters:
    0: Delete delimiter (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(1)
        try:
            instance.objectPlayer.delimiters.remove(value)
        except ValueError:
            return

class Action10(Action):
    """
    List Tokenizing->Delimiters->Set default delimiter index

    Parameters:
    0: Set default delimiter index (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0)
        try:
            value = instance.objectPlayer.delimiters[index]
        except IndexError:
            return
        instance.objectPlayer.defaultDelimiter = value

class Action11(Action):
    """
    List Tokenizing->Delimiters->Set default delimiter

    Parameters:
    0: Set default delimiter (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0)
        if value not in instance.objectPlayer.delimiters:
            return
        instance.objectPlayer.defaultDelimiter = value

class Action12(Action):
    """
    List Tokenizing->File->Save as CSV

    Parameters:
    0: Save as CSV (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            f = open_file(filename, 'wb')
        except IOError:
            return
        f.write('\r\n'.join(instance.objectPlayer.split()))
        f.close()

class Action13(Action):
    """
    List Tokenizing->File->Load from CSV

    Parameters:
    0: Load from CSV (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            data = open_file(filename, 'rb').read().splitlines()
        except IOError:
            return
        instance.objectPlayer.value = instance.objectPlayer.join(data)

try:
    from extensions.KcArray.mmfarray import MMFArray
except ImportError:
    pass
from mmfparser.bytereader import ByteReader

class Action14(Action):
    """
    List Tokenizing->File->Save as MMF Array

    Parameters:
    0: Save as MMF Array (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            file = open_file(filename, 'wb')
        except IOError:
            return
        array = MMFArray()
        value = instance.objectPlayer.split()
        array.setup(len(value), 1, 1, 'Text')
        array.items[0] = {0 : dict(enumerate(value))}
        data = str(array.generate())
        file.write(data)
        file.close()

class Action15(Action):
    """
    List Tokenizing->File->Load from MMF Array

    Parameters:
    0: Load from MMF Array (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            data = open_file(filename, 'rb').read()
        except IOError:
            return
        array = MMFArray()
        array.read(ByteReader(data))
        if array.size[1] != 1 or array.size[2] != 1 or not array.flags['Text']:
            return
        value = []
        valueDict = array.items[0][0]
        for i in xrange(len(valueDict)):
            value.append(valueDict[i])
        instance.objectPlayer.value = instance.objectPlayer.join(value)

class Action16(Action):
    """
    List Tokenizing->File->Save as Dynamic Array

    Parameters:
    0: Save as Dynamic Array (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('Dynamic Array not supported')

class Action17(Action):
    """
    List Tokenizing->File->Load from Dynamic Array

    Parameters:
    0: Load from Dynamic Array (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('Dynamic Array not supported')

class Action18(Action):
    """
    Settings->String Comparisons->Case Insensitive (A == a)
    """

    def execute(self, instance):
        instance.objectPlayer.caseSensitive = False

class Action19(Action):
    """
    Settings->String Comparisons->Case Sensitive (A < a)
    """

    def execute(self, instance):
        instance.objectPlayer.caseSensitive = True

class Action20(Action):
    """
    Settings->Search Mode->Literal
    """

    def execute(self, instance):
        instance.objectPlayer.wildcardSearch = False

class Action21(Action):
    """
    Settings->Search Mode->Wildcards
    """

    def execute(self, instance):
        instance.objectPlayer.wildcardSearch = True

from ConfigParser import RawConfigParser

class Action22(Action):
    """
    List Tokenizing->File->Save as INI

    Parameters:
    0: Save as INI (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            file = open_file(filename, 'wb')
        except IOError:
            return
        config = RawConfigParser()
        config.optionxform = str
        value = instance.objectPlayer.split()
        config.add_section('List')
        config.set('List', 'Elements', str(len(value)))
        for i, item in enumerate(value):
            config.set('List', 'Element%s' % (i+1), item)
        config.write(file)
        file.close()

class Action23(Action):
    """
    List Tokenizing->File->Load from INI

    Parameters:
    0: Load from INI (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            file = open_file(filename, 'rb')
        except IOError:
            return
        config = RawConfigParser()
        config.optionxform = str
        config.readfp(file)
        file.close()
        if 'List' not in config.sections():
            return
        valueDict = {}
        for item in config.options('List'):
            if item.startswith('Element'):
                try:
                    index = int(item[7:])
                except ValueError:
                    continue
                valueDict[index] = config.get('List', item)
        value = [valueDict[k] for k in sorted(valueDict.keys())]
        instance.objectPlayer.value = instance.objectPlayer.join(value)

# Conditions

import string
LETTERS = set(string.ascii_letters) | set(string.digits) | set(['+'])

class Condition0(Condition):
    """
    Is URL safe?
    """

    def check(self, instance):
        value = instance.objectPlayer.value
        i = 0
        while 1:
            if i >= len(value):
                break
            c = value[i]
            i += 1
            if c in LETTERS:
                continue
            elif value[i] == '%':
                try:
                    if (value[i] not in LETTERS 
                    or value[i + 1] not in LETTERS):
                        return False
                    i += 2
                except IndexError:
                    return False
            else:
                return False
        return True

# Expressions

class Expression0(Expression):
    """
    Get string
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.value

class Expression1(Expression):
    """
    Get length of string
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.value)

class Expression2(Expression):
    """
    Substrings->Left substring

    Parameters:
    0: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument()
        return instance.objectPlayer.value[:index]

class Expression3(Expression):
    """
    Substrings->Right substring

    Parameters:
    0: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument()
        return instance.objectPlayer.value[-index:]

class Expression4(Expression):
    """
    Substrings->Middle substring

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        start = self.next_argument()
        end = self.next_argument()
        return instance.objectPlayer.value[start:end]

class Expression5(Expression):
    """
    Substrings->Get number of substrings

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        value = self.next_argument()
        if instance.objectPlayer.wildcardSearch:
            pat = instance.objectPlayer.get_pattern([value])
            return len(pat.findall(instance.objectPlayer.value))
        compare = instance.objectPlayer.value
        if not instance.objectPlayer.caseSensitive:
            value = value.lower()
            compare = compare.lower()
        return compare.count(value)

class Expression6(Expression):
    """
    Substrings->Get index of substring

    Parameters:
    0: (not found) (String)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        value = self.next_argument()
        nth = self.next_argument()
        return instance.objectPlayer.get_substring_index(value, nth - 1) + 1

class Expression7(Expression):
    """
    Substrings->Get index of first substring

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        value = self.next_argument()
        nth = self.next_argument()
        return instance.objectPlayer.get_substring_index(value, 0) + 1

class Expression8(Expression):
    """
    Substrings->Get index of last substring

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        value = self.next_argument()
        return instance.objectPlayer.get_last_substring_index(value) + 1

class Expression9(Expression):
    """
    Substrings->Remove substrings

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        value = self.next_argument()
        pat = instance.objectPlayer.get_pattern([value])
        return pat.sub('', instance.objectPlayer.value)

class Expression10(Expression):
    """
    Substrings->Replace substrings

    Parameters:
    0: (not found) (String)
    1: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        value = self.next_argument()
        replace = self.next_argument()
        pat = instance.objectPlayer.get_pattern([value])
        return pat.sub(replace, instance.objectPlayer.value)

class Expression11(Expression):
    """
    Substrings->Insert substring

    Parameters:
    0: (not found) (String)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        value = self.next_argument()
        index = self.next_argument() - 1
        original = instance.objectPlayer.value
        return original[:index] + value + original[index:]

class Expression12(Expression):
    """
    Transform->Reverse string
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.value[::-1]

class Expression13(Expression):
    """
    Transform->Uppercase string
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.value.upper()

class Expression14(Expression):
    """
    Transform->Lowercase string
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.value.lower()

import urllib

class Expression15(Expression):
    """
    Transform->URL Encoded string
    Return type: Int
    """

    def get(self, instance):
        return urllib.quote(instance.objectPlayer.value)

class Expression16(Expression):
    """
    ASCII->Get ASCII character

    Parameters:
    0: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        value = self.next_argument()
        return chr(value)

class Expression17(Expression):
    """
    ASCII->Get ASCII value

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        value = self.next_argument()
        return ord(value)

class Expression18(Expression):
    """
    ASCII->Get ASCII value list

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        value = instance.objectPlayer.value
        delimiter = self.next_argument()
        return delimiter.join([str(ord(c)) for c in value])

class Expression19(Expression):
    """
    List Tokenizing->Delimiters->Get number of delimiters
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.delimiters)

class Expression20(Expression):
    """
    List Tokenizing->Delimiters->Get delimiter

    Parameters:
    0: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument()
        return instance.objectPlayer.delimiters[index]

class Expression21(Expression):
    """
    List Tokenizing->Delimiters->Get delimiter index

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        value = self.next_argument()
        return instance.objectPlayer.delimiters.index(value)

class Expression22(Expression):
    """
    List Tokenizing->Delimiters->Get default delimiter
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_default_delimiter()

class Expression23(Expression):
    """
    List Tokenizing->Delimiters->Get default delimiter index
    Return type: Int
    """

    def get(self, instance):
        objectPlayer = instance.objectPlayer
        return objectPlayer.delimiters.index(
            objectPlayer.get_default_delimiter())

class Expression24(Expression):
    """
    List Tokenizing->Get number of elements
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.split())

class Expression25(Expression):
    """
    List Tokenizing->Set element

    Parameters:
    0: (not found) (String)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        values = instance.objectPlayer.split(True)
        value = self.next_argument()
        index = self.next_argument() - 1
        values[index * 2] = value
        return ''.join(values)

class Expression26(Expression):
    """
    List Tokenizing->Insert element

    Parameters:
    0: (not found) (String)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        values = instance.objectPlayer.split(True)
        value = self.next_argument()
        index = self.next_argument() - 1
        index *= 2
        if index == 0:
            values.insert(index, instance.objectPlayer.get_default_delimiter())
            values.insert(index, value)
        elif index >= len(values) - 1:
            values.insert(index, instance.objectPlayer.get_default_delimiter())
            values.insert(index, value)
        else:
            values.insert(index, value)
            values.insert(index, instance.objectPlayer.get_default_delimiter())
        return ''.join(values)

class Expression27(Expression):
    """
    List Tokenizing->Append element

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        values = instance.objectPlayer.split(True)
        value = self.next_argument()
        values.append(instance.objectPlayer.get_default_delimiter())
        values.append(value)
        return ''.join(values)

class Expression28(Expression):
    """
    List Tokenizing->Prepend element

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        values = instance.objectPlayer.split(True)
        value = self.next_argument()
        values.insert(0, instance.objectPlayer.get_default_delimiter())
        values.insert(0, value)
        return ''.join(values)

class Expression29(Expression):
    """
    List Tokenizing->Get element

    Parameters:
    0: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument() - 1
        try:
            return instance.objectPlayer.split()[int(index)]
        except IndexError:
            return ''

class Expression30(Expression):
    """
    List Tokenizing->Get first element
    Return type: Int
    """

    def get(self, instance):
        try:
            return instance.objectPlayer.split()[0]
        except IndexError:
            return ''

class Expression31(Expression):
    """
    List Tokenizing->Get last element
    Return type: Int
    """

    def get(self, instance):
        try:
            return instance.objectPlayer.split()[-1]
        except IndexError:
            return ''

class Expression32(Expression):
    """
    List Tokenizing->Find element matching

    Parameters:
    0: (not found) (String)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        values = instance.objectPlayer.split()
        value = self.next_argument()
        index = self.next_argument() - 1
        pat = instance.objectPlayer.convert_pattern([value])
        pat = '^' + pat + '$'
        pat = re.compile(pat)
        i = 0
        for n, item in enumerate(values):
            match = pat.match(item)
            if match != None:
                if i == index:
                    return n + 1
                i += 1
        return 0

class Expression33(Expression):
    """
    List Tokenizing->Find element containing

    Parameters:
    0: (not found) (String)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        values = instance.objectPlayer.split()
        value = self.next_argument()
        index = self.next_argument() - 1
        pat = instance.objectPlayer.get_pattern([value])
        i = 0
        for n, item in enumerate(values):
            match = pat.match(item)
            if match != None:
                if i == index:
                    return n + 1
                i += 1
        return 0

class Expression34(Expression):
    """
    List Tokenizing->Delete element

    Parameters:
    0: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        values = instance.objectPlayer.split(True)
        index = self.next_argument() - 1
        index *= 2
        if index == 0:
            values.pop(0)
            values.pop(0)
        elif index >= len(values) - 1:
            values.pop(-1)
            values.pop(-1)
        else:
            values.pop(index)
            values.pop(index)
        return ''.join(values)

class Expression35(Expression):
    """
    List Tokenizing->Swap elements

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        values = instance.objectPlayer.split(True)
        index1 = (self.next_argument() - 1) * 2
        index2 = (self.next_argument() - 1) * 2
        item1 = values[index1]
        item2 = values[index2]
        values[index1] = item2
        values[index2] = item1
        return ''.join(values)

class Expression36(Expression):
    """
    List Tokenizing->Sort elements ascending
    Return type: Int
    """

    def get(self, instance):
        original = instance.objectPlayer.split(True)
        sortedValues = sorted(original[::2])
        for i in xrange(0, len(original), 2):
            original[i] = sortedValues[i / 2]
        return ''.join(original)

class Expression37(Expression):
    """
    List Tokenizing->Sort elements descending
    Return type: Int
    """

    def get(self, instance):
        original = instance.objectPlayer.split(True)
        sortedValues = sorted(original[::2], reverse = True)
        for i in xrange(0, len(original), 2):
            original[i] = sortedValues[i / 2]
        return ''.join(original)

class Expression38(Expression):
    """
    List Tokenizing->Change delimiters

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        delimiter = self.next_argument()
        values = instance.objectPlayer.split(True)
        for i in xrange(0, len(original), 2):
            values[i] = delimiter
        return ''.join(values)

class Expression39(Expression):
    """
    Set string, return ""

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        value = self.next_argument()
        instance.objectPlayer.value = value
        return ''

class Expression40(Expression):
    """
    Set string, return 0

    Parameters:
    0: (not found) (String)
    Return type: Int
    """

    def get(self, instance):
        value = self.next_argument()
        instance.objectPlayer.value = value
        return 0

import hashlib

class Expression41(Expression):
    """
    Filters->Get MD5 Signature
    Return type: Int
    """

    def get(self, instance):
        return hashlib.md5(instance.objectPlayer.value).hexdigest()

CASE_INSENSITIVE = 0
SEARCH_LITERAL = 0

def find_nth(haystack, needle, n):
    start = haystack.find(needle)
    while start >= 0 and n > 0:
        start = haystack.find(needle, start+len(needle))
        n -= 1
    return start

class DefaultObject(HiddenObject):
    value = None
    delimiters = None
    defaultDelimiter = None
    
    caseSensitive = False
    wildcardSearch = False
    
    def created(self, data):
        self.delimiters = []
        self.defaultDelimiter = ''
        
        data.skipBytes(4)
        self.value = data.readReader(1025).readString()
        self.caseSensitive = data.readShort() != CASE_INSENSITIVE
        self.wildcardSearch = data.readShort() != SEARCH_LITERAL
    
    def split(self, keepDelimiters = False):
        pat = self.get_pattern(self.delimiters, keepDelimiters)
        return pat.split(self.value)
    
    def join(self, value):
        return self.get_default_delimiter().join(value)
    
    def get_default_delimiter(self):
        if self.defaultDelimiter in self.delimiters:
            return self.defaultDelimiter
        return self.delimiters[-1]
        
    def get_pattern(self, value, *arg, **kw):
        return get_pattern(value, not self.caseSensitive, self.wildcardSearch,
            *arg, **kw)
    
    def convert_pattern(self, value, *arg, **kw):
        return convert_pattern(value, not self.caseSensitive, 
            self.wildcardSearch, *arg, **kw)
    
    def get_substring_index(self, value, index):
        if self.wildcardSearch:
            pat = self.get_pattern([value])
            return [m.start() for m in re.finditer(pat, self.value)][index]
        compare = self.value
        if not self.caseSensitive:
            value = value.lower()
            compare = compare.lower()
        return find_nth(compare, value, index)
    
    def get_last_substring_index(self, value):
        if self.wildcardSearch:
            pat = self.get_pattern([value])
            values = [m.start() for m in re.finditer(pat, self.value)]
            return values[-1]
        compare = self.value
        if not self.caseSensitive:
            value = value.lower()
            compare = compare.lower()
        count = compare.count(value)
        return find_nth(compare, value, count - 1)

class parser(UserExtension):
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
        15 : Action15,
        16 : Action16,
        17 : Action17,
        18 : Action18,
        19 : Action19,
        20 : Action20,
        21 : Action21,
        22 : Action22,
        23 : Action23,
    }
    
    conditions = {
        0 : Condition0,
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
        3 : Expression3,
        4 : Expression4,
        5 : Expression5,
        6 : Expression6,
        7 : Expression7,
        8 : Expression8,
        9 : Expression9,
        10 : Expression10,
        11 : Expression11,
        12 : Expression12,
        13 : Expression13,
        14 : Expression14,
        15 : Expression15,
        16 : Expression16,
        17 : Expression17,
        18 : Expression18,
        19 : Expression19,
        20 : Expression20,
        21 : Expression21,
        22 : Expression22,
        23 : Expression23,
        24 : Expression24,
        25 : Expression25,
        26 : Expression26,
        27 : Expression27,
        28 : Expression28,
        29 : Expression29,
        30 : Expression30,
        31 : Expression31,
        32 : Expression32,
        33 : Expression33,
        34 : Expression34,
        35 : Expression35,
        36 : Expression36,
        37 : Expression37,
        38 : Expression38,
        39 : Expression39,
        40 : Expression40,
        41 : Expression41,
    }

extension = parser()

def get_extension():
    return extension
