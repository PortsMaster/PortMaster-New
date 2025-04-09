MotionSensor = Tablet:addState('MotionSensor')
local map = love.graphics.newImage('assets/graphics/map.png')

local SCAN_MIN_WAIT = 1

function MotionSensor:enteredState()
  self.switchTime = love.timer.getTime()
end

function MotionSensor:draw()
  Tablet.draw(self)

  love.graphics.setCanvas(self.canvas)
  Color.WHITE:use()
  love.graphics.draw(map)

    if DEBUG then
      Color.WHITE:use()
      WALK_GRAPH:eachNode(function(_, point)
        love.graphics.circle('fill', point.x, point.y, 2)
      end)

      love.graphics.setLineWidth(1)
      WALK_GRAPH:eachEdge(function(_, _, start, end_p, _)
        love.graphics.line(start.x, start.y, end_p.x, end_p.y)
      end)

      Color.BLUE:use()
      local line = {}
      lume.each(WALK_GRAPH.leftRunawayPath, function(n)
        local pos = WALK_GRAPH:getNodeData(n)
        table.insert(line, pos.x)
        table.insert(line, pos.y)
      end)
      love.graphics.line(unpack(line))

      local line = {}
      lume.each(WALK_GRAPH.rightRunawayPath, function(n)
        local pos = WALK_GRAPH:getNodeData(n)
        table.insert(line, pos.x)
        table.insert(line, pos.y)
      end)
      love.graphics.line(unpack(line))

      Color.RED:use()
      lume.each(self.monsters, function(monster)
        love.graphics.circle('fill', monster.pos.x, monster.pos.y, 5)
      end)
    end

  lume.each(self.dots, function(dot)
    love.graphics.setColor(0, 1, 0, 1 - dot.lifetime / Tablet.DOT_LIFETIME)
    love.graphics.circle('fill', dot.pos.x, dot.pos.y, 5)
  end)

  Color.GREEN:use()
  love.graphics.polygon('fill', 338, 406, 338 + 8, 420, 338 - 8, 420)

  self:drawMotion(true)

  if HEATING_ENABLED then
    self:drawHeating(false)
  end

  love.graphics.setCanvas()
end

function MotionSensor:update(dt)
  Tablet.update(self, dt)

  if love.timer.getTime() - self.switchTime > SCAN_MIN_WAIT then
    if love.timer.getTime() > self.nextScanTime then
      self:gotoState('Scanning')
      self.nextScanTime = love.timer.getTime() + Tablet.SCAN_PERIOD + Tablet.SCAN_DURATION
    end
  end

  if HEATING_ENABLED and self.gameScene:isForward() and self.gameScene.controls.toggleMode:pressed() then
    self:gotoState('Heating')
    Tablet.toggleSound:clone():play()
  end
end
