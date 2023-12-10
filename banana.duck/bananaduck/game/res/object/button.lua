local object = object:extend()
object.tag = "button"

local COLLISION_SIZE = {8, 4}

function object:create(ldtkEntity)
    self.x = ldtkEntity.x
    self.y = ldtkEntity.y

    game.world:add(self, ldtkEntity.x, ldtkEntity.y + 4, COLLISION_SIZE[1], COLLISION_SIZE[2])
    self.sprites = {
        idle = sprite("objects/button.png"),
        pressed = sprite("objects/button-pressed.png"),
    }

    self.sprite = self.sprites.idle
    self.isPressed = false
    self.wait = false

    self.enterEvents = ldtkEntity.props.onEnter
    self.leaveEvents = ldtkEntity.props.onLeave
    self.downEvents = ldtkEntity.props.onDown
    self.upEvents = ldtkEntity.props.onUp

    game.shadows:add(self)
end

function object:update(dt)
    if game.paused then
        return
    end
    if self.isPressed then
        if self.wait then
            self:onDown()
            self.wait = false
        else
            self:onLeave()
            self.isPressed = false
            self.sprite = self.sprites.idle
        end
    else
        self:onUp()
    end
end

function object:playerEnter()
    if not self.isPressed then
        self:onEnter()
    end

    self.isPressed = true
    self.wait = true
    self.sprite = self.sprites.pressed
end

function object:draw()
    if self.subpixel then
        self.sprite:draw(self.x, self.y)
    else
        self.sprite:draw(math.round(self.x), math.round(self.y))
    end

    if DEBUG then
        love.graphics.setColor(1, 0, 0, 0.2)
        graphics.rectangle("fill", game.world:getRect(self))
    end
end

function object:onEnter()
    -- Play click sound
    game.playSound("button-press.wav")
    for index, value in ipairs(self.enterEvents) do
        game.level:fireEvent(value)
    end
end

function object:onLeave()
    -- Play leave sound
    game.playSound("button-unpress.wav")
    for index, value in ipairs(self.leaveEvents) do
        game.level:fireEvent(value)
    end
end

function object:onDown()
    for index, value in ipairs(self.downEvents) do
        game.level:fireEvent(value)
    end
end

function object:onUp()
    for index, value in ipairs(self.upEvents) do
        game.level:fireEvent(value)
    end
end


function object:remove()
    game.world:remove(self)
    game.shadows:remove(self)
end

return object