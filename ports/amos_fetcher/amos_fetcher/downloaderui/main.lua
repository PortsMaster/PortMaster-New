-- Interactive File Downloader with Fast Loading
local push = require('push')
local timer = require('timer')
local osk = require('osk')

local gameWidth, gameHeight = 640, 480
local windowWidth, windowHeight = 640, 480

-- Load platforms dynamically from fetcher.py
local platforms = {}

function loadPlatforms()
    -- Execute platform fetcher
    local command = "cd /storage/roms/ports/amos_fetcher && python3 get_platforms.py > /tmp/platforms.json 2>&1"
    os.execute(command)
    
    -- Read the result
    local file = io.open("/tmp/platforms.json", "r")
    if file then
        local content = file:read("*all")
        file:close()
        
        if content and content ~= "" then
            -- Simple JSON parsing for platforms
            platforms = {}
            local inPlatforms = false
            
            for line in content:gmatch("[^\n]+") do
                if line:match('"platforms"') then
                    inPlatforms = true
                elseif inPlatforms and line:match('"name":') then
                    local name = line:match('"name": "([^"]+)"')
                    if name then
                        -- Look for folder on next few lines
                        local remainingContent = content:sub(content:find(line, 1, true) + #line)
                        local folder = remainingContent:match('"folder":%s*"([^"]+)"')
                        if folder then
                            table.insert(platforms, {
                                name = name,
                                folder = folder
                            })
                        end
                    end
                elseif line:match('^%s*]%s*$') then
                    -- End of platforms array
                    break
                end
            end
            
            if #platforms > 0 then
                return true
            end
        end
    end
    
    -- Fallback to hardcoded list if loading fails
    platforms = {
        {name = "pico-8", folder = "pico-8"},
        {name = "Game Boy", folder = "gb"},
        {name = "Game Boy Color", folder = "gbc"},
        {name = "Game Boy Advance", folder = "gba"},
        {name = "NES", folder = "nes"},
        {name = "Famicom Disk System", folder = "fds"},
        {name = "SNES", folder = "snes"},
        {name = "Game Gear", folder = "gamegear"},
        {name = "Master System", folder = "mastersystem"},
        {name = "Genesis", folder = "genesis"},
        {name = "Saturn", folder = "saturn"},
        {name = "Dreamcast", folder = "dreamcast"},
        {name = "PlayStation 1", folder = "psx"},
        {name = "PSP", folder = "psp"},
        {name = "Nintendo DS", folder = "nds"},
        {name = "Nintendo 64", folder = "n64"},
        {name = "PC Engine", folder = "pcengine"}
    }
    return false
end

local gameState = {
    screen = "platforms",
    selectedPlatform = 1,
    selectedFile = 1,
    scrollOffset = 0,
    fileScrollOffset = 0,
    maxVisible = 10,
    maxFilesVisible = 10,
    downloadStatus = "",
    fileList = {},
    fileListLoaded = false,
    fileListLoading = false,
    searchQuery = "",
    filteredFileList = {},
    isSearching = false,
    -- Bulk download state
    bulkDownloadActive = false,
    bulkDownloadList = {},
    bulkDownloadIndex = 0,
    bulkDownloadTotal = 0,
    bulkDownloadSuccess = 0,
    bulkDownloadFailed = 0
}

-- Button hold state for continuous scrolling
local buttonHold = {
    r1 = false,
    l1 = false,
    dpup = false,
    dpdown = false,
    timer = 0,
    repeatDelay = 0.3,  -- Initial delay before repeat starts
    repeatRate = 0.1    -- Time between repeats
}

function love.load()
    push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {
        fullscreen = true,
        resizable = false,
        pixelperfect = false
    })
    
    -- Load platforms dynamically from fetcher.py
    loadPlatforms()
    
    -- Initialize OSK
    osk.load()

    -- Load pixely font at different sizes
    local fontPath = "assets/fonts/pixely.ttf"
    titleFont = love.graphics.newFont(fontPath, 32)
    headerFont = love.graphics.newFont(fontPath, 18)
    bodyFont = love.graphics.newFont(fontPath, 20)
    smallFont = love.graphics.newFont(fontPath, 14)

    -- Create global fonts table for draw.lua and splash.lua
    fonts = {
        regular = love.graphics.newFont(fontPath, 16),
        small = love.graphics.newFont(fontPath, 12)
    }

    -- Create global fontColors table for draw.lua
    fontColors = {
        regular = {0.60, 0.60, 0.60} -- Medium gray text
    }
    -- Color palette 
    bgColor = {0.776, 0.878, 0.020} -- Light green background
    footerColor = {0.616, 0.741, 0.145} -- Darker green for footer
    titleColor = {0.129, 0.259, 0.192} -- Dark green for titles
    textColor = {0.129, 0.259, 0.192} -- Dark green for text
    selectedColor = {0.129, 0.259, 0.192} -- Keep same for selections
    progressBgColor = {0.25, 0.25, 0.25} -- Keep same for progress bar
    selectionBgColor = {0.616, 0.741, 0.145} -- Light green background for selection
    selectionTextColor = {0.129, 0.259, 0.192} -- Dark green text for selected
