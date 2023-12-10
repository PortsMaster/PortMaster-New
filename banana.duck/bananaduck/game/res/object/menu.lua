local object = object:extend()

local main, options, confirmDelete, confirmQuit, play, about, credit, tools, libraries, other

main = {
    {"play", nil, function (self)
        self.menu = play
        self.size = #self.menu
        self.selection = 1
    end},
    {"options", nil, function (self)
        self.menu = options
        self.size = #self.menu
        self.selection = 1
    end},
    {"Follow Me", nil, function(self)
        self.menu = about
        self.size = #self.menu
        self.selection = 1
    end,
    },
    {"Credit", nil, function (self)
            self.menu = credit
            self.size = #self.menu
            self.selection = 1
        end
    },
    {"quit", nil, function (self)
        self.menu = confirmQuit
        self.size = #self.menu
        self.selection = 2
    end}
}

if love.system.getOS() == "Web" then
    main[5] = nil
end


play = {
    {
        "stage 1", nil, function (self)
            objects.splash_in(32, 32, "Stage1")
        end,
    },
    {
        "stage 2", nil, function (self)
            objects.splash_in(32, 32, "Stage2")
        end,
    },
    {
        "stage 3", nil, function (self)
            
        end,
    },
    {
        "back", nil, function (self)
            self.menu = main
            self.size = #self.menu
            self.selection = 1
        end,
    }
}

options = {
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
            TEsound.volume("sfx", game.options.sfx)
        end,
        function (self)
            game.options.sfx = (game.options.sfx + 0.1)
            if game.options.sfx > 1 then
                game.options.sfx = 0
            end
            gamedata.set("sfx", game.options.sfx, "settings.sav")
            TEsound.volume("sfx", game.options.sfx)
        end,
        function (self)
            game.options.sfx = (game.options.sfx - 0.1)
            if game.options.sfx < 0 then
                game.options.sfx = 1
            end
            gamedata.set("sfx", game.options.sfx, "settings.sav")
            TEsound.volume("sfx", game.options.sfx)
        end
    },
    {
        "Clear GameData",
        nil,
        function (self)
            self.menu = confirmDelete
            self.size = #self.menu
            self.selection = 2
        end,
    },
    {
        "back",
        nil,
        function (self)
            self.menu = main
            self.size = #self.menu
            self.selection = 2
        end
    }
}

confirmDelete = {
    {
        "yes",
        nil,
        function (self)
            self.menu = main
            self.size = #self.menu
            self.selection = 2

            -- RESET GAME PROGRESS
            gamedata.clear("stats.sav")
            gamedata.clear("game.sav")

            game.stats = {
                jumps = 0,
                time = 0,
                deaths = 0,
            }
            

            self.savedProgress = {}
        end
    },
    {
        "no",
        nil,
        function (self)
            self.menu = options
            self.size = #self.menu
            self.selection = 5
        end
    },
}

confirmQuit = {
    {
        "yes",
        nil,
        function (self)
            love.event.quit()
        end
    },
    {
        "no",
        nil,
        function (self)
            self.menu = main
            self.size = #self.menu
            self.selection = 5
        end
    },
}

about = {
    {
        "Twitter", nil, function (self)
            love.system.openURL("https://twitter.com/HamdyElzanqali")
        end,
    },
    {
        "Youtube", nil, function (self)
            love.system.openURL("https://www.youtube.com/channel/UC0V92BG4mHnQ7zg-BiBiRvA")
        end,
    },

    {
        "Patreon", nil, function (self)
            love.system.openURL("https://www.patreon.com/HamdyElzanqali")
        end,
    },
    {
        "Discord", nil, function (self)
            love.system.openURL("https://discord.gg/vCQ3RmwAeV")
        end,  
    },
    {
        "Itch.io", nil, function (self)
            love.system.openURL("https://cyfo.itch.io/")
        end
    },
    {
        "back", nil, function (self)
            self.menu = main
            self.size = #self.menu
            self.selection = 3
        end,
    }
}

credit = {
    {
        "Hamdy", nil, function (self)
            love.system.openURL("https://twitter.com/HamdyElzanqali")
        end,
    },
    {
        "-Tools", nil, function (self)
            self.menu = tools
            self.size = #self.menu
            self.selection = 1
        end,
    },
    {
        "-libraries", nil, function (self)
            self.menu = libraries
            self.size = #self.menu
            self.selection = 1
        end
    },
    {
        "-other", nil, function (self)
            self.menu = other
            self.size = #self.menu
            self.selection = 1
        end
    },
    {
        "back", nil, function (self)
            self.menu = main
            self.size = #self.menu
            self.selection = 4
        end,
    }
}

tools = {
    {"Love", nil, function (self)
        love.system.openURL("https://love2d.org/")
    end},
    {"Aseprite", nil, function(self)
        love.system.openURL("https://www.aseprite.org/")
    end},
    {"Chiptone", nil, function ()
        love.system.openURL("https://sfbgames.itch.io/chiptone")
    end},
    {"back", nil, function (self)
        self.menu = credit
        self.size = #self.menu
        self.selection = 2
    end}
}

