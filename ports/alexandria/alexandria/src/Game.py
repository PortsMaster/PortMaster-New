import sys
import math
from weakref import WeakKeyDictionary
import operator
import pygame
import types
from Vector import Vector, angle_vector
import Geometry
import Image
import PhysicsController
#from data.Rope import Rope, BounceRope, ExactRope
import data.Rope as Rope
from data import BulletStyle
import Level
import Event
import ode

class EndOfObjectException(Exception):
    def __init__(self, obj):
        self.obj = obj

m = ode.Mass()
m.setSphere(1, 16) # mass params for player
class Game(object):
    FORCESCALE = m.mass/2               # 2 pts damage -> 1 pt velo?
    def __init__(self, evman):
        #self.player = Player(Vector([200, 200]))
        self.geometry = Geometry.Geometry()

        self.kill_next = []
        self.bullets = []
        self.explosions = []
        self.ropes = {}
        self.beams = {}
        self.enemies = []
        self.combatants = []
        self.radarobjs = []

        self.goals = []

        self.speaker = None

        self.patterns = WeakKeyDictionary()
        self.actions = []
        self.flags = {} # used for setting game state

        self.frames = 0
        self.forces = {}
        self.impulses = {}
        self.cinematic = {}
        self.controls_disabled = {}
        self.thrustpos = None
        self.evmanager = evman
        self.fps = 0
        self.playable = False
        self.paused = False
        self.gui = False
        self.dialog = None
        self.player = None
        self.scale = 1.0
        self.inertia = True

        self.pastgoals = []

    def update_all(self):
        """Do per-collision-cycle updates of ropes and beams and things
        that the Geometry class doesn't like to deal with."""
        for p, r in self.ropes.iteritems():
            r.update(self.geometry)
            
        for p, b in self.beams.iteritems():
            if not self.geometry.bodies.has_key(p): continue
            pos = self.bullet_pos(p, b)
            dir = angle_vector(self.get_angle(p))
            b.update(self.geometry, pos, dir)
            b.mindepth = b.length

    # FIXME: These are ugly, ugly hacks! Ideally these would be methods on Geom,
    # but the easiest way to implement that is to make a GeomWrapper class, and
    # I can't be bothered.
    # Also be aware of the Breakable shape which sets geom.health directly --
    # *insisting* on a per-geom health. How would that work?
    def get_geom_health(self, geom):
        if geom.health == 'parent':
            return geom.object.health
        else: return geom.health

    def change_geom_health(self, geom, diff):
        if geom.health == 'parent':
            geom.object.health += diff
        else: geom.health += diff

    def set_geom_health(self, geom, num):
        if geom.health == 'parent':
            geom.object.health = num
        else: geom.health = num

    def kill_all(self):
        self.patterns = None
        self.evmanager = None
        self.geometry.kill_all()

    def kill_object(self, object, killer=None, chrome=True):
        self.post(Event.ObjectKillEvent(object, killer, chrome=chrome))
        object.die(self)
        self.delete_object(object, killer=killer, chrome=chrome)

    def delete_object(self, object, killer=None, chrome=True):
        # Chrome before deleting the bodies and geoms
        self.post(Event.ObjectDeleteEvent(object, killer, chrome=chrome))
        if object.die_replace:
            print "replacing"
            shape = object.die_replace
            shape.place(self, replacing=object)
            shape.render(self)
        self.geometry.delete_object(object)
        self.object_deleted(object, chrome)

    def object_deleted(self, object, chrome=True):
        '''Takes care of all the cleanup associated with an object dying.'''
        if object in self.patterns.keys():
            del self.patterns[object]
        if hasattr(object,'on_destroy'):
            #print 'setting pattern for', object
            self.patterns[object] = object.on_destroy
        if object in self.forces.keys():
            del self.forces[object]
        if object in self.impulses.keys():
            del self.impulses[object]
        for lst in self.bullets, self.enemies, self.combatants, self.radarobjs:
            if object in lst:
                lst.remove(object)
        # Unhook (delete) any ropes which are attached to this object.
        for player, rope in self.ropes.items():
            if object in rope.objects:
                del self.ropes[player]

    def last_geom(self, object):
        return len(self.geometry.geoms[object]) == 1

    def kill_part(self, object, part, killstr):
        if self.last_geom(object) or \
               self.geometry.geoms[object][part].health == 'parent':
            self.kill_object(object, killstr)
        else:
            self.delete_part(object, part)

    def delete_part(self, object, part):
        g = self.geometry.geoms[object][part]
        if self.last_geom(object):
            self.delete_object(object)
        else:
            self.post(Event.ObjectDestroyPartEvent(g))
            self.geometry.delete_part(object, part)
            self.unhook_ropes_with_geom(g)

    def queue_kill(self, object, part, killstr=None):
        '''It is sometimes helpful to wait to kill an object.'''
        self.kill_next.append([object, part, killstr])

    def flush_killqueue(self):
        deleted = []
        for [o, part, killstr] in self.kill_next:
            if o not in deleted:
                self.kill_part(o, part, killstr)
                deleted.append(o)
        self.kill_next = []

    def objects(self):
        return self.geometry.objects()

    def bullet_pos(self, shooter, bullet, angle=None):
        '''Good position for a bullet to start.'''
        p = self.geometry.get_pos(shooter)
        if shooter.bulletpos:
            bulletpos = map(operator.add, shooter.bulletpos, p)
            
        else:
            bulletpos = p
            if not angle:
                angle = self.get_angle(shooter)
            bulletpos = bulletpos + angle_vector(angle)*(shooter.size+bullet.size+.001)
        return bulletpos

    def get_angle(self, object):
        b = self.geometry.bodies[object]
        rot = b.getRotation()
        c = rot[0]
        s = rot[1]
        d = 90-math.degrees(math.atan2(c, s))
        return d

    def set_angle(self, object, angle):
        self.geometry.set_angle(object, angle)

    def shoot(self, shooter, bullet, angle=None, pos=None, bulletspeed=None, velo=None,
              style=None, silent=False):
        if not style: style = shooter.bulletstyle
        style = BulletStyle.get_bullet_style(bullet.__class__, style)
        style.silent = silent

        if angle == None: angle = self.get_angle(shooter)
        bullet.angle = angle
        if bulletspeed == None:
            bulletspeed = bullet.speed
            if isinstance(shooter.bulletspeed, int):
                bulletspeed = shooter.bulletspeed
        self.radarobjs.append(bullet)
        self.bullets.append(bullet)
        
        if not pos:
            pos = self.bullet_pos(shooter, bullet)
        if not velo:
            velo = self.geometry.get_velo(shooter)
        self.geometry.new_body(bullet, pos, bulletspeed*angle_vector(angle)+velo, (0, 0))
