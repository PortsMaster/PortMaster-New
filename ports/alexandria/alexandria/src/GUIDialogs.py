import os
import pygame.sprite
from pygame.surface import Surface
import Config
import Level
import Image
import Sprite
import Input
import HackFont
import Event
from pygame.constants import *
from data.Exceptions import ReturnToBase
from KeyDecorators import *

SIG_RESPONSE = 'response'
SIG_CHANGED = 'changed'
SIG_ACTIVATED = 'activated'

# FIXME: merge all this renderer nonsense into one class.
class Renderer(object):
    '''Class to show how a menuitem should look.'''
    def __init__(self):
        super(Renderer, self).__init__()

    def render(self, obj, active = False):
        '''Returns a list of frames that the menuitem should be drawn as.'''
        return [Surface((1, 1))]

class FontRenderer(Renderer):
    def __init__(self, font = None):
        super(FontRenderer, self).__init__()
        if not font: font = HackFont.HackFont("freesansbold.ttf", 16)
        self.font = font

    def render(self, obj, active = False):
        if hasattr(obj, 'textcolor') and obj.textcolor: color = obj.textcolor
        else:
            if isinstance(obj, ChoiceItem) and not obj.active: c = 127
            else: c = 255
            color = (c, c, c, 255)
        text = obj.text
        return [self.font.render(text, True, color)]

class ImageRenderer(Renderer):
    def __init__(self, image = None):
        super(ImageRenderer, self).__init__()

    def render(self, obj):
        pic = obj.pic
        return Image.make_strip(pic, True)

    def render_slider(self, obj):
        c = pygame.Surface((1, 10))
        c.fill((255, 0, 0))
        h = c.get_height()
        w = obj.width+c.get_width()
        s = pygame.Surface((w, h))
        pygame.draw.line(s, (255, 0, 0), (0, h/2), (w, h/2))
        d = (obj.val-obj.range[0])/(obj.range[1]-obj.range[0]) * obj.width
        s.blit(c, (d, 0))
        return [s]

class PlainRenderer(ImageRenderer, FontRenderer):
    def render(self, obj):
        fstrip = FontRenderer.render(self, obj)
        if isinstance(obj, SliderItem):
            slide = self.render_slider(obj)
            diff = (slide[0].get_width()/2 + fstrip[0].get_width()/2 + 10, 0)
            obj.splitx = fstrip[0].get_width() + 5
            obj.sliderect = slide[0].get_rect()
            obj.sliderect.left = fstrip[0].get_width() + 10
            fstrip = Image.merge_strip(fstrip, slide, diff=diff, colorkey=(0, 0, 0))[0]
        return fstrip

class IconRenderer(PlainRenderer):
    def render(self, obj):
        s1 = ImageRenderer.render(self, obj)
        s2 = FontRenderer.render(self, obj)
        diff = (s1[0].get_width()/2 + s2[0].get_width()/2 + 10, 0)
        obj.splitx = s1[0].get_width() + 5
        return Image.merge_strip(s1, s2, diff=diff, colorkey=(0, 0, 0))[0]

class Widget(pygame.sprite.Sprite):
    def __init__(self):
        super(Widget, self).__init__()
        self._signals = {}
        self.focused = False
        self.recursechild = False

    def connect_signal(self, signal, handler, *args, **kwargs):
        self._signals.setdefault(signal, []).append([handler, args, kwargs])

    def emit(self, signal, *data):
        if not self._signals.has_key(signal): return
        lst = self._signals[signal]
        for item in lst:
            handler, args, kwargs = item
            handler(self, *(data+args), **kwargs)

    def handle_event(self, event):
        if self.recursechild:
            self.recursechild.handle_event(event)
            return True

        return False

    def push(self, recurse):
        self.recursechild = recurse

    def pop(self):
        self.recursechild = None

    def on_child_over(self, child, resp):
        self.pop()

    def render(self):
        if self.recursechild:
            self.recursechild.render()

    def draw(self, screen):
        if self.recursechild:
            self.recursechild.rect.topleft = self.rect.topleft
            self.recursechild.rect.move_ip(40, 40)
            #self.recursechild.rect.center = self.rect.center
            if self.recursechild.rect.bottom > screen.get_height():
                self.recursechild.rect.centery = screen.get_height()/2
            self.recursechild.draw(screen)

    KEYFUNCS = {}
    def handle_key(self, key, start):
        if self.recursechild:
            self.recursechild.handle_key(key, start)
            return True
        
        c = self.__class__
        lastdict = None
        while hasattr(c, 'KEYFUNCS'):
            if not lastdict == c.KEYFUNCS:  # skip repeated dictionaries
                lastdict = c.KEYFUNCS
                if lastdict.has_key(key):
                    lastdict[key](self, start)
                    return True   # doesn't pass through to parent functions
            c = c.__bases__[0]

