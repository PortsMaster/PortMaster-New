-- ROCKNIX Screen Capture UI
-- Screenshot and Video Recording Tool
local push = require('push')
local timer = require('timer')

local gameWidth, gameHeight = 640, 480
local windowWidth, windowHeight = 640, 480

-- Capture modes
local modes = {
    {name = "Screenshot Hotkey", description = "Save to /storage/roms/screenshots/", command = "hotkey_screenshot", duration = 0},
    {name = "Record 5s Hotkey", description = "Right Plus button records 5 seconds", command = "hotkey_record", duration = 5},
    {name = "Record 10s Hotkey", description = "Right Plus button records 10 seconds", command = "hotkey_record", duration = 10},
    {name = "Record 30s Hotkey", description = "Right Plus button records 30 seconds", command = "hotkey_record", duration = 30},
    {name = "Disable Hotkey", description = "Stop background hotkey daemon", command = "hotkey_stop", duration = 0},
}


local gameState = {
    screen = "menu",           -- menu, capturing, complete, error
    selectedMode = 1,
    scrollOffset = 0,
    maxVisible = 5,
    status = "",
    progress = 0,
    result = nil,
    captureActive = false,
}

-- Button hold state for continuous scrolling
local buttonHold = {
    dpup = false,
    dpdown = false,
    timer = 0,
    repeatDelay = 0.3,
    repeatRate = 0.15
}

function love.load()
    push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {
        fullscreen = true,
        resizable = false,
        pixelperfect = false
    })

    -- Load fonts (use built-in if custom not available)
    local fontPath = "assets/fonts/pixely.ttf"
    local fontExists = love.filesystem.getInfo(fontPath)

    if fontExists then
        titleFont = love.graphics.newFont(fontPath, 32)
        headerFont = love.graphics.newFont(fontPath, 28)
        bodyFont = love.graphics.newFont(fontPath, 20)
        smallFont = love.graphics.newFont(fontPath, 16)
    else
        titleFont = love.graphics.newFont(28)
        headerFont = love.graphics.newFont(22)
        bodyFont = love.graphics.newFont(18)
        smallFont = love.graphics.newFont(14)
    end

    -- Color palette (matching fetcher theme)
    bgColor = {0.776, 0.878, 0.020}           -- Light green background
    footerColor = {0.616, 0.741, 0.145}       -- Darker green for footer
    titleColor = {0.129, 0.259, 0.192}        -- Dark green for titles
    textColor = {0.129, 0.259, 0.192}         -- Dark green for text
    selectionBgColor = {0.616, 0.741, 0.145}  -- Selection background
    progressBgColor = {0.4, 0.4, 0.4}         -- Progress bar background
    progressFgColor = {0.129, 0.259, 0.192}   -- Progress bar foreground
end

