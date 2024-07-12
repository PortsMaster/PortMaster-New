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
    mainMenu = {"To The Moon", "Minisode 1", "Minisode 2", "Exit"},
}
local selectedMenu = "mainMenu"
local selectedOption = 1

-- Mapping of menu options to file names
local fileMappings = {
    ["To The Moon"] = "gamedata",
    ["Minisode 1"] = "minisode1",
    ["Minisode 2"] = "minisode2",
}

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
        -- Draw the background
        drawBackground()
		
		drawMenu()

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
    backgroundMusic = love.audio.newSource("assets/audio/music/gymnopedie.ogg", "stream")

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
    sky = love.graphics.newImage("assets/video/tothemoonback.png")
    sky:setFilter("nearest", "nearest")
    background = love.graphics.newImage("assets/video/tothemoonfront.png")
    background:setFilter("nearest", "nearest")
    starSpriteSheet = love.graphics.newImage("assets/video/star_tiles.png")

    -- Restore default filter settings
    love.graphics.setDefaultFilter("linear", "linear")
end



function updateStar(dt)
    starTimer = starTimer + dt
    
    if starTimer >= starAppearInterval then
        starTimer = starTimer - starAppearInterval
        starVisible = true
        
        local windowWidth, windowHeight = love.graphics.getDimensions()
        local skyScale = windowHeight / sky:getHeight()
        local starScale = skyScale
        
        -- Calculate star position ensuring it stays within visible bounds
        if selectedThemeIndex == 1 then
            -- Moonlight theme: stars spawn in the top 25% of the display
            starPositionX = math.random(starFrameWidth, windowWidth - starFrameWidth * starScale)
            starPositionY = math.random(0, windowHeight * 0.4 - starFrameHeight * starScale)
        else
            -- Other themes: stars spawn randomly across the screen
            starPositionX = math.random(starFrameWidth, windowWidth - starFrameWidth * starScale)
            starPositionY = math.random(starFrameHeight, windowHeight - starFrameHeight * starScale)
        end
        
        starAnimationStartTime = love.timer.getTime()
    end

    if starVisible and love.timer.getTime() - starAnimationStartTime >= starAnimationDuration then
        starVisible = false
    end
end

function drawBackground()
    if not sky or not background then
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
    
    -- Draw the star sprite if visible and starSpriteSheet is not nil
    if starSpriteSheet and starVisible then
        local currentTime = love.timer.getTime()
        local starFrameIndex = math.floor((currentTime - starAnimationStartTime) / starAnimationDuration * starNumFrames) % starNumFrames
        local starQuad = love.graphics.newQuad(starFrameIndex * starFrameWidth, 0, starFrameWidth, starFrameHeight, starSpriteSheet:getDimensions())
        
        -- Calculate star position and scale based on background scaling
        local starScale = skyScale -- Use the same scale as the background
        local starX = math.floor(skyOffsetX + starPositionX)
        local starY = math.floor(starPositionY)
        
        love.graphics.draw(starSpriteSheet, starQuad, starX, starY, 0, starScale, starScale)
    end

    -- Draw the background layer
    if background then
        local backgroundScale = windowHeight / background:getHeight()
        local backgroundWidth = background:getWidth() * backgroundScale
        local backgroundOffsetX = math.floor((windowWidth - backgroundWidth) / 2)
        love.graphics.draw(background, math.floor(backgroundOffsetX), 0, 0, backgroundScale, backgroundScale)
    end
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

    -- Update stars (or other background elements)
    updateStar(dt)
end