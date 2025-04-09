level02 = {}

local respawnTime

function level02:load()
  respawnTime = 0
end

function level02:update(dt, timer)
  if (respawnTime >= 6/math.sqrt(timer)) then
    respawnTime = 0
    createLaser2(300)
  else
    respawnTime = respawnTime + dt
  end
end

return level02
