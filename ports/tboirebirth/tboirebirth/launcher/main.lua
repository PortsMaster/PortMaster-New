-- Configuration Utility UI in LÖVE2D
-- main.lua

-- Config file path
local configFile = "config.cfg"

-- List of boolean configuration options with internal keys and help text
local options = {
    { key = "scale_hack",      name = "Non-Integer Scaling Hack", value = true, help = "Hack that enables scaling to non-integer values.\nIncreases visibility on small screens, but looks worse." },
    { key = "disable_effects", name = "Disable Effects",          value = true, help = "Turns off lighting and visual effects.\nBig performance boost, looks worse." },
    { key = "disable_fog_overlays", name = "Disable Fog/Overlays",          value = true, help = "Turns off fog and overlays like shadows.\nBig performance boost on later floors, looks worse." },
    { key = "reduce_quality",  name = "Reduce Texture Quality",   value = true, help = "Reduces bitdepth to 16 bit.\nSmall performance boost, lower RAM usage. Looks worse." },
    { key = "x11_hack",        name = "X11 Performance Hack",     value = true, help = "Caches and reduces XGetWindowAttributes calls.\nMassive performance boost. Slight visual glitches on startup." },
    { key = "xkb_fix",         name = "XKB Crash Fix",            value = true, help = "Prevents crashes related to XkbGetKeyboard on XWayland.\nKeep enabled unless you're on a pure X11 system." },
    { key = "swap_ab",         name = "Swap A/B Buttons",         value = false, help = "For TrimUI devices, swaps A/B buttons to correspond\nto their cardinal directions." },
    { key = "swap_abxy",       name = "XBox Style A/B/X/Y",          value = false, help = "For devices with XBox style controls.\nSwaps A/B/X/Y buttons to correspond to their cardinal directions." },
}

-- Index of currently selected item (1 to #options + 1 for launch button at top)
local selected = 1

-- Track if termination was due to SIGTERM
local receivedSigterm = false

local titleFont
local optionFont
local helpFont

-- Load or initialize configuration
local function loadConfig()
    if love.filesystem.getInfo(configFile) then
        local contents = love.filesystem.read(configFile)
        -- Iterate over lines
        for line in contents:gmatch("[^\n]+") do
            -- Parse key = 0 or 1
            local k, v = line:match("^([%w_]+)%s*=%s*([01])%s*$")
            if k and v then
                for _, opt in ipairs(options) do
                    if opt.key == k then
                        opt.value = (v == "1")
                        break
                    end
                end
            end
        end
    end
end

-- Save current options to config file
local function saveConfig()
    local lines = {}
    for _, opt in ipairs(options) do
        lines[#lines+1] = string.format("%s=%d", opt.key, opt.value and 1 or 0)
    end
    love.filesystem.write(configFile, table.concat(lines, "\n"))
end

function love.load()
    helpFont = love.graphics.newFont(15)
    titleFont = love.graphics.newFont(30)
    optionFont = love.graphics.newFont(22)
    helpFont = love.graphics.newFont(15)
    love.graphics.setFont(optionFont)

    loadConfig()

    -- Apply fullscreen option immediately
    love.window.setFullscreen(true)

    -- Setup SIGTERM handler (requires LuaJIT FFI and external signal hook)
    if pcall(require, "ffi") then
        local ffi = require("ffi")
        ffi.cdef[[
            typedef void (*sighandler_t)(int);
            sighandler_t signal(int signum, sighandler_t handler);
        ]]
        local C = ffi.C
        local SIGTERM = 15
        local function handle_sigterm(sig)
            receivedSigterm = true
            love.event.quit()
        end
        local cb = ffi.cast("sighandler_t", handle_sigterm)
        C.signal(SIGTERM, cb)
    end
end

function love.draw()
    local w, h = love.graphics.getDimensions()
    local startY = 55
    local spacing = 40

    -- Draw header
    love.graphics.setFont(titleFont)
    love.graphics.printf("TBOI: Rebirth Port Launcher", 0, 10, w, "center")
    love.graphics.setFont(optionFont)

    -- Draw Launch button at the top
    local y = startY
    if selected == 1 then
        love.graphics.setColor(0.3, 0.6, 0.3)
    else
        love.graphics.setColor(0.1, 0.5, 0.1)
    end
    local btnW, btnH = 350, 50
    local btnX = (w - btnW) / 2
    love.graphics.rectangle("fill", btnX, y, btnW, btnH, 8, 8)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Launch Game", btnX, y + (btnH - 24) / 2, btnW, "center")

    -- Draw each option below the Launch button
    for i, opt in ipairs(options) do
        local optionIndex = i + 1 -- because launch button is index 1
        local optY = startY + btnH + 20 + (i - 1) * spacing
        if selected == optionIndex then
            love.graphics.setColor(0.4, 0.4, 0.4, 0.5)
            love.graphics.rectangle("fill", w/4 - 10, optY - 5, w/2+60, spacing)
        end
        love.graphics.setColor(1,1,1)

        -- Draw checkbox
        local boxX = w/4-50
        love.graphics.rectangle("line", boxX, optY, 24, 24)
        if opt.value then
            love.graphics.line(boxX, optY, boxX+24, optY+24)
            love.graphics.line(boxX+24, optY, boxX, optY+24)
        end
        love.graphics.print(opt.name, boxX + 40, optY)
    end

    -- Draw help text at the bottom
    love.graphics.setFont(helpFont)
    love.graphics.setColor(1, 1, 1)
    local helpText = ""
    if selected == 1 then
        helpText = "Start the game with the selected configuration."
    else
        local opt = options[selected - 1]
        helpText = opt.help or ""
    end
    love.graphics.printf(helpText, 0, h - 45, w-10, "center")
    love.graphics.setFont(optionFont)
end

function love.keypressed(key)
    local totalItems = #options + 1 -- 1 for launch button
    if key == "down" then
        selected = selected < totalItems and selected + 1 or 1
    elseif key == "up" then
        selected = selected > 1 and selected - 1 or totalItems
    elseif key == "space" or key == "return" or key == "right" or key == "left" then
        if selected == 1 then
            launch()
        else
            local opt = options[selected - 1]
            opt.value = not opt.value
            if opt.key == "fullscreen" then
                love.window.setFullscreen(opt.value)
            end
            saveConfig()
        end
    end
end

function love.quit()
    saveConfig()
    if receivedSigterm then
        os.exit(1)
    end
end

function launch()
    saveConfig()
    print("Launching with configuration:")
    for _, opt in ipairs(options) do
        print(string.format("%s = %s", opt.name, tostring(opt.value)))
    end
    love.event.quit()
end
