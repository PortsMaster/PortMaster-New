local gameState = require "src.states.gameState"
local GameConfig = require "src.constants.gameConfig"

local inputManager = {}
local defaultKeyBindings = GameConfig and GameConfig.DEFAULT_KEY_BINDINGS or {}
inputManager.enabled = true

inputManager.keyBindings = {
    keyboard = {},
    gamepad = {}
}

local lastKeyboardState = {}
local lastGamepadState = {}
local currentGamepad = nil
local lastMenuAction = 0
local menuRepeatDelay = GameConfig.INPUT.MENU_REPEAT_DELAY


function inputManager.setEnabled(enable)
    inputManager.enabled = enable
end

function inputManager.isEnabled()
    return inputManager.enabled
end

function inputManager.init()
    lastKeyboardState = {}
    lastGamepadState = {}

    inputManager.keyBindings = {
        keyboard = {},
        gamepad = {}
    }

    -- Populate keyboard bindings with fallbacks to defaults
    for action, key in pairs(defaultKeyBindings.keyboard) do
        if gameState.settings.keyBindings and gameState.settings.keyBindings.keyboard and gameState.settings.keyBindings.keyboard[action] then
            inputManager.keyBindings.keyboard[action] = gameState.settings.keyBindings.keyboard[action]
        else
            inputManager.keyBindings.keyboard[action] = key
        end
    end

    -- Populate gamepad bindings with fallbacks to defaults
    for action, button in pairs(defaultKeyBindings.gamepad) do
        if gameState.settings.keyBindings and gameState.settings.keyBindings.gamepad and gameState.settings.keyBindings.gamepad[action] then
            inputManager.keyBindings.gamepad[action] = gameState.settings.keyBindings.gamepad[action]
        else
            inputManager.keyBindings.gamepad[action] = button
        end
    end

    gameState.settings.keyBindings = inputManager.keyBindings
    gameState.save()

    if love.joystick then
        local joysticks = love.joystick.getJoysticks()
        for _, j in ipairs(joysticks) do
            if j:isGamepad() then
                currentGamepad = j
                break
            end
        end

        if not currentGamepad and #joysticks > 0 then
            currentGamepad = joysticks[1]
        end
    end
end

function inputManager.update(dt)
    if lastMenuAction > 0 then
        lastMenuAction = lastMenuAction - dt
    end
end

function inputManager.isActionDown(action)
    if not inputManager.enabled then return false end
    local keyboardBinding = inputManager.keyBindings.keyboard[action]
    if keyboardBinding and love.keyboard.isDown(keyboardBinding) then
        return true
    end

    if currentGamepad then
        local gamepadBinding = inputManager.keyBindings.gamepad[action]
        if gamepadBinding then
            if gamepadBinding:sub(1, 2) == "dp" then
                return currentGamepad:isGamepadDown(gamepadBinding)
            elseif gamepadBinding == "leftstick_up" then
                return currentGamepad:getGamepadAxis("lefty") < -GameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            elseif gamepadBinding == "leftstick_down" then
                return currentGamepad:getGamepadAxis("lefty") > GameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            elseif gamepadBinding == "leftstick_left" then
                return currentGamepad:getGamepadAxis("leftx") < -GameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            elseif gamepadBinding == "leftstick_right" then
                return currentGamepad:getGamepadAxis("leftx") > GameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            else
                return currentGamepad:isGamepadDown(gamepadBinding)
            end
        end
    end

    return false
end

function inputManager.isActionJustPressed(action)
    if not inputManager.enabled then return false end
    
    local keyboardBinding = inputManager.keyBindings.keyboard[action]
    if keyboardBinding and love.keyboard.isDown(keyboardBinding) and not lastKeyboardState[action] then
        lastKeyboardState[action] = true
        return true
    elseif keyboardBinding and not love.keyboard.isDown(keyboardBinding) then
        lastKeyboardState[action] = false
    end

    if currentGamepad then
        local gamepadBinding = inputManager.keyBindings.gamepad[action]
        if gamepadBinding then
            local isDown = false

            if gamepadBinding:sub(1, 2) == "dp" then
                isDown = currentGamepad:isGamepadDown(gamepadBinding)
            elseif gamepadBinding == "leftstick_up" then
                isDown = currentGamepad:getGamepadAxis("lefty") < -GameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            elseif gamepadBinding == "leftstick_down" then
                isDown = currentGamepad:getGamepadAxis("lefty") > GameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            elseif gamepadBinding == "leftstick_left" then
                isDown = currentGamepad:getGamepadAxis("leftx") < -GameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            elseif gamepadBinding == "leftstick_right" then
                isDown = currentGamepad:getGamepadAxis("leftx") > GameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            else
                isDown = currentGamepad:isGamepadDown(gamepadBinding)
            end

            if isDown and not lastGamepadState[action] then
                lastGamepadState[action] = true
                return true
            elseif not isDown then
                lastGamepadState[action] = false
            end
        end
    end

    return false
