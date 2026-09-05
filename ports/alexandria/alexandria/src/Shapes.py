# Shapes used by level-loading code.
# Shapes are divided into "Shapes" and "Scenery"; "Shapes" cause new objects
# to be placed, but "Scenery" only modifies existing ones, adds graphics,
# or otherwise affects the game in another way.
# Also included are various auxilliary classes: operation, which
# represents things to do to images, and Align, which aligns object placement.

import math
import pygame
import copy
from pygame.rect import Rect
import random
import Image as ImageModule
import Patterns
import Event
import Goals
import Geometry
#from data import Object, Characters, Constants, AI
from data import Characters, Constants, AI
import data.Object
import data.Combatant
from Utils import ShapeWrapper, OPPOSITES, OTHERCENTER
from Vector import listify, avg2d, range2d, point_in_poly, pointswithin, linedist

STANDARD_THICKNESS = THICKNESS = 15
currentfile = None # passed by Level.py before running
allrooms = [] # reset by Level.py
scale_factor = None

def scale(pos):
    if not scale_factor: return pos
    x, y = pos
    return (x*scale_factor, y*scale_factor)

class operation(object):
    '''Pseudo-class which represents operations to be done to pictures.'''
    def __init__(self, picfile):
        self.picfile = picfile

    def filename(self):
        return self.picfile

    def compute(self, currentfile):
        if isinstance(self.picfile, operation):
            strip = self.picfile.compute(currentfile)
        else:
            strip = ImageModule.find_image(self.picfile, currentfile)
        return strip

class flip(operation):
    def __init__(self, picfile, fliph=False, flipv=False):
        super(flip, self).__init__(picfile)
        self.fliph = fliph
        self.flipv = flipv

    def compute(self, currentfile):
        strip = super(flip, self).compute(currentfile)
        nstrip = [pygame.transform.flip(i, self.fliph, self.flipv)
                                   for i in strip]
        return nstrip

class rotate(operation):
    def __init__(self, picfile, angle, counter=False):
        super(rotate, self).__init__(picfile)
        self.angle = angle
        if not counter:
            self.angle = -angle

    def compute(self, currentfile):
        strip = super(rotate, self).compute(currentfile)
        nstrip = [pygame.transform.rotate(i, self.angle)
                                   for i in strip]
        return nstrip


class Align(object):
    def __init__(self, conditions):
        self.conditions = conditions

    def compute_pos(self, object, rect=None):
        pos = [0, 0]
        for cond in self.conditions:
            #print cond
            a = AlignCond(*cond)
            i, p = a.compute_pos(object, rect)
            pos[i] = p
        #print pos
        return pos

class AlignCond(object):
    '''Class to handle aligning one object with another object.'''
    CRITDIM = {'left':0, 'right':0, 'top':1, 'bottom':1,
               'centerx': 0, 'centery': 1}
    def __init__(self, side, target, targside=None):
        self.side = side
        self.target = target
        if not targside:
            targside = OPPOSITES[self.side]
        self.targside = targside

    def compute_pos(self, object, rect=None):
        '''Computes pos to put object in order to satisfy constraints.'''
        d = self.CRITDIM[self.side]
        if rect: r = rect
        else: r = object.rect()
        targrect = self.target.rect()
        targrect.move_ip(self.target.pos)
        #print 'aligning', r, 'with', targrect, "'s", self.side, '--', self.targside
        #print getattr(targrect, self.side)
        oldpos = r.topleft
        setattr(r, self.targside, getattr(targrect, self.side))
        newpos = r.topleft
        #print newpos[d], oldpos[d]
        return d, (newpos[d] - oldpos[d])