function love.update(dt)
    timer.update(dt)

    -- Handle continuous scrolling when holding dpad
    if (buttonHold.dpup or buttonHold.dpdown) and gameState.screen == "menu" then
        buttonHold.timer = buttonHold.timer + dt
        if buttonHold.timer >= buttonHold.repeatRate then
            buttonHold.timer = 0
            if buttonHold.dpdown then
                gameState.selectedMode = math.min(#modes, gameState.selectedMode + 1)
                updateScroll()
            elseif buttonHold.dpup then
                gameState.selectedMode = math.max(1, gameState.selectedMode - 1)
                updateScroll()
            end
        end
    end

    -- Monitor capture progress
    if gameState.captureActive then
        checkCaptureProgress()
    end
end

function love.draw()
    push:start()

    love.graphics.setColor(bgColor)
    love.graphics.rectangle('fill', 0, 0, gameWidth, gameHeight)

    if gameState.screen == "menu" then
        drawMenuScreen()
    elseif gameState.screen == "capturing" then
        drawCapturingScreen()
    elseif gameState.screen == "complete" then
        drawCompleteScreen()
    elseif gameState.screen == "error" then
        drawErrorScreen()
    end

    push:finish()
end

function drawMenuScreen()
    -- Title
    love.graphics.setColor(titleColor)
    love.graphics.setFont(titleFont)
    love.graphics.printf("SCREEN CAPTURE", 0, 25, gameWidth, 'center')

    -- Mode list
    local startY = 80
    local itemHeight = 60

    for i = 1, math.min(gameState.maxVisible, #modes) do
        local modeIndex = i + gameState.scrollOffset
        if modeIndex <= #modes then
            local mode = modes[modeIndex]
            local yPos = startY + (i - 1) * itemHeight

            -- Draw selection background
            if modeIndex == gameState.selectedMode then
                love.graphics.setColor(selectionBgColor)
                love.graphics.rectangle('fill', 30, yPos - 5, gameWidth - 60, itemHeight)
            end

            -- Mode name
            love.graphics.setColor(textColor)
            love.graphics.setFont(headerFont)
            love.graphics.printf(mode.name, 50, yPos, gameWidth - 100, 'left')

            -- Description (capture modes)
            love.graphics.setFont(smallFont)
            love.graphics.printf(mode.description, 50, yPos + 25, gameWidth - 100, 'left')
        end
    end

    -- Scroll indicators
    if gameState.scrollOffset > 0 then
        love.graphics.setColor(textColor)
        love.graphics.setFont(bodyFont)
        love.graphics.printf("▲", 0, 65, gameWidth, 'center')
    end

    if gameState.scrollOffset + gameState.maxVisible < #modes then
        love.graphics.setColor(textColor)
        love.graphics.setFont(bodyFont)
        love.graphics.printf("▼", 0, 340, gameWidth, 'center')
    end

    -- Footer
    love.graphics.setColor(footerColor)
    love.graphics.rectangle('fill', 0, 390, gameWidth, 90)

    love.graphics.setColor(textColor)
    love.graphics.setFont(headerFont)
    love.graphics.printf("Up/Down: Select | A: Start Capture | Start: Exit", 0, 410, gameWidth, 'center')

    -- Selected mode info
    local selectedMode = modes[gameState.selectedMode]
    love.graphics.setFont(smallFont)
    if selectedMode.command == "screenshot" then
        love.graphics.printf("Save to: /storage/roms/screenshots/", 0, 445, gameWidth, 'center')
    else
        love.graphics.printf("Save to: /storage/roms/recordings/", 0, 445, gameWidth, 'center')
    end
end

function drawCapturingScreen()
    local mode = modes[gameState.selectedMode]

    -- Title
    love.graphics.setColor(titleColor)
    love.graphics.setFont(titleFont)
    if mode.command == "screenshot" then
        love.graphics.printf("CAPTURING SCREENSHOT", 0, 80, gameWidth, 'center')
    else
        love.graphics.printf("RECORDING VIDEO", 0, 80, gameWidth, 'center')
    end

    -- Status
    love.graphics.setColor(textColor)
    love.graphics.setFont(headerFont)
    love.graphics.printf(gameState.status, 0, 150, gameWidth, 'center')

    -- Progress bar (for recording)
    if mode.command == "record" and gameState.progress > 0 then
        local barWidth = 400
        local barHeight = 30
        local barX = (gameWidth - barWidth) / 2
        local barY = 220

        -- Background
        love.graphics.setColor(progressBgColor)
        love.graphics.rectangle('fill', barX, barY, barWidth, barHeight, 5, 5)

        -- Progress
        love.graphics.setColor(progressFgColor)
        local progressWidth = barWidth * (gameState.progress / 100)
        love.graphics.rectangle('fill', barX, barY, progressWidth, barHeight, 5, 5)

        -- Percentage text
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(bodyFont)
        love.graphics.printf(gameState.progress .. "%", barX, barY + 5, barWidth, 'center')
    end

    -- Spinner animation
    local dots = string.rep(".", math.floor(love.timer.getTime() * 3) % 4)
    love.graphics.setColor(textColor)
    love.graphics.setFont(bodyFont)
    love.graphics.printf("Please wait" .. dots, 0, 300, gameWidth, 'center')

    -- Footer
    love.graphics.setColor(footerColor)
    love.graphics.rectangle('fill', 0, 390, gameWidth, 90)

    love.graphics.setColor(textColor)
    love.graphics.setFont(bodyFont)
    love.graphics.printf("B: Cancel", 0, 420, gameWidth, 'center')
end

function drawCompleteScreen()
    -- Title
    love.graphics.setColor(titleColor)
    love.graphics.setFont(titleFont)
    love.graphics.printf("COMPLETE!", 0, 80, gameWidth, 'center')

    -- Result info
    love.graphics.setColor(textColor)
    love.graphics.setFont(headerFont)

    if gameState.result then
        -- Handle simple message (for hotkey enable/disable)
        if gameState.result.message then
            love.graphics.setFont(titleFont)
            love.graphics.printf(gameState.result.message, 50, 180, gameWidth - 100, 'center')
        elseif gameState.result.file then
            love.graphics.printf("Saved to:", 0, 160, gameWidth, 'center')
            love.graphics.setFont(smallFont)
            love.graphics.printf(gameState.result.file, 30, 200, gameWidth - 60, 'center')

            love.graphics.setFont(bodyFont)
            if gameState.result.size_kb then
                love.graphics.printf(string.format("Size: %.1f KB", gameState.result.size_kb), 0, 250, gameWidth, 'center')
            elseif gameState.result.size_mb then
                love.graphics.printf(string.format("Size: %.2f MB", gameState.result.size_mb), 0, 250, gameWidth, 'center')
            end

            if gameState.result.width and gameState.result.height then
                love.graphics.printf(string.format("Resolution: %dx%d", gameState.result.width, gameState.result.height), 0, 285, gameWidth, 'center')
            end

            if gameState.result.duration then
                love.graphics.printf(string.format("Duration: %ds at %dfps", gameState.result.duration, gameState.result.fps or 10), 0, 320, gameWidth, 'center')
            end
        end
    end

    -- Footer
    love.graphics.setColor(footerColor)
    love.graphics.rectangle('fill', 0, 390, gameWidth, 90)

    love.graphics.setColor(textColor)
    love.graphics.setFont(bodyFont)
    love.graphics.printf("B: Back to Menu | Start: Exit", 0, 420, gameWidth, 'center')
end

function drawErrorScreen()
    -- Title
    love.graphics.setColor({0.8, 0.2, 0.2})
    love.graphics.setFont(titleFont)
    love.graphics.printf("CAPTURE FAILED", 0, 100, gameWidth, 'center')

    -- Error message
    love.graphics.setColor(textColor)
    love.graphics.setFont(bodyFont)
    love.graphics.printf(gameState.status, 50, 180, gameWidth - 100, 'center')

    -- Footer
    love.graphics.setColor(footerColor)
    love.graphics.rectangle('fill', 0, 390, gameWidth, 90)

    love.graphics.setColor(textColor)
    love.graphics.setFont(bodyFont)
    love.graphics.printf("A: Try Again | B: Back to Menu | Start: Exit", 0, 420, gameWidth, 'center')
end

function love.keypressed(key)
    if gameState.screen == "menu" then
        if key == "up" then
            gameState.selectedMode = math.max(1, gameState.selectedMode - 1)
            updateScroll()
        elseif key == "down" then
            gameState.selectedMode = math.min(#modes, gameState.selectedMode + 1)
            updateScroll()
        elseif key == "return" or key == "space" then
            startCapture()
        elseif key == "escape" then
            love.event.quit()
        end
    elseif gameState.screen == "complete" or gameState.screen == "error" then
        if key == "return" or key == "space" then
            startCapture()
        elseif key == "backspace" then
            gameState.screen = "menu"
        elseif key == "escape" then
            love.event.quit()
        end
    elseif gameState.screen == "capturing" then
        if key == "backspace" then
            cancelCapture()
        end
    end
end

function love.gamepadpressed(joystick, button)
    if button == "a" then
        love.keypressed("return")
    elseif button == "b" then
        love.keypressed("backspace")
    elseif button == "start" then
        love.keypressed("escape")
    elseif button == "dpup" then
        love.keypressed("up")
        if gameState.screen == "menu" then
            buttonHold.dpup = true
            buttonHold.timer = -buttonHold.repeatDelay
        end
    elseif button == "dpdown" then
        love.keypressed("down")
        if gameState.screen == "menu" then
            buttonHold.dpdown = true
            buttonHold.timer = -buttonHold.repeatDelay
        end
    end
end

function love.gamepadreleased(joystick, button)
    if button == "dpup" then
        buttonHold.dpup = false
        buttonHold.timer = 0
    elseif button == "dpdown" then
        buttonHold.dpdown = false
        buttonHold.timer = 0
    end
end

function updateScroll()
    if gameState.selectedMode <= gameState.scrollOffset then
        gameState.scrollOffset = math.max(0, gameState.selectedMode - 1)
    elseif gameState.selectedMode > gameState.scrollOffset + gameState.maxVisible then
        gameState.scrollOffset = gameState.selectedMode - gameState.maxVisible
    end
end

function cancelCapture()
    if not gameState.captureActive then
        return
    end

    -- Kill the Python capture process
    os.execute("pkill -f 'python3 capture.py' 2>/dev/null")

    -- Clean up temp files
    os.execute("rm -f /tmp/capture_progress.json /tmp/capture_result.json 2>/dev/null")

    gameState.captureActive = false
    gameState.screen = "menu"
    gameState.status = ""
    gameState.progress = 0
end

function startCapture()
    local mode = modes[gameState.selectedMode]
    local captureDir = os.getenv("LOVEDIR") or "/storage/roms/ports/amos_capture"

    -- Handle hotkey daemon commands
    if mode.command == "hotkey_screenshot" then
        -- Start daemon in screenshot mode (use nohup and redirect to ensure it survives app exit)
        os.execute(string.format("python3 %s/hotkey_daemon.py stop 2>/dev/null", captureDir))
        os.execute(string.format("nohup python3 %s/hotkey_daemon.py start screenshot </dev/null >/dev/null 2>&1 &", captureDir))
        gameState.screen = "complete"
        gameState.result = {message = "Screenshot hotkey enabled!\nPress Right Plus button during gameplay."}
        return
    elseif mode.command == "hotkey_record" then
        -- Start daemon in record mode with duration (use nohup and redirect to ensure it survives app exit)
        os.execute(string.format("python3 %s/hotkey_daemon.py stop 2>/dev/null", captureDir))
        os.execute(string.format("nohup python3 %s/hotkey_daemon.py start record %d </dev/null >/dev/null 2>&1 &", captureDir, mode.duration))
        gameState.screen = "complete"
        gameState.result = {message = string.format("Record %ds hotkey enabled!\nPress Right Plus button during gameplay.", mode.duration)}
        return
    elseif mode.command == "hotkey_stop" then
        os.execute(string.format("python3 %s/hotkey_daemon.py stop", captureDir))
        gameState.screen = "complete"
        gameState.result = {message = "Hotkey daemon disabled."}
        return
    end

    -- Direct capture (not used in current menu)
    gameState.screen = "capturing"
    gameState.captureActive = true
    gameState.progress = 0
    gameState.result = nil

    if mode.command == "screenshot" then
        gameState.status = "Capturing framebuffer..."
    else
        gameState.status = string.format("Recording %d seconds...", mode.duration)
    end

    -- Clear previous progress file
    os.execute("rm -f /tmp/capture_progress.json")

    -- Build and execute capture command
    local command

    if mode.command == "screenshot" then
        command = string.format("cd %s && python3 capture.py screenshot > /tmp/capture_result.json 2>&1 &", captureDir)
    else
        command = string.format("cd %s && python3 capture.py record -d %d -f 10 > /tmp/capture_result.json 2>&1 &", captureDir, mode.duration)
    end

    os.execute(command)

    -- Start monitoring progress
    timer.after(0.5, function()
        checkCaptureProgress()
    end)
end

function checkCaptureProgress()
    if not gameState.captureActive then
        return
    end

    -- Check progress file
    local progressFile = io.open("/tmp/capture_progress.json", "r")
    if progressFile then
        local content = progressFile:read("*all")
        progressFile:close()

        if content and content ~= "" then
            -- Parse progress JSON
            local status = content:match('"status":%s*"([^"]+)"')
            local percent = tonumber(content:match('"percent":%s*(%d+)')) or 0
            local message = content:match('"message":%s*"([^"]*)"')

            gameState.progress = percent

            if message and message ~= "" then
                gameState.status = message
            end

            if status == "complete" then
                -- Capture complete - parse result
                gameState.captureActive = false
                gameState.screen = "complete"

                -- Parse result details
                gameState.result = {}
                gameState.result.file = content:match('"file":%s*"([^"]+)"')
                gameState.result.width = tonumber(content:match('"width":%s*(%d+)'))
                gameState.result.height = tonumber(content:match('"height":%s*(%d+)'))
                gameState.result.size_kb = tonumber(content:match('"size_kb":%s*([%d%.]+)'))
                gameState.result.size_mb = tonumber(content:match('"size_mb":%s*([%d%.]+)'))
                gameState.result.duration = tonumber(content:match('"duration":%s*(%d+)'))
                gameState.result.fps = tonumber(content:match('"fps":%s*(%d+)'))

                return
            elseif status == "error" then
                gameState.captureActive = false
                gameState.screen = "error"
                gameState.status = content:match('"error":%s*"([^"]*)"') or "Unknown error"
                return
            end
        end
    end

    -- Continue monitoring
    timer.after(0.3, function()
        checkCaptureProgress()
    end)
end
