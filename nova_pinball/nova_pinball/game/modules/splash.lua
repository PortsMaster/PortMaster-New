local splash = {}

function splash:load()
    love.graphics.setFont(smallFont)
    love.graphics.setBackgroundColor(0, 0, 0, 1)
    -- center of screen
    self.center = {}
    self.center.x = scrWidth / 2
    self.center.y = scrHeight / 2
    -- circle radius
    self.r = 226
    -- sprites
    self.heart = loadSprite("images/radeocity-heart.png")
    self.spokes = loadSprite("images/radeocity-spokes.png")
    self.spokes.x = self.center.x
    self.spokes.y = self.center.y
    self.heart.x = self.center.x
    self.heart.y = self.center.y
    -- sprite manager
    self.sprites = spriteManager:new()
    self.sprites:add("spokes", self.spokes):setRotation(0.1)
    self.sprites:add("heart", self.heart)
    -- Fadeout
    self.fading = false
    self.fadeAlpha = 0
    -- Loading message
    local actions = {
        "Carving", "Grinding", "Wiring", "Winding", "Tightening", "Counting"
        }
    local things = {
        " Flippers",
        " Balls",
        " Bumpers",
        " Kickers",
        " Slingshots",
        " Bolts",
        }
    self.loadingMessage = actions[math.random(1, #actions)] .. things[math.random(1, #things)] .. "..."
    -- Loading state
    self.splashLoaded = true
    self.modulesLoadDelay = 2
    self.modulesLoaded = false
end

function splash:unload()
    self.splashLoaded = nil
    self.heart = nil
    self.spokes = nil
    self.sprites = nil
end

function splash:update(dt)
    if self.splashLoaded then
    
        -- Load all other modules
        if (self.modulesLoadDelay) then
            self.modulesLoadDelay = self.modulesLoadDelay - dt
            if (self.modulesLoadDelay < 0) then
                self.modulesLoadDelay = nil
                loadAllModules()
                self.modulesLoaded = true
                self.fading = true
            end
        end

        -- Beat the heart by scaling it up and down
        if (self.heart.scale == 1) then self.sprites:item("heart"):scale(-0.2) end
        if (self.heart.scale < 0.85) then self.sprites:item("heart"):scale(0.3) end

        -- Fade the splash screen out
        if (self.fading) then
            self.fadeAlpha = self.fadeAlpha + (0.5*dt)
            if self.fadeAlpha >= 1 then
                self.fadeAlpha = 1
                self:unload()
                mainstate:set("menu")
                love.graphics.setFont(largeFont)
                return
            end
        end

        -- Update the sprite manager which handles the sprite rotation and scaling
        self.sprites:update(dt)
    end
end

function splash:draw(dt)
    if self.splashLoaded then
        love.graphics.setColor(0, 1, 0)
        love.graphics.circle("fill", self.center.x, self.center.y, self.r)
        love.graphics.setColor(1, 1, 1)
        self.sprites:draw()
        printShadowText(self.loadingMessage, scrHeight - 40, {200/256, 200/256, 100/256})
        if self.fading then
            love.graphics.setColor(0, 0, 0, self.fadeAlpha)
            love.graphics.rectangle("fill", 0, 0, scrWidth, scrHeight)
        end
    end
end

function splash:keypressed(key)
    if (self.modulesLoaded) then
        self.fading = true
    end
end

return splash