class MenuItem(Widget, Sprite.StripSprite):
    def __init__(self, *args, **kwargs):
        self.strip = [None]
        self.params = args
        super(MenuItem, self).__init__()
        for k in kwargs:
            if not hasattr(self, k): setattr(self, k, kwargs[k])

    def changed(self):
        self.emit(SIG_CHANGED)

    def activate(self, *args):
        '''Don't do anything.'''
        # This could happen if the menuitem is in a menu with no
        # selectable items.
        pass

class ChoiceItem(MenuItem):
    '''Parent class for all items that are chooseable.'''
    def __init__(self, *args, **kwargs):
        self.active = False
        super(ChoiceItem, self).__init__(*args, **kwargs)

    def activate(self, menu):
        # emit activated event on self
        self.emit(SIG_ACTIVATED)

class ResponseItem(ChoiceItem):
    def activate(self, menu):
        super(ResponseItem, self).activate(menu)
        menu.respond(self)

class ChoiceManyItem(ChoiceItem):
    def __init__(self, *args, **kwargs):
        self.format = kwargs.pop('text', '%s')
        self.displayfunc = kwargs.pop('displayfunc')
        self.current = kwargs.pop('start', 0)
        super(ChoiceManyItem, self).__init__(*args, **kwargs)
        self.params = list(self.params)
        self.display()

    def display(self):
        currentobj = self.params[self.current]
        self.obj = currentobj
        self.text = self.format % self.displayfunc(currentobj)
        self.changed()

    def activate(self, menu):
        self.current += 1
        if self.current >= len(self.params): self.current = 0
        # Set self.obj and self.text before telling everyone we've been
        # activated. (Maybe do this the other way around, and connect to
        # SIG_CHANGED?)
        self.display()
        super(ChoiceManyItem, self).activate(menu)

    def select_item(self, item, add=True):
        '''Set the currently chosen item to be item.

        If add is True and the item is not available, it will be added to the
        menuitem.'''
        if add and item not in self.params:
            self.params.append(item)
        self.current = self.params.index(item)
        self.display()

class RecurseItem(ChoiceItem):
    def __init__(self, menutype, *args, **kwargs):
        super(RecurseItem, self).__init__(*args, **kwargs)
        self.menutype = menutype

    def activate(self, menu):
        super(RecurseItem, self).activate(menu)
        newmenu = self.menutype()
        menu.push(newmenu)
        self.oldmenu = menu
        newmenu.connect_signal(SIG_RESPONSE, self.menuover)

    def menuover(self, menu, response):
        self.oldmenu.pop()

class BackItem(ChoiceItem):
    def __init__(self):
        super(BackItem, self).__init__(self, obj="Back", pic='back', text="Back")

# TODO: ActivateMenuItem, ChoiceMenuItem

