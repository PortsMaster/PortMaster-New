local object = object:extend()
object.layer = 20

local FLASH_RATE = 0.09
local RESTART_TIME = 0.35
local SPLASH_DELAY = 0.05

function object:create(x, y, flipped, sprite)
    self.sprite = sprite
    self.sprite:setOrigin(6, 11)
    self.sprite:setScale(flipped and -1 or 1, 1)

    self.position = vector(x + 2, y + 6)

    self.flashTimer = 0
    self.restartTimer = RESTART_TIME
    self.restarted = false
    self.splashTimer = SPLASH_DELAY
    self.splashed = false
    

    game.shadows:add(self)

    game.stats.deaths = game.stats.deaths + 1
    game.playSound("die.wav")
end

function object:update(dt)
    if self.splashTimer <= 0 and not self.splashed then
        objects.splash_in(self.position.x, self.position.y - 4, ldtk.currentLevelName)
        self.splashed = true
    else
        self.splashTimer = self.splashTimer - dt
    end
    if self.flashTimer <= 0 then
        self.flashTimer = FLASH_RATE
        self.sprite.color.alpha = self.sprite.color.alpha == 0.3 and 1 or 0.3
    else
        self.flashTimer = self.flashTimer - dt
    end


end

function object:draw()
    if game.subpixel then
        self.sprite:draw(self.position.x, self.position.y)
    else
        self.sprite:draw(math.round(self.position.x), math.round(self.position.y))
    end
end

function object:remove()
    game.shadows:remove(self)
end

return object