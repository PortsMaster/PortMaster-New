-- THIS IS A VERY OLD LIBRARY, I MAY HAVE TO UPDATE IT LATER...
-- (I hope so)

local camera = {
    x = 0,
    y = 0,
    scaleX =  1,
    scaleY =  1,
    rotation = 0,
    pivotX = 0,
    pivotY = 0,
    offsetX = 0,
    offsetY = 0,
    _resolution_offset = {x = 0, y = 0}, -- resolution offset
    _shake_offset = {x = 0, y = 0}, --shake offset
    _shake_power = 1,
    _duration = 0, --duration
    _rotationX = 0,
    _rotationY = 0,
    isSet = false,
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight(),
    baseWidth = 0,
    baseHeight = 0,
    borders = false,
    bordersColor = {0, 0, 0, 1},
    _lastMousePos = {x = nil, y = nil},
  }

camera._rotationX = 0.5 * camera.width
camera._rotationY = 0.5 * camera.height


--sets the camera before draw calls.
function camera.set()
  love.graphics.push()
  camera.isSet = true
  
  love.graphics.translate(camera._rotationX, camera._rotationY)
  love.graphics.rotate(-camera.rotation)
  love.graphics.scale(camera.scaleX, camera.scaleY)
  
  love.graphics.translate(-camera.x - camera.offsetX -camera._rotationX + camera._shake_offset.x + camera._resolution_offset.x, -camera.y - camera.offsetY -camera._rotationY + camera._shake_offset.y + camera._resolution_offset.y)
end

--unsets the camera.
function camera.unset()
  love.graphics.pop()
  camera.isSet = false
end

--moves the camera relative to its current position
function camera.move(dx, dy)
  camera.x = camera.x + (dx or 0)
  camera.y = camera.y + (dy or 0)
end

--rotates the camera relative to its current position (radians)
function camera.rotate(dr)
  camera.rotation = camera.rotation + dr
end

--scales the camera relative to its current position 
function camera.scale(sx, sy)
  sx = sx or 1
  camera.scaleX = camera.scaleX * sx
  camera.scaleY = camera.scaleY * (sy or sx)
end

--sets the current camera position
function camera.setPosition(x, y)
  camera.x = x or camera.x
  camera.y = y or camera.y
end

--sets the current camera scale
function camera.setScale(sx, sy)
  camera.scaleX = sx or camera.scaleX
  camera.scaleY = (sy or sx) or camera.scaleY
end

--sets the current camera rotation (radians)
function camera.setRotation(rotation)
  camera.rotation = rotation
end

--sets the camera pivot (the point that the camera rotates around)
function camera.setPivot(x, y)
  camera.pivotX = x or camera.pivotX
  camera.pivotY = y or camera.pivotY
  camera._rotationX = camera.pivotX * camera.width
  camera._rotationY = camera.pivotY * camera.height
end


--sets the camera offset
function camera.setOffset(x, y)
  camera.offsetX = x or camera.offsetY
  camera.offsetY = y or camera.offsetY
end

function camera.setBaseResolution(width, height, borders, bordersColor)
  camera.baseWidth = width
  camera.baseHeight = height
  camera.borders = borders or false
  camera.bordersColor = bordersColor or {0, 0, 0, 1} -- black

  camera.updateWindowSize()
end


