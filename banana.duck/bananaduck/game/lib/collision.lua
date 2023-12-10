local collision = {}

local rectangle = class:extend()
function rectangle:new(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
end

function collision.checkRectangles(a, b)
    return a.x < b.x + b.w and
           a.x + a.w > b.x and
           a.y < b.y + b.h and
           a.y + a.h > b.y
end

function collision.pointInRectangle(x, y, rectangle)
    return x >= rectangle.x and
           x <= rectangle.x + rectangle.w and
           y >= rectangle.y and
           y <= rectangle.y + rectangle.h
end


collision.rectangle = rectangle

return collision