-------------------------------------------------------------------------------------------
-- WINDOW ---------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
function setupWindow()
    love.window.setTitle("Minilauncher")
    love.window.setFullscreen(true, "desktop")
    love.window.setMode(0, 0)
end

-------------------------------------------------------------------------------------------
-- MENU PRESETS ---------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
local menus = {
    mainMenu = {},  -- Dynamically populated later
}
local selectedMenu = "mainMenu"
local selectedOption = 1

-- Mapping of menu options to file names (populated dynamically)
local fileMappings = {}

-- List of subfolders to exclude
local exclusionList = {
    "cfg",
    "data",
    "launcher",
    "libs",
}

-------------------------------------------------------------------------------------------
-- DYNAMIC MENU LOADING -------------------------------------------------------------------
-------------------------------------------------------------------------------------------

-- Function to read the .load.txt file and return the DATA extension to check
function readLoadTxt(folderPath)
    local loadTxtPath = folderPath .. "/.load.txt"
    local file = io.open(loadTxtPath, "r")
    
    if not file then
        print("[LOG]: .load.txt not found in", folderPath)
        return nil
    end
    
    local dataExtension = nil
    
    for line in file:lines() do
        -- Parse the DATA key
        local key, value = line:match("^(%w+)%s*=%s*(.+)$")
        if key == "DATA" then
            dataExtension = value  -- Get the data type (extension)
        end
    end
    
    file:close()
    
    if dataExtension then
        -- Return the data extension (e.g., "SDM")
        return "." .. dataExtension
    else
        print("[LOG]: DATA key not found in .load.txt for", folderPath)
        return nil
    end
end

-- Function to check if any files with the given extension exist in ./data (cwd/data)
function hasDataFiles(cwd, extension)
    -- Assuming data folder is always "./data" within cwd
    local dataFolder = cwd .. "/data"
    
    -- Use the `find` command to search for files with the specified extension in ./data
    local handle = io.popen("find \"" .. dataFolder .. "\" -type f -name '*" .. extension .. "' 2>/dev/null")
    local result = handle:read("*a")
    handle:close()
    
    -- If the result is empty, no files with the specified extension are found
    return result ~= ""
end

-- Function to load menu options from subfolders, excluding folders in the exclusion list
function loadMenuOptions()
    local cwd = love.filesystem.getSourceBaseDirectory()  -- Get current directory path

    -- Clear the main menu to avoid duplication
    menus.mainMenu = {}

    -- Execute shell command to list directories
    local handle = io.popen("ls -d " .. cwd .. "/*/")
    local result = handle:read("*a")
    handle:close()

    -- Split the result into folder names
    for folderPath in result:gmatch("[^\n]+") do
        -- Extract the folder name from the full path
        local folderName = folderPath:match("([^/]+)%/?$")  -- This will capture the last part of the path
        
        -- Ensure folderName is not nil and is not in the exclusion list
        if folderName and not isExcluded(folderName) then
            local fullPath = cwd .. "/" .. folderName

            -- Read the .load.txt file for the DATA extension
            local dataExtension = readLoadTxt(fullPath)
            
            -- Proceed if the data extension is available
            if dataExtension then
                -- Check if there are any files with the specified extension in ./data (cwd/data)
                if hasDataFiles(cwd, dataExtension) then
                    -- Add the folder name to the main menu
                    table.insert(menus.mainMenu, folderName)
                    -- Map the folder name to its corresponding file
                    fileMappings[folderName] = fullPath
                else
                    print("[LOG]: No " .. dataExtension .. " files found in ./data for", folderName)
                    print("[LOG]: Linux is a case-sensitive filesystem. If data files are there, check for case sensitivity.")
                end
            else
                print("[LOG]: Skipping folder due to missing .load.txt or invalid data")
            end
        end
    end

    -- Add the "Exit" option manually at the end of the menu
    table.insert(menus.mainMenu, "Exit")
end

function isExcluded(folderName)
    local exclusionSet = {}
    for _, excluded in ipairs(exclusionList) do
        exclusionSet[excluded] = true
    end
    return exclusionSet[folderName] or false
end


-------------------------------------------------------------------------------------------
-- FONT SETTINGS --------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- FONT SETTINGS
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
    setupWindow()
    setupFonts()
    loadMenuOptions()
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
        drawBackground()
		drawMenu()
        drawRadioButtons()

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
local maxVisibleItems = 5  -- Number of items to display at once
local startIndex = 0       -- Index of the first item in the visible range
local inputCooldown = 0.2
local timeSinceLastInput = 0
local escapePressed = false
local gamepadAPressed = false

