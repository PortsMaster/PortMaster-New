-- extending the object class
local object = object:extend()

--[[
    Higher layers are drawn on top of lower layers.
    This can only be set here or using the self:setLayer(layer) function.
    Note: directly changing self.layer won't have any effect!
]]
object.layer = 0

-- persistent is whether the object should remain while changing rooms or not
object.persistent = false

-- create is called once the object is just created in the room
function object:create(x, y, ...)
    self.position = vector(x, y)

    
end

-- update is called once every frame
function object:update(dt)
    
end

-- draw is called once every draw frame
function object:draw()
    
end

return object