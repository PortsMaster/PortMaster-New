import math
import pygame
from pygame.constants import *
from data.Exceptions import *
from Vector import Vector, angle_vector
from data.Bullet import Bullet, Hook, PASS, BOUNCE
from data.Beam import Beam
import Event
import Config
import Goals
import View
from KeyDecorators import toggle, periodic_frames as periodic

FAST_MAKES_STRONG = True
#ACCEL_MODE = "ethan1"
ACCEL_MODE = "gears"

class Input(object):
    def __init__(self, game):
        self.game = game
        self.keys_pressed = {}
        self.skipping = 0
        self.game.input_disabled = False
        self.hook = None
        self.a_started = None

    def thread(self):
        while True:
            self.rotvel = 0
            self.handle_events()
            yield None

    def disable(self):
        self.game.input_disabled = True

    def enable(self):
        self.game.input_disabled = False

    def disabled(self):
        '''Check whether we're allowed to act on player input.

        There are many ways to disable input, and they must not conflict.
        As a result, they each have an attribute in the Game object:

            * game.playable (set to False if we are currently in a state of
                             nonplayability, such as a title screen or
                             "you're dead" screen)
            * game.input_disabled (set to True if a level disables us
                                   explicitly)
            * game.paused (set to True if a GUI is up)
            '''
        return not self.game.playable or self.game.paused \
               or self.game.input_disabled

    def handle_key(self, key, state):
        """state is True for KEYDOWN, False for KEYUP, and None if it's being
        held down"""
        game = self.game
        if game.gui:
            game.gui.handle_key(key, state)
            
        for g in game.goals:
            if g.handle_key(key):
                return False

        if current_keymap.has_key(key):
            f = current_keymap[key]
            if f.__name__ not in game.controls_disabled:
                f(self, state)

        if self.debug_functions.has_key(key) and game.debug:
            self.debug_functions[key](self, state)

        return True

    def handle_events(self):
        keys_pressed = self.keys_pressed
        game = self.game
        newkeys = {}

        for e in pygame.event.get():
            if e.type == pygame.constants.QUIT:
                print "Quitting"
                raise KeyboardInterrupt
            if e.type == KEYDOWN:
                if self.handle_key(e.key, True):
                    keys_pressed[e.key] = True
                    newkeys[e.key] = True
            elif e.type == KEYUP:
                if keys_pressed.has_key(e.key): #Sometimes spurious events are sent
                    self.handle_key(e.key, False)
                    del keys_pressed[e.key]
            else:
                if game.gui: game.gui.handle_event(e)

        for key in keys_pressed:
            if newkeys.has_key(key):
                newkeys.pop(key)
                continue
            
            self.handle_key(key, None)

        if self.disabled(): return
        player = game.player
        self.rotate(player, keys_pressed)

    def die(self, start):
        self.game.set_geom_health(self.game.player.geom, 0)

    def player_force(self, start, amt):
        game = self.game
        player = game.player
        m = game.geometry.bodies[player].getMass().mass
        angle = game.get_angle(player)
        a = amt*angle_vector(angle)  # length of vector = 1
        f = 1.0/8
        if ACCEL_MODE == "ethan1":
            v = game.geometry.get_velo(player)
            vlen = math.sqrt(v[0]*v[0]+v[1]*v[1])
            if vlen == 0: f = 4
            else:
                dot = (a[0]*v[0]+a[1]*v[1])/vlen
                theta = math.degrees(math.acos(dot))
                # If theta is less than 45 degrees, then we assume
                # you're heading in the right direction. In this case,
                # if you're going slowly, you want to get a lot of
                # accel, but we want to limit you from accelerating
                # too strongly, or else you'll go out of control, so
                # if you're going too fast, we provide only weak
                # accel.

                # If theta is close to 180 degrees, this means you're
                # trying to "brake", and the opposite is true -- the
                # faster you're going, the more accel you want, in
                # order to cancel your velocity. But if you're close
                # to zero, you're probably trying to get to zero, so
                # only give weak accel.

                # The in-between cases are tricky and I haven't really
                # solved them yet, but I figure if you're applying
                # thrust roughly perpendicular to your velocity,
                # you're either trying to make a big course
                # correction, or trying to brake. I follow the "close
                # to 180" case here.
                if vlen > 5: vlen = 5
