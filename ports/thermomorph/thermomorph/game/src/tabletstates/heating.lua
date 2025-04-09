local Heating = Tablet:addState('Heating')

local tempFont = love.graphics.newFont('assets/ui/digital-font.ttf', 100)

function Heating:draw()
  Tablet.draw(self)

  love.graphics.setCanvas(self.canvas)

  self:drawMotion(false)
  self:drawHeating(true)

  Color.GREEN:use()
  love.graphics.setFont(Tablet.CLOCK_FONT)

  local text = "HEAT: OK"
  if self.gameScene.heating:getState() == "malfunction" then
    text = "HEAT: MALFUNCTION"
  elseif self.gameScene.heating:getState() == "off" then
      text = "HEAT: OFF"
  end

  love.graphics.printf(text, 0, Tablet.CANVAS_SIZE.y / 2 - 25 - 25, Tablet.CANVAS_SIZE.x, "center")

  love.graphics.setFont(tempFont)
  love.graphics.printf(string.format("%.1f", self.gameScene.heating.temp), 0, Tablet.CANVAS_SIZE.y / 2 - 25 + 25, Tablet.CANVAS_SIZE.x, "center")

  love.graphics.setCanvas()
end

function Heating:canResetHeat()
  return self.gameScene.heating:getState() == "malfunction" or self.gameScene.heating:getState() == "off"
end

function Heating:update(dt)
  Tablet.update(self, dt)

  if self.gameScene:isForward() and self.gameScene.controls.toggleMode:pressed() then
    self:gotoState('MotionSensor')
    Tablet.toggleSound:clone():play()
  end

  if self:canResetHeat() and self.gameScene.controls.heatReset:pressed() then
    self.gameScene.heating:startFixing()
    self:gotoState('HeatReset')
    Tablet.toggleSound:clone():play()
  end
end
