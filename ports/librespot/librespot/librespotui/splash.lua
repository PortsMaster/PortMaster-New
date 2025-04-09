local splashlib = {}

local timer = require('timer') 
local soundmanager = require("soundmanager")
local push = require "push"

-- Default font size
local fontSize = 32

function splashlib.new(init)
    init = init or {}
    local self = {}
    local width, height = push:getDimensions()  -- Use push to get dimensions

    -- Load the logo
    self.logo = {
        sprite = love.graphics.newImage("assets/sprites/portmaster.png"),
        scale = 0,  -- Start with scale 0 (invisible)
        rotation = 0,
        alpha = 0,  -- Start with alpha 0 (invisible)
    }
    self.logo.sprite:setFilter("nearest", "nearest")  -- Set filter for sharp pixel art

    -- Background settings (start with black background)
    self.background = {
        color = {0, 0, 0, 1} -- Fully opaque black
    }
	
    self.elapsed = 0

    -- Set up animation using the timer
    timer.clear()
    timer.script(function(wait)
        wait(0.3)
        -- Elastic expansion with fade-in for the logo
        timer.tween(0.3, self.logo, {scale = 0.4, alpha = 1}, "out-back")
        wait (0.1)
        soundmanager.playIntro()  
        -- Wait for the expansion to finish before pausing
        wait(1.4)  -- Wait for 1 second (duration of the expansion)
    
        -- Fade-out the logo without changing scale
        timer.tween(0.2, self.logo, {alpha = 0}, "linear")

        -- Wait for the fade-out to complete
        wait(0.2)

        -- Mark the splash as done after the fade-out
        self.done = true
        if self.onDone then self.onDone() end
    end)

    -- Assign draw, update, and skip functions
    self.draw = splashlib.draw
    self.update = splashlib.update
    self.skip = splashlib.skip

    return self
end

function splashlib:draw()
    local width, height = push:getDimensions() 

    -- Draw the background (initially black, fading to transparent)
    love.graphics.clear(self.background.color)

    -- Draw the logo with scaling, rotation, and alpha
    love.graphics.push()
    love.graphics.setColor(1, 1, 1, self.logo.alpha)
    love.graphics.draw(
        self.logo.sprite,
        width / 2, height / 2.5, 
        self.logo.rotation,
        self.logo.scale,
        self.logo.scale,
        self.logo.sprite:getWidth() / 2,
        self.logo.sprite:getHeight() / 2
    )
    love.graphics.pop()

    -- Calculate the position for the title and subtitle
    local logoBottomY = (height / 2.5) + (self.logo.sprite:getHeight() * self.logo.scale / 2)

   -- Set font for the main title
    love.graphics.setFont(fonts.regular)
    love.graphics.setColor(1, 1, 1, self.logo.alpha)
    love.graphics.printf("Spotify Connect", 0, logoBottomY + 20, width, "center")

    -- Set font for the subtitle
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(1, 1, 1, self.logo.alpha)
    love.graphics.printf("Made by JanTrueno", 0, logoBottomY + 60, width, "center")
end

function splashlib:update(dt)
    timer.update(dt)
    self.elapsed = self.elapsed + dt
end

function splashlib:skip()
    if not self.done then
        self.done = true
        timer.tween(0.3, self.logo, {alpha = 0}, "linear")
        timer.after(0.3, function()
            timer.clear()
            if self.onDone then self.onDone() end
        end)
    end
end

setmetatable(splashlib, { __call = function(self, ...) return self.new(...) end })

return splashlib
