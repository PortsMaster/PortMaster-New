serialize = require 'lib/ser'

saveManager = {}

function saveManager:load()
  if not love.filesystem.getInfo("settings.txt") then
    settings = {}
    settings.resolutionIndex = 5
    settings.isEnabledFPS = false
    settings.isEnabledVSync = false
    settings.isEnabledTicksound = false
    settings.bgDim = 0.5
    settings.mainVolume = 1
    settings.musicVolume = 0.05
    settings.effectVolume = 0.05
    
    love.filesystem.write("settings.txt", serialize(settings))
  end
  
  chunk = love.filesystem.load("settings.txt")
  saveManager.settings = chunk()
  
  
  
  if not love.filesystem.getInfo("highscores.txt") then
    highscores = {}
    highscores.mapScore = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    highscores.mapGrade = {"", "", "", "", "", "", "", "", "", ""}
    
    love.filesystem.write("highscores.txt", serialize(highscores))
  end
  
  chunk = love.filesystem.load("highscores.txt")
  saveManager.highscores = chunk()
end

function saveManager:saveHighscore()
  love.filesystem.write("highscores.txt", serialize(saveManager.highscores))
end

function saveManager:saveSettings()
  settings = {}
  settings.resolutionIndex = saveManager.settings.resolutionIndex
  settings.isEnabledFPS = saveManager.settings.isEnabledFPS
  settings.isEnabledVSync = saveManager.settings.isEnabledVSync
  settings.isEnabledTicksound = saveManager.settings.isEnabledTicksound
  settings.bgDim = saveManager.settings.bgDim
  settings.mainVolume = saveManager.settings.mainVolume
  settings.musicVolume = saveManager.settings.musicVolume
  settings.effectVolume = saveManager.settings.effectVolume
  
  love.filesystem.write("settings.txt", serialize(settings))
end

return saveManager
