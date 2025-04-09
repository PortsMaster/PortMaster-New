require 'states/maingame/maingame'
require 'states/mainmenu/mainmenu'
require 'states/rankingscreen'

stateManager = {}

function stateManager:load()
  stateManager.GameState = "Mainmenu" -- Mainmenu, Maingame, Rankingscreen
  stateManager.GameModeState = "Rush" -- Rush, Catch
  

    Mainmenu:load()
    Maingame:load()
    Rankingscreen:load()

end

function stateManager:gamepadpressed(joystick, button)
  if (stateManager.GameState == "Mainmenu") then
    Mainmenu:gamepadpressed(joystick, button)
  elseif (stateManager.GameState == "Maingame") then
    Maingame:gamepadpressed(joystick, button)
  elseif (stateManager.GameState == "Rankingscreen") then
    Rankingscreen:gamepadpressed(joystick, button)
  end
end

function stateManager:draw()
  if (stateManager.GameState == "Mainmenu") then
    Mainmenu:draw()
  elseif (stateManager.GameState == "Maingame") then
    love.graphics.setFont(defaultFont)
    Maingame:draw()
  elseif (stateManager.GameState == "Rankingscreen") then
    Rankingscreen:draw()
  end
end

function stateManager:update(dt)
  if (stateManager.GameState == "Mainmenu") then
    Mainmenu:update(dt)
  elseif (stateManager.GameState == "Maingame") then
    Maingame:update(dt)
  elseif (stateManager.GameState == "Rankingscreen") then
    Rankingscreen:update(dt)
  end
end


function stateManager:mousepressed(x, y, button)
  if (stateManager.GameState == "Mainmenu") then
    Mainmenu:mousepressed(x, y, button)
  elseif (stateManager.GameState == "Maingame") then
    Maingame:mousepressed(x, y, button)
  elseif (stateManager.GameState == "Rankingscreen") then
    Rankingscreen:mousepressed(x, y, button)
  end
end

function stateManager:keypressed(key)
  if (stateManager.GameState == "Maingame") then
    Maingame:keypressed(key)
  elseif (stateManager.GameState == "Mainmenu") then
    Mainmenu:keypressed(key)
  elseif (stateManager.GameState == "Rankingscreen") then
    Rankingscreen:keypressed(key)
  end
end

return stateManager
