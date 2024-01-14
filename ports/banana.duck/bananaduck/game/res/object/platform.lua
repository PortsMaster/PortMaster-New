local object = object:extend()
object.tag = "platform"

function object:create(ldtkEntity)
    self.spriteEnd = sprite("objects/platform-end.png")
    self.spriteBody = sprite("objects/platform-body.png")
    
    self.position = vector(ldtkEntity.x, ldtkEntity.y)
    self.width = ldtkEntity.width
    
    self.spriteBody:setScale((self.width - 8) / 4, 1)

    self.velocity = vector(0, 0)
    self.player = nil
    self.boxes = {}

    self.playing = ldtkEntity.props.playing

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
        self.path[index  + 1] = vector(value.cx * 8, value.cy * 8)
        if ldtkEntity.props.pointOffset[index] then
            self.path[index + 1] = self.path[index + 1] + vector(ldtkEntity.props.pointOffset[index].x, ldtkEntity.props.pointOffset[index].y)
        end
    end

    self.pathSize = #self.path
    if self.pathSize > 1 and self.playing then
        self.pathCurrent = 2
    else
        self.pathCurrent = 1
    end

    self.pathDelay = ldtkEntity.props.delay
    self.delayTimer = self.pathDelay
    self.speed = ldtkEntity.props.speed
    self.eventLooping = ldtkEntity.props.eventLooping

    self._dif = vector(0, 0)

    game.world:add(self, self.position.x, self.position.y, self.width, 8)
    game.shadows:add(self)

    for _, event in ipairs(ldtkEntity.props.next) do
        game.level:listenToEvent(self, event, function ()
            self.pathCurrent = self.pathCurrent + 1
            self.delayTimer = 0
            
            if self.pathCurrent > self.pathSize then
                if self.eventLooping then
                    self.pathCurrent = 1
                else
                    self.pathCurrent = self.pathSize
                end
            end
        end)
    end

    for _, event in ipairs(ldtkEntity.props.previous) do
        game.level:listenToEvent(self, event, function ()
            self.pathCurrent = self.pathCurrent - 1
            self.delayTimer = 0

            if self.pathCurrent < 1 then
                if self.eventLooping then
                    self.pathCurrent = self.pathSize
                else
                    self.pathCurrent = 1
                end
            end
        end)
    end
end

function object:update(dt)
    if game.paused then
        return
    end

    if self.delayTimer <= 0 or not self.playing then
        if self.pathSize > 1 then
            self._dif = self.path[self.pathCurrent] - self.position
            self.velocity = vector(math.sign(self._dif.x) * math.min(self.speed * dt, math.abs(self._dif.x)), 
                                            math.sign(self._dif.y) * math.min(self.speed * dt, math.abs(self._dif.y)))

            self.position.x = self.position.x + self.velocity.x
            self.position.y = self.position.y + self.velocity.y

            if self.position.x == self.path[self.pathCurrent].x and self.position.y == self.path[self.pathCurrent].y then
                if self.playing then
                    self.pathCurrent = self.pathCurrent + 1
                    self.delayTimer = self.pathDelay
                    if self.pathCurrent > self.pathSize then
                        self.pathCurrent = 1
                    end
                end
            end
        end
    else
        self.delayTimer = self.delayTimer - dt
        self.velocity.x = 0
        self.velocity.y = 0
    end
    game.world:update(self, self.position.x , self.position.y)

    if self.player then
        self.player.position.y = self.position.y - 5
    end
    self.player = nil

    for key, value in pairs(self.boxes) do
        key.position.y = self.position.y - 7
        if key.velocity.x > 0 then
            key.velocity.x = key.velocity.x + 1
        elseif key.velocity.x < 0 then
            key.velocity.x = key.velocity.x - 1
        end
        key.velocity.x = self.velocity.x / dt + key.velocity.x
        key.velocity.y = self.velocity.y / dt

        self.boxes[key] = nil
    end
end

function object:remove()
    game.world:remove(self)
    game.shadows:remove(self)
end

function object:draw()
    if game.subpixel then
        self.spriteEnd:setScale(1, 1)
        self.spriteEnd:draw(self.position.x, self.position.y)
        self.spriteEnd:setScale(-1, 1)
        self.spriteEnd:draw(self.position.x + self.width, self.position.y)
        self.spriteBody:draw(self.position.x + 4, self.position.y)
    else
        self.spriteEnd:setScale(1, 1)
        self.spriteEnd:draw(math.round(self.position.x), math.round(self.position.y))
        self.spriteEnd:setScale(-1, 1)
        self.spriteEnd:draw(math.round(self.position.x + self.width), math.round(self.position.y))
        self.spriteBody:draw(math.round(self.position.x + 4), math.round(self.position.y))
    end

    if DEBUG then
        color.reset(0.5)
        graphics.rectangle("fill", game.world:getRect(self))
    end
end

return object