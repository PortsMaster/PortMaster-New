local draw = {}

-- Required modules
local tables = require "tables"
local push = require "push"
local talkies = require "talkies" 

-- Menu spacing variables
local fixedVerticalSpacing = 12.5
local leftColumnOffsetX = 118
local rightColumnOffsetX = 30
local menuStartHeight = 68

-- Icon variables
local selectorImage
local selectorOffsetX = 74 
local selectorOffsetY = 38 

-- Description text variables
local descriptionX = 20 
local descriptionTopPadding = 240 

-- Toggle position variables
local toggleOffsetX = 164   
local toggleOffsetY = 15  

-- Wraparound variables
local maxWidth = 400

-- Status bar offset variable
local statusBarYOffset = -5 

-- Control icon position variables
local controlIconOffsetX = 84  
local controlIconOffsetY = 68  

-- Position variables for selector borders
local selectorBorderOffsetX = 276  
local selectorBorderOffsetY = -12 


-- Load graphical assets
function draw.load()
    backgroundImage = love.graphics.newImage("assets/sprites/background.png")
    selectorImage = love.graphics.newImage("assets/sprites/selector.png")
    toggleOnImage = love.graphics.newImage("assets/sprites/selector-on.png")
    toggleOffImage = love.graphics.newImage("assets/sprites/selector-off.png")
    statusBarImage = love.graphics.newImage("assets/sprites/statusbar.png")
    controlIconFaceButtonA = love.graphics.newImage("assets/sprites/facebutton-a.png")
    controlIconDpadLR = love.graphics.newImage("assets/sprites/dpad-lr.png")
    toggleBorderImage = love.graphics.newImage("assets/sprites/toggle-border.png") -- Border for toggles
    selectorBorderImage = love.graphics.newImage("assets/sprites/selector-border.png") -- Border for specific options
end

-- Wraparound description string
function wrapText(text, font, maxWidth)
    local lines = {}
    local currentLine = ""

    for word in text:gmatch("%S+") do
        local testLine = (currentLine == "" and word or currentLine .. " " .. word)
        local lineWidth = font:getWidth(testLine)

        if lineWidth > maxWidth then
            if currentLine ~= "" then
                table.insert(lines, currentLine)
            end
            currentLine = word
        else
            currentLine = testLine
        end
    end

    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end

    return lines
end

