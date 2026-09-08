import sys
import math
import random #For drawing random backgrounds
import pygame
import operator
import ode

import Config

pygame.display.init()
pygame.font.init()
SIZE = Config.Config.resolution
pygame.display.set_mode(SIZE, pygame.FULLSCREEN)
PORTRAITSIZE = 50

import Event
import Image
import Vector
import Numeric
import Game
import Level
import Goals
import HackFont
from data import Constants
from data.Constants import *
from data.Object import Object
from Sprite import *

movie = False #Can get set from outside in order to trigger writing movie.

def fill_texture(size, rot, txt):
    '''Pattern a surface with repeated versions of image.'''
    w, h = size
    tw, th = txt.get_size()
    if rot % 180:
        h, w = w, h
    image = pygame.Surface((int(w), int(h)))
    if txt.get_colorkey():
        image.fill(txt.get_colorkey())
        image.set_colorkey(txt.get_colorkey())
    else:
        pink = (0, 255, 255)
        image.fill(pink)
        image.set_colorkey(pink)
    for i in range(0, int(w), tw):
        for j in range(0, int(h), th):
            image.blit(txt, (i, j))
    image = pygame.transform.rotate(image, -rot)
    return image

def scale_texture(size, rot, txt):
    w, h = size
    tw, th = txt.get_size()
    if rot % 180:
        h, w = w, h
    return pygame.transform.scale(txt, (w, h))

class BGSprite(StripSprite):
    repeat = True
    def __init__(self, size):
        self.size = size
        self.state = True
        w, h = self.size
        self.stars = []
        for i in range(100):
            x, y = random.randint(0, w), random.randint(0, h)
            r = 0
            c = random.randint(1, 255)
            self.stars.append((x, y, r, c))
        self.render()
        self.precomputed = False
        super(BGSprite, self).__init__()
        self.rect = pygame.rect.Rect(0, 0, *self.size)

    def update_offset(self, offset):
        # ignore offset
        pass
        
    def render(self):
        image = pygame.surface.Surface(self.size)
        bgcolor = (0,0,0)
        image.fill(bgcolor)
        for x, y, r, c in self.stars:
            pygame.draw.circle(image, (c, c, c), (x, y), r)
        self.strip = [image]

    def draw(self, screen):
        screen.blit(self.image, self.rect)

    def precompute_invert(self):
        if self.precomputed: return
        self.precomputed = True
        darkimgs = []
        lightimgs = []
        n = 10
        image = self.strip[-1]
        image = image.convert(32)
        array = pygame.surfarray.pixels3d(image)
##        for i in range(1, n+1):
##            image = pygame.surfarray.make_surface((float(i)/n * (255-2*array.astype('l')) + array).astype(array.typecode()))
##            imgs.append(image)
        darkimgs.append(image)
        last = 255 - array
        lightimgs.append(pygame.surfarray.make_surface(last))
        neutral = pygame.surface.Surface(self.size)
        neutralcolor = (127, 127, 127)
        neutral.fill(neutralcolor)
        neutral.set_alpha(127)
        for i in range(5):
            d = darkimgs[-1].copy()
            d.blit(neutral, (0, 0))
            darkimgs.append(d)
            l = lightimgs[-1].copy()
            l.blit(neutral, (0, 0))
            lightimgs.append(l)
                   
        lightimgs.reverse()
        imgs = darkimgs+lightimgs
        imgs = [i.convert() for i in imgs]
        copy = imgs[:]
        copy.reverse()
        self.invertstrips = [imgs, copy]

    def change_states(self, state):
        self.strip = self.invertstrips[state]
        self.state = state
        self.repeat = len(self.strip)-1
        self.n = 0

    def invert(self):
        self.change_states(not self.state)

    def reset(self):
        if hasattr(self, 'invertstrips'): # we've been precomputed
            if self.strip in self.invertstrips: # we're in a transition
                self.state = True
                self.strip = self.invertstrips[self.state]
                self.repeat = len(self.strip) - 1
                self.n = self.repeat # only use last frame
        
# We make this sprite global because it can keep the inverted background
# in-memory across View instances.
bg = BGSprite(SIZE)
    
class FlashSprite(MySprite):
    GRADIENT = [(0, (1.0, 0.0, 0.0)), (40, (1.0, 1.0, 0.0))]
    def __init__(self, obj, geom, sprite, strength = 1.0, color=None):
        super(FlashSprite, self).__init__()
        self.obj = obj
        self.target = sprite
        if not color:
            color = self.interpolate(strength)
        self.color = color
        self.n = 0

    def interpolate(self, strength):
        lasts, lastcolor = self.GRADIENT[0]
        if strength == lasts: return lastcolor
        if strength == None: return self.GRADIENT[-1][1]
        i = 1
        while strength > self.GRADIENT[i][0]:
            i += 1
            if i >= len(self.GRADIENT): i-=1; break
        lstr, (lr, lg, lb) = self.GRADIENT[i-1]
        nstr, (nr, ng, nb) = self.GRADIENT[i]
        frac = float(strength - lstr)/(nstr-lstr)
        r = frac*(nr-lr)+lr
        g = frac*(ng-lg)+lg
        b = frac*(nb-lb)+lb
        return (r, g, b)

    def update_offset(self, offset):
        super(FlashSprite, self).update_offset(offset)
        self.rect = self.target.rect

        img = self.target.image.copy()
        array = pygame.surfarray.array3d(img)
        colorkey = pygame.surfarray.array_colorkey(img)
        r, g, b = self.color
        array[:, :, 0] = (colorkey*r).astype(array.dtype)
        array[:, :, 1] = (colorkey*g).astype(array.dtype)
        array[:, :, 2] = (colorkey*b).astype(array.dtype)
        surface = pygame.surfarray.make_surface(array)
        surface.set_colorkey((0, 0, 0))
        self.image = surface

    def advance(self):
        if self.n > 0:
            self.kill()
        else: self.n += 1