##                f1 = 4-(vlen/5)*3
##                f2 = 1+(vlen/5)*3
                # or for trig:
                f1 = math.cos(math.radians(vlen/5*90))*3+1
                f2 = math.cos(math.radians((5-vlen)/5*90))*3+1

                # interpolate based on theta
##                f = (f2-f1)*(theta/180)+f1
                
                if theta < 45: # going "towards"
                    if vlen > 5: vlen = 5
                    f = f1
                elif 135 < theta: # going "away"
                    if vlen > 5: vlen = 5
                    f = f2
                else: f = 1.0
                
            f = f/8.0

        if ACCEL_MODE == "gears":
            if not hasattr(self.game.player, 'gear'): gear = True
            else: gear = self.game.player.gear
            if gear: f = 3.0/8
            else: f = 1.0/8
            
        if start == True or start == None:
            accel = a*f*m
        else:
            accel = Vector([0, 0])
        game.add_force(player, accel)
        p = game.geometry.bodies[player].getPosition()[:2]
        # 8 is the size of the thrustsprite.. FIXME
        player.thrustpos = p-amt*(player.size+8)*angle_vector(angle)
        player.thrusting = True
        player.thrust = accel/m

    def accel(self, start):
        game = self.game
        if self.disabled(): return
        self.player_force(start, 1)

    def retro(self, start):
        if self.disabled(): return
        self.player_force(start, -1)

    def rotate_left(self, start):
        game = self.game
        if self.disabled(): return
        self.rotvel += 5

    def rotate_right(self, start):
        game = self.game
        if self.disabled(): return
        self.rotvel -= 5

    def rotate(self, player, keys_pressed):
        if self.rotvel != 0: player.thrusting = True
        self.game.set_angle(player, self.game.get_angle(player)+self.rotvel)

    def reel_in(self, start):
        if self.disabled(): return
        if not self.game.ropes.has_key(self.game.player): return
        self.game.ropes[self.game.player].reeling_in = 2

    def reel_out(self, start):
        if self.disabled(): return
        if not self.game.ropes.has_key(self.game.player): return
        self.game.ropes[self.game.player].reeling_in = -2

    def stop(self, start):
        if self.disabled(): return
        self.game.geometry.set_velo(self.game.player,Vector([0, 0]))

    def shoot_beam(self, start):
        if start == True or start == None:
            if self.disabled(): return
            if not hasattr(self, 'beam'):
                self.beam = Beam(self.game.player)
                #self.beam.FIX = 2
                self.game.add_beam(self.game.player, self.beam)
        else:
            if hasattr(self, 'beam'):
                self.game.beam_off(self.game.player)
                del self.beam

    @periodic(10)
    def shoot_bullet(self):
        game = self.game
        if self.disabled(): return
        player = game.player
        strength = 10
        if FAST_MAKES_STRONG:
            v = game.geometry.get_velo(player)
            v = math.sqrt(v[0]*v[0]+v[1]*v[1])
            strength += v/2
        angles = [-12, +12]
        for a in angles:
            b = Bullet(player, killstr=player.killstr, bounces=0, strength=strength, friendly=PASS)
            p = game.bullet_pos(player, b, game.get_angle(player)+a)
            game.shoot(player, b, pos=p,)
        player.shots_fired[Bullet] = player.shots_fired.get(Bullet, 0) + 1

    @toggle()
    def shoot_hook(self, start):
        if self.disabled(): return
        game = self.game
        player = game.player
        if game.hooked(player):
            game.unhook(player)
        elif self.hook and (self.hook in game.geometry.objects()):
            game.delete_object(self.hook)
        else:
            self.hook = game.shoot(player,Hook(player))

    @periodic(10)
    def open_menu(self):
        if self.disabled(): return
        if self.game.gui: return
        self.game.recurse(Goals.GUI('usermenu'))

    @toggle()
    def pause(self, start):
        if self.game.gui: return
        self.game.recurse(Goals.GUI('pause', goalargs={'pausekey':current_keymap['pause']}))

    @periodic(10)
    def switch_gears(self):
        if self.disabled(): return
        if not hasattr(self.game.player, 'gear'):
            self.game.player.gear = True
        self.game.player.gear = not self.game.player.gear

    def fast(self, start):
        if self.disabled(): return
        velo = 60 * angle_vector(self.game.get_angle(player))
        print 'new velo = ', velo
        self.game.geometry.set_velo(self.game.player, velo)

    def brakes(self, start):
        if self.disabled(): return
        velo = self.game.geometry.get_velo(self.game.player)
        velo = map(lambda x: 0.95*x, velo)
        self.game.geometry.set_velo(self.game.player, velo)

    def screenshot(self, start):
        self.game.post(Event.ScreenshotEvent())

    @periodic(10)
    def movie(self):
        View.movie = not View.movie

    def render(self, start):
        self.game.post(Event.RenderAllEvent())
        
    def skip_level(self, start):
        raise SkipLevel

    def quit(self, start):
        raise KeyboardInterrupt

    debug_functions = {K_f: fast, K_t: stop, K_r: render, K_c: screenshot}

