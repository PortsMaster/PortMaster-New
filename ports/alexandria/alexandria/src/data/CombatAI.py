from AI import *
import Bullet
class Shoots(AI):
    '''Class to represent an AI that shoots bullets.'''
    bullettype = Bullet.Bullet
    def __init__(self, period=10, bullettype=None,
                 doneai=None, start=0, pattern=None,
                 **bkwargs):
        '''period: the number of ticks that must pass before the enemy can shoot again.
        strength: the strength of the bullet (the most common thing to change).
        bullettype: what kind of bullet to fire.'''

        super(Shoots, self).__init__(doneai=doneai)
        self.start = start
        self.period = period
        if bullettype:
            if bullettype != True:
                self.bullettype = bullettype
        self.userbullet = bool(bullettype)
        self.bkwargs = bkwargs
        self.shooting = False
        self.pattern = pattern
        self.firstframe = None

    def _run(self, enemy, game):
        if self.firstframe == None: self.firstframe = game.frames - self.start
        if not self.period: return
        if issubclass(self.bullettype, Bullet.Bullet):
            if self.period + self.firstframe < game.frames:
                self.firstframe = game.frames
                self.shoot(enemy, game)
        else: # probably a beam
            if not self.shooting:
                self.shooting = True
                self.shoot(enemy, game)

    def shoot(self, enemy, game, **kwargs):
        b = enemy.shoot(game, self.bullettype, userbullet=self.userbullet,
                    bkwargs = self.bkwargs, **kwargs)
        if self.pattern:
            game.add_pattern(b, self.pattern.thread(game, b, b))

    def stop_shooting(self, enemy, game, **kwargs):
        if not self.shooting: return
        self.shooting = False
        game.beam_off(enemy)

class Targets(Rotates, Shoots):
    def __init__(self, turnspeed = 1, **kwargs):
        super(Targets, self).__init__(turnspeed=turnspeed, **kwargs)

    def _target(self, enemy, game):
        p = game.geometry.get_pos(game.player)
        return p

    def point_to(self, target, enemy, game):
        angle = self.angle_to(target, enemy, game)
        self.face(enemy, game, angle, maybe_opposite=False)
##        dtheta = (angle - game.get_angle(enemy))%(360)
##        turnleft = self.get_left(TURNING)
##        if abs(dtheta) < turnleft:
##            game.get_angle(enemy) = angle
##            self.use_amt(TURNING, abs(dtheta))
##        else:
##            game.get_angle(enemy) = (game.get_angle(enemy)+cmp(180, dtheta)*turnleft)%360
##            self.use_amt(TURNING, turnleft)

    def _run(self, enemy, game):
        self.point_to(self._target(enemy, game), enemy, game)
        Shoots._run(self, enemy, game)
        #super(Targets, self)._run(enemy, game)

class Leads(Targets):
    def __init__(self, **kwargs):
        super(Leads, self).__init__(**kwargs)

    def _target(self, enemy, game):
        p = game.geometry.get_pos(game.player)
        p0 = game.geometry.get_pos(enemy)
        d = map(operator.sub, p, p0)
        dist = math.sqrt(d[0]*d[0]+d[1]*d[1])
        bulletspeed = 10
        if enemy.bulletspeed: bulletspeed = enemy.bulletspeed
        t = dist/bulletspeed
        v = game.geometry.get_velo(game.player)
        a = game.forces.get(game.player, (0, 0))
        # p + v*t + 1/2*a*t^2
        t0 = p[0] + v[0]*t + a[0]*t*t/2
        t1 = p[1] + v[1]*t + a[1]*t*t/2
        return [t0, t1]

class Seeds(Shoots):
    bullettype = Bullet.Mine
    def shoot(self, *args, **kwargs):
        kwargs['angle'] = random.randint(0, 360)
        kwargs['bulletspeed'] = random.randint(5, 10)
        super(Seeds, self).shoot(*args, **kwargs)

class Hunts(Orbits, Leads):
    def __init__(self, **kwargs):
        super(Hunts, self).__init__(None, 1.0/24, 1, **kwargs)
        self.target = None

    def _target(self, thing, game):
        return game.geometry.get_pos(self.target)

    def get_target(self, thing, game):
        if game.enemies:
            return random.choice(game.enemies)
        else:
            return # nothing to do

    def new_target(self, thing, game):
        return self.target.dead
            
    def check_target(self, thing, game):
        if self.target == None or self.new_target(thing, game):
            self.target = self.get_target(thing, game)
            if self.target == None: # still ??
                return False
        return True

    def run(self, thing, game):
        if not self.check_target(thing, game): return
        return super(Hunts, self).run(thing, game)

    def _run(self, thing, game):
        #self.pos = game.geometry.get_pos(self.target)
        self.pos = self._target(thing, game)
        n = self.distance_n(thing, game)
        if n > 200: 
            self.stop_shooting(thing, game)
            Orbits._run(self, thing, game)
        else:
            # shoot!!
            Leads._run(self, thing, game)
            self.stop_accelerating(thing, game)

    def stop_accelerating(self, thing, game):
        pass
    
