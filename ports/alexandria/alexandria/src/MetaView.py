import pygame
import Utils
import FadeView

class MetaView(FadeView.FadeView):
    FADE_IN = 10
    DELAY = 2*30
    FADE_OUT = 10
    def __init__(self, game):
        super(MetaView, self).__init__()
        self.info = {}
        self.screen = pygame.display.get_surface()
        self.font = pygame.font.Font("freesansbold.ttf", 33)
    
    def set_info(self, data):
        self.info = data
        self.surfaces = []
        self.rects = []
        strings = []
        for key in ['title', 'subtitle']:
            strings.extend(self.info[key].split('\n'))
        self.strings = strings
            
    def draw(self):
        self.screen.fill((0, 0, 0))

        w = self.screen.get_width()/2
        h = int(self.screen.get_height()*.4)
        c = self.color
        for s in self.strings:
            surface = self.font.render(s, True, (c, c, c))
            rect = surface.get_rect()
            rect.center = (w, h)
            h += int(surface.get_height() * 1.2)
            self.screen.blit(surface, rect)

        pygame.display.flip()

    def over(self):
        pass