class SliderItem(ChoiceItem):
    def __init__(self, init, width=100, range=(0.0, 1.0), *args, **kwargs):
        self.user_moving = False
        self.width = width
        self.val = init
        self.range = range
        self.dragging = False
        super(SliderItem, self).__init__(*args, **kwargs)

    def activate(self, menu):
        self.user_moving = True
        # Some kind of grab, here?

    def handle_key(self, key, state):
        oldval = self.val
        if state in (True, None):
            r = self.range[1]-self.range[0]
            if key == K_LEFT:
                self.val -= r/self.width
            if key == K_RIGHT:
                self.val += r/self.width
        if self.val != oldval: self.new_val()

    def new_val(self):
        '''Call when you need to update with a new val.'''
        if self.val < self.range[0]: self.val = self.range[0]
        if self.val > self.range[1]: self.val = self.range[1]
        self.emit(SIG_CHANGED)

    def handle_event(self, event):
        if event.type == pygame.MOUSEBUTTONDOWN:
            self.grab_events()
            self.dragging = True
        elif event.type == pygame.MOUSEBUTTONUP:
            self.ungrab_events()
            self.dragging = False
        elif event.type == pygame.MOUSEMOTION:
            if self.dragging:
                x = event.pos[0]
                slidex = x - (self.rect.left+self.sliderect.left)
                self.val = float(slidex)/self.width
                self.new_val()

    def grab_events(self):
        self.menu.grab_events(self)

    def ungrab_events(self):
        self.menu.ungrab_events(self)

class ToggleItem(ChoiceItem):
    def __init__(self, init=False, *args, **kwargs):
        self.val = init
        super(ToggleItem, self).__init__(*args, **kwargs)
        self.userstring = self.text
        self.update()

    def update(self):
        self.text = "%s: %s" % (self.userstring, ['off', 'on'][self.val])
        self.emit(SIG_CHANGED)

    def activate(self, menu):
        self.val = not self.val
        self.update()

def spriteunion(lst):
    r = pygame.Rect(0, 0, 0, 0)
    for i in lst:
        r.union_ip(i.rect)
    return r

class Box(Widget):
    '''Class representing a Widget that has many children.'''
    SPACE = 4
    def __init__(self):
        super(Box, self).__init__()
        self._items = []
        self.selected = None

    def get_selected_item(self):
        return self._items[self.selected]

    def set_selected(self, n):
        self.move_selected(self.selected, n, True)

    def move_selected(self, old, new, update=False):
        if old != None:
            starti = self._items[old]
            starti.active = False
        newi = self._items[new]
        newi.active = True
        if update:
            self.selected = new
        if old != new: self.emit(SIG_CHANGED)

    def add_item(self, item):
        self._items.append(item)

    def clear(self):
        del self._items[:]
        self.selected = None

    def handle_event(self, event):
        r = super(Box, self).handle_event(event)
        if r: return r
        if event.type == MOUSEMOTION:
            self.select_object_at(event.pos)

        elif event.type == MOUSEBUTTONDOWN:
            if self.select_object_at(event.pos):
                self.clicked(event)

    def clicked(self, event):
        pass

    def select_object_at(self, pos):
        for i in self._items:
            if not self.can_select(i): continue
            if i.rect.collidepoint(pos):
                self.move_selected(self.selected, self._items.index(i), True)
                return True
        return False

    def render(self):
        '''Constructs an image and rect from the images and rects of its children.

        Assumes the presence of rects and images of all children.'''
        super(Box, self).render()
        r = spriteunion(self._items)
        r.inflate_ip(2*self.SPACE, 2*self.SPACE)
        self.rect = r
        self.image = Surface(r.size)

    def draw(self, screen):
        # By this point we know where we are on the screen (our rectangle).
        # Of course, we now know where our children are (absolutely) so we
        # set that too.
        for i in self._items: i.rect.move_ip(self.rect.topleft)
        screen.blit(self.image, self.rect)
        super(Box, self).draw(screen)

    def advance_selected(self, direction):
        '''Advance the selected item (direction = +1 for down, -1 for up).'''
        startcurs = self.selected
        # Keep advancing until you find either: the next useful item, or
        # you've looped.
        while not self.can_select(self._items[self.next_selected(direction)]):
            if startcurs == self.selected:
                break
        self.move_selected(startcurs, self.selected)

    def next_selected(self, direction):
        'Get the next valid selected position in direction. (Loop.)'
        self.selected += direction
        if self.selected >= len(self._items):
            self.selected = 0
        elif self.selected < 0:
            self.selected = len(self._items) - 1
        return self.selected

    def can_select(self, item):
        return True