class RotSprite(StripSprite):
    debug = False
    def __init__(self):
        l = len(self.strip)
        self.flush_cache()
        super(RotSprite, self).__init__()

    def flush_cache(self):
        # We cache one angle for each frame of animation. This is a big win
        # for objects that don't rotate.
        self.cached = {}
        self.cachedangle = {}

    def merge(self, s2):
        super(RotSprite, self).merge(s2)
        self.flush_cache()

    def advance(self):
        super(RotSprite, self).advance()

##        if self.debug:
##            print 'n:', self.n,
##            print 'image:', self.image
##            if self.strip.files:
##                print 'files[n]:', self.strip.files[self.n]
        angle = self.get_angle()
        if angle == self.cachedangle.get(self.n, None):
            i = self.cached[self.n]
        else:
            i = pygame.transform.rotate(self.image, angle)
            i.set_alpha(self.image.get_alpha())
            self.cachedangle[self.n] = angle
            self.cached[self.n] = i
##            if self.debug:
##                print self.image.get_alpha(), i.get_alpha(), i.get_colorkey()
        self.image = i

class InSprite(RotSprite):
    '''Sprite to represent something coming onto the playing field.'''
    repeat = False
    def __init__(self, obj, angle, game):
        self.strip = obj.instrip
        self.center = obj.pos
        self.game = game
        super(InSprite, self).__init__()

    def destroy(self):
        self.object.place(self.game)

    def get_pos(self):
        return self.center
    def get_angle(self):
        return self.angle

class Explosion(RotSprite):
    repeat = False
    def __init__(self, center, angle, expfile = 'explosion'):
        self.strip = Image.make_strip(expfile, True)
        self.center = center
        self.angle = angle
        super(Explosion, self).__init__()

    def get_pos(self):
        return self.center

    def get_angle(self):
        return self.angle
    
class ThrustSprite(RotSprite):
    repeat = False
    def __init__(self, angle, pos):
        self.strip = Image.make_strip('thrust', True)
        self.angle = angle
        self.pos = pos
        super(ThrustSprite, self).__init__()

    def get_angle(self):
        return self.angle

    def get_pos(self):
        return self.pos

class BodySprite(RotSprite):
    def __init__(self, body, image):
        self.strip = image
        self.body = body
        super(BodySprite, self).__init__()

    def get_pos(self):
        return self.body.getPosition()[:2]

    def get_angle(self):
        rot = self.body.getRotation()
        c = rot[0]
        s = rot[1]
        d = 90-math.degrees(math.atan2(c, s))
        return d

class GeomSprite(RotSprite):
    gimage = None
    texture = None
    def __init__(self, geom, image=None, texture=None, repeat=True):
        self.gimage = image
        self.texture = texture
        self.repeat = repeat
        self.body = geom.getBody()
        self.object = geom.object
        # g is the geom to render
        if geom.shape == 'transform':
            g = geom.getGeom()
            self.trans = g.getPosition()[:2]
        else:
            self.trans = None
            g = geom
        self.geom = g
        self.getparams(self.geom)
        self.render(self.geom)
        self.orig_strip = self.strip
        super(GeomSprite, self).__init__()
        
    def render(self, g):
        if self.gimage == -1:
            self.strip = [pygame.Surface((1, 1))]
            # maybe self.kill()?
        elif self.gimage:
            self.strip = self.gimage
        elif self.texture:
            s = [fill_texture(g.size, g.rot, i) for i in self.texture]
            self.strip = s
        else:
            if g.shape == 'circle':
                r = g.radius
                if r != int(r): print "warning, circle with floating point radius"
                r = int(r)
                d = int(2*r)
                image = pygame.Surface((d, d))
                image.fill((10,10,10))
                pygame.draw.circle(image, (200, 100, 100), (r, r), r)
                
            if g.shape == 'box':
                image = pygame.Surface(g.size)
                image.fill((255, 255, 255))
            image.set_colorkey((10, 10, 10))
            self.strip = [image]

    def get_pos(self):
        if self.trans:
            rot = self.body.getRotation()
            trans = rot[0]*self.trans[0]+rot[1]*self.trans[1], \
                    rot[0]*self.trans[1]-rot[1]*self.trans[0]
            return map(math.floor, map(operator.add, trans,
                       self.body.getPosition()[:2]))
        return self.body.getPosition()[:2]

    def get_angle(self):
        try:
            return self.object.angle
        except:
            rot = self.body.getRotation()
            c = rot[0]
            s = rot[1]
            d = 90-math.degrees(math.atan2(c, s))
            return d

    def switch(self, newstrip, permanent=False):
        self.strip = newstrip
        if permanent: self.orig_strip = newstrip
        self.n = 0

    def advance(self):
        super(GeomSprite, self).advance()
        if self.strip != self.orig_strip and self.cycled:
            self.strip = self.orig_strip
            self.n = 0

    def refresh(self):
        print "refreshing", id(self)
        self.gimage = self.texture = None
        self.getparams(self.geom)
        self.render(self.geom)
        self.orig_strip = self.strip

    def getparams(self, g):
        if self.gimage or self.texture: return
        
        # get image from transform geom -- is this where it will be placed?
        if hasattr(g, 'image') and g.image:
            self.gimage=g.image
            
        elif hasattr(g, 'texture') and g.texture:
            self.texture = g.texture
        #print g, g.image

