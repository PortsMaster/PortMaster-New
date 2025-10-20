-- Input manager for Max Payne launcher
local input = {}

-- Input repeat state
local axisRepeat = {
    x = 0,
    y = 0,
    t = 0,
    repeatDelay = 0.35,
    repeatRate = 0.08
}

local keyRepeat = {
    left = {
        held = false,
        timer = 0
    },
    right = {
        held = false,
        timer = 0
    },
    up = {
        held = false,
        timer = 0
    },
    down = {
        held = false,
        timer = 0
    },
    repeatDelay = 0.35,
    repeatRate = 0.08
}

local gamepadRepeat = {
    dpleft = {
        held = false,
        timer = 0
    },
    dpright = {
        held = false,
        timer = 0
    },
    dpup = {
        held = false,
        timer = 0
    },
    dpdown = {
        held = false,
        timer = 0
    },
    repeatDelay = 0.35,
    repeatRate = 0.08
}

-- Callbacks (to be set by main)
local callbacks = {
    moveSel = nil,
    adjustValue = nil,
    launchGame = nil,
    enterSettings = nil,
    enterControls = nil,
    exitApp = nil,
    saveAndExit = nil,
    toggleValue = nil,
    saveConfig = nil,
    loadConfig = nil,
    returnDefaultConfigs = nil,
    enterEdit = nil,
    exitEdit = nil
}

-- Handle analog stick repeat
local function handleAxis(dt, ui, order)
    axisRepeat.t = axisRepeat.t + dt
    local joysticks = love.joystick.getJoysticks()
    local j = joysticks[1]
    if not j then
        return
    end

    local lx = j:getGamepadAxis("leftx") or 0
    local ly = j:getGamepadAxis("lefty") or 0
    local dead = 0.35

    local function repeatLogic(axis, val, onNeg, onPos)
        if math.abs(val) < dead then
            axisRepeat[axis] = 0
            return
        end
        local dir = (val > 0) and 1 or -1
        if axisRepeat[axis] == 0 then
            axisRepeat[axis] = axisRepeat.t + axisRepeat.repeatDelay
            if dir < 0 then
                onNeg()
            else
                onPos()
            end
        elseif axisRepeat.t >= axisRepeat[axis] then
            axisRepeat[axis] = axisRepeat.t + axisRepeat.repeatRate
            if dir < 0 then
                onNeg()
            else
                onPos()
            end
        end
    end

    if ui.mode == "config" then
        repeatLogic('x', lx, function()
            if callbacks.adjustValue then
                callbacks.adjustValue(order[ui.sel], -1)
            end
        end, function()
            if callbacks.adjustValue then
                callbacks.adjustValue(order[ui.sel], 1)
            end
        end)
    end
    repeatLogic('y', ly, function()
        if callbacks.moveSel then
            callbacks.moveSel(-1)
        end
    end, function()
        if callbacks.moveSel then
            callbacks.moveSel(1)
        end
    end)
end

-- Handle keyboard repeat
local function handleKeyRepeat(dt, ui, order)
    for keyName, keyData in pairs(keyRepeat) do
        if keyName ~= "repeatDelay" and keyName ~= "repeatRate" and keyData.held then
            keyData.timer = keyData.timer + dt
            if keyData.timer >= keyRepeat.repeatDelay then
                keyData.timer = keyData.timer - keyRepeat.repeatRate

                if keyName == "left" and ui.mode == "config" then
                    if callbacks.adjustValue then
                        callbacks.adjustValue(order[ui.sel], -1)
                    end
                elseif keyName == "right" and ui.mode == "config" then
                    if callbacks.adjustValue then
                        callbacks.adjustValue(order[ui.sel], 1)
                    end
                elseif keyName == "up" then
                    if callbacks.moveSel then
                        callbacks.moveSel(-1)
                    end
                elseif keyName == "down" then
                    if callbacks.moveSel then
                        callbacks.moveSel(1)
                    end
                end
            end
        end
    end
end

-- Handle gamepad repeat
local function handleGamepadRepeat(dt, ui, order)
    for buttonName, buttonData in pairs(gamepadRepeat) do
        if buttonName ~= "repeatDelay" and buttonName ~= "repeatRate" and buttonData.held then
            buttonData.timer = buttonData.timer + dt
            if buttonData.timer >= gamepadRepeat.repeatDelay then
                buttonData.timer = buttonData.timer - gamepadRepeat.repeatRate

                if buttonName == "dpleft" and ui.mode == "config" then
                    if callbacks.adjustValue then
                        callbacks.adjustValue(order[ui.sel], -1)
                    end
                elseif buttonName == "dpright" and ui.mode == "config" then
                    if callbacks.adjustValue then
                        callbacks.adjustValue(order[ui.sel], 1)
                    end
                elseif buttonName == "dpup" then
                    if callbacks.moveSel then
                        callbacks.moveSel(-1)
                    end
                elseif buttonName == "dpdown" then
                    if callbacks.moveSel then
                        callbacks.moveSel(1)
                    end
                end
            end
        end
    end
end

-- Public API
function input.setCallbacks(newCallbacks)
    for key, callback in pairs(newCallbacks) do
        callbacks[key] = callback
    end
end

