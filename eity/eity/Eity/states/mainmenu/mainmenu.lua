require 'states/mainmenu/options'
require 'states/mainmenu/songselect'
require 'states/mainmenu/mainmenu_Particles'
require 'objects/squareButton'

Mainmenu = {}

local scaleX, scaleY

local noButton, yesButton, eityButton, playButton, optionsButton, exitButton

function Mainmenu:load()
  Songselect:load()
  Options:load()
  menustate = "Startmenu"
  
  Mainmenu_Particles:load()
  mainBG = love.graphics.newImage("assets/MainBG3.jpg")
  scaleX, scaleY = gameManager:getImageScaleForNewDimensions( mainBG, gw, gh )
  
  noButton = newSquareButton(gw / 2 - 150, gh / 2 + 200, 75, "No", Red, White, 0, -25, function() PressedQuit = false end)
  yesButton = newSquareButton(gw / 2 + 150, gh / 2 + 200, 75, "Yes", Blue, White, 0, -25, function() love.event.quit() end)
  eityButton = newSquareButton(gw / 2 - 270, gh / 2, 220, "Eity", Blue, White, 0, -75)
  playButton = newSquareButton(gw / 2 + 50, gh / 2 - 200, 120, "Play", Green, White, 0, -25, function() menustate = "Songselect" psystem:reset() end)
  optionsButton = newSquareButton(gw / 2 + 250, gh / 2, 120, "Options", Purple, White, 0, -25, function() menustate = "Options" end)
  exitButton = newSquareButton(gw / 2 + 50, gh / 2 + 200, 120, "Exit", Red, White, 0, -25, function() PressedQuit = true end)
    
  PressedQuit = false
end


function Mainmenu:gamepadpressed(joystick, button)
  if menustate == "Startmenu" and not PressedQuit then
    if button == "y" then
      menustate = "Songselect" 
      psystem:reset()
    elseif button == "b" then
      menustate = "Options"
    elseif button == "a" then
      PressedQuit = true
    end
  elseif menustate == "Startmenu" and PressedQuit then
    if button == "a" then
      love.event.quit()
    else
      PressedQuit = false
    end
  elseif menustate == "Options" then
    if button == "a" then
      menustate = "Startmenu"
    end
  elseif menustate == "Songselect" and not isMods then
    if button == "a" then
      gameManager.RestartNewMap()
    elseif button == "x" then
      mapList.PickRandomMapIndex()
    elseif button == "b" then
      menustate = "Startmenu"
    elseif button == "dpup" or button == "dpleft" then
      mapList.mapListUp()
    elseif button == "dpdown" or button == "dpright" then
      mapList.mapListDown()
    end
  end
end

function Mainmenu:update(dt)
  noButton:update(dt)
  yesButton:update(dt)
  if menustate == "Startmenu" and not PressedQuit then
    soundManager.mainmenusrc:play()
    Mainmenu_Particles:update(dt)
    playButton:update(dt)
    optionsButton:update(dt)
    exitButton:update(dt)
  elseif menustate == "Options" then
    Options:update(dt)
  elseif menustate == "Songselect" then
    Songselect:update(dt)
    soundManager.mainmenusrc:stop()
  end                        
end

function Mainmenu:draw()
  if menustate == "Startmenu" or menustate == "Options" then
    love.graphics.draw(mainBG, 0, 0, 0, 1, 1)
    love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
    love.graphics.rectangle('fill', 0, 0, gw, gh)
  end
  if menustate == "Startmenu" then
    menu_UI()
  elseif menustate == "Options" then
    Options:draw()
  elseif menustate == "Songselect" then
    Songselect:draw()
  end
end

function menu_UI()
  love.graphics.setColor(1, 1, 1, 1)
  Mainmenu_Particles:draw()
  
  DrawMainButtons()
  if PressedQuit then
    DrawAreYouSureQuit()
  end
end

function Mainmenu:keypressed(key)
  if menustate == "Songselect" then
    if key == "escape" and not isMods and not isModes then
      menustate = "Startmenu"
    end
    Songselect:keypressed(key)
  elseif key == "escape" and menustate == "Startmenu" then
    PressedQuit = true
  elseif key == "escape" and menustate == "Options" then
    saveManager:saveSettings()
    menustate = "Startmenu"
      if (changedResolution) then
        changedResolution = false
        simpleScale.updateWindow(resolutionList[saveManager.settings.resolutionIndex][1], resolutionList[saveManager.settings.resolutionIndex][2])
      end
  end
end

function Mainmenu:mousepressed(x, y, button)
  if menustate == "Options" then
     Options:mousepressed(x, y, button)  
 elseif menustate == "Songselect" then
     Songselect:mousepressed(x, y, button)
  elseif menustate == "Startmenu" then
    if PressedQuit then
      noButton:mousepressed(x, y, button)
      yesButton:mousepressed(x, y, button)
    else
      playButton:mousepressed(x, y, button)
      optionsButton:mousepressed(x, y, button)
      exitButton:mousepressed(x, y, button)
    end
   end  
end

function DrawAreYouSureQuit()
  love.graphics.setColor(0, 0, 0, 0.9)
  love.graphics.rectangle('fill', 0, 0, gw, gh)
  
  love.graphics.setFont(squareButtonBigFont)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf("Are you sure you want to exit?", gw / 2 - 500, gh / 2 - 300, 1000, "center")
  
  love.graphics.setLineWidth(60)
  love.graphics.setFont(squareButtonsmallFont)  
  noButton:draw()
  yesButton:draw()
end


function DrawMainButtons()    
  love.graphics.setLineWidth(90)
  love.graphics.setFont(squareButtonBigFont)
  eityButton:draw()
  love.graphics.setLineWidth(60)
  love.graphics.setFont(squareButtonsmallFont)
  playButton:draw()
  optionsButton:draw()
  exitButton:draw()
end

return Mainmenu
