
import pyxel

NUM_COLOURS = 4

DEFAULT = [ pyxel.COLOR_NAVY, pyxel.COLOR_GREEN, pyxel.COLOR_LIME, pyxel.COLOR_WHITE ]
RED = [ pyxel.COLOR_PURPLE, pyxel.COLOR_RED, pyxel.COLOR_PINK, pyxel.COLOR_WHITE ]
BLUE = [ pyxel.COLOR_NAVY, pyxel.COLOR_DARK_BLUE, pyxel.COLOR_CYAN, pyxel.COLOR_WHITE ]
BROWN = [ pyxel.COLOR_BROWN, pyxel.COLOR_ORANGE, pyxel.COLOR_PEACH, pyxel.COLOR_WHITE ]
GREY = [ pyxel.COLOR_BLACK, pyxel.COLOR_DARK_BLUE, pyxel.COLOR_GRAY, pyxel.COLOR_WHITE ]

ALL = [
    DEFAULT,
    RED,
    BLUE,
    BROWN,
    GREY
]

FADE_LEVEL_0 = -3 # all colours to darkest colour.
FADE_LEVEL_1 = -2 # all but brightest to darkest colour.
FADE_LEVEL_2 = -1 # all but two brightest to darkest colour.
FADE_LEVEL_3 = 0 # no modification
FADE_LEVEL_4 = 1 # all but two darkest to brightest colour.
FADE_LEVEL_5 = 2 # all but darkest to brightest colour.
FADE_LEVEL_6 = 3 # all colours to brightest colour.

FADE_LEVELS = [
    FADE_LEVEL_0,
    FADE_LEVEL_1,
    FADE_LEVEL_2,
    FADE_LEVEL_3,
    FADE_LEVEL_4,
    FADE_LEVEL_5,
    FADE_LEVEL_6
]
  
FADE_STEP_TICKS_DEFAULT = 5
FADE_STEP_TICKS_SLOW = 10
  
class FadeEvent:
    def __init__(self, ticks_per_level, new_level, callback=None):
        self.ticks_per_level = ticks_per_level
        self.ticks = 0
        self.new_level = new_level
        self.callback = callback
  
class FadeControl:
    def __init__(self):
        self.current_level = FADE_LEVEL_3
        
        self.events = []
        
    def add_event(self, ticks_per_level, new_level, callback=None):
        if ticks_per_level <= 0 or new_level not in FADE_LEVELS:
            return
            
        self.events.append(FadeEvent(ticks_per_level, new_level, callback))
        
    def get_level(self):
        return self.current_level
        
    def update(self):
        if len(self.events) > 0:
            e = self.events[0]
            e.ticks += 1
            
            if e.ticks == e.ticks_per_level:
                e.ticks = 0
                if self.current_level < e.new_level:
                    self.current_level += 1
                elif self.current_level > e.new_level:
                    self.current_level -= 1
                    
                if self.current_level == e.new_level:
                    if e.callback is not None:
                        e.callback()
                    self.events.pop(0)

class PaletteEvent:
    def __init__(self, ticks, new_pal, callback=None):
        self.ticks = ticks
        self.new_pal = DEFAULT
        self.callback = callback
        if new_pal in ALL:
            self.new_pal = new_pal

class PaletteControl:
    def __init__(self):
        self.current_palette = DEFAULT
        
        self.events = []
        
        self.fade_control = FadeControl()
        
    def add_fade_event(self, ticks_per_level, new_level, callback=None):   
        self.fade_control.add_event(ticks_per_level, new_level, callback)
        
    def add_palette_event(self, ticks, new_pal, callback=None):
        if ticks <= 0 or new_pal not in ALL:
            return
            
        #print("added palette event")
        self.events.append(PaletteEvent(ticks, new_pal, callback))
        
    def update(self):
        self.fade_control.update()
    
        if len(self.events) > 0:
            e = self.events[0]
            e.ticks -= 1
            if e.ticks == 0:
                self.current_palette = e.new_pal
                if e.callback is not None:
                    e.callback()
                self.events.pop(0)
                
                #print("Removed pal event, queue size now: " + str(len(self.events)))
        
    def set_pal(self, pal):
        if pal in ALL:
            self.current_palette = pal
        
    def get_pal(self):
        return self.current_palette
        
    def get_col(self, index):
        if index < 0 or index >= NUM_COLOURS:
            return self.current_palette[0]
            
        index = max(0, min(NUM_COLOURS-1, index + self.fade_control.get_level()))
            
        return self.current_palette[index]
        
        
