local Button = require "src.ui.button"
local Slider = require "src.ui.slider"
local gameState = require "src.states.gameState"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"
local inputManager = require "src.utils.inputManager"
local bg = require 'src.shaders.menu_bg'
local signal = require 'libs.signal'
local settingsText = gameState.getText("settings")
local crt = require 'src.shaders.crt'

local settingsState = {}

local function triggerTransition(targetState)
    if settingsState.isTransitioning then return end
    settingsState.isTransitioning = true
    PendingState = targetState

    Transition.play(0.5)

    signal.register('Transition_finished', function()
        signal.remove('Transition_finished')
        if PendingState then
            love.SwitchState(PendingState)
            PendingState = nil
        end
    end)
end

local buttons = {}
local sliders = {}
local titleFont = fontManager.getFont(GameConfig.FONTS.SETTINGS_TITLE)

local tempSettings = {}

local virtualWidth = GameConfig.VIRTUAL_WIDTH
local virtualHeight = GameConfig.VIRTUAL_HEIGHT
local currentGuiScale = 1

local activePopup = "none"
local popupButtons = {}
local selectedPopupIndex = 1

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

local function rebuildLanguagePopup()
    popupButtons = {}
    local languages = gameState.getAvailableLanguages()

    local totalItems = #languages
    local numRows = math.ceil(totalItems / 2)
    local rowSpacing = 15

    local totalFrameRows = numRows + 1
    local totalFrameW = (GameConfig.MENU.BUTTON_WIDTH * 2) + GameConfig.MENU.BUTTON_SPACING
    local totalFrameH = (totalFrameRows * (GameConfig.MENU.BUTTON_HEIGHT + rowSpacing)) - rowSpacing

    local startX = (virtualWidth / 2) - (totalFrameW / 2)
    local startY = (virtualHeight / 2) - (totalFrameH / 2)

    for i, lang in ipairs(languages) do
        if lang.code == tempSettings.language then
            selectedPopupIndex = i
        end

        local col = ((i - 1) % 2) + 1
        local row = math.ceil(i / 2)

        local posX = startX + (col - 1) * (GameConfig.MENU.BUTTON_WIDTH + GameConfig.MENU.BUTTON_SPACING)
        local posY = startY + (row - 1) * (GameConfig.MENU.BUTTON_HEIGHT + rowSpacing)

        table.insert(popupButtons, Button.new(
            posX,
            posY,
            GameConfig.MENU.BUTTON_WIDTH,
            GameConfig.MENU.BUTTON_HEIGHT,
            lang.name,
            function()
                tempSettings.language = lang.code
                activePopup = "none"
                soundManager.playSound('confirm')
                settingsState.recalculateLayout()
            end,
            currentGuiScale
        ))
    end

    local backRow = numRows + 1
    local backPosX = startX + (totalFrameW / 2) - (GameConfig.MENU.BUTTON_WIDTH / 2)
    local backPosY = startY + (backRow - 1) * (GameConfig.MENU.BUTTON_HEIGHT + rowSpacing)

    table.insert(popupButtons, Button.new(
        backPosX,
        backPosY,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("back") or "Back",
        function()
            activePopup = "none"
            soundManager.playSound("back")
        end,
        currentGuiScale
    ))
end

