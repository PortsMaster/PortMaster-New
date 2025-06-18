-------------------------------------------------------------------------------------------
-- WINDOW ---------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
function setupWindow()
    love.window.setTitle("Minecraft Launcher")
    love.window.setFullscreen(true, "desktop")
    love.window.setMode(0, 0)
end


-------------------------------------------------------------------------------------------
-- MENU PRESETS ---------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
local menus = {
    mainMenu = {}
}
local selectedMenu = "mainMenu"
local selectedOption = 1

-- Mapping of menu options to file names
local fileMappings = {
    ["Vanilla v1.7.10"] = "1.7.10.start",
    ["Forge v1.7.10"] = "1.7.10-Forge.start",
    ["Vanilla v1.12.2"] = "1.12.2.start",
    ["Forge v1.12.2"] = "1.12.2-Forge.start",
    ["Fabric v1.16.5"] = "1.16.5-Fabric.start",
}

-- Function to populate menu items based on file validation
function populateMenu()
    local menu = {}

    if love.filesystem.getInfo("vanilla-1.7.10-key") then
        table.insert(menu, "Vanilla v1.7.10")
    end
    if love.filesystem.getInfo("forge-1.7.10-key") then
        table.insert(menu, "Forge v1.7.10")
    end
    if love.filesystem.getInfo("vanilla-1.12.2-key") then
        table.insert(menu, "Vanilla v1.12.2")
    end
    if love.filesystem.getInfo("forge-1.12.2-key") then
        table.insert(menu, "Forge v1.12.2")
    end
    if love.filesystem.getInfo("fabric-1.16.5-key") then
        table.insert(menu, "Fabric v1.16.5")
    end

    table.insert(menu, "Exit")  -- Always add Exit last
    menus.mainMenu = menu
end

-------------------------------------------------------------------------------------------
-- FONT SETTINGS --------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
local normalColor = {0.5, 0.5, 0.5, 1}  -- Grey for non-selected
local selectedColor = {1, 1, 1, 1}      -- White for selected
local currentColors = {}
local transitionSpeed = 2
local font  -- Define regular font globally

-- Setup regular font based on window size
function setupFonts()
    local referenceWidth = 1050  -- Baseline res width where fontsize 32 is good
    local referenceHeight = 900  -- Baseline res height
    local displayWidth, displayHeight = love.graphics.getDimensions()  -- Get the current display dimensions

    local scaleFactor = math.min(displayWidth / referenceWidth, displayHeight / referenceHeight)

    local fontSize = 44 * scaleFactor  -- Adjust the font size based on the scale factor

    -- Create regular font with specified filter mode
    font = love.graphics.newFont("assets/font/Proxima Nova Regular Italic.otf", fontSize)
    font:setFilter("linear", "linear")  -- Set filter mode to nearest for sharp edges

    love.graphics.setFont(font)  -- Set the default font
end

-- Initialize currentColors with normalColor for all menu options
function initializeColors()
    for i = 1, #menus[selectedMenu] do
        currentColors[i] = {unpack(normalColor)}
    end
end

-------------------------------------------------------------------------------------------
-- RESOURCE LOADING -----------------------------------------------------------------------
-------------------------------------------------------------------------------------------
local splashlib = require("splash")  -- Assuming "splash.lua" is the correct module name
local splash -- Declare the splash screen variable globally
local fadeParams = {
    fadeAlpha = 1,
    fadeDurationFrames = 20,
    fadeTimer = 0,
    fadeType = "in", -- can be "in" or "out"
    fadeFinished = false
}

function love.load()
    love.window.setTitle("Minecraft Launcher")
    love.window.setMode(800, 600)

    checkRequiredRuntimes() -- <-- Add this line

    qrImage = love.graphics.newImage("qr.png")

    setupWindow()
    setupFonts()
    populateMenu()
    loadBackground()
    initializeColors()
    loadMusic()

    -- Initialize the splash screen with current window dimensions
    local width, height = love.graphics.getDimensions()
    initializeSplashScreen(width, height)

    -- Initialize fade parameters for fade-in effect
    fadeParams.fadeAlpha = 1
    fadeParams.fadeDurationFrames = 20
    fadeParams.fadeTimer = 0
    fadeParams.fadeType = "in"  -- Set initial fade type
    fadeParams.fadeFinished = false
end

-- Function to recall the resolution after screen is set to fullscreen
function love.resize(w, h)
    -- Initialize or update the splash screen with the new dimensions
    initializeSplashScreen(w, h)
end

