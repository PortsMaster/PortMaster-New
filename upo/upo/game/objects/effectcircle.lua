local effectcircle = {}
listOfCircleEffects = {}

function newCircleEffect(radius, speed)
  local effect = {}
  effect.radius = radius
  effect.speed = speed
  effect.lineWidth = 4
  
  table.insert(listOfCircleEffects, effect)
end

function effectcircle:update(dt)    
  for i, v in ipairs(listOfCircleEffects) do
  v.radius = v.radius + dt * v.speed
  v.lineWidth = v.lineWidth + dt * 2
    if (v.radius > 2000) then
      table.remove(listOfCircleEffects, i)
    end
  end
end

function effectcircle:draw()
  love.graphics.setColor(1, 1, 1, 0.4)
  for _, v in ipairs(listOfCircleEffects) do
    love.graphics.setLineWidth(v.lineWidth)
    love.graphics.circle("line", gw/2, gh/2, v.radius)
  end
end

function effectcircle:clearCircleEffects()
  for i in pairs(listOfCircleEffects) do
    listOfCircleEffects[i] = nil
  end
end

return effectcircle
