local Ending = class('Ending', Scene)
local MainMenu = require 'src.scenes.mainmenu'
local save = require 'src.save'

function Ending:initialize(hour, next)
  Scene.initialize(self)
  self.video = love.graphics.newVideo('assets/graphics/ending.ogv', {audio = true})
  self.video:play()
  self.timer:after(13, function()
    Scene.switchTo(MainMenu())
  end)
end

function Ending:enter()
  save.data.hour = nil
  save.data.completed = true
  save.save()
end

function Ending:draw()
  Scene.draw(self)

  love.graphics.push()
  Color.WHITE:use()
  GameScene.scaling(self)
  love.graphics.draw(self.video)
  love.graphics.pop()
end

return Ending
