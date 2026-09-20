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
AdvPathMov.mfx

Advanced Path Movement object - David Clark (Alien) (http://www.clickteam.com)
Create paths with multiple branches where the player can chose to take
the shortest route from their current position to a new position.

Ported to Python by Mathias Kaerlev
"""

import math

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

def distance_from(x1, y1, x2, y2):
    return math.sqrt((x2 - x1)**2 + (y2 - y1)**2)

# Actions

class Action0(Action):
    """
    Path Control->Create new path node

    Parameters:
    0: X position (TIME, Time)
    1: Y position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        x = self.evaluate_index(0)
        y = self.evaluate_index(1)
        instance.objectPlayer.points.append(Point(x, y))

class Action1(Action):
    """
    Path Control->Remove path node

    Parameters:
    0: node ID (OBJECT, Object)
    1: 01Clear Journey ( type %s ) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0)
        objectPlayer = instance.objectPlayer
        if objectPlayer.distance != 0:
            return
        if objectPlayer.journeys:
            return
        if index < 1:
            return
        if index > len(objectPlayer.points):
            return
        index -= 1
        objectPlayer.pop(index)
        for point in objectPlayer.points:
            for connection in point.connections[:]:
                if connection.id == index:
                    point.connections.remove(connection)
                elif connection.id >= index:
                    connection.id -= 1

class Action2(Action):
    """
    Journey Control ->Clear Journey

    Parameters:
    0: 0 = Remove all nodes 1 = Keep Current node (OBJECT, Object)
    1: Connect node ID %0 to ID %1 with speed %2 (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        clearType = self.evaluate_index(0)
        objectPlayer = instance.objectPlayer
        journeys = objectPlayer.journeys
        if len(journeys) < 2:
            objectPlayer.distance = 0
            objectPlayer.totalDistance = 0
            objectPlayer.moving = False
            return
        if clearType == 0:
            objectPlayer.journeys = []
            objectPlayer.distance = 0
            objectPlayer.totalDistance = 0
            objectPlayer.moving = False
            return
        if clearType == 1 and objectPlayer.distance == 0:
            objectPlayer.remove(1)
            objectPlayer.distance = 0
            objectPlayer.totalDistance = 0
        if clearType == 1 and objectPlayer.distance > 0:
            objectPlayer.remove(2)

class Action3(Action):
    """
    Path Control->Connect nodes

    Parameters:
    0: ...from node ID (SHORT, Short)
    1: ...to node ID (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index1 = self.evaluate_index(0) - 1
        index2 = self.evaluate_index(1) - 1
        speed = float(self.evaluate_index(2) or 1)
        points = instance.objectPlayer.points
        for index in (index1, index2):
            if index < 0 or index >= len(points):
                return
        if index1 == index2:
            return
        point1 = points[index1]
        point2 = points[index2]
        for connection in point1.connections[:]:
            if connection.id == index2:
                point1.connections.remove(connection)
        distance = distance_from(point1.x, point1.y, point2.x, point2.y) / speed
        point1.connections.append(Connection(index2, distance))
        
class Action4(Action):
    """
    Journey Control ->Add path node

    Parameters:
    0: Node ID (OBJECT, Object)
    1: 01 Insert path node ID %s in the journey at %s (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0) - 1
        instance.objectPlayer.journeys.append(Journey(index))

class Action5(Action):
    """
    Journey Control ->Insert path node

    Parameters:
    0: Node ID (TIME, Time)
    1: Position in journey (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0) - 1
        pos = self.evaluate_index(1)
        points = instance.objectPlayer.points
        journey = instance.objectPlayer.journeys
        try:
            points[index]
        except IndexError:
            return
        journey.insert(pos, Journey(index))

class Action6(Action):
    """
    Journey Control ->Remove last path node

    Parameters:
    0: 01 Delete path node ID %s from journey ((unknown 25070))
    """

    def execute(self, instance):
        instance.objectPlayer.journeys.pop()

class Action7(Action):
    """
    Journey Control ->Delete path node

    Parameters:
    0: Node ID (OBJECT, Object)
    1: 01Find Journey to node ID %s  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        if instance.objectPlayer.distance != 0:
            return
        index = self.evaluate_index(0) - 1
        journey = instance.objectPlayer.journeys
        try:
            journey.pop(index)
        except IndexError:
            return
        
from astar import astar

def find_path(start, points, end_node):
    goal_point = points[end_node]
    def goal(point):
        return point == goal_point
    def neighbors(point):
        return [points[connection.id] for connection in point.connections]
    def cost(a, b):
        return distance_from(a.x, a.y, b.x, b.y)
    def heuristic(point):
        return cost(goal_point, point)
    result = astar(start, neighbors, goal, cost, heuristic)
    return [points.index(item) for item in result]

class Action8(Action):
    """
    Journey Control ->Find Journey to node

    Parameters:
    0: Node ID (OBJECT, Object)
    1: 01 Load Path from :  %s  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        node = self.evaluate_index(0) - 1
        if node < 0:
            return
        objectPlayer = instance.objectPlayer
        journeys = objectPlayer.journeys
        if node > len(objectPlayer.points):
            return
        if not journeys:
            return
        if node == journeys[-1].id:
            return
        points = objectPlayer.points
        point = points[journeys[-1].id]
        path = find_path(point, objectPlayer.points, node)
        for item in path:
            journeys.append(Journey(item))
            
class Action9(Action):
    """
    Files->Load Path

    Parameters:
    0: File Directory (OBJECT, Object)
    1: 01 Save Path to :  %s  (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.read(self.evaluate_expression(
            self.get_parameter(0)))

class Action10(Action):
    """
    Files->Save Path

    Parameters:
    0: File Directory (OBJECT, Object)
    1: Start Movement (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.write(self.evaluate_expression(
            self.get_parameter(0)))

class Action11(Action):
    """
    Movement->Start

    Parameters:
    0: Stop Movement ((unknown 25120))
    """

    def execute(self, instance):
        objectPlayer = instance.objectPlayer
        journeys = objectPlayer.journeys
        points = objectPlayer.points
        if not journeys:
            return
        objectPlayer.moving = True
        objectPlayer.mustStop = False
        firstNode = journeys[0].id
        nextNode = 0
        if len(journeys) > 1:
            nextNode = journeys[1].id
        connectFound = False
        for connection in points[firstNode].connections:
            if connection.id == nextNode:
                objectPlayer.totalDistance = connection.distance
                connectFound = True
        if not connectFound:
            objectPlayer.moving = False
            objectPlayer.distance = 0
            objectPlayer.mustStop = False
            objectPlayer.totalDistance = 0

class Action12(Action):
    """
    Movement->Stop

    Parameters:
    0: Pause Movement ((unknown 25130))
    """

    def execute(self, instance):
        instance.objectPlayer.mustStop = True

class Action13(Action):
    """
    Movement->Pause

    Parameters:
    0: 01Set Object speed to %s ((unknown 25140))
    """

    def execute(self, instance):
        instance.objectPlayer.moving = False

class Action14(Action):
    """
    Movement->Object Settings->Set Speed

    Parameters:
    0: Object Speed ( 1: normal 2: fast 0.5: slow (OBJECT, Object)
    1: 01 Set Object to %s (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.speed = self.evaluate_expression(
            self.get_parameter(0))

class Action15(Action):
    """
    Movement->Set Object

    Parameters:
    0: Select Object (OBJECT, Object)
    1: 01Set object X offset to %s (OBJECT, Object)
    """

    def execute(self, instance):
        try:
            currentObject = self.get_instances(
                self.get_parameter(0).objectInfo)[0]
        except IndexError:
            return
        instance.objectPlayer.currentObject = currentObject

class Action16(Action):
    """
    Movement->Object Settings->Set X Offset

    Parameters:
    0: X Pixels (OBJECT, Object)
    1: 01Set Object Y offset to %s (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.xOffset = self.evaluate_expression(
            self.get_parameter(0))

class Action17(Action):
    """
    Movement->Object Settings->Set Y Offset

    Parameters:
    0: Y Pixels (OBJECT, Object)
    1: 01Enable Autostep (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.yOffset = self.evaluate_expression(
            self.get_parameter(0))

class Action18(Action):
    """
    Movement->Auto Step->Enable

    Parameters:
    0: 01Disable Autostep ((unknown 25190))
    """

    def execute(self, instance):
        instance.objectPlayer.autoStep = True

class Action19(Action):
    """
    Movement->Auto Step->Disable

    Parameters:
    0: 01Force-Move object by %s step/s ((unknown 25200))
    """

    def execute(self, instance):
        instance.objectPlayer.autoStep = False

class Action20(Action):
    """
    Movement->Auto Step->Force move x steps

    Parameters:
    0: Number of steps (OBJECT, Object)
    1: 01Set Node %s X pos to %s (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        speed = self.evaluate_index(0)
        instance.objectPlayer.update(speed)

def move_point(point, x, y, points):
    oldX = point.x
    oldY = point.y
    point.x = x
    point.y = y
    index = points.index(point)
    for item in points:
        if item == point:
            continue
        for connection in item.connections:
            if connection.id == index:
                oldDist = distance_from(item.x, item.y, oldX, oldY)
                speed = connection.distance / oldDist
                connection.distance = distance_from(item.x, item.y, x, y) * speed
    
    for connection in point.connections:
        item = points[connection.id]
        distance = connection.distance
        oldDistance = distance_from(item.x, item.y, oldX, oldY)
        speed = distance / oldDistance
        connection.distance = distance_from(item.x, item.y, x, y) * speed

class Action21(Action):
    """
    Path Control->Set Node X

    Parameters:
    0: Node ID (TIME, Time)
    1: X Position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0) - 1
        x = self.evaluate_index(1)
        try:
            point = instance.objectPlayer.points[index]
        except IndexError:
            return
        move_point(point, x, point.y, instance.objectPlayer.points)

class Action22(Action):
    """
    Path Control->Set Node Y

    Parameters:
    0: Node ID (TIME, Time)
    1: Y Position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index = self.evaluate_index(0) - 1
        y = self.evaluate_index(1)
        try:
            point = instance.objectPlayer.points[index]
        except IndexError:
            return
        move_point(point, point.x, y, instance.objectPlayer.points)

class Action23(Action):
    """
    Path Control->Disconnect nodes

    Parameters:
    0: ...from node ID (TIME, Time)
    1: ...to node ID (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        index1 = self.evaluate_index(0) - 1
        index2 = self.evaluate_index(1) - 1
        points = instance.objectPlayer.points
        try:
            point1 = points[index1]
            point2 = points[index2]
        except IndexError:
            return
        for item in point1.connections[:]:
            if item.id == index2:
                point1.connections.remove(item)

class Action24(Action):
    """
    Path Control->Clear path

    Parameters:
    0: 01Auto Change X flag = %s ((unknown 25250))
    """

    def execute(self, instance):
        instance.objectPlayer.points = []
        instance.objectPlayer.journeys = []
        instance.objectPlayer.moving = False

class Action25(Action):
    """
    Movement->Object Flags->Change X

    Parameters:
    0: 1 = Yes 0 = No (OBJECT, Object)
    1: 01Auto Change Y flag = %s (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.changeX = self.evaluate_expression(
            self.get_parameter(0)) == 1

class Action26(Action):
    """
    Movement->Object Flags->Change Y

    Parameters:
    0: 1 = Yes 0 = No (OBJECT, Object)
    1: 01Auto Change Direction flag = %s (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.changeY = self.evaluate_expression(
            self.get_parameter(0)) == 1

class Action27(Action):
    """
    Movement->Object Flags->Change Direction

    Parameters:
    0: 1 = Yes 0 = No (OBJECT, Object)
    1: Change Direction (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.changeDirection = self.evaluate_expression(
            self.get_parameter(0)) == 1


# Conditions

class Condition0(Condition):
    """
    Is moving ?
    """

    def check(self, instance):
        return instance.objectPlayer.moving

class Condition1(Condition):
    """
    Are nodes connected ?

    Parameters:
    0: Connected from Node ID (TIME, Time)
    1: Connected to Node ID (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        index1 = self.evaluate_index(0) - 1
        index2 = self.evaluate_index(1) - 1
        try:
            point1 = instance.objectPlayer.points[index1]
        except IndexError:
            return
        for connection in point1.connections:
            if connection.id == index2:
                return True
        return False
        

class Condition2(Condition):
    """
    Is stopped ?

    Parameters:
    0: 10%sHas reached the end of the journey? ((unknown 26030))
    """

    def check(self, instance):
        return instance.objectPlayer.mustStop

class Condition3(Condition):
    """
    Has reached the end of the journey?

    Parameters:
    0: 10%sHas touched a new node ? ((unknown 26010))
    """
    iterateObjects = False
    instance = None
    
    def created(self):
        if self.isTriggered:
            self.add_handlers(end_reached = self.end_reached)
            
    def end_reached(self, instance):
        self.instance = instance
        self.generate()

    def check(self):
        if not self.isTriggered or self.instance is None:
            return False
        self.select_instances([self.instance])
        return True

class Condition4(Condition):
    """
    Has touched a new node ?

    Parameters:
    0: 10%sIs moving ? ((unknown 26000))
    """
    iterateObjects = False
    instance = None
    
    def created(self):
        if self.isTriggered:
            self.add_handlers(touched_new_node = self.node_touched)
            
    def node_touched(self, instance):
        self.instance = instance
        self.generate()

    def check(self):
        if not self.isTriggered or self.instance is None:
            return False
        self.select_instances([self.instance])
        return True


# Expressions

class Expression0(Expression):
    """
    Nodes->Find closest node from co-ordinates

    Parameters:
    0: (not found) (String)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        x = self.next_argument()
        y = self.next_argument()
        distance = self.next_argument()
        
        answer = distance * distance
        result = 0
        deltaX = 0
        deltaY = 0
        loopCount = 0
        objectPlayer = instance.objectPlayer
        
        for item in objectPlayer.points:
            loopCount += 1
            deltaX = math.fabs(item.x - x)
            deltaY = math.fabs(item.y - y)
            if answer > (deltaX * deltaX + deltaY * deltaY):
                answer = (deltaX * deltaY + deltaY * deltaY)
                result = loopCount
        return result

class Expression1(Expression):
    """
    Nodes->Number of nodes

    Parameters:
    0: (not found) ((unknown 27020))
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.points)

class Expression2(Expression):
    """
    Journey->Get Node ID from Journey

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument()
        try:
            return instance.objectPlayer.journeys[index].id + 1
        except IndexError:
            return 0

class Expression3(Expression):
    """
    Journey->Number of nodes in the journey

    Parameters:
    0: (not found) ((unknown 27040))
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.journeys)

class Expression4(Expression):
    """
    Get Current X

    Parameters:
    0: (not found) ((unknown 27050))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.currentX

class Expression5(Expression):
    """
    Get Current Y

    Parameters:
    0: (not found) ((unknown 27060))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.currentY

class Expression6(Expression):
    """
    Settings->Get Speed

    Parameters:
    0: (not found) ((unknown 27070))
    Return type: Float
    """

    def get(self, instance):
        return instance.objectPlayer.speed

class Expression7(Expression):
    """
    Nodes->Get Distance

    Parameters:
    0: (not found) (Global)
    1: (not found) (Int)
    Return type: Float
    """

    def get(self, instance):
        index1 = self.next_argument() - 1
        index2 = self.next_argument() - 1
        try:
            point1 = instance.objectPlayer.points[index1]
            point2 = instance.objectPlayer.points[index2]
        except IndexError:
            return 0
        return distance_from(point1.x, point1.y, point2.x, point2.y)

class Expression8(Expression):
    """
    Nodes->Get X

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument() - 1
        try:
            return instance.objectPlayer.points[index].x
        except IndexError:
            return 0

class Expression9(Expression):
    """
    Nodes->Get Y

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument() - 1
        try:
            return instance.objectPlayer.points[index].y
        except IndexError:
            return 0

class Expression10(Expression):
    """
    Settings->Get X Offset

    Parameters:
    0: (not found) ((unknown 27120))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.xOffset

class Expression11(Expression):
    """
    Settings->Get Y Offset

    Parameters:
    0: (not found) ((unknown 27130))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.yOffset

class Expression12(Expression):
    """
    Get Current Angle ( North, clockwise )

    Parameters:
    0: (not found) ((unknown 27140))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.angle

class Expression13(Expression):
    """
    Get Current Direction ( 0 to 32 )

    Parameters:
    0: (not found) ((unknown 27150))
    Return type: Int
    """

    def get(self, instance):
        direction = (instance.objectPlayer.angle * 32 + 180) / 360
        direction = 8 - direction
        if direction < 0:
            direction += 32
        return direction

class Expression14(Expression):
    """
    Nodes->Get connection

    Parameters:
    0: (not found) (Global)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        index1 = self.next_argument() - 1
        index2 = self.next_argument()
        try:
            return instance.objectPlayer.points[index1].connections[index2].id
        except IndexError:
            return 0
        

class Expression15(Expression):
    """
    Nodes->Get number of connections

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        index1 = self.next_argument() - 1
        try:
            return len(instance.objectPlayer.points[index1].connections)
        except IndexError:
            return 0

class Expression16(Expression):
    """
    Nodes->Get speed between nodes

    Parameters:
    0: (not found) (Global)
    1: (not found) (Int)
    Return type: Float
    """

    def get(self, instance):
        index1 = self.next_argument() - 1
        index2 = self.next_argument() - 1
        try:
            point1 = instance.objectPlayer.points[index1]
            point2 = instance.objectPlayer.points[index2]
        except IndexError:
            return 0
        for connection in point1.connections:
            if connection.id == index2:
                speed = connection.distance
                break
        else:
            return 0
        distance = distance_from(point1.x, point1.y, point2.x, point2.y)
        if distance == 0:
            return 1
        return distance / speed

class Expression17(Expression):
    """
    Flags->Auto Change X

    Parameters:
    0: (not found) ((unknown 27190))
    Return type: Int
    """

    def get(self, instance):
        return int(instance.objectPlayer.changeX)

class Expression18(Expression):
    """
    Flags->Auto Change Y

    Parameters:
    0: (not found) ((unknown 27200))
    Return type: Int
    """

    def get(self, instance):
        return int(instance.objectPlayer.changeY)

class Expression19(Expression):
    """
    Flags->Auto Change Direction
    Return type: Int
    """

    def get(self, instance):
        return int(instance.objectPlayer.changeDirection)

class Journey(object):
    def __init__(self, pid):
        self.id = pid

class Connection(object):
    def __init__(self, pid, distance):
        self.id = pid
        self.distance = distance

class Point(object):
    connect = None
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.connections = []

from mmfparser.bytereader import ByteReader

class DefaultObject(HiddenObject):
    moving = False
    distance = 0
    totalDistance = 0
    mustStop = False
    currentObject = None
    currentX = currentY = 0
    def created(self, data):
        data.skipBytes(4)
        self.width = data.readShort()
        self.height = data.readShort()
        self.speed = data.readInt() / 100.0
        self.xOffset = data.readInt()
        self.yOffset = data.readInt()
        self.changeX = data.readByte() == 1
        self.changeY = data.readByte() == 1
        self.changeDirection = data.readByte() == 1
        self.autoStep = data.readByte() == 1
        self.points = []
        self.journeys = []
        self.updateEnabled = True
    
    def read(self, filename):
        self.points = []
        try:
            data = ByteReader(open(filename, 'rb'))
        except IOError:
            return
        while data.tell() < len(data):
            count = (data.readInt() - 2) / 2
            x = data.readInt()
            y = data.readInt()
            point = Point(x, y)
            self.points.append(point)
            for _ in xrange(count):
                point_id = data.readInt()
                distance = data.readFloat()
                connection = Connection(point_id, distance)
                point.connections.append(connection)
    
    def write(self, filename):
        for point in self.vector:
            data.writeInt(len(point.connections) * 2 + 2)
            data.writeInt(point.x)
            data.writeInt(point.y)
            for connection in point.connections:
                data.writeInt(connection.id)
                data.writeFloat(connection.distance)
        
    def update(self, speed = None):
        speed = speed or self.speed
        if len(self.journeys) == 1:
            point = self.points[self.journeys[0].id]
            self.update_position(point.x, point.y)
        if not self.moving:
            return
        if not self.autoStep:
            return
        self.distance += speed
        connectFound = False
        i = 0
        while self.moving and self.distance >= self.totalDistance:
            self.journeys.pop(0)
            point = self.points[self.journeys[0].id]
            x = point.x + self.xOffset
            y = point.y + self.yOffset
            self.update_position(x, y)
            self.fire_handler('touched_new_node')
            if len(self.journeys) <= 1 or self.mustStop:
                self.moving = False
                self.distance = 0
                self.mustStop = False
                self.totalDistance = 0
                self.fire_handler('end_reached')
            if self.moving:
                self.distance -= self.totalDistance
                point1 = self.points[self.journeys[0].id]
                point2_id = self.journeys[1].id
                for connection in point1.connections:
                    if connection.id == point2_id:
                        self.totalDistance = connection.distance
                        break
                else:
                    self.moving = False
                    self.distance = 0
                    self.mustStop = False
                    self.totalDistance = 0
        if self.moving and self.distance != 0:
            point1 = self.points[self.journeys[0].id]
            point2 = self.points[self.journeys[1].id]
            x1, y1 = point1.x, point1.y
            x2, y2 = point2.x, point2.y
            deltaX = x2 - x1
            deltaY = y2 - y1
            
            if self.totalDistance != 0:
                self.angle = 180 - (math.atan2(deltaX, deltaY) / math.pi * 180)
                
                x = (x1 + deltaX * (self.distance / self.totalDistance
                    ) + self.xOffset)
                y = (y1 + deltaY * (self.distance / self.totalDistance
                    ) + self.yOffset)
                self.update_position(x, y)
                if self.changeDirection and self.currentObject:
                    direction = 8 - (self.angle * 32 + 180) / 360
                    if direction < 0:
                        direction += 32
                    self.currentObject.set_direction(direction)
    
    def update_position(self, newX, newY):
        self.currentX = newX
        self.currentY = newY
        parent = self.currentObject
        x = parent.x
        y = parent.y
        if newX is not None and self.changeX:
            x = newX
        if newY is not None and self.changeY:
            y = newY
        parent.set_position(x, y)
    
    def remove(self, fromValue):
        while 1:
            try:
                self.journeys.pop(fromValue)
            except IndexError:
                break

class AdvPathMov(UserExtension):
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
        21 : Action21,
        22 : Action22,
        23 : Action23,
        24 : Action24,
        25 : Action25,
        26 : Action26,
        27 : Action27,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3,
        4 : Condition4,
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
        11 : Expression10,
        12 : Expression11,
        13 : Expression12,
        14 : Expression13,
        15 : Expression14,
        16 : Expression15,
        17 : Expression16,
        18 : Expression17,
        19 : Expression18,
        20 : Expression19,
    }

extension = AdvPathMov()

def get_extension():
    return extension
