-------------------------------------------------------------------------------------------
-- INITIALIZATION -------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

-- Splash globals
local splashlib = require("splash")
local splash
local fadeParams = {
    fadeAlpha = 1,
    fadeDurationFrames = 20,
    fadeTimer = 0,
    fadeType = "in", -- can be "in" or "out"
    fadeFinished = false
}

-- Menu globals
local bg
local menus = {
    mainMenu = {},
    subfolders = {},
    filePaths = {}
}
local selectedMenu = "mainMenu"
local fileMappings = {}
local menuPositionYPercentage = 0.6   -- 60% vertical
local menuPositionXPercentage = 0.98   -- 98% horizontal
local maxVisibleItems = 5  -- Number of items to display at once
local startIndex = 0       -- Index of the first item in the visible range
local selectedOption = 1
local currentPath = "doomfiles"  -- Start in the main doomfiles folder
local previousPath = ""

-- Font globals
local referenceWidth = 1050
local referenceHeight = 900
local normalColor = {0.5, 0.5, 0.5, 1}  -- Grey for non-selected
local selectedColor = {1, 1, 1, 1}      -- White for selected
local currentColors = {}
local transitionSpeed = 2
local font

-- Load radio selection from file
function readFromFile(filename)
    local fileHandle = io.open(filename, "r")
    if fileHandle then
        local content = fileHandle:read("*all"):match("^%s*(.-)%s*$")
        fileHandle:close()
        return content
    else
        print("Error opening " .. filename .. " for reading")
        return nil
    end
end

-- Radio button globals
local radioButtonBaseSize = 25           -- Base size of the radio button
local radioButtonBaseSpacing = 175       -- Base spacing between the radio buttons
local radioButtonBaseLabelOffset = 20    -- Base space between radio button and label text
local radioButtonYPercentage = 0.90      -- Radio button Y position (range 0.00 - 1.00)
local radioButtonXPercentage = 0.60      -- Radio button X position (range 0.00 - 1.00)
local fontSizeScaleFactor = 1.0          -- Scale factor for font size relative to button size
local radioFile = "launcher/radio.txt"
local radioContent = readFromFile(radioFile)
local selectedRadioOption = (radioContent == "1" and 1) or (radioContent == "2" and 2) or 1

-- Input globals
local inputCooldown = 0.2
local timeSinceLastInput = 0
local escapePressed = false
local gamepadAPressed = false

-- Initialize display
function setupWindow()
    love.window.setTitle("Minilauncher")
    love.window.setFullscreen(true, "desktop")
    love.window.setMode(0, 0)
end

-- Draw order
function love.draw()
    if splash and not splash.done then
        splash:draw()
    else
        drawBackground()
		drawMenu()
        drawRadioButtons()
        fadeScreen(fadeParams.fadeType)
    end
end

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

