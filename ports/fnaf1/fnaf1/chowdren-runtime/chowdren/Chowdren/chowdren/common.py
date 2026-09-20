import string
import os
import subprocess
import sys
from mmfparser.bytereader import ByteReader

def get_base_path():
    return os.path.join(get_root_path(), 'base')

def get_root_path():
    if hasattr(sys, 'frozen'):
        return os.getcwd()
    path = os.path.join(os.path.dirname(__file__), '..')
    return os.path.abspath(path)

def makedirs(path):
    try:
        os.makedirs(path)
    except OSError:
        return

def fix_path(path):
    return path.replace('\\', '/')

def call(args):
    exp = ' '.join(args)
    print exp
    print ''
    try:
        subprocess.check_call(args)
    except subprocess.CalledProcessError:
        print 'Error, quitting...'
        sys.exit()
        return

COMPARISONS = [
    '==',
    '!=',
    '<=',
    '<',
    '>=',
    '>'
]

VALID_CHARACTERS = string.ascii_letters + string.digits
DIGITS = string.digits

def get_method_name(value, digit_underscore = False):
    new_name = ''
    add_underscore = False
    for c in value:
        if c.isupper():
            c = c.lower()
        if c in VALID_CHARACTERS:
            if add_underscore:
                if new_name:
                    new_name += '_'
                add_underscore = False
            new_name += c
        else:
            add_underscore = True
    if digit_underscore:
        new_name = check_digits(new_name, 'meth_')
    return new_name

def get_class_name(value):
    new_name = ''
    go_upper = True
    for c in value:
        if c in VALID_CHARACTERS:
            if go_upper:
                c = c.upper()
                go_upper = False
            new_name += c
        else:
            go_upper = True
    return check_digits(new_name, 'Obj')

def check_digits(value, prefix):
    if not value:
        return value
    if value[0] in DIGITS:
        value = prefix + value
    return value

class StringWrapper(object):
    def __init__(self, value, cpp):
        self.value = value
        self.cpp = cpp

    def __str__(self):
        return self.value

    def __repr__(self):
        if self.cpp and self.value == '':
            return 'std::string()'
        new = ''
        for c in self.value:
            if c == '\\':
                new += '\\\\'
            elif c == '"':
                new += '\\"'
            elif c == '\r':
                new += '\\r'
            elif c == '\n':
                new += '\\n'
            elif c == '?':
                new += '\\?'
            elif ord(c) > 126 or ord(c) < 32:
                new += '\\' + oct(ord(c))[1:]
            else:
                new += c
        ret = '"%s"' % new
        if self.cpp:
            ret = 'std::string(%s, %s)' % (ret, len(self.value))
        return ret

def to_c(format_spec, *args, **kw):
    new_args = []
    for arg in args:
        if isinstance(arg, str):
            arg = StringWrapper(arg, kw.get('cpp', True))
        elif isinstance(arg, bool):
            if arg:
                arg = 'true'
            else:
                arg = 'false'
        new_args.append(arg)
    return format_spec % tuple(new_args)

def get_color_tuple(value):
    return (value & 0xFF, (value & 0xFF00) >> 8, (value & 0xFF0000) >> 16)

def make_color(value):
    return 'Color(%s)' % ', '.join([str(item) for item in value])

def is_qualifier(handle):
    return handle & 32768 == 32768

def get_qualifier(handle):
    return handle & 2047

def get_directions(value):
    directions = []
    for i in xrange(32):
        if value & (1 << i) != 0:
            directions.append(i)
    return directions

input_directions = [
    -1,             # 0000 Static
    8,              # 0001
    24,             # 0010
    -1,             # 0011 Static
    16,             # 0100
    12,             # 0101
    20,             # 0110
    16,             # 0111
    0,              # 1000
    4,              # 1001
    28,             # 1010
    0,              # 1011
    -1,             # 1100 Static
    8,              # 1101
    24,             # 1110
    -1              # 1111 Static
]

def get_flag_direction(value):
    return input_directions[value]

def get_input_direction(up, down, left, right):
    v = int(up) | (int(down) << 1) | (int(left) << 2) | (int(right) << 3)
    return get_flag_direction(v)

def parse_direction(value):
    if value in (0, -1):
        return 'randrange(32)'
    directions = get_directions(value)
    if len(directions) > 1:
        return 'pick_random(%s, %s)' % (len(directions),
            ', '.join([str(item) for item in directions]))
    return directions[0]

ACCELERATORS = [0.0078125, 0.01171875, 0.015625, 0.0234375, 0.03125, 0.0390625,
    0.046875, 0.0625, 0.078125, 0.09375, 0.1875, 0.21875, 0.25, 0.28125,
    0.3125, 0.34375, 0.375, 0.40625, 0.4375, 0.46875, 0.5625, 0.625, 0.6875,
    0.75, 0.8125, 0.875, 0.9375, 1.0, 1.0625, 1.125, 1.25, 1.3125, 1.375,
    1.4375, 1.5, 1.5625, 1.625, 1.6875, 1.75, 1.875, 2.0, 2.125, 2.1875,
    2.3125, 2.4375, 2.5, 2.625, 2.6875, 2.8125, 2.875, 3.0, 3.0625, 3.1875,
    3.3125, 3.375, 3.5, 3.625, 3.6875, 3.8125, 3.875, 4.0, 4.375, 4.75,
    5.125, 5.625, 6.0, 6.375, 6.75, 7.125, 7.625, 8.0, 8.75, 9.5, 10.5, 11.25,
    12.0, 12.75, 13.5, 14.5, 15.25, 16.0, 25.5625, 19.1953125, 20.375,
    22.390625, 24.0, 25.59765625, 27.1953125, 28.7734375, 30.390625, 32.0,
    38.421875, 45.59375, 52.015625, 58.4375, 64.859375, 71.28125, 77.703125,
    84.0, 100.0, 100.0]

def get_accelerator(value):
    if value <= 100:
        return ACCELERATORS[value]
    return value

ANIMATION_NAMES = [
    'STOPPED',
    'WALKING',
    'RUNNING',
    'APPEARING',
    'DISAPPEARING',
    'BOUNCING',
    'SHOOTING',
    'JUMPING',
    'FALLING',
    'CLIMBING',
    'CROUCH',
    'STAND'
]

def get_animation_name(index):
    try:
        return ANIMATION_NAMES[index]
    except IndexError:
        return str(index)

def get_sized_data(data):
    writer = ByteReader()
    writer.writeIntString(data)
    return str(writer)

TEMPORARY_GROUP_ID = 'thisisthetempid'
