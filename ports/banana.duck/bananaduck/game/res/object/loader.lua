local object = object:extend()

function object:create()
    self.text = "A game by\nHamdy Elzanqali"
    self.size = #self.text
    self.current = ""
    self.index = 0
    self.speed = 0.1
    self.timer = self.speed
    self.wait = 0.5
    self.changed = false
    self.amount = 0
    self.splash = false

    self.typingDelay = math.randomFloat(0.05, 0.15)
    
    game.shadows:add(self)
end

function object:update(dt)
    if game.splash and not self.splash then
        game.splash.stopped = true
    end


    if self.typingDelay > 0 then
        self.typingDelay = self.typingDelay - dt
    else
        if self.current ~= self.text then
            self.typingDelay = math.randomFloat(0.05, 0.15)
            game.playSound("type" .. tostring(math.random(1, 4)) .. ".wav")
        end
    end
    
    if input.anyPressed() then
        self.wait = 0
        self.timer = 0
        self.current = self.text
    end

    if self.timer <= 0 then
        self.amount = 1 + math.floor(-self.timer / self.speed)
        self.timer = self.speed - (self.timer % self.speed)
        if self.current == self.text then
            if self.wait > 0 then
                self.wait = self.wait - dt
                return
            end
            if not self.changed then
                self.changed = true
                objects.menu()
                self:destroy()
                game.hideSplash = false
            end
        else
            self.index = self.index + self.amount
            self.current = self.text:sub(1, math.min(self.index, self.size))
        end
    else
        self.timer = self.timer - dt
    end
end

function object:draw()
    color.white:set()
    graphics.printf(self.current, 2, 24, 64, "left")
end

function object:remove()
    game.shadows:remove(self)
end

return object