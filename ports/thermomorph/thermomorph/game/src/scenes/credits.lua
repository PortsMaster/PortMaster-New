local Credits = class('Credits', Scene)

local creditstext, _ = love.filesystem.read('credits.txt')

function Credits:initialize()
  Scene.initialize(self)
  self:resize()
end

function Credits:resize()
  local scale = self:calculateUIScale()
  self.myFont = love.graphics.newFont("assets/ui/roboto.ttf", scale * 25)
  self.creditsFont = love.graphics.newFont("assets/ui/roboto.ttf", scale * 15)
end

function Credits:draw()
  Scene.draw(self)

  Color.WHITE:use()
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
  local mw, mh = sw / 2, sh / 2

  local _, wrappedText = self.creditsFont:getWrap(creditstext, sw - 200)
  local lines = #wrappedText
  local height = self.creditsFont:getHeight() * lines

  love.graphics.setFont(self.myFont)
  love.graphics.printf("Created by Varun R.", 100, mh - height / 2 - 50, sw - 200, "center")

  love.graphics.setFont(self.creditsFont)
  love.graphics.printf(creditstext, 100, mh - height / 2 + 25, sw - 200, "center")
end

function Credits:keypressed(key, scancode, isrepeat)
  local MainMenu = require 'src.scenes.mainmenu'
  Scene.switchTo(MainMenu())
end

function Credits:touchreleased(id, x, y, dx, dy, pressure)
  local MainMenu = require 'src.scenes.mainmenu'
  Scene.switchTo(MainMenu())
end

return Credits
