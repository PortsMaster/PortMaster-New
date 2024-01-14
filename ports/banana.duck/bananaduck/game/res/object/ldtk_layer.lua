local object = object:extend()

function object:create(layer)
    if layer then
        self.object = layer
        game.shadows:add(self)
    else
        self:destroy()
    end
end

function object:draw()
    if self.object then
        self.object:draw()
    end
end

function object:remove()
    game.shadows:remove(self)
end

return object