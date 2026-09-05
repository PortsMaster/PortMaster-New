# Level.py -- primitives for loading levels
# Classes:
# * Shape. This represents either a circle or a polygon in something's
#   geometry.
#   A shape can be placed, in which case it is also a data.Object.
#   Pos, velo, etc. can be specified in Shape constructor.
import os
import math
import random
import inspect
import pygame
import data.Rope
from data.Exceptions import *
import Event
import Goals
import Shapes
import Patterns
import Utils
import Config
import Sprite
from data import Characters, Constants, AI
import data.Bullet
import data.Beam
import Input
import Vector

PACKAGE=52 # size of the door for a package with player in it

# The globals that will be available to the level.
DEFAULT_LEVELGLOBS = {'continued': False, 'is_continued': False, 'unlock': None, 'locked': False, 'selected': False}
levelglobs = dict(DEFAULT_LEVELGLOBS)
currentglobs = levelglobs
currentlevel = None
LEVELSDIR = 'levels' + os.sep
TESTSDIR = 'tests' + os.sep
FAILEDFLAG = '__failed'

class LevelFile(object):
    '''A class representing a level/campaign pair. If level is not provided,
    level and campaign are both parsed out of campaign.'''
    def __init__(self, campaign, level = None):
        if '.' in campaign:
            campaign, ext = os.path.splitext(campaign) # strip '.py' or whatever
        if not level:
            if campaign.startswith(LEVELSDIR):
                campaign = campaign.replace(LEVELSDIR, '')
            campaign, level = os.path.split(campaign)
        self.level = level
        self.campaign = campaign

    def __eq__(self, levelfile):
        if isinstance(levelfile, LevelFile):
            return self.level == levelfile.level and self.campaign == levelfile.campaign
        return False

    def filename(self):
        dir = os.path.join(LEVELSDIR, self.campaign)
        if self.campaign == 'tests':
            dir = TESTSDIR
        return os.path.join(dir, "%s.py"%self.level)

    def metafilename(self):
        dir = os.path.join(LEVELSDIR, self.campaign)
        if self.campaign == 'tests':
            dir = TESTSDIR
        return os.path.join(dir, "%s-info.py"%self.level)

    def file_metadata(self):
        d = dict(whitelist)
        defaults = {'title': "Some level", 'subtitle': "Some data",
                    'advance': True, 'invertable': False}
        try:
            execfile(self.metafilename(), d)
        except IOError:
            pass # defaults will merge sensibly
        for key in whitelist.keys():
            del d[key] # Take out the stuff copied from the whitelist
        defaults.update(d)
        return defaults

    def metadata(self):
        d = self.file_metadata()
        d['filename'] = self.filename()
        d['solved'] = self.solved()
        return d

    def solved(self):
        return Config.Config.solved.get((self.campaign, self.level), False)

    def play(self, game, loopfunc):
        global levelglobs, currentglobs
        global currentlevel
        if levelglobs['continued'] == False:
            kill_all()    # no-longer-used levelglobs; reference loops
            levelglobs = dict(DEFAULT_LEVELGLOBS)
            currentglobs = levelglobs
        else:
            levelglobs['continued'] = False
            levelglobs['is_continued'] = True
        currentlevel = self
        game.input_disabled = False
        return run_file(self.filename(), game, loopfunc)

def list_levels(campaign):
    l = os.listdir(os.path.join(LEVELSDIR, campaign))
    files = []
    for f in l:
        head, tail = os.path.splitext(f)
        if tail.endswith('~') or tail == '.pyc' or head[0] == '_': continue
        if head.endswith('-info'): continue
        files.append (head)
    files.sort ()

    return [LevelFile(campaign, f) for f in files]
        