end

function inputManager.isActionPressedForMenu(action)
    if not inputManager.enabled then return false end
    local isPressed = false

    local keyboardBinding = inputManager.keyBindings.keyboard[action]
    if keyboardBinding and love.keyboard.isDown(keyboardBinding) then
        isPressed = true
    end

    if not isPressed and currentGamepad then
        local gamepadBinding = inputManager.keyBindings.gamepad[action]
        if gamepadBinding then
            if gamepadBinding:sub(1, 2) == "dp" then
                isPressed = currentGamepad:isGamepadDown(gamepadBinding)
            elseif gamepadBinding == "leftstick_up" then
                isPressed = currentGamepad:getGamepadAxis("lefty") < -GameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            elseif gamepadBinding == "leftstick_down" then
                isPressed = currentGamepad:getGamepadAxis("lefty") > GameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            elseif gamepadBinding == "leftstick_left" then
                isPressed = currentGamepad:getGamepadAxis("leftx") < -GameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            elseif gamepadBinding == "leftstick_right" then
                isPressed = currentGamepad:getGamepadAxis("leftx") > GameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            else
                isPressed = currentGamepad:isGamepadDown(gamepadBinding)
            end
        end
    end

    if isPressed and lastMenuAction <= 0 then
        lastMenuAction = menuRepeatDelay
        return true
    end

    return false
end

function inputManager.isGamepadConnected()
    return currentGamepad ~= nil
end

function inputManager.getBindingText(device, action)
    if not inputManager.keyBindings[device] then
        return "Not Set"
    end

    local binding = inputManager.keyBindings[device][action]
    if not binding then
        return "Not Set"
    end

    if device == "gamepad" then
        if binding == "dpup" then return "DPad Up"
        elseif binding == "dpdown" then return "DPad Down"
        elseif binding == "dpleft" then return "DPad Left"
        elseif binding == "dpright" then return "DPad Right"
        elseif binding == "a" then return "A"
        elseif binding == "b" then return "B"
        elseif binding == "x" then return "X"
        elseif binding == "y" then return "Y"
        elseif binding:sub(1, 9) == "leftstick" then
            return "Left Stick " .. binding:sub(11):upper()
        else
            return binding:sub(1,1):upper() .. binding:sub(2)
        end
    elseif device == "keyboard" then
        if binding == "return" then return "Enter"
        elseif binding == "space" then return "Space"
        else
            return binding:sub(1,1):upper() .. binding:sub(2)
        end
    end

    return "Not Set"
end

function inputManager.setBinding(device, action, newBinding)
    if not inputManager.keyBindings[device] then
        inputManager.keyBindings[device] = {}
    end
    inputManager.keyBindings[device][action] = newBinding
    gameState.settings.keyBindings = inputManager.keyBindings
    gameState.save()
end

function inputManager.resetToDefaults()
    inputManager.keyBindings = {
        keyboard = {},
        gamepad = {}
    }

    for action, key in pairs(defaultKeyBindings.keyboard) do
        inputManager.keyBindings.keyboard[action] = key
    end

    for action, button in pairs(defaultKeyBindings.gamepad) do
        inputManager.keyBindings.gamepad[action] = button
    end

    gameState.settings.keyBindings = inputManager.keyBindings
    gameState.save()

    return inputManager.keyBindings
end

function love.joystickadded(joystick)
    if joystick:isGamepad() then
        if not currentGamepad or not currentGamepad:isGamepad() then
            currentGamepad = joystick
        end
    end
end

function love.joystickremoved(joystick)
    if currentGamepad == joystick then
        currentGamepad = nil

        local joysticks = love.joystick.getJoysticks()
        if #joysticks > 0 then
            currentGamepad = joysticks[1]
        end
    end
end

return inputManager
