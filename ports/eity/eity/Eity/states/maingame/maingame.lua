require 'states/maingame/maingame_UI'
require 'states/maingame/arrow'
require 'states/maingame/slider'
require 'states/maingame/player'

Maingame = {}

local scaleX, scaleY

function Maingame:load()
  maingame_UI:load()
  nextNote = 1
  endTime = 0
  mapNotes = {}
  scaleX, scaleY = gameManager:getImageScaleForNewDimensions(img, gw, gh)
end

function Maingame:update(dt)
  maingame_UI:update(dt)
  
  if modManager.isAuto then
    auto.ApplyMod(mapNotes)
  end
  
  if gameManager.pause or gameManager.isFailed then
     mapSong:pause() 
     love.mouse.setVisible(true) 
   end
  
  if not gameManager.pause and not gameManager.isFailed then
    love.mouse.setVisible(false)
    player:update(dt) 
    mapSong:setPitch(modManager.getSpeed())
    mapSong:play()
    gameManager.gametime = gameManager.gametime + dt * modManager.getSpeed()
    
    for i, v in ipairs(mapNotes) do
      if (#mapNotes >= nextNote and (mapNotes[nextNote][5] - 400) * 0.001 < gameManager.gametime) then
        if (mapNotes[nextNote][4] == 0) then
          createArrow(mapNotes[nextNote][1], math.ceil(mapNotes[nextNote][2] * 4 / 512), mapNotes[nextNote][3] * modManager.getSpeed())    
        elseif (mapNotes[nextNote][4] ~= 0) then
          createSlider(mapNotes[nextNote][1], math.ceil(mapNotes[nextNote][2] * 4 / 512), mapNotes[nextNote][3] * modManager.getSpeed(), mapNotes[nextNote][4])
        end
        nextNote = nextNote + 1
      end
    end

    
    Arrow:update(dt)
    Slider:update(dt)
    
  if #mapNotes < scoreManager.destroyedArrows + 1 then
    if endTime < 2 then          
      endTime = endTime + dt * modManager.getSpeed()
    else
      if scoreManager.combo > scoreManager.maxCombo then scoreManager.maxCombo = scoreManager.combo end
      scoreManager.CalculateTotalNotes()
      mapSong:stop()
      endTime = 0
      love.mouse.setVisible(true)
      stateManager.GameState = "Rankingscreen"
      if (saveManager.highscores.mapScore[mapList.getSelectedMapIndex()] < scoreManager.score) then
        scoreManager.setHighScore()
      end
    end
  end
    
    
    if modManager.isNoFail or modManager.isAuto then
      gameManager.health = 100
      xbar = gw * 0.35
    end
    if modManager.isHidden then
    hidden.ApplyMod(dt)
    elseif modManager.isFlashlight then
      flashlight.ApplyMod(dt)
    end
  end
end

function Maingame:gamepadpressed(joystick, button)
  if gameManager.pause then
    if button == "y" then
      gameManager.pause = false
    elseif button == "b" then
      gameManager.Restart()
    elseif button == "a" then
      stateManager.GameState = "Mainmenu"
    end
  else
    if button == "dpleft" or button == "x" then
      player.direction = "left"
    elseif button == "dpright" or button == "b" then
      player.direction = "right"
    end

    if button == "dpup" or button == "y" then
      player.direction = "up"
    elseif button == "dpdown" or button == "a" then
      player.direction = "down"
    end  
  end
  if button == "start" then
    gameManager.Pause()
  end
end

function Maingame:draw()
  love.graphics.draw(img, 0, 0, 0, scaleX, scaleY)
  love.graphics.setColor(0.3, 0.3, 0.3, gameManager.backgroundDim)
  love.graphics.rectangle('fill', 0, 0, gw, gh)
  Arrow:draw()
  Slider:draw()
  maingame_UI:draw()
  
  love.graphics.setFont(defaultFont)
  --love.graphics.print(gameManager.gametime, 0, 60)
end

function Maingame:mousepressed(x, y,button)
  maingame_UI:mousepressed(x, y,button)
end

function Maingame:keypressed(key)
  
  if key == "escape" and not gameManager.isFailed then
    gameManager.Pause()
  end
  
  if key == "r" then
    gameManager.Restart()
  end
  
  if key == "tab" then
    isEnabledUI = not isEnabledUI
  end
  
  
  
  if not gameManager.pause or not gameManager.isFailed then
    player:keypressed(key)
  end
end 

return Maingame