-- Handle fade effect
function fadeScreen(fadeDirection)
    -- Handle fade effect
    fadeParams.fadeTimer = fadeParams.fadeTimer + 1
    local progress = fadeParams.fadeTimer / fadeParams.fadeDurationFrames

    if fadeDirection == "in" then
        fadeParams.fadeAlpha = 1 - progress
    elseif fadeDirection == "out" then
        fadeParams.fadeAlpha = progress
    end

    if fadeParams.fadeTimer >= fadeParams.fadeDurationFrames then
        fadeParams.fadeAlpha = fadeDirection == "in" and 0 or 1
        fadeParams.fadeFinished = true
    end

    love.graphics.setColor(0, 0, 0, fadeParams.fadeAlpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Check for quit combinations
    if love.keyboard.isDown("z") and love.keyboard.isDown("x") then
        love.event.quit()
    end

    local gamepad = love.joystick.getJoysticks()[1]
    if gamepad and gamepad:isGamepadDown("rightshoulder") and gamepad:isGamepadDown("leftshoulder") then
        love.event.quit()
    end

    love.graphics.setColor(1, 1, 1, 1)  -- Reset color to white
end

-- Draw background
function loadBackground()
    -- Release previously loaded images (if any)
    if bg then
        bg:release()
    end

    -- Load the background image
    bg = love.graphics.newImage("assets/doombg.png")
end

function drawBackground()
    if not bg then
        return
    end

    local windowWidth, windowHeight = love.graphics.getDimensions()

    -- Stretch the background to fit the entire screen
    love.graphics.draw(bg, 0, 0, 0, windowWidth / bg:getWidth(), windowHeight / bg:getHeight())
end

-- Setup regular font based on window size
function setupFonts()
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

-- Init -- splash screen
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

function initializeSplashScreen(width, height)
    -- Configure the splash screen
    local splashConfig = {
        background = {0, 0, 0},  -- Black background
    }

    -- Initialize or update the splash screen
    splash = splashlib(splashConfig, width, height)
end

function love.gamepadpressed(joystick, button)
    -- Handle gamepad input
    if splash and button == "b" then  -- Adjust "a" to the specific button you want to use
        splash:skip()
    end
end

-- Function to convert a string to lowercase
function to_lower(str)
    return str:lower()
end

-- Reset the menu
function resetMenu()
    menus.mainMenu = {}
    menus.subfolders = {}
    menus.filePaths = {}
    selectedMenu = "mainMenu"
    startIndex = 0
    selectedOption = 1
end

-------------------------------------------------------------------------------------------
-- DYNAMIC MENU BUIULDING -----------------------------------------------------------------
-------------------------------------------------------------------------------------------
function readDoomFile(filePath)
    local file = io.open(filePath, "r")

    if not file then
        print("[LOG]: .doom file not found at", filePath)
        return nil
    end

    local iwadPaths = {}
    local modPaths = {}

    for line in file:lines() do
        -- Stop processing if the EOF marker is found
        if line:match("^%s*--%s*end%s*--%s*$") then
            break
        end

        -- Remove leading/trailing whitespace from the line
        line = line:match("^%s*(.-)%s*$")

        -- Parse key-value pairs
        local key, value = line:match("^(%S+)%s*=%s*(.+)$")
        if key and value then
            if key == "IWAD" then
                table.insert(iwadPaths, value)
            elseif key == "MOD" then
                table.insert(modPaths, value)
            end
        else
            print("[LOG]: Skipping malformed line in .doom file:", line)
        end
    end

    file:close()

    return {iwads = iwadPaths, mods = modPaths}
end

-- Function to process all .doom files in the "doom" folder
function loadMenuOptions()
    resetMenu()  -- Reset the menu first
    
    local cwd = love.filesystem.getSourceBaseDirectory()  -- Get current directory path
    local currentDir = cwd .. "/" .. currentPath  -- Full path to the current directory

    -- List subfolders in the current directory only (no deeper subfolders)
    local handle = io.popen("find \"" .. currentDir .. "\" -type d -maxdepth 1 -mindepth 1 2>/dev/null")
    local result = handle:read("*a")
    handle:close()

    -- Add subfolders to the list
    for folderPath in result:gmatch("[^\n]+") do
        local folderName = folderPath:match("([^/]+)$")
        if folderName then
            table.insert(menus.subfolders, folderName)  -- Use menus.subfolders
        end
    end

    -- Sort subfolders alphabetically
    table.sort(menus.subfolders)

    -- Add sorted subfolders to the main menu
    for _, folderName in ipairs(menus.subfolders) do
        table.insert(menus.mainMenu, "[Folder] " .. folderName .. "/")
    end

    -- List .doom files in the current directory only (no subfolder search)
    handle = io.popen("find \"" .. currentDir .. "\" -maxdepth 1 -type f -name '*.doom' 2>/dev/null")
    result = handle:read("*a")
    handle:close()

    -- Store the .doom file paths
    for filePath in result:gmatch("[^\n]+") do
        local fileName = filePath:match("([^/]+)%.doom$")  -- Extract file name without extension
        if fileName then
            -- Read the .doom file and extract IWAD and MOD paths
            local doomFileData = readDoomFile(filePath)
            if doomFileData then
                local allFilesValid = true

                -- Validate the IWAD files
                for _, iwad in ipairs(doomFileData.iwads) do
                    if not validateFiles({iwad}) then
                        allFilesValid = false
                        break
                    end
                end

                -- Validate the MOD files
                for _, mod in ipairs(doomFileData.mods) do
                    if not validateFiles({mod}) then
                        allFilesValid = false
                        break
                    end
                end

                -- Only add the file to the menu if all files are valid
                if allFilesValid then
                    table.insert(menus.filePaths, fileName)  -- Use menus.filePaths
                else
                    print("[LOG]: Skipping invalid .doom file:", fileName)
                end
            end
        end
    end

    -- Sort .doom files alphabetically
    table.sort(menus.filePaths)

    -- Add sorted .doom files to the main menu
    for _, fileName in ipairs(menus.filePaths) do
        table.insert(menus.mainMenu, fileName)  -- Add .doom file to the menu
    end

    -- Add the "Exit" option at the end of the menu
    table.insert(menus.mainMenu, "Exit")
end

-- Function to check if all files in a list exist
function validateFiles(filePaths)
    local cwd = love.filesystem.getSourceBaseDirectory()  -- Get current directory path

    for _, relativePath in ipairs(filePaths) do
        local fullPath = cwd .. "/" .. relativePath  -- Construct the full path
        fullPath = string.lower(fullPath)  -- Convert to lowercase for case-insensitive comparison

        -- Check if the file exists
        local file = io.open(fullPath, "r")
        if not file then
            print("[LOG]: File not found:", fullPath)  -- Log full path for debugging
            return false
        else
            file:close()
        end
    end

    return true
end

-------------------------------------------------------------------------------------------
-- INPUT HANDLING -------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Main input handler (default menu)
function handleInput()
    local gamepad = love.joystick.getJoysticks()[1]
    handleDefaultMenuInput(gamepad)
end

-- Initialize an empty path stack
local pathStack = {}

function handleSubMenu(button)
    if button == "A" then
        -- Check if a subfolder was selected
        local selectedItem = menus.mainMenu[selectedOption]  -- Assume selectedIndex is the current selection
        if selectedItem:match("^%[Folder%]") then
            -- Extract folder name
            local subfolderName = selectedItem:match("%[Folder%] (.+)$")
            if subfolderName then
                table.insert(pathStack, currentPath)  -- Push the current path onto the stack
                currentPath = currentPath .. "/" .. subfolderName  -- Update current path to subfolder
                loadMenuOptions()  -- Reload the menu
                drawMenu()
                timeSinceLastInput = 0
            end
        end
    elseif button == "B" then
        if currentPath ~= "doomfiles" then  -- If not in the root folder
            -- Pop the last path from the stack and update the current path
            currentPath = table.remove(pathStack) or currentPath  -- Ensure pathStack is not empty
            loadMenuOptions()  -- Reload the menu
            drawMenu()
            timeSinceLastInput = 0
        end
    end
end

-- Default menu input handler
function handleDefaultMenuInput(gamepad)
    if love.keyboard.isDown("up") or (gamepad and gamepad:isGamepadDown("dpup")) then
        selectPreviousOption()  -- Move up in the menu
        playUISound("toggle")
    elseif love.keyboard.isDown("down") or (gamepad and gamepad:isGamepadDown("dpdown")) then
        selectNextOption()  -- Move down in the menu
        playUISound("toggle")
    elseif (gamepad and gamepad:isGamepadDown("leftshoulder")) then
        selectedRadioOption = 1  -- "Crispy Doom" selected
        selectRadioOption()
        playUISound("toggle")
    elseif (gamepad and gamepad:isGamepadDown("rightshoulder")) then
        selectedRadioOption = 2  -- "GZ Doom" selected
        selectRadioOption()
        playUISound("toggle")
    elseif love.keyboard.isDown("return") or (gamepad and gamepad:isGamepadDown("a")) then
        -- A button or Enter for selection
        local selectedItem = menus.mainMenu[selectedOption]
        if selectedItem:match("^%[Folder%]") then
            -- If it's a folder, navigate into it
            handleSubMenu("A")
        else
            -- If it's a file, handle selection
            handleSelection()
        end
        playUISound("enter")
    elseif (gamepad and gamepad:isGamepadDown("b")) then
        -- B button to go back to the previous folder
        handleSubMenu("B")
        playUISound("back")
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

--------------------------------------------------------------------------------------
-- DRAW MENU -------------------------------------------------------------------------
--------------------------------------------------------------------------------------
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
    
    -- Draw the header (currentPath)
    local headerStatic = "Path: "
    local headerStaticWidth = font:getWidth(headerStatic)
    local headerStaticX = ((windowWidth - headerStaticWidth) / 2) + (windowWidth * 0.05)

    local truncatedPath = currentPath
    local headerLabelWidth = font:getWidth(truncatedPath)
    local headerLabelX = (windowWidth - headerLabelWidth) - 50

    -- Check if the headerLabelX overlaps headerStaticX
    while headerLabelX < (headerStaticX + headerStaticWidth + (windowWidth * 0.01)) do
        -- Find the first "/" in the path
        local firstSlashIndex = truncatedPath:find("/")
        if not firstSlashIndex then
            -- If no "/" is found, break to prevent infinite loop
            truncatedPath = "..."
            break
        end
    
        -- Truncate the path by removing the first folder and prepend "..."
        truncatedPath = truncatedPath:sub(firstSlashIndex + 1)
    
        -- Calculate the width of the truncated path
        headerLabelWidth = font:getWidth(truncatedPath)
    
        -- Recalculate the headerLabelX position
        headerLabelX = (windowWidth - headerLabelWidth) - 50
    
        -- If the label no longer overlaps, exit the loop
        if headerLabelX >= (headerStaticX + headerStaticWidth) then
            truncatedPath = ".../" .. truncatedPath
            break
        end
    end

    local headerY = (windowHeight * menuPositionYPercentage / 2)
    love.graphics.setFont(font)
    love.graphics.setColor(0.5, 1, 1, 1)
    love.graphics.print(headerStatic, headerStaticX, headerY)
    love.graphics.print(truncatedPath, headerLabelX, headerY)
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the options
    for i = 0, math.min(maxVisibleItems - 1, #menus[selectedMenu] - 1) do
        local index = (selectedOption + i - 1) % #menus[selectedMenu] + 1  -- Wrap around the menu options

        local option = menus[selectedMenu][index]  -- Get the current option
        love.graphics.setFont(font)  -- Use the regular font

        -- Check if the font is valid and if the option is a string
        if font and type(option) == "string" then
            -- Set color for selected option
            if index == selectedOption then
                love.graphics.setColor(1, 1, 1, 1)  -- White for selected option
            else
                -- If the option is a folder, use a dull yellow when not selected
                if option:match("^%[Folder%]") then
                    love.graphics.setColor(0.8, 0.8, 0, 1)  -- Dull yellow color
                else
                    love.graphics.setColor(currentColors[index] or {1, 1, 1, 1})  -- Set default color for other options
                end
            end

            local textWidth = font:getWidth(option)
            love.graphics.print(option, optionX - textWidth, optionY + i * optionSpacing)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)  -- Reset color to white
end

-- Draw the radio buttons
function drawRadioButtons()
    love.graphics.setColor(1, 1, 1, 1)
    local windowWidth, windowHeight = love.graphics.getDimensions()

    -- Calculate scale factor based on current window size
    local scaleFactor = math.min(windowWidth / referenceWidth, windowHeight / referenceHeight)

    -- Adjust button sizes and spacing using scale factor
    local radioButtonSize = radioButtonBaseSize * scaleFactor
    local radioButtonSpacing = radioButtonBaseSpacing * scaleFactor
    local radioButtonLabelOffset = radioButtonBaseLabelOffset * scaleFactor

    -- Set font size dynamically
    local fontSize = radioButtonSize * 0.8  -- Font size relative to button size
    love.graphics.setFont(love.graphics.newFont(fontSize))  -- Create and set font with scaled size

    -- Calculate the base X position for the first radio button
    local radioX = windowWidth * radioButtonXPercentage
    local radioY = windowHeight * radioButtonYPercentage

    -- Draw each radio button and its label
    for i, label in ipairs({"Crispy Doom", "GZ Doom"}) do
        local buttonX = radioX + (i - 1) * (radioButtonSize + radioButtonSpacing)

        -- Draw outer circle
        love.graphics.circle("line", buttonX, radioY, radioButtonSize / 2)

        -- Draw filled inner circle if selected
        if selectedRadioOption == i then
            love.graphics.circle("fill", buttonX, radioY, radioButtonSize / 4)
        end

        -- Draw the label next to the radio button
        love.graphics.print(label, buttonX + radioButtonLabelOffset, radioY - fontSize / 2)
    end

    -- Draw the instruction text below the buttons
    local helpText = "Use L/R to select an engine"
    local helpTextWidth = love.graphics.getFont():getWidth(helpText)
    local buttonsWidth = #({"Crispy Doom", "GZ Doom"}) * (radioButtonSize + radioButtonSpacing) - radioButtonSpacing
    local buttonsCenterX = radioX + buttonsWidth / 2
    local helpTextX = buttonsCenterX - helpTextWidth / 2 + (windowWidth * 0.03)
    love.graphics.print(helpText, helpTextX, radioY + fontSize)
end

-----------------------------------------------------------------------------------
-- HANDLE SELECTION ---------------------------------------------------------------
-----------------------------------------------------------------------------------
function handleSelection()
    -- Define mappings and file paths
    local selectedGame = menus[selectedMenu][selectedOption]
    local radioOptions = { "crispydoom", "gzdoom" }
    local selectedGameFile = "selected_game.txt"
    local radioFile = "launcher/radio.txt"

    -- Get the engine name or handle invalid selection
    local gameEngineName = radioOptions[selectedRadioOption]
    if not gameEngineName then
        print("Error: Invalid selectedRadioOption.")
        return
    end

    -- Define the full path for the selected game
    local fullGamePath
    if selectedGame == "Exit" then
        fullGamePath = selectedGame
    else
        fullGamePath = currentPath .. "/" .. selectedGame .. ".doom"
    end

    -- Function to write content to a file
    local function writeToFile(filename, content)
        local file = io.open(filename, "w")
        if file then
            file:write(content)
            file:close()
        else
            print("Error: Cannot write to " .. filename)
        end
    end

    -- Write files
    writeToFile(selectedGameFile, fullGamePath .. "\n" .. gameEngineName .. "\n")
    writeToFile(radioFile, tostring(selectedRadioOption) .. "\n")

    -- Fade out the background music and initiate fade-out effect
    fadeOutBackgroundMusic()
    fadeParams.fadeTimer = 0
    fadeParams.fadeType = "out"
    fadeParams.fadeFinished = false

    -- Update function to handle quitting after fade-out
    function love.update(dt)
        if fadeParams.fadeFinished then
            love.event.quit()
        end
    end
end

-------------------------------------------------------------------------------------------
-- UPDATE LOGIC ---------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Main update function
function love.update(dt)
	timeSinceLastInput = timeSinceLastInput + dt

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
end