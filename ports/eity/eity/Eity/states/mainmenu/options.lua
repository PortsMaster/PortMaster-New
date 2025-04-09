require 'lib/simple-slider'
require 'objects/button'

Options = {}

local isMouseOnEnableFPS, isMouseOnEnableVSync

local backButton, generalButton, volumeButton, mainButton, musicButton, effectButton, slidertickButton
local resolutionButton, vsyncButton, fpsButton, backroundDimButton
local mainVolumeSlider, musicVolumeSlider, effectsVolumeSlider

function Options:load()
  changedResolution = false
  backButton = newButton(gw * 0.54, gh / 2 + 375, gw * 0.1, 50, 15, "Back", Blue, White, White, "center", 0, 10, function() BackToStartScreen() end)
  generalButton = newButton(gw * 0.38, gh / 2 - 375, gw * 0.1, 50, 15, "General", Purple, White, White, "center", 0, 10)
  volumeButton = newButton(gw * 0.38, gh / 2, gw * 0.1, 50, 15, "Volume", Purple, White, White, "center", 0, 10)
  mainButton = newButton(gw * 0.35, gh / 2 + 75, gw * 0.3, 50, 15, "Main", GrayOpacity4, White, White, "left", 15, 10)
  musicButton = newButton(gw * 0.35, gh * 0.5 + 150, gw * 0.3, 50, 15, "Music", GrayOpacity4, White, White, "left", 15, 10)
  effectButton = newButton(gw * 0.35, gh / 2 + 225, gw * 0.3, 50, 15, "Effect", GrayOpacity4, White, White, "left", 15, 10)
  slidertickButton = newButton(gw * 0.35, gh / 2 + 300, gw * 0.3, 50, 15, "Enable slidertick sound", GrayOpacity4, White, White, "left", 15, 10)
  
  resolutionButton = newButton(gw * 0.35, gh / 2 - 300, gw * 0.3, 50, 15, "Resolution", GrayOpacity4, White, White, "left", 15, 10)
  vsyncButton = newButton(gw * 0.35, gh / 2 - 225, gw * 0.3, 50, 15, "Enable Vsync", GrayOpacity4, White, White, "left", 15, 10)
  fpsButton = newButton(gw * 0.35, gh / 2 - 150, gw * 0.3, 50, 15, "Show FPS", GrayOpacity4, White, White, "left", 15, 10)
  backroundDimButton = newButton(gw * 0.35, gh / 2 - 75, gw * 0.3, 50, 15, "Background dim", GrayOpacity4, White, White, "left", 15, 10)

  backgroundDimSlider = newSlider(gw * 0.56, gh / 2 - 50, gw * 0.15, saveManager.settings.bgDim, 0, 1, function (v) gameManager.setBackgroundDim(v) end)
  
  mainVolumeSlider = newSlider(gw * 0.56, gh / 2 + 100, gw * 0.15, saveManager.settings.mainVolume, 0, 2, function (v) soundManager:SetMainVolume(v) end)
  musicVolumeSlider = newSlider(gw * 0.56, gh / 2 + 175, gw * 0.15, saveManager.settings.musicVolume, 0, 0.1, function (v) soundManager:SetMusicVolume(v) end)
  effectsVolumeSlider = newSlider(gw * 0.56, gh / 2 + 250, gw * 0.15, saveManager.settings.effectVolume, 0, 0.1, function (v) soundManager:SetEffectsVolume(v) end)
end

function Options:update(dt)
  backButton:update(dt)
  backgroundDimSlider:update()
  mainVolumeSlider:update()
  musicVolumeSlider:update()
  effectsVolumeSlider:update()
                
  isMouseOnResolution = mx > gw * 0.51 and mx < gw * 0.51 + 200 and
                          my > gh / 2 - 290 and my < gh / 2 - 290 + 30  
                      
  isMouseOnEnableVSync = mx > gw * 0.63 - 16 and mx < gw * 0.63 + 16 and
                          my > gh / 2 - 200 - 16 and my < gh / 2 - 200 + 16   
                          
  isMouseOnEnableFPS = mx > gw * 0.63 - 16 and mx < gw * 0.63 + 16 and
                          my > gh / 2 - 125 - 16 and my < gh / 2 - 125 + 16   
                          
  isMouseOnEnableTicksound = mx > gw * 0.63 - 16 and mx < gw * 0.63 + 16 and
                          my > gh / 2 + 325 - 16 and my < gh / 2 + 325 + 16   
                                                            
end

function Options:draw()
  DrawButtons()
  DrawSliders()
end