class Menu(Box):
    '''Class representing a menu of items.

    This class handles events and drawing the menuitems.'''
    def __init__(self):
        super(Menu, self).__init__()
        self.renderer = PlainRenderer()
        self.grabbed = None

    def render_item(self, item):
        item.strip = self.renderer.render(item)
        item.restart()

    def add_item(self, item):
        super(Menu, self).add_item(item)
        item.connect_signal(SIG_CHANGED, self.render_item)
        item.menu = self
        self.render_item(item)

    def grab_events(self, item):
        self.grabbed = item

    def ungrab_events(self, item):
        self.grabbed = None

    def pick_selected(self):
        '''Selects the topmost item if none is selected yet.'''
        if self.selected == None:
            self.selected = len(self._items)-1
            self.advance_selected(+1)

    def render(self):
        '''Need to call every frame, since any of the items could be a strip.'''
        self.pick_selected()   # small efficiency drain?
        for i in self._items:
            i.update_offset((0, 0))

        v = self.initplace()
        for i in self._items:
            v = self.place(i, *v)

        super(Menu, self).render()
        for i in self._items:
            i.rect.move_ip(self.SPACE, self.SPACE)
            self.image.blit(i.image, i.rect)

        if self.focused:
            pygame.draw.rect(self.image, 0x00ff00, self._items[self.selected], 1)
        for i in self._items:
            i.advance()

        self.rect = self.image.get_rect()

    def initplace(self):
        w = 0               # Leave some space if there are no items
        for i in self._items:
            if i.rect.width > w:
                w = i.rect.width
        starth = 0
        return (starth, w)

    def place(self, item, h, maxw):
        item.rect.topleft = (0, h)
        return (h+item.rect.height+self.SPACE, maxw)

    def draw(self, screen):
        screen.blit(self.image, self.rect)
        super(Menu, self).draw(screen)

    def move_selected(self, old, new, update=False):
        '''Override Box to re-render relevant items.'''
        super(Menu, self).move_selected(old, new, update)
        if old != None:
            self.render_item(self._items[old])
        self.render_item(self._items[new])

    def respond(self, *data):
        self.emit(SIG_RESPONSE, *data)

    def activate(self):
        self._items[self.selected].activate(self)

    @periodic(5)
    def advance_up(self):
        self.advance_selected(-1)

    @periodic(5)
    def advance_down(self):
        self.advance_selected(+1)

    @toggle()  # ignore start = None
    def escape(self, start):
        if start == True:
            self.respond(False)

    @periodic(5)
    def activate_this(self):
        self.activate()

    KEYFUNCS = {K_UP: advance_up, K_DOWN: advance_down,
               K_ESCAPE: escape, K_RETURN: activate_this}

    def handle_event(self, event):
        if self.grabbed:
            return self.grabbed.handle_event(event)
        self.pick_selected()
        r = super(Menu, self).handle_event(event)
        if r: return r
        self._items[self.selected].handle_event(event)

    def handle_key(self, key, start):
        self.pick_selected()
        r = super(Menu, self).handle_key(key, start)
        if r: return r
        self._items[self.selected].handle_key(key, start)
        
    def clicked(self, event):
        self.activate()

    def can_select(self, item):
        return isinstance(item, (ChoiceItem, ))

class CenterMenu(Menu):
    def place(self, item, h, maxw):
        item.rect.midtop = (maxw/2, h)
        return (h+item.rect.height+self.SPACE, maxw)

class SplitAlignMenu(CenterMenu):
    def __init__(self, *args, **kwargs):
        super(SplitAlignMenu, self).__init__(*args, **kwargs)
        self.renderer = IconRenderer()   # no split with any other Renderer

    def initplace(self):
        split = 0
        for i in self._items:
            if hasattr(i, 'splitx') and i.splitx > split:
                split = i.splitx

        return (split, super(SplitAlignMenu,self).initplace())

    def place(self, item, split, args):
        args = super(SplitAlignMenu, self).place(item, *args)
        if hasattr(item, 'splitx'):
            item.rect.left = split - item.splitx
        return (split, args)

