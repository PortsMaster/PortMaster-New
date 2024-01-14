local object = object:extend()
object.layer = 3
object.tag = "key"

local HOVER_DELAY = 0.5
local FOLLOW_SPEED = 5

function object:create(ldtkEntity)
    self.position = vector(ldtkEntity.x, ldtkEntity.y)
    self.sprite = sprite("objects/key.png")

    self.offset = false
    self.offsetValue = 0
    self.hoverTimer = 0
    self.speedModifier = 1
    
    self.picked = false

    self.target = nil
    self.targetOffset = vector(-2, -10)

    game.world:add(self, self.position.x, self.position.y, 8, 8)
    game.shadows:add(self)
end

function object:update(dt)
    if game.paused then
        return
    end
    if self.hoverTimer > 0 then
        self.hoverTimer = self.hoverTimer - dt
    else
        self.offset = not self.offset
        self.hoverTimer = HOVER_DELAY
    end

    self.sprite:update(dt)

    self.offsetValue = math.lerp(self.offsetValue, self.offset and 1 or 0, 10 * dt)

    if self.target then
        self.position = self.position + (self.target - self.position + self.targetOffset) * FOLLOW_SPEED * math.pow(0.7, self.speedModifier - 1) * dt
    end
end

function object:draw()
    if game.subpixel then
        self.sprite:draw(self.position.x, self.position.y + self.offsetValue)
    else
        self.sprite:draw(math.round(self.position.x), math.round(self.position.y + self.offsetValue))
    end
end

function object:playerEnter(player, number)
    if not self.picked then
        -- Pick sound
        game.playSound("key.wav")
        self.picked = true
        self.target = player.position
        self.targetOffset = vector(-2, -10 - (number - 1) * 6)
        self.speedModifier = number
    end
    
end

function object:remove()
    game.world:remove(self)
    game.shadows:remove(self)
end

return object