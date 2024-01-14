level06 = {}

function level06:load()
  respawnTime = 0
end

function level06:update(dt, timer)
  if (respawnTime >= 8/math.sqrt(timer)) then
    respawnTime = 0
    createCircle(45, 300+math.sqrt(timer*3), math.random(2*math.pi*100)/100, 0)
    createSquare(220, 320)
    createLaser(400)
    createKite(cursor:getPositionX(), cursor:getPositionY(), 400+math.sqrt(timer*2))
  else
    respawnTime = respawnTime + dt
  end
end

return level06
