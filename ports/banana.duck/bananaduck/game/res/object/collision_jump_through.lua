local object = object:extend()
object.tag = "jump_through"
object.layer = 10

function object:create(ldtkEntity)
    self.position = vector(ldtkEntity.x, ldtkEntity.y)
    game.world:add(self, ldtkEntity.x, ldtkEntity.y, ldtkEntity.width, ldtkEntity.height)
end

function object:remove()
    game.world:remove(self)
end

function object:draw()
    if DEBUG then
        color.reset(0.5)
        graphics.rectangle("fill", game.world:getRect(self))
    end
end

return object