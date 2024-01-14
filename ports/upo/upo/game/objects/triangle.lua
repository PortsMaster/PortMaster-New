triangle = {}
listOfTriangles = {}

function createTriangle(targetX, targetY, rotation, speed)
  local trn = {}
  trn.rotation = rotation
  trn.speed = speed
  trn.targetX = targetX
  trn.targetY = targetY
  trn.x = 0
  trn.y = 0
  
  table.insert(listOfTriangles, trn)
end

function triangle:update(dt)
  for i, v in ipairs(listOfTriangles) do
    if (v.rotation == 1) then
      v.y = v.y - v.speed * dt
    elseif (v.rotation == 2) then
      v.x = v.x + math.sin(45) * v.speed * dt
      v.y = v.y - math.cos(45) * v.speed * dt
    elseif (v.rotation == 3) then
      v.x = v.x + v.speed * dt
    elseif (v.rotation == 4) then
      v.x = v.x + math.sin(45) * v.speed * dt
      v.y = v.y + math.cos(45) * v.speed * dt
    elseif (v.rotation == 5) then
      v.y = v.y + v.speed * dt
    elseif (v.rotation == 6) then
      v.x = v.x - math.sin(45) * v.speed * dt
      v.y = v.y + math.cos(45) * v.speed * dt
    elseif (v.rotation == 7) then
      v.x = v.x - v.speed * dt
    elseif (v.rotation == 8) then
      v.x = v.x - math.sin(45) * v.speed * dt
      v.y = v.y - math.cos(45) * v.speed * dt
    end
    if (math.abs(v.x) > 1800 or math.abs(v.y) > 1800) then
      table.remove(listOfTriangles, i)
    end
  end
end

function triangle:draw()
    for _, v in ipairs(listOfTriangles) do
      love.graphics.push()
      love.graphics.translate(v.targetX, v.targetY)
      love.graphics.setColor(28 / 255, 31 / 255, 39 / 255, 1)
      if (v.rotation == 1) then
        love.graphics.polygon('fill', v.x-12, v.y+15,
                                      v.x+0, v.y-15,
                                      v.x+12, v.y+15)                                    
      elseif (v.rotation == 2) then
        love.graphics.polygon('fill', v.x-17, v.y,
                                      v.x-1, v.y+16,
                                      v.x+12, v.y-12)  
      elseif (v.rotation == 3) then
        love.graphics.polygon('fill', v.x-15, v.y-12,
                                      v.x-15, v.y+12,
                                      v.x+15, v.y)
      elseif (v.rotation == 4) then
        love.graphics.polygon('fill', v.x-17, v.y,
                                      v.x-1, v.y-16,
                                      v.x+12, v.y+12) 
      elseif (v.rotation == 5) then
        love.graphics.polygon('fill', v.x-12, v.y-15,
                                      v.x+0, v.y+15,
                                      v.x+12, v.y-15)  
      elseif (v.rotation == 6) then
        love.graphics.polygon('fill', v.x+17, v.y,
                                      v.x+1, v.y-16,
                                      v.x-12, v.y+12) 
      elseif (v.rotation == 7) then
        love.graphics.polygon('fill', v.x+15, v.y-12,
                                      v.x+15, v.y+12,
                                      v.x-15, v.y)
      elseif (v.rotation == 8) then
        love.graphics.polygon('fill', v.x+17, v.y,
                                      v.x+1, v.y+16,
                                      v.x-12, v.y-12)  
      end
      love.graphics.pop()
    end
end

function triangle:clear()
  for i in pairs(listOfTriangles) do
    listOfTriangles[i] = nil
  end
end

return triangle