class HBox(Box):
    SPACE = 0
    def __init__(self):
        super(HBox, self).__init__()
        self.selected = 0

    def add_child(self, child):
        self._items.append(child)

    def render(self):
        self.rect = pygame.rect.Rect(0, 0, 0, 0)
        self._items[self.selected].focused = True
        for i, c in enumerate(self._items):
            c.render()
            # Shade the panel that's not in use.
##            if not self.selected == i:
##                s = pygame.Surface(c.image.get_size())
##                s.fill((0, 0, 0))
##                s.set_alpha(198)
##                c.image.blit(s, (0,0))
            c.rect.left = self.rect.width
            self.rect.width += c.rect.width
            self.rect.height = max(self.rect.height, c.rect.height)
        self._items[self.selected].focused = False
        super(HBox, self).render()

    def set_selected(self, n):
        if 0 <= n < len(self._items):
            self.selected = n
            return True
        return False

    def handle_key(self, key, state):
        r = super(HBox, self).handle_key(key, state)
        if r: return r

        if state == True and key == K_RIGHT:
            self.set_selected(self.selected+1)
        elif state == True and key == K_LEFT:
            self.set_selected(self.selected-1)
        self._items[self.selected].handle_key(key, state)

    def clicked(self, event):
        self._items[self.selected].handle_event(event)

    def draw(self, screen):
        super(HBox, self).draw(screen)
        for c in self._items:
            c.draw(screen)

class Dialog(Widget):
    def __init__(self):
        super(Dialog, self).__init__()
        self.child = None

    def set_child(self, child):
        self.child = child

    def render(self):
        super(Dialog, self).render()
        self.child.render()
        self.rect = self.child.rect.inflate(2, 2)   # 1 pixel border

    def draw(self, screen):
        screen.fill(0x000000, self.rect)
        pygame.draw.rect(screen, 0xffffff, self.rect, 1)
        self.child.rect.topleft = self.rect.move(1, 1).topleft    # 1 pixel
        self.child.draw(screen)
        super(Dialog, self).draw(screen)

    def response(self, menu, resp):
        self.emit(SIG_RESPONSE, resp)

    def handle_event(self, event):
        r = super(Dialog, self).handle_event(event)
        if r: return r
        if self.child:
            self.child.handle_event(event)

    def handle_key(self, key, state):
        r = super(Dialog, self).handle_key(key, state)
        if r: return r
        if self.child:
            self.child.handle_key(key, state)

    def value(self, result):
        '''What should the GUI return to the rest of the game for a given result?'''
        if hasattr(result, 'obj'): return result.obj
        return result.text

class LevelDialog(Dialog):
    def __init__(self):
        super(LevelDialog, self).__init__()
        self.hbox = HBox()
        self.set_child(self.hbox)

        nextc, nextl = Config.Config.nextlevel
        self.campmenu = Menu()
        self.campmenu.renderer = IconRenderer()
        cl = self.campaign_list(None)
        for i, camp in enumerate(cl):
            self.campmenu.add_item(ResponseItem(**campaigninfo(camp)))
            if camp == nextc:
                self.campmenu.set_selected(i)
        self.hbox.add_child(self.campmenu)

        self.levmenu = Menu()
        self.levmenu.renderer = IconRenderer()
        self.hbox.add_child(self.levmenu)

        r = pygame.Rect(0, 0, 0, 0)
        for c in cl:
            self.populate_levels(c)
            Dialog.render(self)
            r.union_ip(self.rect)
            self.levmenu.clear()

        self.maxrect = r
        self.populate_levels(nextc, nextl)
        self.campmenu.connect_signal(SIG_RESPONSE, self.menuresp, 0)
        self.levmenu.connect_signal(SIG_RESPONSE, self.menuresp, 1)

        self.campmenu.connect_signal(SIG_CHANGED, self.menuchanged, 0)

    def render(self):
        super(LevelDialog, self).render()
        self.rect = self.maxrect

    def campaign_list(self, blah):
        return Config.Config.unlocked.keys()

    def level_list(self, campname):
        if not Config.Config.unlocked.has_key(campname):
            print "Can't happen: listing levels for unknown campaign"
            return []
        levels = Config.Config.unlocked[campname]
        levels = [Level.LevelFile(campname, level) for level in levels]
        return levels

    def populate_levels(self, camp, desired=None):
        for i, level in enumerate(self.level_list(camp)):
            self.levmenu.add_item(ResponseItem(**levelinfo(level)))
            if desired == level.level:
                self.levmenu.set_selected(i)

    def menuchanged(self, menu, n):
        self.levmenu.clear()
        self.populate_levels(menu.get_selected_item().text)

    def menuresp(self, menu, resp, n):
        if resp == False:
            if not self.hbox.set_selected(n-1): self.emit(SIG_RESPONSE, False)
        else:
            if not self.hbox.set_selected(n+1): self.emit(SIG_RESPONSE, resp)

