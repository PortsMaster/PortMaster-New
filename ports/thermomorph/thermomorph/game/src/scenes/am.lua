local AM = class('AM', Scene)


local alarm = love.audio.newSource('assets/sound/alarm.wav', 'static')

local save = require 'src.save'

function AM:initialize(hour, next)
  Scene.initialize(self)
  self.hour = hour
  self.timer:after(6, next)
  self.timer:after(3, function()
    self.showSaved = true
  end)

  self:resize()
end

function AM:enter()
  alarm:play()
  save.data.hour = self.hour
  save.save()
end

function AM:resize()
  local uiScale = self:calculateUIScale()
  self.digitalFont = love.graphics.newFont('assets/ui/digital-font.ttf', uiScale * 80)
  self.progressFont = love.graphics.newFont('assets/ui/digital-font.ttf', uiScale * 40)
end

function AM:draw()
  Scene.draw(self)

  Color.GREEN:use()
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  local mw, mh = sw / 2, sh / 2
  love.graphics.setFont(self.digitalFont)
  love.graphics.printf(self.hour .. ":00 AM", 0, mh - 40, sw, "center")

  love.graphics.setFont(self.progressFont)

  if self.showSaved then
    love.graphics.printf("Progress saved...", 0, sh - self.progressFont:getHeight() * 2 - 5, sw - 10, "right")
  end
end

return AM
