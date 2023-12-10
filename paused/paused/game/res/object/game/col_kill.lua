-- extending the object class
local object = object:extend()

object.layer = 5

-- create is called once the object is just created in the room
function object:create(entity)
    self.col = collision.rectangle(entity.x, entity.y, entity.width, entity.height)
    global.game.collisions.kill[self] = self

end

-- draw is called once every draw frame
function object:draw()
    -- graphics.setColor(1, 0.2, 0.2)
    -- love.graphics.rectangle('fill', self.col.x, self.col.y, self.col.w, self.col.h)
end

function object:remove()
    global.game.collisions.kill[self] = nil
end

return object