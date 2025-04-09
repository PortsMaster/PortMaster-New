require 'objects/cursor'
require 'objects/button'

local effectcircle = require 'objects/effectcircle'
local menuparticles = require 'objects/menuparticles'
local audio = require "lib/wave"

mainmenu = {}

function mainmenu:load()
  menustate = "main"

  buttonhover = audio:newSource("assets/buttonhover.wav", "stream")
  buttonhover:setVolume(volumeValue * 0.001)

  buttonhit = audio:newSource("assets/buttonhit2.wav", "stream")
  buttonhit:setVolume(volumeValue * 0.001)

  menumusic = audio:newSource("songs/Hinkik - Ena.mp3", "stream")
  menumusic:parse()
  menumusic:setIntensity(20)
  menumusic:setBPM(64)
  menumusic:setVolume(volumeValue * 0.001)
  menumusic:setLooping(true)
  menumusic:play()

  menumusic:onBeat(function()
    newCircleEffect(450+menumusic:getEnergy()*10, 190)
  end)

  playButton = newButton(gw/2 - 450-menumusic:getEnergy()*10, gh*0.5, 900, 100, function() menustate = "levels" end)
  optionsButton = newButton(gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 100, 900, 100, function() menustate = "options" end)
  quitButton = newButton(gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 200, 900, 100, function() menustate = "quit" end)

  quitYesButton = newButton(gw/2 - 450-menumusic:getEnergy()*10, gh*0.5, 900, 100, function() love.event.quit() end)
  quitNoButton = newButton(gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 100, 900, 100, function() menustate = "main" end)

  optionsJoystickButton = newButton(gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 - 100, 900, 100, function() isJoystickMove = not isJoystickMove joystickNoticeTextOpacity = 1 end)
  optionsResolutionButton = newButton(gw/2 - 450-menumusic:getEnergy()*10, gh*0.5, 900, 100, function() mainmenu:changeResolution(1) end, function() mainmenu:changeResolution(-1) end)
  optionsVolumeButton = newButton(gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 100, 900, 100, function() mainmenu:changeVolume(5) end, function() mainmenu:changeVolume(-5) end)
  optionsBackButton = newButton(gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 200, 900, 100, function() menustate = "main" mainmenu:saveSettings() end)

  level1Button = newButton(gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 - 20, 900, 140, function() mainmenu:startLevel(1) end)
  level2Button = newButton(gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 120, 900, 120, function() mainmenu:startLevel(2) end)
  level3Button = newButton(gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 240, 900, 120, function() mainmenu:startLevel(3) end)
  level4Button = newButton(gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 360, 900, 120, function() mainmenu:startLevel(4) end)
  level5Button = newButton(gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 480, 900, 120, function() mainmenu:startLevel(5) end)
  level6Button = newButton(gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 600, 900, 120, function() mainmenu:startLevel(6) end)

  levelBackButton = newButton(gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 720, 900, 160, function() menustate = "main" end)
end

function mainmenu:startLevel(levelIndex)
  menumusic:stop()
  effectcircle:clearCircleEffects()
  menuparticles:clearParticles()
  statemanager:changeState("game")
  maingame:loadLevel(levelIndex)
end

function mainmenu:saveSettings()
  savemanager:saveSettings(resolutionIndex, volumeValue)
  if (changedResolution) then
    changedResolution = false
    if resolutionList[resolutionIndex][1] == 0 and resolutionList[resolutionIndex][2] == 0 then
      isFullScreen = true
    else
      isFullScreen = false
    end
    simpleScale.updateWindow(resolutionList[resolutionIndex][1], resolutionList[resolutionIndex][2], {fullscreen=isFullScreen})
  end
end

