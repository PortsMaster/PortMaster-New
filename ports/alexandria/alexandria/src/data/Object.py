import math
from Vector import angle_vector, Vector
# import AI below Object

class Object(object):
    '''Class to represent any game object.

    An object can have health, which can be depleted until it is destroyed.

    An object can be static; static objects do not collide with other static
    objects, but are not fixed in place.'''
    debug = False
    side = None
    damaged_by = None # if not None, strong against everything else
    def __init__(self, health=None, sharedhealth=False, static=None, diesound=None,
                 hitsound=None, hurtsound=None, image=None, layer=None,
                 angle=0, remains=None, corpse=None, size=None, damaged_by=None):
        self.health=health
        self.sharedhealth = sharedhealth
        self.maxhealth = health
        self.static=static
        self.diesound=diesound
        self.hitsound=hitsound
        self.hurtsound=hurtsound
        self.angle=angle
        self.image=image
        self.layer=layer
        self.remains=remains
        self.corpse=corpse
        self.dead = False
        if size: self.size = size
        if damaged_by: self.damaged_by = damaged_by
        self.die_replace = None # maybe filled in by Shape.place
        self.thrusting = None
        self.thrustpos = None
        self.rope_placed = None
        self.rope_failed = None

    def thread(self):
        while True:
            yield None

    def passable(self, part, o2, n, t, game):
        return False

    def pre_collide(self, part, pass1, o2, p2, pass2, n, t, game, pos):
        pass

    def post_collide(self, part, pass1, o2, pass2, n, t, game, pos):
        pass

    def struck(self, beam, pos2, game):
        pass

    def get_elasticity(self, part):
        return 0.9

    def die(self, game):
        self.dead = True

    # These next two functions assume health is "parent" for all geoms.
    def get_health(self):
        return self.health, self.maxhealth

    def set_health(self, health, maxhealth=None):
        self.health = health
        if not maxhealth: maxhealth = health
        self.maxhealth = maxhealth

class Switch(Object):
    def __init__(self, action=None, **kwargs):
        kwargs.setdefault('static', True)
        super(Switch, self).__init__(**kwargs)
        self.action = action # action is a Pattern, or has a thread() method

    def pre_collide(self, game, **kwargs):
        #if o1.on_contact: game.defer(o1, o1.on_contact)
        game.add_action(self.action.thread(game, self, self))
