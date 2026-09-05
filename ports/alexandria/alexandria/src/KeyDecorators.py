# Functionality for routing keypresses to different components of the engine
# has to handle being able to send messages about key up and key down events.
# We implement this with functions which are called with a "start" parameter
# True for keydown and False for keyup events. One nice feature of this is
# that we can use decorators to specify properties of the components.
# For instance, @toggle() specifies that the component is in a "state" of
# either True or False, and when there's a key press, goes from one to
# the other, but doesn't change again until the key is let go.

# This file is for decorators for handling keypress repeat-rate
# functionality.  State is kept in attrs in self. For a func named
# foo, key state is self.key_foo, and toggle state is self.state_foo.
# The function will be called with the new state.
def toggle(starts=False):
    def toggle_decorator(func):
        def handler(self, start, name=func.__name__):
            # Actually handle keypress
            if start == True and getattr(self, 'key_%s'%name, False) == False:
                setattr(self, 'state_%s' % name,
                        not getattr(self, 'state_%s'%name, starts))
                func(self, getattr(self, 'state_%s'%name))
                setattr(self, 'key_%s' % name, True)
            elif start == False:
                setattr(self, 'key_%s' % name, False)
        handler.__name__ = func.__name__
        return handler
    return toggle_decorator

# After every keypress, ignore the next `period` keypresses.
# A keyup will reset this.
# The called function will be called with no arguments (besides self).
def periodic(period):
    def period_decorator(func, period=period):
        def handler(self, start, name=func.__name__):
            if start == True:
                remaining = getattr(self, 'remaining_%s'%name, 0)
            if start == None:
                remaining = getattr(self, 'remaining_%s'%name, period)

            if start in (True, None):
                if remaining <= 0:
                    setattr(self, 'remaining_%s'%name, period)
                    func(self)
                else:
                    setattr(self, 'remaining_%s'%name, remaining-1)

            if start == False:
                if hasattr(self, 'remaining_%s'%name):
                    delattr(self, 'remaining_%s'%name)

        handler.__name__ = func.__name__
        return handler
    return period_decorator

# Like the periodic decorator, but counts using self.game.frames
# instead of numbers-of-calls. This way you can't tap the "shoot" key and fire
# more than once every ten frames!
# If rapid=True, then reset on keyup.
def periodic_frames(period, rapid=False):
    def period_decorator(func, period=period, rapid=rapid):
        def handler(self, start, name=func.__name__):
            if start == True or start == None:
                last = getattr(self, 'last_%s'%name, -period)
                if self.game.frames - last >= period:
                    setattr(self, 'last_%s'%name, self.game.frames)
                    func(self)
            if start == False and rapid:
                setattr(self, 'last_%s'%name, self.game.frames - period)

        handler.__name__ = func.__name__
        return handler
    return period_decorator
