require 'objects/button'
require 'objects/mapList'

Songselect = {}

local bigFont, smallFont, smallestFont

local playButton, backButton, randomButton, modsButton
local modsHiddenButton, modsHalfSpeedButton, modsDoubleSpeedButton, modsHiddenButton, modsFlashlightButton, modsNoFailButton, modsAutoButton


function Songselect:load()
  mapList:load(mapManager.getListOfMaps())
  img = gameManager:setBackground()
  scaleX, scaleY = gameManager:getImageScaleForNewDimensions( img, gw, gh )
  bigFont = love.graphics.newFont("assets/roboto.ttf", 84)
  scoreFont = love.graphics.newFont("assets/roboto.ttf", 42)
  smallFont = love.graphics.newFont("assets/roboto.ttf", 24)
  smallestFont = love.graphics.newFont("assets/roboto.ttf", 18)
  
  backButton = newButton(50, gh * 0.94, 150, 50, 10, "Back", GrayOpacity6, Green, Blue, "center", 0, 10, function() menustate = "Startmenu" end)
  modsButton = newButton(gw - 600, gh * 0.94, 150, 50, 10, "Mods", GrayOpacity6, Green, Blue, "center", 0, 10, function() isMods = true end)
  randomButton = newButton(gw - 400, gh * 0.94, 150, 50, 10, "Random", GrayOpacity6, Green, Blue, "center", 0, 10, function() mapList.PickRandomMapIndex() end)
  playButton = newButton(gw - 200, gh * 0.94, 150, 50, 10, "Play", GrayOpacity6, Green, Blue, "center", 0, 10, function() gameManager.RestartNewMap() end)
  
  modsHalfSpeedButton = newButton(gw * 0.4, gh * 0.4, 150, 50, 10, "0.75x speed", GrayOpacity6, Red, Green, "center", 0, 10, function() enableHalfTimeMod() end, true)
  modsDoubleSpeedButton = newButton(gw * 0.52, gh * 0.4, 150, 50, 10, "1.25x speed", GrayOpacity6, Red, Green, "center", 0, 10, function() enableDoubleTimeMod() end, true)
  modsHiddenButton = newButton(gw * 0.4, gh * 0.5, 150, 50, 10, "Hidden", GrayOpacity6, Red, Green, "center", 0, 10, function() enableHiddenMod() end, true)
  modsFlashlightButton = newButton(gw * 0.52, gh * 0.5, 150, 50, 10, "Flashlight", GrayOpacity6, Red, Green, "center", 0, 10, function() enableFlashlightMod() end, true)
  modsNoFailButton = newButton(gw * 0.4, gh * 0.6, 150, 50, 10, "No Fail", GrayOpacity6, Red, Green, "center", 0, 10, function() enableNoFailMod() end, true)
  modsAutoButton = newButton(gw * 0.52, gh * 0.6, 150, 50, 10, "Auto", GrayOpacity6, Red, Green, "center", 0, 10, function() enableAutoMod() end, true)
  modsbackButton = newButton(gw * 0.46, gh * 0.7, gw * 0.08, 50, 10, "Back", GrayOpacity6, White, White, "center", 0, 10, function() isMods = false end)
  
end

function Songselect:update(dt)
  if not isMods then
    backButton:update(dt)
    modsButton:update(dt)
    randomButton:update(dt)
    playButton:update(dt)      
  elseif isMods then    
    modsHalfSpeedButton:update(dt)        
    modsDoubleSpeedButton:update(dt)   
    modsHiddenButton:update(dt)   
    modsFlashlightButton:update(dt)   
    modsNoFailButton:update(dt)   
    modsAutoButton:update(dt)   
    modsbackButton:update(dt)   
  end  
end

function Songselect:draw()
  Background()  
  if not isMods then
    mapList:draw()    
    BottomBar()
    TopBar()
  elseif isMods then
    Mods()
  end
end

function Songselect:keypressed(key)
  if key == "escape" and isMods then
    isMods = false
  elseif (key == "up" and not isMods) or (key == "left" and not isMods) then
    mapList.mapListUp()
  elseif (key == "down" and not isMods) or (key == "right" and not isMods) then
    mapList.mapListDown()
  elseif key == "return" and not isMods then
    gameManager.RestartNewMap()
  end
end

function Songselect:mousepressed(x, y, button)
  if not isMods then       
    mapList:mousepressed(x, y, button)                                                  
    backButton:mousepressed(x, y, button)
    modsButton:mousepressed(x, y, button)
    randomButton:mousepressed(x, y, button)
    playButton:mousepressed(x, y, button)    
  elseif isMods then 
    modsHalfSpeedButton:mousepressed(x, y, button)        
    modsDoubleSpeedButton:mousepressed(x, y, button)
    modsHiddenButton:mousepressed(x, y, button)  
    modsFlashlightButton:mousepressed(x, y, button)
    modsNoFailButton:mousepressed(x, y, button) 
    modsAutoButton:mousepressed(x, y, button)
    modsbackButton:mousepressed(x, y, button)
  end
end

