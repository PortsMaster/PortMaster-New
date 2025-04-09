laser = {}
listOfLasers = {}

function createLaser(speed)
  local lsr = {}
  lsr.speed = speed
  lsr.direction = math.random(1,4) --1=down, 2=right, 3=left, 4=up
  lsr.side = math.random(1,2)
  if (lsr.direction == 1) then
    if (lsr.side == 1) then    
      lsr.x = 510
    else
      lsr.x = 960
    end
    lsr.y = -20
    lsr.width = 450
    lsr.height = 16
  elseif (lsr.direction == 2) then
    lsr.x = 520
    if (lsr.side == 1) then    
      lsr.y = 90
    else
      lsr.y = 540
    end
    lsr.width = 16
    lsr.height = 450
  elseif (lsr.direction == 3) then
    lsr.x = 1450
    if (lsr.side == 1) then    
      lsr.y = 90
    else
      lsr.y = 540
    end
    lsr.width = 16
    lsr.height = 450
  elseif (lsr.direction == 4) then
    if (lsr.side == 1) then    
      lsr.x = 510
    else
      lsr.x = 960
    end
    lsr.y = gh+20
    lsr.width = 450
    lsr.height = 16
  end
  
  table.insert(listOfLasers, lsr)
end

function laser:update(dt)
  for i, v in ipairs(listOfLasers) do
    if (v.direction == 1) then
      v.y = v.y + v.speed * dt
    elseif (v.direction == 2) then
      v.x = v.x + v.speed * dt
    elseif (v.direction == 3) then
      v.x = v.x - v.speed * dt
    elseif (v.direction == 4) then
      v.y = v.y - v.speed * dt
    end
    
    if (math.abs(v.x) > 1800 or math.abs(v.y) > 1800) then
      table.remove(listOfLasers, i)
    end
  end
end

function laser:draw()
    for i, v in ipairs(listOfLasers) do
      love.graphics.setColor(28 / 255, 31 / 255, 39 / 255, 1)
      love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
    end
end

function laser:clear()
  for i in pairs(listOfLasers) do
    listOfLasers[i] = nil
  end
end

return laser