class MyRectSprite(MySprite):
    def __init__(self, rect, geom, colorkey=None, color=None, alpha=None,
                 **kwargs):
        rect = pygame.Rect(rect)
        super(MyRectSprite, self).__init__(**kwargs)
        self.color = color
        self.colorkey = colorkey
        self.image = pygame.Surface(rect.size)
        self.image.set_colorkey(colorkey)
        self.image.set_alpha(alpha)
        self.rect.size = rect.size
        self.topleft = rect.topleft
        self.body = geom.getBody()

    def update_offset(self, offset):
        # FIXME: assumes topleft at body's (0, 0)
        pos = self.body.getPosition()[:2]
        self.rect.topleft = pos
        self.rect.move_ip(offset)
        self.rect.move_ip(self.topleft)

class RectSprite(MyRectSprite):
    def __init__(self, *args, **kwargs):
        super(RectSprite, self).__init__(*args, **kwargs)
        self.image.fill(self.color)

class GasRectSprite(MyRectSprite):
    def __init__(self, *args, **kwargs):
        super(GasRectSprite, self).__init__(*args, **kwargs)
        self.image.fill(self.colorkey)

    def fill_in(self, pos):
        # FIXME: assumes topleft at (0, 0)
        rel = self.body.getPosition()[:2]
        pos = map(int, map(operator.sub, pos, rel))
        self.image.set_at(pos, self.color)

class BGRectSprite(MyRectSprite):
    def __init__(self, rect, part, background, *args, **kwargs):
        super(BGRectSprite, self).__init__(rect, part, *args, **kwargs)
        self.bgsprite = background

    def update_offset(self, offset):
        super(BGRectSprite, self).update_offset(offset)
        self.realrect = self.rect
        self.rect  = self.rect.clip(self.bgsprite.image.get_rect())  # copy
        if self.rect.width > 0 and self.rect.height > 0:
            self.image = self.bgsprite.image.subsurface(self.rect)
        else:
            self.image = pygame.Surface((1, 1))

    def advance(self):
        self.rect = self.realrect
        super(BGRectSprite, self).advance()

MODE_FILL = 0
MODE_SCALE = 1
def draw_rope(p1, p2, texture, offset, rot=0, mode=MODE_FILL):
    d = math.sqrt((p1[0]-p2[0])*(p1[0]-p2[0]) + (p1[1]-p2[1])*(p1[1]-p2[1]))
    v = p2[0]-p1[0], p2[1]-p1[1]
    if rot % 180:
        h = texture.get_width()
    else:
        h = texture.get_height()
    if mode == MODE_FILL:
        image = fill_texture((d, h), rot, texture)
    else:
        image = scale_texture((d, h), rot, texture)
    image = pygame.transform.rotate(image, -math.degrees(math.atan2(v[1], v[0])))
    imagerect = image.get_rect()
    center = (p1[0]+p2[0])/2, (p1[1]+p2[1])/2
    imagerect.center = map(operator.add, center, offset)
    return (image, imagerect)

class ChainSprite(MySprite):
    def __init__(self, body1, body2, pos1, pos2, txt, rot, start = 0):
        super(ChainSprite, self).__init__()
        self.body1 = body1
        self.body2 = body2
        self.pos1 = pos1
        self.pos2 = pos2
        self.txt = txt
        self.rot = rot
        self.n = start

    def update_offset(self, offset):
        self.regen(offset)

    def advance(self):
        self.n += 1
        if self.n >= len(self.txt):
            self.n = 0

    def regen(self, offset):
        p1 = map(operator.add, self.body1.getPosition()[:2], self.pos1)
        p2 = map(operator.add, self.body2.getPosition()[:2], self.pos2)
        self.image, self.rect = draw_rope(p1, p2, self.txt[self.n], offset, self.rot)

class FunctionSprite(MySprite):
    def __init__(self, view, funcname):
        super(FunctionSprite, self).__init__()
        self.view = view
        self.funcname = funcname

    def update_offset(self, offset):
        getattr(self.view, "draw_%s" % self.funcname)(self, offset)

