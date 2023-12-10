local Flip = {}
local infoTable = {}

function Flip.coin()
    return math.random() > 0.5
end

function Flip.get(key)
    local state = infoTable[key]
    if not state then
        state = 1
    end
    state = math.abs(state - 1)
    infoTable[key] = state
    return state == 1
end

return Flip