# Copyright (c) Mathias Kaerlev 2012.

# This file is part of Anaconda.

# Anaconda is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Anaconda is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Anaconda.  If not, see <http://www.gnu.org/licenses/>.

"""
kcpica.mfx
Active Picture object - ClickTeam (http://www.clickteam.com)

Used to display an image file. Dynamic object: supports movements,
rotations, stretch, etc.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.objects.common import ObjectPlayer
from mmfparser.player.extensions.common import UserExtension
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression
from mmfparser.player.common import convert_path
from mmfparser.player.common import load_image

class LoadPicture(Action):
    def execute(self, instance):
        name = self.get_filename(self.get_parameter(0))
        instance.objectPlayer.load(name)
        
class LoadPictureSelector(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))
        
class SetHotspot(Action):
    def execute(self, instance):
        x = self.evaluate_index(0)
        y = self.evaluate_index(1)
        instance.objectPlayer.set_hotspot(x, y)

class SetSize(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class SetAngle(Action):
    def execute(self, instance):
        angle = self.evaluate_index(0)
        instance.objectPlayer.set_angle(angle)

class SetSemiTransparency(Action):
    def execute(self, instance):
        value = self.evaluate_index(0)
        instance.set_transparency((value / 100.0) * 128.0)

class Action6(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action7(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action8(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))
        
class Action9(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))
        
class Action10(Action):
    def execute(self, instance):
        # ACT_SETHOTSPOT_CENTER
        image = instance.objectPlayer.image
        if not image:
            return
        x = image.width / 2
        y = image.height / 2
        instance.objectPlayer.set_hotspot(x, y)

class Action11(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action12(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action13(Action):
    def execute(self, instance):
        # ACT_SETHOTSPOT_BOTTOMCENTER
        image = instance.objectPlayer.image
        if not image:
            return
        x = image.width / 2
        y = image.height
        instance.objectPlayer.set_hotspot(x, y)
        
class Action14(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action15(Action):
    def execute(self, instance):
        if not instance.objectPlayer.image:
            return
        instance.objectPlayer.image.flip_horizontal()

class Action16(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))
        
class Action17(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))
        
class Action18(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))
        
class Action19(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))
        
class Action20(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))
        
class Action21(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))
        
class Action22(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))
        
class Action23(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))
        
class Action24(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))
        
class Action25(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))
        
class Action26(Action):
    def execute(self, instance):
        destX = self.evaluate_index(0)
        destY = self.evaluate_index(1)
        srcX = self.evaluate_index(2)
        srcY = self.evaluate_index(3)
        srcWidth = self.evaluate_index(4)
        srcHeight = self.evaluate_index(5)
        collisionType = self.get_parameter(6).value
        instance.objectPlayer.paste(destX, destY, srcX, srcY, srcWidth, 
            srcHeight, collisionType)
        
class Action27(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))
        
class Action28(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

# ACT_ZOOMPERCENT

class Action29(Action):
    def execute(self, instance):
        objectPlayer = instance.objectPlayer
        image = objectPlayer.image
        if not image:
            return
        percent = self.evaluate_index(0)
        image.scale = percent / 100.0
        
class Action30(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))
        
class Action31(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))
        
class Action32(Action):
    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

# Conditions

class Condition0(Condition):
    def check(self, instance):
        return instance.objectPlayer.image is not None

class Condition1(Condition):
    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition2(Condition):
    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition3(Condition):
    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

# Expressions

class Expression0(Expression):
    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression1(Expression):
    def get(self, instance):
        if instance.objectPlayer.image is None:
            return 0
        return instance.objectPlayer.image.width

class Expression2(Expression):
    def get(self, instance):
        if instance.objectPlayer.image is None:
            return 0
        return instance.objectPlayer.image.height

class Expression3(Expression):
    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression4(Expression):
    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression5(Expression):
    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression6(Expression):
    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression7(Expression):
    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression8(Expression):
    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

# EXP_GETANGLE

class Expression9(Expression):
    def get(self, instance):
        return instance.objectPlayer.angle

class Expression10(Expression):
    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression11(Expression):
    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression12(Expression):
    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

# IMPLEMENT ME!

class Expression13(Expression):
    def get(self, instance):
        # EXP_GETZOOMFACTORX
        image = instance.objectPlayer.image
        if image is None:
            return 0
        return image.scale_x

class Expression14(Expression):
    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

from mmfparser.bitdict import BitDict

"""
    static final int ACT_LOADPICTURE = 0;
    static final int ACT_LOADPICTUREREQ = 1;
    static final int ACT_SETHOTSPOT = 2;
    static final int ACT_SETSIZEPIXELS = 3;
    static final int ACT_SETANGLE = 4;
    static final int ACT_SETSEMITRANSPRATIO = 5;
    static final int ACT_SETHOTSPOT_TOPLEFT = 6;
    static final int ACT_SETHOTSPOT_TOPCENTER = 7;
    static final int ACT_SETHOTSPOT_TOPRIGHT = 8;
    static final int ACT_SETHOTSPOT_CENTERLEFT = 9;
    static final int ACT_SETHOTSPOT_CENTER = 10;
    static final int ACT_SETHOTSPOT_CENTERRIGHT = 11;
    static final int ACT_SETHOTSPOT_BOTTOMLEFT = 12;
    static final int ACT_SETHOTSPOT_BOTTOMCENTER = 13;
    static final int ACT_SETHOTSPOT_BOTTOMRIGHT = 14;
    static final int ACT_FLIPH = 15;
    static final int ACT_FLIPV = 16;
    static final int ACT_LINKDIR = 17;
    static final int ACT_UNLINKDIR = 18;
    static final int ACT_LOOKAT = 19;
    static final int ACT_SETOFFSETX = 20;
    static final int ACT_SETOFFSETY = 21;
    static final int ACT_SETRESIZE_FAST = 22;
    static final int ACT_SETRESIZE_RESAMPLE = 23;
    static final int ACT_SETWRAPMODE_ON = 24;
    static final int ACT_SETWRAPMODE_OFF = 25;
    static final int ACT_ADDBACKDROP = 26;
    static final int ACT_SETAUTORESIZE_ON = 27;
    static final int ACT_SETAUTORESIZE_OFF = 28;
    static final int ACT_ZOOMPERCENT = 29;
    static final int ACT_ZOOMWIDTH = 30;
    static final int ACT_ZOOMHEIGHT = 31;
    static final int ACT_ZOOMRECT = 32;