def wait(event, game, loopfunc, playable=True):
    # To enable recursion, we create a queue of events to process recursively.
    # The game.recurse function gets this definition:
    recevents = []
    def recurse(event):
        recevents.append(event)
        
    game.playable = playable
    event.start(game)
    try:
        while not event.check(game):
            if playable and game.player_health() <= 0:
                # if not playable, maybe we're in some state before the Player
                # object gets created.
                raise GameOverException
            if game.flags.has_key(FAILEDFLAG):
                goal = game.flags[FAILEDFLAG]
                del game.flags[FAILEDFLAG]
                raise GameOverException, goal
            # Re-set recurse definition. Higher levels of recursion might
            # point it at a different recevents list.
            game.recurse = recurse
            loopfunc()
            if recevents:
                # If we have any queued recursion events, here's where we
                # process them.
                wait(recevents.pop(), game, loopfunc, playable)
            
    finally:
        event.stop(game)
    return event.value(game)

def kill_all():
    levelglobs.clear()
    

# Level.py: functionality for loading levels
def run_file(filename, game, loopfunc):
    def wait_internal(event):
        return wait(event, game, loopfunc)
        
    def place(shape):
        object = shape.place(game)
        shape.render(game)
        return object

    def use(module, *args, **kwargs):
        # We hack together a poor man's nested scope implementation here.
        # We first copy the dictionary to an "inner" scope,
        # so that assignments don't "escape" the use(),
        # but any assignment to a variable that exists in the "outer" scope
        # "breaks out".
        f = Utils.find_relative(filename, module+'.py')
        global currentglobs
        oldglobs = currentglobs
        currentglobs = dict(currentglobs) # new scope
        execfile(f, currentglobs)
        ret = currentglobs[module](*args, **kwargs)
        oldglobs.update(ret)
        for k in currentglobs:
            # Only pass through assignments to already-existing variables
            if oldglobs.has_key(k):
                oldglobs[k] = currentglobs[k]
        currentglobs = oldglobs

    def set_thickness(newthick):
        Shapes.THICKNESS = currentglobs['THICKNESS'] = newthick

    def populate_globals(dct):
        actionfuncs = {Goals.Goal: wait_internal, Shapes.Shape: place}
        whitelist = {'len':len, 'True':True, 'False': False,
                     '__builtins__': None, 'math':math,
                     'sqrt': math.sqrt, 'rotate_around': Vector.rotate,
                     'range':range,
                     'Repeat': Patterns.Repeat, 'THICKNESS':Shapes.THICKNESS,
                     'FPS': 30,
                     'set_thickness': set_thickness,
                     'PACKAGE': PACKAGE, 'opposites':Utils.OPPOSITES,
                     'GameOver':GameOverException,
                     'map': map, 'randint':random.randint,
                     'angle_vector': Vector.angle_vector,
                     'max': max, 'min': min, 'int': int, 'float': float,
                     'enumerate': enumerate,
                     'flip': Shapes.flip, 'rotate': Shapes.rotate,
                     'list': list, 'tuple': tuple, 'dict': dict,
                     'isinstance': isinstance, 'str': str, 'repr': repr,
                     'object': object, '__name__': filename,
                     'super': super, 'defer': Utils.Deferred,
                     'style': make_style, 'Rect': pygame.Rect
                     }
        dct.update(whitelist)
        from data import CombatAI
        dct.update({'characters':Characters, 'ai':CombatAI,
                    'sprite': Sprite,
                    'bullettypes': data.Bullet, 'beam': data.Beam})
        dct.update({'wait':wait_internal, 'place':place, 'use': use})

        # These are touchy subjects. Passing the game itself is a bit of a hack.
        # So far there are only a couple of uses of these variables.
        # 1. Test cases. test-cinematic checks whether game.input_disabled has
        #    been set.
        # 2. Making the boss's bullets explode in healbeam7.
        dct.update({'game':game, 'loopfunc':None})

        dct.update({'Rope':data.Rope})
        dct.update(make_actions(game))
        for k in dir(Constants):
            if not k.startswith('_'):
                dct[k] = getattr(Constants, k)

        for name, obj in Shapes.__dict__.items()+Goals.__dict__.items():
            if isinstance(obj, type):
                for cl, func in actionfuncs.iteritems():
                    if issubclass(obj, cl):
                        dct[name.lower()] = compose(func,obj)
                        dct[name] = obj

        for name, obj in Patterns.__dict__.items():
            if isinstance(obj, type) and issubclass(obj, Patterns.Pattern):
                dct[name] = obj

        dirpart = ""
        for part in filename.split(os.sep):
            dirpart = os.path.join(dirpart, part)
            styles = os.path.join(dirpart, "styles.py")
            run_styles(styles, dct)
            library = os.path.join(dirpart, "library.py")
            run_library(library, dct)

    def run_aux(filename, dct):
        if not os.path.exists(filename):
            return {}
        execfile(filename, dct)
        return dct

    def run_library(filename, dct):
        run_aux(filename, dct)

    def make_style(name, klass, kwargs):
        s = Utils.Deferred(klass, (), kwargs)
        currentglobs[name.lower()] = compose(place, s)
        currentglobs[name] = s

    def run_styles(filename, dct):
        d = run_aux(filename, dct)
        if d.has_key('styles'):
            for name, obj in d['styles'].items():
                klass, kwargs = obj
                make_style(name, klass, kwargs)
            del d['styles']
        for key, value in d.iteritems():
            if callable(value):
                dct[key] = value
            
    Shapes.currentfile = filename # Not monkeypatch, but passing information
    Shapes.allrooms = []                # reset
    Shapes.THICKNESS = Shapes.STANDARD_THICKNESS # reset
    Shapes.scale_factor = None          # reset
    game.currentfile = filename
    populate_globals(levelglobs)
    Patterns.levelglobs = levelglobs
    execfile(filename, levelglobs)
    return True
    