local function rebuildResolutionPopup()
    popupButtons = {}
    local sizes = GameConfig.SCREEN_SIZES

    local totalItems = #sizes
    local numRows = math.ceil(totalItems / 2)

    local buttonW = GameConfig.MENU.BUTTON_WIDTH
    local buttonH = GameConfig.MENU.BUTTON_HEIGHT
    local colSpacing = GameConfig.MENU.BUTTON_SPACING
    local rowSpacing = 15

    local totalFrameRows = numRows + 1
    local totalFrameW = (buttonW * 2) + colSpacing
    local totalFrameH = (totalFrameRows * (buttonH + rowSpacing)) - rowSpacing

    local startX = (virtualWidth / 2) - (totalFrameW / 2)
    local startY = (virtualHeight / 2) - (totalFrameH / 2)

    for i, size in ipairs(sizes) do
        if size.width == tempSettings.screenSize.width and size.height == tempSettings.screenSize.height then
            selectedPopupIndex = i
        end

        local col = ((i - 1) % 2) + 1
        local row = math.ceil(i / 2)

        local posX = startX + (col - 1) * (buttonW + colSpacing)
        local posY = startY + (row - 1) * (buttonH + rowSpacing)

        table.insert(popupButtons, Button.new(
            posX,
            posY,
            buttonW,
            buttonH,
            size.label,
            function()
                tempSettings.screenSize = { width = size.width, height = size.height }
                activePopup = "none"
                soundManager.playSound('confirm')
                settingsState.recalculateLayout()
            end,
            currentGuiScale
        ))
    end

    local backRow = numRows + 1
    local backPosX = startX + (totalFrameW / 2) - (buttonW / 2)
    local backPosY = startY + (backRow - 1) * (GameConfig.MENU.BUTTON_HEIGHT + rowSpacing)

    table.insert(popupButtons, Button.new(
        backPosX,
        backPosY,
        buttonW,
        buttonH,
        gameState.getText("back") or "Back",
        function()
            activePopup = "none"
            soundManager.playSound("back")
        end,
        currentGuiScale
    ))
end

function settingsState.recalculateLayout()
    virtualWidth = GameConfig.VIRTUAL_WIDTH
    virtualHeight = GameConfig.VIRTUAL_HEIGHT

    titleFont = fontManager.getFont(GameConfig.FONTS.SETTINGS_TITLE)

    local centerX = virtualWidth / 2
    local startY = virtualHeight * GameConfig.SETTINGS.START_Y_OFFSET + (virtualHeight / 7)
    local spacing = virtualHeight * GameConfig.SETTINGS.SPACING_OFFSET

    local controlWidth = virtualWidth * GameConfig.SETTINGS.CONTROL_WIDTH_RATIO

    sliders = {}
    buttons = {}

    table.insert(sliders, Slider.new(
        centerX - controlWidth / 2,
        startY,
        controlWidth,
        GameConfig.UI.SLIDER.TRACK_HEIGHT,
        0, 1,
        tempSettings.musicVolume,
        gameState.getText("musicVolume"),
        function(value)
            tempSettings.musicVolume = value
        end,
        currentGuiScale
    ))

    table.insert(sliders, Slider.new(
        centerX - controlWidth / 2,
        startY + spacing * 0.5,
        controlWidth,
        GameConfig.UI.SLIDER.TRACK_HEIGHT,
        0, 1,
        tempSettings.effectsVolume,
        gameState.getText("effectsVolume"),
        function(value)
            tempSettings.effectsVolume = value
        end,
        currentGuiScale
    ))

    table.insert(buttons, Button.new(
        centerX - GameConfig.MENU.BUTTON_WIDTH / 2,
        startY + spacing,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("language"),
        function()
            rebuildLanguagePopup()
            activePopup = "language"
            soundManager.playSound('confirm')
        end,
        currentGuiScale
    ))

    table.insert(buttons, Button.new(
        centerX - GameConfig.MENU.BUTTON_WIDTH / 2,
        startY + spacing * 1.5,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("resolution"),
        function()
            rebuildResolutionPopup()
            activePopup = "resolution"
            soundManager.playSound('confirm')
        end,
        currentGuiScale
    ))

    table.insert(buttons, Button.new(
        centerX - GameConfig.MENU.BUTTON_WIDTH / 2,
        startY + spacing * 2,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("controls"),
        function()
            soundManager.playSound('confirm')
            triggerTransition("controls")
        end,
        currentGuiScale
    ))

	table.insert(buttons, Button.new(
		centerX - GameConfig.MENU.BUTTON_WIDTH / 2,
		startY + spacing * 2.5,
		GameConfig.MENU.BUTTON_WIDTH,
		GameConfig.MENU.BUTTON_HEIGHT,
		"Retro",
		function()
			tempSettings.crtOn = not tempSettings.crtOn
			GameConfig.CRT_ON = tempSettings.crtOn
			if crt and crt.toggle then
				crt.toggle(tempSettings.crtOn)
			end

			soundManager.playSound("confirm")
		end,
		currentGuiScale
	))

    table.insert(buttons, Button.new(
        centerX - GameConfig.MENU.BUTTON_WIDTH - GameConfig.MENU.BUTTON_SPACING * 3,
        virtualHeight - GameConfig.MENU.BUTTON_HEIGHT * 4,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("back"),
        function()
            soundManager.playSound('back')
            triggerTransition("menu")
        end,
        currentGuiScale
    ))

    table.insert(buttons, Button.new(
        centerX + GameConfig.MENU.BUTTON_SPACING * 3,
        virtualHeight - GameConfig.MENU.BUTTON_HEIGHT * 4,
        GameConfig.MENU.BUTTON_WIDTH,
        GameConfig.MENU.BUTTON_HEIGHT,
        gameState.getText("apply"),
        function()
            local resChanged = (tempSettings.screenSize.width ~= gameState.settings.screenSize.width) 
                            or (tempSettings.screenSize.height ~= gameState.settings.screenSize.height)
            local crtChanged = (tempSettings.crtOn ~= gameState.settings.crtOn)

            gameState.settings = deepcopy(tempSettings)

            -- Pass boolean indicating whether a display window rebuild is necessary
            gameState.applySettings(resChanged or crtChanged)

            soundManager.updateVolumes()
            soundManager.playSound('confirm')

            settingsState.recalculateLayout()
        end,
        currentGuiScale
    ))

    if activePopup == "language" then
        rebuildLanguagePopup()
    elseif activePopup == "resolution" then
        rebuildResolutionPopup()
    end
