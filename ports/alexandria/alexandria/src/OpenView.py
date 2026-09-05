import pygame
import Sound
import Utils
import FadeView
               
class OpenView(FadeView.FadeView):
    '''Sorta like the TitleView, except it just shows the logo and plays a sound.
    '''
    FADE_IN = 30
    FADE_OUT = 30
    DELAY = 2*30
    def __init__(self):
        super(OpenView, self).__init__()
        self.font = pygame.font.Font("freesansbold.ttf", 24)

        self.screen = pygame.display.get_surface()
        screenrect = self.screen.get_rect()

        text = self.render_text((255, 255, 255))
        self.textrect = text.get_rect()
        self.textrect.center = screenrect.center

        self.sound = Sound.load_sound('thunder.ogg')
        self.sound.play()

    def render_text(self, color):
        return self.font.render('Sixth Floor Labs presents', True, color)

    def draw(self):
        self.screen.fill((0, 0, 0))

        i = self.i
        c = self.color
        text = self.render_text((c, c, c))
        self.screen.blit(text, self.textrect)

        pygame.display.flip()

    def over(self):
        self.sound.fadeout(500)

