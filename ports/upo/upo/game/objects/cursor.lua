require 'objects/collision'
cursortrail_array = require 'objects/cursortrail_array'

cursor = {}

local cursorPosX, cursorPosY

function cursor:load()
  cursorMX = gw/2
  cursorMY = gh/2
end

function cursor:update(dt, isEndGame, levelIndex)  
  
  if (joystickNoticeTextOpacity > 0) then
    joystickNoticeTextOpacity = joystickNoticeTextOpacity - dt / 2
  else
    joystickNoticeTextOpacity = 0
  end
    
  if (isJoystickMove and joystick ~= nil) then
    if (math.abs(joystick:getGamepadAxis("leftx")) > 0.06 or math.abs(joystick:getGamepadAxis("lefty")) > 0.06) then
      cursorMX = cursorMX + joystick:getGamepadAxis("leftx") * dt * 800
      cursorMY = cursorMY + joystick:getGamepadAxis("lefty") * dt * 800
    elseif (math.abs(joystick:getGamepadAxis("rightx")) > 0.06 or math.abs(joystick:getGamepadAxis("righty")) > 0.06) then
      cursorMX = cursorMX + joystick:getGamepadAxis("rightx") * dt * 800
      cursorMY = cursorMY + joystick:getGamepadAxis("righty") * dt * 800
    end
  else
    cursorMX = mx
    cursorMY = my
  end
  
  if (cursorMX > gw) then
    cursorMX = gw
  elseif (cursorMX < 0) then
    cursorMX = 0
  end
  
  if (cursorMY > gh) then
    cursorMY = gh
  elseif (cursorMY < 0) then
    cursorMY = 0
  end
  
  local dx = cursorMX - gw/2
  local dy = cursorMY - gh/2
  local dist = math.sqrt(dx^2+dy^2)

  if (statemanager:getState() == "menu") then
    if (dist < (450-19+menumusic:getEnergy()*10)) then
      cursorPosX = cursorMX
      cursorPosY = cursorMY
    else
      cursorPosX = gw/2 + dx/dist*(450-19+menumusic:getEnergy()*10)
      cursorPosY = gh/2 + dy/dist*(450-19+menumusic:getEnergy()*10)
    end

  elseif (statemanager:getState() == "game" and not isEndGame) then
    cursor:checkCollisionForCircles()
    cursor:checkCollisionForCircles2()
    cursor:checkCollisionForSquares()
    cursor:checkCollisionForKites()
    cursor:checkCollisionForLasers()
    cursor:checkCollisionForLasers2()
    cursor:checkCollisionForTriangles()
    
    if (levelIndex == 4) then
      if (dist < (225-19)) then
        cursorPosX = cursorMX
        cursorPosY = cursorMY
      else
        cursorPosX = gw/2 + dx/dist*(225-19)
        cursorPosY = gh/2 + dy/dist*(225-19)
      end

    elseif (levelIndex == 3) then
      cursorPosX = gw/2 + dx/dist*(450-19)
      cursorPosY = gh/2 + dy/dist*(450-19)
    else
      if (dist < (450-19)) then
        cursorPosX = cursorMX
        cursorPosY = cursorMY
      else
        cursorPosX = gw/2 + dx/dist*(450-19)
        cursorPosY = gh/2 + dy/dist*(450-19)
      end
    end
  end
  cursortrail_array:update(dt, cursorPosX, cursorPosY, levelIndex)
end

function cursor:draw(isEndGame, levelIndex)
  cursortrail_array:draw()
  if (isEndGame) then
    love.graphics.setColor(Red)
  else
    love.graphics.setColor(DarkBlue)
  end
  love.graphics.circle('fill', cursorPosX, cursorPosY, 15, 120)
  love.graphics.setColor(White)
  love.graphics.setLineWidth(2)
  love.graphics.circle('line', cursorPosX, cursorPosY, 15, 120)
  love.graphics.circle('line', cursorMX, cursorMY, 15)
  
  if (joystickNoticeTextOpacity > 0) then
    love.graphics.setColor(1, 1, 1, joystickNoticeTextOpacity)
    love.graphics.setFont(levelTitleFont)
    if (isJoystickMove) then
      love.graphics.print("Joystick movement enabled", cursorPosX-200, cursorPosY-50)
    else
      love.graphics.print("Joystick movement disabled", cursorPosX-200, cursorPosY-50)
    end
  end
end

function cursor:getPositionX()
  return cursorPosX
end

function cursor:getPositionY()
  return cursorPosY
end


function cursor:checkCollisionForCircles()
  for i, v in ipairs(listOfCircles) do
    if (circleDetect(cursor:getPositionX(), cursor:getPositionY(), math.sin(v.rotation)*v.x - math.cos(v.rotation)*v.y + gw/2, 
                            math.cos(v.rotation)*v.x + math.sin(v.rotation)*v.y + gh/2, v.radius-10)) then
      maingame:die()
    end
  end
end

function cursor:checkCollisionForCircles2()
  for i, v in ipairs(listOfCircles2) do
    if (circleDetect(cursor:getPositionX(), cursor:getPositionY(), v.x, v.y, v.radius-10)) then
      maingame:die()
    end
  end
end

function cursor:checkCollisionForSquares()
  for i, v in ipairs(listOfSquares) do
    if (rectangleDetect(cursor:getPositionX(), cursor:getPositionY(), v.x-10, v.y-10, 30+20, 30+20)) then
      maingame:die()
    end
  end
end

function cursor:checkCollisionForKites()
  for i, v in ipairs(listOfKites) do
    if (circleDetect(cursor:getPositionX(), cursor:getPositionY(), math.sin(v.rotation)*v.x+v.targetX, math.cos(v.rotation)*v.x+v.targetY, 18)) then
      maingame:die()
    end
  end
end

function cursor:checkCollisionForLasers()
  for i, v in ipairs(listOfLasers) do
    if (rectangleDetect(cursor:getPositionX(), cursor:getPositionY(), v.x, v.y, v.width, v.height)) then
      maingame:die()
    end
  end
end

function cursor:checkCollisionForLasers2()
  for i, v in ipairs(listOfLasers2) do
    if (rectangleDetect(cursor:getPositionX(), cursor:getPositionY(), v.x, v.y, v.width, v.height)) then
      maingame:die()
    end
  end
end

function cursor:checkCollisionForTriangles()
  for i, v in ipairs(listOfTriangles) do
    if (circleDetect(cursor:getPositionX(), cursor:getPositionY(), v.x+v.targetX, v.y+v.targetY, 7)) then
      maingame:die()
    end
  end
end

return cursor
