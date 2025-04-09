-- extending the object class
local object = object:extend()

object.layer = 0

-- persistent is whether the object should remain while changing rooms or not
object.persistent = false

-- create is called once the object is just created in the room
function object:create(entity)
    self.text = entity.props.text
    self.x = entity.x
    self.y = entity.y
end

-- draw is called once every draw frame
function object:draw()
    color.white:set()
    graphics.print(self.text, self.x, self.y)
end

return object