class View(object):
    fx_funcs = {}
    font = HackFont.HackFont("freesans.ttf", 17)
    healthfont = HackFont.HackFont("freesansbold.ttf", 18)
    def __init__(self, game):
        self.screen = pygame.display.set_mode([800, 600], pygame.FULLSCREEN)
        # Precompute some helpful positions on-screen
        for attr in ['topleft', 'topright', 'bottomleft', 'bottomright']:
            setattr(self, attr, getattr(self.screen.get_rect(), attr))
        #player = self.player = game.player
        self.game = game
        meta = game.metainfo
        self.background = bg
        if meta.get('invertable', False):
            self.background.precompute_invert()
        bg.reset()
        #load_background(self.background)

        # Frame counter.
        self.i = 0

        # We load some strips here because we use them in draw().
        self.ropestrip = Image.make_strip('ropebeam', True)
        self.ropehookstrip = Image.make_strip('beamhook', True)
        self.scaleropestrip = Image.make_strip('trirope', True)


        # HUD stuff
        self.hud_surf = pygame.Surface((200, 100))
        self.hud_surf.fill((0, 127, 255))
        self.hud_surf.set_alpha(24)
        self.hud_rect = self.hud_surf.get_rect()
        self.hud_rect.bottomleft = self.bottomleft
        self.outer = Image.make_strip('lifebar-outer', True)[0]
        self.lifebar = Image.make_strip('lifebar', True)[0]
        self.gear1 = Image.make_strip('gear1', True)[0]
        self.gear2 = Image.make_strip('gear2', True)[0]

        # The GeomSprite for a given geom.
        self.geom_sprites = {}

        # The group of sprites for a given geom.
        self.geom_groups = {}

        # The group of sprites for a given object.
        self.obj_groups = {}

        # All sprites.
        self.spritesgroup = pygame.sprite.Group()

        # Sprites used in explosions.
        self.explodesprites = pygame.sprite.Group()

        # "Flash" sprites for when something gets hit.
        self.flashsprites = pygame.sprite.Group()
        self.flash_this_frame = {}

        # Sprites for incoming objects.
        self.in_sprites = {}

        # Sprites used for depicting thrust.
        self.thrustsprites = pygame.sprite.Group()

        # Sprites used for depicting thrust by going over another object.
        self.thrustoverlays = {}

        # Attribute to keep track of whether objects were thrusting already.
        self.startthrust = {}

        self.layers = LayerGroup()
        self.layers.add(FunctionSprite(self, 'ropes'), under=True, layer=Constants.LAYERGEOMS)
        self.layers.add(FunctionSprite(self, 'radar'), under=True, layer=Constants.LAYERGEOMS)
        self.layers.add(FunctionSprite(self, 'speed'), under=True, layer=Constants.LAYERGEOMS)
        self.layers.add(FadeSprite(self.screen.get_size(), (0, 0, 0), ticks=10, reverse=True), layer=Constants.LAYEREXPLOSIONS)

    def kill_all(self):
        '''A sprite keeps track of its groups, which keep track of their
        sprites. This is an easy reference loop. Break all of them by killing
        the sprites.'''
        for sprite in self.layers.sprites():
            sprite.kill()
        self.geom_sprites.clear()
        # Any sprites that aren't in layers? (Disabled sprites, for instance.)
        for key, value in self.geom_groups.iteritems():
            for sprite in value:
                sprite.kill()
        self.obj_groups.clear()

    def thread(self):
        '''Infinite loop that just calls draw.'''
        while True:
            self.draw(self.screen)
            self.flash_this_frame.clear()
            yield None
            
    def draw_bg(self):
        self.background.draw(self.screen)
        #self.screen.blit(self.background.image, self.background.rect)
        self.background.advance()

    def draw_radar(self, sprite, offset):
        SCALE = 10
        geom = self.game.geometry
        p = geom.get_pos(self.game.player)
        radarobjs = self.game.radarobjs
        # self.game.combatants + self.game.bullets
        for obj in radarobjs:
            if obj.static: continue
            if obj.color == -1: continue
            p2 = geom.get_pos(obj)
            delta = (p2[0] - p[0])/SCALE, (p2[1] - p[1])/SCALE
            color = obj.color
            size = int(2*obj.size/10+1)
            pygame.draw.line(self.screen, color, (400, 300), (400+delta[0], 300+delta[1]), size)

    def draw_speed(self, sprite, offset):
        geom = self.game.geometry
        if Config.Config.velo_indicator:
            v = geom.get_velo(self.game.player)
            pygame.draw.line(self.screen, (0, 0, 255), (400, 300), (400+v[0]*5, 300+v[1]*5), 4)

        if hasattr(self.game.player, 'thrust') and Config.Config.accel_indicator:
            a = self.game.player.thrust
            pygame.draw.line(self.screen, (0, 255, 255), (400, 300), (400+a[0]*80, 300+a[1]*80), 4)


    def draw_ropes(self, sprite, offset):
        screen_blit = self.screen.blit
        # Drawing ropes can't be done in sprites because there could,
        # potentially, be a variable number of segments per rope. As
        # such, it is easier to do right here.
        # FIXME: some better mechanism for specifying, this rope has a hook
        # image, this one needs to be scaled versus repeated, etc?
        for r in self.game.ropes.values():
            segs = r.segments()
            p0 = segs[0][0]
            if r.style == 'player':
                hooki = self.ropehookstrip[self.i%len(self.ropehookstrip)]
                hookrect = hooki.get_rect()
                hookrect.center = p0
                hookrect.move_ip(offset)
                screen_blit(hooki, hookrect)
            if r.style != 'player':
                strip = self.scaleropestrip; mode = MODE_SCALE
            else: strip = self.ropestrip; mode = MODE_FILL
            for s in segs:
                p1, p2 = s
                image, imagerect = draw_rope(p1, p2, strip[self.i%len(strip)], offset, mode=mode)

                screen_blit(image, imagerect)

    def draw(self, screen, offset=None):
        paused = self.game.paused
        screen_blit = screen.blit
        self.draw_bg()
        geom = self.game.geometry
        if not offset:
            # Default offset is to put the player in the middle of the screen.
            offset = Vector.Vector([screen.get_width()/2,
                                    screen.get_height()/2]) - \
                                    geom.get_pos(self.game.player)
        geoms = geom.get_shapes()
        n = 0

        def spriteblit():
            # The slice is because sprite.advance() can kill() the
            # sprite, which leads to skipping the next sprite. Weirdness.
            # It's possible to work around this by telling LayerGroup to
            # buffer deleting sprites until it gets a call to flush(), but
            # tests suggested this wasn't a big performance gain, so I'm
            # leaving this.
            for s in self.layers.sprites()[:]:
                s.update_offset(offset)
                screen_blit(s.image, s.rect)
                if not paused: # don't switch frames if paused
                    s.advance()

        spriteblit()

        # n = len(self.layers.sprites())
	# print "drawn", n, "sprites"

        for b in self.game.beams.values():
            segs = b.segments()
            for s in segs:
                p1, p2 = s
                p1 = p1[0] + offset[0], p1[1] + offset[1]
                p2 = p2[0] + offset[0], p2[1] + offset[1]
                pygame.draw.line(screen, (255, 0, 0), p1, p2, 1)

        self.draw_health()
        self.draw_fps()
        self.draw_goals(offset)
        
        player = self.game.player
        if player.thrustpos and self.i % 12 == 0:
            s = ThrustSprite(self.game.get_angle(player), player.thrustpos)
            self.thrustsprites.add(s)
            self.layers.add(s, layer=Constants.LAYERGEOMS)
        player.thrustpos = None

        for o, geoms in geom.geoms.iteritems():
            if o.thrusting:
                if not self.startthrust.has_key(o):
                    self.startthrust[o] = True
                    for g in geoms.values():
                        if g.thrustanim:
                            s = self.geom_sprites[g]
                            s.switch(g.thrustanim, permanent=True)
                        if g.thrustoverlay:
                            s = GeomSprite(g, image=g.thrustoverlay)
                            self.thrustoverlays[g] = s
                            self.layers.add(s, layer=Constants.LAYERABOVEGEOMS)
                o.thrusting = False
            else:
                if self.startthrust.has_key(o):
                    del self.startthrust[o]
                for g in geoms.values():
                    if self.thrustoverlays.has_key(g):
                        s = self.thrustoverlays.pop(g)
                        self.layers.remove(s)
                    if g.thrustanim:
                        # Re-render to restore, hope there weren't any
                        # decorations
                        self.geom_sprites[g].render(g)
        
        def flip():
            '''For benchmarking.'''
            pygame.display.flip()
        flip()
        if movie and not paused:
            pygame.image.save(screen, 'test-%04d.tga'%self.i)
        self.i += 1

    def add_to_group(self, geom, sprite, groupdict=None):
        if groupdict == None: groupdict = self.geom_groups
        if groupdict.has_key(geom):
            group = groupdict[geom]
        else:
            # needs to be ordered so that if group is removed/readded, sprites
            # stay in same order
            group = groupdict[geom] = pygame.sprite.OrderedUpdates()
        group.add(sprite)

    def add_to_obj(self, obj, sprite):
        self.add_to_group(obj, sprite, self.obj_groups)

    def new_geom(self, geom, layer=None):
        s = GeomSprite(geom)
        self.geom_sprites[geom] = s
        self.add_to_group(geom, s)
        self.spritesgroup.add(s)
        if not layer:
            layer = Constants.LAYERGEOMS

        if not isinstance(geom.under, bool) and not geom.under == None:
            layer = geom.under
            geom.under = True
        s.layer = layer
        self.layers.add(s, layer=layer, under=geom.under)

    def Notify(self, event):
        if isinstance(event, Event.ObjectRefreshEvent):
            if not event.obj: return
            print "refresh event", event.obj
            if isinstance(event.obj, Object):
                # as far as I know, this code path never gets activated
                # It should work if it does get called, but it might wipe
                # decorations off the rest of the object.
                print "Refreshing a whole object! Oh no!"
                geoms = self.game.geometry.get_shapes()[event.obj].values()
            else:
                geoms = [event.obj]

            for geom in geoms:
                #self.geom_sprites[geom] # just see if it's there
                self.geom_sprites[geom].refresh()
            print 'spriterefresh'

        elif isinstance(event, Event.NewGeomEvent):
            self.new_geom(event.geom)

        elif isinstance(event, Event.NewObjectEvent):
            self.in_sprites.pop(event.obj, None)
            layer = event.obj.layer
            for geom in self.game.geometry.get_shapes()[event.obj].values():
                #self.geom_sprites[geom] # just see if it's there
                self.new_geom(geom, layer=layer)
            if event.obj.image:
                s = BodySprite(self.game.geometry.bodies[event.obj], event.obj.image)
                self.add_to_obj(event.obj, s)
                self.layers.add(s, layer=Constants.LAYERBG, under=True)
            
        elif isinstance(event, Event.AddImageEvent):
            rel = event.rel
            if rel:
                rel = self.game.geometry.bodies[rel]
            txt = event.texture
            if txt:
                w, h = txt
                def texturate(i):
                    return fill_texture((w, h), 0, i)
                event.strip = map(texturate, event.strip)
            if event.type: sprite = event.type
            else: sprite = ImageSprite
            s = sprite(event.pos, event.strip, event.rot, event.attr,
                       rel, start=event.start, repeat=event.repeat,
                       **event.kwargs)
            if event.merge:
                self.geom_sprites[event.merge].merge(s)
            else:
                # MERGING IS DISABLED RIGHT NOW for all other sprites.
                # If you want to benchmark it, just remove the "and False"
                # clause in the if statement.

                # This would probably be a better optimization if we
                # checked if the images overlapped. That's too hard for right
                # now, though. 

                # See if we can merge with any of the other sprites on this
                # layer. FIXME: HACK. Is there a better way to get all the
                # sprites that are on a layer, other than having a dict of
                # layers -> groups?
                layer = self.layers.layer_sprites(event.layer)
                merged = False
                # For now we only merge BG sprites because we expect
                # that ABOVEGEOM sprites are too small and too far
                # apart for there to be a gain. We should really check whether
                # the rectangles overlap here instead.
                if self.obj_groups.has_key(event.rel) and \
                       event.layer == Constants.LAYERBG and False:
                    for ls in layer:
                        if ls in self.obj_groups[event.rel]:
                            print "merging", ls, s, ls.get_pos(), s.get_pos()
                            ls.merge(s)
                            merged = True
                if not merged:
                    self.layers.add(s, layer=event.layer)
                    if event.attach:
                        self.geom_groups[event.attach].add(s)
                        s.layer = event.layer
                    self.add_to_obj(event.rel, s)
            event.image = s

        elif isinstance(event, Event.ToggleGeomEvent):
            group = self.geom_groups[event.geom]
            if event.toggle == False:
                self.layers.remove(group)
            else:
                for sprite in group:
                    self.layers.add(sprite, layer=sprite.layer)

        elif isinstance(event, Event.GeomImageEvent):
            s = GeomSprite(event.geom, image=event.image, texture=event.texture)
            #print s
            layer = Constants.LAYERGEOMS
            if event.layer: layer = event.layer
            
            self.layers.add(s, layer=layer)
            if event.attach:
                self.geom_groups[event.geom].add(s)
            event.response = s

        elif isinstance(event, Event.ExplosionSpriteEvent):
            s = Explosion(*event.args)
            self.explodesprites.add(s)
            self.layers.add(s, layer=Constants.LAYEREXPLOSIONS)
        elif isinstance(event, Event.ObjectKillEvent):
            # XXX: still doesn't handle very well multiple-geom-objects
            geoms = self.game.geometry.get_shapes()
            outanim = None
            if hasattr(event.obj, 'outanim') and event.obj.outanim:
                outanim = event.obj.outanim
                if outanim.find("%") >= 0:
                    # Try formatting the string. If there's no strip with that
                    # name, try stripping the formatting.
                    # This is a bit simplistic; more sophisticated approaches
                    # with more variables might have to select which variables
                    # to drop first.
                    def f(anim):
                        return Image.find_image(anim, self.game.currentfile)
                    try:
                        strip = f(outanim % {'killer': event.killstr})
                        
                    except ValueError:
                        strip = f(outanim % {'killer': ''})
                else:
                    strip = Image.find_image(outanim, self.game.currentfile)
            
            for key, geom in geoms[event.obj].iteritems():
                if hasattr(event.obj, 'corpse') and event.obj.corpse:
                    s = GeomSprite(geom, image=event.obj.corpse, repeat=True)
                    self.geom_sprites[geom] = s
                    # Replace the old sprites in self.geom_groups[geom] with
                    # this corpse
                    for olds in self.geom_groups[geom].sprites():
                        olds.kill()
                    g = pygame.sprite.Group()
                    g.add(s)
                    # Add corpse to geom_groups, so that it can be deleted
                    # if need be.
                    self.geom_groups[geom] = g
                    self.layers.add(s, layer=Constants.LAYERGEOMS)
                # Do outanim after corpse so that deleting the old geoms won't
                # delete the outanim.
                if outanim:
                    repeat = False
                    if event.obj.remains:
                        if isinstance(event.obj.remains, list):
                            # Repeat after the last image given here.
                            repeat = len(strip)
                            strip.extend(event.obj.remains.images)
                        else:
                            # event.obj == True or something. Hold the
                            # last image of the strip.
                            repeat = len(strip)-1
                    s = GeomSprite(geom, image=strip, repeat=repeat)
                    # Don't add outanim to geom_groups, or it'll get deleted
                    # by the DeleteEvent.
                    #self.geom_groups[geom].add(s)
                    self.layers.add(s, layer=Constants.LAYEREXPLOSIONS)

        elif isinstance(event, Event.ObjectDeleteEvent):
            # XXX: still doesn't handle very well multiple-geom-objects
            # Sometimes objects are deleted multiple times. This used to be
            # true of Player; it may be true of other objects too, especially
            # if they leave a corpse.
            geoms = self.game.geometry.get_shapes()
            for key, geom in geoms[event.obj].iteritems():
                g = self.geom_groups[geom]
                for s in g.sprites():
                    s.kill()
                del self.geom_sprites[geom]
                del self.geom_groups[geom]
                    
            # also delete all geoms in self.obj_groups[obj]
            if self.obj_groups.has_key(event.obj):
                for s in self.obj_groups[event.obj].sprites():
                    s.kill()
                del self.obj_groups[event.obj]

        elif isinstance(event, Event.ObjectDestroyPartEvent):
            # event.obj is a geom
            label = event.obj.label
            geom = event.obj
            g = self.geom_groups[geom]
            for s in g.sprites():
                s.kill()
            del self.geom_sprites[geom]
            del self.geom_groups[geom]
        elif isinstance(event, Event.ObjectIncomingEvent):
            o = event.obj
            s = InSprite(obj, 0, self)
            self.spritesgroup.add(s)
            self.layers.add(s, layer=Constants.LAYERGEOMS)
            self.in_sprites[o] = s
        elif isinstance(event, Event.ObjectHitEvent):
            geoms = self.game.geometry.get_shapes()
            if event.geom: flash = [event.geom]
            else: flash = geoms[event.obj].values()
            if tuple(flash) in self.flash_this_frame: return
            self.flash_this_frame[tuple(flash)] = True
            for geom in flash:
                s = FlashSprite(event.obj, geom, self.geom_sprites[geom], event.strength)
                self.flashsprites.add(s)
                self.layers.add(s, layer=Constants.LAYEREXPLOSIONS)
        elif isinstance(event, Event.ObjectShootingEvent):
            if not event.obj.attackimg: return
            geoms = self.game.geometry.get_shapes()
            for key, geom in geoms[event.obj].iteritems():
                s = self.geom_sprites[geom]
                s.switch(event.obj.attackimg)

        elif isinstance(event, Event.AddChainEvent):
            b1 = self.game.geometry.bodies[event.obj1]
            b2 = self.game.geometry.bodies[event.obj2]
            s = ChainSprite(b1, b2, event.pos1, event.pos2,
                            event.txt, event.rot, start=event.start)
            layer = event.layer
            if layer == None: layer = Constants.LAYERBG
            self.layers.add(s, layer=layer)
        
        elif isinstance(event, Event.ScreenshotEvent):
            pygame.image.save(self.screen, 'test-%04d.tga'%self.i)

        elif isinstance(event, Event.RenderAllEvent):
            # Get a rect that includes every image on the screen.
            r = pygame.rect.Rect(0, 0, 0, 0)
            for sprite in self.layers.sprites():
                sprite.update_offset((0, 0))
                r.union_ip(sprite.rect)

            s = pygame.Surface(r.size)
            # We create a new offset which will, when added, put the topleft of
            # r at (0, 0) on s.
            self.draw(s, offset=(-r.topleft[0], -r.topleft[1]))
            levelname = Level.LevelFile(self.game.currentfile)
            levelname = "%s-%s"%(levelname.campaign, levelname.level)
            pygame.image.save(s, '%s.tga'%levelname)

        elif isinstance(event, Event.FXEvent):
            r = self.fx_funcs[event.type](self, event.part, **event.kwargs)
            event.response = r

    textcolor = (255, 255, 255)
    def draw_fps(self):
        if self.game.fps > 27 and not Config.Config.showfps: return   # nobody needs to see that
        fps = "fps: %d"%self.game.fps
        s = self.font.render(fps, True, self.textcolor, (0, 0, 0))
        s.set_colorkey((0, 0, 0))
        r = s.get_rect()
        r.bottomright = self.bottomright
        self.screen.blit(s, r)

    def draw_health(self):
        #self.screen.blit(self.hud_surf, self.hud_rect)
        x = 0
        outer = self.outer
        lifebar = self.lifebar
        gears = self.gear1, self.gear2
        for c in [self.game.player]+self.game.combatants:
            if c.side != self.game.player.side: continue
            if not c.show_info: continue

            x += 3
            portrait = Image.make_strip("hero", True)[0]
            r = portrait.get_rect()
            r.bottom = self.bottomleft[1] - 10
            r.left = x
            self.screen.blit(portrait, r)

            x += portrait.get_width()+1
            r = outer.get_rect()
            r.bottom = self.bottomleft[1] - 10
            r.left = x
            self.screen.blit(outer, r)

            if hasattr(c, 'gear'):
                g = gears[c.gear]   # c.gear True -> gear2
                r3 = g.get_rect()
                r3.right = x + outer.get_width()
                r3.bottom = r.top - 2
                self.screen.blit(g, r3)

            v = self.game.geometry.get_velo(self.game.player)
            speed = math.sqrt(v[0]*v[0]+v[1]*v[1])
            s = self.healthfont.render("%0.2f"%speed, True, self.textcolor, (0, 0, 0))
            s.set_colorkey((0, 0, 0))
            r2 = s.get_rect()
            r2.bottom = r3.bottom
            r2.left = x
            self.screen.blit(s, r2)

            x += 2                      # left border
            health = c.health
            r = lifebar.get_rect()
            r.bottom = self.bottomleft[1] - 10-2
            r.left = x
            area = lifebar.get_rect()
            if health < 0: health = 0   # width must be nonnegative
            area.width = health
            self.screen.blit(lifebar, r, area)

            s = self.healthfont.render("%d"%health, True, self.textcolor)
            r2 = s.get_rect()
            r2.center = r.center
            self.screen.blit(s, r2)

            x += outer.get_width()    # right border
            x += 2

    def draw_goals(self, offset):
        '''This draws all the goals in self.goals.'''
        # Each goal is really a Goals.Goal!
        for g in self.game.goals:
            if not g.visible: continue
            try:
                View.draw_event_funcs[g.__class__](self, g, offset)
            except KeyError:
                pass # Oh, well

    # A table of drawing functions for each goal.
    def draw_objectin(self, event, offset):
        area = event.area.move(offset)
        if event.rel:
            area.move_ip(self.game.geometry.get_pos(event.rel._object))
        pygame.draw.rect(self.screen, (100, 200, 100), area, 2)

    def draw_isnt(self, event, offset):
        #Uh, hmm.
        pass

    def draw_which(self, event, offset):
        #Draw them the same color?
        pass

    def draw_all(self, event, offset):
        pass

    def draw_ticks(self, event, offset):
        pass

    def draw_seconds(self, event, offset):
        pass

    def draw_kills(self, event, offset):
        pass

    def draw_heals(self, event, offset):
        # outline object in red or something?
        pass
        
    def draw_noneevent(self, event, offset):
        pass

    def draw_never(self, event, offset):
        pass

    def draw_dialog(self, event, offset):
        try:
            event.window
        except AttributeError:
            self.render_sprite(event)
        self.screen.blit(event.window, event.windowrect)

    def draw_gui(self, event, offset):
        event.gui.draw()

    def draw_sequence(self, event, offset):
        pass

    def fx_invert(self, part, **args):
        self.background.invert()
        self.textcolor = (0, 0, 0)

    def fx_fade(self, part, **args):
        color = args.pop('color')
        ticks = args.pop('ticks')
        s = FadeSprite(self.screen.get_size(), color, ticks, **args)
        self.layers.add(s, layer=Constants.LAYEREXPLOSIONS)

    def fx_rotozoom(self, part, **args):
        if isinstance(part, str):
            image = Image.find_image(part, self.game.currentfile, False)

        s = ZoomSprite(image=image, **args)
        self.layers.add(s, layer=Constants.LAYEREXPLOSIONS)
        return s

    def fx_darkness(self, part, **args):
        s = DarkSprite(self.screen.get_size(), **args)
        self.layers.add(s, layer=Constants.LAYEROVERLAY)
        return s

    def fx_rect(self, part, rect=None, **kwargs):
        s = RectSprite(rect, part, **kwargs)
        self.layers.add(s, layer=Constants.LAYERGEOMS)
        return s

    def fx_gasrect(self, part, rect=None, **kwargs):
        s = GasRectSprite(rect, part, **kwargs)
        self.layers.add(s, layer=Constants.LAYERGEOMS)
        return s

    def fx_flash(self, part, **kwargs):
        obj = part._object
        color = kwargs.get('color', (1.0, 1.0, 1.0))
        layer = kwargs.get('layer', Constants.LAYEREXPLOSIONS)
        for geom in self.game.geometry.geoms[obj].values():
            s = FlashSprite(part, geom, self.geom_sprites[geom],
                            color=color)
            self.flashsprites.add(s)
            self.layers.add(s, layer=layer)

    def fx_bgrect(self, part, rect=None, **kwargs):
        part = self.game.geometry.geoms[part._object].values()[0]
        s = BGRectSprite(rect, part, self.background, **kwargs)
        self.layers.add(s, layer=Constants.LAYERABOVEGEOMS)
        return s
            
    def render_sprite(self, event):
        '''For rendering a sprite from a Dialog goal.'''
        s = DialogRenderer(self.font).render(event)

            

    fx_funcs = {'invert': fx_invert, 'fade': fx_fade, 'rotozoom': fx_rotozoom,
                'darkness': fx_darkness, 'gasrect': fx_gasrect, 'rect': fx_rect,
                'bgrect': fx_bgrect, 'flash': fx_flash}