end

function settingsState.init(vWidth, vHeight)
    bg.init()
    tempSettings = deepcopy(gameState.settings)
    settingsState.recalculateLayout()
    settingsState.selectedElement = {type = "slider", index = 1}
end

function settingsState.enter()
    activePopup = "none"
    settingsState.isTransitioning = true
    Transition.fadeIn(0.5, function()
        settingsState.isTransitioning = false
    end)
end

function settingsState.resize(w, h)
    settingsState.recalculateLayout()
end

function settingsState.update(dt)
    bg.update(dt)
    inputManager.update(dt)

    if not settingsState.selectedElement then
        settingsState.selectedElement = {type = "slider", index = 1}
    end

    if activePopup ~= "none" then
        for _, btn in ipairs(popupButtons) do btn:update(dt) end

        local totalItems = #popupButtons
        local backButtonIndex = totalItems
        local numGridItems = totalItems - 1
        local numRows = math.ceil(numGridItems / 2)
        local curRow = math.ceil(selectedPopupIndex / 2)
        local curCol = ((selectedPopupIndex - 1) % 2) + 1

        if inputManager.isActionJustPressed("up") then
            if selectedPopupIndex == backButtonIndex then
                curRow = numRows
                selectedPopupIndex = math.min(numGridItems, (curRow - 1) * 2 + curCol)
            else
                curRow = curRow - 1
                if curRow < 1 then
                    selectedPopupIndex = backButtonIndex
                else
                    local targetIndex = (curRow - 1) * 2 + curCol
                    if targetIndex > numGridItems then targetIndex = numGridItems end
                    selectedPopupIndex = targetIndex
                end
            end
            soundManager.playSound("select")
            if popupButtons[selectedPopupIndex] then popupButtons[selectedPopupIndex]:pulse() end
            return

        elseif inputManager.isActionJustPressed("down") then
            if selectedPopupIndex == backButtonIndex then
                curRow = 1
                selectedPopupIndex = math.min(numGridItems, (curRow - 1) * 2 + curCol)
            else
                curRow = curRow + 1
                if curRow > numRows then
                    selectedPopupIndex = backButtonIndex
                else
                    local targetIndex = (curRow - 1) * 2 + curCol
                    if targetIndex > numGridItems then targetIndex = numGridItems end
                    selectedPopupIndex = targetIndex
                end
            end
            soundManager.playSound("select")
            if popupButtons[selectedPopupIndex] then popupButtons[selectedPopupIndex]:pulse() end
            return

        elseif inputManager.isActionJustPressed("left") or inputManager.isActionJustPressed("right") then
            if selectedPopupIndex ~= backButtonIndex then
                if curCol == 1 then
                    local targetIndex = selectedPopupIndex + 1
                    if targetIndex <= numGridItems then
                        selectedPopupIndex = targetIndex
                        soundManager.playSound("select")
                    end
                else
                    selectedPopupIndex = selectedPopupIndex - 1
                    soundManager.playSound("select")
                end
            end
            if popupButtons[selectedPopupIndex] then popupButtons[selectedPopupIndex]:pulse() end
            return

        elseif inputManager.isActionJustPressed("select") then
            popupButtons[selectedPopupIndex]:click()
            return
        elseif inputManager.isActionJustPressed("back") then
            activePopup = "none"
            soundManager.playSound("back")
            return
        end
        return
    end

    for _, slider in ipairs(sliders) do slider:update(dt) end
    for _, button in ipairs(buttons) do button:update(dt) end

    local hoveredButton = nil
    for i, button in ipairs(buttons) do
        button:update(dt)
    end

    if hoveredButton ~= nil then
        if settingsState.selectedButton ~= hoveredButton then
            settingsState.selectedButton = hoveredButton
        end
    end

    if activePopup == "none" then
        if settingsState.selectedElement.type == "slider" then
            local slider = sliders[settingsState.selectedElement.index]
            if slider then
                if inputManager.isActionPressedForMenu("left") then
                    slider:setValue(slider.value - (0.05 * dt * 30))
                elseif inputManager.isActionPressedForMenu("right") then
                    slider:setValue(slider.value + (0.05 * dt * 30))
                end
            end
        end

        local selectedChanged = false

        if inputManager.isActionJustPressed("up") then
            if settingsState.selectedElement.type == "slider" then
                if settingsState.selectedElement.index == 2 then
                    settingsState.selectedElement.index = 1
                    selectedChanged = true
                elseif settingsState.selectedElement.index == 1 then
                    settingsState.selectedElement = {type = "button", index = 6}
                    selectedChanged = true
                end
            elseif settingsState.selectedElement.type == "button" then
                if settingsState.selectedElement.index == 1 then
                    settingsState.selectedElement = {type = "slider", index = 2}
                    selectedChanged = true
                elseif settingsState.selectedElement.index == 2 then
                    settingsState.selectedElement.index = 1
                    selectedChanged = true
                elseif settingsState.selectedElement.index == 3 then
                    settingsState.selectedElement.index = 2
                    selectedChanged = true
                elseif settingsState.selectedElement.index == 4 then
                    settingsState.selectedElement.index = 3
                    selectedChanged = true
                elseif settingsState.selectedElement.index == 5 then
                    settingsState.selectedElement.index = 4
                    selectedChanged = true
                elseif settingsState.selectedElement.index == 6 then
                    settingsState.selectedElement.index = 4
                    selectedChanged = true
                end
            end

        elseif inputManager.isActionJustPressed("down") then
            if settingsState.selectedElement.type == "slider" then
                if settingsState.selectedElement.index == 1 then
                    settingsState.selectedElement.index = 2
                    selectedChanged = true
                elseif settingsState.selectedElement.index == 2 then
                    settingsState.selectedElement = {type = "button", index = 1}
                    selectedChanged = true
                end
            elseif settingsState.selectedElement.type == "button" then
                if settingsState.selectedElement.index == 1 then
                    settingsState.selectedElement.index = 2
                    selectedChanged = true
                elseif settingsState.selectedElement.index == 2 then
                    settingsState.selectedElement.index = 3
                    selectedChanged = true
                elseif settingsState.selectedElement.index == 3 then
                    settingsState.selectedElement.index = 4
                    selectedChanged = true
                elseif settingsState.selectedElement.index == 4 then
                    settingsState.selectedElement.index = 5
                    selectedChanged = true
                elseif settingsState.selectedElement.index == 5 then
                    settingsState.selectedElement = {type = "slider", index = 1}
                    selectedChanged = true
                elseif settingsState.selectedElement.index == 6 then
                    settingsState.selectedElement = {type = "slider", index = 1}
                    selectedChanged = true
                end
            end

        elseif inputManager.isActionJustPressed("left") then
            if settingsState.selectedElement.type == "button" then
                if settingsState.selectedElement.index == 6 then
                    settingsState.selectedElement.index = 5
                    selectedChanged = true
                end
            end

        elseif inputManager.isActionJustPressed("right") then
            if settingsState.selectedElement.type == "button" then
                if settingsState.selectedElement.index == 5 then
                    settingsState.selectedElement.index = 6
                    selectedChanged = true
                end
            end

        elseif inputManager.isActionJustPressed("select") then
            if settingsState.selectedElement.type == "button" then
                buttons[settingsState.selectedElement.index]:click()
            end
        elseif inputManager.isActionJustPressed("back") then
            triggerTransition("menu")
            soundManager.playSound("back")
        end

        if selectedChanged then
            soundManager.playSound("select")
            if settingsState.selectedElement.type == "button" then
                local targetButton = buttons[settingsState.selectedElement.index]
                if targetButton then
                    targetButton:pulse()
                end
            end
        end
    end
