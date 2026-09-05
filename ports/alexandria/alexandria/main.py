import os.path
import sys
sys.path.insert(0, os.path.abspath('src'))
sys.path.append(os.path.abspath('lib'))
import gc
import random
random.seed(4)

import EventManager

import MusicView
import View
import TitleView
import OpenView
import Scheduler
import Input
import pygame
from Vector import Vector
import PhysicsController
from Game import Game
import Level
import EnemyController
import Goals
import data.Exceptions
import MetaView
import Config
import Utils

debug = False
profile = False

# "fake" imports to fool py2exe into working
import weakref
import ode
import xode.transform
import Numeric
import pygame.locals

if "movie" in sys.argv:
    View.movie = True
    sys.argv.remove('movie')
if "debug" in sys.argv:
    debug = True
    sys.argv.remove('debug')
if "profile" in sys.argv:
    profile = True
    sys.argv.remove('profile')
try:
    campaign = sys.argv.pop(1)
    if len(sys.argv) > 1:
        level = sys.argv.pop(1)
    else:
        level = ''
    selected = True # don't run title screen
except:
    campaign, level = Config.Config.nextlevel
    selected = False
level = Level.LevelFile(campaign, level)

if debug:
    profile = True
musicview = MusicView.MusicView()


class Main(object):
    '''Class to coordinate all the components of a game: Game,
    Physics, View, MetaView, Input, etc.

    When a new level is started, a new Game is created, and therefore
    a new View, PhysicsController, etc. The only time new things are
    not created is when one level is continued into another one.

    It is assumed that play_meta will only be called once for a given
    Main object.'''
    
    def __init__(self):
        global scheduler
        global g
        self.manager = manager = EventManager.EventManager()
        Config.Config.manager = manager

        self.g = g = Game(manager)
        self.g.debug = debug
        self.scheduler = scheduler = Scheduler.Scheduler()
        self.p = PhysicsController.PhysicsController(g)
        self.enemies = EnemyController.EnemyController(g)
        self.i = Input.Input(g)
        scheduler.register_actor(self.i, self.i.thread())
        self.is_setup = False

    def play_meta(self, levelfile):
        self.metadata = levelfile.metadata()
        g.metainfo = self.metadata
        self.meta = MetaView.MetaView(g)
        self.meta.set_info(self.metadata)
        
        self.fade_out(self.meta, Goals.Keypress(time=6.625))

    def run(self, obj, goal = None):
        if goal == None: goal = Goals.Keypress()
        scheduler.register_actor(obj, obj.thread())
        try:
            Level.wait(goal, g, scheduler.poll, playable=False)
        except IndexError:
            pass # presume this means "object is over"
        scheduler.kill_actor(obj)

    def fade_out(self, obj, goal = None):
        self.run(obj, goal)
        obj.fade_out()
        self.run(obj, Goals.Never())
        obj.over()


    def play_title(self):
        self.fade_out(OpenView.OpenView())
        self.fade_out(TitleView.TitleView())

    def _setup(self):
        '''Needs to be called before the level is actually run.'''
        if self.is_setup: return
        self.is_setup = True
        self.view = View.View(g)
        self.manager.RegisterListener(self.view)
        self.manager.RegisterListener(musicview)
        scheduler.register_actor(self.g, self.g.thread())
        scheduler.register_actor(self.p, self.p.thread())
        scheduler.register_actor(self.enemies, self.enemies.thread())
        scheduler.register_actor(scheduler, scheduler.thread(self.g))
        scheduler.register_actor(self.view, self.view.thread())
        scheduler.register_actor(musicview, musicview.thread())

    def play_level(self, levelfile):
        self.metadata = levelfile.metadata()
        g.metainfo = self.metadata
        # The level could be marked "advance", and it could be marked "solved"
        # (i.e. automatically solved). If the level was solved previously,
        # you don't advance to it. For this reason, we check if we need
        # to advance first, before we check if it's automatically solved.
        if g.metainfo['advance'] and not levelfile.solved() and \
               not levelfile.level.startswith('test-'):
            # Don't advance to levels that have been solved already.
            Config.Config.nextlevel = levelfile.campaign, levelfile.level

        meta = levelfile.file_metadata()
        if meta.has_key('solved') and meta['solved']:
            # solved by default
            print 'level solved', level.campaign, level.level
            Config.Config.solved[(level.campaign, level.level)] = True
        self._setup()

        try:
            levelfile.play(g, scheduler.poll)
        except data.Exceptions.GameOverException:
            self.i.disable()
            Level.wait(Goals.RestartDialog('Press return to restart the level.'), g, scheduler.poll, playable=False)
            toret = False
        except data.Exceptions.ReturnToBase, e:
            Level.levelglobs['nextlevel'] = Level.LevelFile(*e.level)
            toret = 2
        else:
            toret = 1
        return toret

    def cleanup(self):
        '''Should be called before object is destroyed (fixes memory leaks etc.).'''
        scheduler.kill_all()
        self.view.kill_all()
        self.g.kill_all()

def unlock_level(level):
    c = level.campaign
    lev = level.level
    if not Config.Config.unlocked.has_key(c):
        Config.Config.unlocked[c] = [lev]
    else:
        if lev not in Config.Config.unlocked[c]:
            Config.Config.unlocked[c].append(lev)

def main():
    global level
    if debug:
        gc.enable()
        gc.set_debug(gc.DEBUG_UNCOLLECTABLE)
    try:    
        while True:
            # play a level
            done = False
            fresh = True # new level

            meta = level.file_metadata()

            while not done:
                # repeat level until solved (or quit)
                if fresh:
                    if not Level.levelglobs['continued']:
                        m = Main()
                        # This waits for user input, so it's inconvenient
                        # when profiling.
                        if not profile:
                            m.play_meta(level)
                    fresh = False
                else:
                    # restarting level
                    m.cleanup()
                    m = Main()
                done = m.play_level(level)
                
            oldlevel = level
            nextlevel = Level.levelglobs['nextlevel']
            if not isinstance(nextlevel, Level.LevelFile):
                nextlevelfile = "%s.py"%nextlevel
                nextlevelfile = Utils.find_relative(level.filename(), nextlevelfile)
                nextlevel = Level.LevelFile(nextlevelfile)
            wassolved = oldlevel.solved()
            # was level solved legitimately, bailed, or what?
            if done == 1:
                Config.Config.solved[(oldlevel.campaign, oldlevel.level)] = True

                if not Level.levelglobs['locked']: # is this actually useful?
                    unlock_level(nextlevel)

                if Level.levelglobs['unlock']:
                    unlevel = Level.levelglobs['unlock']
                    if '.py' not in unlevel: unlevel = unlevel + '.py'
                    unfile = Utils.find_relative(oldlevel.filename(),
                                                 unlevel)
                    unlock_level(Level.LevelFile(unfile))

            if not Level.levelglobs['continued']:
                m.cleanup()
##            if not wassolved or Level.levelglobs['selected']:
            level = nextlevel
##            else:
##                level = Level.LevelFile(*Config.Config.nextlevel)
            
    except KeyboardInterrupt, e:
        m.cleanup()
        Level.kill_all()  # reference loop
        print e
        pass
    scheduler.printstats()
    g.printstats()
    Config.Config.save_config()

if not selected and not debug:
    Main().play_title()

if profile:
    import hotshot
    prof = hotshot.Profile('run.prof')
    prof.runcall(main)
    prof.close()
else:
    main()
if debug:
    print gc.collect()
    import pprint
    pprint.pprint(gc.garbage, file('garbage.txt', 'w'))