class Keymap(dict):
    def __init__(self, dct=None):
        super(Keymap, self).__init__()

        if dct:
            self.add_bindings(dct)

    def add_binding(self, key, function):
        self[function] = key
        function = getattr(Input, function)
        self[key] = function

    def add_bindings(self, dct):
        for k, f in dct.items():
            self.add_binding(k, f)

    def clone(self):
        klone = Keymap()
        for k, f in self.items():
            klone[k] = f
        return klone

# Keys common to both QWERTY and Dvorak layouts.
general = {K_UP: 'accel', K_DOWN: 'retro',
           K_LEFT: 'rotate_left', K_RIGHT: 'rotate_right', K_a: 'shoot_bullet',
           K_p: 'pause', K_ESCAPE: 'open_menu',
           K_SPACE: "switch_gears"
           }

# Create dict of layout-specific bindings, and translate them automatically.
dv_func = {K_o: 'shoot_hook', K_QUOTE: 'shoot_beam', K_e: 'reel_in', K_u: 'reel_out'}
dv_to_qw = {K_o: K_s,         K_QUOTE: K_q,          K_e: K_d,       K_u: K_f}
qw_func = {}
for key in dv_func:
    qw_func[dv_to_qw[key]] = dv_func[key]

dvorak_keymap = Keymap(general)
dvorak_keymap.add_bindings(dv_func)
qwerty_keymap = Keymap(general)
qwerty_keymap.add_bindings(qw_func)

custom_keymap = None

class Command(object):
    def __init__(self, description=None, visible=True):
        self.description = description
        self.visible = visible

commands = [
    ('accel', Command("Accelerate")),
    ('retro', Command("Retro rockets")),
    ('rotate_left', Command("Rotate left")),
    ('rotate_right', Command("Rotate right")),
    ('switch_gears', Command("Switch gears")),
    
    ('shoot_bullet', Command("Shoot")),
    ('shoot_hook', Command("Fire/release Hook")),
    ('pause', Command("Pause")),
    ('shoot_beam', Command("Beam weapon")),
    ('reel_in', Command("Reel in pull beam")),
    ('reel_out', Command("Reel out pull beam")),

    ('render', Command("render", visible=False)),
    ('movie', Command("movie", visible=False)),
    ('fast', Command("fast", visible=False)),
    ('stop', Command("stop", visible=False)),
    ('screenshot', Command("screenshot", visible=False)),
    ]

command_dict = dict(commands)

# We have to create this pairing on-the-fly, because custom_keymap can change
# quite a bit over the run of a program.
def d(): return [('dvorak', dvorak_keymap), ('qwerty', qwerty_keymap),
                 ('custom', custom_keymap)]

def name_to_keymap(name):
    return dict(d())[name]

def keymap_to_name(tkeymap):
    for name, keymap in d():
        if keymap == tkeymap: return name

current_keymap = name_to_keymap(Config.Config.layout)

# These dictionaries map between keycodes and strings suitable for storing in
# a file (and vice versa).
file_to_keyval = {}
keyval_to_file = {}
for c in dir(pygame.constants):
    if not c.startswith("K_"): continue
    val = getattr(pygame.constants, c)
    # name = pygame.key.name(val)
    file_to_keyval[c] = val
    keyval_to_file[val] = c

def key_name(keycode):
    return keyval_to_file[keycode]

if Config.Config.bindings:
    current_keymap = custom_keymap = current_keymap.clone()
    b = Config.Config.bindings
    for k, f in b.iteritems():
        if command_dict.has_key(f):
            # Don't fail if bindings aren't set somehow.
            if file_to_keyval.has_key(k):
                k = file_to_keyval[k]
                current_keymap.add_binding(k, f)
            else:
                print "Warning: key string", k, "not found. Binding to", f, "not set"
