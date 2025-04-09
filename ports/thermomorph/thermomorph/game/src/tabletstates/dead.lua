local Dead = Tablet:addState('Dead')

function Dead:canCrash() return false end

function Dead:update(dt)
  -- No update operation when the player is dead.
end