function initializeSplashScreen(width, height)
    -- Configure the splash screen
    local splashConfig = {
        background = {0, 0, 0},  -- Black background
    }

    -- Initialize or update the splash screen
    splash = splashlib(splashConfig, width, height)
end

function love.keypressed(key)
    -- Handle keyboard input
    if splash and key == "space" then
        splash:skip()
    end
end

function love.gamepadpressed(joystick, button)
    -- Handle gamepad input
    if splash and button == "b" then  -- Adjust "a" to the specific button you want to use
        splash:skip()
    end
end

-------------------------------------------------------------------------------------------
-- DRAW ORDER -----------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
function love.draw()
    -- Draw the splash screen if it exists and is not done
    if splash and not splash.done then
        splash:draw()
    else
	if hasMissingRuntimes() then
        love.graphics.clear(47 / 255, 60 / 255, 126 / 255) -- Background color
        local missing = getMissingRuntimes()

        -- Big warning at the top
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.setFont(love.graphics.newFont(36))
        love.graphics.printf("!! RUNTIMES MISSING !!", 0, 30, love.graphics.getWidth(), "center")

        -- Reset font and color for rest
        love.graphics.setFont(love.graphics.newFont(18))
        love.graphics.setColor(1, 1, 1)

        -- Left: Instructions
        local instructions = [[
Some required runtimes are missing!

To install them either:
1. Scan the QR code on the right with your phone, download the right files and copy them to the PortMaster/libs folder
OR
2. Download them from the PortMaster Application under Options -> Runtime Manager 


        ]]
        love.graphics.printf(instructions, 40, 100, 320, "left")

        -- List missing runtimes below instructions
        love.graphics.setColor(1, 0.8, 0.2)
        love.graphics.printf("Missing Runtimes:", 40, 370, 320, "left")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(table.concat(missing, "\n"), 60, 390, 320, "left")

        -- Right: QR code image (smaller and centered vertically)
        love.graphics.setColor(1, 1, 1)
        local qrScale = 1.2
        local qrWidth = qrImage:getWidth() * qrScale
        local qrHeight = qrImage:getHeight() * qrScale
        local qrX = love.graphics.getWidth() - qrWidth - 80
        local qrY = 140
        love.graphics.draw(qrImage, qrX, qrY, 0, qrScale, qrScale)
    else
        -- Draw the background
        drawBackground()
		drawMenu()
    end
        -- Determine which fade effect to apply
        if fadeParams.fadeType == "in" then
            fadeScreenIn(fadeParams)
        elseif fadeParams.fadeType == "out" then
            fadeScreenOut(fadeParams)
        end
    end
end

-------------------------------------------------------------------------------------------
-- INPUT HANDLING -------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
local inputCooldown = 0.2
local timeSinceLastInput = 0
local escapePressed = false
local gamepadAPressed = false

-- Main input handler (default menu)
function handleInput()
    local gamepad = love.joystick.getJoysticks()[1]
    handleDefaultMenuInput(gamepad)
end

-- Default menu input handler
function handleDefaultMenuInput(gamepad)
    if love.keyboard.isDown("up") or (gamepad and gamepad:isGamepadDown("dpup")) then
        selectPreviousOption()
        playUISound("toggle")  -- Play side sound for upward movement
    elseif love.keyboard.isDown("down") or (gamepad and gamepad:isGamepadDown("dpdown")) then
        selectNextOption()
        playUISound("toggle")  -- Play side sound for downward movement
    elseif love.keyboard.isDown("return") or (gamepad and gamepad:isGamepadDown("a")) then  -- Switched to 'a' for selection action
        handleSelection()
        playUISound("enter")  -- Play enter sound for selection
    end
end


-- Select previous option (upward movement)
function selectPreviousOption()
    selectedOption = selectedOption - 1
    if selectedOption < 1 then
        selectedOption = #menus[selectedMenu]
    end
    timeSinceLastInput = 0
end

-- Select next option (downward movement)
function selectNextOption()
    selectedOption = selectedOption + 1
    if selectedOption > #menus[selectedMenu] then
        selectedOption = 1
    end
    timeSinceLastInput = 0
end

-- Smoothly update colors for all menu options
function updateColors(dt)
    for i = 1, #menus[selectedMenu] do
        local targetColor = normalColor
        if i == selectedOption then
            targetColor = selectedColor
        end

        for j = 1, 4 do
            if currentColors[i][j] < targetColor[j] then
                currentColors[i][j] = math.min(currentColors[i][j] + transitionSpeed * dt, targetColor[j])
            elseif currentColors[i][j] > targetColor[j] then
                currentColors[i][j] = math.max(currentColors[i][j] - transitionSpeed * dt, targetColor[j])
            end
        end
    end
