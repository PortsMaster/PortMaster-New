circle = {}
listOfCircles = {}

function createCircle(radius, speed, rotation, direction)
  local crl = {}
  crl.radius = radius
  crl.rotation = rotation
  if (direction == 0) then
    crl.speed = -speed
    crl.x = 500
    crl.y = math.random(0,400)
  elseif (direction == 1) then
    crl.speed = speed
    crl.x = 0
    crl.y = 0
  end

  table.insert(listOfCircles, crl)
end

function circle:update(dt)
  for i, v in ipairs(listOfCircles) do
    v.x = v.x + v.speed * dt
    if (v.x < -500 or v.x > 1000) then
      table.remove(listOfCircles, i)
    end
  end
end

function circle:draw()
  for i, v in ipairs(listOfCircles) do
    love.graphics.setColor(28 / 255, 31 / 255, 39 / 255, 1)
    love.graphics.circle("fill", math.sin(v.rotation)*v.x - math.cos(v.rotation)*v.y + gw/2,
                                 math.cos(v.rotation)*v.x + math.sin(v.rotation)*v.y + gh/2, v.radius)
  end
end

function circle:clear()
  for i, v in ipairs(listOfCircles) do
    listOfCircles[i] = nil
  end
end

return circle
