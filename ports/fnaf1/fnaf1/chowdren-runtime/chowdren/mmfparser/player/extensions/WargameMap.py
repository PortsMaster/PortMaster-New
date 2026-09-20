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
WargameMap.mfx
Wargame Map Object - Chris Branch (http://www.clickteam.com)

Calculates paths through a hexagonal map.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Set map width

    Parameters:
    0: Width of the map (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.create_array(
            width = self.evaluate_index(0),
            initial = 0)

class Action1(Action):
    """
    Set map height

    Parameters:
    0: Height of the map (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.create_array(
            height = self.evaluate_index(0),
            initial = 0)

class Action2(Action):
    """
    Set the cost of movement for a tile

    Parameters:
    0: Tile X coordinate (EXPRESSION, ExpressionParameter)
    1: Tile Y coordinate (EXPRESSION, ExpressionParameter)
    2: The movement cost of this tile (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        x = self.evaluate_index(0) - 1
        y = self.evaluate_index(1) - 1
        cost = self.evaluate_index(2)
        instance.objectPlayer.set_cost(x, y, cost)

class Action3(Action):
    """
    Calculate a path

    Parameters:
    0: Starting tile's X coordinate (EXPRESSION, ExpressionParameter)
    1: Starting tile's Y coordinate (EXPRESSION, ExpressionParameter)
    2: Destination tile's X coordinate (EXPRESSION, ExpressionParameter)
    3: Destination tile's Y coordinate (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        x1 = self.evaluate_index(0) - 1
        y1 = self.evaluate_index(1) - 1
        x2 = self.evaluate_index(2) - 1
        y2 = self.evaluate_index(3) - 1
        instance.objectPlayer.find_path(x1, y1, x2, y2)

class Action4(Action):
    """
    Next movement in path
    """

    def execute(self, instance):
        instance.objectPlayer.add_index(1)

class Action5(Action):
    """
    Previous movement in path
    """

    def execute(self, instance):
        instance.objectPlayer.add_index(-1)

class Action6(Action):
    """
    Reset movement to start of path
    """

    def execute(self, instance):
        instance.objectPlayer.add_index(None)

class Action7(Action):
    """
    Calculate line-of-sight path

    Parameters:
    0: Starting tile's X coordinate (EXPRESSION, ExpressionParameter)
    1: Starting tile's Y coordinate (EXPRESSION, ExpressionParameter)
    2: Destination tile's X coordinate (EXPRESSION, ExpressionParameter)
    3: Destination tile's Y coordinate (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        x1 = self.evaluate_index(0) - 1
        y1 = self.evaluate_index(1) - 1
        x2 = self.evaluate_index(2) - 1
        y2 = self.evaluate_index(3) - 1
        instance.objectPlayer.find_los_path(x1, y1, x2, y2)

# Conditions

class Condition0(Condition):
    """
    Compare to cost of movement for a tile

    Parameters:
    0: Tile X coordinate (EXPRESSION, ExpressionParameter)
    1: Tile Y coordinate (EXPRESSION, ExpressionParameter)
    2: Compare to the movement cost (COMPARISON, ExpressionParameter)
    """

    def check(self, instance):
        x = self.evaluate_index(0) - 1
        y = self.evaluate_index(1) - 1
        cost = self.evaluate_index(2)
        self.compare(instance.objectPlayer.get_cost(x, y), cost)

class Condition1(Condition):
    """
    Is tile impassable?

    Parameters:
    0: Tile X coordinate (EXPRESSION, ExpressionParameter)
    1: Tile Y coordinate (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        x = self.evaluate_index(0) - 1
        y = self.evaluate_index(1) - 1
        return instance.objecctPlayer.get_cost(x, y) >= INF_TILE_COST

class Condition2(Condition):
    """
    Does a valid path exist?
    """

    def check(self, instance):
        return bool(instance.objectPlayer.path)

class Condition3(Condition):
    """
    Compare to the total cost...->of the entire path

    Parameters:
    0: Compare to the movement cost (COMPARISON, ExpressionParameter)
    """

    def check(self, instance):
        value = self.evaluate_index(0)
        return self.compare(instance.objectPlayer.get_total_cost(-1), value)

class Condition4(Condition):
    """
    Compare to the number of movements in the path

    Parameters:
    0: Compare to the number of movements in the path (COMPARISON, ExpressionParameter)
    """

    def check(self, instance):
        value = self.evaluate_index(0)
        return self.compare(len(instance.objectPlayer.path), value)

class Condition5(Condition):
    """
    Compare to the total cost...->from the beginning to a specified movement

    Parameters:
    0: Index of movement (EXPRESSION, ExpressionParameter)
    1: Compare to the movement cost (COMPARISON, ExpressionParameter)
    """

    def check(self, instance):
        index = self.evaluate_index(0)
        value = self.evaluate_index(1)
        return self.compare(instance.objectPlayer.get_total_cost(index), value)

class Condition6(Condition):
    """
    Compare to the direction of a specified movement

    Parameters:
    0: Index of movement (EXPRESSION, ExpressionParameter)
    1: Compare to the direction of this movement (COMPARISON, ExpressionParameter)
    """

    def check(self, instance):
        index = self.evaluate_index(0)
        value = self.evaluate_index(1)
        return self.compare(instance.objectPlayer.get_direction(index), value)

class Condition7(Condition):
    """
    Compare to the total cost...->from the beginning to the current movement

    Parameters:
    0: Compare to the movement cost (COMPARISON, ExpressionParameter)
    """

    def check(self, instance):
        value = self.evaluate_index(0)
        return self.compare(instance.objectPlayer.get_total_cost(
            instance.objectPlayer.currentIndex), value)

class Condition8(Condition):
    """
    Compare to the direction of the current movement

    Parameters:
    0: Compare to the direction of this movement (COMPARISON, ExpressionParameter)
    """

    def check(self, instance):
        value = self.evaluate_index(0)
        return self.compare(instance.objectPlayer.get_direction(
            instance.objectPlayer.currentIndex), value)

class Condition9(Condition):
    """
    End of path reached?
    """

    def check(self, instance):
        path = instance.objectPlayer.path
        if not path:
            return True
        if instance.objectPlayer.currentIndex >= len(path) - 1:
            return True
        return False

# Expressions

class Expression0(Expression):
    """
    Map properties->Map width
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.mapWidth

class Expression1(Expression):
    """
    Map properties->Map height
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.mapHeight

class Expression2(Expression):
    """
    Map properties->Cost of movement for a tile

    Parameters:
    0: Tile X coordinate (Int)
    1: Tile Y coordinate (Int)
    Return type: Int
    """

    def get(self, instance):
        x = self.next_argument() - 1
        y = self.next_argument() - 1
        return instance.objectPlayer.get_cost(x, y)

class Expression3(Expression):
    """
    Total cost...->of the entire path
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_total_cost(-1)

class Expression4(Expression):
    """
    Number of movements in the path
    Return type: Int
    """

    def get(self, instance):
        return len(instance.objectPlayer.path)

class Expression5(Expression):
    """
    Total cost...->from the beginning to a specified movement

    Parameters:
    0: Index of movement (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument()
        return instance.objectPlayer.get_total_cost(index)

class Expression6(Expression):
    """
    Specified movement->Direction

    Parameters:
    0: Index of movement (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument()
        return instance.objectPlayer.get_direction(index)

class Expression7(Expression):
    """
    Specified movement->X coordinate

    Parameters:
    0: Index of movement (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument()
        try:
            return instance.objectPlayer.path[index][0] + 1
        except IndexError:
            return 0

class Expression8(Expression):
    """
    Specified movement->Y coordinate

    Parameters:
    0: Index of movement (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument()
        try:
            return instance.objectPlayer.path[index][1] + 1
        except IndexError:
            return 0

class Expression9(Expression):
    """
    Start and Destination tiles->X coordinate of the starting point
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.x1

class Expression10(Expression):
    """
    Start and Destination tiles->Y coordinate of the starting point
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.y1

class Expression11(Expression):
    """
    Start and Destination tiles->X coordinate of the destination point
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.x2

class Expression12(Expression):
    """
    Start and Destination tiles->Y coordinate of the destination point
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.y2

class Expression13(Expression):
    """
    Current movement->Index
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.currentIndex

class Expression14(Expression):
    """
    Total cost...->from the beginning to the current movement
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_total_cost(
            instance.objectPlayer.currentIndex)

class Expression15(Expression):
    """
    Current movement->Direction
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.get_direction(
            instance.objectPlayer.currentIndex)

class Expression16(Expression):
    """
    Current movement->X coordinate
    Return type: Int
    """

    def get(self, instance):
        index = instance.objectPlayer.currentIndex
        try:
            return instance.objectPlayer.path[index][0] + 1
        except IndexError:
            return 0

class Expression17(Expression):
    """
    Current movement->Y coordinate
    Return type: Int
    """

    def get(self, instance):
        index = instance.objectPlayer.currentIndex
        try:
            return instance.objectPlayer.path[index][1] + 1
        except IndexError:
            return 0

class Expression18(Expression):
    """
    Specified movement->Cost of movement

    Parameters:
    0: Index of movement (Int)
    Return type: Int
    """

    def get(self, instance):
        index = self.next_argument()
        return instance.objectPlayer.get_cost(*
            instance.objectPlayer.path[index])

class Expression19(Expression):
    """
    Current movement->Cost of movement
    Return type: Int
    """

    def get(self, instance):
        index = instance.objectPlayer.currentIndex
        return instance.objectPlayer.get_cost(*
            instance.objectPlayer.path[index])

import array
import math
from astar import astar

INF_TILE_COST = 99

class DefaultObject(HiddenObject):
    currentIndex = 0
    x1 = y1 = x2 = y2 = 0
    path = None
    def created(self, data):
        width = data.readInt(True)
        height = data.readInt(True)
        self.oddColumns = int(data.readByte() != 0)
        self.create_array(width, height, 1)
        self.path = []
        self.costs = []
    
    def create_array(self, width = None, height = None, initial = 1):
        width = width or self.mapWidth
        height = height or self.mapHeight
        self.mapWidth = width
        self.mapHeight = height
        self.cost = array.array('B', [initial] * (width * height))
    
    def get_direction(self, index):
        try:
            x1, y1 = self.path[index]
            x2, y2 = self.path[index - 1]
        except IndexError:
            return 0
        diff_x = x1 - x2
        if diff_x == 0:
            return [2, 8][int(y1 < y2)]
        elif diff_x == -1:
            return [7, 1][int((y1 == y2) ^ self.is_high_column(x1))]
        elif diff_x == 1:
            return [9, 3][int((y1 == y2) ^ self.is_high_column(x1))]
        return 0
    
    def is_high_column(self, x):
        oddColumns = bool(self.oddColumns)
        return ((oddColumns and ((x % 2) == 1)) or (
            not oddColumns and ((x % 2) == 0)))
    
    def get_cost(self, x, y):
        try:
            return self.cost[x + y * self.mapWidth]
        except IndexError:
            return INF_TILE_COST
    
    def get_total_cost(self, index):
        try:
            return self.costs[index]
        except IndexError:
            return INF_TILE_COST
    
    def set_cost(self, x, y, cost):
        try:
            self.cost[x + y * self.mapWidth] = cost
        except IndexError:
            pass
    
    def add_index(self, value):
        if value is None:
            self.currentIndex = 0
        else:
            self.currentIndex += value
    
    def find_path(self, x1, y1, x2, y2):
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        self.currentIndex = 0
        end_point = (x2, y2)

        def goal(point):
            return point == end_point
            
        def neighbors((x, y)):
            columnConstant = ((x % 2) ^ self.oddColumns) * 2 - 1
            nodes = []
            for n_x, n_y in ((x - 1, y),
                             (x - 1, y + columnConstant),
                             (x, y - 1),
                             (x, y + 1),
                             (x + 1, y),
                             (x + 1, y + columnConstant)):
                if (n_x < 0 or n_x >= self.mapWidth or
                    n_y < 0 or n_y >= self.mapHeight):
                    continue
                if self.get_cost(n_x, n_y) >= INF_TILE_COST:
                    continue
                nodes.append((n_x, n_y))
            return nodes

        def cost((x1, y1), (x2, y2)):
            return self.get_cost(x2, y2)

        def heuristic((x, y)):
            return self.heuristic(x, y, x2, y2)

        self.path, self.costs = astar((x1, y1), neighbors, goal, cost, 
            heuristic, True)
        if self.path:
            self.path.insert(0, (x1, y1))
            self.costs.insert(0, 0)
    
    def heuristic(self, x1, y1, x2, y2):
        xdist = math.fabs(x1 - x2)
        ydist = math.fabs(y1 - y2)
        if ((x1 % 2) ^ self.oddColumns) == 1:
            additional = ydist - ((xdist + 1) / 2)
        else:
            additional = ydist - (xdist / 2)
        if additional > 0:
            return xdist + additional
        return xdist
    
    def find_los_path(self, x1, y1, x2, y2):
        path, costs = self._find_los(x1, y1, x2, y2)
        self.path = path
        self.costs = costs
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        self.currentIndex = 0
        
    def _find_los(self, x1, y1, x2, y2):
        cost = cumulative = 0
        xstep = [-1, 1][int(x1 < x2)]
        ystep = [-1, 1][int(y1 < y2)]
        path = []
        costs = []
        if x1 == x2:
            while 1:
                cost = self.get_cost(x1, y1)
                if cost >= INF_TILE_COST:
                    return [], []
                cumulative += cost
                path.append((x1, y1))
                costs.append(cumulative)
                if y1 == y2:
                    return path, costs
                y1 += ystep
        verticalMovement = adjustedWidth = 0
        incrementColumn = [0, 1][self.oddColumns]
        if ((x1 < x2) and (y1 > y2)) or ((x1 > x2) and (y1 < y2)):
            incrementColumn = 1 - incrementColumn
        elif (y1 == y2) and ((max(x1, x2) & 1) == incrementColumn):
            incrementColumn = 1 - incrementColumn
        adjustedWidth = x2 - ([0, 1][int((x2 & 1) != incrementColumn)])
        adjustedWidth -= x1 - ([0, 1][int((x1 & 1) != incrementColumn)])
        verticalMovement = math.fabs(adjustedWidth) / 2
        if math.fabs(y2 - y1) != verticalMovement:
            return [], []
        if x1 > x2:
            incrementColumn = 1 - incrementColumn
        while 1:
            cost = self.get_cost(x1, y1)
            if cost >= INF_TILE_COST:
                return [], []
            cumulative += cost
            path.append((x1, y1))
            costs.append(cumulative)
            if x1 == x2:
                return path, costs
            x1 += xstep
            if (x1 & 1) == incrementColumn:
                y1 += ystep
        return [], []
        
class WargameMap(UserExtension):
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
        9 : Condition9,
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
    }

extension = WargameMap()

def get_extension():
    return extension
