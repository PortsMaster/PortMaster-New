require 'levels/level01'
require 'levels/level02'
require 'levels/level03'
require 'levels/level04'
require 'levels/level05'
require 'levels/level06'

levelmanager = {}

function levelmanager:loadLevel(levelIndex)
  math.randomseed(os.time())
  if (levelIndex == 1) then
    level01:load()
  elseif (levelIndex == 2) then
    level02:load()
  elseif (levelIndex == 3) then
    level03:load()
  elseif (levelIndex == 4) then
    level04:load()
  elseif (levelIndex == 5) then
    level05:load()
  elseif (levelIndex == 6) then
    level06:load()
  end
end

function levelmanager:update(dt, timer, levelIndex)
  if (levelIndex == 1) then
    level01:update(dt, timer)
  elseif (levelIndex == 2) then
    level02:update(dt, timer)
  elseif (levelIndex == 3) then
    level03:update(dt, timer)
  elseif (levelIndex == 4) then
    level04:update(dt, timer)
  elseif (levelIndex == 5) then
    level05:update(dt, timer)
  elseif (levelIndex == 6) then
    level06:update(dt, timer)
  end
end

return levelmanager