function mainmenu:update(dt)
  cursor:update(dt)
  effectcircle:update(dt)
  menuparticles:update(dt)
  menumusic:update(dt)

  if (menustate == "main") then
    playButton:update(dt)
    optionsButton:update(dt)
    quitButton:update(dt)
  elseif (menustate == "options") then
    if (joystick ~= nil) then
      optionsJoystickButton:update(dt)
    end
    optionsResolutionButton:update(dt)
    optionsVolumeButton:update(dt)
    optionsBackButton:update(dt)
  elseif (menustate == "quit") then
    quitYesButton:update(dt)
    quitNoButton:update(dt)
  elseif (menustate == "levels") then
    level1Button:update(dt)
    level2Button:update(dt)
    level3Button:update(dt)
    level4Button:update(dt)
    level5Button:update(dt)
    level6Button:update(dt)
    levelBackButton:update(dt)
  end
end

function mainmenu:draw()
  love.graphics.setBackgroundColor(25 / 255, 25 / 255, 25 / 255, 1)
  menuparticles:draw()
  effectcircle:draw()
  love.graphics.setColor(58 / 255, 65 / 255, 81 / 255, 1)
  love.graphics.circle("fill", gw/2, gh/2, 450+menumusic:getEnergy()*10)
  love.graphics.setColor(White)
  if(menustate == "main") then
    mainmenu:mainButtons()
  elseif(menustate == "options") then
    mainmenu:optionsButtons()
  elseif(menustate == "quit") then
    mainmenu:quitButtons()
  elseif(menustate == "levels") then
    mainmenu:levels()
  end

  love.graphics.setLineWidth(5)
  love.graphics.circle("line", gw/2, gh/2, 450+menumusic:getEnergy()*10)
  cursor:draw()
end

function mainmenu:mousepressed(x, y, button)
  if (menustate == "main") then
    playButton:mousepressed(x, y, button)
    optionsButton:mousepressed(x, y, button)
    quitButton:mousepressed(x, y, button)
  elseif (menustate == "options") then
    if (joystick ~= nil) then
      optionsJoystickButton:mousepressed(x, y, button)
    end
    optionsResolutionButton:mousepressed(x, y, button)
    optionsVolumeButton:mousepressed(x, y, button)
    optionsBackButton:mousepressed(x, y, button)
  elseif (menustate == "quit") then
    quitYesButton:mousepressed(x, y, button)
    quitNoButton:mousepressed(x, y, button)
  elseif (menustate == "levels") then
    level1Button:mousepressed(x, y, button)
    level2Button:mousepressed(x, y, button)
    level3Button:mousepressed(x, y, button)
    level4Button:mousepressed(x, y, button)
    level5Button:mousepressed(x, y, button)
    level6Button:mousepressed(x, y, button)
    levelBackButton:mousepressed(x, y, button)
  end
end

function mainmenu:gamepadpressed(joystick, button)
  if (button == "start" or button == "back" or button == "b") then
    if (menustate == "main") then
      menustate = "quit"
    elseif (menustate == "options") then
      menustate = "main"
    elseif (menustate == "levels") then
      menustate = "main"
    end
  end
  if (menustate == "main") then
    playButton:gamepadpressed(joystick, button)
    optionsButton:gamepadpressed(joystick, button)
    quitButton:gamepadpressed(joystick, button)
  elseif (menustate == "options") then
    if (joystick ~= nil) then
      optionsJoystickButton:gamepadpressed(joystick, button)
    end
    optionsResolutionButton:gamepadpressed(joystick, button)
    optionsVolumeButton:gamepadpressed(joystick, button)
    optionsBackButton:gamepadpressed(joystick, button)
  elseif (menustate == "quit") then
    quitYesButton:gamepadpressed(joystick, button)
    quitNoButton:gamepadpressed(joystick, button)
  elseif (menustate == "levels") then
    level1Button:gamepadpressed(joystick, button)
    level2Button:gamepadpressed(joystick, button)
    level3Button:gamepadpressed(joystick, button)
    level4Button:gamepadpressed(joystick, button)
    level5Button:gamepadpressed(joystick, button)
    level6Button:gamepadpressed(joystick, button)
    levelBackButton:gamepadpressed(joystick, button)
  end
end

function mainmenu:keypressed(key)
  if (key == "escape") then
    if (menustate == "main") then
      menustate = "quit"
    elseif (menustate == "options") then
      menustate = "main"
    elseif (menustate == "levels") then
      menustate = "main"
    end
  end
