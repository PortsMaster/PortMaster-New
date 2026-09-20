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

from mmfparser.player.movements.common import MovementPlayer, get_direction

class Path(MovementPlayer):
    pixel_per_move = None

    step = None
    steps = None
    stepIndex = None
    sinus = None
    cosinus = None
    
    distanceLeft = None
    distance = None
    
    reversed = False
    
    endX = None
    endY = None
    
    repositionAtEnd = None
    loop = None
    reverseAtEnd = None
    
    paused = False
    
    goToIndex = None

    def created(self):
        self.maxSpeed = self.movement.loader.maximumSpeed
        self.minSpeed = self.movement.loader.minimumSpeed
        self.reverseAtEnd = self.movement.loader.reverseAtEnd
        self.loop = self.movement.loader.loop
        self.repositionAtEnd = self.movement.loader.repositionAtEnd

        self.steps = self.movement.loader.steps
        if self.steps:
            self.set_step(0)
        else:
            self.stop()
        self.endX = self.endY = 0
        for step in self.steps:
            self.endX += step.destinationX
            self.endY += step.destinationY
    
    def speed_changed(self):
        self.pixel_per_move = self.get_pixels(self.speed)
    
    def get_move(self):
        return self.pixel_per_move * self.player.multiplier
        
    def move(self):
        if self.speed == 0:
            return
        move = self.get_move()
        self.distanceLeft -= move
        if self.distanceLeft <= 0:
            move += self.distanceLeft
        
        y_speed = self.sinus * move
        x_speed = self.cosinus * move
        x, y = self.parent.x, self.parent.y
        x += x_speed
        y += y_speed
        self.parent.set_position(x, y)
        self.handle_collisions()

        if self.distanceLeft <= 0:
            if self.reversed:
                stepIndex = self.stepIndex - 1
                realIndex = self.stepIndex
            else:
                stepIndex = realIndex = self.stepIndex + 1
            if realIndex != self.goToIndex:
                self.set_step(stepIndex)
            else:
                self.goToIndex = True
                self.stop()
            if stepIndex <= len(self.steps) -1:
                self.fire_handler('node_reached')
                if self.step.name != '':
                    self.fire_handler('named_node_reached', self.step.name)
    
    def on_start(self):
        # MMF2 behaviour-- we can't go anywhere now!
        if self.goToIndex is True:
            return
        self.set_speed(self.step.speed)
        self.set_walk()
    
    def on_stop(self):
        self.unschedule()
        self.set_speed(0)
        self.set_walk()
    
    def depause(self, sinceLast, index):
        self.set_step(index)
    
    def reverse(self):
        self.reversed = not self.reversed
        self.cosinus *= -1
        self.sinus *= -1
        self.distanceLeft = self.step.length - self.distanceLeft
    
    def unschedule(self):
        self.player.clock.unschedule(self.depause)
    
    def set_step(self, index):
        if self.goToIndex is None:
            if index > len(self.steps) - 1:
                if self.repositionAtEnd and not self.reverseAtEnd:
                    x, y = self.parent.x, self.parent.y
                    x -= self.endX
                    y -= self.endY
                    self.parent.set_position(x, y)
                if not self.reversed and self.reverseAtEnd:
                    self.reversed = True
                    self.set_step(self.stepIndex)
                elif self.loop:
                    self.set_step(0)
                else:
                    self.parent.fire_handler('path_finished')
                    self.stop()
                return
            elif index < 0:
                self.reversed = False
                self.set_step(0)
                if not self.loop:
                    self.stop()
                return
            
        self.stepIndex = index
        step = self.step = self.steps[index]
        self.distanceLeft = step.length
        sinus = step.sinus
        cosinus = step.cosinus
        if self.reversed:
            sinus = step.sinus * -1
            cosinus = step.cosinus * -1
        self.sinus = sinus
        self.cosinus = cosinus
        if step.pause and not self.paused:
            self.paused = True
            self.stop()
            self.player.clock.schedule_once(self.depause, step.pause / 50.0, 
                index)
            return
        else:
            self.paused = False
            self.start()
        self.set_direction(step.direction)
        self.set_speed(step.speed)
    
    def branch_node(self, name):
        index = self.find_node_index(name)
        if index is None:
            return
        self.goToIndex = None
        if self.reversed:
            index -= 1
        self.set_step(index)
    
    def goto_node(self, name):
        index = self.find_node_index(name)
        if index is None:
            return
        self.unschedule()
        if self.stepIndex >= index and not self.reversed:
            self.reverse()
        self.goToIndex = index
    
    def find_node_index(self, name):
        name = name.lower()
        for index, step in enumerate(self.steps):
            if step.name is not None and step.name.lower() == name:
                return index
        return None

__all__ = ['Path']