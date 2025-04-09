socket = require 'socket'

mapList = {}

local bigFont
local rankingFont
local smallFont
local smallestFont
local maplist
local scrollY
local selectedMap
local isMouseOnMap

function mapList:load(listOfMaps)
  bigFont = love.graphics.newFont("assets/roboto.ttf", 84)
  smallFont = love.graphics.newFont("assets/roboto.ttf", 24)
  smallestFont = love.graphics.newFont("assets/roboto.ttf", 18)
  rankingFont = love.graphics.newFont("assets/roboto.ttf", 58)
  maplist = listOfMaps
  scrollY = 0
  selectedMap = 1
  isMouseOnMap = false
end

function mapList.getSelectedMapIndex()
  return selectedMap
end

function mapList.PickRandomMapIndex()
  math.randomseed(socket.gettime())
  selectedMapCheck = math.random(1, #mapManager.getListOfMaps())
  if(selectedMapCheck == selectedMap) then selectedMapCheck = math.random(1, #mapManager.getListOfMaps()) end
  selectedMap = selectedMapCheck
  img = gameManager:setBackground()
end

function mapList:draw()
  for i, v in ipairs(maplist) do
    if (i == selectedMap) then
      love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
      love.graphics.rectangle('fill', gw - 820, scrollY + 100 + 111 * (i - 1), 700, 100, 10)
      love.graphics.setColor(White)
      love.graphics.rectangle('line', gw - 820, scrollY + 100 + 111 * (i - 1), 700, 100, 10)
      love.graphics.setFont(smallFont)
      love.graphics.printf(mapManager.getTitleOfIndex(i), gw - 800, scrollY + 115 + 111 * (i - 1), 700, "left")
      love.graphics.setFont(smallestFont)
      love.graphics.setColor(White)
      love.graphics.printf(mapManager.getPorterOfIndex(i), gw - 790, scrollY + 145 + 111 * (i - 1), 700, "left")
      love.graphics.setColor(Blue)
      love.graphics.printf(mapManager.getDifficultOfIndex(i), gw - 790, scrollY + 165 + 111 * (i - 1), 700, "left")  
      DrawGrade(i)
    else
      love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
      love.graphics.rectangle('fill', gw - 780, scrollY + 100 + 111 * (i - 1), 660, 100, 10)
      love.graphics.setColor(White)
      love.graphics.rectangle('line', gw - 780, scrollY + 100 + 111 * (i - 1), 660, 100, 10)
      love.graphics.setFont(smallFont)
      love.graphics.printf(mapManager.getTitleOfIndex(i), gw - 760, scrollY + 115 + 111 * (i - 1), 660, "left")
      love.graphics.setFont(smallestFont)
      love.graphics.setColor(White)
      love.graphics.printf(mapManager.getPorterOfIndex(i), gw - 750, scrollY + 145 + 111 * (i - 1), 700, "left")
      love.graphics.setColor(Blue)
      love.graphics.printf(mapManager.getDifficultOfIndex(i), gw - 750, scrollY + 165 + 111 * (i - 1), 700, "left")
      
      DrawGrade(i)
    end
  end
end

function DrawGrade(i)
  love.graphics.setFont(rankingFont)
  love.graphics.setColor(White)
  love.graphics.printf(saveManager.highscores.mapGrade[i], gw * 0.61 - 2, scrollY + 116 + 111 * (i - 1) - 2, gw * 0.6, "center")
  love.graphics.printf(saveManager.highscores.mapGrade[i], gw * 0.61 + 2, scrollY + 116 + 111 * (i - 1) - 2, gw * 0.6, "center")
  love.graphics.printf(saveManager.highscores.mapGrade[i], gw * 0.61 - 2, scrollY + 116 + 111 * (i - 1) + 2, gw * 0.6, "center")
  love.graphics.printf(saveManager.highscores.mapGrade[i], gw * 0.61 + 2, scrollY + 116 + 111 * (i - 1) + 2, gw * 0.6, "center")
  love.graphics.setColor(scoreManager.getGradeColor(saveManager.highscores.mapGrade[i]))
  love.graphics.printf(saveManager.highscores.mapGrade[i], gw * 0.61, scrollY + 116 + 111 * (i - 1), gw * 0.6, "center") 
end

function mapList:mousepressed(x, y, button)  
  for i, v in ipairs(maplist) do
    isMouseOnMap = mx > gw - 820 and mx < gw - 820 + 700 and
                            my > scrollY + 100 + 111 * (i - 1) and my < scrollY + 100 + 111 * (i - 1) + 100 and
                            my < gh * 0.92       
    if isMouseOnMap and button == 1 then    
      selectedMap = i    
      img = gameManager:setBackground()
    end  
  end 
end


function love.wheelmoved(x, y)
    if y > 0 then
        scrollY = scrollY + 30
        if (scrollY >= 0) then
          scrollY = 0
        end
    elseif y < 0 then
        scrollY = scrollY - 30
        if (scrollY <= 890 + #maplist * -111) then
          scrollY = 890 + #maplist * -111
        end
    end
end


function mapList.mapListUp()
  if selectedMap > 1 then
    selectedMap = selectedMap - 1
    img = gameManager:setBackground()
  end
end

function mapList.mapListDown()
  if selectedMap < #maplist then
    selectedMap = selectedMap + 1
    img = gameManager:setBackground()
  end
end
