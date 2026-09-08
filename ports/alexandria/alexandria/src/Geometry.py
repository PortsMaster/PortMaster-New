import operator
import math
import ode
import xode.transform
from pygame.rect import Rect

CATEGORY_STATIC = 0x1

def sphere_rect(self):
    r = Rect(0, 0, 2*self.radius, 2*self.radius)
    r.center = self.getBody().getPosition()[:2]
    return r

class NoneGeom(object):
    pass

class Geometry(object):
    def __init__(self):
        #self.space = ode.QuadTreeSpace((0, 0, 0), (10000, 10000, 1), 4)
        self.staticspace = ode.SimpleSpace()
        self.dynamicspace = ode.SimpleSpace()
        self.world = ode.World()
        self.world.setERP(0.8)
        self.world.setCFM(1e-8)
        self.bodies = {}
        self.geoms = {}
        self.allgeoms = [] # cached, flat version of self.geoms
        self.rays = []
        self.contactgroup = ode.JointGroup()
        self.affectsareas = {}
        self.statforces = {}

    def kill_all(self):
        for obj in self.geoms.keys():
            self.delete_object(obj)
        self.geoms.clear()
        del self.allgeoms[:]
        
    def new_body(self, object, pos, velo, accel):
        body = ode.Body(self.world)
        body.object = object
        body.setPosition(tuple(pos)+(0,))
        body.setLinearVel(tuple(velo)+(0,))
        body.setForce(tuple(accel)+(0,))
        self.bodies[object] = body
        if hasattr(object, 'angle'):
            self.set_angle(object, object.angle)
            del object.angle
        self.geoms[object] = {}

    def set_angle(self, object, angle):
        a = math.radians(-angle)
        body = self.bodies[object]
        r = [math.cos(a), -math.sin(a), 0, math.sin(a), math.cos(a), 0, 0, 0, 1]
        body.setRotation(r)
        body.setAngularVel((0, 0, 0))
            
    def objects(self):
        return self.bodies.keys()

    def add_affects_area(self, geom, rect, func):
        # surround geom with rect
        lengths = rect.size+(100,)
        b = ode.GeomBox(lengths=lengths)
        #b.setCollideBits(~CATEGORY_STATIC) # by definition, maybe?
        offset = rect.center
        b = self.transform_geom(b, offset=offset)
        #geom.setRotation(geom.getRotation())
        if isinstance(geom, ode.GeomObject): 
            b.setBody(geom.getBody())
            b.object = geom.getBody()
        else:
            b.setBody(self.bodies[geom])
            b.object = self.bodies[geom]
        b.shape = 'affects_area'
        b.func = func
        self.staticspace.add(b)
        self.affectsareas[b] = func
        return b

    def transform_geom(self, geom, rotate=None, offset=(0, 0)):
        if rotate:
            trans = xode.transform.Transform()
            trans.rotate(0, 0, rotate)
            geom.setRotation(trans.getRotation())
        if offset != (0, 0):
            t = ode.GeomTransform()
            geom.setPosition(offset+(0,))
            t.setGeom(geom)
            t.shape = 'transform'
            geom = t
        return geom

    def add_geom(self, object, label, geom, offset=(0,0), body=True,
                 health=None, under=False, image=None, absent=False,
                 thrustanim=False, thrustoverlay=False):
        geom.object = object
        geom.image = image
        geom = self.transform_geom(geom, offset=offset)
        geom.under = under
        geom.object = object
        if body:
            geom.setBody(self.bodies[object])
        geom.label = label
        if health == None: health = object.health
        geom.health = health
        geom.absent = absent
        geom.thrustanim = thrustanim
        geom.thrustoverlay = thrustoverlay
        
        geom.damaged_by = False # damaged by anything, by default
        geom.to_rect = geom_to_rect.__get__(geom, geom.__class__)
        self.geoms[object][label] = geom
        self.allgeoms.append(geom)
        if absent:
            return
        if object.static:
            geom.setCategoryBits(CATEGORY_STATIC)
            geom.setCollideBits(~CATEGORY_STATIC)
            self.staticspace.add(geom)
        elif hasattr(object, 'collision_class'):
            # FIXME: Actually make this general
            geom.setCategoryBits(object.collision_class)
            geom.setCollideBits(~object.collision_class)
            self.dynamicspace.add(geom)
        else:
            self.dynamicspace.add(geom)

        if object.damaged_by:
            geom.damaged_by = object.damaged_by

        if object.sharedhealth:
            geom.health = 'parent'

    def add_box(self, object, label, rect, density = 1000, rotate=0,
                texture=None, image=None, health=None, under=None,
                thrustanim=None, thrustoverlay=None):
        lengths = rect.size+(100,)
        b = ode.GeomBox(lengths=lengths)
        bm = self.bodies[object].getMass()
        m = ode.Mass()
        m.setBox(density, *lengths)
        # Working rotation code for when we actually implement
        # non-orthogonal walls.
        self.transform_geom(b, rotate=rotate)
        bm.add(m)
        b.shape = 'box'
        b.size = rect.size
        b.rotate = rotate
        b.texture = texture
        self.bodies[object].setMass(bm)
        self.add_geom(object, label, b, offset=rect.center, health=health, image=image, under=under, thrustanim=thrustanim, thrustoverlay=thrustoverlay)
        return b

    def add_circle(self, object, label, radius, density = 1000, center=(0,0),
                   image=None, health=None, under=None, absent=False,
                   thrustanim=False, thrustoverlay=False):
        c = ode.GeomSphere(radius=radius)
        cm = self.bodies[object].getMass()
        m = ode.Mass()
        m.setSphere(density, radius)
        cm.add(m)
        c.shape = 'circle'
        c.radius = radius
        c.make_rect = sphere_rect
        self.bodies[object].setMass(cm)
        self.add_geom(object, label, c, health=health, offset=center, image=image, under=under, absent=absent, thrustanim=thrustanim, thrustoverlay=thrustoverlay)
        return c
    
    def add_ray(self, length):
        ray = ode.GeomRay(self.dynamicspace, rlen=length)
        ray.shape = 'ray'
        self.rays.append(ray)
        return ray

    def add_polygon(self, object, label, points):
        '''Add a polygon to an object.'''
        print "needs Trimesh, that's hard too."
        self.polys.add_new(self.objects_nicknames[object], label, points)

    def remove_ray(self, ray):
        self.rays.remove(ray)
        self.dynamicspace.remove(ray)

    def get_pos(self, object):
        '''Get the position of an object.'''
        return self.bodies[object].getPosition()[0:2]

    def set_pos(self, object, pos):
        '''Set the position of an object.'''
        self.bodies[object].setPosition(tuple(pos)+(0,))

    def get_mass(self, object):
        return self.bodies[object].getMass().mass

    def move(self, object, v):
        '''Move an object by the vector v.'''
        self.pos[self.objects_nicknames[object]] += array(v).astype(self.pos.typecode())

    def set_accel(self, object, accel):
        '''Set the acceleration of an object.'''
        self.bodies[object].setForce(tuple(accel)+(0,))

    def get_velo(self, object):
        return self.bodies[object].getLinearVel()[:2]

    def set_velo(self, object, velo):
        self.bodies[object].setLinearVel(tuple(velo)+(0,))

    def get_shapes(self):
        '''Returns all the information needed by the display to draw everything.'''
        return self.geoms

    def delete_object(self, object):
        try:
            for k in self.geoms[object].keys():
                self.delete_part(object, k)
            del self.bodies[object]
            del self.geoms[object]
            for i in self.now_affects.values():
                if object in i:
                    i.remove(object)
        except KeyError:
            # already deleted
            pass

    def delete_part(self, object, label):
        try:
            g = self.geoms[object][label]
            
            if not g.absent:
                if object.static:
                    self.staticspace.remove(g)
                else:
                    self.dynamicspace.remove(g)
            try:
                del g.to_rect
            except:
                # old version of PyODE. Let's see if this crashes.
                pass
            del self.geoms[object][label]
            self.allgeoms.remove(g)
            if not self.geoms[object]:
                #self.delete_object(object)
                return True
        except KeyError:
            pass

        return False

    def obj_geoms(self, obj):
        return self.geoms[obj].values()
        
    ## --------- COLLISION STUFF ---------- ##
    def check(self, s, game):
        x, y = self.get_pos(game.player)
        if not x > 0 and not x < 0 and not y > 0 and not y < 0:
            print s, self.get_pos(game.player)
            for p, r in game.ropes.iteritems():
                r.report(game)
            # If you ever see this message, PLEASE write me
            # If you can reproduce it, the above goes double!
            raise AssertionError, "you've been bitten by the NaN bug!"

    def collide_all(self, game):
        # Do these name lookups once and only once.
        # This is a pretty common optimization in the Pygame world.
        # Since these attributes are used each time through the loop
        # (10 iterations right now), it helps to look them up right now.
        # This is especially true with the bound methods (self.near_callback).
        check = self.check
        dynspace = self.dynamicspace
        world = self.world
        forces = game.forces
        impulses = game.impulses
        self_near_callback = self.near_callback
        contactgroup = self.contactgroup
        collide = ode.collide2
        n = 10
        for i in range(n):
            for b, f in forces.iteritems():
                self.bodies[b].setForce(tuple(f)+(0,))
            for b, f in impulses.iteritems():
                f = f[0]*n, f[1]*n
                self.bodies[b].setForce(tuple(f)+(0,))
            impulses.clear()

            reelinspace = ode.Space()
            for person, rope in game.ropes.iteritems():
                if rope.reeling_in:
                    rope.reel_in(rope.reeling_in/float(n))
                    dynspace.remove(self.geoms[person][0])
                    reelinspace.add(self.geoms[person][0])  # FIXME: multigeom
                
            game.update_all()

            for beam in self.rays:
                beam.object.mindepth = beam.object.length

            self.statforces.clear()