end

function love.update(dt)
    timer.update(dt)
    osk.update(dt)

    -- Handle continuous scrolling when holding shoulder buttons (File list)
    if (buttonHold.r1 or buttonHold.l1) and gameState.screen == "filelist" and gameState.fileListLoaded then
        buttonHold.timer = buttonHold.timer + dt
        if buttonHold.timer >= buttonHold.repeatRate then
            buttonHold.timer = 0
            local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList
            if buttonHold.r1 then
                gameState.selectedFile = math.min(#currentList, gameState.selectedFile + 10)
                updateFileScroll()
            elseif buttonHold.l1 then
                gameState.selectedFile = math.max(1, gameState.selectedFile - 10)
                updateFileScroll()
            end
        end
    end
    
    -- Handle continuous scrolling when holding dpad (platform list)
    if (buttonHold.dpup or buttonHold.dpdown) and gameState.screen == "platforms" then
        buttonHold.timer = buttonHold.timer + dt
        if buttonHold.timer >= buttonHold.repeatRate then
            buttonHold.timer = 0
            if buttonHold.dpdown then
                gameState.selectedPlatform = math.min(#platforms, gameState.selectedPlatform + 1)
                updateScroll()
            elseif buttonHold.dpup then
                gameState.selectedPlatform = math.max(1, gameState.selectedPlatform - 1)
                updateScroll()
            end
        end
    end
    
    -- Handle continuous scrolling when holding dpad (File list)
    if (buttonHold.dpup or buttonHold.dpdown) and gameState.screen == "filelist" and gameState.fileListLoaded then
        buttonHold.timer = buttonHold.timer + dt
        if buttonHold.timer >= buttonHold.repeatRate then
            buttonHold.timer = 0
            local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList
            if buttonHold.dpdown then
                gameState.selectedFile = math.min(#currentList, gameState.selectedFile + 1)
                updateFileScroll()
            elseif buttonHold.dpup then
                gameState.selectedFile = math.max(1, gameState.selectedFile - 1)
                updateFileScroll()
            end
        end
    end
end

function love.draw()
    push:start()
    
    love.graphics.setColor(bgColor)
    love.graphics.rectangle('fill', 0, 0, gameWidth, gameHeight)
    
    if gameState.screen == "main" then
        drawMainScreen()
    elseif gameState.screen == "platforms" then
        drawPlatformScreen()
    elseif gameState.screen == "filelist" then
        drawFileListScreen()
    elseif gameState.screen == "downloading" then
        drawDownloadScreen()
    elseif gameState.screen == "bulkdownload" then
        drawBulkDownloadScreen()
    end
    
    -- Draw OSK overlay if visible
    osk.draw()
    
    push:finish()
end

function drawMainScreen()
    love.graphics.setColor(titleColor)
    love.graphics.setFont(titleFont)
    love.graphics.printf("SELECT PLATFORM", 30, 15, gameWidth, 'left')

    local startY = 45
    local itemHeight = 30

    for i = 1, math.min(gameState.maxVisible, #platforms) do
        local platformIndex = i + gameState.scrollOffset
        if platformIndex <= #platforms then
            local platform = platforms[platformIndex]
            local yPos = startY + (i - 1) * itemHeight

            -- Draw selection background rectangle
            if platformIndex == gameState.selectedPlatform then
                love.graphics.setColor(selectionBgColor)
                love.graphics.rectangle('fill', 20, yPos - 2, gameWidth - 40, itemHeight + 2)
                love.graphics.setColor(selectionTextColor)
            else
                love.graphics.setColor(textColor)
            end

            love.graphics.setFont(titleFont)
            love.graphics.printf(platformIndex .. ". " .. platform.name, 30, yPos, gameWidth, 'left')
        end
    end

    if gameState.scrollOffset > 0 then
        love.graphics.setColor(textColor)
        love.graphics.printf("▲", 30, 30, gameWidth, 'left')
    end

    if gameState.scrollOffset + gameState.maxVisible < #platforms then
        love.graphics.setColor(textColor)
        love.graphics.printf("▼", 30, 240, gameWidth, 'left')
    end

    -- Footer background
    love.graphics.setColor(footerColor)
    love.graphics.rectangle('fill', 0, 390, gameWidth, 90)

    love.graphics.setColor(textColor)
    love.graphics.setFont(titleFont)
    love.graphics.printf("Up/Down: Navigate | A: View Files | Start: Exit", 30, 400, gameWidth, 'left')

    local selectedPlatform = platforms[gameState.selectedPlatform]
    love.graphics.setColor(textColor)
    love.graphics.setFont(titleFont)
    love.graphics.printf("Selected: " .. selectedPlatform.name, 30, 435, gameWidth, 'left')
end

function drawPlatformScreen()
    love.graphics.setColor(titleColor)
    love.graphics.setFont(titleFont)
    love.graphics.printf("SELECT PLATFORM", 30, 25, gameWidth, 'left')

    local startY = 65
    local itemHeight = 30
    
    for i = 1, math.min(gameState.maxVisible, #platforms) do
        local platformIndex = i + gameState.scrollOffset
        if platformIndex <= #platforms then
            local platform = platforms[platformIndex]
            local yPos = startY + (i - 1) * itemHeight
            
            -- Draw selection background rectangle
            if platformIndex == gameState.selectedPlatform then
                love.graphics.setColor(selectionBgColor)
                love.graphics.rectangle('fill', 20, yPos - 2, gameWidth - 40, itemHeight + 2)
                love.graphics.setColor(selectionTextColor)
            else
                love.graphics.setColor(textColor)
            end
            
            love.graphics.setFont(titleFont)
            love.graphics.printf(platformIndex .. ". " .. platform.name, 30, yPos, gameWidth, 'left')
        end
    end
    
    -- Footer background
    love.graphics.setColor(footerColor)
    love.graphics.rectangle('fill', 0, 390, gameWidth, 90)
    
    love.graphics.setColor(textColor)
    love.graphics.setFont(titleFont)
    love.graphics.printf("Up/Down: Navigate | A: View Files | Start: Exit", 30, 400, gameWidth, 'left')
    
    local selectedPlatform = platforms[gameState.selectedPlatform]
    love.graphics.setColor(textColor)
    love.graphics.setFont(titleFont)
    love.graphics.printf("Selected: " .. selectedPlatform.name, 30, 435, gameWidth, 'left')
end

function drawFileListScreen()
    local platform = platforms[gameState.selectedPlatform]
    
    -- Combined platform name and File count will be displayed later after File list is loaded
    
    if gameState.fileListLoading then
        
        -- Loading animation
        local dots = string.rep(".", math.floor(love.timer.getTime() * 2) % 4)
        love.graphics.setColor(titleColor)
        love.graphics.printf("Loading" .. dots, 0, gameHeight / 2 - 12, gameWidth, 'center')
        return
    end
    
    if not gameState.fileListLoaded or #gameState.fileList == 0 then
        love.graphics.setColor(textColor)
        love.graphics.setFont(titleFont)
        love.graphics.printf("Press A to fetch file names", 0, 100, gameWidth, 'center')
        -- Footer background
        love.graphics.setColor(footerColor)
        love.graphics.rectangle('fill', 0, 390, gameWidth, 90)
        
        love.graphics.setColor(textColor)
        love.graphics.setFont(smallFont)
        love.graphics.printf("A: Fetch Files | B: Back to platforms", 0, 400, gameWidth, 'center')
        return
    end
    
    -- Show combined platform name and File count
    love.graphics.setColor(titleColor)
    love.graphics.setFont(titleFont)
    local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList
    local combinedTitle = gameState.isSearching and 
        string.format("%s - Found %d/%d Files", platform.name, #gameState.filteredFileList, #gameState.fileList) or
        string.format("%s - Found %d Files", platform.name, #gameState.fileList)
    love.graphics.printf(combinedTitle, 30, 25, gameWidth, 'left')
    
    -- Show search query if searching
    if gameState.isSearching and gameState.searchQuery ~= "" then
        love.graphics.setColor(textColor)
        love.graphics.setFont(titleFont)
        love.graphics.printf("Search: \"" .. gameState.searchQuery .. "\"", 30, 25, gameWidth - 60, 'right')
    end
    
    -- File list
    local startY = gameState.isSearching and gameState.searchQuery ~= "" and 85 or 65
    local itemHeight = 30
    local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList

    for i = 1, math.min(gameState.maxFilesVisible, #currentList) do
        local fileIndex = i + gameState.fileScrollOffset
        if fileIndex <= #currentList then
            local file = currentList[fileIndex]
            local yPos = startY + (i - 1) * itemHeight

            -- Draw selection background rectangle
            if fileIndex == gameState.selectedFile then
                love.graphics.setColor(selectionBgColor)
                love.graphics.rectangle('fill', 20, yPos - 2, gameWidth - 40, itemHeight + 2)
                love.graphics.setColor(selectionTextColor)
            else
                love.graphics.setColor(textColor)
            end

            love.graphics.setFont(titleFont)
            -- Truncate long File names
            local displayName = file.name
            if string.len(displayName) > 50 then
                displayName = string.sub(displayName, 1, 47) .. "..."
            end
            love.graphics.printf(fileIndex .. ". " .. displayName, 30, yPos, gameWidth, 'left')
        end
    end
    

    -- Footer background
    love.graphics.setColor(footerColor)
    love.graphics.rectangle('fill', 0, 390, gameWidth, 90)

    -- Controls
    love.graphics.setColor(textColor)
    love.graphics.setFont(titleFont)
    local controlsText
    if gameState.bulkDownloadActive then
        controlsText = "Bulk downloading... Please wait"
    elseif gameState.isSearching and #gameState.filteredFileList > 1 then
        controlsText = "A: Download | L1: Bulk Download All | X: Search | Y: Clear | B: Back"
    elseif gameState.isSearching then
        controlsText = "A: Download | X: Search | Y: Clear | B: Back"
    else
        controlsText = "L1/R1: Scroll 10 items | A: Download | X: Search | B: Back"
    end
    love.graphics.printf(controlsText, 30, 400, gameWidth, 'left')

    -- Selected File info
    local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList
    if gameState.selectedFile <= #currentList then
        local selectedFile = currentList[gameState.selectedFile]
        love.graphics.setColor(textColor)
        love.graphics.setFont(titleFont)
        local fileName = selectedFile.name
        if string.len(fileName) > 50 then
            fileName = string.sub(fileName, 1, 47) .. "..."
        end
        love.graphics.printf("Selected: " .. fileName, 30, 435, gameWidth, 'left')
    end
end

function drawDownloadScreen()
    love.graphics.setColor(textColor)
    love.graphics.setFont(titleFont)
    love.graphics.printf("DOWNLOADING File", 0, 50, gameWidth, 'center')
    
    local platform = platforms[gameState.selectedPlatform]
    love.graphics.setColor(textColor)
    love.graphics.setFont(headerFont)
    love.graphics.printf("Platform: " .. platform.name, 0, 100, gameWidth, 'center')
    
    local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList
    if gameState.selectedFile <= #currentList then
        local file = currentList[gameState.selectedFile]
        love.graphics.setColor(textColor)
        love.graphics.setFont(titleFont)
        local fileName = file.name
        if string.len(fileName) > 40 then
            fileName = string.sub(fileName, 1, 37) .. "..."
        end
        love.graphics.printf("File: " .. fileName, 0, 130, gameWidth, 'center')
    end
    
    love.graphics.setColor(textColor)
    love.graphics.setFont(titleFont)
    love.graphics.printf(gameState.downloadStatus, 0, 180, gameWidth, 'center')
    
end

function drawBulkDownloadScreen()
    love.graphics.setColor(titleColor)
    love.graphics.setFont(titleFont)
    love.graphics.printf("BULK DOWNLOADING FileS", 0, 30, gameWidth, 'center')
    
    local platform = platforms[gameState.selectedPlatform]
    love.graphics.setColor(titleColor)
    love.graphics.setFont(headerFont)
    love.graphics.printf("Platform: " .. platform.name, 0, 70, gameWidth, 'center')
    
    -- Progress info
    love.graphics.setColor(titleColor)
    love.graphics.setFont(titleFont)
    local progressText = string.format("Progress: %d / %d Files", gameState.bulkDownloadIndex, gameState.bulkDownloadTotal)
    love.graphics.printf(progressText, 0, 110, gameWidth, 'center')
    
    -- Success/Failed counts
    love.graphics.setColor(textColor)
    love.graphics.setFont(titleFont)
    local successText = string.format("Success: %d  Failed: %d", gameState.bulkDownloadSuccess, gameState.bulkDownloadFailed)
    love.graphics.printf(successText, 0, 140, gameWidth, 'center')
    
    -- Progress bar
    local barWidth = 400
    local barHeight = 20
    local barX = (gameWidth - barWidth) / 2
    local barY = 170
    
    -- Background bar
    love.graphics.setColor(footerColor)
    love.graphics.rectangle('fill', barX, barY, barWidth, barHeight)
    
    -- Progress bar
    if gameState.bulkDownloadTotal > 0 then
        local progress = gameState.bulkDownloadIndex / gameState.bulkDownloadTotal
        love.graphics.setColor(selectionBgColor) -- Use dark green for progress bar
        love.graphics.rectangle('fill', barX, barY, barWidth * progress, barHeight)
    end
    
    -- Current File being downloaded
    if gameState.bulkDownloadIndex > 0 and gameState.bulkDownloadIndex <= #gameState.bulkDownloadList then
        local currentRom = gameState.bulkDownloadList[gameState.bulkDownloadIndex]
        if currentRom then
            love.graphics.setColor(textColor)
            love.graphics.setFont(titleFont)
            local fileName = currentRom.name
            if string.len(fileName) > 50 then
                fileName = string.sub(fileName, 1, 47) .. "..."
            end
            love.graphics.printf("Current: " .. fileName, 0, 210, gameWidth, 'center')
        end
    end
    
    -- Status
    love.graphics.setColor(titleColor)
    love.graphics.setFont(titleFont)
    love.graphics.printf(gameState.downloadStatus, 0, 250, gameWidth, 'center')
    
    -- Footer background
    love.graphics.setColor(footerColor)
    love.graphics.rectangle('fill', 0, 390, gameWidth, 90)
    
    -- Controls
    love.graphics.setColor(titleColor)
    love.graphics.setFont(titleFont)
    if gameState.bulkDownloadActive then
        love.graphics.printf("Downloading... Press B to cancel", 0, 410, gameWidth, 'center')
    else
        love.graphics.printf("Press B to return to File list", 0, 410, gameWidth, 'center')
    end
end

function love.keypressed(key)
    if gameState.screen == "main" then
        if key == "return" or key == "space" then
            gameState.screen = "platforms"
        elseif key == "escape" then
            love.event.quit()
        end
    elseif gameState.screen == "platforms" then
        if key == "up" then
            gameState.selectedPlatform = math.max(1, gameState.selectedPlatform - 1)
            updateScroll()
        elseif key == "down" then
            gameState.selectedPlatform = math.min(#platforms, gameState.selectedPlatform + 1)
            updateScroll()
        elseif key == "return" or key == "space" then
            enterRomList()
        elseif key == "escape" then
            love.event.quit()
        end
    elseif gameState.screen == "filelist" then
        if not gameState.fileListLoaded then
            if key == "return" or key == "space" then
                fetchRomList()
            elseif key == "backspace" then
                gameState.screen = "platforms"
            end
        else
            -- Don't handle input if OSK is visible
            if osk.isVisible() then
                return
            end
            
            local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList
            
            if key == "up" then
                gameState.selectedFile = math.max(1, gameState.selectedFile - 1)
                updateFileScroll()
            elseif key == "down" then
                gameState.selectedFile = math.min(#currentList, gameState.selectedFile + 1)
                updateFileScroll()
            elseif key == "return" or key == "space" then
                startRomDownloadReal()
            elseif key == "x" then
                showSearchKeyboard()
            elseif key == "y" and gameState.isSearching then
                clearSearch()
            elseif key == "l" and gameState.isSearching and #gameState.filteredFileList > 1 then
                startBulkDownload()
            elseif key == "backspace" then
                gameState.screen = "platforms"
            end
        end
    elseif gameState.screen == "downloading" then
        if key == "backspace" then
            gameState.screen = "filelist"
        end
    elseif gameState.screen == "bulkdownload" then
        if key == "backspace" then
            if gameState.bulkDownloadActive then
                cancelBulkDownload()
            end
            gameState.screen = "filelist"
        end
    end
end

function love.gamepadpressed(joystick, button)
    -- Set joystick for OSK if not already set
    if not osk.getJoystick() then
        osk.setJoystick(joystick)
    end
    
    if button == "a" then
        love.keypressed("return")
    elseif button == "b" then
        love.keypressed("backspace")
    elseif button == "start" then
        love.keypressed("escape")
    elseif button == "x" then
        love.keypressed("x")
    elseif button == "y" then
        love.keypressed("y")
    elseif button == "dpup" then
        love.keypressed("up")
        -- Enable continuous scrolling for platform and File lists
        if gameState.screen == "platforms" or (gameState.screen == "filelist" and gameState.fileListLoaded) then
            buttonHold.dpup = true
            buttonHold.timer = -buttonHold.repeatDelay  -- Negative to add initial delay
        end
    elseif button == "dpdown" then
        love.keypressed("down")
        -- Enable continuous scrolling for platform and File lists
        if gameState.screen == "platforms" or (gameState.screen == "filelist" and gameState.fileListLoaded) then
            buttonHold.dpdown = true
            buttonHold.timer = -buttonHold.repeatDelay  -- Negative to add initial delay
        end
    elseif button == "rightshoulder" then
        -- R1: Skip 10 items down in File list
        if gameState.screen == "filelist" and gameState.fileListLoaded then
            local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList
            gameState.selectedFile = math.min(#currentList, gameState.selectedFile + 10)
            updateFileScroll()
            buttonHold.r1 = true
            buttonHold.timer = -buttonHold.repeatDelay  -- Negative to add initial delay
        end
    elseif button == "leftshoulder" then
        -- L1: Skip 10 items up in File list OR bulk download when searching
        if gameState.screen == "filelist" and gameState.fileListLoaded then
            if gameState.isSearching and #gameState.filteredFileList > 1 then
                startBulkDownload()
            else
                local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList
                gameState.selectedFile = math.max(1, gameState.selectedFile - 10)
                updateFileScroll()
                buttonHold.l1 = true
                buttonHold.timer = -buttonHold.repeatDelay  -- Negative to add initial delay
            end
        end
    end
end

function love.gamepadreleased(joystick, button)
    if button == "rightshoulder" then
        buttonHold.r1 = false
        buttonHold.timer = 0
    elseif button == "leftshoulder" then
        buttonHold.l1 = false
        buttonHold.timer = 0
    elseif button == "dpup" then
        buttonHold.dpup = false
        buttonHold.timer = 0
    elseif button == "dpdown" then
        buttonHold.dpdown = false
        buttonHold.timer = 0
    end
end

function updateScroll()
    if gameState.selectedPlatform <= gameState.scrollOffset then
        gameState.scrollOffset = math.max(0, gameState.selectedPlatform - 1)
    elseif gameState.selectedPlatform > gameState.scrollOffset + gameState.maxVisible then
        gameState.scrollOffset = gameState.selectedPlatform - gameState.maxVisible
    end
end

function updateFileScroll()
    local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList
    if gameState.selectedFile <= gameState.fileScrollOffset then
        gameState.fileScrollOffset = math.max(0, gameState.selectedFile - 1)
    elseif gameState.selectedFile > gameState.fileScrollOffset + gameState.maxFilesVisible then
        gameState.fileScrollOffset = gameState.selectedFile - gameState.maxFilesVisible
    end
end

-- Filter File list based on search query
function filterRomList(query)
    gameState.filteredFileList = {}
    if query == "" then
        gameState.isSearching = false
        return
    end
    
    gameState.isSearching = true
    local lowerQuery = string.lower(query)
    
    for _, file in ipairs(gameState.fileList) do
        if string.find(string.lower(file.name), lowerQuery, 1, true) then
            table.insert(gameState.filteredFileList, file)
        end
    end
    
    -- Reset selection to first item
    gameState.selectedFile = 1
    gameState.fileScrollOffset = 0
end

-- Show search keyboard
function showSearchKeyboard()
    osk.show(gameState.searchQuery, function(newQuery)
        gameState.searchQuery = newQuery
        filterRomList(newQuery)
    end)
end

-- Clear search
function clearSearch()
    gameState.searchQuery = ""
    gameState.isSearching = false
    gameState.filteredFileList = {}
    gameState.selectedFile = 1
    gameState.fileScrollOffset = 0
end

-- Start bulk download of all filtered Files
function startBulkDownload()
    if not gameState.isSearching or #gameState.filteredFileList == 0 then
        return
    end
    
    -- Initialize bulk download state
    gameState.bulkDownloadActive = true
    gameState.bulkDownloadList = {}
    gameState.bulkDownloadIndex = 0
    gameState.bulkDownloadTotal = #gameState.filteredFileList
    gameState.bulkDownloadSuccess = 0
    gameState.bulkDownloadFailed = 0
    
    -- Copy filtered Files to bulk download list
    for _, file in ipairs(gameState.filteredFileList) do
        table.insert(gameState.bulkDownloadList, file)
    end
    
    -- Switch to bulk download screen
    gameState.screen = "bulkdownload"
    gameState.downloadStatus = "Preparing bulk download of " .. gameState.bulkDownloadTotal .. " Files..."
    
    -- Start downloading the first File
    timer.after(1, function()
        downloadNextRom()
    end)
end

-- Download the next File in the bulk list
function downloadNextRom()
    if not gameState.bulkDownloadActive then
        return
    end
    
    gameState.bulkDownloadIndex = gameState.bulkDownloadIndex + 1
    
    if gameState.bulkDownloadIndex > gameState.bulkDownloadTotal then
        -- All downloads complete
        completeBulkDownload()
        return
    end
    
    local file = gameState.bulkDownloadList[gameState.bulkDownloadIndex]
    local platform = platforms[gameState.selectedPlatform]
    
    gameState.downloadStatus = string.format("Downloading File %d/%d...\n%s", 
        gameState.bulkDownloadIndex, gameState.bulkDownloadTotal, file.name)
    
    -- Execute File download
    local command = string.format("cd /storage/roms/ports/amos_fetcher && python3 downloader.py '%s' '%s' > /tmp/bulk_download_result_%d.json 2>&1 &", 
        platform.name, file.filename, gameState.bulkDownloadIndex)
    os.execute(command)
    
    -- Monitor this download
    timer.after(2, function()
        monitorBulkDownload(gameState.bulkDownloadIndex)
    end)
end

-- Monitor individual File download in bulk
function monitorBulkDownload(romIndex)
    if not gameState.bulkDownloadActive or romIndex ~= gameState.bulkDownloadIndex then
        return
    end
    
    -- Check result file
    local resultFile = io.open("/tmp/bulk_download_result_" .. romIndex .. ".json", "r")
    if resultFile then
        local content = resultFile:read("*all")
        resultFile:close()
        
        if content and content ~= "" then
            if content:match('"status": "success"') then
                gameState.bulkDownloadSuccess = gameState.bulkDownloadSuccess + 1
            else
                gameState.bulkDownloadFailed = gameState.bulkDownloadFailed + 1
            end
            
            -- Clean up result file
            os.execute("rm -f /tmp/bulk_download_result_" .. romIndex .. ".json")
            
            -- Download next File
            timer.after(0.5, function()
                downloadNextRom()
            end)
            return
        end
    end
    
    -- Still downloading, check again
    timer.after(2, function()
        monitorBulkDownload(romIndex)
    end)
end

-- Complete bulk download
function completeBulkDownload()
    gameState.bulkDownloadActive = false
    gameState.downloadStatus = string.format(
        "Bulk download complete!\n\nSuccess: %d Files\nFailed: %d Files\n\nPress B to continue", 
        gameState.bulkDownloadSuccess, gameState.bulkDownloadFailed)
end

-- Cancel bulk download
function cancelBulkDownload()
    gameState.bulkDownloadActive = false
    gameState.downloadStatus = "Bulk download cancelled"
    -- Clean up any remaining result files
    os.execute("rm -f /tmp/bulk_download_result_*.json")
end

function enterRomList()
    gameState.screen = "filelist"
    gameState.fileListLoaded = false
    gameState.fileListLoading = false
    gameState.fileList = {}
    gameState.selectedFile = 1
    gameState.fileScrollOffset = 0
    -- Reset search state
    gameState.searchQuery = ""
    gameState.filteredFileList = {}
    gameState.isSearching = false
    -- Automatically fetch File list
    fetchRomList()
end

function fetchRomList()
    local platform = platforms[gameState.selectedPlatform]
    gameState.fileListLoading = true
    gameState.fileListLoaded = false
    
    -- Execute fast File fetcher
    local command = string.format("cd /storage/roms/ports/amos_fetcher && python3 fetcher.py '%s' > /tmp/file_list.json 2>&1 &", platform.name)
    os.execute(command)
    
    -- Start monitoring for results sooner
    timer.after(1, function()
        loadRomListResults()
    end)
end

function loadRomListResults()
    local file = io.open("/tmp/file_list.json", "r")
    if file then
        local content = file:read("*all")
        file:close()
        
        if content and content ~= "" and not content:match("Fetching Files") then
            gameState.fileList = {}
            
            -- Parse JSON content for real File names
            local inRomsArray = false
            for line in content:gmatch("[^\n]+") do
                if line:match('"files"') then
                    inRomsArray = true
                elseif inRomsArray and line:match('"name":') then
                    local fileName = line:match('"name": "([^"]+)"')
                    if fileName then
                        -- Look for the filename on the next few lines
                        local actualFilename = fileName .. ".zip"  -- default fallback
                        local remainingContent = content:sub(content:find(line, 1, true) + #line)
                        local filenameMatch = remainingContent:match('"filename":%s*"([^"]+)"')
                        if filenameMatch then
                            actualFilename = filenameMatch
                        end
                        
                        table.insert(gameState.fileList, {
                            name = fileName,
                            filename = actualFilename
                        })
                    end
                elseif line:match('"error"') then
                    -- Handle error case
                    gameState.fileList = {}
                    table.insert(gameState.fileList, {name = "Error fetching Files", filename = ""})
                    break
                end
            end
            
            -- If we got real File data, mark as loaded
            if #gameState.fileList > 0 and gameState.fileList[1].name ~= "Error fetching Files" then
                gameState.fileListLoaded = true
                gameState.fileListLoading = false
            else
                -- Still loading or error, try again
                timer.after(2, function()
                    loadRomListResults()
                end)
            end
        else
            -- Still loading, check again
            timer.after(2, function()
                loadRomListResults()
            end)
        end
    else
        -- File not ready, check again
        timer.after(1, function()
            loadRomListResults()
        end)
    end
end

function startRomDownloadReal()
    local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList
    if gameState.selectedFile <= #currentList then
        gameState.screen = "downloading"
        local file = currentList[gameState.selectedFile]
        gameState.downloadStatus = "Preparing to download:\n" .. file.name .. "\n\nThis feature connects to GitHub\nand downloads the selected File."
    end
end

-- Execute real File download
function startRomDownloadReal()
    local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList
    if gameState.selectedFile <= #currentList then
        gameState.screen = "downloading"
        local file = currentList[gameState.selectedFile]
        local platform = platforms[gameState.selectedPlatform]

        gameState.downloadStatus = "Starting download...\n" .. file.name .. "\n\nConnecting to GitHub..."
        
        -- Execute real File download
        local command = string.format("cd /storage/roms/ports/amos_fetcher && python3 downloader.py '%s' '%s' > /tmp/file_download_result.json 2>&1 &", platform.name, file.filename)
        os.execute(command)
        
        -- Start monitoring download progress
        timer.after(1, function()
            monitorDownloadProgress()
        end)
    end
end

-- Monitor real download progress
function monitorDownloadProgress()
    -- Check progress file
    local progress_file = io.open("/tmp/file_download_progress.json", "r")
    if progress_file then
        local content = progress_file:read("*all")
        progress_file:close()
        
        if content and content ~= "" then
            -- Parse progress (simplified)
            if content:match('"status": "starting"') then
                gameState.downloadStatus = "Initializing download...\nConnecting to GitHub..."
            elseif content:match('"status": "downloading"') then
                local percent = tonumber(content:match('"percent": (%d+)')) or 0
                local downloaded_mb = tonumber(content:match('"downloaded_mb": ([%d%.]+)')) or 0
                local total_mb = tonumber(content:match('"total_mb": ([%d%.]+)')) or 0
                
                gameState.downloadStatus = string.format("Downloading... %d%%\n%.1f MB / %.1f MB\n\nSaving to /storage/roms/%s/", 
                    percent, downloaded_mb, total_mb, platforms[gameState.selectedPlatform].folder)
            elseif content:match('"status": "success"') then
                local size_mb = tonumber(content:match('"size_mb": ([%d%.]+)')) or 0
                local folder = platforms[gameState.selectedPlatform].folder
                
                gameState.downloadStatus = string.format("Download Complete!\n\nFile saved to:\n/storage/roms/%s/\n\nSize: %.1f MB\n\nPress B to continue", 
                    folder, size_mb)
                return -- Stop monitoring
            elseif content:match('"error"') then
                local error_msg = content:match('"error": "([^"]+)"') or "Unknown error"
                gameState.downloadStatus = "❌ Download Failed!\n\n" .. error_msg .. "\n\nPress B to try again"
                return -- Stop monitoring
            end
        end
    else
        gameState.downloadStatus = "Preparing download...\nInitializing connection..."
    end
    
    -- Continue monitoring
    timer.after(1, function()
        monitorDownloadProgress()
    end)
end