# Shapes:
class Shape(object):
    '''Class for a shape as used by the user.

    For "smart placement", we accept the following forms:

    Shape(rel=walls, pos=(400, 400)) # for instance to place an object "in" a room
    Shape(rel=(left, walls, (0, 400))) # "to the left of walls, where our y=0 matches their y=400"

    self.parts: label -> geomnum

    To explicitly turn display of a shape off, you can use image=-1.
    '''
    def __init__(self, pos=(0,0), velo=(0,0), accel=(0,0), label=0,
                 pattern=None, rel=None, health=None, debug=False,
                 on_destroy=None, die_replace=None,
                 image=None, under=False, layer=None,
                 radarcolor=False, texture=None,
                 bg=None, texturebg=None,
                 inanim=None, outanim=None,
                 corner=None, remains=None, corpse=None,
                 thrustanim=None, thrustoverlay=None,
                 start=None, end=None, first_start=None, last_end=None,
                 startcorner=None, endcorner=None,
                 invertcorner=None,
                 use_start=True, use_end=True, use_first_start=True,
                 use_last_end=True,
                 use_startcorner=True,
                 use_endcorner=True, use_invertcorner=True,
                 corners_at=None,
                 **kwargs):
        self.kwargs = kwargs
        self.pos = scale(pos)
        self.rel = rel
        self.health = health
        self.debug = debug
        self.velo = velo
        self.accel = accel
        self.label = label
        self.under = under
        self.layer = layer
        self.radarcolor = radarcolor
        self.parts = {}
        self.rendered = None
        if not pattern:
            pattern = []
        self.pattern = pattern
        self.on_destroy = on_destroy
        self.die_replace = die_replace
        self.pic('image', locals())
        self.pic('thrustanim', locals())
        self.pic('thrustoverlay', locals())
        self.pic('texture', locals())
        # corner stuff should probably go in Walls
        # maybe make the name of the texture available in self.texturename?
        self.pic('texturebg', locals())
        self.pic('inanim', locals())
        self.pic('remains', locals())
        self.pic('corpse', locals())
        self.outanim = outanim
        if corners_at:
            self.corners_at = corners_at
        else:
            self.corners_at = []
        l = locals()
        self.unpack(l, 'bg', ['bgdx', 'bgdy'], [0, 0])
        self.pic('bg', l)
        self.unpack(l, 'startcorner', ['startcornerrot'], [None])
        self.unpack(l, 'endcorner', ['endcornerrot'], [None])
        self.unpack(l, 'start', ['startrot'], [None])
        self.unpack(l, 'end', ['endrot'], [None])
        self.maybe_pic_from('corner', 'texture', '-corner', l)
        self.maybe_pic_from('start', 'texture', '-start', l)
        self.maybe_pic_from('end', 'texture', '-end', l)
        self.maybe_pic_from('first_start', 'texture', '-first-start', l)
        self.maybe_pic_from('last_end', 'texture', '-last-end', l)
        self.maybe_pic_from('startcorner', 'texture', '-startcorner', l)
        self.maybe_pic_from('endcorner', 'texture', '-endcorner', l)
        self.maybe_pic_from('invertcorner', 'texture', '-invertcorner', l)
        if not self.first_start:
            self.first_start = self.start
        if not self.last_end:
            self.last_end = self.end
        self.use_start = use_start
        self.use_end = use_end
        self.use_startcorner = use_startcorner
        self.use_endcorner = use_endcorner
        self.use_invertcorner = use_invertcorner
        self.use_first_start = use_first_start
        self.use_last_end = use_last_end
        #self.pic('outanim', locals())
        self.kwargs['remains'] = remains
        self.kwargs['corpse'] = self.corpse
        self._object = None

    def copy(self):
        return copy.deepcopy(self)

    def unpack(self, locals, attr, vars, defaults):
        try:
            if len(locals[attr]) == len(vars)+1:
                for i in range(len(vars)):
                    setattr(self, vars[i], locals[attr][i+1])
                locals[attr] = locals[attr][0]
            else:
                raise TypeError, "set defaults"
        except:
            for i in range(len(vars)):
                setattr(self, vars[i], defaults[i])

    def pic(self, attr, locals):
        if (isinstance(locals[attr], str) or
            isinstance(locals[attr], operation)) and locals[attr]:
            file = locals[attr]
            if isinstance(file, str):
                file = operation(file)
            setattr(self, attr+'name', file.filename())
            setattr(self, attr, file.compute(currentfile))
        else:
            setattr(self, attr, locals[attr])

    def maybe_pic_from(self, attr, oldattr, append, locals):
        if locals[attr]:
            #print "locals[attr]", locals, attr
            self.pic(attr, locals)
        elif isinstance(locals[oldattr], str) and not locals[attr] == False:
            file = locals[oldattr] + append
            locals[attr] = file
            try:
                self.pic(attr, locals)
            except ValueError:
                setattr(self, attr, None)
        else:
            setattr(self, attr, None)

    def rect(self):
        c = self.center()
        s = self.size()
        r = Rect(0, 0, *s)
        r.center = c
        return r

    def _make_object(self, kwargs):
        '''Returns the object that should be added to the game if placed.'''
        return data.Object.Object(**kwargs)

    def add_to(self, game, object):
        '''Function which adds specified shape to the geometry of object.'''
        self._add_to(game, object)
        
    def preplace(self, game, filename=None, object=None):
        if self.inanim: game.make_inanim(self); return
        self.place(game, filename, object)
    
    def place(self, game, filename=None, object=None, replacing=None):
        '''Add an object to a game, using various parameters in self to fill
        in defaults in Geometry.add_object.'''
        if self.health != None:
            self.kwargs['health'] = self.health
        if self.layer != None:
            self.kwargs['layer'] = self.layer
        if not object: object = self._make_object(self.kwargs)
        self._object = object
        geom = game.geometry
        if replacing:
            old_obj = replacing
            self.pos = geom.get_pos(old_obj)
            self.velo = geom.get_velo(old_obj)
        # Compute position using rel argument. Add pos to allow
        # placing relative to this.
        if self.rel:
            if isinstance(self.rel, ShapeWrapper):
                #print 'relative to', self.rel
                p = game.geometry.get_pos(self.rel._object)
                #print 'which is at', p
                self.pos = map(lambda x, y: x+y, self.pos, p)
                self.rel = None
            # rel = walls
            # rel = ('left', walls, (ours, theirs))
            else:
                if len(self.rel) > 1 and isinstance(self.rel[1], ShapeWrapper):
                    # rel is just one condition
                    self.rel = [self.rel]
                a = Align(self.rel)
                p = a.compute_pos(self)
                self.pos = map(lambda x, y: x+y, self.pos, p)
                self.rel = None
                
        #print 'creating new body at', object, self.pos
        geom.new_body(object, self.pos, self.velo, self.accel)
        if self.radarcolor:
            game.radarobjs.append(object)
            if self.radarcolor != True:
                object.color = self.radarcolor
        game.add_pattern(object, Patterns.Pattern(self.pattern).thread(game, self, object))
        if self.on_destroy:
            object.on_destroy = Patterns.Pattern(self.on_destroy).thread(game, self, object)
        object.die_replace = self.die_replace
        self.add_to(game, object)
        v = self.value()
        object.outanim = self.outanim
        object.remains = self.remains
        try:
            return map(ShapeWrapper, v)
        except:
            return ShapeWrapper(v)

    def render(self, game):
        shapes = game.geometry.get_shapes()
        geoms = shapes[self._object]
        if self.rendered == None:
            self.rendered = {}
            game.post(Event.NewObjectEvent(self._object))
            for k, v in geoms.iteritems():
                self.rendered[k] = True
        else:
            for k, v in geoms.iteritems():
                if not self.rendered.has_key(k):
                    game.post(Event.NewGeomEvent(v))
                    self.rendered[k] = True

    def value(self):
        return self

    # Functions to allow derived classes to specify geometric properties
    def center(self):
        '''Center of this object'''
        return (0, 0)

    def size(self):
        '''Size of this object -- be sure to include negative coordinates!'''
        return (0, 0)

    def insidesize(self):
        return self.size()

    def disable(self):
        pass

    def enable(self):
        pass

class Scenery(Shape):
    body = None
    def __init__(self, **kwargs):
        super(Scenery, self).__init__(**kwargs)
        # These are not necessary for Scenery
        del self.kwargs['remains']
        del self.kwargs['corpse']

    def place(self, game, filename=None, object=None):
        self.game = game # Some scenery needs to know this
        if self.body: pass # Create a body object, use patterns?..
        self._add_to(game)
        return self

    def render(self, game):
        # intercept Shape.render; we've done all our rendering, thanks
        pass

class Polygon(Shape):
    def __init__(self, *args, **kwargs):
        super(Polygon, self).__init__(**kwargs)
        self.points = listify(args)

    def _add_to(self, game, object):
        print "Boned!"
        game.geometry.add_polygon(object, self.label, self.points, health=self.health)

    def center(self):
        mx, my = range2d(self.points)
        return mx/2, my/2

    def size(self):
        return range2d(self.points)

