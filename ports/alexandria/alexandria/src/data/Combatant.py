import Object
import Bullet
import Utils
from Constants import *

class Combatant(Object.Object):
    '''Class representing a more-or-less sentient game object: something which acts or
    shoots. Combatants can trigger doors and mines.'''
    bulletai = None
    attackimg = None
    bulletsound = None
    show_info = True

class Player(Combatant):
    killstr = "human"
    side = SIDE_PLAYER
    color = (0x00, 0x80, 0xff)
    bulletstyle = 'human'
    bulletcolor = (0x00, 0x20, 0xff)
    gear = True
    def __init__(self, size, bulletspeed=None, killstr=None, **kwargs):
        kwargs.setdefault('health',100)
        kwargs.setdefault('angle', 0)
        super(Player, self).__init__(**kwargs)#Geometry([Round(16)]), pos)
        if killstr: self.killstr = killstr
        self.size = size
        self.bulletspeed = bulletspeed
        #self.hooked = False
        self.bulletpos = None
        self.geom = None
        self.shots_fired = {}  # bullettype -> int

class dialogelement(object):
    def __init__(self, action, key=None, enabled=None, depends=None, once=True):
        self.action = action
        self.key = key
        if not depends: depends = []
        self.depends = depends
        if enabled == None:
            if depends: enabled = False
            else: enabled = True
        self.enabled = enabled
        self.once = once

    def undepend(self, obj, key):
        if (obj, key) in self.depends:
            self.depends.remove((obj, key))

        return len(self.depends) == 0

CONTROLLED_DEPENDENCIES = {}

class Controlled(Combatant):
    killstr = "enemy"
    side = SIDE_ENEMIES
    def __init__(self, ai=None, size=None, bulletpos=None, health=None,
                 bulletspeed = None, bulletexplodeimage=None,
                 bulletimage=None, bulletsize=None, killstr=None,
                 bulletai=None, bullettype=None,
                 bulletstyle='enemy', side=None,
                 rect=None,
                 **kwargs):
        kwargs.setdefault('health',health)
        if kwargs.has_key('show_info'): self.show_info = kwargs.pop('show_info')

        super(Controlled, self).__init__(**kwargs)#Geometry([Round(16)]), pos)
        self.size = size
        self.ai = ai
        # WandersRects needs this:
        self.rect = rect
        self.bulletpos = bulletpos
        self.bulletspeed = bulletspeed
        self.bulletsize = bulletsize
        if killstr: self.killstr = killstr
        if bulletimage:
            self.bulletimage = bulletimage
        if bulletexplodeimage:
            self.bulletexplodeimage = bulletexplodeimage
        if bulletai:
            self.bulletai = bulletai
        self.bullettype = bullettype
        self.bulletstyle = bulletstyle
        # dialog stuff
        self.dialogsets = [Utils.DialogSet(self)]
        self.current_dialogset = self.dialogsets[0]
        self.disabled_dialogs = {}

        self.color = (0xff, 0x00, 0x00)
        if side:
            self.side = side
            if side == SIDE_PLAYER:
                self.color = Player.color
                self.bulletcolor = Player.bulletcolor

        if self.color == (0xff, 0x00, 0x00):
            self.bulletcolor = (0x22, 0xff, 0x22)
        
    def pre_collide(self, o2, pass2, game, **kwargs):
        if isinstance(o2, Player): # you a playa?
            self.speak(game)

    def struck(self, beam, pos2, game):
        self.speak(game)

    def shoot(self, game, bullettype, userbullet=False, bkwargs = {}, **kwargs):
        if userbullet: b = bullettype
        elif self.bullettype: b = self.bullettype
        else:
            b = bullettype
        if not b:
            print "shooting blanks!!"
            b = Bullet.Bullet

        bkwargs.setdefault('killstr', self.killstr)
        if issubclass(b, Bullet.Bullet):
            d = {'bounces': 0, 'size': self.bulletsize}
            d.update(bkwargs)
            b0 = b(self, **d)
            game.shoot(self, b0,
                       style=self.bulletstyle, **kwargs)
            return b0
        else:
            game.add_beam(self, b(self, **kwargs))

            
    def speak(self, game):
        # pick the dialog to use
        if self.current_dialogset.empty(): return

        dlg = self.current_dialogset.next()
        if not dlg: return
        action = dlg.action
        if game.add_action(action.thread(game, self, self),
                           dialog=True):
            self.current_dialogset.advance(dlg.key)
            action.restart_goals(game)
            self.trigger_dependencies(dlg.key)
            if dlg.once:
                self.current_dialogset.remove(dlg.key)

    def trigger_dependencies(self, key):
        if not CONTROLLED_DEPENDENCIES.has_key((self, key)): return
        for obj, k2 in CONTROLLED_DEPENDENCIES[(self, key)]:
            if obj.disabled_dialogs[k2].undepend(self, key):
                obj.enable_dialog(k2)

    def _add_dialog(self, dlgaction, depends=None, to=None, **kwargs):
        newdepends = []
        if depends == None: depends = []
        for shape, key in depends:
            obj = (shape._object, key)
            newdepends.append(obj)

        dlg = dialogelement(dlgaction, depends=newdepends, **kwargs)
        ds = to
        if not ds: ds = self.current_dialogset
        if not dlg.key:
            dlg.key = ds.new_key()
        if not dlg.enabled: self.disabled_dialogs[dlg.key] = dlg
        else:
            ds.add(dlg, dlg.key)

        for obj in dlg.depends:
            CONTROLLED_DEPENDENCIES.setdefault(obj, []).append((self, dlg.key))

    def remove_dialog(self, key):
        self.current_dialogset.remove(key)

    def new_dialogset(self):
        ds = Utils.DialogSet(self)
        self.dialogsets.append(ds)
        return ds

    def switch_dialogset(self, ds):
        if ds not in self.dialogsets:
            print "Warning: switching to dialogset", ds, "not in", self
        self.current_dialogset = ds

##    def enable_dialog(self, key):
##        i = self._find_dialog_i(key)
##        self.dialogs[i].enabled = True
##        self.new.append(i)

##    def disable_dialog(self, key):
##        i = self._find_dialog_i(key)
##        self.dialogs[i].enabled = False
##        if i in self.new: self.new.remove(i)

class Powerup(Object.Object):
    def __init__(self, flavor=None, args={}, **kwargs):
        self.flavor = flavor
        self.args = args
        # this next line magically creates a bound method. See "descriptors".
        self.actfunc = self.ACTFUNCS[flavor].__get__(self, self.__class__)
        super(Powerup, self).__init__(**kwargs)
        
    def passable(self, o2, game, **kwargs):
        if isinstance(o2, Controlled):
            return True # so that enemies can't get it?
        return False

    def pre_collide(self, o2, game, **kwargs):
        if isinstance(o2, Player):
            game.queue_kill(self, 0)
            self.actfunc(o2, game)
            return True # pass through

    def healfunc(self, o2, game):
        print "healing", o2
        if self.args.has_key('amount'):
            game.change_geom_health(o2, self.args['amount'])
        else:
            game.set_geom_health(o2, 100)

    ACTFUNCS = {"heal": healfunc}

