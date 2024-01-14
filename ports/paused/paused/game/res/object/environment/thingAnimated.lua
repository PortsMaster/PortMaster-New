-- extending the object class
local object = object:extend()

object.layer = 0

-- persistent is whether the object should remain while changing rooms or not
object.persistent = false

-- create is called once the object is just created in the room
function object:create(entity)
    self.x = entity.x
    self.y = entity.y
    self.sprite = sprite(unpack(string.split(entity.props.imgs, ', ')))
    self.sprite:setSpeed(entity.props.spd)
    self.sprite.scaleX = (entity.props.flipped and -1 or 1)
    self:setLayer(entity.props.layer)
    self.id = entity.props.id

    if entity.props.rw then
        local repeated_width = entity.props.rw
        entity.props.rw = nil
        for i = 1, math.floor(entity.width / repeated_width) - 1, 1 do
            local new_entity = table.clone(entity)
            entity.x = entity.x + repeated_width
            new_entity.x = entity.x
            objects.thingAnimated(new_entity)
        end
    end
end

-- update is called once every frame
function object:update(dt)
    self.sprite:update(dt)
end

-- draw is called once every draw frame
function object:draw()
    self.sprite:draw(self.x, self.y + (global.game.collisions.ids[self.id] and global.game.collisions.ids[self.id].offset or 0))
end

return object