libraries = {
    {"classic", nil, function (self)
        love.system.openURL("https://github.com/rxi/classic")
    end},
    {"lume", nil, function (self)
        love.system.openURL("https://github.com/rxi/lume")
    end
    },
    {"Vector", nil, function (self)
        love.system.openURL("https://github.com/themousery/vector.lua") 
    end},
    {"require", nil, function (self)
        love.system.openURL("https://github.com/kikito/fay/blob/master/src/lib/require.lua") 
    end},
    {"bump", nil, function(self)
        love.system.openURL("https://github.com/kikito/bump.lua")
    end},
    {"back",nil, function (self)
        self.menu = credit
        self.size = #self.menu
        self.selection = 3
    end}
}

other = {
    {"Floating cat", nil, function (self)
        love.system.openURL("https://uppbeat.io/track/michael-grubb/floating-cat")
    end},
    {"ENDESGA 16", nil, function (self)
        love.system.openURL("https://lospec.com/palette-list/endesga-16")
    end},
    {"back", nil, function (self)
        self.menu = credit
        self.size = #self.menu
        self.selection = 4
    end}
}

function object:create()
    if game.selectStage then
        self.selection = game.selectStage
        game.selectStage = nil
        self.menu = play
    else
        self.selection = 1
        self.menu = main
    end
    self.size = #self.menu
    
    self.handSprite = sprite("objects/hand.png")
    self.handPosition = vector(6, 34 - (self.size * 4) + (self.selection - 1) * 8)
    self.handOffset = 0
    self.handOffsetDirection = 1
    self.handOffsetAmount = 1
    self.handOffsetTimer = 0
    self.handOffsetTimerSpeed = 0.5 

    self.menuX = 12

    self.confirmDelete = false
    self.deleted = false

    game.shadows:add(self)

    self.savedProgress = {
        stage2 = gamedata.get("S2", "game.sav"),
        stage3 = gamedata.get("S3", "game.sav"),
        secretStage = gamedata.get("secretStage", "game.sav"),
    }

    game.hideSplash = false
end

function object:update(dt)
    if input.get("ui_up") then
        game.playSound("menu-select.wav")
        self.selection = self.selection - 1
        if self.selection < 1 then
            self.selection = self.size
        end

        if self.menu == play then
            if self.selection == 3 and not self.savedProgress.stage3 then
                self.selection = 2
            end

            if self.selection == 2 and not self.savedProgress.stage2 then
                self.selection = 1
            end
        end
    end
    
    if input.get("ui_down") then
        game.playSound("menu-select.wav")
        self.selection = self.selection + 1
        if self.selection > self.size then
            self.selection = 1
        end

        if self.menu == play then
            
            if self.selection == 2 and not self.savedProgress.stage2 then
                self.selection = 3
            end

            if self.selection == 3 and not self.savedProgress.stage3 then
                self.selection = 4
            end
        end
    end

    if input.get("ui_select") then
        game.playSound("menu-choose.wav")
        if self.menu[self.selection][3] then
            self.menu[self.selection][3](self)
        end
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

    if self.menu == options then
        self.handPosition.x = 1
        self.menuX = 6
        self.handOffsetAmount = 1
    else
        self.handPosition.x = 6
        self.menuX = 12
        self.handOffsetAmount = 1
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
end


function object:draw()
    graphics.setColor(1, 1, 1, 1)
    if game.subpixel then
        self.handSprite:draw(self.handPosition.x + self.handOffset, self.handPosition.y)
        
        for index, value in ipairs(self.menu) do
            local text = value[1]
            if value[2] then
                text = text .. value[2](self)
            end
            if self.selection == index then
                color.yellow:set()
                graphics.print(text, self.menuX + 1, 32 - (self.size * 4) + (index - 1) * 8)
            else
                color.white:set()

                if self.menu == play then
                    if index == 2 and not self.savedProgress.stage2 then
                        color.gray:set()
                    elseif index == 3 and not self.savedProgress.stage3 then
                        color.gray:set()
                    end
                end

                graphics.print(text, self.menuX, 32 - (self.size * 4) + (index - 1) * 8)
            end
        end
    else
        self.handSprite:draw(math.floor(self.handPosition.x + self.handOffset), math.floor(self.handPosition.y))

        for index, value in ipairs(self.menu) do
            local text = value[1]
            if value[2] then
                text = text .. value[2](self)
            end
            if self.selection == index then
                color.yellow:set()
                graphics.print(text, self.menuX + 1, math.floor(32 - (self.size * 4) + (index - 1) * 8))
            else
                color.white:set()

                if self.menu == play then
                    if index == 2 and not self.savedProgress.stage2 then
                        color.gray:set()
                    elseif index == 3 and not self.savedProgress.stage3 then
                        color.gray:set()
                    end
                end

                graphics.print(text, self.menuX, math.floor(32 - (self.size * 4) + (index - 1) * 8))
            end
        end
    end
end

function object:remove()
    game.shadows:remove(self)
end


return object