end

function mainmenu:mainButtons()
  love.graphics.setFont(logoFont)
  love.graphics.printf("upo", 0, gh*0.22, gw, "center")

  love.graphics.setFont(titleFont)

  if (playButton:getHoverState()) then
    love.graphics.setColor(Opacity17)
  else
    love.graphics.setColor(Transparent)
  end
  love.graphics.polygon('fill', gw/2 - 450-menumusic:getEnergy()*10, gh*0.5,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.5,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.5 + 100,
                                gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 100)
  love.graphics.setColor(White)
  love.graphics.printf("Play", 0, gh*0.52, gw, "center")

  if (optionsButton:getHoverState()) then
    love.graphics.setColor(Opacity17)
  else
    love.graphics.setColor(Transparent)
  end
  love.graphics.polygon('fill', gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 100,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.5 + 100,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.5 + 200,
                                gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 200)
  love.graphics.setColor(White)
  love.graphics.printf("Options", 0, gh*0.52 + 100, gw, "center")

  if (quitButton:getHoverState()) then
    love.graphics.setColor(Opacity17)
  else
    love.graphics.setColor(Transparent)
  end
  love.graphics.polygon('fill', gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 200,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.5 + 200,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.5 + 300,
                                gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 300)
  love.graphics.setColor(White)
  love.graphics.printf("Quit", 0, gh*0.52 + 200, gw, "center")
end


function mainmenu:optionsButtons()
  love.graphics.setFont(logoFont)
  love.graphics.printf("Options", 0, gh*0.22, gw, "center")

  love.graphics.setFont(titleFont)

  if (joystick ~= nil) then
    if (optionsJoystickButton:getHoverState()) then
      love.graphics.setColor(Opacity17)
    else
      love.graphics.setColor(Transparent)
    end
    love.graphics.polygon('fill', gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 - 100,
                                  gw/2 + 450+menumusic:getEnergy()*10, gh*0.5 - 100,
                                  gw/2 + 450+menumusic:getEnergy()*10, gh*0.5,
                                  gw/2 - 450-menumusic:getEnergy()*10, gh*0.5)
    love.graphics.setColor(White)
    if (isJoystickMove) then
      love.graphics.printf("Disable joystick movement", 0, gh*0.52 - 100, gw, "center")
    else
      love.graphics.printf("Enable joystick movement", 0, gh*0.52 - 100, gw, "center")
    end
  end


  if (optionsResolutionButton:getHoverState()) then
    love.graphics.setColor(Opacity17)
  else
    love.graphics.setColor(Transparent)
  end
  love.graphics.polygon('fill', gw/2 - 450-menumusic:getEnergy()*10, gh*0.5,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.5,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.5 + 100,
                                gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 100)
  love.graphics.setColor(White)
  if resolutionList[resolutionIndex][1] == 0 and resolutionList[resolutionIndex][2] == 0 then
    love.graphics.printf("Resolution: Fullscreen", 0, gh*0.52, gw, "center")
  else
    love.graphics.printf("Resolution: " .. resolutionList[resolutionIndex][1] .. "x" .. resolutionList[resolutionIndex][2], 0, gh*0.52, gw, "center")
  end

  if (optionsVolumeButton:getHoverState()) then
    love.graphics.setColor(Opacity17)
  else
    love.graphics.setColor(Transparent)
  end
  love.graphics.polygon('fill', gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 100,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.5 + 100,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.5 + 200,
                                gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 200)
  love.graphics.setColor(White)
  love.graphics.printf("Volume: " .. volumeValue .."%", 0, gh*0.52 + 100, gw, "center")

  if (optionsBackButton:getHoverState()) then
    love.graphics.setColor(Opacity17)
  else
    love.graphics.setColor(Transparent)
  end
  love.graphics.polygon('fill', gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 200,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.5 + 200,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.5 + 300,
                                gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 300)
  love.graphics.setColor(White)
  love.graphics.printf("Back", 0, gh*0.52 + 200, gw, "center")
