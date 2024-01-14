local GameOver = class('GameOver', Scene)

local MainMenu = require 'src.scenes.mainmenu'

function GameOver:initialize()
  Scene.initialize(self)
  self.timer:after(4, function()
    Scene.switchTo(MainMenu())
  end)
end

return GameOver
