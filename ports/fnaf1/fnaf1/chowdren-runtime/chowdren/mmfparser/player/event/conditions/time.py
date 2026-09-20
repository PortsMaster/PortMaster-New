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

from mmfparser.player.event.conditions.common import Condition

class Every(Condition):
    seconds = None
    last = None
    left = None
    
    def created(self):
        seconds = self.seconds = self.get_parameter(0).delay / 1000.0
        self.left = seconds

    def check(self):
        self.left -= self.player.sinceLast
        if self.left > 0:
            return False
        self.left += self.seconds
        return True

class TimerEquals(Condition):
    ticked = False
    def created(self):
        seconds = self.seconds = self.get_parameter(0).timer / 1000.0
        self.player.clock.schedule_once(self.tick, seconds)
        self.player.add_time_change_handler(self.time_changed)
    
    def time_changed(self):
        self.ticked = False
        self.group.container.remove_enable_callback(self.on_enable)
        clock = self.player.clock
        clock.unschedule(self.tick)
        clock.schedule_once(self.tick, 
            self.seconds - self.player.get_offset_time())
    
    def tick(self, sinceLast):
        if self.isTriggered:
            if self.group.container.is_enabled():
                self.ticked = True
                self.generate()
            else:
                self.player.clock.schedule_once(self.tick, 0)
    
    def on_enable(self):
        self.generate()

    def on_detach(self):
        self.player.clock.unschedule(self.tick)
    
    def check(self):
        hasTicked = self.ticked
        self.ticked = False
        return hasTicked

class TimerGreater(Condition):
    def created(self):
        self.seconds = self.get_parameter(0).timer / 1000.0
        if self.isTriggered:
            self.player.clock.schedule_once(self.first_trigger, self.seconds)
            self.player.add_time_change_handler(self.time_changed)

    def time_changed(self):
        clock = self.player.clock
        clock.unschedule(self.trigger)
        clock.unschedule(self.first_trigger)
        clock.schedule_once(self.first_trigger, 
            self.seconds - self.player.get_offset_time())
    
    def first_trigger(self, sinceLast):
        self.player.schedule_loop(self.trigger)
        self.trigger()
    
    def trigger(self, sinceLast = None):
        self.generate()
    
    def check(self):
        return self.player.get_offset_time() > self.seconds
    
    def on_detach(self):
        self.player.clock.unschedule(self.trigger)
        self.player.clock.unschedule(self.first_trigger)

class TimerLess(Condition):
    def created(self):
        self.seconds = self.get_parameter(0).timer / 1000.0
        if self.isTriggered:
            self.player.schedule_loop(self.trigger)
            self.player.clock.schedule_once(self.first_trigger,
                self.seconds - self.player.get_offset_time())
            self.player.add_time_change_handler(self.time_changed)

    def time_changed(self):
        clock = self.player.clock
        clock.unschedule(self.trigger)
        clock.unschedule(self.first_trigger)
        if self.check():
            self.player.schedule_loop(self.trigger)
            self.player.clock.schedule_once(self.first_trigger, self.seconds)
    
    def first_trigger(self, sinceLast):
        self.player.clock.unschedule(self.trigger)
    
    def trigger(self, sinceLast = None):
        self.generate()
    
    def check(self):
        return self.player.get_offset_time() < self.seconds
        
    def on_detach(self):
        self.player.clock.unschedule(self.trigger)
        self.player.clock.unschedule(self.first_trigger)

class CompareAwayTime(Condition):
    def created(self):
        self.seconds = self.get_time(self.get_parameter(0))
    
    def check(self):
        return self.player.awayTime > self.seconds