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
kcclock.mfx
Date and Time object - ClickTeam (http://www.clickteam.com)

Used to display date and time in various formats. Can act as a
stopwatch or countdown device.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Set hundredths of seconds

    Parameters:
    0: Set hundredths of seconds (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0)
        newTime = int(instance.objectPlayer.currentTime) + value / 100.0
        instance.objectPlayer.currentTime = newTime
        
class SetTimeAction(Action):
    def execute(self, instance):
        new = self.evaluate_index(0)
        value = instance.objectPlayer.get_struct_time()
        self.action(value, new)
        instance.objectPlayer.set_struct_time(value)
        
    def action(self, value, new):
        pass

class Action1(SetTimeAction):
    """
    Set seconds

    Parameters:
    0: Set seconds (EXPRESSION, ExpressionParameter)
    """

    def action(self, value, new):
        value.tm_sec = new

class Action2(SetTimeAction):
    """
    Set minutes

    Parameters:
    0: Set minutes (EXPRESSION, ExpressionParameter)
    """

    def action(self, value, new):
        value.tm_min = new

class Action3(SetTimeAction):
    """
    Set hours

    Parameters:
    0: Set hours (EXPRESSION, ExpressionParameter)
    """

    def action(self, value, new):
        value.tm_hours = new

class Action4(SetTimeAction):
    """
    Set day of week

    Parameters:
    0: Set day of week (EXPRESSION, ExpressionParameter)
    """

    def action(self, value, new):
        value.tm_wday = new

class Action5(SetTimeAction):
    """
    Set day of month

    Parameters:
    0: Set day of month (EXPRESSION, ExpressionParameter)
    """

    def action(self, value, new):
        value.tm_mday = new

class Action6(SetTimeAction):
    """
    Set month

    Parameters:
    0: Set month (EXPRESSION, ExpressionParameter)
    """

    def action(self, value, new):
        value.tm_mon = new

class Action7(SetTimeAction):
    """
    Set year

    Parameters:
    0: Set year (EXPRESSION, ExpressionParameter)
    """

    def action(self, value, new):
        value.tm_year = new

class Action8(Action):
    """
    Stop watch->Reset stop watch to 00:00:00
    """

    def execute(self, instance):
        instance.objectPlayer.counting = None
        instance.objectPlayer.currentTime = 0

class Action9(Action):
    """
    Stop watch->Start stop watch
    """

    def execute(self, instance):
        instance.objectPlayer.counting = 1

class Action10(Action):
    """
    Stop watch->Pause stop watch
    """

    def execute(self, instance):
        instance.objectPlayer.counting = None

class Action11(Action):
    """
    Visibility->Make object reappear
    """

    def execute(self, instance):
        instance.visible = True

class Action12(Action):
    """
    Visibility->Make object invisible
    """

    def execute(self, instance):
        instance.visible = False

class Action13(Action):
    """
    Position->Select position...

    Parameters:
    0: Select position... (POSITION, Position)
    """

    def execute(self, instance):
        destX, destY, _ = self.get_positions(
            self.get_parameter(0))[0]
        instance.set_position(destX, destY, True)

class Action14(Action):
    """
    Count down->Set count down

    Parameters:
    0: Set count down (TIME, Time)
    """

    def execute(self, instance):
        instance.objectPlayer.currentTime = self.get_time(self.get_parameter(0))

class Action15(Action):
    """
    Count down->Start count down
    """

    def execute(self, instance):
        instance.objectPlayer.counting = -1

class Action16(Action):
    """
    Count down->Pause count down
    """

    def execute(self, instance):
        instance.objectPlayer.counting = None

class Action17(Action):
    """
    Position->Set Horizontal Position

    Parameters:
    0: Set Horizontal Position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        x = self.evaluate_index(0)
        instance.set_position(x, instance.y, True)

class Action18(Action):
    """
    Position->Set Vertical Position

    Parameters:
    0: Set Vertical Position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        y = self.evaluate_index(0)
        instance.set_position(instance.x, y, True)

class Action19(Action):
    """
    Size->Set Horizontal Size

    Parameters:
    0: Set Horizontal Size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        width = self.evaluate_index(0)
        instance.objectPlayer.resize(width = width)

class Action20(Action):
    """
    Size->Set Vertical Size

    Parameters:
    0: Set Vertical Size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        height = self.evaluate_index(0)
        instance.objectPlayer.resize(height = height)

# Conditions

class Condition0(Condition):
    """
    Compare to chrono

    Parameters:
    0: Compare to chrono (CMPTIME, CompareTime)
    """
    
    def created(self):
        parameter = self.get_parameter(0)
        self.compareValue = parameter.comparison
        self.seconds = parameter.timer / 1000.0

    def check(self, instance):
        return self.compare(instance.objectPlayer.currentTime, self.seconds)

class Condition1(Condition):
    """
    New clock second ?
    """
    
    def created(self):
        self.add_handlers(second_changed = self.changed)

    def changed(self):
        self.generate()
        
    def check(self, instance):
        return self.isTriggered

class Condition2(Condition):
    """
    New clock minute ?
    """

    def created(self):
        self.add_handlers(minute_changed = self.changed)

    def changed(self):
        self.generate()
        
    def check(self, instance):
        return self.isTriggered

class Condition3(Condition):
    """
    New clock hour ?
    """

    def created(self):
        self.add_handlers(hour_changed = self.changed)

    def changed(self):
        self.generate()
        
    def check(self, instance):
        return self.isTriggered

class Condition4(Condition):
    """
    New clock day ?
    """

    def created(self):
        self.add_handlers(day_changed = self.changed)

    def changed(self):
        self.generate()
        
    def check(self, instance):
        return self.isTriggered

class Condition5(Condition):
    """
    New clock month ?
    """

    def created(self):
        self.add_handlers(month_changed = self.changed)

    def changed(self):
        self.generate()
        
    def check(self, instance):
        return self.isTriggered

class Condition6(Condition):
    """
    New clock year ?
    """

    def created(self):
        self.add_handlers(year_changed = self.changed)

    def changed(self):
        self.generate()
        
    def check(self, instance):
        return self.isTriggered

class Condition7(Condition):
    """
    Compare to count down

    Parameters:
    0: Compare to count down (CMPTIME, CompareTime)
    """

    def created(self):
        parameter = self.get_parameter(0)
        self.compareValue = parameter.comparison
        self.seconds = parameter.timer / 1000.0

    def check(self, instance):
        return self.compare(instance.objectPlayer.currentTime, self.seconds)

class Condition8(Condition):
    """
    Is visible ?
    """

    def check(self, instance):
        return instance.visible


# Expressions

class Expression0(Expression):
    """
    Retrieve hundredths of seconds
    Return type: Int
    """

    def get(self, instance):
        val = instance.objectPlayer.currentTime
        return int((val - int(val)) * 100)

class Expression1(Expression):
    """
    Retrieve seconds
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_struct_time().tm_second

class Expression2(Expression):
    """
    Retrieve minutes
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_struct_time().tm_min

class Expression3(Expression):
    """
    Retrieve hours
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_struct_time().tm_hour

class Expression4(Expression):
    """
    Retrieve day of week
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_struct_time().tm_wday

class Expression5(Expression):
    """
    Retrieve day of month
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_struct_time().tm_mday

class Expression6(Expression):
    """
    Retrieve month
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_struct_time().tm_mon

class Expression7(Expression):
    """
    Retrieve year
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_struct_time().tm_year

class Expression8(Expression):
    """
    Retrieve Stop watch time
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.currentTime

class Expression9(Expression):
    """
    Retrieve analog clock data->X coordinate of clock centre
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_center(True)[0]

class Expression10(Expression):
    """
    Retrieve analog clock data->Y coordinate of clock centre
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_center(True)[1]

def get_hand(instance, angle, is_hour = False):
    radius = instance.objectPlayer.get_radius()
    if is_hour:
        radius /= 1.5
    mid_x, mid_y = instance.objectPlayer.get_center(True)
    x_value = math.cos(angle)
    y_value = -math.sin(angle)
    return (mid_x + x_value * radius, mid_y + y_value * radius)

class Expression11(Expression):
    """
    Retrieve analog clock data->X coordinate of hour hand's end
    Return type: Int
    """

    def get(self, instance):
        second, minute, hour = instance.objectPlayer.get_time()
        angle = get_hour_angle(hour + minute / 60.0)
        return get_hand(instance, angle)[0]

class Expression12(Expression):
    """
    Retrieve analog clock data->Y coordinate of hour hand's end
    Return type: Int
    """

    def get(self, instance):
        second, minute, hour = instance.objectPlayer.get_time()
        angle = get_hour_angle(hour + minute / 60.0)
        return get_hand(instance, angle)[1]

class Expression13(Expression):
    """
    Retrieve analog clock data->X coordinate of minute hand's end
    Return type: Int
    """

    def get(self, instance):
        second, minute, hour = instance.objectPlayer.get_time()
        angle = get_second_minute_angle(minute + second / 60.0)
        return get_hand(instance, angle)[0]

class Expression14(Expression):
    """
    Retrieve analog clock data->Y coordinate of minute hand's end
    Return type: Int
    """

    def get(self, instance):
        second, minute, hour = instance.objectPlayer.get_time()
        angle = get_second_minute_angle(minute + second / 60.0)
        return get_hand(instance, angle)[1]

class Expression15(Expression):
    """
    Retrieve analog clock data->X coordinate of second hand's end
    Return type: Int
    """

    def get(self, instance):
        second, minute, hour = instance.objectPlayer.get_time()
        angle = get_second_minute_angle(second)
        return get_hand(instance, angle)[0]

class Expression16(Expression):
    """
    Retrieve analog clock data->Y coordinate of second hand's end
    Return type: Int
    """

    def get(self, instance):
        second, minute, hour = instance.objectPlayer.get_time()
        angle = get_second_minute_angle(second)
        return get_hand(instance, angle)[1]

class Expression17(Expression):
    """
    Retrieve Count down time
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.currentTime

class Expression18(Expression):
    """
    X Position of Clock
    Return type: Int
    """

    def get(self, instance):
        return instance.x

class Expression19(Expression):
    """
    Y Position of Clock
    Return type: Int
    """

    def get(self, instance):
        return instance.y

class Expression20(Expression):
    """
    X Size of Clock
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.width

class Expression21(Expression):
    """
    Y Size of Clock
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.height

from mmfparser.data.font import LogFont

ANALOG_CLOCK = 0
DIGITAL_CLOCK = 1
INVISIBLE = 2
CALENDAR = 3

CLOCK = 0
STOPWATCH = 1
COUNTDOWN = 2

SHORTDATE = 0
LONGDATE = 1
FIXEDDATE = 2

import datetime
import calendar
import time
import math

from pyglet.gl import (glTranslatef, glPushMatrix, glPopMatrix, glBegin,
    glEnd, glVertex2f, glColor3ub, GL_LINES, glLineWidth, glEnable,
    glDisable, GL_LINE_SMOOTH, GL_POINT_SMOOTH, GL_LINE_LOOP)

from pyglet.graphics import vertex_list

from mmfparser.player.common import make_ellipse_vertices

def get_pointer_angle(value):
    return math.radians(360.0 * value)

def get_mark_angle(i):
    return get_pointer_angle((i + 1) / 12.0)

def get_hour_angle(i):
    return -get_pointer_angle(i / 12.0 - 0.25)

def get_second_minute_angle(i):
    return -get_pointer_angle(i / 60.0 - 0.25)

roman_characters = [ "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", 
    "X", "XI", "XII"]

def display_pointer(angle, color, radius):
    x_value = math.cos(angle)
    y_value = math.sin(angle)
    glBegin(GL_LINES)
    glColor3ub(*color)
    glVertex2f(0.0, 0.0)
    glVertex2f(x_value * radius, y_value * radius)
    glEnd()

class DefaultObject(HiddenObject):
    clockLabels = None
    border = None
    formatString = None
    label = None
    text = None
    counting = None
    currentTime = 0
    oldTime = None
    def created(self, data):
        self.width = data.readShort(True)
        self.height = data.readShort(True)
        data.skipBytes(4 * 16)
        displayType = self.displayType = data.readShort(True)
        self.clockMode = data.readShort(True)
        self.drawBorder = data.readShort() != 0
        self.drawLines = data.readShort() != 0
        analogClockMarkerType = data.readShort(True)
        font = LogFont(data)
        if font.height in (8, -8) and font.faceName.lower() == 'system':
            font.height = -13
            font.weight = 700
        color = self.color = data.readColor()
        data.skipBytes(40)
        
        self.displaySeconds = data.readShort(True) != 0
        self.secondsColor = data.readColor()
        self.displayMinutes = data.readShort(True) != 0
        self.minutesColor = data.readColor()
        self.displayHours = data.readShort(True) != 0
        self.hoursColor = data.readColor()
        
        digitalClockType = data.readShort(True)
        calenderType = data.readShort(True)
        calenderFormat = data.readShort(True)
        data.skipBytes(40)
        
        if self.clockMode == COUNTDOWN:
            countHours = data.readShort(True)
            countMinutes = data.readShort(True)
            countSeconds = data.readShort(True)
            self.currentTime = (countSeconds + countMinutes * 60 + 
                countHours * 60 * 60)
        elif self.clockMode == CLOCK:
            self.currentTime = time.time()
        
        minWidth = data.readShort(True)
        minHeight = data.readShort(True)
    
        if displayType == ANALOG_CLOCK:
            if analogClockMarkerType != 2:
                self.clockLabels = []
                for i in xrange(1, 13):
                    if analogClockMarkerType == 0:
                        text = str(i)
                    else:
                        text = roman_characters[i-1]
                    label = self.create_label(font, text, color)
                    label.width = label.content_width
                    label.height = label.content_height
                    label.y = label.content_height / 2
                    label.x = -label.content_width / 2
                    self.clockLabels.append(label)
            self.make_border()
        elif displayType == DIGITAL_CLOCK:
            if digitalClockType == 0:
                formatString = '%(hour)s:%(minute)s'
            elif digitalClockType == 1:
                formatString = '%(hour)s:%(minute)s:%(second)s'
            elif digitalClockType == 2:
                formatString = '%(full_hour)s:%(minute)s'
            elif digitalClockType == 3:
                formatString = '%(full_hour)s:%(minute)s:%(second)s'
            self.formatString = formatString
        elif displayType == CALENDAR:
            if calenderType == SHORTDATE:
                formatString = '%d-%m-%Y'
            elif calenderType == LONGDATE:
                formatString = '%d. %B %Y'
            else:
                if calenderFormat == 0:
                    formatString = '%d/%m/%y'
                elif calenderFormat == 1:
                    formatString = '%d %B %Y'
                elif calenderFormat == 2:
                    formatString = '%d %B, %Y'
                elif calenderFormat == 3:
                    formatString = '%B %d, %Y'
                elif calenderFormat == 4:
                    formatString = '%d-%b-%y'
                elif calenderFormat == 5:
                    formatString = '%B, %y'
                elif calenderFormat == 6:
                    formatString = '%b-%Y'
            self.formatString = formatString
        if displayType in (DIGITAL_CLOCK, CALENDAR):
            label = self.label = self.create_label(font, '', color, 
                multiline = True)
            label.height = self.height
            label.width = self.width
            label.content_valign = 'center'
            label.set_style('align', 'center')
            label.x = label.y = 0

        glEnable(GL_LINE_SMOOTH)
        glEnable(GL_POINT_SMOOTH)
        
        self.updateEnabled = True
    
    def update(self):
        if (self.counting is not None or self.clockMode == CLOCK or 
        self.displayType == CALENDAR):
            self.currentTime += self.player.sinceLast * (self.counting or 1)
        self.currentTime = max(0, self.currentTime)
        val = self.get_struct_time()
        old_val = self.oldTime
        if old_val is not None:
            if val.tm_sec != old_val.tm_sec:
                self.fire_handler('second_changed')
            if val.tm_hour != old_val.tm_hour:
                self.fire_handler('hour_changed')
            if val.tm_yday != old_val.tm_yday:
                self.fire_handler('day_changed')
            if val.tm_mon != old_val.tm_mon:
                self.fire_handler('month_changed')
            if val.tm_year != old_val.tm_year:
                self.fire_handler('year_changed')
        self.oldTime = val
    
    def make_border(self):
        if self.drawBorder:
            if self.border is not None:
                self.border.delete()
            radius = min(self.width, self.height) / 2.0 - 20
            vertices = []
            for item in make_ellipse_vertices(radius * 2, radius * 2):
                vertices += item
            self.border = vertex_list(len(vertices) / 2, 
                ('v2f', vertices),
                ('c3B', self.color * (len(vertices) / 2)))
    
    def get_center(self, not_gl = False):
        mid_x = self.width / 2.0
        mid_y = self.height / 2.0
        if not_gl:
            return (self.parent.x + mid_x, self.parent.y + mid_y)
        else:
            return (self.x + mid_x, self.y - mid_y)
    
    def get_radius(self):
        return min(self.width, self.height) / 2.0 - 20
            
    def draw(self):
        mid_x, mid_y = self.get_center()
        glLineWidth(2)
        if self.displayType == ANALOG_CLOCK:
            radius = min(self.width, self.height) / 2.0 - 10
            radius_end = radius - 10
            glPushMatrix()
            glTranslatef(mid_x, mid_y, 0)
            if self.clockLabels is not None or self.drawLines:
                for i in xrange(0, 12):
                    glPushMatrix()
                    angle = get_mark_angle(i + 1)
                    x_value = math.cos(angle)
                    y_value = math.sin(angle)
                    if self.drawLines:
                        glBegin(GL_LINES)
                        glColor3ub(*self.color)
                        glVertex2f(x_value * radius_end, y_value * radius_end)
                        glVertex2f(x_value * (radius - 20), 
                            y_value * (radius - 20))
                        glEnd()
                    if self.clockLabels is not None:
                        x = x_value * radius
                        y = y_value * radius
                        glTranslatef(x, y, 0)
                        self.clockLabels[-i].draw()
                    glPopMatrix()
            # second pointer
            second, minute, hour = self.get_time()
            if self.displaySeconds:
                display_pointer(get_second_minute_angle(
                    second), 
                    self.secondsColor, radius_end)
            
            if self.displayHours:
                display_pointer(get_hour_angle(hour + minute / 60.0), 
                    self.hoursColor, radius_end / 1.5)
            
            if self.displayMinutes:
                display_pointer(get_second_minute_angle(
                    minute + second / 60.0), self.minutesColor, 
                    radius_end)
            glPopMatrix()
            if self.border is not None:
                glPushMatrix()
                glTranslatef(self.x + 20, self.y - 20, 0.0)
                self.border.draw(GL_LINE_LOOP)
                glPopMatrix()

        elif self.displayType in (DIGITAL_CLOCK, CALENDAR):
            text = self.get_text()
            if text != self.text:
                self.label.text = text
                self.text = text
            glPushMatrix()
            glTranslatef(self.x, self.y, 0)
            self.label.draw()
            if self.displayType == DIGITAL_CLOCK and self.drawBorder:
                glBegin(GL_LINE_LOOP)
                glColor3ub(*self.color)
                glVertex2f(0, 0)
                glVertex2f(self.width, 0)
                glVertex2f(self.width, -self.height)
                glVertex2f(0, -self.height)
                glEnd()
            glPopMatrix()
    
    def get_text(self):
        if self.displayType == CALENDAR:
            return time.strftime(self.formatString, 
                self.get_struct_time())
        else:
            second, minute, full_hour = self.get_time(False)
            hour = full_hour % 12
            return self.formatString % {
                'second' : '%02d' % second,
                'minute' : '%02d' % minute,
                'full_hour' : '%02d' % full_hour,
                'hour' : '%02d' % hour
            }
    
    def set_struct_time(self, value):
        if self.displayType != CALENDAR and self.clockMode != CLOCK:
            self.currentTime = calender.timegm(value)
        else:
            self.currentTime = time.mktime(value)
    
    def get_struct_time(self):
        if self.displayType != CALENDAR and self.clockMode != CLOCK:
            return time.gmtime(self.currentTime)
        else:
            return time.localtime(self.currentTime)
    
    def get_time(self, micro_precision = True):
        val = self.get_struct_time()
        second = val.tm_sec + self.currentTime - int(self.currentTime)
        return (second, val.tm_min, val.tm_hour)
    
    def resize(self, width = None, height = None):
        self.width = width or self.width
        self.height = height or self.height
        self.make_border()

class kcclock(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
        3 : Action3,
        4 : Action4,
        5 : Action5,
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
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3,
        4 : Condition4,
        5 : Condition5,
        6 : Condition6,
        7 : Condition7,
        8 : Condition8,
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
        14 : Expression14,
        15 : Expression15,
        16 : Expression16,
        17 : Expression17,
        18 : Expression18,
        19 : Expression19,
        20 : Expression20,
        21 : Expression21,
    }

extension = kcclock()

def get_extension():
    return extension
