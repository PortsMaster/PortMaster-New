# * Goal. This represents a "goal" for the player. An event can be waited
#   on. Goals can also have "meanwhile" patterns. If A is a meanwhile
#   pattern of event B, A's lifetime is a subset of B's lifetime. If B
#   ends, A ends immediately.
import types
import pygame.constants
from data import Characters
from pygame.rect import Rect
from Vector import listify
import GUIDialogs
from Utils import ShapeWrapper
from Shapes import Shape
import Patterns

class Goal(object):
    '''Goal: class to represent a condition

    The goal class, in its simplest form, represents a goal for the player.
    It is a simple class with three basic functions:

        start(game)
        check(game)
        stop(game)

    check(game) returns True if the condition has been reached.

    Each Goal becomes a function, goal(...), in a level file, which means
    "wait until this is accomplished". In a pattern, a Goal represents waiting
    until the Goal has been achieved.

    Each goal "returns" through the method goal.value(game), and for certain
    goals, goal.response().

    Calling goal.start(game) adds it to the game, and goal.stop(game)
    removes it. The player sees representations of all goals which are
    currently active, so be sure to remove goals when you are done with them.

    Most goals need to be restarted before they can be used again. Although
    these goals could be designed so that calling start() on them
    automatically does this (or something analagous), we decided not to do
    that because it makes Goals too complicated -- ultimately all they are
    is an OO representation of a boolean function.'''
    debug = False
    visible = False
    def __init__(self, meanwhile=None, debug=False, visible = None):
        if isinstance(meanwhile, Goal): meanwhile = Patterns.Pattern([meanwhile])
        self.meanwhile = meanwhile
        self.action = None
        if visible != None:
            self.visible = visible
        if debug: self.debug = debug
        
    def check(self, game):
        return self._check(game)
    def _check(self, game):
        pass

    def handle_key(self, key):
        pass

    def value(self, game):
        return None

    def response(self):
        """For those Goals that have responses that
        don't require a Game to return, this function can be provided too."""
        return None

    def start(self, game):
        game.goals.append(self)
        if self.meanwhile:
            self.action = self.meanwhile.thread(game, self, self)
            game.add_action(self.action)
        self._start(game)

    def _start(self, game):
        pass

    def restart(self, game):
        pass

    def stop(self, game):
        game.goals.remove(self)
        if self.action:
            if game.stop_action(self.action):
                self.meanwhile.stop(game)
        self._stop(game)
    def _stop(self, game):
        pass

class ObjectIn(Goal):
    def __init__(self, shape, area, rel=None, **kwargs):
        super(ObjectIn, self).__init__(**kwargs)
        self.shape = shape
        self.rel = rel
        self.area = Rect(area)

    def _check(self, game):
        if self.rel:
            area = self.area.move(game.geometry.get_pos(self.rel._object))
        else: area = self.area
        return game.geometry.contained(self.shape._object, area)

class AIDone(Goal):
    def __init__(self, enemy, **kwargs):
        super(AIDone, self).__init__(**kwargs)
        self.shape = enemy

    def _start(self, game):
        # Don't fetch object until necessary (in case it hasn't been placed yet)
        self.enemy = self.shape._object

    def _check(self, game):
        return self.enemy.ai.done(self.enemy, game)

    def _stop(self, game):
        pass

class Kills(Goal):
    def __init__(self, shape, **kwargs):
        super(Kills, self).__init__(**kwargs)
        self.shape = shape

    def _start(self, game):
        if isinstance(self.shape, ShapeWrapper) or \
               isinstance(self.shape, Shape):
            self.obj = self.shape
            self._check = self.check_obj
        else:
            self.obj = self.shape
            self._check = self.check_geom

    def _stop(self, game):
        del self._check  # reference loop

    def check_geom(self, game):
        if isinstance(game.get_geom_health(self.obj), types.NoneType):
            return False
        else:
            return game.get_geom_health(self.obj) <= 0

    def check_obj(self, game):
        # return False if the object hasn't been placed yet
        return self.obj._object and self.obj._object.dead

class Heals(Goal):
    def __init__(self, damage, **kwargs):
        super(Heals, self).__init__(**kwargs)
        self.damage = damage

    def _check(self, game):
        return self.damage.amount <= 0

class Isnt(Goal):
    def __init__(self, event, **kwargs):
        super(Isnt, self).__init__(**kwargs)
        self.event = event

    def _check(self, game):
        return self.event.check(game)

    def _start(self, game):
        self.event.start(game)

    def _stop(self, game):
        self.event.stop(game)

class MultiGoal(Goal):
    def __init__(self, *events, **kwargs):
        super(MultiGoal, self).__init__(**kwargs)
        self.events = listify(events)

    def __iter__(self):
        return iter(self.events)
    

class Which(MultiGoal):
    def _check(self, game):
        for i, e in enumerate(self.events):
            if e.check(game):
                self.success = i
                return True

    def value(self, game):
        return self.success

    def _start(self, game):
        for e in self.events:
            e.start(game)

    def _stop(self, game):
        for e in self.events:
            e.stop(game)

class All(MultiGoal):
    def _check(self, game):
        for e in self.events:
            if not e.check(game):
                return False
        return True

    def _start(self, game):
        for e in self.events:
            e.start(game)

    def _stop(self, game):
        for e in self.events:
            e.stop(game)

