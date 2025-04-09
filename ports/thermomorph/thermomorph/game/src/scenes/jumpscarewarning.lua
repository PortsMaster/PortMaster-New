local JumpScareWarning = class('JumpScareWarning', Scene)


local warning = love.graphics.newImage('assets/graphics/exclamation-triangle.png')

local AM = require 'src.scenes.am'
local MainMenu = require 'src.scenes.mainmenu'

function JumpScareWarning:initialize()
  Scene.initialize(self)
  self.fadingOut = false
  self.alpha = 0

  self.timer:after(3, function() self:next() end)

  self:resize()
end

function JumpScareWarning:resize()
  self.warningFont = love.graphics.newFont("assets/ui/roboto.ttf", self:calculateUIScale() * 30)
end

function JumpScareWarning:update(dt)
  Scene.update(self, dt)
  if self.fadingOut == false then
    self.alpha = self.alpha + dt
    if self.alpha > 1 then self.alpha = 1 end
  end

  if self.fadingOut == true then
    self.alpha = self.alpha - dt
  end
end

function JumpScareWarning:next()
  if not self.fadingOut then
    self.fadingOut = true
    self.timer:after(1, function()
      Scene.switchTo(MainMenu())
    end)
  end
end

function JumpScareWarning:keypressed() self:next() end
function JumpScareWarning:mousepressed() self:next() end
function JumpScareWarning:touchpressed() self:next() end

function JumpScareWarning:draw()
  Scene.draw(self)

  love.graphics.setColor(1, 1, 1, self.alpha)

  local scale = self:calculateUIScale()
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  local mw, mh = sw / 2, sh / 2
  love.graphics.draw(warning, mw - warning:getWidth() * scale / 2, mh - warning:getHeight() * scale, 0, scale, scale)

  love.graphics.setFont(self.warningFont)
  love.graphics.printf("THIS GAME CONTAINS JUMPSCARES", 100, mh + 25, sw - 200, "center")
end

return JumpScareWarning
