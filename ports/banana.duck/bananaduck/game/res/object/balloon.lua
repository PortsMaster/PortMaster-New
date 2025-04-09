local object = object:extend()
object.tag = "bouncy"

function object:create(ldtkEntity)
    self.position = vector(ldtkEntity.x, ldtkEntity.y)
    self.sprites = {
        idle = sprite("objects/ballon.png"),
        ghost = sprite("objects/ballon-ghost.png")
    }

    self.sprite = self.sprites.idle

    self.jump = true
    self.height = ldtkEntity.props.height
    self.delay = ldtkEntity.props.delay
    self.timer = 0

    self.startDelay = ldtkEntity.props.startDelay

    self.hoverSpeed = 0.5
    self.hover = (self.hoverSpeed) > 0
    self.hoverTimer = 0
    self.offset = 0

    game.world:add(self, self.position.x, self.position.y, 7, 8)
    game.shadows:add(self)

end

function object:update(dt)
    if game.paused then
        return
    end

    if self.startDelay > 0 then
        self.startDelay = self.startDelay - dt
        return
    end
    
    if self.hoverTimer < 0 then
        self.hoverTimer = self.hoverSpeed
        self.offset = self.offset == 1 and 0 or 1
    else
        self.hoverTimer = self.hoverTimer - dt
    end

    if self.timer > 0 then
        self.timer = self.timer - dt
        self.jump = false
        if self.timer < 0.1 then
            self.sprite = self.sprites.idle
        else
            self.sprite = self.sprites.ghost
        end
    else
        self.sprite = self.sprites.idle
        self.jump = true
    end
end

function object:playerEnter()
    if self.timer <= 0 then
        self.timer = self.delay
        -- play sound
        game.playSound("bouncy.wav")
    end
end

function object:draw()
    if game.subpixel then
        self.sprite:draw(self.position.x, self.position.y + self.offset)
    else
        self.sprite:draw(math.floor(self.position.x), math.floor(self.position.y) + self.offset)
    end

    if DEBUG then
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.rectangle("fill", game.world:getRect(self))
        love.graphics.setColor(1, 1, 1)
    end
end

function object:remove()
    game.world:remove(self)
    game.shadows:remove(self)
end

return object