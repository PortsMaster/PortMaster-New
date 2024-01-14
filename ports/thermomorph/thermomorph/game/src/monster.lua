Monster = class('Monster')
Monster:include(Stateful)

local IDLE_TIME_RANGE = vector(2, 4)
local IDLE_CHANCE = 0.1

function Monster:initialize(walkGraph, gameScene, i)
  self.graph = walkGraph
  self.gameScene = gameScene

  -- We start at the left corner or the right corner.
  local START_POSITIONS = {WALK_GRAPH.leftCorner, WALK_GRAPH.rightCorner}
  self.node = START_POSITIONS[i]
  self.pos = self:getPosFromNode(self.node)

  -- Keep track of a set of visited nodes so that the robot doesn't go back and
  -- forth between two nodes.
  self:clearVisited()

  -- Start out in the random walk state
  self:gotoState('Idle')
end

function Monster:clearVisited()
  self.visited = {}
  self.visited[self.node] = true
end


local randomness = 8
function Monster:getPosFromNode()
   return self.graph:getNodeData(self.node)
    + vector(lume.random(-randomness, randomness),
             lume.random(-randomness, randomness))
end

function Monster:update(dt)
end

local RandomWalkState = Monster:addState('RandomWalk')

function RandomWalkState:enteredState()
  -- Get neighbors that aren't in our visited set.
  local neighbors = self.graph:getNeighbors(self.node)
  local choices = lume.filter(neighbors, function(n)
    return self.visited[n] == nil
  end)

  -- If we have no non-visited nodes, clear the visited set and just choose from
  -- our neighbors.
  if #choices == 0 then
    log.debug("Resetting visited set.")
    self:clearVisited()
    choices = neighbors
  end

  -- Pick the next node randomly from our choices.
  local nextNode = lume.randomchoice(choices)

  local tansitionTime = lume.random(TRANSITION_TIME_RANGE.x, TRANSITION_TIME_RANGE.y)
  self.gameScene.timer:after(tansitionTime, function()
    self.node = nextNode
    self.pos = self:getPosFromNode(self.node)
    self.visited[self.node] = true

    if self.node == WALK_GRAPH.attackLeft then
      self:gotoState('Attacking', 'left')
    elseif self.node == WALK_GRAPH.attackRight then
      self:gotoState('Attacking', 'right')
    elseif self.gameScene.heating:getState() == "off" then
        self:gotoState('Pathing')
    elseif lume.random() < IDLE_CHANCE then
        self:gotoState('Idle')
    else
      self:gotoState('RandomWalk')
    end
  end)
end

local PathingState = Monster:addState('Pathing')

function PathingState:enteredState()
  local leftPath = WALK_GRAPH:getPath(self.node, WALK_GRAPH.attackLeft)
  local righPath = WALK_GRAPH:getPath(self.node, WALK_GRAPH.attackRight)

  -- Choose the shortest path.
  local path = nil
  if #leftPath < #righPath then
    path = leftPath
  else
    path = rightPath
  end

  log.debug("Current Node:", self.node)
  log.debug("Shortest Path:", inspect(path))

  if path == nil then
    log.error("Path is nil for some reason.")
    self:gotoState('RandomWalk')
    return
  end

  local nextNode = path[2]
  local tansitionTime = lume.random(TRANSITION_TIME_RANGE.x, TRANSITION_TIME_RANGE.y)

  self.gameScene.timer:after(tansitionTime, function()
    self.node = nextNode
    self.pos = self:getPosFromNode(self.node)

    if self.node == WALK_GRAPH.attackLeft then
      self:gotoState('Attacking', 'left')
    elseif self.node == WALK_GRAPH.attackRight then
      self:gotoState('Attacking', 'right')
    elseif self.gameScene.heating:getState() ~= "off" then
        self:gotoState('RandomWalk')
    else
      self:gotoState('Pathing')
    end
  end)
end

local AttackingState = Monster:addState('Attacking')

function AttackingState:enteredState(direction)
  log.debug("Entering AttackingState...")

  -- Check if this current attacking node is already occupied by another monster.
  local occupied = false
  for _, other in ipairs(self.gameScene.monsters) do
    if other ~= self and (other.node == WALK_GRAPH.attackLeft or other.node == WALK_GRAPH.attackRight) then
      occupied = true
      break
    end
  end

  if occupied then
    -- If occupied, go back to the first flee node.
    local path = nil
    if direction == 'left' then
      path = WALK_GRAPH.leftRunawayPath
    elseif direction == 'right' then
      path = WALK_GRAPH.rightRunawayPath
    else
      error("Unknown attacking direction.")
    end

    log.debug('Avioding an occupied attack spot.')
    self.node = path[2]
    self.pos = self:getPosFromNode(self.node)
    self:gotoState('Idle')
  else
    self.attackCallback = self.gameScene.timer:after(ATTACKING_TIME, function()
      if direction == 'left' then
        self.gameScene.leftAttack = true
      elseif direction == 'right' then
        self.gameScene.rightAttack = true
      else
        error("Unknown attacking direction.")
      end
    end)
  end
end

function AttackingState:runaway(direction)
  self.gameScene.timer:cancel(self.attackCallback)
  self:gotoState('Fleeing', direction)
end

local FleeingState = Monster:addState('Fleeing')
function FleeingState:enteredState(direction)
  log.debug('Monster fleeing...')
  if direction == 'left' then
    self.path = WALK_GRAPH.leftRunawayPath
  elseif direction == 'right' then
    self.path = WALK_GRAPH.rightRunawayPath
  else
    error("Unknown attacking direction.")
  end

  self.pathIndex = 2
  self.node = self.path[self.pathIndex]
  self.pos = self:getPosFromNode(self.node)
  self:startMovement()
end

local FLEE_TRANSITION_TIME = 2
function FleeingState:startMovement()
  self.gameScene.timer:after(FLEE_TRANSITION_TIME, function()
    self.pathIndex = self.pathIndex + 1
    if self.pathIndex > #self.path then
      self:gotoState('Idle')
    else
      self.node = self.path[self.pathIndex]
      self.pos = self:getPosFromNode(self.node)
      self:startMovement()
    end
  end)
end

local IdleState = Monster:addState('Idle')

function IdleState:enteredState()
  log.debug("Entering idle state.")
  self:clearVisited()
  local idleTme = lume.random(IDLE_TIME_RANGE.x, IDLE_TIME_RANGE.y)
  self.gameScene.timer:after(idleTme, function()
    self:gotoState('RandomWalk')
  end)
end


return Monster
