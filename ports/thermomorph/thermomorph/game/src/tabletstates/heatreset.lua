local HeatReset = Tablet:addState('HeatReset')

local RESET_DURATION = 5

function HeatReset:enteredState()
  self.resetTime = 0
end

function HeatReset:draw()
  Tablet.draw(self)

  love.graphics.setCanvas(self.canvas)
  Color.GREEN:use()
  love.graphics.setFont(Tablet.CLOCK_FONT)
  love.graphics.printf("RESETTING HEAT", 0, Tablet.CANVAS_SIZE.y / 2 - 25, Tablet.CANVAS_SIZE.x, "center")

  local barW = Tablet.CANVAS_SIZE.x / 2
  love.graphics.rectangle('line', Tablet.CANVAS_SIZE.x / 2 - Tablet.CANVAS_SIZE.x / 4, 280, barW, 50)
  love.graphics.rectangle('fill', Tablet.CANVAS_SIZE.x / 2 - Tablet.CANVAS_SIZE.x / 4, 280, barW * (self.resetTime / RESET_DURATION), 50)

  love.graphics.setCanvas()
end

function HeatReset:canCrash() return false end

function HeatReset:update(dt)
  Tablet.update(self, dt)

  self.resetTime = self.resetTime + dt
  if self.resetTime > RESET_DURATION then
    self.gameScene.heating:gotoState('Working')
    Tablet.toggleSound:play()
    self:gotoState('Heating')
  end
end
