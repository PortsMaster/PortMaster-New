local Graph = require "src.graph"

WALK_GRAPH = Graph()

local attackLeft = WALK_GRAPH:addNode(vector(300, 413))
WALK_GRAPH.attackLeft = attackLeft

local left1 = WALK_GRAPH:addNode(vector(277, 333))
WALK_GRAPH:addEdge(attackLeft, left1)

local left2 = WALK_GRAPH:addNode(vector(210, 241))
WALK_GRAPH:addEdge(left1, left2)

local leftRoom = WALK_GRAPH:addNode(vector(180, 328))
WALK_GRAPH:addEdge(left1, leftRoom)

local left3 = WALK_GRAPH:addNode(vector(93, 239))
WALK_GRAPH:addEdge(left2, left3)

local left4 = WALK_GRAPH:addNode(vector(89, 124))
WALK_GRAPH:addEdge(left3, left4)

local leftHallway = WALK_GRAPH:addNode(vector(44, 206))
WALK_GRAPH:addEdge(leftRoom, leftHallway)
WALK_GRAPH:addEdge(leftHallway, left4)
WALK_GRAPH.leftHallway = leftHallway

local leftCorner = WALK_GRAPH:addNode(vector(91, 31))
WALK_GRAPH:addEdge(left4, leftCorner)
WALK_GRAPH.leftCorner = leftCorner

local left5 = WALK_GRAPH:addNode(vector(210, 31))
WALK_GRAPH:addEdge(left5, leftCorner)

local left6 = WALK_GRAPH:addNode(vector(212, 124))
WALK_GRAPH:addEdge(left5, left6)
WALK_GRAPH:addEdge(left2, left6)


local attackRight = WALK_GRAPH:addNode(vector(370, 414))
WALK_GRAPH.attackRight = attackRight

local right1 = WALK_GRAPH:addNode(vector(396, 335))
WALK_GRAPH:addEdge(attackRight, right1)

local rightRoom = WALK_GRAPH:addNode(vector(495, 330))
WALK_GRAPH:addEdge(rightRoom, right1)

local right2 = WALK_GRAPH:addNode(vector(467, 241))
WALK_GRAPH:addEdge(right2, right1)
WALK_GRAPH:addEdge(right2, rightRoom)

local right3 = WALK_GRAPH:addNode(vector(474, 127))
WALK_GRAPH:addEdge(right3, right2)

local middle = WALK_GRAPH:addNode(vector(361, 30))
WALK_GRAPH:addEdge(left5, middle)

local rightCorner = WALK_GRAPH:addNode(vector(581, 32))
WALK_GRAPH:addEdge(rightCorner, middle)
WALK_GRAPH.rightCorner = rightCorner

local right4 = WALK_GRAPH:addNode(vector(580, 241))
WALK_GRAPH:addEdge(right2, right4)

local right5 = WALK_GRAPH:addNode(vector(580, 122))
WALK_GRAPH:addEdge(right4, right5)
WALK_GRAPH:addEdge(right3, right5)
WALK_GRAPH:addEdge(rightCorner, right5)

local middle2 = WALK_GRAPH:addNode(vector(371, 131))
WALK_GRAPH:addEdge(right3, middle2)
WALK_GRAPH:addEdge(middle2, left6)

WALK_GRAPH.leftRunawayPath = {attackLeft, left1, left2, left3, left4, leftCorner}
WALK_GRAPH.rightRunawayPath = {attackRight, right1, right2, right4, right5, rightCorner}

return WALK_GRAPH