-- Render graphics
function draw.render()
    local bgWidth, bgHeight = backgroundImage:getDimensions()
    local scale = 2
    local offsetX = (push:getWidth() - bgWidth * scale) / 2
    local offsetY = (push:getHeight() - bgHeight * scale) / 2

    -- Draw background image
    love.graphics.draw(backgroundImage, offsetX, offsetY, 0, scale, scale)

    local centerX = push:getWidth() / 2
    local dynamicLeftOffsetX = leftColumnOffsetX * scale
    local dynamicRightOffsetX = rightColumnOffsetX * scale
    local menuVerticalSpacing = fixedVerticalSpacing * scale * 2
    local menuStartY = menuStartHeight * scale

    local options = tables.menu
    local rightColumnBaseX = centerX + dynamicRightOffsetX

    for i, option in ipairs(options) do
        local yPosition = menuStartY + (i - 1) * menuVerticalSpacing

        -- Draw selector
        if i == currentSelection and selectorImage then
            local selectorX = centerX - dynamicLeftOffsetX - selectorOffsetX
            local selectorY = yPosition - selectorImage:getHeight() * scale + selectorOffsetY
            love.graphics.draw(selectorImage, selectorX, selectorY, 0, scale, scale)
        end

        -- Draw option text
        love.graphics.setFont(fonts.regular)
        love.graphics.setColor(fontColors.regular)
        love.graphics.print(option, centerX - dynamicLeftOffsetX, yPosition)

        -- Draw toggle images and border
        if option == "Mode" or option == "Autoplay" then
            local toggleImage = tables.settings[option:lower()] and toggleOnImage or toggleOffImage
            local toggleX = rightColumnBaseX + toggleOffsetX
            local toggleY = yPosition - (toggleImage:getHeight() * scale) / 2 + toggleOffsetY

            -- Draw border image if the option is selected
            if i == currentSelection then
                local borderX = toggleX - (toggleBorderImage:getWidth() * scale - toggleImage:getWidth() * scale) / 2
                local borderY = toggleY - (toggleBorderImage:getHeight() * scale - toggleImage:getHeight() * scale) / 2
                love.graphics.draw(toggleBorderImage, borderX, borderY, 0, scale, scale)
            end

            -- Draw toggle image
            love.graphics.draw(toggleImage, toggleX, toggleY, 0, scale, scale)
        else
            local valueText = getOptionValueText(option)
            love.graphics.setColor(0.8, 0.8, 0.8)
            love.graphics.print(valueText, rightColumnBaseX, yPosition)
            love.graphics.setColor(1, 1, 1, 1)
        end

        -- Draw selector border for "Bitrate" and "Device Name" when selected
        if option == "Bitrate" or option == "Device Name" then
            if i == currentSelection then
                local borderX = centerX - dynamicLeftOffsetX + selectorBorderOffsetX
                local borderY = yPosition + selectorBorderOffsetY
                love.graphics.draw(selectorBorderImage, borderX, borderY, 0, scale, scale)
            end
        end
    end

    -- Draw description text
    local description = getOptionDescription(currentSelection)
    local wrappedDescription = wrapText(description, fonts.small, maxWidth)
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.8, 0.8, 0.8)
    local descriptionY = menuStartY + descriptionTopPadding

    for _, line in ipairs(wrappedDescription) do
        love.graphics.print(line, descriptionX, descriptionY)
        descriptionY = descriptionY + fonts.small:getHeight()
    end

    -- Draw status bar
    if tables.settings.mode then
        local statusBarWidth = statusBarImage:getWidth() * scale
        local statusBarX = (push:getWidth() - statusBarWidth) / 2
        local statusBarY = push:getHeight() - statusBarImage:getHeight() * scale + statusBarYOffset
        love.graphics.draw(statusBarImage, statusBarX, statusBarY, 0, scale, scale)

        -- Draw status info
        love.graphics.setFont(fonts.small)
        love.graphics.setColor(1, 1, 1)
        local combinedText = string.format("Status: %s, %s, %s", infoData.status or "Unknown", infoData.host or "", infoData.country or "")
        local combinedTextX = statusBarX + statusBarWidth - fonts.small:getWidth(combinedText) - 10
        love.graphics.print(combinedText, combinedTextX, statusBarY + 10)
    end

    love.graphics.setColor(1, 1, 1, 1)
    local controlIcon = (currentSelection >= 1 and currentSelection <= 3) and controlIconDpadLR or (currentSelection == 4) and controlIconFaceButtonA
    if controlIcon then
        local controlIconX = push:getWidth() - controlIconOffsetX - controlIcon:getWidth() * scale
        local controlIconY = push:getHeight() - controlIconOffsetY - controlIcon:getHeight() * scale
        love.graphics.draw(controlIcon, controlIconX, controlIconY, 0, scale, scale)
    end

    love.graphics.setFont(fonts.regular)
end


-- Helper functions
function getOptionValueText(option)
    if option == "Mode" or option == "Autoplay" then
        return ""
    elseif option == "Bitrate" then
        return tables.bitrate[tables.settings.bitrate] or "Unknown"
    elseif option == "Device Name" then
        return tables.settings.deviceName or "Unknown"
    else
        return ""
    end
end

function getOptionDescription(index)
    return tables.descriptions[index] or "No description available"
end

function draw.setFadeAlpha(alpha)
    fadeAlpha = alpha
end

function love.resize(w, h)
    push:resize(w, h)
end

return draw