"""

"""
    static final int CND_PICTURELOADED = 0;
    static final int CND_ISFLIPPED_HORZ = 1;
    static final int CND_ISFLIPPED_VERT = 2;
    static final int CND_ISWRAPMODE_ON = 3;
"""

"""
    static final int EXP_GETPICTURENAME = 0;
    static final int EXP_GETPICTUREXSIZE = 1;
    static final int EXP_GETPICTUREYSIZE = 2;
    static final int EXP_GETRESIZEDXSIZE = 3;
    static final int EXP_GETRESIZEDYSIZE = 4;
    static final int EXP_GETDISPLAYXSIZE = 5;
    static final int EXP_GETDISPLAYYSIZE = 6;
    static final int EXP_GETHOTSPOTX = 7;
    static final int EXP_GETHOTSPOTY = 8;
    static final int EXP_GETANGLE = 9;
    static final int EXP_GETSEMITRANSPRATIO = 10;
    static final int EXP_GETOFFSETX = 11;
    static final int EXP_GETOFFSETY = 12;
    static final int EXP_GETZOOMFACTORX = 13;
    static final int EXP_GETZOOMFACTORY = 14;
"""

from pyglet import image

region_cache = {}

class ActivePicture(ObjectPlayer):
    flags = None
    imageName = None
    image = None
    texture = None
    imageData = None
    angle = 0
    def created(self, data):
        self.flags = flags = BitDict(
            'Resize',
            'HideOnStart',
            'TransparentBlack',
            'TransparentFirstPixel',
            'FlippedHorizontally',
            'FlippedVertically',
            'Resample',
            'WrapModeOff',
        )
        self.width = data.readInt()
        self.height = data.readInt()
        flags.setFlags(data.readInt(True))
        self.transparentColor = data.readColor()
        imageName = data.readString(260)
        if imageName != '':
            self.load(imageName)
    
    def load(self, name):
        self.image = self.imageName = None
        try:
            if self.flags['TransparentFirstPixel']:
                transparent = None
            else:
                transparent = self.transparentColor
            self.imageData = load_image(name, transparent)
            if self.imageData is None:
                return
            self.texture = self.imageData.get_texture()
            self.image = newImage = self.make_sprite(self.texture)
            self.set_transparency(self.parent.transparency)
            self.set_angle(self.angle)
            newImage.shape.bottom = -newImage.height
            self.collision = newImage.collision
            self.set_position(self.x, self.y)
            self.imageName = name
            if self.flags['Resize']:
                self.set_size(self.width, self.height)
        except IOError:
            pass
    
    def set_size(self, width, height):
        if self.image is None:
            return
        self.image.scale_x = float(width) / self.image.width
        self.image.scale_y = float(height) / self.image.height
    
    def set_angle(self, value):
        if self.image:
            self.image.rot = value
        self.angle = value
    
    def set_hotspot(self, x, y):
        if not self.image:
            return
        imageData = self.imageData
        image = self.image
        diff_x = -image.shape.left - x
        diff_y = (image.shape.bottom + imageData.height) - y
        self.set_position(image.x - diff_x, image.y + diff_y)
        image.shape.left = -x
        image.shape.bottom = -imageData.height + y
    
    def set_transparency(self, value):
        if not self.image:
            return
        self.image.alpha = value / 128.0
    
    def set_position(self, x, y):
        if self.image:
            self.image.xy = x, y
    
    def draw(self):
        if self.image:
            self.image.render()
    
    def paste(self, destX, destY, srcX, srcY, width, height, collisionType):
        if self.image is None:
            return
        image = self.imageData
        newImage = image.get_region(srcX, image.height - height - srcY, width,
            height)
        sprite = self.make_sprite(newImage)
        sprite.alpha = self.image.alpha
        x, y = self.player.get_window_coordinates_python(destX, destY)
        sprite.x = x
        sprite.y = y
        sprite.shape.bottom = -newImage.height
        self.player.frame.paste_sprite(sprite, collisionType, 
            self.parent.layerIndex)

class kcpica(UserExtension):
    objectPlayer = ActivePicture
    
    actions = {
        0 : LoadPicture,
        1 : LoadPictureSelector,
        2 : SetHotspot,
        3 : SetSize,
        4 : SetAngle,
        5 : SetSemiTransparency,
        6 : Action6,
        7 : Action7,
        8 : Action8,
        9 : Action9,
        10 : Action10,
        11 : Action11,
        12 : Action12,
        13 : Action13,
        14 : Action14,
        15 : Action15,
        16 : Action16,
        17 : Action17,
        18 : Action18,
        19 : Action19,
        20 : Action20,
        21 : Action21,
        22 : Action22,
        23 : Action23,
        24 : Action24,
        25 : Action25,
        26 : Action26,
        27 : Action27,
        28 : Action28,
        29 : Action29,
        30 : Action30,
        31 : Action31,
        32 : Action32
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
        3 : Expression3,
        4 : Expression4,
        5 : Expression5,
        6 : Expression6,
        7 : Expression7,
        8 : Expression8,
        9 : Expression9,
        10 : Expression10,
        11 : Expression11,
        12 : Expression12,
        13 : Expression13,
        14 : Expression14
    }

extension = kcpica()

def get_extension():
    return extension