end

function mainmenu:quitButtons()
  love.graphics.setFont(titleFont)
  love.graphics.printf("you really want to quit?", gw/2-450, gh*0.25, 450*2, "center")

  if (quitYesButton:getHoverState()) then
    love.graphics.setColor(Opacity17)
  else
    love.graphics.setColor(Transparent)
  end
  love.graphics.polygon('fill', gw/2 - 450-menumusic:getEnergy()*10, gh*0.5,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.5,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.5 + 100,
                                gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 100)
  love.graphics.setColor(White)
  love.graphics.printf("Yes", 0, gh*0.52, gw, "center")

  if (quitNoButton:getHoverState()) then
    love.graphics.setColor(Opacity17)
  else
    love.graphics.setColor(Transparent)
  end
  love.graphics.polygon('fill', gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 100,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.5 + 100,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.5 + 200,
                                gw/2 - 450-menumusic:getEnergy()*10, gh*0.5 + 200)
  love.graphics.setColor(White)
  love.graphics.printf("No", 0, gh*0.52 + 100, gw, "center")
end

function mainmenu:levels()
  love.graphics.setFont(levelTitleFont)
  if (level1Button:getHoverState()) then
    love.graphics.setColor(Opacity17)
  else
    love.graphics.setColor(Transparent)
  end
  love.graphics.polygon('fill', gw/2 - 450-menumusic:getEnergy()*10, 0,
                                gw/2 + 450+menumusic:getEnergy()*10, 0,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.1 + 120,
                                gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 120)
  love.graphics.setColor(Opacity17)
  love.graphics.line(gw/2 + 330+menumusic:getEnergy()*10, gh*0.1 + 120, gw/2 - 330-menumusic:getEnergy()*10, gh*0.1 + 120)

  love.graphics.setColor(White)
  love.graphics.printf("ParagonX9 - Chaoz Airflow", 0, gh*0.1 + 30, gw, "center")
  love.graphics.setFont(levelScoreFont)
  love.graphics.printf("Best Time: " .. savemanager.highscores.levelScore[1], 0, gh*0.1 + 70, gw, "center")

  love.graphics.setFont(levelTitleFont)
  if (level2Button:getHoverState()) then
    love.graphics.setColor(Opacity17)
  else
    love.graphics.setColor(Transparent)
  end
  love.graphics.polygon('fill', gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 120,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.1 + 120,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.1 + 240,
                                gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 240)

  love.graphics.setColor(Opacity17)
  love.graphics.line(gw/2 + 410+menumusic:getEnergy()*10, gh*0.1 + 240, gw/2 - 410-menumusic:getEnergy()*10, gh*0.1 + 240)

  love.graphics.setColor(White)
  love.graphics.printf("Hinkik - Explorers", 0, gh*0.1 + 120 + 30, gw, "center")
  love.graphics.setFont(levelScoreFont)
  love.graphics.printf("Best Time: " .. savemanager.highscores.levelScore[2], 0, gh*0.1 + 70 + 120, gw, "center")

  love.graphics.setFont(levelTitleFont)
  if (level3Button:getHoverState()) then
    love.graphics.setColor(Opacity17)
  else
    love.graphics.setColor(Transparent)
  end
  love.graphics.polygon('fill', gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 240,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.1 + 240,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.1 + 360,
                                gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 360)

  love.graphics.setColor(Opacity17)
  love.graphics.line(gw/2 + 450+menumusic:getEnergy()*10, gh*0.1 + 360, gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 360)


  love.graphics.setColor(White)
  love.graphics.printf("Hinkik - Time Leaper", 0, gh*0.1 + 240 + 30, gw, "center")
  love.graphics.setFont(levelScoreFont)
  love.graphics.printf("Best Time: " .. savemanager.highscores.levelScore[3], 0, gh*0.1 + 240 + 70, gw, "center")

  love.graphics.setFont(levelTitleFont)
  if (level4Button:getHoverState()) then
    love.graphics.setColor(Opacity17)
  else
    love.graphics.setColor(Transparent)
  end
  love.graphics.polygon('fill', gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 360,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.1 + 360,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.1 + 480,
                                gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 480)

  love.graphics.setColor(Opacity17)
  love.graphics.line(gw/2 + 445+menumusic:getEnergy()*10, gh*0.1 + 480, gw/2 - 445-menumusic:getEnergy()*10, gh*0.1 + 480)

  love.graphics.setColor(White)
  love.graphics.printf("Lchavasse - Lunar Abyss", 0, gh*0.1 + 360 + 30, gw, "center")
  love.graphics.setFont(levelScoreFont)
  love.graphics.printf("Best Time: " .. savemanager.highscores.levelScore[4], 0, gh*0.1 + 360 + 70, gw, "center")

  love.graphics.setFont(levelTitleFont)
  if (level5Button:getHoverState()) then
    love.graphics.setColor(Opacity17)
  else
    love.graphics.setColor(Transparent)
  end
  love.graphics.polygon('fill', gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 480,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.1 + 480,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.1 + 600,
                                gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 600)

  love.graphics.setColor(Opacity17)
  love.graphics.line(gw/2 + 420+menumusic:getEnergy()*10, gh*0.1 + 600, gw/2 - 420-menumusic:getEnergy()*10, gh*0.1 + 600)

  love.graphics.setColor(White)
  love.graphics.printf("Xtrullor - Supernova", 0, gh*0.1 + 480 + 30, gw, "center")
  love.graphics.setFont(levelScoreFont)
  love.graphics.printf("Best Time: " .. savemanager.highscores.levelScore[5], 0, gh*0.1 + 480 + 70, gw, "center")

  love.graphics.setFont(levelTitleFont)
  if (level6Button:getHoverState()) then
    love.graphics.setColor(Opacity17)
  else
    love.graphics.setColor(Transparent)
  end
  love.graphics.polygon('fill', gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 600,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.1 + 600,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.1 + 720,
                                gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 720)

  love.graphics.setColor(Opacity17)
  love.graphics.line(gw/2 + 350+menumusic:getEnergy()*10, gh*0.1 + 720, gw/2 - 350-menumusic:getEnergy()*10, gh*0.1 + 720)

  love.graphics.setColor(White)
  love.graphics.printf("Kurototei - Galaxy Collapse", 0, gh*0.1 + 600 + 30, gw, "center")
  love.graphics.setFont(levelScoreFont)
  love.graphics.printf("Best Time: " .. savemanager.highscores.levelScore[6], 0, gh*0.1 + 600 + 70, gw, "center")

  love.graphics.setFont(levelTitleFont)
  if (levelBackButton:getHoverState()) then
    love.graphics.setColor(Opacity17)
  else
    love.graphics.setColor(Transparent)
  end
  love.graphics.polygon('fill', gw/2 - 450-menumusic:getEnergy()*10, gh*0.1 + 720,
                                gw/2 + 450+menumusic:getEnergy()*10, gh*0.1 + 720,
                                gw/2 + 450+menumusic:getEnergy()*10, gh,
                                gw/2 - 450-menumusic:getEnergy()*10, gh)

  love.graphics.setColor(White)
  love.graphics.printf("Back", 0, gh*0.1 + 720 + 60, gw, "center")

end

function mainmenu:changeResolution(value)
  changedResolution = true
  resolutionIndex = resolutionIndex + value
  if (resolutionIndex < 1) then
    resolutionIndex = #resolutionList
  elseif (resolutionIndex > #resolutionList) then
    resolutionIndex = 1
  end
end

function mainmenu:changeVolume(value)
  volumeValue = volumeValue + value
  if (volumeValue < 0) then
    volumeValue = 200
  elseif (volumeValue > 200) then
    volumeValue = 0
  end
  menumusic:setVolume(volumeValue * 0.001)
  buttonhover:setVolume(volumeValue * 0.001)
  buttonhit:setVolume(volumeValue * 0.001)
  failsound:setVolume(volumeValue * 0.001)
end

return mainmenu
