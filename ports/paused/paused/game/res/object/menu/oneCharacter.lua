-- extending the object class
local object = object:extend()

object.layer = 0

-- create is called once the object is just created in the room
function object:create(entity)
    self.character = entity.props.character
end

-- update is called once every frame
function object:update(dt)
    if global.level then
        global.level:selectCharacter(self.character)
        if self.character == 1 then
            global.duckling.position.x = -100
            global.duckling.position.y = -100
            global.bunny.paused = false
        elseif self.character == 2 then
            global.bunny.position.x = -100
            global.bunny.position.y = -100
            global.duckling.paused = false
        end
    end
end

-- draw is called once every draw frame
function object:draw()
    
end

return object