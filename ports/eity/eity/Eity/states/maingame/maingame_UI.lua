require 'objects/squareButton'
require 'states/maingame/player'

maingame_UI = {}

local bigFont
local xScale
local pausedButton, continueButton, quitButton, restartButton, failedButton


function maingame_UI:load()
  bigFont = love.graphics.newFont("assets/roboto.ttf", 92)
  xbar = 0
  isEnabledUI = true
  failedButton = newSquareButton(gw / 2 - 270, gh / 2, 220, "Failed", Blue, White, 0, -50)
  pausedButton = newSquareButton(gw / 2 - 270, gh / 2, 220, "Paused", Blue, White, 0, -50)
  
  restartButton = newSquareButton(gw / 2 + 250, gh / 2, 120, "Restart", Purple, White, 0, -25, function() gameManager.Restart() end)
  quitButton = newSquareButton(gw / 2 + 50, gh / 2 + 200, 120, "Quit", Red, White, 0, -25, function() stateManager.GameState = "Mainmenu" end)  
  continueButton = newSquareButton(gw / 2 + 50, gh / 2 - 200, 120, "Continue", Green, White, 0, -25, function() gameManager.Pause() end)
end


function maingame_UI:update(dt)
  restartButton:update(dt)
  quitButton:update(dt)
  continueButton:update(dt)
  
  if gameManager.health > 0 then
    xScale = gw * 0.35 * gameManager.health / 100
  else
    xScale = 20
  end
  if xbar <= xScale then
    xbar = xbar + (dt * 170)
  elseif xbar >= xScale then
    xbar = xbar - (dt * 400)
  end
end



function maingame_UI:draw()
  MaingameOverlay()
  if (isEnabledUI) then
    Healthbar()
    scoreManager:draw()
  end
  player:draw()
  if gameManager.pause then
    PauseScreen()
  elseif gameManager.isFailed then
    FailScreen()
  end
end

function maingame_UI:mousepressed(x, y, button)                          
                          
   if gameManager.pause then
     continueButton:mousepressed(x, y, button) 
     restartButton:mousepressed(x, y, button)     
     quitButton:mousepressed(x, y, button) 
   elseif gameManager.isFailed then
     restartButton:mousepressed(x, y, button)     
     quitButton:mousepressed(x, y, button) 
   end
end



function Healthbar()
  love.graphics.setColor(0.6, 0.6, 0.6, 1)
  love.graphics.rectangle("fill", 10, 10, gw * 0.35 + 1, 30)
  love.graphics.setColor(0.3, 0.3, 0.3, 1)
  love.graphics.rectangle("fill", 15, 15, gw * 0.35 - 10, 20)
  love.graphics.setColor(0.95, 0.95, 0.95, 1)
  love.graphics.rectangle("fill", 20, 20, xbar - 20, 10)
  love.graphics.setColor(0.3, 0.3, 0.3, 1)
end

function FailScreen()
  love.graphics.setColor(0, 0, 0, 0.6)
  love.graphics.rectangle('fill', 0, 0, gw, gh)  
  love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
  love.graphics.rectangle('fill', 0, 0, gw, gh)
    
  love.graphics.setLineWidth(90)
  love.graphics.setFont(bigFont)  
  failedButton:draw()
  love.graphics.setLineWidth(60)
  love.graphics.setFont(squareButtonsmallFont)  
  restartButton:draw()
  quitButton:draw()
end


function PauseScreen()
  love.graphics.setColor(0, 0, 0, 0.6)
  love.graphics.rectangle('fill', 0, 0, gw, gh)  
  love.graphics.setColor(0.1, 0.1, 0.1, 0.5)
  love.graphics.rectangle('fill', 0, 0, gw, gh)
    
  love.graphics.setLineWidth(90)
  love.graphics.setFont(bigFont)
  pausedButton:draw()
  love.graphics.setLineWidth(60)
  love.graphics.setFont(squareButtonsmallFont)
  restartButton:draw()
  continueButton:draw()
  quitButton:draw()
end

function MaingameOverlay()
  love.graphics.setLineWidth(700)
  love.graphics.setColor(0.1, 0.1, 0.1, 1)
  love.graphics.circle("line", gw / 2, gh / 2, gh * 1.05, 4)
  love.graphics.circle("fill", gw / 2, gh / 2, gh * 0.1, 4)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setLineWidth(18)
  love.graphics.circle("line", gw / 2, gh / 2, gh * 0.1, 4)
  love.graphics.setLineWidth(112)
  love.graphics.circle("line", gw / 2, gh / 2, gh * 0.55, 4)
end

return maingame_UI
