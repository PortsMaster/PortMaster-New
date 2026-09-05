import pygame
import Sound
import Image
import Utils
import FadeView

class TitleView(FadeView.FadeView):
    BLINK_PERIOD = 30
    FRAME_PERIOD = 180
    DELAY = None
    FADE_IN = 40
    FADE_OUT = 10
    '''A View that doesn't actually view anything, but displays a title screen.

    '''
    def __init__(self):
        super(TitleView, self).__init__()
        self.font = pygame.font.Font("freesansbold.ttf", 24)
        self.image = Image.load_image('titlescreen', False)
        self.image = self.image.convert()
        self.screen = pygame.display.get_surface()
        pygame.mixer.music.load(Sound.find_music('Jaws of Victory.ogg'))
        pygame.mixer.music.set_volume(0)
        pygame.mixer.music.play(-1)
        self.state = 0
        self.start_state = self.FADE_IN

    def change_state(self, statenum):
        self.state = statenum
        self.start_state = self.i

    def draw(self):
        if not self.fade_out_start:
            pygame.mixer.music.set_volume(.8*float(self.color)/255)

        frame = self.i - self.start_state   # frames since totally faded in
        if self.state == 0:
            if self.color != 255:
                c = self.color
            else:
                # don't fade in just after FadeView fade in!
                if frame < 10 and self.start_state != self.FADE_IN:
                    c = Utils.fade_in_color(frame, 10, 1)
                elif frame > self.FRAME_PERIOD - 10:
                    c = Utils.fade_out_color(frame - (self.FRAME_PERIOD - 10) , 10)
                else:
                    c = 255
            self.image.set_alpha(c)
            self.screen.fill((0, 0, 0))
            self.screen.blit(self.image, (0, 0))

            if int(frame / self.BLINK_PERIOD) % 2:
                text = self.font.render('Press a key to start', True, (c, c, c))
                textrect = text.get_rect()
                screenrect = self.screen.get_rect()
                textrect.centerx = screenrect.centerx
                textrect.midbottom = screenrect.midbottom
                textrect.bottom -= 40
                self.screen.blit(text, textrect)
            if frame >= self.FRAME_PERIOD:
                self.change_state(1)
        else:
            strings = """Generations ago, humanity got its first
            glance at its galactic neighbors. Though the initial
            diplomatic gestures seemed well-received, something
            fell through. The Blogospheres began an all-out war.
            Although terran forces have not managed a true victory
            even after decades of battle, they've held the alien fleets
            far from Earth. Despite the threat forever looming
            on the horizon, life had regained some degree of normalcy.

            Having just finished the last semester at the NavInstitute,
            you have received your permanent placement; although the
            documents don't explain what Project Alexandria actually
            is, they talk about the front lines... """.split('\n')
            strings = [s.strip() for s in strings]
            SPEED = 1
            starth = self.screen.get_height() + 10 - SPEED*frame
            midx = self.screen.get_width()/2
            c = self.color
            self.screen.fill((0, 0, 0))
            for s in strings:
                surf = self.font.render(s, True, (c, c, c))
                surfrect = surf.get_rect()
                surfrect.top = starth
                surfrect.centerx = midx
                starth += surfrect.height + 1
                self.screen.blit(surf, surfrect)
                
            if surfrect.bottom < -10-10*SPEED: self.change_state(0)

        pygame.display.flip()

    def over(self):
        pygame.mixer.music.fadeout(1000)

    def fade_out(self):
        self.fade_out_start = self.i
