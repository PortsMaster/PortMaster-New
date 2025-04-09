level05 = {}

local respawnTime1

function level05:load()
  respawnTime1 = 0
end

function level05:update(dt, timer)
  if (respawnTime1 > 2/math.sqrt(timer)) then
    if (timer > 130) then
      createKite(cursor:getPositionX(), cursor:getPositionY(), 380)
    else
      createKite(cursor:getPositionX(), cursor:getPositionY(), 250+timer)
    end
    respawnTime1 = 0
  else
    respawnTime1 = respawnTime1 + dt
  end
end

return level05