end

-------------------------------------------------------------------------------------------
-- DRAW FUNC MENU -------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

-- Define variables to store the percentage of the display dimensions for menu positioning
local menuPositionYPercentage = 0.65   -- 60% vertically (centered)
local menuPositionXPercentage = 0.98   -- 90% horizontally (right side)

function drawMenu()
    love.graphics.setColor(1, 1, 1, 1)  -- Reset color to white

    local windowHeight = love.graphics.getHeight()  -- Get the height of the window
    local windowWidth = love.graphics.getWidth()  -- Get the width of the window
    local optionYStart = windowHeight * menuPositionYPercentage  -- Calculate the vertical start position based on the percentage
    local optionX = windowWidth * menuPositionXPercentage  -- Calculate the horizontal position based on the percentage
    local optionSpacing = font:getHeight() * 1.5  -- Calculate the spacing between options based on font height

    -- Calculate the starting Y position so that the menu is centered vertically
    local totalMenuHeight = #menus[selectedMenu] * optionSpacing
    local optionY = optionYStart - (totalMenuHeight / 2)

    -- Draw the menu options
    for i, option in ipairs(menus[selectedMenu]) do
        love.graphics.setFont(font)  -- Use the regular font
        love.graphics.setColor(currentColors[i])
        local textWidth = font:getWidth(option)
        love.graphics.print(option, optionX - textWidth, optionY + (i - 1) * optionSpacing)
    end

    love.graphics.setColor(1, 1, 1, 1)  -- Reset color to white
end

-------------------------------------------------------------------------------------------
-- AUDIO ----------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Load background music
function loadMusic()
    -- Stop the background music if it's playing
    if backgroundMusic and backgroundMusic:isPlaying() then
        love.audio.stop(backgroundMusic)
    end

    -- Load a specific music file
    backgroundMusic = love.audio.newSource("assets/audio/music/menu.ogg", "stream")

    -- Set the music to loop and play it if it is not nil
    if backgroundMusic then
        backgroundMusic:setLooping(true)
        love.audio.play(backgroundMusic)
    end
end

function fadeOutBackgroundMusic()
    local fadeDuration = 0.5  -- Fade duration in seconds

    if backgroundMusic and backgroundMusic:isPlaying() then
        local initialVolume = backgroundMusic:getVolume()

        -- Perform gradual volume reduction
        local startTime = love.timer.getTime()
        local elapsedTime = 0

        while elapsedTime < fadeDuration do
            elapsedTime = love.timer.getTime() - startTime
            local progress = elapsedTime / fadeDuration
            local currentVolume = initialVolume * (1 - progress)

            backgroundMusic:setVolume(currentVolume)
            love.timer.sleep(0.01)  -- Adjust sleep time for smoother effect
        end

        love.audio.stop(backgroundMusic)
    end
end
	
-- Play UI sounds
function playUISound(actionType)
    local soundMapping = {
        toggle = "assets/audio/fx/toggle.ogg",
        enter = "assets/audio/fx/enter.ogg"
    }

    local soundPath = soundMapping[actionType]

    if soundPath then
        love.audio.play(love.audio.newSource(soundPath, "static"))
    end
end

-------------------------------------------------------------------------------------------
-- THEMES ---------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Draw background
function loadBackground()
    -- Release previously loaded images (if any)
    if bg then
        bg:release()
    end

    -- Load the background image
    bg = love.graphics.newImage("assets/minecraftbg.png")
end

function drawBackground()
    if not bg then
        return
    end

    local windowWidth, windowHeight = love.graphics.getDimensions()

    -- Stretch the background to fit the entire screen
    love.graphics.draw(bg, 0, 0, 0, windowWidth / bg:getWidth(), windowHeight / bg:getHeight())
end

-------------------------------------------------------------------------------------------
-- HANDLE SELECTION FUNCTION ---------------------------------------------------------------
-------------------------------------------------------------------------------------------
function handleSelection()
    local selectedGame = menus[selectedMenu][selectedOption]  -- Get selected game option text
    local filename = "selected_game.txt"
    local file = io.open(filename, "w")  -- Open file in write mode

    if file then
        local fileToWrite = fileMappings[selectedGame] or selectedGame
        if fileToWrite then
            file:write(fileToWrite)  -- Write the corresponding file name or default to option text
            file:close()  -- Close the file
            print("Selected game file '" .. fileToWrite .. "' written to " .. filename)
            
            -- Fade out the background music
            fadeOutBackgroundMusic()

            -- Initiate fade-out effect (if needed)
            fadeParams.fadeTimer = 0
            fadeParams.fadeType = "out"
            fadeParams.fadeFinished = false

            -- Update function to handle quitting after fade-out
            function love.update(dt)
                if fadeParams.fadeFinished then
                    love.event.quit()  -- Quit LOVE2D after fade-out completes
                end
            end
        else
            print("Error: No file name found for selected game '" .. selectedGame .. "'.")
            file:close()  -- Close the file if not already closed
        end
    else
        print("Error: Unable to open file " .. filename .. " for writing.")
    end
