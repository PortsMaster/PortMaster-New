local PauseMenu = {}
local defaultYSpacing = 6
function positionElements(menu, baseY, spacing)
    for k = 1,#menu do
        menu[k].y = baseY + (k-1) * spacing
    end
end
function positionElementsCentered(menu, spacing)
    positionElements(menu, -(#menu-1)/2*spacing, spacing)
end
function gameOptionsSubMenu(parent)
    local menu = {}
    table.insert(menu, createSlider("CAM SHAKE", 0, 0, parent,
        function(currentVal)
            gamePreferences.cameraShakePreferenceMultiplier = currentVal
        end, gamePreferences.cameraShakePreferenceMultiplier, 0.25))
    table.insert(menu, createButton("BACK", 0, 0, parent,
        function()
            parent:changeMenu(parent.optionsSubMenu)
        end))
    positionElementsCentered(menu, defaultYSpacing)
    return menu
end

function audioSubMenu(parent)
    local menu = {}
    table.insert(menu, createSlider("SFX VOLUME", 0, 0, parent,
        function(currentVal)
            SoundManager.setVolumeScale(currentVal)
            SoundManager.playSound("SmallExplosion") -- example sound
        end, SoundManager.volumeScale, 0.1))
    table.insert(menu, createSlider("MUSIC", 0, 0, parent,
        function(currentVal)
            MusicManager.setVolumeScale(currentVal)
        end, MusicManager.volumeScale, 0.1))
    table.insert(menu, createButton("BACK", 0, 0, parent,
        function()
            parent:changeMenu(parent.optionsSubMenu)
        end))
    positionElementsCentered(menu, defaultYSpacing)
    return menu
end

function videoSubMenu(parent)
    local menu = {}
    local windowOptionsButton = createCheckbox("FULLSCREEN", 0, 0, parent,
        function()
            local isFs, fsMode = love.window.getFullscreen()
            if isFs then
                resizeWindow(640, 640)
            else
                setFullscreen(true, "desktop")
            end
        end, 
        function()
            local isFs, fsMode = love.window.getFullscreen()
            return isFs
        end)
    table.insert(menu, windowOptionsButton)
    table.insert(menu, createCheckbox("VSYNC", 0, 0, parent,
        function()
            local vsyncStatus = love.window.getVSync()
            love.window.setVSync(vsyncStatus == 1 and 0 or 1)
        end, 
        function()
            return love.window.getVSync() == 1
        end))
    table.insert(menu, createCheckbox("CAP FPS", 0, 0, parent,
        function()
            lockFPS = not lockFPS
        end, function() return lockFPS end))
    table.insert(menu, createButton("BACK", 0, 0, parent,
        function()
            parent:changeMenu(parent.optionsSubMenu)
        end))
    positionElementsCentered(menu, defaultYSpacing)
    return menu
end

function controlsSubMenu(parent, isGamepad)
    local menu = {}
    local numButtons = Input.numInConfig
    local buttonInd = 0
    local buttonSpacing = defaultYSpacing
    -- Sort to avoid reordering when pressing "restore defaults"
    table.sort(Input.currentConfig, function(a, b)
        return a.buttonName < b.buttonName
    end)
    for k = 1,numButtons do
        local currentConfigButton = Input.currentConfig[k]
        local keyName = currentConfigButton.buttonName
        if (keyName ~= "pause" and keyName ~= "navup" and keyName ~= "navdown" and keyName ~= "select" and keyName ~= "navleft" and keyName ~= "navright") then
            local controlString = isGamepad and "gamepad" or "keyboard"
            local displayString = currentConfigButton[controlString][1]
            if isGamepad and Input.controllerType == "PS4" and Input.aliases.PS4[currentConfigButton[controlString][1]] then
                displayString = Input.aliases.PS4[currentConfigButton[controlString][1]]
            end
            local currentButton = createButton(keyName .. " " .. displayString, 0, -(numButtons - 5)/2*buttonSpacing + buttonInd*buttonSpacing, parent)
            currentButton.buttonString = currentConfigButton[controlString][1]
            currentButton.choosingNewValue = false
            currentButton.fcn =
                function()
                    currentButton.text = keyName .. " " .. "_press_"
                    PauseMenu.frozen = true
                    currentButton.choosingNewValue = true
                    Input.lastKeyPressed = nil
                    Input.lastGamepadPressed = nil
                end
            currentButton.update = 
                function()
                    if Input.getMappedButtonPressed("pause") then
                        currentButton.choosingNewValue = false
                    end
                    if currentButton.choosingNewValue then
                        local lastBtn = nil
                        if isGamepad then
                            lastBtn = Input.lastGamepadPressed
                        else
                            lastBtn = Input.lastKeyPressed
                        end
                        if lastBtn then
                            PauseMenu.frozen = false
                            currentButton.buttonString = lastBtn
                            local newDisplayString = currentButton.buttonString
                            if isGamepad and Input.controllerType == "PS4" and Input.aliases.PS4[lastBtn] then
                                newDisplayString = Input.aliases.PS4[lastBtn]
                            end
                            currentButton.text = keyName .. " " .. newDisplayString
                            if not Input.isKeyMapped(lastBtn) then
                                Input.addKeyMapping(lastBtn, isGamepad)
                            end
                            if controlString == "gamepad" then
                                Input.remap(keyName, nil, lastBtn)
                            elseif controlString == "keyboard" then
                                Input.remap(keyName, lastBtn, nil)
                            end
                            currentButton.choosingNewValue = false
                        end
                    end
                end
            table.insert(menu, currentButton)
            buttonInd = buttonInd + 1
        end
    end
    table.insert(menu, createButton("restore defaults", 0, buttonInd/2*buttonSpacing, parent,
        function()
            Input.map(Input.defaultConfig)
            if isGamepad then
                parent.gamepadControlsSubmenu = controlsSubMenu(PauseMenu, true)
                parent:changeMenu(parent.gamepadControlsSubmenu)
            else
                parent.keyboardControlsSubmenu = controlsSubMenu(PauseMenu, false)
                parent:changeMenu(parent.keyboardControlsSubmenu)
            end
        end))
    table.insert(menu, createButton("BACK", 0, (buttonInd/2 + 1)*buttonSpacing, parent,
        function()
            parent:changeMenu(parent.optionsSubMenu)
        end))
    return menu
end

function PauseMenu.initialize()
    PauseMenu.elements = {}
    PauseMenu.canPause = true
    PauseMenu.x = gameResolution.width / 2
    PauseMenu.y = gameResolution.height / 2
    PauseMenu.font = love.graphics.newFont("Fonts/PICO-8 mono.ttf", 4)
    PauseMenu.frozen = false
    PauseMenu.selected = 1
    PauseMenu.navMode = "keyboard" -- "keyboard" or "mouse"
    PauseMenu.lastMousePos = {x=0,y=0}
    PauseMenu.mainMenu = {}
    PauseMenu.optionsSubMenu = {}
    PauseMenu.audioSubMenu = audioSubMenu(PauseMenu)
    PauseMenu.videoSubMenu = videoSubMenu(PauseMenu)
    PauseMenu.keyboardControlsSubmenu = controlsSubMenu(PauseMenu, false)
    PauseMenu.gamepadControlsSubmenu = controlsSubMenu(PauseMenu, true)
    PauseMenu.gameOptionsSubMenu = gameOptionsSubMenu(PauseMenu)

    function PauseMenu:changeMenu(newMenu)
        PauseMenu.elements = newMenu
        PauseMenu.selected = 1
        PauseMenu.elements[1]:hoverOn()
    end
    -- Options Sub Menu
    table.insert(PauseMenu.optionsSubMenu, createButton("GAME", 0, 0, PauseMenu,
        function()
            PauseMenu:changeMenu(PauseMenu.gameOptionsSubMenu)
        end))
    table.insert(PauseMenu.optionsSubMenu, createButton("AUDIO", 0, 0, PauseMenu,
        function()
            PauseMenu:changeMenu(PauseMenu.audioSubMenu)
        end))
    if not web then
        -- Only allow video options if not on the web
        table.insert(PauseMenu.optionsSubMenu, createButton("VIDEO", 0, 0, PauseMenu,
        function()
            PauseMenu:changeMenu(PauseMenu.videoSubMenu)
        end))
    end
    table.insert(PauseMenu.optionsSubMenu, createButton("KB CNTRLS", 0, 0, PauseMenu,
        function()
            PauseMenu:changeMenu(PauseMenu.keyboardControlsSubmenu)
        end))
    if not armorgames and not crazygames then
        table.insert(PauseMenu.optionsSubMenu, createButton("GAMEPAD CNTRLS", 0, 0, PauseMenu,
            function()
                PauseMenu:changeMenu(PauseMenu.gamepadControlsSubmenu)
            end))
    end
    table.insert(PauseMenu.optionsSubMenu, createButton("BACK", 0, 0, PauseMenu,
        function()
            PauseMenu:changeMenu(PauseMenu.mainMenu)
        end))
    positionElementsCentered(PauseMenu.optionsSubMenu, defaultYSpacing)
    PauseMenu.createMainMenu()
end

function PauseMenu.createMainMenu()
    PauseMenu.mainMenu = {}
    table.insert(PauseMenu.mainMenu, createButton("RESUME", 0, 0, PauseMenu, function()
        gameState.paused = false
    end))
    table.insert(PauseMenu.mainMenu, createButton("RESTART STAGE", 0, 0, PauseMenu,
        function()
            restartStage()
            gameState.paused = false
        end))
    if gameState.state.isCutscene then
        table.insert(PauseMenu.mainMenu, createButton("SKIP SCENE", 0, 0, PauseMenu,
            function()
                gameState.goToNextLevel()
                gameState.paused = false
            end))
    end
    table.insert(PauseMenu.mainMenu, createButton("OPTIONS", 0, 0, PauseMenu,
        function()
            PauseMenu:changeMenu(PauseMenu.optionsSubMenu)
        end))
    table.insert(PauseMenu.mainMenu, createButton("TITLE", 0, 0, PauseMenu,
        function()
            goToTitleScreen()
            gameState.paused = false
        end))
    if not web then
        table.insert(PauseMenu.mainMenu, createButton("QUIT", 0, 0, PauseMenu,
        function()
            love.event.quit()
        end))
    end
    positionElementsCentered(PauseMenu.mainMenu, defaultYSpacing)
end

function PauseMenu.activate()
    PauseMenu.frozen = false
    PauseMenu:changeMenu(PauseMenu.mainMenu)
end

function PauseMenu.update(dt)
    PauseMenu.x = gameResolution.width / 2
    PauseMenu.y = gameResolution.height / 2
    if Input.getMappedButtonPressed("pause") and PauseMenu.canPause then
        gameState.paused = not gameState.paused
        if gameState.paused then
            PauseMenu.lastMousePos.x, PauseMenu.lastMousePos.y = getMouseCanvasPosition()
            PauseMenu.activate()
            if crazygames then
                print("cgCall:stop")
            end
        else
            if crazygames then
                print("cgCall:start")
            end
        end
    end
    if gameState.paused then
        if not PauseMenu.frozen then
            local mouseX, mouseY = getMouseCanvasPosition()
            if math.abs(mouseX - PauseMenu.lastMousePos.x) > 3 or math.abs(mouseY - PauseMenu.lastMousePos.y) > 3 then
                PauseMenu.navMode = "mouse"
            end
            PauseMenu.lastMousePos.x, PauseMenu.lastMousePos.y = mouseX, mouseY
            if PauseMenu.navMode == "mouse" then
                for k = 1,#PauseMenu.elements do
                    if PauseMenu.elements[k] then
                        if PauseMenu.elements[k]:mouseInBounds(mouseX, mouseY) then
                            PauseMenu.selected = k
                            if Input.getButtonPressed("mouse1") then
                                PauseMenu.elements[k]:click(mouseX)
                                break
                            end
                        end
                    end
                end
                if Input.getMappedButtonPressed("navup") or Input.getMappedButtonPressed("navdown")
                    or Input.getMappedButtonPressed("navleft") or Input.getMappedButtonPressed("navright")
                    or Input.getMappedButtonPressed("select") then
                    PauseMenu.navMode = "keyboard"
                end
            end
            if PauseMenu.navMode == "keyboard" then
                if Input.getMappedButtonPressed("navup") then
                    PauseMenu.selected = PauseMenu.selected - 1
                    if PauseMenu.selected < 1 then
                        PauseMenu.selected = #PauseMenu.elements
                    end
                elseif Input.getMappedButtonPressed("navdown") then
                    PauseMenu.selected = PauseMenu.selected + 1
                    if PauseMenu.selected > #PauseMenu.elements then
                        PauseMenu.selected = 1
                    end
                elseif Input.getMappedButtonPressed("select") then
                    PauseMenu.elements[PauseMenu.selected]:press()
                elseif Input.getMappedButtonPressed("navright") then
                    PauseMenu.elements[PauseMenu.selected]:leftRight(1)
                elseif Input.getMappedButtonPressed("navleft") then
                    PauseMenu.elements[PauseMenu.selected]:leftRight(-1)
                end
            end
        else
            for k = 1,#PauseMenu.elements do
                if PauseMenu.elements[k].update then
                    PauseMenu.elements[k].update()
                end
            end
        end
        for k = 1,#PauseMenu.elements do
            if k == PauseMenu.selected and not PauseMenu.elements[k].hovering then
                PauseMenu.elements[k]:hoverOn()
            elseif k ~= PauseMenu.selected and PauseMenu.elements[k].hovering then
                PauseMenu.elements[k]:hoverOff()
            end
        end
    end
end

function PauseMenu.draw()
    local tFont = love.graphics.getFont()
    love.graphics.setFont(PauseMenu.font)
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle('fill', 0, 0, windowWidth, windowHeight)
    for k=1,#PauseMenu.elements do
        PauseMenu.elements[k]:draw()
    end
    love.graphics.setFont(tFont)
end

return PauseMenu