### AI.py: definitions of various types of AI
# Copyright Sixth Floor Labs, 2007
# This is the worst source file in the whole project, easily. The functions
# labeled new_run aren't used at all yet, and may never be. All the AIs suck to
# varying degrees. There's no clean separation of concerns -- look at HuntsGeom
# (especially in action). I can only say in my defense that A* and other algorithms
# don't really deal well with inertia, as far as I can tell. Someone really needs
# to take better care of this area!

import operator
import math
import random
import Numeric

# types of thing that AIs might have contention over
TURNING = 'turning'
SHOOTING = 'shooting'
ACCEL = 'accel'

# AIs which don't rely on bullet first
class AI(object):
    '''Class for a generic enemy.'''
    def __init__(self, doneai=None):
        self.doneai = doneai

        # Resources the AI has
        self.allowed = {}
        # Resources the AI has used this tick
        self.used = {}
    
    def _run(self, enemy, game):
        if self.doneai:
            self.doneai._run(enemy, game)

    def run(self, enemy, game):
        self.used.clear()
        enemy.thrusting = False
        self._run(enemy, game)

    def get_left(self, stuff):
        return self.allowed[stuff] - self.used.setdefault(stuff, 0)

    def use_amt(self, stuff, amt):
        self.used[stuff] = self.used.get(stuff, 0) + amt

    def use_all(self, stuff):
        left = self.get_left(stuff)
        self.use_amt(stuff, left)
        return left

    def pos_to(self, target, enemy, game):
        p0 = game.geometry.get_pos(enemy)
        return map(operator.sub, target, p0)

    def angle_to(self, target, enemy, game):
        d = self.pos_to(target, enemy, game)
        x, y = d
        angle = -math.degrees(math.atan2(y, x))
        return angle

    def distance_to(self, target, enemy, game):
        d = self.pos_to(target, enemy, game)
        return math.hypot(*d)

Stationary = AI
NoAI = AI

class Damps(AI):
    def __init__(self, speed=1, accel=1.0/24, **kwargs):
        super(Damps, self).__init__(**kwargs)
        self.speed = speed
        self.allowed[ACCEL] = accel

    def _run(self, enemy, game):
        v = game.geometry.get_velo(enemy)
        speed = math.hypot(*v)
        if speed > self.speed:
            # apply braking force of self.accel in opposite direction
            m = game.geometry.get_mass(enemy)
            # Note: impulse instead of force.
            # this "optimization" means slightly less accurate results.
            # But so many mines do this, so I feel it's needed.
            game.add_impulse(enemy,
                           self.damp(m, v, speed, self.speed, self.get_left(ACCEL)))
            
    def damp(self, m, velo, speed, maxspeed, maxaccel):
        diff = min(speed - maxspeed, maxaccel)
        brake = [(-velo[0]/speed)*m*diff, (-velo[1]/speed)*m*diff]
        return brake

class DampsLevels(Damps):
    '''Class to specify various levels at which damping takes place.

    You might use this to make something slow faster when it gets too fast.

    Note: This class doesn't use get_left(ACCEL) at all!'''
    def __init__(self, *args, **kwargs):
        super(DampsLevels, self).__init__(**kwargs)
        # args is (speed, accel, speed, accel, speed, accel)
        # speed, speed, speed is args[0::2]
        # accel, accel, accel is args[1::2]
        self.levels = zip(args[0::2], args[1::2])
        self.levels.sort(reverse=True)

    def _run(self, enemy, game):
        v = game.geometry.get_velo(enemy)
        speed = math.hypot(*v)
        for maxspeed, accel in self.levels:
            if speed > maxspeed:
                game.add_force(enemy,
                               self.damp(m, v, speed, maxspeed, accel))
                return

class Wanders(Damps):
    CHANGING=60 # time to change directions (frames)
    def __init__(self, dur=300, **kwargs):
        super(Wanders, self).__init__(**kwargs)
        self.dur = dur

        self.states = ['travelling', 'changing direction']

        self.thisdir = (0, 0)
        self.thislong = self.dur

        self.newv = None

    def _run(self, enemy, game):
        super(Wanders, self)._run(enemy, game)
        if self.thislong == self.dur:
            if not self.newv:
                # pick a new direction and start applying force
                m = game.geometry.get_mass(enemy)
                dir = random.uniform(0, 360)
                dir = math.radians(-dir) # convert to "math"
                self.newv = [self.speed*math.cos(dir), self.speed*math.sin(dir)]
                #print 'self.newdir is', self.newv
                self.force = [(self.newv[0] - self.thisdir[0])*m/self.CHANGING,
                              (self.newv[1] - self.thisdir[1])*m/self.CHANGING]
                self.changing = 0
            elif self.changing == self.CHANGING:
                self.thisdir = self.newv
                self.newv = None
                self.dur = 0
            else:
                game.add_force(enemy, self.force)
                self.changing += 1

        else:
            self.dur += 1

