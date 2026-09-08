import types
import ode
from Object import Object
class Beam(Object):
    size = 0
    length = 1000
    FIX = .02 # trial and error
    def __init__(self, shooter):
        super(Beam, self).__init__()
        self.shooter = shooter
        self.startpos = None
        self.hit = None
        self.mindepth = self.length

    def add_geometry(self, geometry):
        self.ray = geometry.add_ray(self.length)
        self.ray.object = self
        self.ray.label = 0

    def update(self, geometry, pos, dir):
        self.ray.set(tuple(pos)+(0,), tuple(dir)+(0,))
        self.startpos = pos
        
    def segments(self):
        if self.mindepth != self.length:
            return [(self.startpos, self.hit[1])]
        return []
        
    def kill(self, geometry):
        geometry.remove_ray(self.ray)
        del self.ray

    def struck(self, o2, pos, game):
        if hasattr(o2,"damage"):
            if o2.damage.amount > 0:
                o2.damage.amount -= self.FIX
                if int(o2.damage.amount-self.FIX) != int(o2.damage.amount):
                    #print o2.damage.amount, game.frames
                    pass
                if o2.damage.amount <= 0:
                    print "frames needed", game.frames - o2.start
                    o2.damage.healed()
                else:
                    if not hasattr(o2, 'start'): o2.start = game.frames
                    o2.damage.update()
        else:
            if not isinstance(game.get_geom_health(o2), types.NoneType):
                game.hit(o2, 'healbeam', self.FIX)
