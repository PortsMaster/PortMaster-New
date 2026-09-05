# Sprite.py: some useful sprites
import operator
import random #For drawing random backgrounds
import pygame.sprite
import Image

class MySprite(pygame.sprite.Sprite):
    def __init__(self):
        super(MySprite, self).__init__()
        self.image = pygame.Surface((1, 1))
        self.rect = pygame.rect.Rect(0, 0, 0, 0)

    def update_offset(self, offset):
        pass

    def advance(self):
        pass

class StripSprite(MySprite):
    repeat = True
    debug = False
    def __init__(self, start=None):
        super(StripSprite, self).__init__()
        if start == None: start = 0
        self.n = start-1
        self.cycled = False
        #self.strip = None
        self.advance()

    def get_pos(self):
        '''The center of the sprite in game coordinates.'''
        return (0, 0)

    def destroy(self):
        '''Action to take when destroyed (if not cyclic).'''
        pass

    def update_offset(self, offset):
        # We have to regenerate the rectangle every frame because the image
        # might be rotated or otherwise change size. Besides, regenerating
        # the rectangle is cheap; there's no measurable difference if you
        # remove it.
        # We'd still have to recenter it and update its offset, anyow.
        r = self.image.get_rect()
        r.center = self.get_pos()
        r.move_ip(offset)
        self.rect = r

    def advance_zero(self):
        '''In case the strip wasn't present on object construction, this lets
        you add a strip and call advance_zero() to pull the new strip in to
        the .image attribute.'''
        # FIXME: is this a hack? I don't really think so; I could add
        # separate part of the advance() function (the self.image =
        # self.strip[self.n] part) out, and call it in advance(), but
        # that would require making an extra function call in the
        # advance() function, which would be bad for efficiency.
        self.n -= 1
        self.advance()

    def restart(self):
        self.n = -1
        self.advance()

    def advance(self):
        self.n += 1
        if self.n >= len(self.strip):
            if self.repeat == False:
                self.kill()
                self.destroy()
            self.cycled = True
            if self.repeat != True:
                self.n = self.repeat
            else:
                self.n = 0
        else:
            self.cycled = False
        self.image = self.strip[self.n]
##        if self.debug:
##            print self.strip, self.n

    def merge(self, s2, diff=None):
        assert isinstance(s2, StripSprite)
        if not diff:
            diff = map(operator.sub, s2.get_pos(), self.get_pos())
        strip, resized, resizeoff = Image.merge_strip(self.strip, s2.strip,
                                                      diff)
        self.orig_strip = self.strip = strip
        return resized, resizeoff

class FadeSprite(MySprite):
    def __init__(self, size, color, ticks, reverse=False):
        super(FadeSprite, self).__init__()
        self.surface = pygame.surface.Surface(size)
        self.surface.fill(color)
        self.reverse = reverse
        alpha = 0
        if reverse: alpha = 255
        self.surface.set_alpha(alpha)
        self.image = self.surface
        self.rect = pygame.rect.Rect(0, 0, 0, 0)
        self.i = 0
        self.ticks = ticks

    def advance(self):
        alpha = 255*self.i/self.ticks
        if self.reverse: alpha = 255 - alpha
        self.image.set_alpha(alpha)
        if self.i < self.ticks:
            self.i += 1
    
class ZoomSprite(MySprite):
    def __init__(self, image=None, rotrate=None, startpt=None, velocity=None):
        super(ZoomSprite, self).__init__()
        self.orig_image = image
        self.rotrate = rotrate
        self.velocity = velocity
        self.rot = 0
        self.pos = startpt[:-1]
        self.z = startpt[-1]
        self.n = 0
        self.render()

    def advance(self):
        self.render()
        x, y, z = self.velocity
        self.pos = self.pos[0]+x, self.pos[1]+y
        self.z += z
        self.rot += self.rotrate
        self.n += 1

    def render(self):
        i = self.orig_image[self.n%len(self.orig_image)]
        self.image = pygame.transform.rotozoom(i, self.rot,
                                               1.0/self.z)
        #print self.image.get_colorkey(), i.get_colorkey(), self.image.get_at((0, 0)), i.get_at((0, 0))
        self.image.set_colorkey(i.get_colorkey())
        self.rect = self.image.get_rect()
        self.rect.center = self.pos[0]/self.z, self.pos[1]/self.z

class DarkSprite(MySprite):
    def __init__(self, size, radius=200, **kwargs):
        super(DarkSprite, self).__init__()
        self.image = pygame.Surface(size)
        self.image.fill((0,0,0,255))
        self.image.set_colorkey((255, 255, 255))
        w, h = size
        pygame.draw.circle(self.image, (255, 255, 255), (w/2, h/2), radius)
        self.rect = pygame.Rect(0, 0, 0, 0)