class RectWanders(Wanders):
    def __init__(self, **kwargs):
        super(RectWanders, self).__init__(**kwargs)

    def _run(self, enemy, game):
        super(RectWanders, self)._run(enemy, game)
        try:
            r = enemy.rect
        except:
            raise ValueError, "Cannot run RectWanders AI on %s: no rect attribute" %(enemy)
        m = game.geometry.get_mass(enemy)
        c = r.center
        p = game.geometry.get_pos(enemy)
        d = r.center[0] - p[0], r.center[1] - p[1]
        if abs(d[0]) + 20 > r.width/2:
            # apply force in direction of d[0]
            game.add_force(enemy, (d[0]*m/(r.width/2)/16, 0))
        if abs(d[1]) + 20 > r.height/2:
            # apply force in direction of d[1]
            game.add_force(enemy, (0, d[1]*m/(r.height/2)/16))

class Rotates(AI):
    def __init__(self, turnspeed = 4, period=150, **kwargs):
        super(Rotates, self).__init__(**kwargs)
        self.period = period
        self.allowed[TURNING] = turnspeed
        self.want_angle = 0
        self.ticks = 0
        
    def _run(self, enemy, game):
        self.ticks += 1
        if self.period and self.ticks % self.period == 0:
            self.want_angle = random.randint(0, 360)
        self.face(enemy, game, self.want_angle)

    def face(self, enemy, game, wantangle, maybe_opposite=False):
        '''Face in the direction specified by wantangle.

        If maybe_opposite == True, also try wantangle+180, and if that's
        possible instead, go with it.'''
        turnleft = self.get_left(TURNING)
        diff = wantangle%360 - game.get_angle(enemy)%360
        if abs(diff) < turnleft or abs(diff) > 360-turnleft:
            game.set_angle(enemy, wantangle)
            self.use_amt(TURNING, abs(diff))
            return True
        elif maybe_opposite:
            if 180 - turnleft < abs(diff) < 180 + turnleft:
                game.set_angle(enemy, wantangle + 180)
                self.use_amt(TURNING, abs(diff))
                return True

        enemy.thrusting = True
        self.use_amt(TURNING, turnleft)
        a = game.get_angle(enemy)
        if -360 < diff < -270 or 0 < diff < 90:
            game.set_angle(enemy, a + turnleft)
            return False
        if -90 < diff < 0 or 270 < diff < 360:
            game.set_angle(enemy, a - turnleft)
            return False
        if -270 < diff < -180 or 90 < diff < 180:
            if maybe_opposite:
                game.set_angle(enemy, a - turnleft)
            else:
                game.set_angle(enemy, a + turnleft)
            return False
        else: # -180 < diff < -90 or 180 < diff < 270
            if maybe_opposite:
                game.set_angle(enemy, a + turnleft)
            else:
                game.set_angle(enemy, a - turnleft)
            return False

class Orbits(Rotates):
    def __init__(self, pos, force, randomness, topspeed=None, **kwargs):
        super(Orbits, self).__init__(**kwargs)
        self.pos = pos
        self.allowed[ACCEL] = force
        self.randomness = randomness
        self.topspeed = topspeed
        self.path = []
        self.debug = False

    def set_target(self, target):
        self.pos = target

    def set_path(self, points, replace=True):
        self.path = points
        if replace:
            self.pos = self.path.pop(0)

    def distance(self, enemy, game):
