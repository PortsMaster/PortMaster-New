local object = object:extend()
object.tag = "danger"
object.layer = 10


function object:create(ldtkEntity)
    game.world:add(self, ldtkEntity.x, ldtkEntity.y, ldtkEntity.width, ldtkEntity.height)
end

function object:remove()
    game.world:remove(self)
end

function object:draw()
    if DEBUG then
        graphics.setColor(1, 0, 0, 0.5)
        graphics.rectangle("fill", game.world:getRect(self))
    end
end

return object