import os

def find_relative(current, target):
    l, tail = os.path.split(current)
    while l:
        f = os.path.join(l, target)
        if os.path.exists(f):
            return f
        l, tail = os.path.split(l)

# For setting attributes in shapes which affect their objects.
# Typical use might be to set a position. If you set a ShapeWrapper's
# position, it will change the object (if it has been placed) or the
# shape (if it has not), which will later change the shape.  This is
# necessary so that Objects can be given to Align with (the Align
# takes ShapeWrappers and uses the Shapes).  There might be more
# elegant ways to do this -- convert Shape.rect into some kind of
# Object.rect? How would Package get the size of its contents? -- but
# I'm kind of skeptical.
class ShapeWrapper(object):
    def __init__(self, shape):
        self.__dict__['shape'] = shape
        
    def __setattr__(self, attr, val):
        try:
            setattr(self.__dict__['shape']._object, attr, val)
        except:
            setattr(self.__dict__['shape'], attr, val)

    def __getattr__(self, attr):
        if attr == 'shape': return self.__dict__['shape']
        try:
            return getattr(self.__dict__['shape']._object, attr)
        except:
            return getattr(self.__dict__['shape'], attr)

class Deferred(object):
    """Class to represent calling a function later.

    Sort of like the Lisp quote function. The idea is that you do:

        c = Deferred(class, args, kwargs)
        newc = c()   # create an object of class, called with args and kwargs

    But of course you can use this with functions too. Partial application?"""
    def __init__(self, f, args, kwargs=None):
        self.target = f
        try:
            self.args = tuple(args)
        except:
            self.args = (args,)
        if not kwargs:
            kwargs = {}
        self.kwargs = kwargs

    def __call__(self, *args, **kwargs):
        d = dict(self.kwargs)
        d.update(kwargs)
        a = tuple(self.args) + args
        return self.target(*a, **d)

    def call(self, func, *args, **kwargs):
        '''Like __call__() except on a different function.'''
        d = dict(self.kwargs)
        d.update(kwargs)
        a = tuple(self.args) + args
        return func(*a, **d)
            
OPPOSITES = {'left': 'right', 'right':'left', 'top':'bottom', 'bottom':'top'}
OTHERCENTER = {'left': 'centery', 'right': 'centery',
               'top': 'centerx', 'bottom': 'centerx'}

class DialogSet(object):
    def __init__(self, controlled):
        self.keys = []
        self.newkeys = []
        self.dialogs = {}
        self.lastkey = None
        self.defaulted = 0
        self.controlled = controlled

    def empty(self):
        return not self.keys

    def new_key(self):
        i = self.defaulted
        self.defaulted += 1
        return i

    def add(self, dialog, key):
        self.keys.append(key)
        self.newkeys.append(key)
        self.dialogs[key] = dialog
        return key

    def remove(self, key):
        # If self.lastkey is in the list of keys before this, make sure
        # it still is afterwards
        if self.lastkey == key:
            self.lastkey = self.keys.index(key)-1
        self.keys.remove(key)
        if key in self.newkeys:
            self.newkeys.remove(key)
        del self.dialogs[key]

    def next(self):
        '''Returns the next dialog to be used.

        Note: Doesn't advance the dialogs at all. We defer that to advance().'''
        if self.newkeys:
            key = self.newkeys[0]  # don't pop until it goes through
            spin = False
        else:
            if self.lastkey == None:
                i = 0
            else:
                # Either: self.lastkey is in the list of keys, or the list
                # is empty.
                if not self.keys: return None
                i = self.keys.index(self.lastkey)
            while not self.dialogs[self.keys[i]].enabled and self.lastkey != self.keys[i]:
                i = (i+1)%len(self.keys)
                if i == start: raise ValueError, "No more dialogs"
            key = self.keys[i]
        return self.dialogs[key]
            
    def advance(self, key):
        if key in self.newkeys:
            self.newkeys.remove(key)
            self.lastkey = None # start from the beginning
            # Should we really? If this dialog is #2 in the list, and
            # there's another one at #3, then this dialog will get
            # played twice before #3 is heard once. However, if we
            # go to #3 after this one, then it's kind of disorienting.
            # Is it really? Or is it only because I personally expect
            # the next dialog to be the beginning? Dunno.
        else:
            self.lastkey = key

    def switch(self):
        self.controlled.switch_dialogset(self)

def fade_color(i, FADE_IN, delay):
    if 0 <= i < FADE_IN:
        c = i*256/FADE_IN
    elif FADE_IN <= i < FADE_IN + delay:
        c = 255
    elif FADE_IN + delay <= i < 2*FADE_IN + delay:
        c = 256-(256/FADE_IN)*(i-(FADE_IN+delay-1))
    elif 2*FADE_IN + delay == i:
        c = 0
    else: raise IndexError
    return c

def fade_out_color(i, FADE_OUT):
    return fade_color(i+FADE_OUT, FADE_OUT, 0)

def fade_in_color(i, FADE_IN, delay):
    if i >= FADE_IN + delay:
        raise IndexError
    return fade_color(i, FADE_IN, delay)