function input.update(dt, ui, order)
    handleAxis(dt, ui, order)
    handleKeyRepeat(dt, ui, order)
    handleGamepadRepeat(dt, ui, order)
end

function input.gamepadPressed(joy, button, ui, launcherOptions)
    if button == "dpup" or button == "dpdown" or button == "dpleft" or button == "dpright" then
        if gamepadRepeat[button] then
            gamepadRepeat[button].held = true
            gamepadRepeat[button].timer = 0
        end
    end

    if ui.mode == "launcher" then
        if button == "dpup" then
            if callbacks.moveSel then
                callbacks.moveSel(-1)
            end
        elseif button == "dpdown" then
            if callbacks.moveSel then
                callbacks.moveSel(1)
            end
        elseif button == "a" then
            if ui.sel == 1 then
                if callbacks.launchGame then
                    callbacks.launchGame()
                end
            elseif ui.sel == 2 then
                if callbacks.enterSettings then
                    callbacks.enterSettings()
                end
            elseif ui.sel == 3 then
                if callbacks.enterControls then
                    callbacks.enterControls()
                end
            end
        elseif button == "b" or button == "back" then
            if callbacks.exitApp then
                callbacks.exitApp()
            end
        end
        return
    end

    if ui.edit then
        -- Handle virtual keyboard navigation (simplified for now)
        if button == "b" or button == "back" then
            if callbacks.exitEdit then
                callbacks.exitEdit()
            end
        elseif button == "start" then
            if callbacks.exitEdit then
                callbacks.exitEdit()
            end
        end
        return
    end

    -- Config mode
    if button == "dpup" then
        if callbacks.moveSel then
            callbacks.moveSel(-1)
        end
    elseif button == "dpdown" then
        if callbacks.moveSel then
            callbacks.moveSel(1)
        end
    elseif button == "dpleft" then
        if callbacks.adjustValue then
            callbacks.adjustValue(ui.order[ui.sel], -1)
        end
    elseif button == "dpright" then
        if callbacks.adjustValue then
            callbacks.adjustValue(ui.order[ui.sel], 1)
        end
    elseif button == "a" then
        if callbacks.toggleValue then
            callbacks.toggleValue(ui.order[ui.sel])
        end
    elseif button == "y" then
        if callbacks.loadConfig then
            callbacks.loadConfig()
        end
    elseif button == "x" then
        if callbacks.returnDefaultConfigs then
            callbacks.returnDefaultConfigs()
        end
    elseif button == "start" then
        if callbacks.saveConfig then
            callbacks.saveConfig()
        end
    elseif button == "back" or button == "b" then
        if callbacks.saveAndExit then
            callbacks.saveAndExit()
        end
    end
end

function input.gamepadReleased(joy, button)
    if button == "dpup" or button == "dpdown" or button == "dpleft" or button == "dpright" then
        if gamepadRepeat[button] then
            gamepadRepeat[button].held = false
            gamepadRepeat[button].timer = 0
        end
    end
end

function input.keyPressed(key, ui, launcherOptions)
    if key == "up" or key == "down" or key == "left" or key == "right" then
        if keyRepeat[key] then
            keyRepeat[key].held = true
            keyRepeat[key].timer = 0
        end
    end

    if ui.mode == "launcher" then
        if key == "up" then
            if callbacks.moveSel then
                callbacks.moveSel(-1)
            end
        elseif key == "down" then
            if callbacks.moveSel then
                callbacks.moveSel(1)
            end
        elseif key == "return" or key == "space" then
            if ui.sel == 1 then
                if callbacks.launchGame then
                    callbacks.launchGame()
                end
            elseif ui.sel == 2 then
                if callbacks.enterSettings then
                    callbacks.enterSettings()
                end
            elseif ui.sel == 3 then
                if callbacks.enterControls then
                    callbacks.enterControls()
                end
            end
        elseif key == "escape" then
            if callbacks.exitApp then
                callbacks.exitApp()
            end
        end
        return
    end

    -- Config mode
    if key == "up" then
        if callbacks.moveSel then
            callbacks.moveSel(-1)
        end
    elseif key == "down" then
        if callbacks.moveSel then
            callbacks.moveSel(1)
        end
    elseif key == "left" then
        if callbacks.adjustValue then
            callbacks.adjustValue(ui.order[ui.sel], -1)
        end
    elseif key == "right" then
        if callbacks.adjustValue then
            callbacks.adjustValue(ui.order[ui.sel], 1)
        end
    elseif key == "return" or key == "space" then
        if callbacks.toggleValue then
            callbacks.toggleValue(ui.order[ui.sel])
        end
    elseif key == "escape" then
        if callbacks.saveAndExit then
            callbacks.saveAndExit()
        end
    elseif key == "s" then
        if callbacks.saveConfig then
            callbacks.saveConfig()
        end
    elseif key == "r" then
        if callbacks.loadConfig then
            callbacks.loadConfig()
        end
    elseif key == "e" and ui.order and ui.order[ui.sel] == "mod_file" then
        if callbacks.enterEdit then
            callbacks.enterEdit()
        end
    end
end

function input.keyReleased(key)
    if key == "up" or key == "down" or key == "left" or key == "right" then
        if keyRepeat[key] then
            keyRepeat[key].held = false
            keyRepeat[key].timer = 0
        end
    end
end

return input
