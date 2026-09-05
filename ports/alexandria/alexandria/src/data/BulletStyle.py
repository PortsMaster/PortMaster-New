class BulletStyle(object):
    explodesound = "boom.wav"
    firesound = "shot.wav"
    imagename = 'bullet'
    explodeimage = 'explosion'

class BulletHumanStyle(BulletStyle):
    explodesound = "zap.wav"
    explodeimage = 'bullethit'
    firesound = "electric.wav"
    
class BulletBossStyle(BulletStyle):
    imagename = "bossbullet"
    explodeimage = ['bossbullethit', 'explosion']
    firesound = 'captbullet.ogg'
    explodesound = 'captbullet-2.ogg'

class BulletInvertebrateStyle(BulletStyle):
    explodeimage = 'invertebrate-bullethit'
    imagename = 'invertebrate-bullet'

class BulletVertebrateStyle(BulletStyle):
    imagename = 'vertebrate-bullet'

class BulletBouncerStyle(BulletStyle):
    imagename = 'healbeam7-bouncer-bullet'

class BulletMinemakerStyle(BulletStyle):
    imagename = 'healbeam7-minemaker-bullet'

class HookStyle(BulletStyle):
    pass

class HookHumanStyle(BulletHumanStyle, HookStyle):
    firesound = "electric2.wav"
    imagename = 'beamhook'

class MineStyle(BulletStyle):
    imagename = 'bomb'
    explodeimage = 'bombexplosion'

bulletstyles = {}
def get_bullet_style(klass, style):
    if not bulletstyles.has_key((klass, style)):
        bulletstyles[(klass, style)] = make_bullet_style(klass, style)
    return bulletstyles[(klass, style)]

def get_style_name(kname, style):
    return kname.capitalize() + style.capitalize() + "Style"

def make_bullet_style(klass, style):
    '''Get an appropriate style for a bullet of type klass being fired by a shooter
    with style.

    This method needs to be thought out better once it is used
    more.'''
    
    kname = klass.__name__
    stylekname = get_style_name(kname, style)
    if globals().has_key(stylekname):
        return globals()[stylekname]

    # If that doesn't work, try without a style.
    if globals().has_key(get_style_name(kname, '')):
        return globals()[get_style_name(kname, '')]
    # Otherwise, bail. (Rethink this later.)
    raise ValueError, "I'm so confused :("

    # Abandoned, since whatever it does will probably be wrong.
    # Otherwise, find the bare-style style class for any of the ancestors of klass.
    # Find the closest bare-style style class for any ancestor that has a correctly
    # styled subclass, and merge those two classes.
    # ex.: for MadeUpMine and "human", see if there's a MadeUpMineStyle.
    # If not, see if there's a MineStyle. Let's say there is.
    # Then see if there's a MineHumanStyle. If not, see if there's a BulletHumanStyle.
    # Let's say there is. So we merge MineStyle and BulletHumanStyle.
    styleancestor = klass

    while not globals().has_key(get_style_name(styleancestor.__name__, '')):
        styleancestor = styleancestor.__bases__[0]
    klass1 = globals()[get_style_name(styleancestor.__name__, '')]

    while not globals().has_key(get_style_name(styleancestor.__name__, style)):
        styleancestor = styleancestor.__bases__[0]
    klass2 = styleancestor
    
    return merge(klass1, klass2, klass, style)

def merge(klass1, klass2, klass, style):
    '''Makes a new anonymous class for (klass, style).

    Use heuristics to combine attributes from klass1 and klass2. Or, what?

    klass1 overrides klass2 in the new class.'''
    pass

