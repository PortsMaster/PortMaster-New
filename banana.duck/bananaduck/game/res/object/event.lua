local object = object:extend()
object.tag = "event"
object.layer = 10

function object:create(ldtkEntity)
    game.world:add(self, ldtkEntity.x, ldtkEntity.y, ldtkEntity.width, ldtkEntity.height)
    self.events = ldtkEntity.props.events
    self.once = ldtkEntity.props.once
    self.triggered = false
end

function object:playerEnter()
    if self.once and self.triggered then
        return
    end

    for index, value in ipairs(self.events) do
        game.level:fireEvent(value)
    end

    self.triggered = true
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