class Circle(Shape):
    def __init__(self, radius=0, center=None, density=1,
                 absent=False, **kwargs):
        self.radius = radius*(scale_factor or 1.0)
        kwargs.setdefault('size', self.radius)
        super(Circle, self).__init__(**kwargs)
        if not center:
            center = (0, 0)
        self.centerpos = scale(center)
        self.density = density
        self.absent = absent

    def _add_to(self, game, object):
        return game.geometry.add_circle(object, self.label, self.radius,
                                        self.density, self.centerpos,
                                        image=self.image, health=self.health,
                                        under=self.under, absent=self.absent,
                                        thrustanim=self.thrustanim,
                                        thrustoverlay=self.thrustoverlay)

    def center(self):
        return self.centerpos

    def size(self):
        return (2*self.radius,)*2

class Box(Shape):
    def __init__(self, lengths=(0, 0), offset=(0, 0), density=1, **kwargs):
        super(Box, self).__init__(**kwargs)
        self.lengths = [l * (scale_factor or 1.0) for l in lengths]
        self.offset = offset
        self.density = density

    def _add_to(self, game, object):
        rect = pygame.Rect(0, 0, *self.lengths)
        rect.center = self.offset
        return game.geometry.add_box(object, self.label, rect, self.density, image=self.image, texture=self.texture, health=self.health, under=self.under)

    def center(self):
        return self.offset

    def size(self):
        return (self.lengths)
    

class Player(Circle):
    PLAYERSIZE=16
    def __init__(self, pos=None, **kwargs):
        # The special placement of the pos argument here is to allow the use
        # of a non-kwarg in the first position.
        d = {'pos': pos, 'image': 'ship', 'corpse': 'ship-dead',
             'outanim':'ship-death', 'thrustoverlay': 'forwardthrust',
             'radius': self.PLAYERSIZE, 'label': 0, 'density': 1}
        d.update(kwargs)
        super(Player, self).__init__(**d)

    def _make_object(self, kwargs):
        return data.Combatant.Player(**kwargs)

    def _add_to(self, game, object):
        self.health = 'parent'    # hack to get the geom to reflect changes
                                        # in the parent
        g = super(Player, self)._add_to(game, object)
        game.player = object
        object.geom = g
        return g

class Powerup(Circle):
    SIZE = 8
    def __init__(self, **kwargs):
        d = {'radius': self.SIZE, 'density': 4, 'label': 0}
        d.update(kwargs)
        super(Powerup, self).__init__(**d)

    def _make_object(self, kwargs):
        return data.Combatant.Powerup(**kwargs)
    
class Bullet(Shape):
    '''All bullets are radarobjs automatically, you can't change that yet.
    But it's OK because unless they're shot by someone, they don't have
    a color, so they don't show up.'''
    SIZE = data.Bullet.Bullet.size
    def __init__(self, bullettype, side=Constants.SIDE_ENEMIES, bulletai=None,
                 angle = 0, bulletspeed = None, velo = None, bulletimage = 'bullet',
                 bulletstyle = '', silent = True,
                 **kwargs):
        super(Bullet, self).__init__(**kwargs)
        self.bullettype = bullettype
        self.side = side
        self.angle = angle
        self.bulletspeed = bulletspeed
        if not bulletai: bulletai = AI.NoAI()
        self.bulletai = bulletai
        if not velo: velo = (0, 0)
        self.velo = velo
        self.bulletimage = bulletimage
        self.bulletsound = ''
        self.bulletstyle = bulletstyle
        self.bulletcolor = -1
        self.attackimg = None
        self.silent = silent

    def _make_object(self, kwargs):
        return self.bullettype(self, **kwargs)

    def _add_to(self, game, object):
        game.shoot(self, object, pos=self.pos, velo=self.velo, silent=self.silent, angle=self.angle)

    def size(self):
        return (self.SIZE*2, self.SIZE*2)
    
class Rope(Shape):
    def __init__(self, obj1, obj2, pos1, pos2, start=0, length=50,
                 style = None, **kwargs):
        self.rot = kwargs.pop('rot', 0)
        super(Rope, self).__init__(**kwargs)
        
        self.obj1 = obj1.shape._object
        self.obj2 = obj2.shape._object
        self.pos1 = scale(pos1)
        self.pos2 = scale(pos2)
        self.start = start
        self.length = length
        self.style = style

    def _add_to(self, game, object):
        g = game.geometry.geoms[self.obj2][0]
        game.add_rope(data.Rope.ODERope, self.obj1, self.obj2, g,
                      self.pos2, self.length, style=self.style)

class Room(Scenery):
    def __init__(self, pts=[], clear=[]):
        self.chars = {}
        self.pts = pts
        newclear = []
        for c in clear:
            if isinstance(c, Rect):
                newclear.append([c.topleft, c.topright,
                                 c.bottomright, c.bottomleft])
            else:
                newclear.append(c)

        self.clear = newclear # areas to keep clear

    def _add_to(self, game):
        allrooms.append(self)

    def can_fit(self, shape, pos, debug=False):
        if debug: print 'trying', pos
        if not point_in_poly(pos, self.pts):
            if debug: print 'point not in poly'
            return False
        for c in self.clear:
            if point_in_poly(pos, c):
                if debug: print 'point in self.clear'
                return False
        lp = self.pts[0]
        for p in self.pts[1:]+[self.pts[0]]:
            # too close to any line segment?
            px, py = p
            d = linedist(lp, p, pos)
            if d < shape.shapesize+0.5:
                if debug: print 'point too close to', lp, p
                return False
            else:
                if debug: print lp, p, pos, d, shape.shapesize, 'far enough'
                pass
            lp = p

        # TODO: check locations of self.chars

        return True

    def rect(self):
        minx = 100000
        maxx = -100000
        miny = 100000
        maxy = -100000
        for p in self.pts:
            x, y = p
            if x < minx: minx = x
            if x > maxx: maxx = x
            if y < miny: miny = y
            if y > maxy: maxy = y
        return pygame.rect.Rect(minx, miny, maxx-minx, maxy-miny)