##            check('before collide', game)
            self.now_affects = {}
            collide(reelinspace, self.staticspace, (game, world),
                    self.reelin_back)
            collide(reelinspace, dynspace, (game, world),
                    self.reelin_back)
            for person, rope in game.ropes.iteritems():
                if hasattr(person, 'newp'):
                    self.bodies[person].setPosition(person.newp)
                    del person.newp
                if reelinspace.query(self.geoms[person][0]):
                    reelinspace.remove(self.geoms[person][0])
                    dynspace.add(self.geoms[person][0])

            dynspace.collide((game,world, contactgroup), self_near_callback)
            collide(self.staticspace, dynspace,
                    (game, world, contactgroup),
                    self_near_callback)
##            check('after collide', game)

            for g in self.statforces:
                if len(self.statforces[g]) > 1:
                    f1 = self.statforces[g][0]
                    f2 = self.statforces[g][1]
                    dot = sum(map(operator.mul, f1, f2))
                    # rounding error on identical f1, f2. We only care
                    # if dot is close to -1.
                    if dot > 1: 
                        continue
                    # Similarly there's sometimes rounding error and we get
                    # less than -1. So instead of dot->angle, we angle->dot
                    # and compare.
                    # cosine of 165 == cos 195 so we just check once.
                    # cos 165 ~= -0.9659. cos 180 = -1.0.
                    if math.cos(math.radians(165)) > dot: 
                        # o crushed!
                        game.hit(g, "crush", None)
                        game.play_sound("crunch.ogg", g)
            
            for beam in self.rays:
                if beam.object.length != beam.object.mindepth:
                    o2, pos2 = beam.object.hit
                    beam.object.struck(o2, pos2, game)
                    o2.object.struck(beam, pos2, game)

            for person, rope in game.ropes.iteritems():
                if rope.check_broken():
                    rope.reeling_in = None

