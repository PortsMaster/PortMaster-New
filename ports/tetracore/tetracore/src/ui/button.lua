-- Button class for the menus
local love = require "love"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"
local GameConfig = require "src.constants.gameConfig"

local img = love.graphics.newImage('assets/ui/button.png')
if not img and GameConfig.DEBUG and GameConfig.DEBUG.ENABLE_CONSOLE then
    print("Warning: Failed to load button image: assets/ui/button.png")
end

local Button = {}
Button.__index = Button

-- Create a new button
-- x, y, width, height are on the virtual canvas (e.g., 800x450)
-- guiScale is the overall scale factor from main.lua, used for fine details
function Button.new(x, y, width, height, text, callback, guiScale, playSounds)
    local self = setmetatable({}, Button)
    self.x = x         -- Position on the virtual canvas
    self.y = y         -- Position on the virtual canvas
    self.width = width -- Width on the virtual canvas
    self.height = height -- Height on the virtual canvas
    self.text = text
    self.callback = callback
    self.hovered = false
    self.disabled = false -- Add disabled state
    self.guiScale = guiScale or 1 -- Store the GUI scale for detail scaling
    self.playSounds = playSounds -- If true (default), play sounds on hover/click. If false, no sounds.
    if self.playSounds == nil then self.playSounds = true end -- Default to true if not specified

    -- Animation state
    self.popScale = 1.0

    -- Default colors
    self.normalColor = GameConfig.UI.BUTTON.NORMAL_COLOR
    self.hoverColor = GameConfig.UI.BUTTON.HOVER_COLOR
    self.hoverFill = GameConfig.UI.BUTTON.SELECTION_HIGHLIGHT_COLOR
    self.disabledColor = GameConfig.UI.BUTTON.DISABLED_COLOR
    self.textColor = GameConfig.UI.BUTTON.TEXT_COLOR
    self.disabledTextColor = GameConfig.UI.BUTTON.DISABLED_TEXT_COLOR

    -- Font sized for the virtual canvas
    -- It will be scaled visually by main.lua's global transform.
    self.font = fontManager.getFont(GameConfig.UI.BUTTON.FONT_SIZE) -- Base font size for virtual canvas

    -- Track the last update's hover state to only play sound once
    self.lastHoverState = false

    return self
end

-- Manually trigger the selection pop animation (useful for keyboard/gamepad navigation)
function Button:pulse()
    self.popScale = GameConfig.UI.BUTTON.POP_SCALE or 1.15
end

-- Update the button state
function Button:update(dt, guiScale) -- Receive current overall guiScale
    if guiScale and self.guiScale ~= guiScale then
        self.guiScale = guiScale
    end

    -- Smoothly interpolate back to normal scale (1.0)
    self.popScale = self.popScale + (1.0 - self.popScale) * 15 * dt

    -- If disabled, don't process hover effects
    if self.disabled then
        self.hovered = false
        return
    end
end

function Button:draw()
    love.graphics.push()

    -- Apply pop/pulse animation scaling
    if self.popScale ~= 1.0 then
        local cx = self.x + self.width / 2
        local cy = self.y + self.height / 2
        love.graphics.translate(cx, cy)
        love.graphics.scale(self.popScale)
        love.graphics.translate(-cx, -cy)
    end

    -- 1. Determine which color to tint the button image
    local buttonColor = self.normalColor
    if self.disabled then
        buttonColor = self.disabledColor
    elseif self.hovered then
        buttonColor = self.hoverColor
    end

    -- 2. Tint and scale the image to fit your button's configured dimensions
    love.graphics.setColor(buttonColor)

    local imgW, imgH = img:getDimensions()
    local scaleX = self.width / imgW
    local scaleY = self.height / imgH

    love.graphics.draw(img, self.x, self.y, 0, scaleX, scaleY)

    -- 3. Fill with self.hoverFill when hovered
    if self.hovered and not self.disabled then
        love.graphics.setColor(self.hoverFill)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end

    -- 4. Draw the button text
    love.graphics.setColor(self.disabled and self.disabledTextColor or self.textColor)
    love.graphics.setFont(self.font)

    local textWidth = self.font:getWidth(self.text)
    local textHeight = self.font:getHeight()

    local centerX = self.x + self.width / 2
    local centerY = self.y + self.height / 2
    local textX = centerX - textWidth / 2
    local textY = centerY - textHeight / 2

    love.graphics.print(self.text, textX, textY)

    love.graphics.pop()
    -- Reset graphics color state
    love.graphics.setColor(1, 1, 1, 1)
end

-- Check if button is clicked
function Button:click(virtualX, virtualY)
    if not self.disabled then
        if self.playSounds then
            soundManager.playSound("menuSelect")
        end
        if self.callback then
            self.callback()
        end
        return true
    end
    return false
end

function Button:containsPoint(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

return Button
