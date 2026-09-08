import pygame

class HackFont(pygame.font.Font):
    '''Hacked-up font with support for the broken Windows FreeType build I'm using.

    This issue should be gone in the next version of pygame (1.8),
    which will be built against a new version of FreeType, and built
    for python 2.5, but that day isn't here yet.'''
    def __init__(self, file, size):
        super(HackFont, self).__init__(file, size)
        self.ascent = ASCENTS[(file, size)]
        self.height = HEIGHTS[(file, size)]

    def get_height(self):
        return self.height

    def render(self, *args, **kwargs):
        s = super(HackFont, self).render(*args, **kwargs)
        top = super(HackFont, self).get_ascent() - self.ascent
        return s.subsurface((0, top, s.get_width(), self.height))

ASCENTS = {("freesans.ttf", 17): 14, ("freesansbold.ttf", 16): 13,
           ("freesansbold.ttf", 18): 15}
HEIGHTS = {("freesans.ttf", 17): 18, ("freesansbold.ttf", 16): 17,
           ("freesansbold.ttf", 18): 19}
