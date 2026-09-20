from chowdren.common import make_color

FADE_TYPES = {
    'DOOR': 'DOOR',
    'FADE': 'FADE'
}

def write(writer, fade, out):
    fade_dir = 1.0 / (fade.duration / 1000.0)
    if not out:
        fade_dir = -fade_dir
    color = fade.color
    fade_type = 'Transition::%s' % FADE_TYPES.get(fade.name, 'FADE')
    writer.putlnc('manager.set_fade(%s, %s, %s);', fade_type,
                  make_color(color), fade_dir)