function enableHalfTimeMod()
  if modManager.isDoubleSpeed == true then
    modManager.isDoubleSpeed = false
    modManager.SetSpeed(1.0)
    modsDoubleSpeedButton:setNormalOutlineColor()
  end
  if modManager.isHalfSpeed == false then
    modManager.isHalfSpeed = true
    modManager.SetSpeed(halfSpeed.ApplyMod())
    modsHalfSpeedButton:setHighlightOutlineColor()
  else
    modManager.isHalfSpeed = false
    modManager.SetSpeed(1.0)
    modsHalfSpeedButton:setNormalOutlineColor()
  end
end

function enableDoubleTimeMod()
  if modManager.isHalfSpeed == true then
    modManager.isHalfSpeed = false
    modManager.SetSpeed(1.0)
    modsHalfSpeedButton:setNormalOutlineColor()
  end
  if modManager.isDoubleSpeed == false then
    modManager.isDoubleSpeed = true
    modManager.SetSpeed(doubleSpeed.ApplyMod())
    modsDoubleSpeedButton:setHighlightOutlineColor()
  else
    modManager.isDoubleSpeed = false
    modManager.SetSpeed(1.0)
    modsDoubleSpeedButton:setNormalOutlineColor()
  end
end

function enableHiddenMod()
  if modManager.isHidden == false then
    modManager.isHidden = true
    modsHiddenButton:setHighlightOutlineColor()
  else
    modManager.isHidden = false
    modsHiddenButton:setNormalOutlineColor()
  end
end

function enableFlashlightMod()
  if modManager.isFlashlight == false then
    modManager.isFlashlight = true
    modsFlashlightButton:setHighlightOutlineColor()
  else
    modManager.isFlashlight = false
    modsFlashlightButton:setNormalOutlineColor()
  end
end

function enableNoFailMod()
  if modManager.isAuto == true then
    modManager.isAuto = false
    modsAutoButton:setNormalOutlineColor()
  end
  if modManager.isNoFail == false then
    modManager.isNoFail = true
    modsNoFailButton:setHighlightOutlineColor()
  else
    modManager.isNoFail = false
    modsNoFailButton:setNormalOutlineColor()
  end
end

function enableAutoMod()
  if modManager.isNoFail == true then
    modManager.isNoFail = false
    modsNoFailButton:setNormalOutlineColor()
  end
  if modManager.isAuto == false then
    modManager.isAuto = true
    modsAutoButton:setHighlightOutlineColor()
  else
    modManager.isAuto = false
    modsAutoButton:setNormalOutlineColor()
  end
end

function BottomBar()
  love.graphics.setFont(smallFont)
  love.graphics.setLineWidth(3)  
  love.graphics.setColor(0,0,0,1)
  love.graphics.rectangle('fill', 0, gh * 0.92, gw, gh * 0.08)
  love.graphics.setColor(White)
  love.graphics.line(0, gh * 0.92, gw, gh * 0.92)
  
  backButton:draw()
  modsButton:draw()
  randomButton:draw()
  playButton:draw()
end

function TopBar()
  love.graphics.setFont(smallFont)
  love.graphics.setLineWidth(3)  
  love.graphics.setColor(0,0,0,1)
  love.graphics.rectangle('fill', 0, gh * 0.0, gw, gh * 0.08)
  love.graphics.setColor(White)
  love.graphics.line(0, gh * 0.08, gw, gh * 0.08)

  love.graphics.printf(mapManager.getTitleOfIndex(mapList.getSelectedMapIndex()) .. " - " ..
                      mapManager.getPorterOfIndex(mapList.getSelectedMapIndex()) ..
                      " [" .. mapManager.getDifficultOfIndex(mapList.getSelectedMapIndex()) .. "]", 15, 10, 700, "left")
  love.graphics.printf("Length: " ..
                         math.floor(mapManager.getLengthOfIndex(mapList.getSelectedMapIndex()) / modManager.getSpeed() / 60) .. ":" .. 
                         string.format("%02d", math.floor(mapManager.getLengthOfIndex(mapList.getSelectedMapIndex()) / modManager.getSpeed() % 60))
                         , 15, 40, 700, "left")
  love.graphics.setFont(scoreFont)
  love.graphics.printf("Highscore " .. string.format("%08d", saveManager.highscores.mapScore[mapList.getSelectedMapIndex()]), 0, 20, gw, "center")
end

function Mods()
  love.graphics.setColor(0, 0, 0, 0.8)
  love.graphics.rectangle('fill', 0, 0, gw, gh)
  
  love.graphics.setFont(bigFont)  
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf("Mods", 0, gh * 0.22, gw, "center") 
  love.graphics.setFont(smallFont)
  love.graphics.printf("Score Multiplier: " .. string.format("%0.2f", scoreManager.modMultiplier) .. "x", 0, gh * 0.33, gw, "center") 
  
  modsHalfSpeedButton:draw()
  modsDoubleSpeedButton:draw()
  modsHiddenButton:draw()
  modsFlashlightButton:draw()
  modsNoFailButton:draw()
  modsAutoButton:draw()
  modsbackButton:draw()
end


function Background()
  love.graphics.draw(img, 0, 0, 0, scaleX, scaleY)
  love.graphics.setColor(0.3, 0.3, 0.3, gameManager.backgroundDim)
  love.graphics.rectangle('fill', 0, 0, gw, gh)
end


return Songselect
