local object = object:extend()
object.tag = "danger"
object.layer = 3

local SPIKE_HITBOX = 2
local FALL_RANGE = 8
local DELAY = 0.05
local GRAVITY = 175

function object:create(x, y)
    self.sprite = sprite("objects/spike.png")
    game.shadows:add(self)

    self.x = x - 1
    self.y = y + 3
    self.sprite:setScale(1, -1)
    game.world:add(self, self.x + 1, self.y - 3, 3, SPIKE_HITBOX)

    self.segment = vector(math.floor((self.x + game.level.data.props.x) / 64), math.floor((self.y + game.level.data.props.y) / 64))
    self.delay = DELAY
    self.fall = false
    self.speedY = 0

    self.dead = false
end

local function collisionFilter(item, other)
    return "cross"
end

function object:update(dt)
    if math.floor((camera.x + game.level.data.props.x) / 64) == self.segment.x and math.floor((camera.y + game.level.data.props.y) / 64) == self.segment.y then
        if game.player then
            if game.player.position.x > self.x - FALL_RANGE and game.player.position.x + 3 < self.x + FALL_RANGE + 4 and game.player.position.y > self.y then
                self.fall = true
                
            end
        end
    end

    if self.fall then
        if self.delay > 0 then
            self.delay = self.delay - dt
            return
        end

        self.speedY = self.speedY + GRAVITY * dt

        local actualX, actualY, cols, len = game.world:check(self, self.x, self.y + self.speedY * dt, collisionFilter)
        
        for i = 1, len do
            if cols[i].overlaps and (cols[i].other.tag == "solid" or cols[i].other.tag == "jump_through" or cols[i].other.tag == "box") then
                if not self.dead then
                    self:destroy()
                    self.dead = true
                end
            end
        end

        game.world:update(self, actualX + 1, actualY - 3)
        self.x = actualX
        self.y = actualY

        if self.y > game.level.data.height then
            if not self.dead then
                self:destroy()
                self.dead = true
            end
        end
    end
end

function object:draw()
    if game.subpixel then
        self.sprite:draw(self.x, self.y)
    else
        self.sprite:draw(math.round(self.x), math.round(self.y))
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