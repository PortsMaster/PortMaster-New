require 'managers/levelmanager'

require 'objects/cursor'

require 'objects/circle'
require 'objects/circle2'
require 'objects/square'
require 'objects/kite'
require 'objects/triangle'
require 'objects/laser'
require 'objects/laser2'

local effectcircle = require 'objects/effectcircle'
local audio = require "lib/wave"

maingame = {}

levelSongs = {audio:newSource("songs/ParagonX9 - Chaoz Airflow.mp3", "stream"),
              audio:newSource("songs/Hinkik - Explorers.mp3", "stream"),
              audio:newSource("songs/Hinkik - Time Leaper.mp3", "stream"),
              audio:newSource("songs/Lchavasse - Lunar Abyss.mp3", "stream"),
              audio:newSource("songs/Xtrullor - Supernova.mp3", "stream"),
              audio:newSource("songs/Kurokotei - Galaxy Collapse.mp3", "stream")}

local hiddenBG = love.graphics.newImage("assets/hidden.png")
local level1BG = love.graphics.newImage("assets/level01.png")
local level2BG = love.graphics.newImage("assets/level02.png")
local level3BG = love.graphics.newImage("assets/level03.png")

local levelIndex
local timer

function maingame:load()
  restartButton = newButton(gw/2 - 200, gh*0.44, 400, 130, function() maingame:restart() end)
  exitButton = newButton(gw/2 - 200, gh*0.56, 400, 130, function() maingame:endLevel() end)

  failsound = audio:newSource("assets/failsound.wav", "stream")
  failsound:setVolume(volumeValue * 0.001)
end

function maingame:update(dt)
  effectcircle:update(dt)
  cursor:update(dt, isEndGame, levelIndex)
  if (isEndGame) then
    restartButton:update(dt)
    exitButton:update(dt)
  end

  if not (isEndGame) then
    circle:update(dt)
    circle2:update(dt)
    square:update(dt)
    kite:update(dt)
    triangle:update(dt)
    laser:update(dt)
    laser2:update(dt)

    timer = timer + dt
    levelmanager:update(dt, timer, levelIndex)
  end
end

function maingame:draw()
  local imgX = (gw - level1BG:getWidth()) / 2
  local imgY = (gh - level1BG:getHeight()) / 2

  love.graphics.setColor(58 / 255, 65 / 255, 81 / 255, 1)
  love.graphics.setLineWidth(4)
  love.graphics.circle("fill", gw / 2, gh / 2, 450)
  if not (isEndGame) then
    circle:draw()
    circle2:draw()
    square:draw()
    kite:draw()
    triangle:draw()
    laser:draw()
    laser2:draw()
  end

  love.graphics.setColor(White)
  love.graphics.setFont(scoreFont)

  if (levelIndex == 3) then
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.circle("fill", gw / 2, gh / 2, 120)
    love.graphics.setColor(White)
    love.graphics.circle("line", gw / 2, gh / 2, 120)
    love.graphics.draw(level1BG, imgX, imgY)
    love.graphics.circle("line", gw / 2, gh / 2, 450)
    love.graphics.printf(string.format("%0.1f", timer), 0, gh*0.2, gw, "center")
  elseif (levelIndex == 4) then
    love.graphics.draw(level3BG, imgX, imgY)
    love.graphics.circle("line", gw / 2, gh / 2, 225)
    love.graphics.printf(string.format("%0.1f", timer), 0, gh*0.4, gw, "center")
  elseif (levelIndex == 5) then
    love.graphics.draw(level2BG, imgX, imgY)
    love.graphics.draw(hiddenBG, cursor:getPositionX(), cursor:getPositionY(), 0, 1, 1, hiddenBG:getWidth() / 2, hiddenBG:getHeight() / 2)
    love.graphics.circle("line", gw / 2, gh / 2, 450)
    love.graphics.printf(string.format("%0.1f", timer), 0, gh*0.2, gw, "center")
  else
    love.graphics.draw(level1BG, imgX, imgY)
    love.graphics.circle("line", gw / 2, gh / 2, 450)
    love.graphics.printf(string.format("%0.1f", timer), 0, gh*0.2, gw, "center")
  end
  effectcircle:draw()
  cursor:draw(isEndGame, levelIndex)
  if (isEndGame) then
    maingame:endScreen()
  end
end

function maingame:mousepressed(x, y, button)
  if (isEndGame) then
    restartButton:mousepressed(x, y, button)
    exitButton:mousepressed(x, y, button)
  end
end

function maingame:gamepadpressed(joystick, button)
  if (button == "start" or button == "back") then
    maingame:die()
  end
  if (isEndGame) then
    restartButton:gamepadpressed(joystick, button)
    exitButton:gamepadpressed(joystick, button)
  end
end

function maingame:keypressed(key)
  if (key == "escape") then
    maingame:die()
  end
end

function maingame:loadLevel(index)
  levelIndex = index
  gamemusic = levelSongs[levelIndex]
  gamemusic:setVolume(volumeValue * 0.001)
  gamemusic:setLooping(true)
  maingame:restart()
end

function maingame:die()
  isEndGame = true
  circle:clear()
  circle2:clear()
  square:clear()
  kite:clear()
  triangle:clear()
  laser:clear()
  laser2:clear()
  gamemusic:stop()
  failsound:play()

  if (timer > savemanager.highscores.levelScore[levelIndex]) then
    savemanager.highscores.levelScore[levelIndex] = tonumber(string.format("%0.1f", timer))
    savemanager:saveHighscores()
  end
end

function maingame:endScreen()
  love.graphics.setColor(0, 0, 0, 0.2)
  love.graphics.rectangle('fill', 0, 0, gw, gh)

  love.graphics.setFont(bigScoreFont)
  if (restartButton:getHoverState()) then
    love.graphics.setColor(White)
  else
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
  end
  love.graphics.printf("Restart", 0, gh*0.44, gw, "center")

  if (exitButton:getHoverState()) then
    love.graphics.setColor(White)
  else
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
  end
  love.graphics.printf("Exit", 0, gh*0.56, gw, "center")

  love.graphics.setFont(levelScoreFont)
  love.graphics.setColor(White)
  if (timer > savemanager.highscores.levelScore[levelIndex]) then
    if (levelIndex == 4) then
      love.graphics.printf("NEW PERSONAL BEST", 0, gh*0.37, gw, "center")
    else
      love.graphics.printf("NEW PERSONAL BEST", 0, gh*0.17, gw, "center")
    end
  end
end

function maingame:restart()
  timer = 0
  isEndGame = false
  gamemusic:play()
  levelmanager:loadLevel(levelIndex)
end

function maingame:endLevel()
  statemanager:changeState("menu")
  gamemusic:stop()
  menumusic:play()
end

function maingame:getSong()
  if (levelIndex == 1) then
    return "Chaoz Airflow"
  elseif (levelIndex == 2) then
    return "Explorers"
  elseif (levelIndex == 3) then
    return "Time Leaper"
  elseif (levelIndex == 4) then
    return "Lunar Abyss"
  elseif (levelIndex == 5) then
    return "Supernova"
  elseif (levelIndex == 6) then
    return "Galaxy Collapse"
  end
end

function maingame:getArtist()
  if (levelIndex == 1) then
    return "ParagonX9"
  elseif (levelIndex == 2) then
    return "Hinkik"
  elseif (levelIndex == 3) then
    return "Hinkik"
  elseif (levelIndex == 4) then
    return "Lchavasse"
  elseif (levelIndex == 5) then
    return "Xtrullor"
  elseif (levelIndex == 6) then
    return "Kurokotei"
  end
end

return maingame
