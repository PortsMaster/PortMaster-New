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
Get.mfx
Get object - AquadaSoft/Jamie McLaughlin (http://www.aquadasoft.com)

This extension can retrieve the output of HTTP web pages and scripts

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Get URL

    Parameters:
    0: URL (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        value = self.evaluate_index(0)
        instance.objectPlayer.get(value)

# Conditions

class Condition0(Condition):
    """
    On get complete
    """
    instance = None
    
    def created(self):
        if self.isTriggered:
            self.add_handlers(get_completed = self.get_completed)
    
    def get_completed(self, instance):
        self.generate()

    def check(self, instance):
        return True

class Condition1(Condition):
    """
    Is get pending?
    """

    def check(self, instance):
        return instance.objectPlayer.pending

# Expressions

class Expression0(Expression):
    """
    Page content
    Return type: String
    """

    def get(self, instance):
        return instance.objectPlayer.data or ''

import threading, time
import urllib2

class Fetch(threading.Thread):
    def __init__(self, parent, page):
    	threading.Thread.__init__(self)
    	self.page = page
        self.parent = parent

    def run(self):
        try:
            data = urllib2.urlopen(self.page).read()
        except urllib2.URLError:
            data = None
        self.parent.data = data

class GetObject(HiddenObject):
    pending = True
    getThread = None
    data = None
    
    def created(self):
        pass
        
    def get(self, url):
        if self.getThread is not None:
            return
        self.pending = True
        getThread = self.getThread = Fetch(self, url)
        getThread.start()
        self.player.clock.schedule(self.updateDone)
    
    def updateDone(self, dt):
        if self.getThread.is_alive():
            return
        self.player.clock.unschedule(self.updateDone)
        self.getThread = None
        self.pending = False
        if self.data is None:
            return
        self.fire_handler('get_completed')

class Get(UserExtension):
    objectPlayer = GetObject
    
    actions = {
        0 : Action0,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
    }
    
    expressions = {
        0 : Expression0,
    }

extension = Get()

def get_extension():
    return extension