class GasRect(Scenery):
    def __init__(self, rect=None, **kwargs):
        self.rect = Rect(rect)
        super(GasRect, self).__init__(**kwargs)

    def _add_to(self, game):
        b = game.add_affects_area(self.rel._object, self.rect, self.obj_in_area)
        e = Event.FXEvent(b, 'gasrect', dict(rect=self.rect, colorkey=(0, 0, 0),
                                             color=(255, 255, 255)))
        game.post(e)
        self.sprite = e.response
        self.game = game

    def obj_in_area(self, objs):
        for o in objs:
            if isinstance(o, data.Bullet.Bullet):
                self.sprite.fill_in(self.game.geometry.get_pos(o))

class DamageRect(Scenery):
    def __init__(self, rect=None, rate=1, **kwargs):
        self.rect = Rect(rect)
        self.rate = rate
        super(DamageRect, self).__init__(**kwargs)

    def _add_to(self, game):
        b = game.add_affects_area(self.rel._object, self.rect, self.obj_in_area)
        e = Event.FXEvent(b, 'rect', dict(rect=self.rect, alpha=64,
                                          color=(255, 0, 0)))
        game.post(e)
        self.sprite = e.response
        self.game = game

    def obj_in_area(self, objs):
        # FIXME: HACK: works on objects, not geoms! Need to specify an
        # affects_area for geoms too?
        for o in objs:
            if isinstance(o, data.Combatant.Combatant):
                for g in self.game.geometry.geoms[o].values():
                    self.game.hit(g, 'damagerect', self.rate)

class Teleporter(Scenery):
    def __init__(self, rect=None, targetpos=None, newvelo=(0, 0),
                 increment=(0, 100), **kwargs):
        self.rect = Rect(rect)
        self.targetpos = targetpos
        self.increment = increment
        self.newvelo = newvelo
        super(Teleporter, self).__init__(**kwargs)

    def _add_to(self, game):
        b = game.add_affects_area(self.rel._object, self.rect, self.obj_in_area)
        self.game = game

    def obj_in_area(self, objs):
        for o in objs:
            self.game.geometry.set_pos(o, self.targetpos)
            self.game.geometry.set_velo(o, self.newvelo)
            self.targetpos = self.targetpos[0]+self.increment[0], self.targetpos[1]+self.increment[1]

class Multiple(Shape):
    def __init__(self, shapes=[], **kwargs):
        self.shapes = shapes
        super(Multiple, self).__init__(**kwargs)
        self.kwargs['image'] = self.image

    def _add_to(self, game, object):
        for shape in self.shapes:
            shape.add_to(game, object)

    def _make_object(self, kwargs):
        o = super(Multiple, self)._make_object(kwargs)
        del o.angle
        return o

class Controlled(Multiple):
    SIGN = {'left': -1, 'right':1, 'top':-1, 'bottom':1}
    def __init__(self, ai=None, angle=0, size=8, bulletpos=None, bulletspeed = None, health=1, attackimg=None,
                 dialogchar=None,
                 **kwargs):
        # kwargs: side, bullettype, FIXME: what else?
        self.shapesize = size
        self.debug = kwargs.get('debug', False)
        room = None
        if not kwargs.has_key('pos'):
            #raise ValueError, 'location not given'
            pass # could be enclosed in another object (EnemyBox)
        else:
            pos = kwargs['pos']
            if isinstance(pos, tuple) or isinstance(pos, list):
                room = None
                for r in allrooms:
                    if point_in_poly(kwargs['pos'], r.pts):
                        room = r
                self.randomly_placed = False
            else:
                room = pos
                kwargs['pos'] = self.random_pos(room)
                self.randomly_placed = True
            #print 'placing', self, 'at', kwargs['pos']
        self.room = room
        if room: room.chars[self] = kwargs['pos']
        kwargs.setdefault("radarcolor", True)
        kwargs['health'] = health   # default to health of at least 1
        super(Controlled, self).__init__(**kwargs)

        if not ai: ai = AI.Stationary()
        self.ai = copy.deepcopy(ai) # in case of AI.DoesAll
        self.angle = angle
        self.bulletpos = bulletpos
        self.bulletspeed = bulletspeed
        self.pic('attackimg', locals())
        self.dialogchar = dialogchar

    def relocate(self, game):
        #print 'replacing', self
        self.pos = self.random_pos(self.room)
        self.room.chars[self] = self.pos
        game.geometry.set_pos(self._object, self.pos)

    def random_pos(self, room):
        r = room.rect()
        while True:
            x = random.randint(0, r.width) + r.left
            y = random.randint(0, r.height) + r.top
            if room.can_fit(self, (x, y), self.debug):
                break
        return (x, y)
        
    def make_dialogevent(self, dialog, dialogchar):
        def dgoal(text): return Goals.Dialog(text, dialogchar, bottom=True)
        if isinstance(dialog, str):
            return dgoal(dialog)
        if isinstance(dialog, list) or isinstance(dialog, tuple):
            return Goals.Sequence(*map(dgoal, dialog))

    def _make_object(self, kwargs):
        e = data.Combatant.Controlled(ai=self.ai, size=self.shapesize,
                                   bulletpos=self.bulletpos,
                                   angle=self.angle, bulletspeed=self.bulletspeed,
                                   **kwargs)
        e.attackimg = self.attackimg # FIXME: is this a huge hack?
        # problem is, how to get attackimg (Shape attr) where Game can access
        # it when the obj shoots? Put in AI? Object.Enemy attr images = {} ?
        return e

    def add_dialog(self, dlg, char=None, after=None, *args, **kwargs):
        '''Set the dialog for the corresponding object.

        shape.set_dialog("Blah", char=characters.Narrator)
        shape.set_dialog(Dialog("Blah", char=characters.Narrator))
        shape.set_dialog(Dialog("Blah", char=characters.Narrator), after=["set_flag('foo', True")])
        shape.set_dialog(["foo", "bar"], char=characters.Narrator)
        shape.set_dialog(["foo", "bar"], char=characters.Narrator, after=["set_flag('foo', True)"])
        '''
        # Convert dlg, char and after to a Pattern that we send to the Object.
        if isinstance(dlg, Goals.Goal):
            # Search for dialog events to make them appear on the bottom
            # of the screen
            goals = [dlg] # Just one goal
            if isinstance(dlg, Goals.Sequence): # many goals
                goals = dlg
            for g in goals:
                if isinstance(g, Goals.Dialog):
                    g.bottom = True
            dialogevent = dlg
        else:
            # dlg is list of statements. Convert to Goals.Dialog event.
            # Is the first element of args is a character specifier?
            if not char:
                char = self.dialogchar
            dialogevent = self.make_dialogevent(dlg, char)
        if after == None:
            after = []
        action = Patterns.Pattern([dialogevent]+after)
        self._object._add_dialog(action, *args, **kwargs)

    def _add_to(self, game, object):
        if self.room:
            for c, pos in self.room.chars.iteritems():
                if self == c: continue
                if pointswithin(pos, self.pos, self.shapesize+c.shapesize):
                    #print "too close to", c, pos, self.pos
                    if c.randomly_placed:
                        c.relocate(game)
                    elif self.randomly_placed:
                        self.relocate(game)
                    
        super(Controlled, self)._add_to(game, object)

        if game.player and object.side != game.player.side:
            game.add_enemy(object)
        game.combatants.append(object)

    def center(self):
        return avg2d([s.center() for s in self.shapes])

    def size(self):
        return range2d([s.size() for s in self.shapes])

    def disable(self):
        self.offai = self._object.ai
        self._object.ai = data.AI.Stationary()

    def enable(self):
        self._object.ai = self.offai

