circle2 = {}
listOfCircles2 = {}

function createCircle2(targetX, targetY, radius, speed)
  local crl = {}
  crl.targetX = targetX
  crl.targetY = targetY
  crl.radius = radius
  crl.speed = -speed
  crl.x = gw/2
  crl.y = gh/2
  crl.rotation = math.atan2(gh/2-crl.targetY, gw/2-crl.targetX)

  table.insert(listOfCircles2, crl)
end

function circle2:update(dt)
  for i, v in ipairs(listOfCircles2) do
    v.x = v.x + math.cos(v.rotation) * v.speed * dt
    v.y = v.y + math.sin(v.rotation) * v.speed * dt
    if (math.abs(v.x) > 2000 or math.abs(v.y) > 2000) then
      table.remove(listOfCircles2, i)
    end
  end
end

function circle2:draw()
  for i, v in ipairs(listOfCircles2) do
    love.graphics.setColor(28 / 255, 31 / 255, 39 / 255, 1)
    love.graphics.circle("fill", v.x, v.y, v.radius)
  end
end

function circle2:clear()
  for i, v in ipairs(listOfCircles2) do
    listOfCircles2[i] = nil
  end
end

return circle2