-- Define variables for radio buttons
local selectedRadioOption = 1  -- 1 for "EC Wolf", 2 for "LZ Wolf"
local radioButtonSize = 12     -- Size of the radio button
local radioButtonSpacing = 80  -- Spacing between the two radio buttons
local radioButtonLabelOffset = 10  -- Space between radio button and label text
local radioButtonYPercentage = 0.05 -- Position for the radio buttons (5% from the top)
local radioButtonXPercentage = 0.85 -- Align to the right side, similar to the menu

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
    elseif (gamepad and gamepad:isGamepadDown("leftshoulder")) then
        selectedRadioOption = 1  -- "EC Wolf" selected
        selectRadioOption()
        playUISound("toggle")
    elseif (gamepad and gamepad:isGamepadDown("rightshoulder")) then
        selectedRadioOption = 2  -- "LZ Wolf" selected
        selectRadioOption()
        playUISound("toggle")
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

-- Select radio option
function selectRadioOption()
    timeSinceLastInput = 0
end


-- Handle selection in the main menu
function handleMainMenuSelection()
    local selectedOptionText = menus[selectedMenu][selectedOption]
    if selectedOptionText == "Exit" then
        love.event.quit()  -- Quit LOVE2D
    elseif selectedOptionText == "Game 1" then
        -- Open settings menu
        selectedMenu = "Game 1"
        selectedOption = 1
    elseif selectedOptionText == "Game 2" then
        -- Start game
        selectedMenu = "Game 2"
        selectedOption = 1
    elseif selectedOptionText == "Game 3" then
        -- Connect to PC
        selectedMenu = "Game 3"
        selectedOption = 1
    end
    updateCurrentColors()
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
local menuPositionYPercentage = 0.5   -- 50% vertically (centered)
local menuPositionXPercentage = 0.98   -- 90% horizontally (right side)