class KeyboardDialog(Dialog):
    def __init__(self):
        super(KeyboardDialog, self).__init__()
        self.menu = Menu()
        self.menu.add_item(MenuItem(text="Configuration!"))
        #self.menu.add_item(MenuItem(text='noobs'))

        # Create the item to select layouts.
        # First, which layout are we? Only offer "custom" as an option if we're
        # already using a custom layout.
        options = ['qwerty', 'dvorak']
        layoutname = Input.keymap_to_name(Input.current_keymap)
        if layoutname not in options: options.append(layoutname)
        start = options.index(layoutname)
        # Presentation names are stored in ldict. custom is included here
        # in case it gets added later.
        ldict = {'dvorak': "Dvorak", "qwerty": 'QWERTY', 'custom': 'Custom'}
        layouti = ChoiceManyItem(text='keyboard layout = %s',
                                 displayfunc=ldict.get, start = start,
                                 *options)
        layouti.connect_signal(SIG_ACTIVATED, self.rewrite_keys)
        self.menu.add_item(layouti)
        self.layoutitem = layouti

        self.layout = Input.current_keymap
        self.bind_waiting = None

        self.keyitems = []
        for func, cmd in Input.commands:
            if not cmd.visible: continue
            text = self.func_item_text(func)
            c = ChoiceItem(obj=func, text=text)
            c.connect_signal(SIG_ACTIVATED, self.bind_key, func)
            self.keyitems.append(c)
            self.menu.add_item(c)
        #self.menu.add_item(RecurseItem(ConfigMenu, text='newmenu'))
        self.menu.add_item(ResponseItem(text="Go back"))
        self.set_child(self.menu)
        self.menu.connect_signal(SIG_RESPONSE, self.response)

    def response(self, menu, resp):
        self.emit(SIG_RESPONSE, resp)

    def rewrite_keys(self, menuitem):
        newlay = menuitem.obj
        # 'custom' just means there's differences from standard qwerty or
        # dvorak. We don't save that kind of layout to the config file;
        # only its base and its differences.
        if newlay != 'custom':
            Config.Config.layout = newlay
        self.layout = Input.current_keymap = Input.name_to_keymap(newlay)
        for keyitem in self.keyitems:
            self.refresh_key(keyitem)

    def func_item_text(self, func):
        l = self.layout
        cmd = Input.command_dict[func]
        return "%s: %s" %(cmd.description, pygame.key.name(l[func]))

    def bind_key(self, item, func):
        item.textcolor = (255, 0, 0)
        self.menu.render_item(item)
        self.bind_waiting = (item, func)

    def refresh_key(self, item):
        item.text = self.func_item_text(item.obj)
        self.menu.render_item(item)

    def handle_key(self, key, state):
        if state == True and self.bind_waiting:
            # This takes precedence over passing events to recursive dialogs!
            item, func = self.bind_waiting
            bindings = Config.Config.bindings

            self.layout = Input.current_keymap = Input.custom_keymap = Input.current_keymap.clone()
            self.layoutitem.select_item('custom', add=True)

            oldkey = self.layout[func]
            del self.layout[oldkey]
            # bindings uses a keyname
            oldkey = Input.key_name(oldkey)
            if bindings.has_key(oldkey): del bindings[oldkey]

            self.layout.add_binding(key, func)

            # This layout was based on some layout, with some bindings added.
            # If that layout has the same key, we don't need a binding.
            parent = Input.name_to_keymap(Config.Config.layout)
            # Check self.layout here because layout[key] is a function, which
            # we can only get to through the add_binding call above.
            if parent.get(key, None) != self.layout[key]:
                bindings[Input.key_name(key)] = func
            self.refresh_key(item)
            del item.textcolor
            self.menu.render_item(item)
            self.bind_waiting = None
        else:
            return super(KeyboardDialog, self).handle_key(key, state)

