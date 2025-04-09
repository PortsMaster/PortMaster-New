--Android Touchcontrols by RamiLego4Game

_touches = {}

--Constants
local sw, sh = love.graphics.getDimensions()
local circleSize = 78 --love.window.toPixels(78)

local joyColor = {0,0,0,80/255}
local joybodyColor = {1,1,1}

--Positions
local joycx, joycy = circleSize*1.5, sh - circleSize*1.5
local joyx, joyy = joycx, joycy
local joybodyR = circleSize --Joystick body circle radius
local joyR = circleSize/2 --Joystick circle radius

function drawTouchJoy()

  love.graphics.setColor(joybodyColor[1], joybodyColor[2], joybodyColor[3], tc.a/255)
  love.graphics.circle("fill", joycx, joycy, joybodyR)

  love.graphics.setColor(joyColor[1], joyColor[2], joyColor[3], tc.a/255)
  love.graphics.circle("fill", joyx, joyy, joyR)

end

--Touch Processing

local pi = math.pi
local joydr = (joybodyR*0.2)^2 --The joystick dead range.
local joymr_ = joybodyR*1.1-joyR --The joystick max distance
local joymr = (joymr_)^2 --The joystick max distance
local joypr = joybodyR^2

local function moveJoy(x,y)

  local dist = (x-joycx)^2 + (y-joycy)^2

  local a = math.atan2(joycy-y, x-joycx)/pi

  if dist > joymr then
    joyx = joycx + math.cos(a*pi)*joymr_
    joyy = joycy - math.sin(a*pi)*joymr_
  else
    joyx, joyy = x,y
  end

  if dist <= joydr then
    _keys["up"], _keys["down"], _keys["left"], _keys["right"] = false, false, false, false
    return
  end --Dead Range

  --right
  if a >= -0.3 and a < 0.3 then _keys["right"] = _keys["right"] and "" or true
  else _keys["right"] = false end

  --up
  if a >= 0.2 and a < 0.8 then _keys["up"] = _keys["up"] and "" or true
  else _keys["up"] = false end

  --left
  if a >= 0.7 or a < -0.7 then _keys["left"] = _keys["left"] and "" or true
  else _keys["left"] = false end

  --down
  if a >= -0.8 and a < -0.2 then _keys["down"] = _keys["down"] and "" or true
  else _keys["down"] = false end
end

local joytid --Joystick touch id

function love.touchpressed(id,x,y,dx,dy,pressure)
  if not joytid then
    if (x-joycx)^2 + (y-joycy)^2 < joypr then
      joytid = id
      moveJoy(x,y)
    end
  end

  _touches[id] = {x,y}
end

function love.touchmoved(id,x,y,dx,dy,pressure)
  if joytid and joytid == id then
    moveJoy(x,y)
  end

  _touches[id][1], _touches[id][2] = x,y
end

function love.touchreleased(id,x,y,dx,dy,pressure)
  if joytid and joytid == id then
    moveJoy(joycx, joycy)
    joytid = false
  end

  _touches[id] = false
end