class ImageSprite(StripSprite):
    def __init__(self, pos, strip, rot=None, attr=None, rel=None, repeat=True,
                 **kwargs):
        if attr == None:
            attr = 'topleft'
        if rot:
            def rotate(i):
                return pygame.transform.rotate(i, -rot)
            self.strip = map(rotate, strip)
        else:
            self.strip = strip
        r = self.strip[0].get_rect()
        setattr(r, attr, pos)
        self._pos = r.center
        self._rel = rel
        self.repeat = repeat
        super(ImageSprite, self).__init__(**kwargs)
        if len(self.strip) == 1 and self.repeat:
            # some optimizations for one-image sprites
            self.advance = self.advance_strip_one
            self.cycled = True

    def advance_strip_one(self):
        pass

    def get_pos(self):
        if not self._rel:
            return self._pos
        else:
            relpos = self._rel.getPosition()
            #print relpos, self._pos
            return relpos[0]+self._pos[0], relpos[1]+self._pos[1]

    def merge(self, s2):
        resized, diff = super(ImageSprite, self).merge(s2)
        if resized:
            x, y = self._pos
            x += diff[0]
            y += diff[1]
            self._pos = (x, y)

class PulseSprite(ImageSprite):
    # SLOW. Use EXTREMELY SPARINGLY.
    # FIXME: optimize by precomputing all images needed?
    def __init__(self, *args, **kwargs):
        self.startscale = kwargs.pop('startscale', 1.0)
        self.afterstart = kwargs.pop('afterstart', 0)
        self.endscale = kwargs.pop('endscale', 0.85)
        self.afterend = kwargs.pop('afterend', 0)
        self.period = kwargs.pop('period', 8)
        self.waitlist = [self.period, self.afterend, self.period, self.afterstart]
        self.increase = [1,           0,             1,          0]
        self.source =  [self.startscale, self.endscale, self.endscale, self.startscale]
        self.phase = 0
        self.scaleframe = 0

        super(PulseSprite, self).__init__(*args, **kwargs)

    def advance(self):
        super(PulseSprite, self).advance()
        period = self.period
        frame = self.scaleframe
        self.scaleframe += 1
        
        if frame >= self.waitlist[self.phase]:
            self.phase += 1
            if self.phase == len(self.waitlist): self.phase = 0
            self.scaleframe = 0
            frame = 0
        increase = self.increase[self.phase]
        start = self.source[self.phase]
        end = [self.startscale, self.endscale][start == self.startscale]
        scale = start + increase*(end-start)*(float(frame)/period)
        i = self.image
        self.image = pygame.transform.rotozoom(i, 0, scale)
        self.image.set_colorkey(i.get_colorkey())

class LayerGroup(pygame.sprite.Group):
    '''LayerGroup -- simple layering group

    This is a pygame sprite group based on DR0ID's FastRenderGroup
    and LayeredRenderGroup. It provides layers by storing sprites as a
    list, with the topmost layers at the "back" of the list. Drawing
    all these sprites in this order will leave the topmost sprites last.

    This group is much less full-featured than DR0ID's implementation;
    it basically does only what I need.'''

    def __init__(self, *sprites, **kwargs):
        self._spritelayers = {}
        self._spritelist = []
        super(LayerGroup, self).__init__(*sprites, **kwargs)

    def sprites(self): return self._spritelist

    def layer_sprites(self, layer):
        start = -1
        for i in range(len(self._spritelist)):
            s = self._spritelist[i]
            if self._spritelayers[s] < layer:
                start = i
            elif self._spritelayers[s] > layer:
                return self._spritelist[start+1:i]

        return self._spritelist[start+1:]

    def add(self, *sprites, **kwargs):
        layer = kwargs.pop('layer', 0)
        under = kwargs.pop('under', None)
        for sprite in sprites:
            self.add_internal(sprite, layer, under)
            sprite.add_internal(self)

    def add_internal(self, sprite, layer, under=None):
        # list.insert(n, obj) inserts obj at list[n], and shifts the old
        # list[n] to list[n+1].
        self._spritelayers[sprite] = layer
        if under: layer -= 1
        for i in range(len(self._spritelist)):
            s = self._spritelist[i]
            if self._spritelayers[s] > layer:
                self._spritelist.insert(i, sprite)
                return

        # Wasn't able to find one bigger than us; we must go at the end.
        self._spritelist.append(sprite)

    def remove_internal(self, sprite):
        self._spritelist.remove(sprite)
        del self._spritelayers[sprite]

    def has_internal(self, sprite):
        return self._spritelayers.has_key(sprite)
