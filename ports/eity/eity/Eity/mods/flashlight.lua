flashlight = {}


function flashlight.ApplyMod(dt)
  for i, v in ipairs(listOfArrows) do
    if (v.direction == 4 and v.tempPosition < gh * 0.820) or (v.direction == 2 and v.tempPosition > gh * 0.180) or
      (v.direction == 1 and v.tempPosition < gw * 0.680) or (v.direction == 3 and v.tempPosition > gw * 0.320) then
    v.alpha = v.alpha + 0.0025 * modManager.getSpeed() * v.speed * 0.00425
    end
  end
  for i, v in ipairs(listOfSliders) do
    if (v.direction == 4 and v.tempPosition < gh * 0.815) or (v.direction == 2 and v.tempPosition > gh * 0.185) or
      (v.direction == 1 and v.tempPosition < gw * 0.675) or (v.direction == 3 and v.tempPosition > gw * 0.325) then
    v.alpha = v.alpha + 0.0025 * modManager.getSpeed() * v.speed * 0.00425
    end
  end
end

return flashlight
