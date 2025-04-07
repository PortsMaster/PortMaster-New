local folders = {}
local selectedFolder = nil
local baseDir = "../"
local targetDir = "logs"
local filesToCopy = {"log.txt", "patchlog.txt", "patchlog_error.txt"}
local itemsPerPage = 10
local currentPage = 1
local totalPages = 1
local selectedIndex = 1
local serverUrl = "https://0x0.st/"  
local uploadLogPath = "uploadlog.txt"
local lastUploadLog = ""
local processComplete = true -- Flag to indicate if the copy and zip process is complete
local push = require "push"
local splashlib = require("splash")  -- Assuming "splash.lua" is the correct module name
local splash2lib = require("splash2")  -- Second splash screen
local splash -- Declare the splash screen variable globally
local secondSplash -- Declare the second splash screen variable globally
local gameWidth, gameHeight = 640, 480 -- Fixed game resolution
local windowWidth, windowHeight = love.window.getDesktopDimensions()
push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false})

local wifiStatus = false

local fadeParams = {
    fadeAlpha = 1,
    fadeDurationFrames = 20,
    fadeTimer = 0,
    fadeType = "in", -- can be "in" or "out"
    fadeFinished = false
}
-- Second splash screen configuration
local secondSplashConfig = { 
    text = [[
Welcome to LOG Uploader!
        
How to use it?
- Select the game you have problems with ( you can select multiple ones )
- Now post the Link you will see at the Bottom on the Portmaster Discord
    ( Either a Picture or you can just type it out )
		

Controls:
- Use Left/Right arrow keys to change pages.
- Use Up/Down arrow keys to navigate through folders.
- Press (A) to select a folder and start the copy and zip process.
- Press Start and Select to quit the tool
    ]],
    duration = 10
}

--------------------------------
--BACKGROUND------------------------------
------------------------------------------

function loadBackground()
    -- Release previously loaded images (if any)
    if background then
        background:release()
        background = nil
    end
      
    -- Load images with nearest-neighbor filtering
    love.graphics.setDefaultFilter("nearest", "nearest")

    background = love.graphics.newImage("assets/background2.png")
    background:setFilter("nearest", "nearest")

    -- Restore default filter settings
    love.graphics.setDefaultFilter("linear", "linear")
end

function drawBackground()
    local windowWidth, windowHeight = love.graphics.getDimensions()

    -- Set the default filter to nearest for sharp pixel scaling
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Draw the background layer
    if background then
        local backgroundScale = windowHeight / background:getHeight()
        local backgroundWidth = background:getWidth() * backgroundScale
        local backgroundOffsetX = math.floor((windowWidth - backgroundWidth) / 2)
        love.graphics.draw(background, math.floor(backgroundOffsetX), 0, 0, backgroundScale, backgroundScale)
    end
end

function initializeSplashScreen(width, height)
    -- Configure the splash screen
    local splashConfig = {
        background = {0, 0, 0},  -- Black background
    }

    -- Initialize or update the splash screen
    splash = splashlib(splashConfig, width, height)
end

function initializeSecondSplashScreen(width, height)
    -- Configure the second splash screen
    secondSplash = splash2lib.new(secondSplashConfig, width, height)
end

function love.keypressed(key)
    -- Handle keyboard input
    if splash and key == "space" then
        splash:skip()
    elseif secondSplash and key == "space" then
        secondSplash:skip()
    elseif key == "x" then
        showText = not showText -- Toggle the showText flag when "X" is pressed
    end
end

function love.gamepadpressed(joystick, button)
    -- Handle gamepad input
    if splash and button == "b" then  -- Adjust "a" to the specific button you want to use
        splash:skip()
    elseif secondSplash and button == "b" then
        secondSplash:skip()
    end
end