class OptionsDialog(Dialog):
    def __init__(self):
        super(OptionsDialog, self).__init__()
        self.menu = SplitAlignMenu()
        self.menu.renderer = PlainRenderer()
        self.set_child(self.menu)
        self.menu.connect_signal(SIG_RESPONSE, self.response)
        self.menu.add_item(MenuItem(text="Options"))

        c = ChoiceItem(text="Change controls")
        self.menu.add_item(c)
        c.connect_signal(SIG_ACTIVATED, self.controlsmenu)

        self.conf_item(ToggleItem, "Velocity indicator", 'velo_indicator')
        self.conf_item(ToggleItem, "Acceleration indicator", 'accel_indicator')
        
        self.conf_item(SliderItem, "Music volume", 'musicvolume')
        self.conf_item(SliderItem, "FX volume", 'fxvolume')

    def conf_item(self, type, text, confkey):
        val = getattr(Config.Config, confkey)
        c = type(text=text, init=val)
        self.menu.add_item(c)
        c.connect_signal(SIG_CHANGED, self.conf_changed, confkey)

    def conf_changed(self, menuitem, confkey):
        setattr(Config.Config, confkey, menuitem.val)
        Config.Config.manager.Post(Event.ConfigChangedEvent(confkey))

    def controlsmenu(self, menuitem):
        k = KeyboardDialog()
        k.connect_signal(SIG_RESPONSE, self.on_child_over)
        self.push(k)

    def music_set(self, menuitem):
        # Not used -- we could do something with grabs here, maybe, but
        # I decided it would be easier to handle keys w/o grabs and mice
        # events separately (see SliderItem).
        pass

class MissionLogWidget(Widget):
    FIT = 4
    def __init__(self, game):
        super(MissionLogWidget, self).__init__()
        self.game = game
        self.topi = 0

    def render(self):
        self.rect = pygame.Rect(0, 0, self.game.pastgoals[self.topi].windowrect.width, 0)
        for i in self.slice():
            self.rect.height += self.game.pastgoals[i].windowrect.height

    def draw(self, screen):
        x, y = self.rect.topleft
        for i in self.slice():
            g = self.game.pastgoals[i]
            screen.blit(g.window, (x, y))
            y += g.windowrect.height

    def slice(self):
        '''Currently visible slice of self.game.pastgoals.'''
        end = min(len(self.game.pastgoals), self.topi+self.FIT)
        return range(self.topi, end)

    def morebelow(self):
        return self.topi+self.FIT < len(self.game.pastgoals)
    
    def moreabove(self):
        return self.topi > 0

    @periodic(5)
    def scroll_down(self):
        if self.morebelow():
            self.topi += 1

    @periodic(5)
    def scroll_up(self):
        if self.moreabove():
            self.topi -= 1

    KEYFUNCS = {K_UP: scroll_up, K_DOWN: scroll_down}

class MissionLogDialog(Dialog):
    def __init__(self, game):
        super(MissionLogDialog, self).__init__()
        self.child = MissionLogWidget(game)

    def handle_key(self, key, state):
        r = super(MissionLogDialog, self).handle_key(key, state)
        if r: return r
        if state == True and (key in [K_RETURN, K_ESCAPE]):
            self.emit(SIG_RESPONSE, True)

    def draw(self, screen):
        self.rect.center = (400, 300)
        super(MissionLogDialog, self).draw(screen)

