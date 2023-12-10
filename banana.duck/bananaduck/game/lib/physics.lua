-- TODO
local physics = {}

function physics.rectangle(x, y, w, h)
    return {x = x, y = y, w = w, h = h}
end

function physics.isColliding(a, b)
    if not a or not b then
        return false
    end
    
    return a.x < b.x + b.w and
           b.x < a.x + a.w and
           a.y < b.y + b.h and
           b.y < a.y + a.h
end

return physics