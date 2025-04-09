local Input = {}

-- Pass in a string array of key names (i.e {"up","down","left","right"})
-- Call this before Input.map
function Input.initialize(keys, gamepadButtons)
    Input.gamepadPrefix = "gamepad_"
    -- Keyboard
    keys = keys or {}
    Input.allKeys = keys
    for i,key in ipairs(keys) do
        Input[key] = {lastPressed = false, isDown = false}
    end

    -- Gamepad buttons
    gamepadButtons = gamepadButtons or {}
    Input.allGamepadButtons = gamepadButtons
    for i,key in ipairs(gamepadButtons) do
        Input[Input.gamepadPrefix..key] = {lastPressed = false, isDown = false}
    end

    -- Input will always initialize joystick axes
    Input["leftx"] = {value=0, lastValue=0}
    Input["lefty"] = {value=0, lastValue=0}

    -- Set up for mapped buttons
    Input.allMappedButtons = {}
    Input.mappings = {}

    -- Set up for controller detection
    Input.controllerIsConnected = false
    Input.controllerType = ""
end

-- Call this function to map inputs that were passed to "initialize" to specific higher-level names
-- like mapping "x" and "a" to "attack" or something.
-- inputMappings is an array of tables, each table has
-- buttonName, keyboard, gamepad
-- buttonName is a string, keyboard is an array of strings, gamepad is also an array of strings.
function Input.map(inputMappings, numInputs)
    for k = 1,numInputs do
        Input.allMappedButtons[k] = inputMappings[k].buttonName
        Input.mappings[inputMappings[k].buttonName] = {}
        Input.mappings[inputMappings[k].buttonName].keyboard = inputMappings[k].keyboard
        Input.mappings[inputMappings[k].buttonName].gamepad = inputMappings[k].gamepad
    end
end

-- Call this in your love.keypressed and love.keyreleased functions
-- also call this in love.gamepadpressed and love.gamepadreleased with the gamepadPrefix
function Input.setButtonStatus(key, status)
    if Input[key] ~= nil then
        Input[key].isDown = status
    end
end

-- Call this in your love.gamepadaxis function.
function Input.setAxisValue(axis, value)
    if Input[axis] ~= nil then
        Input[axis].value = value
    end
end

-- Call this at the end of your love.update loop
function Input.updateButtons()
    for i,key in ipairs(Input.allKeys) do
        Input[key].lastPressed = Input[key].isDown
    end
    for i,key in ipairs(Input.allGamepadButtons) do
        Input[Input.gamepadPrefix..key].lastPressed = Input[Input.gamepadPrefix..key].isDown
    end
    Input["leftx"].lastValue = Input["leftx"].value
    Input["lefty"].lastValue = Input["lefty"].value
    
    -- Also check if any controllers are connected
    if (not web or itch) and love.joystick.getJoystickCount() > 0 then
        Input.controllerIsConnected = true
        local joysticks = love.joystick.getJoysticks()
        for i, joystick in ipairs(joysticks) do
            Input.controllerType = string.find(joystick:getName(), "PS4") and "PS4" or "XBOX"
        end
    else
        Input.controllerIsConnected = false
        Input.controllerType = ""
    end
end

-- Use these functions in your actual controller code, i.e in player controller code

-- These are higher-level button press functions.
function Input.getMappedButtonPressed(button)
    return Input.getMappedButtonStatus(button, Input.getButtonPressed)
end

function Input.getMappedButtonHeld(button)
    return Input.getMappedButtonStatus(button, Input.getButtonHeld)
end

function Input.getMappedButtonReleased(button)
    return Input.getMappedButtonStatus(button, Input.getButtonReleased)
end

-- Use this to detect joystick input
function Input.getAxisValue(axis)
    if axis ~= "leftx" and axis ~= "lefty" then
        error("Axis requested does not exist. Valid axes are leftx and lefty")
    end
    return Input[axis].value
end

function Input.getAxisLastValue(axis)
    if axis ~= "leftx" and axis ~= "lefty" then
        error("Axis requested does not exist. Valid axes are leftx and lefty")
    end
    return Input[axis].lastValue
end

-- These are primitive buttonpress functions. They take in the literal string for the button (like "x" or "gamepad_dpleft")
-- Use the mapped button functions for higher-level button presses (i.e "jump", "attack", etc)
-- Returns true on the frame the button was first pressed
function Input.getButtonPressed(key)
    return Input[key].isDown and not Input[key].lastPressed
end

-- Returns true on all frames the button is held
function Input.getButtonHeld(key)
    return Input[key].isDown
end

-- Returns true on the frame the button was first released
function Input.getButtonReleased(key)
    return not Input[key].isDown and Input[key].lastPressed
end

-- Internal function for mapped button presses
function Input.getMappedButtonStatus(button, fcn)
    local mappedButton = Input.mappings[button]
    local status = false
    for i,key in ipairs(mappedButton.keyboard) do
        status = fcn(mappedButton.keyboard[i])
        if status then
            return true 
        end
    end
    for i,key in ipairs(mappedButton.gamepad) do
        status = fcn(Input.gamepadPrefix..mappedButton.gamepad[i])
        if status then
            return true
        end
    end
    return false
end

return Input