function Options:mousepressed(x, y,button)     
  backButton:mousepressed(x, y, button)              
  if isMouseOnEnableFPS and button == 1 then
    soundManager.playSoundEffect(soundManager.buttonHitsrc)
    if saveManager.settings.isEnabledFPS then
      saveManager.settings.isEnabledFPS = false
    else
      saveManager.settings.isEnabledFPS = true
    end
  elseif isMouseOnEnableVSync and button == 1 then
    soundManager.playSoundEffect(soundManager.buttonHitsrc)
    if saveManager.settings.isEnabledVSync then
      saveManager.settings.isEnabledVSync = false
    else
      saveManager.settings.isEnabledVSync = true
    end
  elseif isMouseOnEnableTicksound and button == 1 then
    soundManager.playSoundEffect(soundManager.buttonHitsrc)
    if saveManager.settings.isEnabledTicksound then
      saveManager.settings.isEnabledTicksound = false
    else
      saveManager.settings.isEnabledTicksound = true
    end
  elseif isMouseOnResolution and button == 1 then
    changedResolution = true
    soundManager.playSoundEffect(soundManager.buttonHitsrc)
    saveManager.settings.resolutionIndex = saveManager.settings.resolutionIndex - 1
    if saveManager.settings.resolutionIndex <= 0 then
      saveManager.settings.resolutionIndex = #resolutionList
    end
  elseif isMouseOnResolution and button == 2 then
    changedResolution = true
    soundManager.playSoundEffect(soundManager.buttonHitsrc)
    saveManager.settings.resolutionIndex = saveManager.settings.resolutionIndex + 1
    if saveManager.settings.resolutionIndex > #resolutionList then
      saveManager.settings.resolutionIndex = 1
    end
  end
end

function BackToStartScreen()
  saveManager:saveSettings()
  menustate = "Startmenu"
  if (changedResolution) then
    changedResolution = false
    simpleScale.updateWindow(resolutionList[saveManager.settings.resolutionIndex][1], resolutionList[saveManager.settings.resolutionIndex][2])
  end
end

function DrawSliders()
  backgroundDimSlider:draw()
  mainVolumeSlider:draw()
  musicVolumeSlider:draw()
  effectsVolumeSlider:draw()
end

function DrawButtons()  
  love.graphics.setFont(buttonSmallFont)
  love.graphics.setLineWidth(6)   
  backButton:draw()
  generalButton:draw()  
  resolutionButton:draw()
  love.graphics.setColor(Green)
  love.graphics.rectangle("fill", gw * 0.51, gh / 2 - 290, 200, 30, 10)
  love.graphics.setColor(White)
  love.graphics.setLineWidth(5)
  love.graphics.rectangle("line", gw * 0.51, gh / 2 - 290, 200, 30, 10)
  love.graphics.printf(resolutionList[saveManager.settings.resolutionIndex][1] .. " x " .. resolutionList[saveManager.settings.resolutionIndex][2], gw * 0.51, gh / 2 - 290, 200, "center")
  
  vsyncButton:draw()
  love.graphics.circle('line', gw * 0.63, gh / 2 - 200, 16, 4)
  if saveManager.settings.isEnabledVSync then
    love.graphics.setColor(Green)
    love.graphics.circle('fill', gw * 0.63, gh / 2 - 200, 8, 4)
  end
      
  fpsButton:draw()
  love.graphics.circle('line', gw * 0.63, gh / 2 - 125, 16, 4)
  if saveManager.settings.isEnabledFPS then
    love.graphics.setColor(Green)
    love.graphics.circle('fill', gw * 0.63, gh / 2 - 125, 8, 4)
  end
  
  backroundDimButton:draw()
  volumeButton:draw()
  mainButton:draw()
  musicButton:draw()
  effectButton:draw()
  slidertickButton:draw()
  love.graphics.circle('line', gw * 0.63, gh / 2 + 325, 16, 4)
  if saveManager.settings.isEnabledTicksound then
    love.graphics.setColor(Green)
    love.graphics.circle('fill', gw * 0.63, gh / 2 + 325, 8, 4)
    love.graphics.setColor(1, 1, 1, 1)
  end
  --[[
  love.graphics.setColor(Colors.getGreenColor())
  love.graphics.rectangle('fill', gw * 0.35, gh / 2 - 75, gw * 0.3, 50, 15)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle('line', gw * 0.35, gh / 2 - 75, gw * 0.3, 50, 15)
  love.graphics.printf("Keyboard bindings", 0, gh / 2 - 63, gw, "center")
  ]]
end

return Options