##            check('after crush', game)
            game.flush_killqueue()
            check('before step', game)
            world.step(1.0/n)
            check('after step, %f'%(1.0/n), game)
            contactgroup.empty()

        self.handle_affects_areas()

        for person, rope in game.ropes.iteritems():
            rope.reeling_in = None

    def near_callback(self, args, geom1, geom2):
        """Callback function for the collide() method.
        
        This function checks if the given geoms do collide and
        creates contact joints if they do.
        """

        if geom1.shape == 'affects_area' or geom2.shape == 'affects_area':
            self.callback_affect(geom1, geom2)
            return

        if isinstance(geom2, ode.GeomRay):
            self.callback_beam(geom2, geom1)
            return # don't concern yourself
            
        if isinstance(geom1, ode.GeomRay):
            self.callback_beam(geom1, geom2)
            return

        # Weird; I thought disabled Geoms were supposed to be uncollideable!
        if not (geom1.isEnabled() and geom2.isEnabled()): return
        if geom1.object == geom2.object: return

        # Check if the objects do collide
        contacts = ode.collide(geom1, geom2)

        # Create contact joints
        game,world,contactgroup = args
        for c in contacts:
            (pos, normal, depth, ngeom1, ngeom2) = c.getContactGeomParams()
            o1 = geom1.object
            o2 = geom2.object
            # Clip third coordinate on ODE stuff
            pos = pos[:2]
            normal = normal[:2]
            pass1=o1.passable(part=geom1, o2=o2, n=normal, t=depth, game=game)
            pass2=o2.passable(part=geom2, o2=o1, n=normal, t=depth, game=game)
            if pass1 or pass2: return
            o1t = o1.pre_collide(part=geom1, pass1=pass1, o2=o2, p2=geom2, pass2=pass2, n=normal, t=depth, game=game, pos=pos)
            o2t = o2.pre_collide(part=geom2, pass1=pass2, o2=o1, p2=geom1, pass2=pass1, n=normal, t=depth, game=game, pos=pos)
            #print 'collide', normal, geom1.object, geom2.object, geom1.getPosition(), geom2.getPosition(), depth, geom1.getRotation(), geom2.getRotation()
            if o1t or o2t: return

            c.setBounce(0.9)
            c.setMu(0000)

            c.setContactGeomParams(pos+(0,), normal+(0,), depth, ngeom1, ngeom2)
            j = ode.ContactJoint(world, contactgroup, c)

            if not o1.static: g1 = geom1.getBody()
            else: g1 = None
            if not o2.static: g2 = geom2.getBody()
            else: g2 = None

            if o1.static:
                self.statforces.setdefault(geom2, []).append(normal)
            if o2.static:
                # point normal "towards" o2 (usually they point to o1)
                n = -normal[0], -normal[1]
                self.statforces.setdefault(geom1, []).append(n)
            
            if not pass2 and not pass1:
                j.attach(g1, g2)

            game.play_sound('bounce.wav')
            o1.post_collide(part=geom1, pass1=pass1, o2=o2, pass2=pass2, n=normal, t=depth, game=game, pos=pos)
            o2.post_collide(part=geom2, pass1=pass2, o2=o1, pass2=pass1, n=normal, t=depth, game=game, pos=pos)

    def callback_beam(self, beamgeom, geom2):
        if beamgeom.object.shooter == geom2.object:
            return
        contacts = ode.collide(beamgeom, geom2)
        if not contacts: return
        for c in contacts:
            (pos, normal, depth, ngeom1, ngeom2) = c.getContactGeomParams()
            if depth < beamgeom.object.mindepth:
                beamgeom.object.hit = (geom2, pos)
                beamgeom.object.mindepth = depth
        #print beamgeom, geom2, beamgeom.getLength(), contacts

    def callback_affect(self, geom1, geom2):
        contacts = ode.collide(geom1, geom2)
        
        if contacts:
            if geom2.shape == 'affects_area':
                geom1, geom2 = geom2, geom1
            self.now_affects.setdefault(geom1, []).append(geom2.object)

    def reelin_back(self, args, geom1, geom2):
        if geom1 == geom2: return
        game, world = args
        o1 = geom1.object
        o2 = geom2.object
        contacts = ode.collide(geom1, geom2)
        if not contacts: return
        for c in contacts:
            (pos, normal, depth, ngeom1, ngeom2) = c.getContactGeomParams()
            if o1.rope_placed:
                rx, ry = o1.rope_placed
                x1, y1, z1 = self.bodies[o1].getPosition()
                if x1-0.1 < rx < x1+0.1 and y1-0.1 < ry < y1+0.1:
                    p = self.bodies[o1].getPosition()
                    newp = p[0] + normal[0]*depth, p[1] + normal[1]*depth, 0
                    o1.newp = newp
                    o1.rope_failed = True
                else:
                    print "bong", o1.rope_placed, self.bodies[o1].getPosition()
            elif o2.rope_placed:
                rx, ry = o2.rope_placed
                x2, y2, z2 = self.bodies[o2].getPosition()
                if x2-0.1 < rx < x2+0.1 and y2-0.1 < ry < y2+0.1:
                    p = self.bodies[o2].getPosition()
                    newp = p[0] - normal[0]*depth, p[1] - normal[1]*depth, 0
                    o2.newp = newp
                    o2.rope_failed = True
                else:
                    print "bing", o2.rope_placed, self.bodies[o2].getPosition()

    def handle_affects_areas(self):
        for areageom, func in self.affectsareas.iteritems():
            if self.now_affects.has_key(areageom):
                func(self.now_affects[areageom])
            else:
                func([])

    def contained(self, obj, rect):
        for k, v in self.geoms[obj].iteritems():
            func = globals()['%s_contained'%v.shape]
            if not func(v, rect):
                return False

        return True

def transform_contained(transg, rect):
    return False

def box_contained(boxg, rect):
    x, y, z = boxg.getPosition()
    dx, dy, dz = boxg.getLengths()
    points = [(x-dx, y-dy), (x+dx, y-dy), (x+dx, y+dy), (x-dx, y+dy)]
    for p in points:
        if not rect.collidepoint(p):
            return False
    return True

def circle_contained(sphereg, rect):
    x, y, z = sphereg.getPosition()
    r = sphereg.getRadius()
    if rect.left <= x - r and rect.top <= y - r and \
           x + r < rect.right and y + r < rect.bottom:
        #Yes, contained
        return True
    else:
        return False

def geom_to_rect(geom):
    g = geom
    x = y = 0
    if g.shape == 'transform':
        g = g.getGeom()
        x, y = g.getPosition()[:2]
    if g.shape == 'circle':
        w = h = 2*g.radius
    if g.shape == 'box':
        w, h = g.size
    r = Rect(0, 0, w, h)
    r.center = x, y
    return r