class Sequence(MultiGoal):
    '''Sequencing meta-event.

    Create with a list of events. This event will start the first, check it
    until finished, and then stop it before proceeding to the next, and
    repeating.'''
    def __init__(self, *events, **kwargs):
        super(Sequence, self).__init__(**kwargs)
        if isinstance(events[0], list):
            raise TypeError, "Sequence events are passed as *args"
        self.events = list(events)
        self.n = 0

    def restart(self, game):
        for event in self.events[:self.n]:
            event.restart(game)
        self.n = 0

    def _check(self, game):
        # This is a hack -- more elegant away to do simple things?
        while self.n < len(self.events) and self.events[self.n].check(game):
            self.events[self.n].stop(game)
            self.n += 1
            if self.n < len(self.events): # Goals left?
                self.events[self.n].start(game) # start next
        return self.n == len(self.events)

    def _start(self, game):
        if self.n < len(self.events):
            self.events[self.n].start(game)

    def _stop(self, game):
        if self.n < len(self.events):
            self.events[self.n].stop(game)

class Seconds(Goal):
    def __init__(self, n, **kwargs):
        super(Seconds, self).__init__(**kwargs)
        self.n = n

    def _start(self, game):
        self.restart(game)
        
    def restart(self, game):
        self.t0 = pygame.time.get_ticks()

    def _check(self, game):
        return pygame.time.get_ticks() - self.t0 > self.n*1000

class Ticks(Goal):
    def __init__(self, n, **kwargs):
        super(Ticks, self).__init__(**kwargs)
        self.n = n

    def _start(self, game):
        self.restart(game)

    def restart(self, game):
        self.target = game.frames + self.n

    def _check(self, game):
        return game.frames >= self.target

class NoneGoal(Goal):
    def __init__(self, **kwargs):
        super(NoneGoal, self).__init__(**kwargs)

    def _check(self, game):
        return True

Always = NoneGoal
class Never(Goal):
    def __init__(self, **kwargs):
        super(Never, self).__init__(**kwargs)
    def _check(self, game):
        return False

class Keypress(Goal):
    def __init__(self, time=-1):
        super(Keypress, self).__init__()
        if time == -1: self.event = Never()
        else: self.event = Seconds(time)
        
    def _start(self, game):
        super(Keypress, self)._start(game)
        self.done = False
        self.event._start(game)

    def _stop(self, game):
        self.event._stop(game)

    def _check(self, game):
        if self.done: return True
        return self.event._check(game)

    def handle_key(self, key):
        self.done = True
        return True

class Dialog(Goal):
    visible = True
    def __init__(self, text, character=None, forever=False, bottom=False,
                 **kwargs):
        super(Dialog, self).__init__(**kwargs)
        self.text = text
        if not forever:
            self.event = Seconds(1+len(text)/8.0)
        else:
            self.event = Never()
        if character == None:
            character = Characters.Narrator
        self.character = character
        self.done = False
        self.bottom = bottom

    def handle_key(self, key):
        if key == pygame.constants.K_RETURN:
            self.done = True
            return True

    def restart(self, game):
        self.event.restart(game)
        self.done = False

    def _check(self, game):
        if self.done: return True
        return self.event.check(game)

    def _start(self, game):
        if self not in game.pastgoals:
            game.pastgoals.append(self)
        self.event.start(game)

    def _stop(self, game):
        self.event.stop(game)

def RestartDialog(text):
    return Dialog(text, forever=True)

class GUI(Goal):
    visible = True
    def __init__(self, guitype, goalargs={}, **kwargs):
        super(GUI, self).__init__(**kwargs)
        self.done = False
        self._response = None
        self.guitype = guitype
        self.goalargs = goalargs

    def _start(self, game):
        self.done = False
        self._response = None
        screen = pygame.display.get_surface()
        if self.guitype == 'level':
            d = GUIDialogs.LevelDialog
        elif self.guitype == 'pause':
            d = GUIDialogs.PauseDialog
        else:
            d = GUIDialogs.UserMenuDialog
        self.gui = GUIDialogs.MakeDialog(game, screen, d, 'Blah', **self.goalargs)
        self.gui.set_response(self.gui_over)
        game.gui = self.gui
        game.pause(True)
        self.game = game

    def value(self, game):
        return self._response

    def response(self):
        return self._response

    def gui_over(self, result, value):
        if result: self._response = value
        else: self._response = result
        self.done = True
        self.game.pause(False)

    def _check(self, game):
        return self.done

    def _stop(self, game):
        game.pause(False)
        game.gui = False

class Training(Goal):
    def __init__(self, type, args, **kwargs):
        super(Training, self).__init__(**kwargs)
        self.type = type
        self.kwargs = args

    def _check_shoot(self, game):
        if game.player.shots_fired.get(self.kwargs['bullet'], 0) > \
               self.kwargs.get('num', 0):
            return True
        return False

    def _check_switch_gears(self, game):
        if hasattr(game.player, 'gear'):
            if game.player.gear != True:
                return True
        return False

    def _check(self, game):
        return getattr(self, '_check_%s'%self.type)(game)
    
class Flag(Goal):
    '''Acceptable forms:

    Flag("x") # wait until flag x is true
    Flag("x", 4) # wait until flag x is 4'''
    def __init__(self, flag, *args, **kwargs):
        if kwargs.has_key('value'):
            self.wanted = kwargs['value']
            del kwargs['value']
        if args:
            self.wanted = args[0]
        super(Flag, self).__init__(**kwargs)
        self.flag = flag

    def _check(self, game):
        if self.debug:
            print "checking", self.flag, game.flags.get(self.flag, None)
        if not game.flags.has_key(self.flag):
            return False

        if hasattr(self, 'wanted'):
            return game.flags[self.flag] == self.wanted
        else: return bool(game.flags[self.flag])

    def value(self, game):
        return game.flags[self.flag]
        
