local object = object:extend()
object.tag = "danger"


function object:create(ldtkEntity)
    self.sprite = sprite("objects/blade1.png", "objects/blade2.png", "objects/blade3.png", "objects/blade4.png", 0.1)
    self.sprite:setOrigin(8, 8)
    self.position = vector(ldtkEntity.x, ldtkEntity.y)

    if not ldtkEntity.props.pointOffset then
        ldtkEntity.props.pointOffset = {}
    else
        local split
        for index, value in ipairs(ldtkEntity.props.pointOffset) do
            split = value:split(",")
            ldtkEntity.props.pointOffset[index] = vector(tonumber(split[1]), tonumber(split[2]))
        end
    end

    self.path = {
        vector(self.position.x, self.position.y)
    }

    for index, value in ipairs(ldtkEntity.props.path) do
        self.path[index + 1] = vector(value.cx * 8 + 4, value.cy * 8 + 4)
        if ldtkEntity.props.pointOffset[index] then
            self.path[index + 1] = self.path[index + 1] + vector(ldtkEntity.props.pointOffset[index].x, ldtkEntity.props.pointOffset[index].y)
        end
    end

    self.pathSize = #self.path
    if self.pathSize > 1 then
        self.pathCurrent = 2
    end

    self.pathDelay = ldtkEntity.props.delay
    self.delayTimer = self.pathDelay
    self.speed = ldtkEntity.props.speed

    self._dif = vector(0, 0)

    game.shadows:add(self)
    game.world:add(self, self.position.x - 5, self.position.y - 5, 10, 10)
end

function object:update(dt)
    if game.paused then
        return
    end
    self.sprite:update(dt)
    if self.delayTimer <= 0 then
        if self.pathSize > 1 then
            self._dif = self.path[self.pathCurrent] - self.position
            self.position.x = self.position.x + math.sign(self._dif.x) * math.min(self.speed * dt, math.abs(self._dif.x))
            self.position.y = self.position.y + math.sign(self._dif.y) * math.min(self.speed * dt, math.abs(self._dif.y))
            if self.position.x == self.path[self.pathCurrent].x and self.position.y == self.path[self.pathCurrent].y then
                self.pathCurrent = self.pathCurrent + 1
                self.delayTimer = self.pathDelay
                if self.pathCurrent > self.pathSize then
                    self.pathCurrent = 1
                end
            end
        end
    else
        self.delayTimer = self.delayTimer - dt
    end
    game.world:update(self, self.position.x - 5, self.position.y - 5)
end

function object:draw()
    if game.subpixel then
        self.sprite:draw(self.position.x, self.position.y)
    else
        self.sprite:draw(math.floor(self.position.x), math.floor(self.position.y))
    end

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