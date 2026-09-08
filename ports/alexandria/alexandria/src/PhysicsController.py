import Geometry
from Vector import Vector, Vectortype, dot, length
import weakref
import Numeric

class PhysicsController:
    def __init__(self, game):
        self.game = game
        self.on = False #Start in non-physicated state
        self.affects_dict = weakref.WeakKeyDictionary()

    def thread(self):
        while True:
            if self.game.paused: yield None
            else:
                # FIXME: Some way to combine these two loops without everything
                # being terrible?
                for obj, pattern in self.game.patterns.items():
                    try:
                        pattern.next()
                    except StopIteration:
                        # obj could have been deleted
                        # pattern could have changed (don't delete the new one)
                        if self.game.patterns.has_key(obj) \
                               and self.game.patterns[obj] == pattern:
                            del self.game.patterns[obj]

                for i, a in enumerate(self.game.actions):
                    try:
                        a.next()
                    except StopIteration:
                        if a == self.game.dialog: self.game.dialog = None
                        self.game.actions.remove(a)

                for obj, body in self.game.geometry.bodies.items():
                    if self.game.inertia == False:
                        v = body.getLinearVel()
                        drag = 0.1
                        s = 1-drag
                        body.setLinearVel((v[0]*s, v[1]*s, v[2]*s))

                if self.game.cinematic.get('physics', 'on') == "on": 
                    self.game.geometry.collide_all(self.game)
                    self.game.forces.clear()
                    # Make sure we haven't wandered out of z
                    for obj, body in self.game.geometry.bodies.items():
                        if body.getPosition()[2] != 0:
                            print obj, "z position", body.getPosition()[2]
                        elif obj.debug:
                            print obj, 'position', body.getPosition()
                yield None

