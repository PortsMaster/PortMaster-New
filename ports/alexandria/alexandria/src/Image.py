from os import listdir, stat, getcwd
from os.path import isdir, join, splitext, split, exists
import pygame.image
import re
GFXDIR = 'gfx'

image_cache = {} #'filename' -> Surface('gfx/filename.png')

def load_image(imagename, colorkey=True, dir=GFXDIR):
    '''Load an image, caching in image_cache.
    
    If colorkey is true, the image tries to guess the colorkey for the
    image.'''
    try:
        return image_cache[imagename]
    except KeyError:
        # We call convert() aggressively, because it's easier to spot a broken
        # transparency than a weird slowdown. The only way to preserve alpha
        # is with an info file that says "colorkey=None".
        imagefile = join(dir, "%s.png" % imagename)
        image = pygame.image.load(imagefile)
        infofile = join(dir, "%s.inf"%imagename)
        if exists(infofile):
            # get colorkey from this file
            whitelist = {'None': None, 'False': False, 'True':True}
            execfile(infofile, whitelist)
            ckey = whitelist['colorkey']
            if ckey:
                image = image.convert()
                try:
                    r, g, b = ckey
                except:
                    try:
                        x, y = ckey
                    except:
                        colorkey = ckey # hopefully it was T/F
                        x = y = 0
                    r, g, b, a = image.get_at((x, y))
                image.set_colorkey((r,g,b,255), pygame.RLEACCEL)
            elif ckey == False:
                image = image.convert()
            else:
                image = image.convert_alpha()
        else:
            print "No file information on", imagename, "; no colorkey set"
            image = image.convert()

        # Shouldn't this disable alpha on some images? Not sure..
        image.set_alpha(None, pygame.constants.RLEACCEL)
        image_cache[imagename] = image
            
        return image

def expand_list_numbers(images):
    """Transforms a list of files and images into an explicit list:

    [img1, img2, img3, img4] and ["file1", "file2", "file4", "file5"]
    becomes [img1, img2, img2, img3, img4]."""

    k = images.keys()
    k.sort()
    lastn = k[0]
    strip = []
    
    for n in k[1:]:
        strip.extend([images[lastn]]*(n-lastn))
        lastn = n
    strip.append(images[n])

    return strip

def r(start, end):
    '''Useful bi-directional range function. Includes both endpoints.'''
    if start < end:
        return range(start, end+1)
    if start == end:
        return [start]
    # start > end
    l = range(end, start+1)
    l.reverse()
    return l

listops = {'__builtins__': None, 'range': range, 'r': r}

def make_strip(filename, colorkey, dir=GFXDIR):
    if filename == '': raise ValueError, "can't read main gfx directory"
    animlist = None

    if isdir(join(dir, filename)):
        files = listdir(join(dir,filename))
        if exists(join(dir, filename, 'index.py')):
            s = file(join(dir, filename, 'index.py')).read()
            animlist = eval(s, listops)
        def add_dirname(s): return join(filename, s)
        files = map(add_dirname, files)
    elif exists(join(dir, filename+'.png')):
        # Not a strip, just a single file
        files = [filename+'.png']
    else:
        try:
            l = listdir(dir)
        except OSError:
            l = []
            try: l = listdir(".")
            except: pass
            s = "couldn't list %s. cwd is %s, files present are %s" %(dir, getcwd(), l)
            raise OSError, s
        r = re.compile("%s(-\d+)?\.png"%filename)
        def is_part(s): return r.match(s)
        files = filter(is_part, l)
        if not files: raise ValueError, "no such file as %s in %s"%(filename, dir)

    def is_image(s): return s.endswith(".png")
    files = filter(is_image, files)

    def strip_ext(s): return splitext(s)[0]
    files = map(strip_ext, files)

    files.sort()

    def load(image): return load_image(image, colorkey, dir)
    images = map(load, files)
    # Check if all images are the same size; if not, warn
    size = images[0].get_width(), images[0].get_height()
    for i in range(len(images)):
        w, h = images[i].get_width(), images[i].get_height()
        if (w, h) != size:
            print "File %s has different size than other files in this strip: %s %s" % (files[i], (w, h), (size))

    r = re.compile('(\d+)$')
    if len(images) == 1 or files == None:
        return images
    
    def number(f):
        return int(r.search(f).group())

    numdict = {}
    for i in range(len(images)):
        numdict[number(files[i])] = images[i]

    if animlist:
        ret = []
        for a in animlist:
            ret.append(numdict[a])
        return ret

    return expand_list_numbers(numdict)

def find_image(filename, location, colorkey=True):
    # Warning: if given levels/training/gfx/, will first try levels/training
    #print 'finding location at', location
    tried = []
    while location:
        location, tail = split(location)
        dir = join(location, 'gfx')
        try:
            return make_strip(filename, colorkey, dir)
        except (ValueError, OSError):
            tried.append(location)

    raise ValueError, "can't find %s (tried %s)"%(filename, tried)

def flip_strip(strip, fliph, flipv):
    def flip(i):
        return pygame.transform.flip(i, fliph, flipv)
    return map(flip, strip)

def merge_strip(s1, s2, diff, colorkey=None):
    def gcd(a,b):
        """Return greatest common divisor using Euclid's Algorithm.
        
        Implementation from http://mail.python.org/pipermail/edu-sig/2000-September/000610.html"""
        while b:      
            a, b = b, a % b
        return a
    def lcm(a, b): return (a*b)/gcd(a, b)

    n1 = len(s1)
    n2 = len(s2)
    n = lcm(n1, n2)
    newstrip = []
    resized = False
    resizeoff = (0, 0)
    for i in range(n):
        i1 = i%n1
        i2 = i%n2
        r1 = s1[i1].get_rect()
        r2 = s2[i2].get_rect()
        r2.center = r1.center
        r2.move_ip(*diff)
        r = r1.union(r2)
        if r == r1:
            s = s1[i1].copy()
            s.blit(s2[i2], r2)
        else:
            resized = True
            # We need a bigger surface.
            s = pygame.Surface(r.size)
            # If r2 is off the surface, r will reflect this by having
            # a negative coordinate (top or left).
            # Adjust.
            tl = -r.left, -r.top
            # The center of the image has changed; we need to say by how much.
            resizeoff = r.centerx - r1.centerx,\
                        r.centery - r1.centery
            # We need a colorkey.
            # Guess!
            if not colorkey:
                colorkey = (0, 255, 255)
            s.set_colorkey(colorkey)
            s.fill(colorkey)
            s.blit(s1[i1], r1.move(tl))
            s.blit(s2[i2], r2.move(tl))
        newstrip.append(s)
    return newstrip, resized, resizeoff
