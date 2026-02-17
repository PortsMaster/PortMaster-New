-- ROM Playtime Viewer
local push = require('push')
local timer = require('timer')
local osk = require('osk')

local gameWidth, gameHeight = 640, 480
local windowWidth, windowHeight = 640, 480

-- Load platforms dynamically from rom_index.py
local platforms = {}

function loadPlatforms(forceRefresh)
    -- Execute ROM indexer
    local command = "cd /storage/roms/ports/amos_playtime && python3 rom_index.py --platforms"
    if forceRefresh then
        command = command .. " --refresh"
    end
    command = command .. " > /tmp/platforms.json 2>&1"
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

function clearPlaytimeCache()
    os.execute("rm -f /tmp/file_cache/playtime_lookup_cache.json")
    if gameState ~= nil then
        gameState.cachedPlaytimeTotal = "N/A"
    end
end

local gameState = {
    screen = "platforms",
    selectedPlatform = 1,
    selectedFile = 1,
    scrollOffset = 0,
    fileScrollOffset = 0,
    maxVisible = 10,
    maxFilesVisible = 10,
    fileList = {},
    fileListLoaded = false,
    fileListLoading = false,
    searchQuery = "",
    filteredFileList = {},
    isSearching = false,
    playtimeLoading = false,
    playtimeStatus = "",
    playtimeData = nil,
    cachedPlaytimeTotal = nil,
    -- Reserved for future features
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

local triggerState = {
    r2 = false
}

function love.load()
    push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {
        fullscreen = true,
        resizable = false,
        pixelperfect = false
    })
    
    -- Load platforms dynamically from rom_index.py
    loadPlatforms()

    -- Preload cached playtime total (best-effort)
    updateCachedPlaytimeTotal()
    
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
    bgColor = {0.239, 0.200, 0.616} -- dark purple background
    footerColor = {0.149, 0.118, 0.412} -- darker purple for footer
    titleColor = {1.000, 1.000, 1.000} -- white for titles
    textColor = {0.478, 0.435, 0.835} -- light purple for regular text
    selectedColor = {1.000, 1.000, 1.000} -- white for selected item text
    progressBgColor = {0.478, 0.435, 0.835} -- light purple for progress bar background
    selectionBgColor = {0.478, 0.435, 0.835} -- light purple for selected item background
    selectionTextColor = {1.000, 1.000, 1.000} -- white text for selected item
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

    -- Handle continuous scrolling when holding shoulder buttons (platform list)
    if (buttonHold.r1 or buttonHold.l1) and gameState.screen == "platforms" then
        buttonHold.timer = buttonHold.timer + dt
        if buttonHold.timer >= buttonHold.repeatRate then
            buttonHold.timer = 0
            if buttonHold.r1 then
                gameState.selectedPlatform = math.min(#platforms, gameState.selectedPlatform + 10)
                updateScroll()
            elseif buttonHold.l1 then
                gameState.selectedPlatform = math.max(1, gameState.selectedPlatform - 10)
                updateScroll()
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
    elseif gameState.screen == "playtime" then
        drawPlaytimeScreen()
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
    love.graphics.printf("A: View ROMs | R2: Clear+Refresh | Start: Exit", 30, 400, gameWidth, 'left')

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
    love.graphics.printf("A: View ROMs | R2: Clear Total | Start: Exit", 30, 400, gameWidth, 'left')
    local selectedPlatform = platforms[gameState.selectedPlatform]
    love.graphics.setColor(textColor)
    love.graphics.setFont(titleFont)
    local totalText = "Total (cached): " .. (gameState.cachedPlaytimeTotal or "N/A")
    love.graphics.printf(totalText, 30, 442, gameWidth, 'left')
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
        love.graphics.printf("Press A to load ROM list", 0, 100, gameWidth, 'center')
        -- Footer background
        love.graphics.setColor(footerColor)
        love.graphics.rectangle('fill', 0, 390, gameWidth, 90)
        
        love.graphics.setColor(textColor)
        love.graphics.setFont(smallFont)
        love.graphics.printf("A: Load ROMs | B: Back to platforms", 0, 400, gameWidth, 'center')
        return
    end
    
    -- Show combined platform name and File count
    love.graphics.setColor(titleColor)
    love.graphics.setFont(titleFont)
    local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList
    local combinedTitle = gameState.isSearching and 
        string.format("%s - Found %d/%d ROMs", platform.name, #gameState.filteredFileList, #gameState.fileList) or
        string.format("%s - Found %d ROMs", platform.name, #gameState.fileList)
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
    if gameState.isSearching then
        controlsText = "A: Playtime | X: Search | Y: Clear | B: Back"
    else
        controlsText = "L1/R1: Scroll 10 items | A: Playtime | X: Search | B: Back"
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

function drawPlaytimeScreen()
    love.graphics.setColor(titleColor)
    love.graphics.setFont(titleFont)
    love.graphics.printf("PLAYTIME", 0, 40, gameWidth, 'center')

    local platform = platforms[gameState.selectedPlatform]
    love.graphics.setColor(textColor)
    love.graphics.setFont(headerFont)
    love.graphics.printf("Platform: " .. platform.name, 0, 90, gameWidth, 'center')

    local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList
    if gameState.selectedFile <= #currentList then
        local file = currentList[gameState.selectedFile]
        local fileName = file.name
        if string.len(fileName) > 40 then
            fileName = string.sub(fileName, 1, 37) .. "..."
        end
        love.graphics.setColor(textColor)
        love.graphics.setFont(titleFont)
        love.graphics.printf("ROM: " .. fileName, 0, 120, gameWidth, 'center')
    end

    if gameState.playtimeLoading then
        love.graphics.setColor(textColor)
        love.graphics.setFont(titleFont)
        love.graphics.printf(gameState.playtimeStatus, 0, 180, gameWidth, 'center')
    elseif gameState.playtimeData then
        local data = gameState.playtimeData
        local lines = {
            "Title: " .. (data.title or "Unknown"),
            "Estimated: " .. (data.estimated and (string.format("%.1f hrs", data.estimated)) or "N/A"),
            "Main: " .. (data.main and (string.format("%.1f hrs", data.main)) or "N/A"),
            "Main+Extra: " .. (data.extra and (string.format("%.1f hrs", data.extra)) or "N/A"),
            "Completionist: " .. (data.completionist and (string.format("%.1f hrs", data.completionist)) or "N/A"),
            "Source: " .. (data.source or "unknown")
        }
        love.graphics.setColor(textColor)
        love.graphics.setFont(titleFont)
        local startY = 170
        for i, line in ipairs(lines) do
            love.graphics.printf(line, 0, startY + (i - 1) * 26, gameWidth, 'center')
        end
    else
        love.graphics.setColor(textColor)
        love.graphics.setFont(titleFont)
        love.graphics.printf(gameState.playtimeStatus ~= "" and gameState.playtimeStatus or "No playtime data available.", 0, 180, gameWidth, 'center')
    end

    -- Footer background
    love.graphics.setColor(footerColor)
    love.graphics.rectangle('fill', 0, 390, gameWidth, 90)

    -- Controls
    love.graphics.setColor(textColor)
    love.graphics.setFont(titleFont)
    love.graphics.printf("B to return to list | Start: Exit", 0, 410, gameWidth, 'center')
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
            elseif key == "escape" then
                love.event.quit()
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
                openPlaytimeScreen()
            elseif key == "x" then
                showSearchKeyboard()
            elseif key == "y" and gameState.isSearching then
                clearSearch()
            elseif key == "backspace" then
                gameState.screen = "platforms"
            elseif key == "escape" then
                love.event.quit()
            end
        end
    elseif gameState.screen == "playtime" then
        if key == "backspace" then
            gameState.screen = "filelist"
        elseif key == "escape" then
            love.event.quit()
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
        -- R1: Skip 10 items down in File list or platform list
        if gameState.screen == "platforms" then
            gameState.selectedPlatform = math.min(#platforms, gameState.selectedPlatform + 10)
            updateScroll()
            buttonHold.r1 = true
            buttonHold.timer = -buttonHold.repeatDelay  -- Negative to add initial delay
        elseif gameState.screen == "filelist" and gameState.fileListLoaded then
            local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList
            gameState.selectedFile = math.min(#currentList, gameState.selectedFile + 10)
            updateFileScroll()
            buttonHold.r1 = true
            buttonHold.timer = -buttonHold.repeatDelay  -- Negative to add initial delay
        end
    elseif button == "righttrigger" then
        -- R2: Clear cached playtime total and refresh platforms
        if gameState ~= nil and gameState.screen == "platforms" then
            clearPlaytimeCache()
            loadPlatforms(true)
            updateCachedPlaytimeTotal()
            gameState.selectedPlatform = 1
            gameState.scrollOffset = 0
        end
    elseif button == "leftshoulder" then
        -- L1: Skip 10 items up in platform list or File list
        if gameState.screen == "platforms" then
            gameState.selectedPlatform = math.max(1, gameState.selectedPlatform - 10)
            updateScroll()
            buttonHold.l1 = true
            buttonHold.timer = -buttonHold.repeatDelay  -- Negative to add initial delay
        elseif gameState.screen == "filelist" and gameState.fileListLoaded then
            local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList
            gameState.selectedFile = math.max(1, gameState.selectedFile - 10)
            updateFileScroll()
            buttonHold.l1 = true
            buttonHold.timer = -buttonHold.repeatDelay  -- Negative to add initial delay
        end
    end
end

function love.gamepadaxis(joystick, axis, value)
    -- Some controllers expose triggers as axes instead of buttons
    if axis == "triggerright" or axis == "righttrigger" then
        if value > 0.6 and not triggerState.r2 then
            if gameState ~= nil and gameState.screen == "platforms" then
                clearPlaytimeCache()
                loadPlatforms(true)
                updateCachedPlaytimeTotal()
                gameState.selectedPlatform = 1
                gameState.scrollOffset = 0
            end
            triggerState.r2 = true
        elseif value < 0.2 then
            triggerState.r2 = false
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

function updateCachedPlaytimeTotal()
    local file = io.open("/tmp/file_cache/playtime_lookup_cache.json", "r")
    if not file then
        gameState.cachedPlaytimeTotal = "N/A"
        return
    end

    local content = file:read("*all")
    file:close()

    if not content or content == "" then
        gameState.cachedPlaytimeTotal = "N/A"
        return
    end

    local total = 0
    local count = 0

    for hours in content:gmatch('"main"%s*:%s*([%d%.]+)') do
        local val = tonumber(hours)
        if val then
            total = total + val
            count = count + 1
        end
    end

    if count == 0 then
        gameState.cachedPlaytimeTotal = "N/A"
    else
        gameState.cachedPlaytimeTotal = string.format("%.1f hrs (%d)", total, count)
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
    
    -- Execute ROM indexer for this platform
    local command = string.format("cd /storage/roms/ports/amos_playtime && python3 rom_index.py --files '%s' > /tmp/file_list.json 2>&1 &", platform.name)
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
        
        if content and content ~= "" then
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
                    table.insert(gameState.fileList, {name = "Error loading ROMs", filename = ""})
                    break
                end
            end
            
            -- If we got real File data, mark as loaded
            if #gameState.fileList > 0 and gameState.fileList[1].name ~= "Error loading ROMs" then
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

function openPlaytimeScreen()
    local currentList = gameState.isSearching and gameState.filteredFileList or gameState.fileList
    if gameState.selectedFile <= #currentList then
        local file = currentList[gameState.selectedFile]
        local platform = platforms[gameState.selectedPlatform]

        gameState.screen = "playtime"
        gameState.playtimeLoading = true
        gameState.playtimeStatus = "Loading playtime data..."
        gameState.playtimeData = nil

        os.execute("rm -f /tmp/playtime_result.json")
        local command = string.format("cd /storage/roms/ports/amos_playtime && python3 playtime.py --playtime '%s' '%s' > /tmp/playtime_result.json 2>&1 &", platform.name, file.filename)
        os.execute(command)

        timer.after(1, function()
            loadPlaytimeResult()
        end)
    end
end

function loadPlaytimeResult()
    local file = io.open("/tmp/playtime_result.json", "r")
    if file then
        local content = file:read("*all")
        file:close()

        if content and content ~= "" then
            local status = content:match('"status"%s*:%s*"([^"]+)"')
            if status == "success" then
                local title = content:match('"title"%s*:%s*"([^"]+)"') or "Unknown"
                local source = content:match('"source"%s*:%s*"([^"]+)"') or "unknown"
                local estimated = tonumber(content:match('"estimated_hours"%s*:%s*([%d%.]+)'))
                local main = tonumber(content:match('"main"%s*:%s*([%d%.]+)'))
                local extra = tonumber(content:match('"extra"%s*:%s*([%d%.]+)'))
                local completionist = tonumber(content:match('"completionist"%s*:%s*([%d%.]+)'))

                gameState.playtimeData = {
                    title = title,
                    source = source,
                    estimated = estimated,
                    main = main,
                    extra = extra,
                    completionist = completionist
                }
                gameState.playtimeLoading = false
        gameState.playtimeStatus = "Playtime data loaded"
        updateCachedPlaytimeTotal()
        return
            elseif status == "not_found" then
                gameState.playtimeLoading = false
                gameState.playtimeStatus = "No playtime data found for this game."
                return
            end
        end
    end

    -- Still loading, check again
    timer.after(1, function()
        loadPlaytimeResult()
    end)
end
