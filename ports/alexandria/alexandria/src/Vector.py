# Vector.py -- various math-related stuff
import Numeric
import math

def listify(args):
    if len(args) == 1:
        try:
            len(args[0])
            # args is a list of points
            return list(args[0])
        except:
            pass
    return list(args)

def range2d(lst):
    # min x, min y
    nx = 0
    ny = 0
    # max x, max y
    xx = 0
    xy = 0
    for p in lst:
        x, y = p
        nx = min(nx, x)
        ny = min(ny, y)
        xx = max(xx, x)
        xy = max(xy, y)
    return (xx - nx, xy - ny)

def avg2d(lst):
    sx = 0
    sy = 0
    for p in lst:
        x, y = p
        sx += x
        sy += y
    return (sx/len(lst), sy/len(lst))

#Vector = Numeric.array
def Vector(array):
    return Numeric.array(array, Vectortype)

Vectortype = 'd'

dot = Numeric.matrixmultiply

nmin = Numeric.minimum.reduce
nmax = Numeric.maximum.reduce
import math

def normal(array):
    '''Assuming array is nx2, return an array of normals to each column.'''
    print array.shape, array
    new = array.copy()
    old = array
    #old = Numeric.reshape(array, (Numeric.product(array.shape)/2, 2))
    #new = old.copy()
    new[:, 0] = -old[:, 1]
    new[:, 1] =  old[:, 0]
    return Numeric.reshape(new, array.shape)

def length(array):
    '''Assuming array is nx2, return an array of the length of each vector.'''
    return Numeric.sqrt(Numeric.sum(array**2, -1))

def normalize(array):
    #print 'before',array
    #print 'after', array/length(array)[:, Numeric.NewAxis]
    return array/length(array)[..., Numeric.NewAxis]

def angle_vector(angle):
    '''Returns a vector that is (1, 0) rotated by angle degrees.

    Rotation is "clockwise", which is counterclockwise in pygame terms.

    angle = 0 is to the right.'''
    angle = float(angle)/180 * math.pi
    return Vector([math.cos(angle), -math.sin(angle)])
    
def point_in_poly(p, poly):
    """point_in_poly(p, poly) -> bool

    poly is a sequence of (x, y) pairs.
    p is (x, y).

    Based on code from
    http://local.wasp.uwa.edu.au/~pbourke/geometry/insidepoly/ and
    http://www.ariel.com.au/a/python-point-int-poly.html ."""

    x, y = p
    inside = False
    lp = poly[0]
    for np in list(poly[1:])+[poly[0]]:
        if min(np[1], lp[1]) < y <= max(np[1], lp[1]):
            if x <= max(np[0], lp[0]):
                if np[1] != lp[1]:
                    m_1 = (np[0]-lp[0])/(np[1]-lp[1]) # inverse slope
                    xinters = (y-np[1])*m_1 + np[0]
                    if x < xinters:
                        inside = not inside
                else:
                    pass # on the horizontal line; edge case, we ignore it
        lp = np
    return inside

def pointswithin(p1, p2, dist):
    x, y = p1
    a, b = p2
    return (a-x)*(a-x) + (b-y)*(b-y) < dist*dist

def linedist(p1, p2, p3):
    '''Calculate distance between p3 and the line between p1 and p2.'''
    x1, y1 = p1
    x2, y2 = p2
    x3, y3 = p3
    length = (p2[0]-p1[0])*(p2[0]-p1[0]) + (p2[1]-p1[1])*(p2[1]-p1[1])
    u = ((x3-x1)*(x2-x1)+(y3-y1)*(y2-y1))/float(length)
    if u < 0: u = 0
    elif u > 1: u = 1
    px, py = x1+(x2-x1)*u, y1+(y2-y1)*u
    return math.sqrt((px-x3)*(px-x3)+(py-y3)*(py-y3))
    
def rotate(p, deg, center):
    x = p[0]-center[0]
    y = p[1]-center[1]
    r = -math.radians(deg)   # compensate for pygame's coordinate system
    newx = x*math.cos(r)-y*math.sin(r)
    newy = x*math.sin(r)+y*math.cos(r)
    return (newx+center[0], newy+center[1])

if __name__ == 'main':
    assert(Vector.point_in_poly((0, 0), [(-100, -100), (100, -100), (100, 100), (-100, 100)]))
    assert(not Vector.point_in_poly((200, 0), [(-100, -100), (100, -100), (100, 100), (-100, 100)]))
    assert(not Vector.point_in_poly((-200, 0), [(-100, -100), (100, -100), (100, 100), (-100, 100)]))
    assert(Vector.point_in_poly((0, 100), [(-100, -100), (100, -100), (100, 100), (-100, 100)]))
    assert(not Vector.point_in_poly((0, 200), [(-100, -100), (100, -100), (100, 100), (-100, 100)]))
