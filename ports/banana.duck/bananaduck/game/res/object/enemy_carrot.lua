local object = object:extend()
object.layer = 5
object.tag = "danger"

local JUMP_HEIGHT = 16
local GRAVITY = 350

function object:create(ldtkEntity)
    self.sprites = {
        idle = sprite("carrot-man/1.png", "carrot-man/2.png", "carrot-man/3.png", "carrot-man/4.png", 0.1),
        jump = sprite("carrot-man/5.png"),
        fall = sprite("carrot-man/6.png")
    }
    self.sprite = self.sprites.idle
    self.flipped = false

    for _, sprite in pairs(self.sprites) do
        sprite:setOrigin(6, 0)
    end

    self.position = vector(ldtkEntity.x + 4, ldtkEntity.y - 3)

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
        self.path[index + 1] = vector(value.cx * 8 + 4, value.cy * 8 - 3)
        if ldtkEntity.props.pointOffset[index] then
            self.path[index + 1] = self.path[index + 1] + vector(ldtkEntity.props.pointOffset[index].x, ldtkEntity.props.pointOffset[index].y)
        end
    end

    self.direction = 1
    self.pathSize = #self.path
    self.pathCurrent = 1
    self.flipped = self.path[1].x > self.path[2].x

    self.jumpDelay = ldtkEntity.props.delay
    self.delayTimer = self.pathDelay
    self.speed = ldtkEntity.props.speed

    self.groundY = ldtkEntity.y - 3
    self.velocityY = 0
    self.jumpTimer = self.jumpDelay
    self.jumpVelocity = -math.sqrt(2 * GRAVITY * JUMP_HEIGHT)


    self._dif = vector(0, 0)

    game.shadows:add(self)
    game.world:add(self, self.position.x - 2, self.position.y + 5, 4, 4)
end

function object:update(dt)
    if game.paused then
        return
    end
    self.sprite:update(dt)

    if self.jumpTimer > 0 then
        self.jumpTimer = self.jumpTimer - dt
        self.velocityY = self.jumpVelocity
        self.nextPath = self.pathCurrent + 1
        if self.path[self.nextPath] == nil then
            self.nextPath = 1
        end

        self.direction = self.path[self.pathCurrent].x > self.path[self.nextPath].x and -1 or 1
        return
    end

    self.velocityY = self.velocityY + GRAVITY * dt
    self.position.y = self.position.y + self.velocityY * dt

    if self.position.y > self.groundY then
        self.position.y = self.groundY
        self.velocityY = 0
        self.jumpTimer = self.jumpDelay
    end

    if self.direction == 1 then
        self.flipped = false
    elseif self.direction == -1 then
        self.flipped = true
    end

    if self.direction == 1 then
        if self.position.x > self.path[self.nextPath].x - 8 then
            self.pathCurrent = self.nextPath
        end
    else
        if self.position.x < self.path[self.nextPath].x + 8 then
            self.pathCurrent = self.nextPath
        end
    end

    if self.pathSize > 1 then
        if self.velocityY ~= 0 then
            self.position.x = self.position.x + self.direction * self.speed * dt
        end
    end


    if self.velocityY == 0 then
        self.sprite = self.sprites.idle
    else
        if self.velocityY > 0 then
            self.sprite = self.sprites.fall
        else
            self.sprite = self.sprites.jump
        end
    end

    game.world:update(self, self.position.x - 2, self.position.y + 5)
end

function object:draw()
    self.sprite:setScale(self.flipped and -1 or 1, 1)
    if game.subpixel then
        self.sprite:draw(self.position.x, self.position.y)
    else
        self.sprite:draw(math.floor(self.position.x), math.floor(self.position.y))
    end

    if DEBUG then
        love.graphics.setColor(0, 1, 0, 0.5)
        love.graphics.rectangle("fill", game.world:getRect(self))
        if self.path[self.nextPath] then
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", self.path[self.nextPath].x, self.path[self.nextPath].y + 10, 1, 1)
        end
    end
end

function object:remove()
    game.shadows:remove(self)
    game.world:remove(self)
end

return object