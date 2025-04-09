laser2 = {}
listOfLasers2 = {}

function createLaser2(speed)
  local lsr = {}
  lsr.speed = speed
  lsr.direction = math.random(1,4) --1=down, 2=right, 3=left, 4=up
  lsr.phase = 1
  if (lsr.direction == 1) then
    lsr.x = 0
    lsr.y = -20
    lsr.width = gw
    lsr.height = 24
  elseif (lsr.direction == 2) then
    lsr.x = 500
    lsr.y = 0
    lsr.width = 24
    lsr.height = gh
  elseif (lsr.direction == 3) then
    lsr.x = 1450
    lsr.y = 0
    lsr.width = 24
    lsr.height = gh
  elseif (lsr.direction == 4) then
    lsr.x = 0
    lsr.y = gh+20
    lsr.width = gw
    lsr.height = 24
  end
  
  table.insert(listOfLasers2, lsr)
end

function laser2:update(dt)
  for i, v in ipairs(listOfLasers2) do
    if (v.direction == 1) then
      if (v.phase == 1) then
        v.y = v.y + v.speed * dt
        if (v.y > 540) then
          v.phase = 2
        end
      elseif (v.phase == 2) then
        v.y = v.y - v.speed * dt
      end
    elseif (v.direction == 2) then
      if (v.phase == 1) then
        v.x = v.x + v.speed * dt
        if (v.x > 960) then
          v.phase = 2
        end
      elseif (v.phase == 2) then
        v.x = v.x - v.speed * dt
      end
    elseif (v.direction == 3) then
      if (v.phase == 1) then
        v.x = v.x - v.speed * dt
        if (v.x < 960) then
          v.phase = 2
        end
      elseif (v.phase == 2) then
        v.x = v.x + v.speed * dt
      end
    elseif (v.direction == 4) then
      if (v.phase == 1) then
        v.y = v.y - v.speed * dt
        if (v.y < 540) then
          v.phase = 2
        end
      elseif (v.phase == 2) then
        v.y = v.y + v.speed * dt
      end
    end  
    
    if (math.abs(v.x) > 1800 or math.abs(v.y) > 1800) then
      table.remove(listOfLasers2, i)
    end
  end
end

function laser2:draw()
    for i, v in ipairs(listOfLasers2) do
      love.graphics.setColor(28 / 255, 31 / 255, 39 / 255, 1)
      love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
    end
end

function laser2:clear()
  for i in pairs(listOfLasers2) do
    listOfLasers2[i] = nil
  end
end

return laser2
