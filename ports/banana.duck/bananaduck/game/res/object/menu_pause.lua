local object = object:extend()
object.layer = 99

local main

local savedProgress = {
    stage2 = false,
    stage3 = false,
    secretStage = false,
}

main = {
    {"Resume", nil, function (self)
        game.paused = false
    end},
    {"Restart", nil, function (self)
        game.paused = false
        objects.splash_in(game.player.position.x + 2, game.player.position.y + 3, ldtk.currentLevelName)
    end},
    {
        "fullscreen: ", 
        function (self)
            return game.options.fullscreen and "on" or "off"
        end,
        function (self)
            game.options.fullscreen = not game.options.fullscreen
            love.window.setFullscreen(game.options.fullscreen)
            gamedata.set("fullscreen", game.options.fullscreen, "settings.sav")
            camera.updateWindowSize()
        end
    },

    {
        "sub-pixels: ", 
        function (self)
            return game.subpixel and "on" or "off"
        end,
        function (self)
            game.subpixel = not game.subpixel
            gamedata.set("subpixel", game.subpixel, "settings.sav")
        end
    },

    {
        "music: ",
        function (self)
            return tostring(math.round(game.options.music * 10))
        end,
        function (self)
            game.options.music = (game.options.music + 0.1)
            if game.options.music > 1 then
                game.options.music = 0
            end
            gamedata.set("music", game.options.music, "settings.sav")
            TEsound.volume("music", game.options.music * 0.5)
        end,
        function (self)
            game.options.music = (game.options.music + 0.1)
            if game.options.music > 1 then
                game.options.music = 0
            end
            gamedata.set("music", game.options.music, "settings.sav")
            TEsound.volume("music", game.options.music * 0.5)
        end,
        function (self)
            game.options.music = (game.options.music - 0.1)
            if game.options.music < 0 then
                game.options.music = 1
            end
            gamedata.set("music", game.options.music, "settings.sav")
            TEsound.volume("music", game.options.music * 0.5)
        end
    },
    {
        "sound: ",
        function (self)
            return tostring(math.round(game.options.sfx * 10))
        end,
        function (self)
            game.options.sfx = (game.options.sfx + 0.1)
            if game.options.sfx > 1 then
                game.options.sfx = 0
            end
            gamedata.set("sfx", game.options.sfx, "settings.sav")
        end,
        function (self)
            game.options.sfx = (game.options.sfx + 0.1)
            if game.options.sfx > 1 then
                game.options.sfx = 0
            end
            gamedata.set("sfx", game.options.sfx, "settings.sav")
        end,
        function (self)
            game.options.sfx = (game.options.sfx - 0.1)
            if game.options.sfx < 0 then
                game.options.sfx = 1
            end
            gamedata.set("sfx", game.options.sfx, "settings.sav")
        end
    },
    
    {"main menu", nil, function (self)
        game.checkpoint = nil
        game.selectStage = 1
        objects.splash_in(self.position.x + 32,self.position.y + 32, "Menu")
    end}
}

function object:create()
    self.position = vector(0, 0)

    self.selection = 1
    self.menu = main
    self.size = #self.menu
    
    self.handSprite = sprite("objects/hand.png")
    self.handPosition = vector(1, 34 - (self.size * 4) + (self.selection - 1) * 8)
    self.handOffset = 0
    self.handOffsetDirection = 1
    self.handOffsetAmount = 1
    self.handOffsetTimer = 0
    self.handOffsetTimerSpeed = 0.5 

    self.menuX = 6

    self.confirmDelete = false
    self.deleted = false

    game.shadows:add(self)
end

