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
    Input["rightx"] = {value=0, lastValue=0}
    Input["righty"] = {value=0, lastValue=0}

    -- Input will always initialize the mouse
    Input["mouse1"] = {lastPressed = false, isDown = false}
    Input["mouse2"] = {lastPressed = false, isDown = false}

    -- Set up for mapped buttons
    Input.allMappedButtons = {}
    Input.mappings = {}

    -- Set up for controller detection
    Input.controllerIsConnected = true
    Input.controllerType = ""
    Input.numJoysticksConnected = 0
    Input.activelyUsingController = true
    -- Set up for caching the last input series
    Input.currentConfig = {}
    Input.defaultConfig = {}
    Input.numInConfig = 0
    Input.lastKeyPressed = nil
    Input.lastGamepadPressed = nil
    -- Set up button aliases for alternate controllers
    Input.aliases = {
        PS4 = {
            a="x",
            b="circle",
            y="triangle",
            x="square",
            leftshoulder="L1",
            rightshoulder="R1"
        }
    }
end

-- Call this function to check if a key exists in our overall list of keys
function Input.isKeyMapped(keyname, isGamepad)
    local buttons = isGamepad and Input.allGamepadButtons or Input.allKeys
    for k = 1,#buttons do
        if buttons[k] == keyname then
            return true
        end
    end
    return false
end

function Input.addKeyMapping(keyname, isGamepad)
    local buttonStr = "allKeys"
    if isGamepad then
        keyname = keyname
        buttonStr = "allGamepadButtons"
    end
    Input[keyname] = {lastPressed = false, isDown = false}
    table.insert(Input[buttonStr], keyname)
end

-- Call this function to map inputs that were passed to "initialize" to specific higher-level names
-- like mapping "x" and "a" to "attack" or something.
-- inputMappings is an array of tables, each table has
-- buttonName, keyboard, gamepad
-- buttonName is a string, keyboard is an array of strings, gamepad is also an array of strings.
function Input.map(inputMappings, isDefault)
    for k = 1,#inputMappings do
        Input.allMappedButtons[k] = inputMappings[k].buttonName
        Input.mappings[inputMappings[k].buttonName] = {}
        Input.mappings[inputMappings[k].buttonName].keyboard = inputMappings[k].keyboard
        Input.mappings[inputMappings[k].buttonName].gamepad = inputMappings[k].gamepad
    end
    if isDefault then
        Input.defaultConfig = inputMappings
    end
    Input.currentConfig = inputMappings
    Input.numInConfig = #inputMappings
end

function Input.remap(buttonName, keyboard, gamepad)
    if keyboard then
        Input.mappings[buttonName].keyboard = {keyboard}
    elseif gamepad then
        Input.mappings[buttonName].gamepad = {gamepad}
    end
end

function Input.getControlString(buttonName, isGamepad)
    if isGamepad then
        local controlString = Input.mappings[buttonName].gamepad[1]
        if Input.controllerType == "PS4" then
            if Input.aliases.PS4[controlString] then
                controlString = Input.aliases.PS4[controlString]
            end
        end
        return controlString
    else
        return Input.mappings[buttonName].keyboard[1]
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
    Input["mouse1"].lastPressed = Input["mouse1"].isDown
    Input["mouse2"].lastPressed = Input["mouse2"].isDown
    Input["leftx"].lastValue = Input["leftx"].value
    Input["lefty"].lastValue = Input["lefty"].value
    Input["rightx"].lastValue = Input["rightx"].value
    Input["righty"].lastValue = Input["righty"].value
    
    -- Also check if any controllers are connected
    if (not web or itch) and Input.numJoysticksConnected > 0 then
        Input.controllerIsConnected = true
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
    if axis ~= "leftx" and axis ~= "lefty" and axis ~= "rightx" and axis ~= "righty" then
        error("Axis requested does not exist. Valid axes are leftx, lefty, rightx, and righty")
    end
    return Input[axis].value
end

function Input.getAxisLastValue(axis)
    if axis ~= "leftx" and axis ~= "lefty" and axis ~= "rightx" and axis ~= "righty" then
        error("Axis requested does not exist. Valid axes are leftx, lefty, rightx, and righty")
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

-- useful if you're doing an operation in between a key press
-- like launching the pause menu without the pause button i.e at the main menu
function Input.clearMappedButtonStatus(button)
    local mappedButton = Input.mappings[button]
    for i,key in ipairs(mappedButton.keyboard) do
        Input[mappedButton.keyboard[i]].isDown = false
        Input[mappedButton.keyboard[i]].lastPressed = false
    end
    for i,key in ipairs(mappedButton.gamepad) do
        Input[Input.gamepadPrefix..mappedButton.gamepad[i]].isDown = false
        Input[Input.gamepadPrefix..mappedButton.gamepad[i]].lastPressed = false
    end
end

-- update these functions depending on your 'move' input names
function leftInputHeld()
    return Input.getMappedButtonHeld("moveleft") or Input.getAxisValue("leftx") < -0.2
end

function rightInputHeld()
    return Input.getMappedButtonHeld("moveright") or Input.getAxisValue("leftx") > 0.2
end

function upInputHeld()
    return Input.getMappedButtonHeld("moveup") or Input.getAxisValue("lefty") < -0.2
end

function downInputHeld()
    return Input.getMappedButtonHeld("movedown") or Input.getAxisValue("lefty") > 0.2
end

return Input
