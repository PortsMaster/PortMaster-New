-- Slider class for settings menu
local love = require("love")
local fontManager = require "src.utils.fontManager"
local GameConfig = require "src.constants.gameConfig"

local Slider = {}
    Slider.__index = Slider

    function Slider.new(x, y, width, height, min, max, value, label, onChange, guiScale, showPercentage)
    local self = setmetatable({}, Slider)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.min = min or 0
    self.max = max or 1
    self.value = value or self.min
    self.label = label or ""
    self.onChange = onChange
    self.dragging = false
    self.guiScale = guiScale or 1
    self.lastValue = value
    self.barColor = GameConfig.UI.SLIDER.BAR_COLOR
    self.handleColor = GameConfig.UI.SLIDER.HANDLE_COLOR
    self.textColor = GameConfig.UI.SLIDER.TEXT_COLOR
    self.showPercentage = showPercentage ~= false
    self.disabled = false
    self.disabledColor = {0.4, 0.4, 0.4, 1}  -- Gray color for disabled state

    self.font = fontManager.getFont(GameConfig.UI.SLIDER.FONT_SIZE)

    return self
end

function Slider:getPosition()
    return (self.value - self.min) / (self.max - self.min)
end

function Slider:setValue(newValue)
    if self.disabled then return end
    newValue = math.max(self.min, math.min(self.max, newValue))
    if newValue ~= self.value then
        self.value = newValue
        if self.onChange then
            self.onChange(self.value)
        end
    end
end

function Slider:setFromPosition(pos)
    if self.disabled then return end
    local newValue = self.min + pos * (self.max - self.min)
    self:setValue(newValue)
end

function Slider:update(dt, guiScale)
    if guiScale and self.guiScale ~= guiScale then
        self.guiScale = guiScale
    end
end

function Slider:draw()
    -- Use font sized for virtual canvas
    love.graphics.setFont(self.font)

    -- Draw the label with appropriate color
    local labelColor = self.disabled and self.disabledColor or (self.highlighted and GameConfig.UI.SLIDER.HOVER_COLOR or self.textColor)
    love.graphics.setColor(labelColor)
    love.graphics.print(self.label, self.x, self.y - self.font:getHeight() - GameConfig.UI.SLIDER.LABEL_Y_OFFSET)

    local handleWidth = GameConfig.UI.SLIDER.HANDLE_WIDTH_SCALE * self.guiScale
    local handleHeight = self.height + GameConfig.UI.SLIDER.HANDLE_HEIGHT_OFFSET

    -- Draw the bar background
    love.graphics.setColor(self.disabled and self.disabledColor or self.barColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height,
                            GameConfig.UI.SLIDER.CORNER_RADIUS_SCALE, GameConfig.UI.SLIDER.CORNER_RADIUS_SCALE)

    -- Draw the filled part
    love.graphics.setColor(self.disabled and {self.disabledColor[1], self.disabledColor[2], self.disabledColor[3], 0.5} or GameConfig.UI.SLIDER.FILL_COLOR)
    local fillWidth = self.width * self:getPosition()
    love.graphics.rectangle("fill", self.x, self.y, fillWidth, self.height,
                            GameConfig.UI.SLIDER.CORNER_RADIUS_SCALE, GameConfig.UI.SLIDER.CORNER_RADIUS_SCALE)

    -- Draw the border
    love.graphics.setColor(self.disabled and self.disabledColor or GameConfig.UI.SLIDER.BORDER_COLOR)
    love.graphics.setLineWidth(1 * self.guiScale)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height,
                            GameConfig.UI.SLIDER.CORNER_RADIUS_SCALE, GameConfig.UI.SLIDER.CORNER_RADIUS_SCALE)
    love.graphics.setLineWidth(1)

    -- Draw the handle
    love.graphics.setColor(self.disabled and self.disabledColor or self.handleColor)
    local handleX = self.x + self.width * self:getPosition() - (handleWidth / 2)
    love.graphics.rectangle("fill", handleX, self.y - handleHeight / 4, handleWidth, handleHeight, GameConfig.UI.SLIDER.HANDLE_CORNER_RADIUS, GameConfig.UI.SLIDER.HANDLE_CORNER_RADIUS)

    -- Draw the value text
    love.graphics.setColor(self.disabled and self.disabledColor or self.textColor)
    if self.showPercentage then
        local percent = math.floor(self:getPosition() * 100)
        love.graphics.print(percent .. "%", self.x + self.width + 8, self.y - 8)
    else
        local displayValue = math.floor(self.value + 0.5)
        love.graphics.print(displayValue, self.x + self.width + 8, self.y - 8)
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

return Slider