Enemy=Controlled

class _wall(object):
    def __init__(self, lp, p, make_center=False, thickness=None):
        if not thickness: thickness = THICKNESS
        lx, ly = lp
        x, y = p
        # Vector math by hand, yuk!
        dx, dy = x - lx, y - ly
        l = math.sqrt(dx**2 + dy**2)
        # The image, by default, is the top. Rotating it 90
        # degrees gets you the right side, etc.
        if dy == 0:
            if dx < 0:
                r = pygame.Rect(lx, ly, dx, thickness)
                texturerot = 2*90
            else:
                r = pygame.Rect(lx, ly, dx, -thickness)
                texturerot = 0*90
        else:
            if dy < 0:
                r = pygame.Rect(lx, ly, -thickness, dy)
                texturerot = 3*90
            else:
                r = pygame.Rect(lx, ly, thickness, dy)
                texturerot = 1*90
        r.normalize()
        self.p1 = lp
        self.p2 = p
        self.v = (dx, dy)
        self.l = l
        self.rect = r
        self.make_center = make_center
        if make_center:
            self.rect.center = (lx+x)/2, (ly+y)/2
        self.rot = texturerot
    
    def rectrot(self):
        return self.rect, self.rot

    startattr = {0: 'midleft', 90: 'midtop', 180: 'midright',
                 270: 'midbottom'}
    endattr = {0: 'midright', 90: 'midbottom', 180: 'midleft',
               270: 'midtop'}
    middleattr = {0: 'midbottom', 90: 'midleft', 180: 'midtop',
                  270: 'midright'}

    def backmiddle(self):
        return getattr(self.rect, self.startattr[self.rot])

    def frontmiddle(self):
        return getattr(self.rect, self.endattr[self.rot])

    def decorate(self, game, part, image, rel, rot = None, attach=None):
        if part == 'end':
            attr = self.endattr[self.rot]
        elif part == 'middle':
            attr = self.middleattr[self.rot]
        else:
            attr = self.startattr[self.rot]
        if rot == None:
            rot = self.rot
        p = getattr(self.rect, attr)
        return game.add_image(Constants.LAYERGEOMS, p, image, rot, attr,
                              rel=rel, attach=attach, merge=attach)

