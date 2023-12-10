local Crashed = Tablet:addState('Crashed')
local crash = love.audio.newSource('assets/sound/crash.wav', 'static')

local RESET_DURATION = 6

function Crashed:enteredState()
  crash:play()
  self.resetting = false
  self.gameScene.timer:after(2, function()
    crash:play()
    self.resetting = true
    self.resetTime = 0
  end)
end

function Crashed:draw()
  Tablet.draw(self)

  love.graphics.setCanvas(self.canvas)
  Color.GREEN:use()
  love.graphics.setFont(Tablet.CLOCK_FONT)
  love.graphics.printf("SYSTEM CRASHED", 0, Tablet.CANVAS_SIZE.y / 2 - 25 - 50, Tablet.CANVAS_SIZE.x, "center")
  if self.resetting then
    love.graphics.printf("Resetting...", 0, Tablet.CANVAS_SIZE.y / 2 - 25, Tablet.CANVAS_SIZE.x, "center")

    local barW = Tablet.CANVAS_SIZE.x / 2
    love.graphics.rectangle('line', Tablet.CANVAS_SIZE.x / 2 - Tablet.CANVAS_SIZE.x / 4, 300, barW, 50)
    love.graphics.rectangle('fill', Tablet.CANVAS_SIZE.x / 2 - Tablet.CANVAS_SIZE.x / 4, 300, barW * (self.resetTime / RESET_DURATION), 50)
  end
  love.graphics.setCanvas()
end

function Crashed:update(dt)
  Tablet.update(self, dt)

  if self.resetting then
    self.resetTime = self.resetTime + dt

    if self.resetTime > RESET_DURATION then
      crash:play()
      self:gotoState('MotionSensor')
      self:setupCrashTimer()
    end
  end
end
