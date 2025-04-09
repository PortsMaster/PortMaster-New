local Intro = class('Intro', Scene)

local AM = require 'src.scenes.am'

local TIME_PER_LINE = 5
local START_TIME = 1

function Intro:initialize()
  Scene.initialize(self)
  self.alphas = {0, 0, 0}
  self.timer:after(START_TIME, function()
    self.timer:tween(1, self.alphas, {[1] = 1}, 'linear')
  end)

  self.timer:after(START_TIME + TIME_PER_LINE, function()
    self.timer:tween(1, self.alphas, {[2] = 1}, 'linear')
  end)

  self.timer:after(START_TIME + 2 * TIME_PER_LINE, function()
    self.timer:tween(1, self.alphas, {[3] = 1}, 'linear')
  end)

  self.timer:after(START_TIME + 3 * TIME_PER_LINE + 2, function()
    self.timer:tween(1, self.alphas, {[1] = 0, [2] = 0, [3] = 0}, 'linear', function()
      Scene.switchTo(AM(1, function()
        Scene.switchTo(GameScene(1))
      end))
    end)
  end)

  self:resize()
end

function Intro:resize()
  self.font = love.graphics.newFont("assets/ui/digital-font.ttf", self:calculateUIScale() * 30)
end

function Intro:draw()
  Scene.draw(self)
  love.graphics.setFont(self.font)

  local uiScale = self:calculateUIScale()

  love.graphics.setColor(0, 1, 0, self.alphas[1])
  love.graphics.printf("You are part of a mining expedition sent to the remote planet of Midas C.",
    0, 0.4 * love.graphics.getHeight(), love.graphics.getWidth(), "center")

  love.graphics.setColor(0, 1, 0, self.alphas[2])
  love.graphics.printf("Upon reaching orbit, several of the crew fall mysteriously ill and die.", 0, 0.4 * love.graphics.getHeight() + uiScale * 40, love.graphics.getWidth(), "center")

  love.graphics.setColor(0, 1, 0, self.alphas[3])
  love.graphics.printf("Three days later, creatures emerge from the bodies stored in the morgue...", 0, 0.4 * love.graphics.getHeight() + uiScale * 80, love.graphics.getWidth(), "center")
end

function Intro:update(dt)
  Scene.update(self, dt)
end

return Intro
