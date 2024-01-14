level04 = {}

function level04:load()
  respawnTime = 0
end

function level04:update(dt, timer)
  if (respawnTime >= 6/math.sqrt(timer)+1) then
    respawnTime = 0
    createCircle(45, 220+math.sqrt(timer*1.7), math.random(2*math.pi*100)/100, 0)
    createSquare(220, 200)
    createLaser(250)
    createKite(cursor:getPositionX(), cursor:getPositionY(), 300+math.sqrt(timer*0.7))
  else
    respawnTime = respawnTime + dt
  end
end

return level04
