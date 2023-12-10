kite = {}
listOfKites = {}

function createKite(targetX, targetY, speed)
  local kte = {}
  kte.rotation = math.random(2*math.pi*100)/100
  kte.speed = -speed
  kte.targetX = targetX
  kte.targetY = targetY
  kte.x = 1000

  table.insert(listOfKites, kte)
end

function kite:update(dt)
  for i, v in ipairs(listOfKites) do
    v.x = v.x + v.speed * dt
    if (v.x < -800) then
      table.remove(listOfKites, i)
    end
  end
end

function kite:draw()
  for _, v in ipairs(listOfKites) do      
    love.graphics.push()
    love.graphics.translate(math.sin(v.rotation)*v.x+v.targetX, math.cos(v.rotation)*v.x+v.targetY)
    love.graphics.rotate(v.rotation)
    love.graphics.setColor(28 / 255, 31 / 255, 39 / 255, 1)
    love.graphics.circle("fill", 0, 0, 28, 4)
    love.graphics.pop()            
  end
end

function kite:clear()
  for i in pairs(listOfKites) do
    listOfKites[i] = nil
  end
end

return kite