function object:update(dt)
    
    if input.get("ui_pause") then
        game.paused = not game.paused
        if game.paused then
            -- open menu sound
            self.selection = 1
            self.handPosition.y = self.position.y + 34 - (self.size * 4) + (self.selection - 1) * 8
        end
        game.playSound("menu-select.wav")
    end
    
    if input.get("restart") then
        game.paused = false
        objects.splash_in(game.player.position.x + 2, game.player.position.y + 3, ldtk.currentLevelName)
    end

    if not game.paused then
        return
    end

    if input.get("ui_up") then
        self.selection = self.selection - 1
        if self.selection < 1 then
            self.selection = self.size
        end
        game.playSound("menu-select.wav")
    end
    
    if input.get("ui_down") then
        self.selection = self.selection + 1
        if self.selection > self.size then
            self.selection = 1
        end
        game.playSound("menu-select.wav")
    end

    if input.get("ui_select") then
        if self.menu[self.selection][3] then
            self.menu[self.selection][3](self)
        end
        game.playSound("menu-choose.wav")
    end
    
    if input.get("ui_right") then
        if self.menu[self.selection][4] then
            self.menu[self.selection][4](self)
            game.playSound("menu-select.wav")
        end
    end
    
    if input.get("ui_left") then
        if self.menu[self.selection][5] then
            self.menu[self.selection][5](self)
            game.playSound("menu-select.wav")
        end
    end
    
    if game.subpixel then
        self.handPosition.y = math.lerp(self.handPosition.y, 34 - (self.size * 4) + (self.selection - 1) * 8, 15 * dt)
        if self.handOffsetDirection == 1 then
            self.handOffset = math.lerp(self.handOffset, self.handOffsetAmount + 0.05, 5 * dt)
            if self.handOffset > self.handOffsetAmount then
                self.handOffsetDirection = -1
            end
        else
            self.handOffset = math.lerp(self.handOffset, -self.handOffsetAmount - 0.05, 5 * dt)
            if self.handOffset < -self.handOffsetAmount then
                self.handOffsetDirection = 1
            end
        end
    else
        self.handOffsetTimer = self.handOffsetTimer - dt
        if self.handOffsetTimer < 0 then
            self.handOffsetTimer = self.handOffsetTimerSpeed
            self.handOffset = (self.handOffset == 1) and 0 or 1
        end

        self.handPosition.y =  34 - (self.size * 4) + (self.selection - 1) * 8
    end

    self.position.x = camera.x + camera.offsetX
    self.position.y = camera.y + camera.offsetY
end


function object:draw()
    if not game.paused then
        return
    end
    
    graphics.setColor(1, 1, 1, 1)
    if game.subpixel then
        color.black:set(0.9)
        graphics.rectangle("fill", self.position.x - 16, self.position.y - 16, 96, 96)
        self.handSprite:draw(self.position.x + self.handPosition.x + self.handOffset, self.position.y + self.handPosition.y)
        
        for index, value in ipairs(self.menu) do
            local text = value[1]
            if value[2] then
                text = text .. value[2](self)
            end
            if self.selection == index then
                color.yellow:set()
                graphics.print(text, self.position.x + self.menuX + 1, self.position.y + 32 - (self.size * 4) + (index - 1) * 8)
            else
                color.white:set()
                graphics.print(text, self.position.x + self.menuX, self.position.y + 32 - (self.size * 4) + (index - 1) * 8)
            end
        end
    else
        color.black:set(0.9)
        graphics.rectangle("fill", math.round(self.position.x - 16), math.round(self.position.y - 16), 96, 96)

        self.handSprite:draw(math.round(self.position.x + self.handPosition.x + self.handOffset), math.round(self.position.y + self.handPosition.y))

        for index, value in ipairs(self.menu) do
            local text = value[1]
            if value[2] then
                text = text .. value[2](self)
            end
            if self.selection == index then
                color.yellow:set()
                graphics.print(text, math.round(self.position.x + self.menuX + 1),  math.round(self.position.y + 32 - (self.size * 4) + (index - 1) * 8))
            else
                color.white:set()

                graphics.print(text, math.round(self.position.x + self.menuX), math.round(self.position.y + 32 - (self.size * 4) + (index - 1) * 8))
            end
        end
    end
end

function object:remove()
    game.shadows:remove(self)
end


return object