end

-------------------------------------------------------------------------------------------
-- MINOR FUNCTIONS --------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Function to handle fade-in effect
function fadeScreenIn(params)
    params.fadeTimer = params.fadeTimer + 1
    local progress = params.fadeTimer / params.fadeDurationFrames

    params.fadeAlpha = 1 - progress

    if params.fadeTimer >= params.fadeDurationFrames then
        params.fadeAlpha = 0
        params.fadeFinished = true
    end

    love.graphics.setColor(0, 0, 0, params.fadeAlpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)  -- Reset color to white
end

-- Function to handle fade-out effect
function fadeScreenOut(params)
    params.fadeTimer = params.fadeTimer + 1
    local progress = params.fadeTimer / params.fadeDurationFrames

    params.fadeAlpha = progress

    if params.fadeTimer >= params.fadeDurationFrames then
        params.fadeAlpha = 1
        params.fadeFinished = true
    end

    love.graphics.setColor(0, 0, 0, params.fadeAlpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)  -- Reset color to white
end

-- Function to check for quit combinations
function checkForQuitCombination()
    -- Check if Z and X are pressed simultaneously
    if love.keyboard.isDown("z") and love.keyboard.isDown("x") then
        love.event.quit()
    end

    -- Check if rightshoulder and leftshoulder are pressed simultaneously
    local gamepad = love.joystick.getJoysticks()[1]
    if gamepad and gamepad:isGamepadDown("rightshoulder") and gamepad:isGamepadDown("leftshoulder") then
        love.event.quit()
    end
end

-------------------------------------------------------------------------------------------
-- UPDATE LOGIC ---------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Main update function
function love.update(dt)
	timeSinceLastInput = timeSinceLastInput + dt
    -- Check for quit combinations
    checkForQuitCombination()

    -- Update the splash screen if it's not done
    if splash and not splash.done then
        splash:update(dt)
        return
    end

    -- Transition from splash screen to main content
    if splash and splash.done and not splash.skipped then
        splash = nil
        fadeParams.fadeTimer = 0  -- Reset fade timer when splash is done
        fadeParams.fadeFinished = false
        fadeParams.fadeType = "in"  -- Set fade type to "in" for fade-in effect
    end

       -- Handle user input
		if timeSinceLastInput >= inputCooldown then
        if isNumberPadActive then
            handleNumberPadInput()
        else
            handleInput()
        end
		end

    -- Update color transitions
    updateColors(dt)
end


-------------------------------------------------------------------------------------------
-- Runtime checkery -----------------------------------------------------------------------
-------------------------------------------------------------------------------------------
local requiredRuntimes = {
    { filename = "weston_pkg_0.2.squashfs", pretty = "Weston PKG" },
    { filename = "zulu17.54.21-ca-jre17.0.13-linux.squashfs", pretty = "Java 17" },
    { filename = "zulu8.86.0.25-ca-jdk8.0.452-linux.squashfs", pretty = "Java 8" }
}
local missingRuntimes = {}

-- Add this near the top of your file, before you use BaseDir:
local function getBaseDir()
    local str = arg and arg[0] or ""
    return str:match("(.*/)") or "./"
end

local BaseDir = getBaseDir()
print("BaseDir is: " .. BaseDir)

function checkRequiredRuntimes()
    local present = {}
    -- Use LÖVE's filesystem API
    if love.filesystem.getInfo("runtimes.txt") then
        for line in love.filesystem.lines("runtimes.txt") do
            present[line:match("^%s*(.-)%s*$")] = true -- trim whitespace
        end
    end

    local missing = {}
    for _, file in ipairs(requiredRuntimes) do
        if not present[file.filename] then
            table.insert(missing, file.pretty)
        end
    end
    missingRuntimes = missing
    return #missing == 0
end

function hasMissingRuntimes()
    return #missingRuntimes > 0
end

function getMissingRuntimes()
    return missingRuntimes
end
