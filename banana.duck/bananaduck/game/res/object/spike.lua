local object = object:extend()
object.tag = "danger"
object.layer = 3

local SPIKE_HITBOX = 1

function object:create(x, y, direction)
    self.sprite = sprite("objects/spike.png")
    game.shadows:add(self)

    if direction == 1 then
        self.x = x
        self.y = y + 1
        game.world:add(self, self.x + 1, self.y + 3 - SPIKE_HITBOX, 3, SPIKE_HITBOX)
    elseif direction == 3 then
        self.x = x - 1
        self.y = y + 3
        self.sprite:setScale(1, -1)
        game.world:add(self, self.x + 1, self.y - 3, 3, SPIKE_HITBOX)
    elseif direction == 2 then
        self.x = x + 1
        self.y = y + 5
        self.sprite:setRotation(-math.pi / 2)
        game.world:add(self, self.x + 3 - SPIKE_HITBOX, self.y -4, SPIKE_HITBOX, 3)
    elseif direction == 4 then
        self.x = x + 3
        self.y = y
        self.sprite:setRotation(math.pi / 2)
        game.world:add(self, self.x - 3, self.y + 1, SPIKE_HITBOX, 3)
    end
end

function object:draw()
    self.sprite:draw(self.x, self.y)

    if DEBUG then
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.rectangle("fill", game.world:getRect(self))
        love.graphics.setColor(1, 1, 1)
    end
end

function object:remove()
    game.shadows:remove(self)
    game.world:remove(self)
end

return object