def extract_line(words, font, limit):
    i = 0
    line = words.pop(0)
    while words and font.size(line + ' ' + words[0])[0] < limit:
        line += ' ' + words.pop(0)
    return line

def wrap_text(font, text, color, bg, w):
    words = text.split()

    newh = 0
    lines = []
    while words:
        line = extract_line(words, font, w)
        lsurf = font.render(line, True, color, bg)
        newh += font.get_height()
        lines.append(lsurf)

    s = pygame.Surface((w, newh))
    s.fill(bg)
    h = 0

    for line in lines:
        s.blit(line, (0, h))
        h += font.get_height()

    return s, pygame.rect.Rect(0, 0, w, newh)


class DialogRenderer(object):
    dialog_border = Image.make_strip('dialogborder', True)[0]
    dialog_corner = Image.make_strip('dialogborder-corner', True)[0]
    portrait_border = Image.make_strip('portraitborder', True)[0]
    portrait_corner = Image.make_strip('portraitborder-corner', True)[0]
    def __init__(self, font):
        self.font = font

    def render(self, goal):
        # FIXME: this code puts a bunch of data in goal, but I don't
        # remember why
        w, h = pygame.display.get_surface().get_size()

        windw = int(w*.9)
        pbh = self.portrait_border.get_height()

        # portraits are 50x50
        # border to the left and to the right of the window
        # portrait border to the left and right of the portrait
        # 5 pixels between text and portrait (on left)
        # 5 pixels between text and border (on right)
        textw = windw - PORTRAITSIZE - 2*self.dialog_border.get_height() \
                - 2*pbh - 10

        s, r = wrap_text(self.font, goal.text, (255, 255, 255),
                                     goal.character.color, textw)
        h = r.height + 2*self.dialog_border.get_height()
        goal.window = self.make_window(goal.character.color, windw, h)
        goal.windowrect = goal.window.get_rect()

        w, h = goal.windowrect.size

        goal.textsprite = s
        textrect = r.move(0, 0)  # copy
        textrect.left = PORTRAITSIZE+self.dialog_border.get_height()+5 + 2*pbh
        textrect.centery = goal.windowrect.centery
        goal.window.blit(goal.textsprite, textrect, r)
        if goal.character.picture:
            image = Image.load_image(goal.character.picture)
            imagesurf = pygame.Surface((image.get_width()+2*pbh,
                                        image.get_height()+2*pbh))
            self.border_window(imagesurf, self.portrait_border, self.portrait_corner)
            imagesurf.blit(image, (pbh, pbh))
            imagerect = imagesurf.get_rect()
            imagerect.move_ip(5, 0)
            imagerect.centery = goal.windowrect.centery
            goal.window.blit(imagesurf, imagerect)
        #goal.window.fill((255, 255, 255), textrect)

        goal.windowrect.midtop = (400, 50)
        if goal.bottom:
            goal.windowrect.midbottom = (400, 550)

    def make_window(self, color, w, h):
        minh = PORTRAITSIZE + 2*self.dialog_border.get_height() + \
               2*self.portrait_border.get_height()
        surf = pygame.Surface((w, max(minh, h)))
        surf.fill(color)
        self.border_window(surf, self.dialog_border, self.dialog_corner)
        return surf

    def border_window(self, surface, border, corner):
        w, h = surface.get_size()
        r = surface.get_rect()

        bw, bh = border.get_size()
        surface.blit(fill_texture((w, bh), 0, border), (0, 0))
        surface.blit(fill_texture((w, bh), 180, border), (0, h-bh))
        surface.blit(fill_texture((bw, h), 270, border), (0, 0))
        surface.blit(fill_texture((bw, h), 90, border), (w-bh, 0))
        
        dc = corner
        dcr = dc.get_rect()

        for attr in ['topright', 'topleft', 'bottomleft', 'bottomright']:
            setattr(dcr, attr, getattr(r, attr))
            surface.blit(dc, dcr)
            dc = pygame.transform.rotate(dc, 90)

_drawfuncs = {}
for name, thing in Goals.__dict__.iteritems():
    if isinstance(thing, type):
        if issubclass(thing, Goals.Goal):
            funcname = 'draw_%s'%(name.lower())
            if hasattr(View, funcname):
                _drawfuncs[thing] = getattr(View, "draw_%s"%name.lower())

View.draw_event_funcs = _drawfuncs
            
