local object = object:extend()

function object:create(x, y)
    self.x = x
    self.y = y

    self.sprite = sprite("particles/land1.png", "particles/land2.png", 0.09)
    game.shadows:add(self)
end

function object:update(dt)
    self.sprite:update(dt)
    if self.sprite:isFinished() then
        self:destroy()
    end
end

function object:draw()
    if game.subpixel then
        self.sprite:draw(self.x, self.y)
    else
        self.sprite:draw(math.round(self.x), math.round(self.y))
    end
end

function object:remove()
    game.shadows:remove(self)
end

return object