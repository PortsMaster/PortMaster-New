# Pattern
import Goals
import Shapes
from Utils import ShapeWrapper

class Pattern(object):
    def __init__(self, patternlist, fork = False, **args):
        self.lst = patternlist
        self.args = args
        if isinstance(patternlist, Pattern):
            self.lst = patternlist.lst
            self.args.update(patternlist.args)
        self.fork = fork
        self.running = None

    def restart_goals(self, game):
        for item in self.lst:
            if isinstance(item, Goals.Goal):
                item.restart(game)

    def thread(self, game, shape, object):
        repeat = True
        # We need to make a sensible "self". Check if we were given an
        # actual shape; if so, make a ShapeWrapper for
        # self. Otherwise, use the object itself.
        if isinstance(shape, Shapes.Shape):
            self.args.update({'self':ShapeWrapper(shape)})
        else:
            self.args.update({'self': object})

        while repeat:
            repeat = False
            for item in self.lst:
                self.running = item
                #print 'doing', self, item, shape, self.args
                if item == Repeat: repeat = True; continue
                if isinstance(item, str):
                    # If this is just an expression, try to use the result
                    # If it's a statement, of course there's nothing we can
                    # do.
                    try:
                        item = eval(item, levelglobs, self.args)
                        # Or: be sure to exclude None, ShapeWrapper, etc.
                        if not isinstance(item, Goals.Goal): continue
                    except:
                        exec(item, levelglobs, self.args); continue
                if callable(item): item(); continue

                if isinstance(item, Goals.Goal):
                    item.start(game)
                    while not item.check(game):
                        yield None
                    item.stop(game)
                    continue

                if isinstance(item, Pattern):
                    # patterns containing patterns? oh dear..
                    t = item.thread(game, shape, object)
                    for yieldable in t:
                        yield yieldable
                    continue
                
                try:
                    velo, t = item
                except:
                    raise ValueError, "couldn't unpack %s in %s" % (item, self.lst)
                if velo:
                    game.geometry.set_velo(object, velo)
                for i in range(int(t)):
                    yield None

    def stop(self, game):
        if isinstance(self.running, Goals.Goal):
            self.running.stop(game)

    def __iter__(self):
        return iter(self.lst)

class Repeat(object):
    '''Dummy object to specify that a pattern repeats.'''
    pass

def EmptyGenerator(): # generator that doesn't yield anything
    if 0:
        yield None

class Once(Pattern):
    def __init__(self, *args, **kwargs):
        self.runyet = False
        super(Once, self).__init__(*args, **kwargs)

    def thread(self, game, shape, object):
        if self.runyet:
            return EmptyGenerator()
        else:
            self.runyet = True
            return super(Once, self).thread(game, shape, object)

class On(Pattern):
    def __init__(self, shape, key):
        lst = ['shape.enable_dialog("%s")'%key]
        super(On, self).__init__(lst, shape=shape)

class Off(Pattern):
    def __init__(self, shape, key):
        lst = ['shape.disable_dialog("%s")'%key]
        super(Off, self).__init__(lst, shape=shape)
    