class Walls(Shape):
    '''Shape representing a bunch of rectangles, each a wall.

    Walls([(0, 0), (200, 0), (200, 200), (0, 200)])
    Walls([(0, 0), (200, 0), 'rightwall', (200, 200), (0, 200)])

    closed (bool): wall between first and last point? (Default: False)
    counter (bool): points given counter-clockwise? (Default: False)

    corners_at is a list of tuples (num, side, (pic, rot)), which can
    be used to specify decorations for individual corners. An example:

        corners_at=[(-1, 'end', ('invertcorner', 90)),
                    (0, 'start', ('invertcorner', 180))]

    This says, at the end of wall segment -1 (i.e. the last one),
    place the 'invertcorner' image, rotated 90 degrees. At the start
    of the first wall segment, place the 'invertcorner' image, rotated
    180 degrees. This can be helpful when you want to specify
    individual corners on a troublesome figure.

    Strings between two points "label" a given wall.

    Assumes all walls are vertical or horizontal right now.

    '''
    def __init__(self, *points, **kwargs):
        self.closed = kwargs.pop('closed', False)
        self.counter = kwargs.pop('counter', False)
        self.thickness = kwargs.pop('thickness', None)
        self.make_center = kwargs.pop('make_center', False)
        kwargs.setdefault('static',True)
        kwargs.setdefault('health',None) # invulnerable by default
        super(Walls, self).__init__(**kwargs)
        points = listify(points)
        if self.counter:
            points.reverse()

        points = self.strip_labels(points)

        self.points = []
        for i, t in enumerate(points):
            if len(t) > 2:
                x, y = scale(points[0:1])
                self.parts[points[2]] = len(points)+i
                self.points.append((x, y))
            else:
                self.points.append(scale(t))

        self.generate_walls()

    def strip_labels(self, points):
        # Loop invariant: points[0:i] are all tuples.
        # If points[i] is a string, i-1 is the last point.
        # Wall 0 is between points 0 and 1, wall 1 is between 1 and 2..
        # So if we get a string between points i-1 and i, this string
        # refers to wall i-1.
        i = 0
        while i < len(points):
            if isinstance(points[i], str):
                self.parts[points[i]] = i-1
                del points[i]
                # points[i] is no longer a string.
            else:
                i += 1
        return points

    def generate_walls(self):
        self.walls = []
        lp = self.points[0]
        r = None
        points = self.points[1:]
        if self.closed: points.append(self.points[0])
        for i, p in enumerate(points):
            w = _wall(lp, p, make_center=self.make_center,
                      thickness=self.thickness)
            self.walls.append(w)
            lp = p
            rect, rot = w.rectrot()
            if r:
                r = r.union(rect)
            else:
                r = rect

        self._rect = r

    def decorate(self, game, n, side, image, rot=None):
        '''Add a decoration to a wall.

        side: part of the wall to be decorated ("start", "end", "middle")
        image: image to decorate it with
        rot: amount to rotate image (passed to _wall.decorate, so None means
          "guess"'''
        n = n % len(self.walls)
        g = game.geometry.geoms[self._object][n]
        self.walls[n].decorate(game, side, image, self._object,
                               rot=rot, attach=g)

    def decorate_start(self, game, n, rot=None):
        """Decorate a wall with our start image.

        If we don't have a start image, do nothing.

        rot: amount to rotate image -- None means 'guess'"""
        if self.start:
            self.decorate(game, n, 'start', self.start, rot=rot)

    def decorate_end(self, game, n, rot=None):
        if self.end:
            self.decorate(game, n, 'end', self.end, rot=rot)
            # with n points, walls use points (0, 1), (1, 2), ..,(n-2, n-1)
            # there are n-1 walls, which are numbered 0..n-2

    def _add_to(self, game, object):
        def place_wall(i):
            r, texturerot = self.walls[i].rectrot()
            rot = 0
            #rot = math.atan2(dy, dx)
            box = game.geometry.add_box(object, i, r, rotate=rot, texture=self.texture, image=self.image, under=self.under)
            box.rot = texturerot
            # FIXME: 9, 0 is just nonsense for now
            return 9, 0, box
        
        def add_tri(i, p1, p2, p3):
            return
            game.geometry.add_polygon(object, i+len(self.points), [p1, p2, p3])

        def get_corner(lastrot, rot):
            if corners.has_key((lastrot, rot)):
                attr1, attr2, crot = corners[(lastrot, rot)]
                invert = False
            else:
                attr1, attr2, crot = corners[(rot, lastrot)]
                crot = (-crot) % 360
                invert = True
                attr2, attr1 = attr1, attr2
            return attr1, attr2, crot, invert

        placecorners = [] # list for corners which we will add later
        def add_corner(p, lastrot, rot, image=self.corner,
                       invertimage=self.invertcorner, crot=None, next=True):
            if not image: return
            givencrot = crot
            if lastrot != None and rot != lastrot:
                attr1, attr2, crot, invert = get_corner(lastrot, rot)
                if next: attr = attr1
                else: attr = attr2
                #print 'corner at', p, lastrot, rot, self.corner, crot, attr
                if isinstance(givencrot, int): crot = givencrot
                if invert:
                    if invertimage:
                        crot = -crot
                        image = invertimage
                    else:
                        print "can't invertimage"
                        return # Don't bother
                args = ((Constants.LAYERGEOMS, p, image, crot, attr), {'rel':self._object})
                placecorners.append(args)

        lp = self.points[0]
        lastrot = None
        # A corner is placed in the middle of an adjoining wall.  This
        # dict specifies which part of the image goes there, and how
        # much to rotate it. If it's the "next" wall, use the first
        # attribute; if it's the "previous" wall, use the second.
        corners = {(0, 90): ("midbottom", "midleft", 0), (90, 180): ("midleft", "midtop", 90),
                   (180, 270): ("midtop", "midright", 180), (270, 0): ("midright", "midbottom", 270)}
        if self.bg:
            game.add_image(Constants.LAYERBG,
                           (self.bgdx, self.bgdy),
                           self.bg, rel=self._object)
        if self.texturebg:
            #print "adding texture", self.texturebgname, self._object
            game.add_image(Constants.LAYERBG,
                           (0, 0),
                           self.texturebg, rel=self._object, texture=self.insidesize())
        oldwallp1 = None
        points = self.points[1:]
        if self.closed:
            points.append(self.points[0])
        for i, p in enumerate(points):
            oldwallp2, newwallp1, box = place_wall(i)
            rot = box.rot
            add_corner(self.walls[i].backmiddle(), lastrot, rot)
            if lastrot == None:
                firstrot = rot
            # XXX: if we ever add geometry triangles to round out
            # corners, this is how we do it
            if oldwallp1:
                add_tri(i, oldwallp1, oldwallp2, lp)
            else:
                firstp2 = oldwallp2
            oldwallp1 = newwallp1
                
            lastrot = rot
            lp = p

        # Force adding of geom sprites before scenery
        self.render(game)

        if self.closed:
            add_tri(i, newwallp1, firstp2, self.points[0])
            add_corner(self.walls[i].frontmiddle(), lastrot, firstrot, next=False)
        else:
            rect, rot = self.walls[0].rectrot()
            p = self.points[0]
            if self.use_first_start and self.first_start:
                self.decorate(game, 0, 'start', self.first_start, self.startrot)
            if self.use_last_end and self.last_end:
                self.decorate(game, -1, 'end', self.last_end, self.endrot)

            if self.startcorner and self.use_startcorner:
                #print 'startcorner', self.startcornername
                if isinstance(self.startcorner, bool):
                    add_corner(self.walls[0].backmiddle(), (rot-90)%360, rot, crot=self.startcornerrot)
                else:
                    add_corner(self.walls[0].backmiddle(), (rot-90)%360, rot, self.startcorner,
                               crot=self.startcornerrot)
                    
            rect, rot = self.walls[-1].rectrot()

            if self.endcorner and self.use_endcorner:
                if self.debug: print "endcorner at", self.walls[-1].frontmiddle()
                if isinstance(self.endcorner, bool):
                    add_corner(self.walls[-1].frontmiddle(), rot, (rot+90)%360, next=False)
                else:
                    add_corner(self.walls[-1].frontmiddle(), rot, (rot+90)%360, self.endcorner, next=False)

        n = len(self.walls)
        for c in self.corners_at:
            try:
                wallnum, side, (style, rot) = c
            except:
                wallnum, side, style = c
                rot = None
            if hasattr(self, style):
                image = getattr(self, style)
            else:
                image = ImageModule.make_strip(style, currentfile)
            self.decorate(game, wallnum, side, image, rot=rot)

        for c in placecorners:
            args, kwargs = c
            e = game.add_image(*args, **kwargs)

    def center(self):
        return self._rect.center

    def size(self):
        return self._rect.size

    def insidesize(self):
        mx, my = range2d(self.points)
        return (mx, my)
            