function camera.updateWindowSize(big_scale, difference)
  camera.width  = love.graphics.getWidth()
  camera.height = love.graphics.getHeight()
  camera._rotationX = camera.pivotX * camera.width
  camera._rotationY = camera.pivotY * camera.height

  local width_scale, height_scale = nil, nil
  if camera.baseWidth > 0 then
    width_scale = math.floor(camera.width / camera.baseWidth)
  end

  if camera.baseHeight > 0 then
    height_scale = math.floor(camera.height / camera.baseHeight)
  end

  if big_scale then
    if width_scale and width_scale > big_scale then
      width_scale = width_scale - difference
    end

    if height_scale and height_scale > big_scale then
      height_scale = height_scale - difference
    end
  end

  if width_scale then
    if height_scale then
      local smallest_scale = math.min(width_scale, height_scale)
      camera.setScale(smallest_scale, smallest_scale)
      camera._resolution_offset.x = math.round((camera.width - (smallest_scale * camera.baseWidth)) / (2 * smallest_scale))
      camera._resolution_offset.y = math.round((camera.height - (smallest_scale * camera.baseHeight)) / (2 * smallest_scale))
    else
      camera.setScale(width_scale, width_scale)
      camera._ro.x = math.round((camera.width - (width_scale * camera.baseWidth)) / (2 * width_scale))
      camera._resolution_offset.y = math.round((camera.height - (width_scale * camera.baseHeight)) / (2 * width_scale))
    end 
  elseif height_scale then
    camera.setScale(height_scale, height_scale)
    camera._resolution_offset.x = math.round((camera.width - (height_scale * camera.baseWidth)) / (2 * height_scale))
    camera._resolution_offset.y = math.round((camera.height - (height_scale * camera.baseHeight)) / (2 * height_scale))
  else
    camera._resolution_offset.x = 0
    camera._resolution_offset.y = 0
  end
end
--gets the mouse position in the game
function camera.getWorldMousePosition()
  -- Only calculate it once every frame
  if camera._lastMousePos.x == nil then
    camera._lastMousePos.x, camera._lastMousePos.y = camera.toWorld(camera.getWindowMousePosition())
  end
  return camera._lastMousePos.x, camera._lastMousePos.y
end

--get the mouse position on the screen
function camera.getWindowMousePosition()
  return love.mouse.getPosition()
end

--gets the point in world by its point on screen
function camera.toWorld(x, y)
  if (camera.isSet) then 
    x, y = love.graphics.inverseTransformPoint(x, y)
  else
    camera.set()
    x, y = love.graphics.inverseTransformPoint(x, y)
    camera.unset()
  end
  return x, y
end


--gets the point on screen by its point in world
function camera.toScreen(x, y)
  if (camera.isSet) then 
    x, y = love.graphics.transformPoint(x, y)
  else
    camera.set() 
    x, y = love.graphics.transformPoint(x, y)
    camera.unset()
  end
  return x, y
end

function camera.shake(duration, rate, x, y)
  camera._original_duration = duration or 0.35
  camera._duration = camera._original_duration
  camera._rate = rate or (1 / 120)
  camera._wait_time = 0
  camera._shake_offset.x, camera._shake_offset.y = 0, 0
  camera._x = x or 0.5
  camera._y = y or x or 0.2
end

function camera.clearShake()
  camera._duration = 0
end

function camera.setShakePower(power)
  camera._shake_power = power
end
local p = 0
function camera.update(dt)
  if camera._duration > 0 then
    camera._duration = camera._duration - dt
    if camera._wait_time > 0 then
      camera._wait_time = camera._wait_time - dt
    else
      camera._wait_time = camera._rate
      p = (camera._duration / (camera._original_duration or 1))
      camera._shake_offset.x = p * love.math.random(-camera._x, camera._x) * camera._shake_power
      camera._shake_offset.y = p * love.math.random(-camera._y, camera._y) * camera._shake_power
    end
  else
      camera._shake_offset.x, camera._shake_offset.y = 0, 0
  end

  if camera._lastMousePos.x then
    camera._lastMousePos.x = nil
  end
end

function camera.drawUI(fn, ...)
  camera:unset()
  fn(...)
  camera:set()
end

function camera.drawBorders()
  if camera.borders then
    love.graphics.setColor(camera.bordersColor)
    love.graphics.rectangle('fill', 0, 0, camera.width, camera._ro.y * camera.scaleX)
    love.graphics.rectangle('fill', 0, camera.height - camera._ro.y * camera.scaleX, camera.width, camera._ro.y * camera.scaleX)
    love.graphics.rectangle('fill', 0, camera._ro.y * camera.scaleX, camera._ro.x * camera.scaleX , camera.height - (camera._ro.y * camera.scaleX * 2))
    love.graphics.rectangle('fill', camera.width - camera._ro.x * camera.scaleX, camera._ro.y * camera.scaleX, camera._ro.x * camera.scaleX, camera.height - (camera._ro.y * camera.scaleX * 2))
    love.graphics.setColor(1, 1, 1, 1)
  end
end

return camera