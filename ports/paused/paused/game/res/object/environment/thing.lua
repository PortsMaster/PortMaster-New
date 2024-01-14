-- extending the object class
local object = object:extend()

object.layer = 0

-- persistent is whether the object should remain while changing rooms or not
object.persistent = false

-- create is called once the object is just created in the room
function object:create(entity)
    self.x = entity.x
    self.y = entity.y
    self.image = resource.image(entity.props.image)
    self:setLayer(entity.props.layer)
    self.id = entity.props.id
    self.floaty = entity.props.floaty
    self.spd = entity.props.spd
    self.timer = self.spd or 0
    self.offset = 0
    self.startDelay = entity.props.startDelay or 0
    self.timer = self.timer + self.startDelay

    if entity.props.rw then
        local repeated_width = entity.props.rw
        entity.props.rw = nil
        for i = 1, math.floor(entity.width / repeated_width) - 1, 1 do
            local new_entity = table.clone(entity)
            entity.x = entity.x + repeated_width
            new_entity.x = entity.x
            objects.thing(new_entity)
        end
    end
end

-- update is called once every frame
function object:update(dt)
    if self.floaty then
        self.timer = self.timer - dt
        if self.timer <= 0 then
            self.timer = self.spd
            if self.offset == 0 then
                self.offset = 1
            else
                self.offset = 0
            end
        end
    end
end

-- draw is called once every draw frame
function object:draw()
    color.reset()
    graphics.draw(self.image, self.x, self.y + (global.game.collisions.ids[self.id] and global.game.collisions.ids[self.id].offset or 0) + self.offset)
end

return object