end

function settingsState.draw()
    bg.draw()
    love.graphics.setFont(titleFont)
    love.graphics.setColor(1, 1, 1, 1)

    local titleW = titleFont and titleFont:getWidth(settingsText) or 0
    love.graphics.print(settingsText, virtualWidth / 2 - titleW / 2,
                        GameConfig.VIRTUAL_HEIGHT * 0.01)

    for i, slider in ipairs(sliders) do
        if activePopup == "none" and settingsState.selectedElement and settingsState.selectedElement.type == "slider" and settingsState.selectedElement.index == i then
            slider.highlighted = true
        end
        slider:draw()
        slider.highlighted = false
    end

    for i, button in ipairs(buttons) do
        if activePopup == "none" and settingsState.selectedElement and settingsState.selectedElement.type == "button" and settingsState.selectedElement.index == i then
            local originalHoverColor = button.hoverColor
            button.hoverColor = GameConfig.UI.BUTTON.HOVER_COLOR
            button.hovered = true
            button:draw()
            button.hoverColor = originalHoverColor
            button.hovered = false
        else
            button:draw()
        end
    end

    if activePopup ~= "none" then
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", 0, 0, virtualWidth, virtualHeight)

        love.graphics.setColor(0, 0, 0, 0.8)
        local numRows = 6

        local frameW = (GameConfig.MENU.BUTTON_WIDTH * 15)
        local frameH = (numRows * (GameConfig.MENU.BUTTON_HEIGHT + 15)) + 45
        love.graphics.rectangle("fill", (virtualWidth / 2) - (frameW / 2), (virtualHeight / 2) - (frameH / 2), frameW, frameH, 8, 8)

        love.graphics.setColor(1, 1, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", (virtualWidth / 2) - (frameW / 2), (virtualHeight / 2) - (frameH / 2), frameW, frameH, 8, 8)
        love.graphics.setLineWidth(1)

        for i, button in ipairs(popupButtons) do
            if selectedPopupIndex == i then
                local originalHoverColor = button.hoverColor
                button.hoverColor = GameConfig.UI.BUTTON.HOVER_COLOR
                button.hovered = true
                button:draw()
                button.hoverColor = originalHoverColor
                button.hovered = false
            else
                button:draw()
            end
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end


return settingsState
