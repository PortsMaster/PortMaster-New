local input = {}

local inputCooldown = 0.2
local timeSinceLastInput = 0
local joystick
local osk = require("osk") 
local tables = require("tables")
local soundmanager = require("soundmanager")
local command = require("command") 
local talkies = require "talkies" 

function input.load()
    -- Initialize joystick
    local joysticks = love.joystick.getJoysticks()
    if #joysticks > 0 then
        joystick = joysticks[1]
    end
    osk.load()
end

function input.update(dt)
    timeSinceLastInput = timeSinceLastInput + dt

    if joystick and not osk.isVisible() then
        handleJoystickInput(dt)
    end
end

-- Function to handle joystick input and update settings
function handleJoystickInput(dt)
    if timeSinceLastInput >= inputCooldown then
        local settingChanged = false

        local selectableIndices = {1, 2, 3, 4}  

        -- Ensure the current selection is valid based on the selectable indices
        if not tableContains(selectableIndices, currentSelection) then
            currentSelection = selectableIndices[1]
        end

        -- Check for quit command (LB + RB)
        if joystick:isGamepadDown("leftshoulder") and joystick:isGamepadDown("rightshoulder") then
            love.event.quit()  -- Quit
            return
        end

        -- Navigate through the menu using D-pad up and down
        if joystick:isGamepadDown("dpup") then
            currentSelection = currentSelection - 1
            while not tableContains(selectableIndices, currentSelection) do
                currentSelection = currentSelection - 1
                if currentSelection < 1 then
                    currentSelection = #tables.menu
                end
            end
            soundmanager.playUp()  
            timeSinceLastInput = 0  
        elseif joystick:isGamepadDown("dpdown") then
            currentSelection = currentSelection + 1
            while not tableContains(selectableIndices, currentSelection) do
                currentSelection = currentSelection + 1
                if currentSelection > #tables.menu then
                    currentSelection = 1
                end
            end
            soundmanager.playDown() 
            timeSinceLastInput = 0  
        end

        -- Adjust settings based on D-pad left and right
        if joystick:isGamepadDown("dpleft") or joystick:isGamepadDown("dpright") then
            local adjustValue = joystick:isGamepadDown("dpright") and 1 or -1

            if tables.menu[currentSelection] == "Mode" then
                tables.settings.mode = not tables.settings.mode  
                
                -- Run the appropriate command based on the new mode
                if tables.settings.mode then
                    command.startLibrespot(tables.settings)
                else
                    command.stopLibrespot()
                end

                soundmanager.playLeft()  
                timeSinceLastInput = 0 

            elseif tables.menu[currentSelection] == "Autoplay" then
                tables.settings.autoplay = not tables.settings.autoplay  
                settingChanged = true
                soundmanager.playRight()  
                timeSinceLastInput = 0 

            elseif tables.menu[currentSelection] == "Bitrate" then
                tables.settings.bitrate = tables.settings.bitrate + adjustValue
                if tables.settings.bitrate < 1 then tables.settings.bitrate = #tables.bitrate end
                if tables.settings.bitrate > #tables.bitrate then tables.settings.bitrate = 1 end
                settingChanged = true
                soundmanager.playLeft()  
                timeSinceLastInput = 0  
            end

            if settingChanged then
                saveSettings()  
            end
        end

        -- Launch OSK if "Device Name" is selected
        if joystick:isGamepadDown("a") and tables.menu[currentSelection] == "Device Name" then
            osk.show(tables.settings.deviceName, function(newName)
                tables.settings.deviceName = newName
                settingChanged = true
            end)
            timeSinceLastInput = 0  
        end
    end
end

-- Utility function to check if a value is in a table
function tableContains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- Function to get the OSK instance
function input.getOSK()
    return osk
end

return input