##        return self.distance_to(self.pos, enemy, game)
        current = game.geometry.get_pos(enemy)
        target = self.pos
        distance = map(operator.sub, target, current)
        return distance

    def distance_n(self, enemy, game):
        distance = self.distance(enemy, game)
        return math.sqrt(distance[0]*distance[0] + distance[1]*distance[1])

    def done(self, enemy, game):
        return len(self.path) == 0 and self.distance_n(enemy, game) < 10

    def wantvelo_accel(self, enemy, game, dwant, can_rotate=True):
        velo = game.geometry.get_velo(enemy)
        diff = map(operator.sub, dwant, velo) # force to apply
        l = math.sqrt(diff[0]*diff[0]+diff[1]*diff[1])

        if l:
            angle = -math.degrees(math.atan2(diff[1], diff[0]))
            #print angle, game.get_angle(enemy)
            if can_rotate:
                if not self.face(enemy, game, angle,
                                 maybe_opposite=True):
                    return
                m = game.geometry.get_mass(enemy)
                accel = self.use_all(ACCEL)
                enemy.thrusting = True
                f = (diff[0]/l*m*accel, diff[1]/l*m*accel)
                if self.debug:
                    current = game.geometry.get_pos(enemy)
                    target = self.pos
                    print target, current
                    print l, diff, f, accel
                game.add_force(enemy, f)
            else:
                if not 90 < abs(game.get_angle(enemy) - angle)%360 < 270:
                    game.accelerate(enemy, self.use_all(ACCEL))
                    enemy.thrusting = True
            
        return not bool(l) # True if l = 0

    def _run(self, enemy, game, can_rotate=True):
        distance = self.distance(enemy, game)
        d = self.distance_n(enemy, game)
        # If we were braking constantly, what velocity would we need to get to
        # the point?
        # vf^2 = vi^2 + 2*a*d
        # vi^2 = vf^2-2ad (a is negative)
        # a = self.force
        vi = math.sqrt(2*d*self.allowed[ACCEL]) # subtract k for some carefulness
        if 30 > d and self.path:
            self.pos = self.path.pop(0)
        if d > 0.5:
            dnorm = distance[0]/d, distance[1]/d # normalize
            dwant = dnorm[0]*vi, dnorm[1]*vi # velocity we want
        else:
            dnorm = (0, 0)
            dwant = (0, 0)
        if self.debug: print distance, d, dnorm, dwant, vi

        if self.wantvelo_accel(enemy, game, dwant, can_rotate=can_rotate):
            super(Orbits, self)._run(enemy, game)

    def new_run(self, enemy, game):
        distance = self.distance(enemy, game)
        d = self.distance_n(enemy, game) / self.allowed[ACCEL]
        velo = game.geometry.get_velo(enemy)
        force = (0, 0)
        forcespent = 0
        # start by resolving velo into "towards distance" and "other"
        # project velo onto distance and then subtract to get other
        dnorm = distance[0]/d, distance[1]/d
        v2 = velo[0]*velo[0] + velo[1]*velo[1]
        v = math.sqrt(v2)
        velonorm = velo[0]/v, velo[1]/v
        dot = velonorm[0] * dnorm[0] + velonorm[1]*dnorm[1]
        if dot < 0: # we're going opposite where we need to be
            opposite = True
            dot = -dot
        else:
            opposite = False
        proj = dot * v * dnorm[0], dot * v * dnorm[1]
        if opposite:
            # try to cancel proj
            if dot * v >= self.get_left(ACCEL):
                force = dnorm[0]*self.force, dnorm[1]*self.force
                self.use_amt(ACCEL, self.force)
            else:
                force = dnorm[0]*dot*v, dnorm[1]*dot*v
                self.use_amt(ACCEL, dot*v)
        if self.get_left(ACCEL) > 0: # force left
            velo = velo[0] - proj[0], velo[1] - proj[1] # remaining velo
            # velo is now orthogonal to distance
            v = math.sqrt(velo[0]*velo[0]+velo[1]*velo[1])
            # try to cancel remaining
        
        # accelerating at 1 pixel/tick/tick from target, how many ticks would
        # it take to get to current?
        # turns out ODE comes pretty close to behaving as in the continuous
        # case. Some numbers are in PHYSICS.
        # If we start decelerating now, how far will we go?
        # vf^2 = vi^2 + 2 a d
        # vf = 0, vi = v, a = self.force
        vi2 = velo[0]*velo[0] + velo[1]*velo[1]
        computedd = vi2/(2*self.allowed[ACCEL])
        if computedd < d: # accelerate
            wantdir = distance
            wantlen = d
            # project velo on wantdir to see how far "off" we are
            wantnorm = wantdir[0] / wantlen, wantdir[1] / wantlen # normalize
            vi = math.sqrt(vi2)
            velonorm = velo[0]/vi, velo[1]/vi    # likewise
            dot = velonorm[0]*wantnorm[0] + velonorm[1]*wantnorm[1]
            proj = dot * vi * wantnorm[0], dot * vi * wantnorm[1]
            # compute what accel we need to apply to get there
            toapply = proj[0]-velo[0], proj[1]-velo[1]
            toaplen = math.sqrt(toapply[0]*toapply[0] + toapply[1]*toapply[1])
            if toaplen < self.get_left(ACCEL):
                # we still have some, so let's put the rest towards wantdir
                pass
        else: # start braking
            wantdir = (0, 0)
        #if d < 30/self.force and self.path:
        #    self.pos = self.path.pop(0)
        #elif d < 5/self.force:
        #    distance = (0, 0)
        #else:


class Accel(AI):
    def __init__(self, accel):
        self.allowed[ACCEL] = accel

    def _run(self, enemy, game):
        game.add_force(enemy, self.use_all(ACCEL))

class DoesAll(AI):
    def __init__(self, *args):
        super(DoesAll, self).__init__()
        self.ais = args
        # Share attributes about the same object
        for ai in self.ais:
            self.allowed.update(ai.allowed)
            ai.allowed = self.allowed
            ai.used = self.used

    def _run(self, enemy, game):
        for ai in self.ais:
            ai._run(enemy, game)

class Spins(AI):
    def __init__(self, rate=0, **kwargs):
        super(Spins, self).__init__(**kwargs)
        self.rate = rate

    def _run(self, enemy, game):
        game.set_angle(enemy, game.get_angle(enemy) + self.rate)