##        print 'bulletvelo',10*angle_vector(angle)
        bullet.style = style

        if hasattr(style, 'imagename'): bulletimage = style.imagename
        else: bulletimage = shooter.bulletimage
        image = Image.find_image(bulletimage, self.currentfile)
        #s = [pygame.transform.rotate(i, angle) for i in image]
        s = [i for i in image]
        self.geometry.add_circle(bullet, 0, bullet.size, density=1, image=s)
        bullet.add_geometry(self.geometry)
        # HACK HACK HACK FIXME XXX: We set a 'game' attribute in the Bullet
        # object so that the user code can call Bullet.explode(), but really
        # we never use it, and other places call bullet.explode(game), as
        # well as similar things in other places. Isn't there a better solution?
        bullet.game = self
        self.post(Event.NewObjectEvent(bullet))
        self.post(Event.ObjectShootingEvent(shooter))

        bulletsound = None
        if shooter.bulletsound:
            bulletsound = shooter.bulletsound
        elif style.firesound:
            bulletsound = style.firesound
        if bulletsound and not silent:
            self.play_sound(bulletsound, bullet)
        return bullet

    def accelerate(self, thing, force):
        v = angle_vector(self.get_angle(thing))
        m = self.geometry.get_mass(thing)
        self.add_force(thing, (v[0]*m*force, v[1]*m*force))

    def make_explosion(self, center, angle, pic, sound=None, bullet=None):
        self.post(Event.ExplosionSpriteEvent(center, angle, pic))
        if sound:
            self.play_sound(sound, bullet)

    def pause(self, start):
        self.paused = start
                
    def hit(self, geom, killstr, strength):
        # XXX: Still doesn't consider multiple-geoms-per-object case
        if geom.object.dead: return # who cares?

        # strength == None is an instant-kill and trumps other things.
        if strength != None and \
           (isinstance(self.get_geom_health(geom), types.NoneType) or \
            geom.damaged_by and geom.damaged_by != killstr):
            # FIXME: someone needs to think about invulnerability seriously
            if geom.object.hitsound:
                self.play_sound(geom.object.hitsound, geom.object)
            return

        if strength == None: # destroy!!!
            self.set_geom_health(geom, 0)
        else:
            self.change_geom_health(geom, -strength)
            if geom.object.hurtsound:
                self.play_sound(geom.object.hurtsound, geom.object)

        self.post(Event.ObjectHitEvent(geom.object, killstr,
                                       self.get_geom_health(geom) <= 0, geom,
                                       strength))
        if self.get_geom_health(geom) <= 0:
            # geom dies!!
            if geom.object == self.player:
                geom.object.dead = True
                # Do this without killing the object, so that the player
                # bounces around and remains visible and stuff
                self.post(Event.ObjectKillEvent(geom.object, killstr, True))
            else:
                if geom.object.diesound:
                    self.play_sound(geom.object.diesound, geom.object)
                self.queue_kill(geom.object, geom.label, killstr)

            if geom.object.diesound:
                self.play_sound(geom.object.diesound, geom.object)

    def unhook_ropes_with_geom(self, g):
        for player, rope in self.ropes.items():
            if g in rope.geoms:
                del self.ropes[player]

    def disable(self, obj, part):
        g = self.geometry.geoms[obj][part]
        g.disable()
        self.unhook_ropes_with_geom(g)
        self.post(Event.ToggleGeomEvent(self.geometry.geoms[obj][part], False))

    def enable(self, obj, part):
        self.geometry.geoms[obj][part].enable()
        self.post(Event.ToggleGeomEvent(self.geometry.geoms[obj][part], True))

    def player_health(self):
        return self.get_geom_health(self.geometry.geoms[self.player][0])

    def add_rope(self, ropetype, player, o2, p2, pos, d, **kwargs):
        r=ropetype(self, player, o2, p2, pos, d, **kwargs)
        self.ropes[player]= r

    def unhook(self, player):
        del self.ropes[player]

    def hooked(self, player):
        return player in self.ropes.keys()

    def add_beam(self, shooter, beam):
        self.beams[shooter] = beam
        beam.add_geometry(self.geometry)

    def beam_off(self, shooter):
        self.beams[shooter].kill(self.geometry)
        del self.beams[shooter]

    def make_inanim(self, obj):
        self.post(Event.ObjectIncomingEvent(obj))

    def add_enemy(self, e):
        self.enemies.append(e)

    def add_image(self, *args, **kwargs):
        e = Event.AddImageEvent(*args, **kwargs)
        self.post(e)
        return e.image

    def add_affects_area(self, geom, rect, func):
        return self.geometry.add_affects_area(geom, rect, func)

    def printstats(self):
        print "Bodies:", len(self.geometry.bodies)
        geomsum = 0
        for b, geomdict in self.geometry.geoms.iteritems():
            geomsum += len(geomdict)
        print "Geoms:", geomsum

    def thread(self):
        while True:
            #print self.player, 'velo', self.geometry.get_velo(self.player)
            #print 'bullets', self.bullets
            if not self.paused:
                self.flush_killqueue()
                self.frames += 1
            yield None

    def add_force(self, object, force):
        if self.inertia == False:
            s = 5
            force = force[0]*s, force[1]*s
        self.forces.setdefault(object, Vector([0, 0]))
        self.forces[object] += force
                                         
    def add_impulse(self, object, force):
        self.impulses.setdefault(object, Vector([0, 0]))
        self.impulses[object] += force

    def add_action(self, action, dialog=False):
        if dialog and self.dialog: return False # someone else is speaking now
        if dialog: self.dialog = action
        self.actions.append(action)
        return True

    def stop_action(self, action):
        if action in self.actions:
            self.actions.remove(action)
            return True

    def add_pattern(self, object, action):
        self.patterns[object] = action

    def post(self, event):
        self.evmanager.Post(event)

    def play_music(self, mfile, loop):
        self.evmanager.Post(Event.NewSoundEvent(mfile, loop, music=True))

    def play_sound(self, sfile, source=None):
        self.evmanager.Post(Event.NewSoundEvent(sfile, source=source))
