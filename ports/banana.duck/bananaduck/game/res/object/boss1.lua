local object = object:extend()
object.layer = -1

local GRAVITY = 600

local LINES = {
    "HA HA HA HA HA",
    "LOOK AT YOU SO SMOL",
    "LOL",
    "YOU'RE SO WEAK",
    "HA HA HA HA HA",
    "YOU ARE FRAGILE",
    "LOL XD",
    "NEVER GONNA",
    "GIVE YOU UP",
    "LOL",
}

local READ_TIME = 4

function object:create(ldtkEntity)
    game.shadows:add(self)
    self.sprites = {
        idle = sprite("boss1/1.png", "boss1/2.png", "boss1/3.png", "boss1/4.png", 0.1),
        die  = sprite("boss1/5.png")
    }
    self.sprite = self.sprites.idle

    self.visible = false
    self.position = vector(ldtkEntity.x, ldtkEntity.y)
    self.offset = vector(0, 32)
    self.velocity = vector(0, -100)

    self.linesSize = #LINES
    self.current = 1
    self.lineTimer = READ_TIME
    self.numberOfCrownsCOllected = 0
    for i = 1, 11, 1 do
        if gamedata.get("crown_S1_L".. i, "game.sav") then
            self.numberOfCrownsCOllected = self.numberOfCrownsCOllected + 1
        end
    end

    game.level:listenToEvent(self, "start", function ()
        self:start()
    end)

    game.level:listenToEvent(self, "finish", function ()
        self:finish()
    end)
end

function object:remove()
    game.shadows:remove(self)
end

function object:update(dt)
    if not self.visible then
        return
    end

    self.sprite:update(dt)

    self.lineTimer = self.lineTimer - dt
    if self.lineTimer < 0 then
        self.lineTimer = READ_TIME
        self.current = self.current + 1
        if self.current > self.linesSize then
            self.current = 1
        end
    end
    
    self.offset.y = self.offset.y + self.velocity.y * dt
    
    if self.sprite == self.sprites.idle then
        if self.offset.y < 0 then
            self.velocity.y = self.velocity.y + GRAVITY * dt
        end

        if self.velocity.y > 0 then
            if self.offset.y > 0 then
                self.velocity.y = 0
                self.offset.y = 0
            end
        end
    else
        if self.offset.y < 32 then
            self.velocity.y = self.velocity.y + GRAVITY * dt
        else
            self.velocity.y = 0
        end
    end
end

local function getCleanTime(time)
    local hours = math.floor(time / 3600)
    local minutes = math.floor((time - hours * 3600) / 60)
    local seconds = math.floor(time % 60)
    local milliseconds = math.floor((time * 100) % 100)
    if hours > 0 then
        return string.format("%02d:%02d:%02d.%02d", hours, minutes, seconds, milliseconds)
    else
        return string.format("%02d:%02d.%02d", minutes, seconds, milliseconds)
    end
end

function object:draw()
    if self.sprite == self.sprites.die then
        color.white:set()
        graphics.print("" .. getCleanTime(game.stats.time), self.position.x, self.position.y - 1)
        graphics.print("DIED: " .. game.stats.deaths, self.position.x, self.position.y + 11)
        graphics.print(tostring(self.numberOfCrownsCOllected) .. "/11 FOUND", self.position.x, self.position.y + 5)
        graphics.print("JUMP: " .. game.stats.jumps, self.position.x, self.position.y + 17)
    end

    if self.visible then
        if game.subpixel then
            self.sprite:draw(self.position.x + self.offset.x, self.position.y + self.offset.y)
        else
            self.sprite:draw(math.round(self.position.x + self.offset.x), math.round(self.position.y + self.offset.y))
        end

        if self.sprite == self.sprites.idle then
            graphics.printf(LINES[self.current], self.position.x, self.position.y - 12, 32, "center")
        end
    end
end

function object:start()
    self.visible = true
end

function object:finish()
    self.sprite = self.sprites.die
    self.velocity.y = -100
    game.saveStats = false
end


return object