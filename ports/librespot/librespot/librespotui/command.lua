local command = {}
local tables = require("tables")

-- Convert bitrate string to numeric value
local function getBitrateValue(bitrate)
    if bitrate == "Normal" then
        return 160
    elseif bitrate == "High" then
        return 320
    end
end

function command.stopLibrespot()
    local lovedir = love.filesystem.getSourceBaseDirectory()
    if not lovedir then
        print("LOVEDIR is not set. Exiting.")
        return
    end
    print("LOVEDIR is set to: " .. lovedir)

    -- Construct the command string with lovedir using pkill -9
    local commandStr = "pkill -9 -f '" .. lovedir .. "/librespot'"
    print("Executing command to forcefully stop librespot:", commandStr)

    -- Execute the command
    local success = os.execute(commandStr)

    -- Print the result of the command execution
    if success then
        print("Command executed successfully.")
    else
        print("Command execution failed.")
    end
end


-- Function to start the librespot process and log output
function command.startLibrespot(settings)
    local lovedir = love.filesystem.getSourceBaseDirectory()
    if not lovedir then
        print("LOVEDIR is not set. Exiting.")
        return
    end

    local bitrate = getBitrateValue(tables.bitrate[settings.bitrate])
    local deviceName = settings.deviceName or "DefaultDeviceName"
    local cacheDir = lovedir .. "/cache"
    local autoplayFlag = settings.autoplay and "--autoplay on" or ""

    -- Base command with optional autoplay flag
    local commandStr = string.format(
        "%s/librespot --name '%s' --bitrate %d --cache '%s' --device-type gameconsole --backend sdl %s",
        lovedir, deviceName, bitrate, cacheDir, autoplayFlag
    )

    -- Add redirection and background execution
    commandStr = commandStr .. " > info.txt 2>&1 &"
    print("Executing command:", commandStr)

    -- Execute the command and check success
    local success = os.execute(commandStr)
    print(success and "Command executed successfully." or "Command execution failed.")
end


-- Function to run the appropriate command based on settings
function command.run(settings)
    if settings.autoplay == 1 then
        -- If autoplay is on, start librespot
        command.startLibrespot(settings)
    else
        -- If autoplay is off, stop librespot
        command.stopLibrespot()
    end
    -- Print confirmation message
    print("Autoplay is set to", settings.autoplay == 1 and "ON" or "OFF")
end

return command