function love.load()
    checkWiFiStatus()
    music = love.audio.newSource("assets/music.mp3", "stream") -- "stream" because ram lol
    music:setLooping(true) 
    music:play() 

    -- Initialize the splash screen with current window dimensions
    local width, height = love.graphics.getDimensions()
    initializeSplashScreen(width, height)

    -- Initialize fade parameters for fade-in effect
    fadeParams.fadeAlpha = 1
    fadeParams.fadeDurationFrames = 20
    fadeParams.fadeTimer = 0
    fadeParams.fadeType = "in"  -- Set initial fade type
    fadeParams.fadeFinished = false

    -- Set font size based on screen height
    local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    local fontsize =  (screenHeight / 20 )
    local font = love.graphics.newFont(fontsize)
    love.graphics.setFont(font)
    
    loadBackground()

    -- Debug: Print the base directory
    print("Base Directory: " .. baseDir)

    -- List all folders in the base directory using ls and filter directories
    local dirCommand = 'ls -d "' .. baseDir .. '"/*/'
    local p = io.popen(dirCommand)
    for folder in p:lines() do
        -- Remove trailing slash and base path
        folder = folder:match(".*/(.*)/")
        print(folder)
        table.insert(folders, folder)
    end
    p:close()

    -- Create the target directory if it doesn't exist
    local targetDirPath = love.filesystem.getSourceBaseDirectory() .. "/" .. targetDir
    if not love.filesystem.getInfo(targetDirPath) then
        love.filesystem.createDirectory(targetDir)
        print("Created target directory: " .. targetDir)
    else
        print("Target directory already exists: " .. targetDir)
    end

    -- Calculate total pages
    totalPages = math.ceil(#folders / itemsPerPage)

    -- Debug: Print all found directories
    print("Folders found:")
    for _, folder in ipairs(folders) do
        print(folder)
    end

    -- Check if internet.txt exists
   if wifiStatus then
        -- Read the last upload log
        readLastUploadLog()
    else
        lastUploadLog = "Get the logs.zip at roms/ports/loguploader"
    end
end

function love.draw()
    -- Draw the splash screen if it exists and is not done
    if splash and not splash.done then
        splash:draw()
    elseif secondSplash and not secondSplash.done then
        secondSplash:draw()
    else
        drawBackground()
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()
        local lineHeight = love.graphics.getFont():getHeight()
        local y = 10

        local function printCentered(text, y)
            local textWidth = love.graphics.getFont():getWidth(text)
            love.graphics.print(text, (screenWidth - textWidth) / 2, y)
        end

        printCentered("Select a folder to copy log files (Page " .. currentPage .. " of " .. totalPages .. "):", y)
        y = y + lineHeight + 10

        local startIndex = (currentPage - 1) * itemsPerPage + 1
        local endIndex = math.min(startIndex + itemsPerPage - 1, #folders)
        for i = startIndex, endIndex do
            local displayIndex = i - startIndex + 1
            local folderText = (displayIndex == selectedIndex and "> " or "") .. folders[i]
            printCentered(folderText, y)
            y = y + lineHeight + 10
        end

        if selectedFolder then
            printCentered("Selected folder: " .. selectedFolder, y)
            y = y + lineHeight + 10
        end

        printCentered("Press Left/Right to change page, Up/Down to navigate, (A) to select", y)
        y = y + lineHeight + 10

        if lastUploadLog ~= "" then
            printCentered(lastUploadLog, y)
            y = y + lineHeight + 10
        end

        if showText then
            printCentered("This is the toggled text displayed when 'X' is pressed.", y)
        end
    end

    -- Determine which fade effect to apply
    if fadeParams.fadeType == "in" then
        fadeScreenIn(fadeParams)
    elseif fadeParams.fadeType == "out" then
        fadeScreenOut(fadeParams)
    end
end

function love.keypressed(key)
    if splash then
        -- Handle splash screen key press
    elseif secondSplash then
        -- Handle second splash screen key press
    elseif key == "right" and currentPage < totalPages then
        currentPage = currentPage + 1
        selectedIndex = 1
    elseif key == "left" and currentPage > 1 then
        currentPage = currentPage - 1
        selectedIndex = 1
    elseif key == "down" and selectedIndex < math.min(itemsPerPage, #folders - (currentPage - 1) * itemsPerPage) then
        selectedIndex = selectedIndex + 1
    elseif key == "up" and selectedIndex > 1 then
        selectedIndex = selectedIndex - 1
    elseif key == "return" then
        if processComplete then -- Check if the process is complete
            local folderIndex = (currentPage - 1) * itemsPerPage + selectedIndex
            if folders[folderIndex] then
                selectedFolder = folders[folderIndex]
                -- Print selected folder
                print("Selected folder: " .. selectedFolder)
                processComplete = false -- Set the flag to false before starting the process
                copyAndZipLogs(selectedFolder)
            end
        end
    end
end

function copyAndZipLogs(folder)
    local path = baseDir .. "/" .. folder
    local targetDirPath = love.filesystem.getSourceBaseDirectory() .. "/" .. targetDir

    -- Copy files to target directory
    for _, fileName in ipairs(filesToCopy) do
        local sourceFilePath = '"' .. path .. '/' .. fileName .. '"'
        local targetFilePath = '"' .. targetDirPath .. '/' .. folder .. '_' .. fileName .. '"'
        local treeCommand = 'tree "' .. path .. '" && find "' .. path .. '" -type f -exec md5sum {} + > "' .. targetDirPath .. '/' .. folder .. '_tree_md5.txt"'
        local treeResult = os.execute(treeCommand)

        -- Use os.execute to copy the file
        local copyCommand = 'cp ' .. sourceFilePath .. ' ' .. targetFilePath
        print("Running command: " .. copyCommand)
        local result = os.execute(copyCommand)
        text = result
        -- Debug: Print info about the copy operation
        if result == 0 then
            print("Copied " .. fileName .. " to " .. targetDir .. " directory.")
        else
            print("Failed to copy " .. fileName .. " to " .. targetDir .. " directory.")
        end
    end

    -- Zip the entire logs directory
    local zipFilePath = targetDirPath .. ".zip"
    local zipCommand = '7za a "' .. zipFilePath .. '" "' .. targetDirPath .. '/*"'
    print("Running command: " .. zipCommand)
    local result = os.execute(zipCommand)
    processComplete = true 

    -- Debug: Print info about the zip operation ( i will leave that here so i know if 7zs is borked )
    if result == 0 then
        print("Zipped logs to " .. zipFilePath)
        uploadLogs(zipFilePath)
    else
        print("Failed to zip logs to " .. zipFilePath)
    end
end

function uploadLogs(zipFilePath)
    -- Use curl to upload the file and log the output
    local uploadCommand = 'curl -F "file=@' .. zipFilePath .. '" ' .. serverUrl .. ' -o ' .. uploadLogPath .. ' -Fexpires=2 2>&1'
    print("Running command: " .. uploadCommand)
    local result = os.execute(uploadCommand)

    -- Read the last line of the upload log
    if result == 0 then
        readLastUploadLog()
    else
        lastUploadLog = "Upload failed"
    end
end

function readLastUploadLog()
    local file = io.open(uploadLogPath, "r")
    if file then
        local lines = {}
        for line in file:lines() do
            table.insert(lines, line)
        end
        file:close()
        if #lines > 0 then
            lastUploadLog = lines[#lines]
        else
            lastUploadLog = "Upload log is empty"
        end
    elseif not wifiStatus then
        lastUploadLog = "You aren't connected to the Internet, grab the logs.zip at " .. baseDir
	else
        lastUploadLog = "No upload log found"
    end


end

function love.update(dt)
    -- Update the splash screen if it's not done
    if splash and not splash.done then
        splash:update(dt)
        return
    end

    -- Transition from the first splash screen to the second
    if splash and splash.done and not splash.skipped then
        splash = nil
        initializeSecondSplashScreen(love.graphics.getWidth(), love.graphics.getHeight())
        return
    end

    -- Update the second splash screen if it's not done
    if secondSplash and not secondSplash.done then
        secondSplash:update(dt)
        return
    end

    -- Transition from the second splash screen to the main content
    if secondSplash and secondSplash.done and not secondSplash.skipped then
        secondSplash = nil
        fadeParams.fadeTimer = 0  -- Reset fade timer when splash is done
        fadeParams.fadeFinished = false
        fadeParams.fadeType = "in"  -- Set fade type to "in" for fade-in effect
    end
end

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

function checkWiFiStatus()
    local file = io.open("internet.txt", "r")
    if file then
        wifiStatus = true
        file:close()
    else
        wifiStatus = false
    end
end