import Vector
import Numeric
import math
import operator
import ode

class Rope(object):
    def __init__(self, game, player, o2, p2, pos, distance):
        self.player = player
        self.obj = o2
        self.pos = pos
        self.d = distance
        self.objects = [player, o2]

    def segments(self):
        return []

class ODERope(Rope):
    def __init__(self, game, player, o2, p2, pos, distance, style='player'):
        super(ODERope, self).__init__(game, player, o2, p2, pos, distance)
        self.style = style
        geom = game.geometry
        self.geometry = geom
        self.geoms = [p2]
        p0 = geom.get_pos(player)
        #print p0, pos
        newbpos = map(lambda x,y: (x+y)/2, p0, pos)
        #print 'spank!'
        v = map(operator.sub, pos,p0)
        #print v
        newb = ode.Body(geom.world)
        m = ode.Mass()
        m.setSphere(1, 10)
        newb.setMass(m)
        newb.setPosition(tuple(pos)+(0,))
        j0 = ode.HingeJoint(geom.world)
        #print o2, o2.static
        if o2.static:
            #print 'attaching to new body'
            body0 = ode.Body(geom.world)
            body0.setPosition(tuple(pos)+(0,))
            j0.attach(body0, newb)
            self.motor = ode.LMotor(geom.world)
            self.body0 = body0
            self.motor.attach(ode.environment, body0)
            self.motor.setNumAxes(2)
            self.motor.setAxis(0, 0, (1, 0, 0))
            self.motor.setAxis(1, 0, (0, 1, 0))
            self.motor.setParam(ode.ParamFMax, 1000000)
            self.motor.setParam(ode.ParamFMax2, 1000000)
            vx, vy = geom.get_velo(o2)
            self.motor.setParam(ode.ParamVel, vx)
            self.motor.setParam(ode.ParamVel2, vy)
            o2p = geom.get_pos(o2)
#            self.motor.setParam(ode.ParamStopERP, 0.8)
            
            self.offset = pos[0]-o2p[0], pos[1]-o2p[1]

        else:
            self.motor = None
            j0.attach(geom.bodies[o2], newb)
        j0.setAxis((0, 0, 1))
        j0.setAnchor(tuple(pos)+(0,))
        #j0.setParam(ode.ParamCFM, 1e-10)
        
        rotb = ode.Body(geom.world)
        rotb.setPosition(tuple(p0)+(0,))

        j1 = ode.SliderJoint(geom.world)
        j1.attach(newb, rotb)
        j1.setAxis(tuple(v)+(0,))
        j2 = ode.HingeJoint(geom.world)
        j2.attach(rotb, geom.bodies[player])
        j2.setAxis((0, 0, 1))
        j2.setAnchor(tuple(p0)+(0,))
        #j1.setAnchor(tuple(newbpos)+(0,))
        j1.setParam(ode.ParamHiStop, 10.0)
        delta = map(operator.sub, list(pos)+[0], geom.bodies[player].getPosition())
        d = math.sqrt(sum(map(operator.mul, delta, delta)))
        j1.setParam(ode.ParamLoStop, -d)
        j1.setParam(ode.ParamStopCFM, 1e-10)
        j1.setParam(ode.ParamStopERP, .9)
        j1.setFeedback(True)

        self.j0 = j0
        self.j1 = j1
        self.j2 = j2
        self.newb = newb
        self.oldpos = geom.get_pos(o2)
        self.reeling_in = None
        self.overextend = 0
        self.initdist = self.extend()

    def update(self, geom):
        if not self.obj.static: return
        p0x, p0y, p0z = self.body0.getPosition()
        px, py = geom.get_pos(self.obj)
        vx, vy = geom.get_velo(self.obj)
        ox, oy = self.offset
        # body0 is at p0x, p0y, want to be at px+vx+ox, py+vy+oy

        diff = px + vx + ox - p0x, py + vy + oy - p0y
        self.motor.setParam(ode.ParamVel, diff[0])
        self.motor.setParam(ode.ParamVel2, diff[1])
        return

    def segments(self):
        def trim3d(pos):
            return pos[:-1]
        return [(trim3d(self.newb.getPosition()), self.geometry.get_pos(self.player))]

    def report(self, game):
        print self.player, game.geometry.bodies[self.player].getPosition(), self.newb.getPosition()
        lo = self.j1.getParam(ode.ParamLoStop)
        hi = self.j1.getParam(ode.ParamHiStop)
        pos = self.newb.getPosition()
        delta = map(operator.sub, pos, game.geometry.bodies[self.player].getPosition())
        d = math.sqrt(sum(map(operator.mul, delta, delta)))
        print self.j1.getParam(ode.ParamStopCFM), self.j1.getParam(ode.ParamStopERP), self.j1.getFeedback(),
        print self.j0.getAnchor(), self.j1.getAxis(), self.j0.getAngle(), self.j0.getAngleRate(), lo, self.j1.getPosition(), hi, self.j1.getPositionRate()
        pass

    def move(self, dist):
        p0x, p0y, p0z = self.body0.getPosition()
        self.body0.setPosition((p0x+dist[0], p0y+dist[1], 0))
        p0x, p0y, p0z = self.newb.getPosition()
        self.newb.setPosition((p0x+dist[0], p0y+dist[1], 0))

    def reel_in(self, amt):
        axis = self.j1.getAxis()
        p = self.geometry.get_pos(self.player)
        jp = self.j1.getPosition()
        jh = self.j1.getParam(ode.ParamHiStop)
        newjh = jh-amt
##        v = self.geometry.get_velo(self.player)
##        vdot = v[0]*axis[0]+v[1]*axis[1]
##        vtlen = vdot/math.sqrt(v[0]*v[0]+v[1]*v[1])
        #print "reeling", jp, jh, .95*jh, vtlen
        if jp > .95*jh or jp > newjh:
            newpos = (p[0]+axis[0]*amt, p[1]+axis[1]*amt)
            self.player.rope_before = p
            self.player.rope_placed = newpos
            self.last_high = jh
            #print "placing rope"
            self.geometry.set_pos(self.player, newpos)
        self.j1.setParam(ode.ParamHiStop, newjh)

    def extend(self):
        p0 = self.newb.getPosition()[:2]
        p1 = self.geometry.bodies[self.player].getPosition()[:2]
        delta = p0[0]-p1[0], p0[1]-p1[1]
        dist = delta[0]*delta[0]+delta[1]*delta[1]
        return math.sqrt(dist)

    def check_broken(self):
        if not self.reeling_in: return
        if self.player.rope_failed:
            dist = self.j1.getParam(ode.ParamHiStop)
            dist = self.extend()-self.initdist
            #print "setting histop", dist
            self.j1.setParam(ode.ParamHiStop, dist)
            # only return True if we're actually reeling in. If we're reeling
            # out, then brokenness doesn't bother us too much
            #return self.reeling_in > 0

        self.player.rope_before = self.player.rope_placed = None
        self.player.rope_failed = None
