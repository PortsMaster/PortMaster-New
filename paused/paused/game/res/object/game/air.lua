-- extending the object class
local object = object:extend()

object.layer = 5


-- create is called once the object is just created in the room
function object:create(entity)
    self.col = collision.rectangle(entity.x, entity.y, entity.width, entity.height)
    global.game.collisions.air[self] = self
    self.force = entity.props.force
    self.glide = entity.props.glide
    self.timer = 0
end

function object:update(dt)
    self.timer = self.timer - dt
    if self.timer < 0 then
        self.timer = math.randomFloat(0.05, 0.15)
        for x = 0, math.floor(self.col.w / 8), 1 do
            for y = 0, math.floor(self.col.h / 8), 1 do
                if math.random(0, 100) < 15 then
                    objects.windUp(self.col.x + x * 8 + math.randomFloat(-4, 4), self.col.y + y * 8 + math.randomFloat(-4, 4))
                end
            end
        end
    end
end

-- draw is called once every draw frame
function object:draw()
    color.light_grey:set(0.002)
    graphics.rectangle('fill', self.col.x, self.col.y, self.col.w, self.col.h)
end

function object:remove()
    global.game.collisions.air[self] = nil
end

return object