def compose(f, g):
    '''Simple function compositor which has the added benefit of retaining
    definitions of f and g in a new closure.'''
    def fog(*args, **kwargs):
        return f(g(*args, **kwargs))
    return fog

whitelist = {'__builtins__': {}, 'True': True, 'False': False}
#return {'title': 'Training part 5', 'subtitle': 'n00bs in space'}

def mirror(pattern, axis):
    '''Mirrors the vector parts of a pattern in either the y or x directions.

    Useful for constructing patterns for crushers, for intance.'''
    axmult = [1, 1]
    axmult[axis] = -1
    newpat = []
    for item in pattern:
        try:
            v, t = item
            newv = (v[0]*axmult[0], v[1]*axmult[1])
            newpat.append((newv, t))
        except:
            newpat.append(item)
    return newpat

def make_actions(game):
    '''Creates the functions which need to access game when called.

    Returns a dict which can be used to update levelglobs.'''
    import pygame
    def delete(shape, label=None):
        #print 'deleting', shape, label
        if isinstance(label, str):
            label = shape.parts[label]
        if isinstance(shape, Shapes.ShapeWrapper):
            shape = shape._object
        if label != None:
            game.delete_part(shape, label)
        else:
            game.delete_object(shape, chrome=False)

    def kill(shape, label=None):
        if isinstance(label, str):
            label = shape.parts[label]
        if isinstance(shape, Shapes.ShapeWrapper):
            shape = shape._object
        if label != None:
            game.kill_part(shape, label)
        else:
            game.kill_object(shape)

    def disable(shape, label):
        game.disable(shape._object, shape.parts[label])

    def enable(shape, label):
        game.enable(shape._object, shape.parts[label])
        
    def controls(enable = [], disable = []):
        if isinstance(enable, str): enable = [enable]
        if isinstance(disable, str): disable = [disable]
        for e in enable:
            game.controls_disabled.pop(e, None) # don't throw an error
        for d in disable:
            game.controls_disabled[d] = True

    def get_control(func):
        return pygame.key.name(Input.current_keymap[func])

    def move_to(shape, pos):
        # Should not always move the center of the object!
        # That would destroy important relative relationships between, say,
        # a package (where (0, 0) is upper left) and its payload
        # (where (0, 0) is its center).
        print "moving_to"
        game.geometry.set_pos(shape._object, pos)

    def move_by(shape, dist):
        p0 = game.geometry.get_pos(shape._object)
        newp = dist[0] + p0[0], dist[1] + p0[1]
        game.geometry.set_pos(shape._object, newp)
        for r in game.ropes.values():
            if r.obj == shape._object:
                r.move(dist)

    def start(shape, pattern):
        if isinstance(shape, (Shapes.Shape, Utils.ShapeWrapper)):
            object = shape._object
        else:
            object = shape
        game.patterns[object] = Patterns.Pattern(pattern).thread(game, shape, object)

    def stop_pattern(shape):
        del game.patterns[shape._object]

    def align(shape, side, rel, pos=None):
        '''Aligns shape correctly, and returns offset that was necessary
        to align it correctly (to apply to other objects).'''
        a = Shapes.Align([(side, rel)])
        #print 'aligning'
        apos = a.compute_pos(shape)
        newpos = apos[0] + pos[0], apos[1] + pos[1]
        oldpos = game.geometry.get_pos(shape._object)
        #print 'oldpos', oldpos, 'newpos', newpos
        dist = [newpos[0]-oldpos[0], newpos[1]-oldpos[1]]
        move_by(shape, dist)
        return dist

    def cinematic(**kwargs):
        game.cinematic = kwargs
        # Special case input-disabling
        if kwargs.get('input', 'on') != 'on':
            game.input_disabled = True

    def end_cinematic():
        game.cinematic = {}

    def add_action(*args, **kwargs):
        action = Patterns.Pattern(args, **kwargs)
        t = action.thread(game, None, None)
        game.add_action(t)
        return t

    def stop_action(thread):
        game.stop_action(thread)

    def mirror_y(pattern):
        return mirror(pattern, 1)

    def mirror_x(pattern):
        return mirror(pattern, 0)

    def set_flag(flag, value):
        game.flags[flag] = value

    def get_flag(flag):
        return game.flags.get(flag, None)

    def set_inertia(val):
        game.inertia = val

    def set_scale(val):
        Shapes.scale_factor = val

    def stop(sound):
        game.post(Event.StopSoundEvent(sound))

    def play(sound, loop=None):
        event = Event.NewSoundEvent(sound, loop, False)
        game.post(event)
        return event.sound

    def parentlocals():
        f = inspect.currentframe()
        # f.f_back is caller
        # f.f_back.f_back is therefore parent
        return f.f_back.f_back.f_locals

    def fail(goal=None):
        if goal == None: goal = Goals.NoneGoal
        set_flag(FAILEDFLAG, goal)

    def exit():
        raise KeyboardInterrupt

    def get_angle(object):
        return game.get_angle(object._object)

    def set_angle(object, angle):
        game.set_angle(object._object, angle)

    def get_pos(object):
        return game.geometry.get_pos(object._object)

    return {'delete':delete, 'kill': kill, 'disable': disable, 'enable': enable,
            'controls': controls, 'get_control': get_control,
            'move_to': move_to, 'move_by': move_by,
            'align': align, 'set_flag': set_flag, 'get_flag': get_flag,
            'set_scale': set_scale, 'set_inertia': set_inertia,
            'start':start, 'stop_pattern': stop_pattern, 'mirror_y':mirror_y,
            'mirror_x':mirror_x, 'stop':stop, 'play':play,
            'cinematic': cinematic, 'end_cinematic': end_cinematic,
            'add_action': add_action, 'stop_action': stop_action,
            'parentlocals': parentlocals,
            'fail': fail, 'exit': exit,
            'get_angle': get_angle, 'set_angle': set_angle, 'get_pos': get_pos}
