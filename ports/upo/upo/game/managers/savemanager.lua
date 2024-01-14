serialize = require 'lib/ser'

savemanager = {}

function savemanager:load()
  if not love.filesystem.getInfo("settings.txt") then
    settings = {}
    settings.resolutionIndex = 8
    settings.volume = 100

    love.filesystem.write("settings.txt", serialize(settings))
  end

  chunk = love.filesystem.load("settings.txt")
  savemanager.settings = chunk()

  if not love.filesystem.getInfo("highscores.txt") then
    highscores = {}
    highscores.levelScore = {0, 0, 0, 0, 0, 0}
    love.filesystem.write("highscores.txt", serialize(highscores))
  end

  chunk = love.filesystem.load("highscores.txt")
  savemanager.highscores = chunk()
end

function savemanager:saveHighscores()
  love.filesystem.write("highscores.txt", serialize(savemanager.highscores))
end

function savemanager:saveSettings(resolutionIndex, volume)
  settings = {}
  settings.resolutionIndex = resolutionIndex
  settings.volume = volume

  love.filesystem.write("settings.txt", serialize(settings))
end

return savemanager