function drawMenu()
    love.graphics.setColor(1, 1, 1, 1)  -- Reset color to white

    local windowHeight = love.graphics.getHeight()
    local windowWidth = love.graphics.getWidth()
    local optionYStart = windowHeight * menuPositionYPercentage
    local optionX = windowWidth * menuPositionXPercentage
    local optionSpacing = font:getHeight() * 1.5

    -- Check if there are any options to display
    if #menus[selectedMenu] == 0 then
        return  -- No options to draw
    end

    -- Calculate the starting Y position so that the menu is centered vertically
    local totalMenuHeight = math.min(maxVisibleItems, #menus[selectedMenu]) * optionSpacing
    local optionY = optionYStart - (totalMenuHeight / 2)

    -- Draw only the visible options
    for i = 0, math.min(maxVisibleItems - 1, #menus[selectedMenu] - 1) do
        local index = (selectedOption + i - 1) % #menus[selectedMenu] + 1  -- Wrap around the menu options

        local option = menus[selectedMenu][index]  -- Get the current option
        love.graphics.setFont(font)  -- Use the regular font

        -- Check if the font is valid and if the option is a string
        if font and type(option) == "string" then
            -- Set color for selected option
            if index == selectedOption then
                love.graphics.setColor(1, 1, 1, 1)  -- Change color for selected option (e.g., white)
            else
                love.graphics.setColor(currentColors[index] or {1, 1, 1, 1})  -- Set color
            end
            local textWidth = font:getWidth(option)
            love.graphics.print(option, optionX - textWidth, optionY + i * optionSpacing)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)  -- Reset color to white
end

-- Define font size scaling factor
local fontSizeScaleFactor = 1.0  -- Scale factor for font size relative to button size

-- Draw the radio buttons at the top-right of the screen
function drawRadioButtons()
    love.graphics.setColor(1, 1, 1, 1)  -- Set color to white
    local windowHeight = love.graphics.getHeight()
    local windowWidth = love.graphics.getWidth()

    -- Calculate the position for the radio buttons
    local radioButtonY = windowHeight * radioButtonYPercentage
    local radioButtonX = windowWidth * radioButtonXPercentage

    -- Set the font size based on button size
    local fontSize = radioButtonSize * fontSizeScaleFactor
    love.graphics.setFont(love.graphics.newFont(fontSize))  -- Create a new font with the calculated size

    -- Draw first radio button ("EC Wolf")
    local ecWolfX = radioButtonX - (2 * radioButtonSize + radioButtonSpacing)  -- Left button
    love.graphics.circle("line", ecWolfX, radioButtonY, radioButtonSize / 2)  -- Outer circle

    -- Fill if selected
    if selectedRadioOption == 1 then
        love.graphics.circle("fill", ecWolfX, radioButtonY, radioButtonSize / 4)  -- Inner filled circle
    end
    
    -- Calculate the vertical position for the label to align with the button
    local ecWolfLabelY = radioButtonY - fontSize / 2  -- Align vertically with the center of the button
    love.graphics.print("EC Wolf", ecWolfX + radioButtonLabelOffset, ecWolfLabelY)

    -- Draw second radio button ("LZ Wolf")
    local lzWolfX = ecWolfX + radioButtonSize + radioButtonSpacing  -- Right button
    love.graphics.circle("line", lzWolfX, radioButtonY, radioButtonSize / 2)  -- Outer circle

    -- Fill if selected
    if selectedRadioOption == 2 then
        love.graphics.circle("fill", lzWolfX, radioButtonY, radioButtonSize / 4)  -- Inner filled circle
    end
    
    -- Calculate the vertical position for the label to align with the button
    local lzWolfLabelY = radioButtonY - fontSize / 2  -- Align vertically with the center of the button
    love.graphics.print("LZ Wolf", lzWolfX + radioButtonLabelOffset, lzWolfLabelY)

    -- Draw the instruction text closer to the radio buttons
    local instructionY = radioButtonY + 18 -- Adjust positioning closer
    local instructionX = radioButtonX - (4 * radioButtonSize + radioButtonSpacing + radioButtonLabelOffset)  -- Move left
    love.graphics.print("Use L/R to select an engine to use", instructionX, instructionY)

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
	
-- Function to play a UI sound based on the action type
function playUISound(actionType)
    local soundPath = nil

    -- Determine which sound to play based on actionType
    if actionType == "toggle" then
        soundPath = "assets/audio/fx/toggle.ogg"
    elseif actionType == "enter" then
        soundPath = "assets/audio/fx/enter.ogg"
    end

    -- Check if soundPath is valid and play the sound
    if soundPath then
        love.audio.play(love.audio.newSource(soundPath, "static"))
    end
end


-------------------------------------------------------------------------------------------
-- THEMES ---------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
math.randomseed(os.time()) -- needed for randomness

-- Variables for star animation
local starSpriteSheet
local starFrameWidth = 64
local starFrameHeight = 64
local starNumFrames = 9
local starAnimationDuration = 0.4 -- Duration for the entire animation in seconds
local starAppearInterval = math.random(2, 4) -- Initial random interval between 2 and 5 seconds
local starTimer = 0
local starPositionX, starPositionY
local starVisible = false
local starAnimationStartTime = 0

-- Background and animated sprite variables
local sky, background, animatedSpriteSheet
local spriteWidth = 80
local spriteHeight = 80
local numColumns = 25
local numRows = 25
local totalFrames = numColumns * numRows

function loadBackground()
    -- Release previously loaded images (if any)
    if sky then
        sky:release()
        sky = nil
    end
    if background then
        background:release()
        background = nil
    end
      
    -- Load images with nearest-neighbor filtering
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Load Moonlight theme images
    sky = love.graphics.newImage("assets/wolfbg.png")
    sky:setFilter("nearest", "nearest")

    -- Restore default filter settings
    love.graphics.setDefaultFilter("linear", "linear")
end

function drawBackground()
    if not sky then
        return
    end

    local windowWidth, windowHeight = love.graphics.getDimensions()

    -- Set the default filter to nearest for sharp pixel scaling
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Draw the sky layer
    local skyScale = windowHeight / sky:getHeight()
    local skyWidth = sky:getWidth() * skyScale
    local skyOffsetX = math.floor((windowWidth - skyWidth) / 2)
    love.graphics.draw(sky, math.floor(skyOffsetX), 0, 0, skyScale, skyScale)
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
            file:write(fileToWrite .. "\n")  -- Write the corresponding file name or default to option text
            
            -- Write the selected radio option
            if selectedRadioOption == 1 then
                file:write("ecwolf\n")  -- Write label for EC Wolf
            elseif selectedRadioOption == 2 then
                file:write("lzwolf\n")  -- Write label for LZ Wolf
            end
            
            file:close()  -- Close the file
            
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
            file:close()  -- Close the file if not already closed
        end
    else
        print("Error opening file for writing")  -- Print error if file couldn't be opened
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