class Package(Walls):
    PADDING=10
    def __init__(self, payload=None, size=None, **kwargs):
        kwargs.setdefault('closed', True) # can you imagine an open package?
        if kwargs.has_key('bg'):
            kwargs.setdefault('texturebg', kwargs.pop('bg'))
        self.payload = payload
        if not size:
            sx, sy = payload.size()
            self.s = (sx+2*self.PADDING, sy+2*self.PADDING)
        else: self.s = size

        super(Package, self).__init__([(0, 0), 'top', (self.s[0], 0),
                                       'right', self.s, 'bottom',
                                       (0, self.s[1]), 'left',], **kwargs)

        payload.origpattern = list(payload.pattern) # copy
        payload.pattern[:0] = self.motion(self.pattern)        
        payload.pattern[:0] = ['self.disable()']
        if payload.velo != (0, 0):
            payload.pattern.append((payload.velo, 1))
        payload.pattern.append('self.enable()')
        
    def _add_to(self, game, object=None):
        super(Package, self)._add_to(game, object)
        sx, sy = self.payload.size()
        r = Rect(0, 0, sx, sy)
        #print r, r.center
        r.center = self.payload.center()
        #print r, r.move(*self.pos),
        r.move_ip(*self.pos)
        r.move_ip(*self.center())
        self.payload.pos = r.center
        self.payshape = self.payload.place(game) # ie. create a new object
        game.post(Event.NewObjectEvent(self.payshape._object))

    def motion(self, pattern):
        '''Return only the motion parts of the pattern.'''
        return filter(lambda x: isinstance(x, tuple), pattern)

    def center(self):
        return self.s[0]/2, self.s[1]/2
    
    def size(self):
        return self.s

    def value(self):
        return self, self.payshape

class EnemyBox(Package):
    def __init__(self, payload=None, target=None, targetcut=None, side=None,
                 pos=None, **kwargs):
        
        self.target = target
        def vector(dir, x):
            v = {'left':(1, 0), 'right':(-1, 0), 'top':(0, 1), 'bottom':(0, -1)}
            return v[dir][0]*x, v[dir][1]*x
        # Amount to move Payload in.

        self.side = side
        rel = (side, target)
        boxpos = [0, 0]
        boxpos[1-AlignCond.CRITDIM[side]] = pos[1-AlignCond.CRITDIM[side]]
        boxpos[AlignCond.CRITDIM[side]] = 500*Controlled.SIGN[side]
        inamt = pos[AlignCond.CRITDIM[side]]
        intime = float(abs(inamt)+payload.size()[0]+20)/30
        #print 'constructing enemybox', inamt, intime
        if self.target.parts.has_key(targetcut):
            tcutact = 'disable(self.target, "%s")'%targetcut
        else:
            tcutact = '%s.open()'%targetcut
        pattern = [(vector(side, 5), 100), ((0, 0), 0),
                   'disable(self, "%s")'% OPPOSITES[side],
                   tcutact]
        payload.pattern[:0] = [(vector(side,intime),30), ((0, 0), 0)]
        #print payload.pattern

        super(EnemyBox, self).__init__(pos=boxpos, rel=rel, payload=payload, pattern=pattern, **kwargs)

    def _add_to(self, game, object):
        super(EnemyBox, self)._add_to(game, object)
        lastpos = self.pos
        lastpos[AlignCond.CRITDIM[self.side]] -= 500*Controlled.SIGN[self.side]
        r = self.rect()
        r.topleft = lastpos
        self.payload.finalpos = r.center

def can_open_door(o):
    return (isinstance(o, data.Combatant.Combatant))

class Airlock(Walls):
    def __init__(self, size, opens=0, **kwargs):
        w, h = size
        kwargs.setdefault('closed', True) # can you imagine an open package?
        super(Airlock, self).__init__([(0, 0), 'top', (w, 0),
                                       'right', (w, h), 'bottom',
                                       (0, h), 'left',], **kwargs)
        self.opens = opens

    def _add_to(self, game, object=None):
        f1 = self.obj_in_area1
        f2 = self.obj_in_area2
        d = AutoDoor
        lock = ShapeWrapper(self)
        if self.opens == 0:
            self.doors = [d(lock, 'left', func=f1), d(lock, 'right', func=f2)]
        else:
            self.doors = [d(lock, 'top', func=f1), d(lock, 'bottom', func=f2)]
        super(Airlock, self)._add_to(game, object)
        self.doors[0].place(game, object=object)
        self.doors[1].place(game, object=object)


    def door_callback(self, objs, doornum):
        x = doornum
        y = 1-doornum
        for o in objs:
            if can_open_door(o) and not self.doors[x].locked:
                self.doors[x].open()
                self.doors[y].close()
                self.doors[y].lock()
                break
        else:
            self.doors[x].close()
            self.doors[y].unlock()

    def obj_in_area1(self, objs):
        self.door_callback(objs, 0)

    def obj_in_area2(self, objs):
        self.door_callback(objs, 1)
        
class Switch(Shape):
    '''Class to place Switches, which are game objects which take
    actions under certain circumstances (ie. when collided with). An
    action is a pattern without an attached object.'''
    def __init__(self, shapes=[], action=[], **kwargs):
        kwargs.setdefault('static', True)
        super(Switch, self).__init__(**kwargs)
        self.shapes = shapes
        self.action = action

    def _make_object(self, kwargs):
        return data.Object.Switch(action=Patterns.Pattern(self.action), **kwargs)
    
    def _add_to(self, game, object):
        # FIXME: overlap with Enemy. collapse into Compound class?
        for shape in self.shapes:
            shape.add_to(game, object)

class Door(Scenery):
    '''A door in a set of walls -- something that can open and reveal a floor.

    start and end are interpreted as with Walls.
    The Walls that is being decorated will have the preceding and following
    wall decorated, unless use_startcorner (preceding) or use_endcorner
    (following) is set to False.'''
    def __init__(self, object, part, **kwargs):
        # Remember, object is a shapewrapper.
        self.locked = kwargs.pop('locked', False)
        super(Door, self).__init__(**kwargs)
        self.shape = object.shape
        self.obj = object.shape._object
        self.part = part
        self.is_open = False
        #self._object = None
        if not self.texturebg:
            texturebg = self.shape.texturename + '-opendoor'
            self.pic('texturebg', locals())
        if not self.texture:
            if not self.end:
                self.end = self.shape.end
            if not self.start:
                self.start = self.shape.start

    def _add_to(self, game):
        self.num = self.shape.parts[self.part]
        self.geom = g = game.geometry.geoms[self.obj][self.num]
        game.post(Event.GeomImageEvent(g, texture=self.texturebg, attach=False, layer=Constants.LAYERBELOWGEOMS))
        if self.texture:
            g.getGeom().texture = self.texture
            game.post(Event.ObjectRefreshEvent(g))
        if self.start:
            e = self.shape.walls[self.num].decorate(game, 'start', self.start,
                                                    self.obj, self.startrot, attach=g)
        if self.end:
            e = self.shape.walls[self.num].decorate(game, 'end', self.end,
                                                    self.obj, self.endrot, attach=g)
        l = len(self.shape.walls)
        if self.use_startcorner:
            if self.shape.walls[self.num-1].rot == \
                   self.shape.walls[self.num].rot:
                self.shape.decorate_end(game, self.num-1)
        if self.use_endcorner:
            if self.shape.walls[(self.num+1)%l].rot == \
                   self.shape.walls[self.num].rot:
                self.shape.decorate_start(game, self.num+1)

    def lock(self):
        if not self.locked:
            self.locked = True

    def unlock(self):
        if self.locked:
            self.locked = False

    def open(self):
        if not self.is_open and not self.locked:
            self.game.disable(self.obj, self.shape.parts[self.part])
            #self.game.delete_part(self.obj, self.shape.parts[self.part])
            self.is_open = True

    def close(self):
        if self.is_open and not self.locked:
            self.game.enable(self.obj, self.shape.parts[self.part])
            self.is_open = False


