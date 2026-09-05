import math
import operator
import Image
import PhysicsController
import Game
import Rope
from Object import Object
import AI
import Combatant

PASS = 'pass'
BOUNCE = 'bounce'

class Bullet(Object):
    size=4
    ttl = None
    ai = AI.NoAI()
    speed=10
    splash=False
    distfactor = 1
    forcescale = 1.0
    strength = 2
    def __init__(self, shooter, bounces=-1, size=None, strength=None,
                 killstr = "", ttl='', friendly=False, speed=None, splash=False,
                 distfactor=None, forcescale=None,
                 **kwargs):
        super(Bullet, self).__init__(**kwargs)
        self.shooter = shooter
        self.bounces = bounces
        self.side = shooter.side
        self.color = shooter.bulletcolor
        if size != None: self.size = size
        if speed != None: self.speed = speed
        if splash != None: self.splash = splash
        if distfactor != None: self.distfactor = distfactor
        self.friendly = friendly
        if isinstance(strength, (int, float)):
            self.strength = strength
        if isinstance(forcescale, float):
            self.forcescale = forcescale
        self.killstr = killstr
        if shooter.bulletai:
            self.ai = shooter.bulletai
        if ttl != '': self.ttl = ttl
        if self.ttl:
            self.ttl = self.ttl # make instance attribute from class attribute

    def add_geometry(self, geometry):
        pass

    def passable(self, part, o2, n, t, game):
        if self.shooter == o2: return True
        if self.friendly == PASS and self.side == o2.side and \
           isinstance(o2, (Combatant.Combatant, Hook)): return True
        return False

    def pre_collide(self, pass1, o2, p2, pass2, n, game, **kwargs):
        if self.static: return
        if not pass2 and self.bounces > 0:
            # Should I bounce?
            if not isinstance(o2, Combatant.Combatant) or \
                   (o2.side == self.side and self.friendly):
                self.bounces -= 1
                return
        if (o2.side == self.side and self.friendly):
            # Don't damage the other guy
            self.explode(game)
            return
        
        self.hit(game, n, o2, p2)

        return True

    def hit(self, game, n, obj, geom):
        strength = self.strength
        game.hit(geom, self.killstr, strength)
        if not obj.static:
            m = game.FORCESCALE * self.forcescale
            accel = [n[0]*strength*m, n[1]*strength*m]
            game.add_impulse(obj, accel)

        self.explode(game)

    def do_splash_damage(self, game):
        if not self.splash: return
        
        geom = game.geometry
        c = geom.get_pos(self)
        for obj in geom.bodies.keys():
            p = geom.get_pos(obj)
            diff = c[0]-p[0], c[1]-p[1]
            # splash damage down as the square of the distance?
            dist = math.sqrt(diff[0]*diff[0]+diff[1]*diff[1])
            damage = self.splash - self.distfactor*dist
            if damage <= 0: continue
            for g in geom.geoms[obj].values():
                game.hit(g, killstr=self.killstr, strength=damage)

    def explode(self, game=None):
        # FIXME: please see src/Game.py for what's going on here.
        if not game: game = self.game

        self.do_splash_damage(game)

        c = game.geometry.get_pos(self)
        game.queue_kill(self, 0)
        e = self.style.explodeimage
        if not isinstance(e, list):
            e = [e]
        game.make_explosion(c, game.get_angle(self), e[0],
                            sound=self.style.explodesound, bullet=self)
        for image in e[1:]:
            game.make_explosion(c, game.get_angle(self), image)

    def die(self, game):
        self.do_splash_damage(game)
        super(Bullet, self).die(game)

    def expire(self, game):
        self.explode(game)

class Hook(Bullet):
    size = 4
    speed = 20
    def __init__(self, player):
        super(Hook, self).__init__(player)

    def add_geometry(self, geometry):
        self.geometry = geometry

    def pre_collide(self, o2, p2, pass2, pos, t, n, game, **kwargs):
        if pass2:
            return
        v = map(lambda x: t*x, n[:2])
        pos = map(operator.add, pos, v)
        
        game.add_rope(Rope.ODERope, self.shooter, o2, p2, pos, 100)
        #self.player.hooked = self
        game.queue_kill(self, 0)

        game.make_explosion(pos, game.get_angle(self), 'beamhook')

        if isinstance(o2, Combatant.Combatant):
            o2.speak(game)

class Mine(Bullet):
    size = 5
    ttl = 150

    collision_class = 0x2
    def __init__(self, *args, **kwargs):
        kwargs['bounces'] = 2
        super(Mine, self).__init__(*args, **kwargs)
        
    def passable(self, part, o2, n, t, game):
        if self.side == o2.side: return True
        return False

    def pre_collide(self, o2, p2, n, game, **kwargs):
        if not (isinstance(o2, Combatant.Combatant)) and\
           not (isinstance(o2, Bullet)):
            return super(Mine, self).pre_collide(o2=o2, p2=p2, n=n, game=game, **kwargs)

        self.hit(game, n, o2, p2)
        return True