class UserMenuDialog(Dialog):
    def __init__(self):
        super(UserMenuDialog, self).__init__()
        self.menu = CenterMenu()
        self.set_child(self.menu)
        self.menu.connect_signal(SIG_RESPONSE, self.response)
        self.menu.add_item(MenuItem(text="Menu"))

        self.menu.add_item(ResponseItem(text="Back to game"))

        c = ChoiceItem(text="Mission log")
        self.menu.add_item(c)
        c.connect_signal(SIG_ACTIVATED, self.missionlog)

        c = ChoiceItem(text="Options")
        self.menu.add_item(c)
        c.connect_signal(SIG_ACTIVATED, self.optionsmenu)

        c = ChoiceItem(text="Back to station")
        self.menu.add_item(c)
        c.connect_signal(SIG_ACTIVATED, self.last_advancelevel)

        c = ChoiceItem(text="Quit")
        self.menu.add_item(c)
        c.connect_signal(SIG_ACTIVATED, self.quit)

    def optionsmenu(self, menuitem):
        o = OptionsDialog()
        o.connect_signal(SIG_RESPONSE, self.on_child_over)
        self.push(o)

    def missionlog(self, menuitem):
        m = MissionLogDialog(self.game)
        m.connect_signal(SIG_RESPONSE, self.on_child_over)
        self.push(m)

    def last_advancelevel(self, menuitem):
        raise ReturnToBase, (Config.Config.nextlevel,)

    def quit(self, menuitem):
        raise KeyboardInterrupt

class PauseDialog(Dialog):
    def __init__(self, pausekey=None):
        super(PauseDialog, self).__init__()
        self.menu = Menu()
        self.set_child(self.menu)
        self.menu.add_item(MenuItem(text="Paused"))
        self.menu.connect_signal(SIG_RESPONSE, self.response)
        self.key = pausekey

    def handle_key(self, key, state):
        if state == True and key == self.key:
            self.response(self.menu, False)
            return True
        super(PauseDialog, self).handle_key(key, state)

class TestPicMenu(CenterMenu):
    def __init__(self):
        super(ConfigMenu, self).__init__()
        self.renderer = IconRenderer()
        self.add_item(ResponseItem(pic='invertebrate', text="a"))
        self.add_item(ResponseItem(pic="bossbullet", text="choose me"))

def campaigninfo(campname):
    return {'pic': 'unsolved', 'text': campname}

def levelinfo(level):
    try:
        d = level.metadata()
    except ValueError:
        return {'pic': 'unsolved', 'text': level.level}
    solved = d.pop('solved')
    d['text'] = d.pop('title')
    d['obj'] = level
    if solved:
        d['pic'] = 'solved'
    else:
        d['pic'] = 'unsolved'
    return d

class MakeDialog(object):
    '''Wrapper class to take care of creating, rendering and passing
    events to ocempgui dialogs.

    Also does some neat default stuff like focus the window and make
    it know that it has moved.'''
    def __init__(self, game, screen, dtype, title, *args, **kwargs):
        menu = dtype(*args, **kwargs)
        self.menu = menu
        menu.connect_signal(SIG_RESPONSE, self.response)
        menu.game = game
        self.screen = screen
        self.game = game

    def handle_event(self, event):
        '''Handle pygame input event.'''
        self.menu.handle_event(event)

    def handle_key(self, key, state):
        self.menu.handle_key(key, state)

    def set_response(self, respfunc):
        '''Set the handler when the dialog is over.'''
        self.respfunc = respfunc

    def response(self, dialog, result):
        '''Handler for response events on dialog.'''
        print "responded"
        if result: value = dialog.value(result)
        else: value = result
        self.respfunc(bool(result), value)

    def draw(self):
        self.menu.render()
        self.menu.rect.center = self.screen.get_rect().center
        self.menu.draw(self.screen)