class HuntsGeom(Hunts):
    def __init__(self, object, part, **kwargs):
        super(HuntsGeom, self).__init__(**kwargs)
        self.object = object
        self.part = part

    def get_target(self, thing, game):
        if not game.geometry.geoms[self.object._object].has_key(self.object.parts[self.part]):
            return None
        target = game.geometry.geoms[self.object._object][self.object.parts[self.part]]
        pos = self.pos_to(target.to_rect().center, thing, game)
        # targetside = the closest side of the geom
        # leftcorn, rightcorn = the corners on that side, when viewing that side
        # xaxis = the axis that has the coordinate that you compare
        #    with the targetside
        if pos[0] > 0:
            self.targetside = 'left'
            self.leftcorn = 'topleft'
            self.rightcorn = 'bottomleft'
            self.xaxis = 0
            self.forward = 1
            self.towardsangle = 0
        elif pos[0] < 0:
            self.targetside = 'right'
            self.leftcorn = 'bottomright'
            self.rightcorn = 'topright'
            self.xaxis = 0
            self.forward = -1
            self.towardsangle = 180
        elif pos[1] > 0:
            self.targetside = 'top'
            self.leftcorn = 'topright'
            self.rightcorn = 'topleft'
            self.xaxis = 1
            self.forward = 1
            self.towardsangle = 270
        else:
            self.targetside = 'bottom'
            self.leftcorn = 'bottomleft'
            self.rightcorn = 'bottomright'
            self.xaxis = 1
            self.forward = -1
            self.towardsangle = 90
        self.leftpos = getattr(target.to_rect(), self.leftcorn)
        self.rightpos = getattr(target.to_rect(), self.rightcorn)
        return target

    def done(self, thing, game):
        return self.target and self.target.health < 0

    def new_target(self, thing, game):
        return self.target.health < 0

    def _target(self, thing, game):
        return self.target.to_rect().center

    def stop_accelerating(self, thing, game):
        self.wantvelo_accel(thing, game, (0, 0), can_rotate=False)

    def new_run(self, thing, game):
        left = right = self.angle_to(self._target(thing, game), thing, game)
        for c in 'topleft', 'bottomleft', 'topright', 'bottomright':
            a = self.angle_to(getattr(self.target.to_rect(), c), thing, game)
            if a < left: left = a
            if a > right: right = a
        pos = game.geometry.get_pos(thing)
        rect = self.target.to_rect()
        lpos = getattr(rect, self.leftcorn)
        rpos = getattr(rect, self.rightcorn)
        if lpos[not self.xaxis] < pos[not self.xaxis] < rpos[not self.xaxis] or\
           rpos[not self.xaxis] < pos[not self.xaxis] < lpos[not self.xaxis]:
            n = pos[self.xaxis] - rect[self.xaxis]
        else:
            # XXX
            n1 = self.distance_to(leftpos, thing, game)
            n2 = self.distance_to(rightpos, thing, game)
            n = min(n1, n2)
            if n == n1: corn = 'left'
            else: corn = 'right'
        v = game.geometry.get_velo(thing)
        if math.hypot(*v) > 40:
            # try to slow down, but don't turn (you'll bounce off a wall too soon)
            self.wantvelo_accel(thing, game, (0, 0), can_rotate=False)
        if math.hypot(*v) > 10:
            # try to slow down, but turning is OK
            self.wantvelo_accel(thing, game, (0, 0), can_rotate=True)
        if n > 500:
            # accel towards thing horizontally
            if v[self.axis] < sqrt(2*300):
                push = [0, 0]
                push[self.axis] = self.forward
                if v[not self.axis] > 0:
                    push[not self.axis] = -0.1
                else:
                    push[not self.axis] = 0
            angle = -math.degrees(math.atan2(push[1], push[0]))
            if self.face(thing, game, angle, maybe_opposite=False):
                pass
        if n > 200:
            # try to slow down and face target
            pass
        if n < 200: # try to cancel velo while staying pointed at target
            pass

class Flies(AI):
    def __init__(self, turnrate = 5, accel=1.0/24):
        self.turnrate = turnrate
        self.allowed[ACCEL] = accel
        self.moving = 'forward'

    def _run(self, enemy, game):
        if self.moving == 'forward':
            game.add_force()

def angle_between(v1, v2):
    l1 = math.hypot(*v1)
    l2 = math.hypot(*v2)
    costheta = (v1[0]*v2[0] + v1[1]*v2[1])/(l1*l2)
    return math.degrees(math.arccos(costheta))

class Dodges(Flies):
    def _run(self, enemy, game):
        p = game.geometry.get_pos(enemy)
        v = game.geometry.get_velo(enemy)
        for obj in game.bullets:
            bpos = game.geometry.get_pos(obj)
            dx = p[0] - bpos[0], p[1] - bpos[1]
            bv = game.geometry.get_velo(obj)
            relv = v[0] - bv[0], v[1] - bv[1]
            theta = angle_between(dx, relv)
            if -10 < theta < 10:
                # try to dodge this one
                pass
