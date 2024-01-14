local object = object:extend()

function object:create(x, y)
    self.x = x
    self.y = y

    self.sprite = sprite("particles/particle.png", 0.09)
    game.shadows:add(self)

    self.lifetime = math.randomFloat(0.5, 1.5)
    self.timer = self.lifetime
    self.speed = math.randomFloat(1, 3)
    self.angle = math.randomFloat(0, math.pi * 2)
    self._cos = math.cos(self.angle) * self.speed
    self._sin = math.sin(self.angle) * self.speed
    self.rotation = math.randomFloat(0, math.pi * 2)
    self.rotationSpeed = math.randomFloat(-math.pi, math.pi)
end

function object:update(dt)
    self.timer = self.timer - dt
    self.x = self.x + self._cos * dt
    self.y = self.y + self._sin * dt
    self.rotation = self.rotation + self.rotationSpeed * dt

    self.sprite:setScale(self.timer / self.lifetime, self.timer / self.lifetime)
    self.sprite:update(dt)
    if self.timer < 0 then
        self:destroy()
    end
end

function object:draw()
    if game.subpixel then
        self.sprite:draw(self.x, self.y, self.rotation)
    else
        self.sprite:draw(math.round(self.x), math.round(self.y), 0)
    end
end

function object:remove()
    game.shadows:remove(self)
end

return object