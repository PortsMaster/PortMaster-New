local push = require "push"

local osk = {}
local inputText = ""
local onConfirm = nil
local visible = false

-- Dimensions for the OSK
local keyWidth, keyHeight
local padding = 8

-- Key layout with different numbers of keys per row
local rows = {
    {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "Back"},
    {"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "Enter"},
    {"A", "S", "D", "F", "G", "H", "J", "K", "L", ":", "!"},
    {"Z", "X", "C", "V", "B", "N", "M", "-", "_", ",", "." },
}

-- Font for rendering text
local font
local joystick
local oskSelection = {1, 1}  -- Row and column selection

-- Cooldown for input (in seconds)
local inputCooldown = 0.2
local timeSinceLastInput = 0

-- Size multipliers for special keys
local specialKeyWidthMultiplier = 3  -- Multiplier for special keys like "Back" and "Enter"

function osk.load()
    font = love.graphics.newFont(30)  -- Adjust font size as needed
    love.graphics.setFont(font)
    keyWidth = (push:getWidth() / 18)  -- Adjust key width based on virtual resolution
    keyHeight = (push:getHeight() / 10)  -- Adjust key height based on virtual resolution
end

function osk.show(initialText, onConfirmCallback)
    inputText = initialText or ""
    onConfirm = onConfirmCallback
    visible = true
end

function osk.hide()
    visible = false
    onConfirm = nil  
end

function osk.isVisible()
    return visible
end

function osk.update(dt)
    if not visible then return end

    -- Update the cooldown timer
    timeSinceLastInput = timeSinceLastInput + dt

    -- Only allow input if the cooldown has elapsed
    if timeSinceLastInput >= inputCooldown then
        local joystick = osk.getJoystick()
        if not joystick then return end

        -- Simple navigation with joystick
        if joystick:isGamepadDown("dpleft") then
            oskSelection[2] = (oskSelection[2] - 2) % #rows[oskSelection[1]] + 1
            timeSinceLastInput = 0
        elseif joystick:isGamepadDown("dpright") then
            oskSelection[2] = (oskSelection[2] % #rows[oskSelection[1]]) + 1
            timeSinceLastInput = 0
        elseif joystick:isGamepadDown("dpup") then
            oskSelection[1] = (oskSelection[1] - 2) % #rows + 1
            oskSelection[2] = math.min(oskSelection[2], #rows[oskSelection[1]])
            timeSinceLastInput = 0
        elseif joystick:isGamepadDown("dpdown") then
            oskSelection[1] = (oskSelection[1] % #rows) + 1
            oskSelection[2] = math.min(oskSelection[2], #rows[oskSelection[1]])
            timeSinceLastInput = 0
        elseif joystick:isGamepadDown("a") then
            osk.handleKeyPress(rows[oskSelection[1]][oskSelection[2]])
            timeSinceLastInput = 0
        elseif joystick:isGamepadDown("b") then
            osk.handleKeyPress("Back")
            timeSinceLastInput = 0
        elseif joystick:isGamepadDown("start") then
            osk.handleKeyPress("Enter")
            timeSinceLastInput = 0
        elseif joystick:isGamepadDown("back") then
            osk.handleKeyPress("Clear")
            timeSinceLastInput = 0
        end
    end
end

function osk.handleKeyPress(key)
    if not visible then return end  -- Only handle key presses if OSK is visible

    if key == "Back" then
        -- Handle special key `Back`
        inputText = inputText:sub(1, -2)
    elseif key == "Enter" then
        -- Handle special key `Enter`
        if onConfirm then
            onConfirm(inputText)
        end
        osk.hide()
          -- Hide OSK
    elseif key == "Clear" then
        -- Handle special key `Clear` - clear all input
        inputText = ""
    else
        -- Check if adding the new key would exceed the limit
        if #inputText < 10 then
            inputText = inputText .. key
        end
    end

    print("Current text: ", inputText)  -- Debug print to check the text being updated
end

function osk.draw()
    if not visible then return end

    

    -- Draw the full-screen background
    -- love.graphics.setColor(0.35, 0.45, 0.25, 0.95)  -- Semi-transparent dark green background
    love.graphics.setColor(0.35, 0.45, 0.25, 0.95)  -- Semi-transparent dark green background
    love.graphics.rectangle("fill", 0, 0, push:getWidth(), push:getHeight())  -- Full screen

    -- Calculate the total width and height for the OSK
    local totalWidth = 0
    local totalHeight = 0
    for i, row in ipairs(rows) do
        local rowWidth = 0
        for j, key in ipairs(row) do
            local keyW = (key == "Back" or key == "Enter") and keyWidth * specialKeyWidthMultiplier or keyWidth
            rowWidth = rowWidth + keyW + (j < #row and padding or 0)
        end
        totalWidth = math.max(totalWidth, rowWidth)
        totalHeight = totalHeight + keyHeight + padding
    end

    -- Center the OSK
    local xOffset = (push:getWidth() - totalWidth) / 2
    local yOffset = (push:getHeight() - totalHeight) / 1.2

    -- Draw the keyboard keys
    love.graphics.setColor(0.55, 0.66, 0.35)  -- Medium green color for the keys
    local currentY = yOffset

    for i, row in ipairs(rows) do
        local currentX = xOffset
        for j, key in ipairs(row) do
            local keyW = (key == "Back" or key == "Enter") and keyWidth * specialKeyWidthMultiplier or keyWidth
            
            -- Fill unpressed keys with progressBgColor
            if not (i == oskSelection[1] and j == oskSelection[2]) then
                love.graphics.setColor(0.55, 0.66, 0.35)  -- progressBgColor for unpressed keys
                love.graphics.rectangle("fill", currentX, currentY, keyW, keyHeight)
            end
            
            -- Draw key border (removed)
            -- love.graphics.setColor(0.55, 0.66, 0.35)  -- Medium green color for the key borders
            -- love.graphics.rectangle("line", currentX, currentY, keyW, keyHeight)

            -- Highlight the current selection
            if i == oskSelection[1] and j == oskSelection[2] then
                love.graphics.setColor(0.776, 0.878, 0.020)  -- Light green highlight
                love.graphics.rectangle("fill", currentX, currentY, keyW, keyHeight)
            end

            -- Reset color for text
            love.graphics.setColor(0.2, 0.3, 0.15)  -- Dark green color for text
            
            -- Calculate the vertical offset to fine-tune the text position
            local verticalOffset = (keyHeight - font:getHeight()) 

            -- Draw the text, horizontally centered and vertically fine-tuned
            love.graphics.printf(key, currentX, currentY + verticalOffset, keyW, "center")

            currentX = currentX + keyW + padding
        end
        currentY = currentY + keyHeight + padding
    end

    -- Draw the input text
    local textInputWidth = 280
    local textInputHeight = 40
    local textInputX = (push:getWidth() - textInputWidth) / 2
    local textInputY = yOffset - textInputHeight -60  -- Adjust position above the keyboard

    love.graphics.setColor(0.129, 0.259, 0.192)  -- dark green for the input text
    local textWidth = font:getWidth(inputText)
    local textX = textInputX + (textInputWidth - textWidth) / 2
    local textY = textInputY + (textInputHeight - font:getHeight()) / 2
    love.graphics.print(inputText, textX, textY)

  
end

function osk.setJoystick(js)
    joystick = js
end

-- Called when a joystick is connected
function love.joystickadded(js)
    print("Joystick connected: " .. js:getName())
    osk.setJoystick(js)
end

-- Called when a joystick is disconnected
function love.joystickremoved(js)
    print("Joystick disconnected: " .. js:getName())
    if js == osk.getJoystick() then
        osk.setJoystick(nil)
    end
end

-- Add a getter for the joystick
function osk.getJoystick()
    return joystick
end

return osk