class AutoDoor(Door):
    def __init__(self, obj, part, **kwargs):
        self.func = kwargs.pop('func', self.obj_in_area)
        super(AutoDoor, self).__init__(obj, part, **kwargs)

    def _add_to(self, game):
        super(AutoDoor, self)._add_to(game)
        w, h = self.geom.getGeom().size
        trans = self.geom.getGeom().getPosition()[:2]
        depth = 100 # how far the door "sees" you
        excess = 24 # don't close until you're out of the way vertically
        if w > h:
            aw = w + excess
            ah = h + depth
        else:
            ah = h + excess
            aw = w + depth
        area = Rect(0, 0, aw, ah)
        area.center = trans
        game.add_affects_area(self.geom, Rect(area), self.obj_in_area)
        self.affectsarea = area

    def obj_in_area(self, objs):
        for o in objs:
            if can_open_door(o):
                self.open()
                break
        else:
            self.close()


class Damaged(Scenery):
    '''A Scenery that is used to make another object look damaged.
    Heal beam can "fix" damaged things.'''
    def __init__(self, obj, part, amount, **kwargs):
        super(Damaged, self).__init__(**kwargs)
        self.shape = obj.shape
        self.obj = obj.shape._object
        self.part = part
        self.startamt = self.amount = amount

    def _add_to(self, game):
        num = self.shape.parts[self.part]
        self.geom = game.geometry.geoms[self.obj][num]
        self.geom.damage = self
        if not self.texture:
            texture = self.shape.texturename + '-damage'
            self.pic('texture', locals())
        e = Event.GeomImageEvent(self.geom, texture=self.texture, layer=self.layer)
        game.post(e)
        self.spr = e.response

    def healed(self):
        self.spr.kill()

    def update(self):
        # Scale so that undamaged is 0, fully healed is 128
        self.spr.strip[0].set_alpha(127+128*self.amount/self.startamt)
        self.spr.flush_cache()

class Breakable(Scenery):
    def __init__(self, obj, part, health=0, damaged_by=None, **kwargs):
        self.shape = obj
        self.obj = obj._object
        self.part = part
        self.health = health
        self.damaged_by = damaged_by

    def _add_to(self, game):
        num = self.shape.parts[self.part]
        self.geom = game.geometry.geoms[self.obj][num]
        self.geom.health = self.health
        self.geom.damaged_by = self.damaged_by

    def disable(self):
        self.storedhealth = self.geom.health
        self.geom.health = None

    def enable(self):
        self.geom.health = self.storedhealth

class Image(Scenery):
    def __init__(self, object, part=None, side=None, flipv=False, fliph=False, offset=(0, 0), start=None, repeat=True, **kwargs):
        #print kwargs['image']
        kwargs.setdefault('layer', Constants.LAYERBG)
        super(Image, self).__init__(**kwargs)
        if fliph or flipv:
            self.image = ImageModule.flip_strip(self.image, fliph, flipv)
        self.shape = object.shape
        self.obj = object.shape._object
        self.part = part
        self.side = side
        self.offset = offset
        self.start = start
        self.repeat = repeat

    def _add_to(self, game):
        #print self.image, self.obj
        dx, dy = 0, 0
        if self.part:
            label = self.shape.parts[self.part]
            g = game.geometry.geoms[self.obj][label]
            i = self.image
            # Hacks to allow Align to work properly
            # We need to create rects for both this object and the image
            # and set them on the correct objects.
            r = Geometry.geom_to_rect(g)
            print "geom located at", r
            def grect():
                return r

            w, h = i[0].get_width(), i[0].get_height()
            irect = Rect(0, 0, w, h)
            g.rect = grect
            g.pos = (0, 0)
            #print g.rect(), g.pos
            a = Align([(self.side, g), (OTHERCENTER[self.side], g, OTHERCENTER[self.side])])
            dx, dy = a.compute_pos(i, irect)
            #del g.rect
            #del g.pos
            print dx, dy
        if self.offset:
            dx += self.offset[0]
            dy += self.offset[1]
        game.post(Event.AddImageEvent(self.layer,
                                            (dx, dy), self.image,
                                            rel=self.obj, start=self.start,
                                            repeat=self.repeat, **self.kwargs))

class FX(Scenery):
    def __init__(self, part, type, **kwargs):
        self.part = part
        self.type = type
        self.kwargs = kwargs
    def _add_to(self, game):
        e = Event.FXEvent(self.part, self.type, self.kwargs)
        game.post(e)
        self.sprite = e.response

    def kill(self):
        self.sprite.kill()

class Chain(Scenery):
    def __init__(self, obj1, obj2, pos1, pos2, start=0, **kwargs):
        self.rot = kwargs.pop('rot', 0)
        super(Chain, self).__init__(**kwargs)
        
        self.obj1 = obj1.shape._object
        self.obj2 = obj2.shape._object
        self.pos1 = pos1
        self.pos2 = pos2
        self.start = start

    def _add_to(self, game):
        game.post(Event.AddChainEvent(self.obj1, self.obj2,
                                      self.pos1, self.pos2,
                                      self.texture, self.rot,
                                      start=self.start, layer=self.layer))

class Music(Scenery):
    def __init__(self, filename, loop=True):
        self.mfile = filename
        self.loop = loop

    def _add_to(self, game):
        game.play_music(self.mfile, self.loop)
