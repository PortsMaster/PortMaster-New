local object = class:extend()

----- [Variables] -----

-- A persistent object doesn't get destroyed while changing the room.
object.persistent = false

-- Objects with higher layers are drawn on top of objects with lower layers.
-- Note: this should only be changed using Object:setLayer to take effect.
object.layer = 0


-- constructor
function object:new(...)
    -- adds the object to the current room.
    room._add(self, ...)
end

----- [Functions] -----

-- Removes the object at the end of the frame.
function object:destroy()
    room._remove(self)
end

-- Sets the persistent state of the object.
function object:setPersistent(persistent)
    self.persistent = persistent
end

-- Changes the layer of the object.
function object:setLayer(layer)
    room._changeLayer(self, layer)
end

----- [CALLBACKS] -----

-- Create is called once the object is created and added to the room.
function object:create(...)
    
end

-- Update is called once each update cycle.
function object:update(dt)
    
end

-- Draw is called once every draw cycle.
function object:draw()
    
end

-- Remove is called when the object is destroyed.
function object:remove()
    
end


return object