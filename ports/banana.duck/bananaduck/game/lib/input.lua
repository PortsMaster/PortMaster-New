local Input = {
    actions = {},
    
    kpressed = {},
    kreleased = {},
    kdown = {},
    tinput = '',
    klastpressed = nil,
    klastreleased = nil,
    
    mpressed = {},
    mreleased = {},
    mdown = {},
    mmovement = {0, 0},
    mposition = {0, 0},
    mwheel = {0, 0},
    mlastpressed = nil,
    mlastreleased = nil,

    gamepads = {},
    gamepadsAdded = {},
    gamepadsRemoved = {},
    gpressed = {},
    greleased = {},
    gdown = {},
    gaxis = {},
    deadzone = 0.03,
    glastpressed = {},
    glastreleased = {},
    isWeb = love.system.getOS() == 'Web',
}

--  ##ROADMAP##
-- [x] Keyboard support (held, pressed, released)
-- [x] Mouse support (held, pressed, released, wheel, movement)
-- [x] (?) Gamepad support (I don't have a physical controller to fully test it myself)
-- [x] actions (working fine)
-- [+] Config (save, load)
-- [ ] Sequences/Cheats/Combos/Shortcuts
-- [ ] Touch (and related functions)
-- [ ] Swipe

-- TODO
-- [+] last key pressed/released (useful for making custom user-defined controls)
-- [+] Gamepad/Device vibration


------- Basic Functionality -------
-- KEYBOARD
---
---Checks if a keyboard key is just pressed.
---
---@param key string
---@return boolean
function Input.keyPressed(key)
    return Input.kpressed[key]
end

---
---Checks if a keyboard key is just released.
---
---@param key string
---@return boolean
function Input.keyReleased(key)
    return Input.kreleased[key]
end

---
---Checks if a keyboard key is down.
---
---@param key string
---@return boolean
function Input.key(key)
    return Input.kdown[key]
end

---
---Checks if any keyboard key is down.
---
---@return boolean
function Input.anyKey()
    for key, value in pairs(Input.kdown) do
        return true
    end
    return false
end

---
---Checks if any keyboard key is just pressed.
---
---@return boolean
function Input.anyKeyPressed()
    for key, value in pairs(Input.kpressed) do
        return true
    end
    return false
end

---
---Checks if any keyboard key is just released.
---
---@return boolean
function Input.anyKeyReleased()
    for key, value in pairs(Input.kreleased) do
        return true
    end
    return false
end

---
---Returns the last text input.
---It returns an empty string ('') if no text input is present.
---
---@return string
function Input.textInput()
    return Input.tinput
end

---
---Returns the last keyboard key pressed.
---It returns nil if no key is pressed.
---
---@return string
function Input.lastKeyPressed()
    return Input.klastpressed
end

---
---Returns the last keyboard key released.
---It returns nil if no key is released.
---
---@return string
function Input.lastKeyReleased()
    return Input.klastreleased
end


-- MOUSE

--- 
---Checks if a mouse button is just pressed.
---
---@param button string
---@return boolean
function Input.mousePressed(button)
    if Input.mpressed[button] then
        return unpack(Input.mpressed[button])
    end
    return false
end

---
---Checks if a mouse button is just released.
---
---@param button string
---@return boolean
function Input.mouseReleased(button)
    if Input.mreleased[button] then
        return unpack(Input.mreleased[button])
    end
    return false
end

---
---Checks if a mouse button is down.
---
---@param button string
---@return boolean
function Input.mouse(button)
    return Input.mdown[button]
end

---
---Returns the mouse movement since the last frame.
---
---@return number, number
function Input.mouseMovement()
    return unpack(Input.mmovement)
end


---
---Checks if the mouse has moved since the last frame.
---
---@return boolean
function Input.mouseMoved()
    return Input.mmovement[1] ~= 0 or Input.mmovement[2] ~= 0
end

---
---Returns the mouse wheel movement since the last frame.
---
---@return number, number
function Input.mouseWheel()
    return Input.mwheel[1], Input.mwheel[2]
end

---
---Returns the mouse wheel vertical movement since the last frame.
---
---@return number
function Input.mouseWheelVertical()
    return Input.mwheel[2]
end

---
---Returns the mouse wheel horizontal movement since the last frame.
---
---@return number
function Input.mouseWheelHorizontal()
    return Input.mwheel[1]
end

---
---Checks if the mouse wheel is going up.
---
---@return boolean
function Input.mouseWheelUp(deadzone)
    return Input.mwheel[2] > (deadzone or 0)
end

---
---Checks if the mouse wheel is going down.
---
---@return boolean
function Input.mouseWheelDown(deadzone)
    return Input.mwheel[2] < (deadzone or 0)
end

---
---Checks if the mouse wheel is going right.
---
---@return boolean
function Input.mouseWheelRight(deadzone)
    return Input.mwheel[1] > (deadzone or 0)
end

---
---Checks if the mouse wheel is going left.
---
---@return boolean
function Input.mouseWheelLeft(deadzone)
    return Input.mwheel[1] < (deadzone or 0)
end

---
---Checks if any mouse button is down.
---
---@return boolean
function Input.anyMouse()
    for key, value in pairs(Input.mdown) do
        return true
    end

    if Input.mwheel[1] ~= 0 or Input.mwheel[2] ~= 0 then
        return true
    end

    if Input.mouseMoved() then
        return true
    end

    return false
end

---
---Checks if any mouse button is just pressed.
---
---@return boolean
function Input.anyMousePressed()
    for key, value in pairs(Input.mpressed) do
        return true
    end
    return false
end

---
---Checks if any mouse button is just released.
---
---@return boolean
function Input.anyMouseReleased()
    for key, value in pairs(Input.mreleased) do
        return true
    end
    return false
end

---
---Returns the mouse position.
---
---@return number, number
function Input.getMousePosition()
    return Input.mposition[1], Input.mposition[2]
end



---
---Returns the last mouse key pressed (nil if none).
---
---@return number
function Input.lastMousePressed()
    return Input.mlastpressed
end


---
---Returns the last mouse key released (nil if none).
---
---@return number
function Input.lastMouseReleased()
    return Input.mlastreleased
end


-- GAMEPAD

---
---* `Input.gamepadAdded()`:Returns a table of the newly connected gamepads.
---* `Input.gamepadAdded(index)`: Check if a specific gamepad is just added.
---
---@overload fun():table
---@param index number
---@return boolean
function Input.gamepadAdded(index)
    if index then
        return Input.gamepadsAdded[index]
    end

    return Input.gamepadsAdded
end

Input.gamepadAdded()

---
---* `Input.gamepadRemoved()`:Returns a table of the newly disconnected gamepads.
---* `Input.gamepadRemoved(index)`: Check if a specific gamepad is just removed.
---
---@overload fun():table
---@param index number
---@return boolean
function Input.gamepadRemoved(index)
    if index then
        return Input.gamepadsRemoved[index]
    end

    return Input.gamepadsRemoved
end

---
---Returns a table with all the connected gamepads.
---
---@return table
function Input.getGamepads()
    return Input.gamepads
end

---
---Returns a specific gamepad.
---
---@param id number
function Input.getGamepad(id)
    return Input.gamepads[id]
end

---
---Checks if a gamepad is connected.
---
---@param id number
function Input.gamepadIsConnected(id)
    if Input.gamepads[id] then
        return true
    end
    return false
end

---
---* `Input.gamepad(button)`:Checks if a button is down on all gamepads.
---* `Input.gamepad(button, id)`: Checks if a button is down on a specific gamepad.
---
---@overload fun(button:string):boolean
---@overload fun(button:string, nil):boolean
---@param button string
---@param id number
---@return boolean
function Input.gamepad(button, id)
    if id then
        if Input.gamepadIsConnected(id) then
            return Input.gdown[id][button]
        end
    else
        for id, _ in pairs(Input.gamepads) do
            if Input.gdown[id][button] then
                return true
            end
        end
    end
    return false
end


---
---* `Input.gamepadPressed(button)`:Checks if a button is just pressed on all gamepads.
---* `Input.gamepadPressed(button, id)`: Checks if a button is just pressed on a specific gamepad.
---
---@overload fun(button:string):boolean
---@overload fun(button:string, nil):boolean
---@param button string
---@param id number
---@return boolean
function Input.gamepadPressed(button, id)
    if id then
        if Input.gamepadIsConnected(id) then
            return Input.gpressed[id][button]
        end
    else
        for id, _ in pairs(Input.gamepads) do
            if Input.gpressed[id][button] then
                return true
            end
        end
    end
    return false
end

---
---* `Input.gamepadReleased(button)`:Checks if a button is just released on all gamepads.
---* `Input.gamepadReleased(button, id)`: Checks if a button is just released on a specific gamepad.
---
---@overload fun(button:string):boolean
---@overload fun(button:string, nil):boolean
---@param button string
---@param id number
function Input.gamepadReleased(button, id)
    if id then
        if Input.gamepadIsConnected(id) then
            return Input.greleased[id][button]
        end
    else
        for id, _ in pairs(Input.gamepads) do
            if Input.greleased[id][button] then
                return true
            end
        end
    end
    return false
end

---
---* `Input.gamepadAxis(axis)`:Gets the value of a gamepad axis on all gamepads.
---* `Input.gamepadAxis(axis, id)`: Gets the value of a gamepad axis on a specific gamepad.
---
---@overload fun(axis:string):number
---@overload fun(axis:string, nil):number
---@param axis string
---@param id number
function Input.gamepadAxis(axis, id, deadzone)
    local r
    deadzone = deadzone or Input.deadzone
    if id then
        if Input.gamepadIsConnected(id) then
            r = Input.gaxis[id][axis] or 0
            if r > deadzone then
                return r
            elseif r < -deadzone then
                return r
            else
                return 0
            end
        end
    else
        for id, _ in pairs(Input.gamepads) do
            r = Input.gaxis[id][axis] or 0
            if r > deadzone then
                return r
            elseif r < -deadzone then
                return r
            end
        end
    end
    return 0
end

---
---* `Input.gamepadAxisRaw(axis)`:Gets the raw value (-1, 0, or 1) of a gamepad axis on all gamepads.
---* `Input.gamepadAxisRaw(axis, id)`: Gets the raw value (-1, 0, or 1) of a gamepad axis on a specific gamepad.
---
---@overload fun(axis:string):number
---@overload fun(axis:string, nil):number
---@param axis string
---@param id number
function Input.gamepadAxisRaw(axis, id, deadzone)
    local r
    deadzone = deadzone or Input.deadzone
    if id then
        if Input.gamepadIsConnected(id) then
            r = Input.gaxis[id][axis] or 0
            if r > Input.deadzone then
                return 1
            elseif r < -deadzone then
                return -1
            else
                return 0
            end
        end
    else
        for id, _ in pairs(Input.gamepads) do
            r = Input.gaxis[id][axis] or 0
            if r > deadzone then
                return 1
            elseif r < -deadzone then
                return -1
            end
        end
    end
    return 0
end


---
---* `Input.anyGamepad()`: Checks if any gamepad button is down on all gamepads.
---* `Input.anyGamepad(id)`: Checks if any gamepad button is down on a specific gamepad.
---
---@overload fun():boolean
---@overload fun(nil):boolean
---@param id number
---@return boolean, number
function Input.anyGamepad(id)
    if id then
        if Input.gamepadIsConnected(id) then
            for _,_ in Input.gdown[id] do
                return true, id
            end
        end
    end
    
    for id, _ in pairs(Input.gamepads) do
        for _,_ in pairs(Input.gdown[id]) do
            return true, id
        end
    end
    return false
end

---
---* `Input.anyGamepadPressed()`: Checks if any gamepad button is just pressed on all gamepads.
---* `Input.anyGamepadPressed(id)`: Checks if any gamepad button is just pressed on a specific gamepad.
---
---@overload fun():boolean
---@param id number
---@return boolean, number
function Input.anyGamepadPressed(id)
    if id then
        if Input.gamepadIsConnected(id) then
            for _,_ in Input.gpressed[id] do
                return true, id
            end
        end
    end
    
    for id, _ in pairs(Input.gamepads) do
        for _,_ in pairs(Input.gpressed[id]) do
            return true, id
        end
    end
    return false
end

---
---* `Input.anyGamepadReleased()`: Checks if any gamepad button is just released on all gamepads.
---* `Input.anyGamepadReleased(id)`: Checks if any gamepad button is just released on a specific gamepad.
---
---@overload fun():boolean
---@param id number
---@return boolean, number
function Input.anyGamepadReleased(id)
    if id then
        if Input.gamepadIsConnected(id) then
            for _,_ in Input.greleased[id] do
                return true, id
            end
        end
    end
    
    for id, _ in pairs(Input.gamepads) do
        for _,_ in pairs(Input.greleased[id]) do
            return true, id
        end
    end
    return false
end

---
---Sets the default deadzone for gamepad axis.
---
---@param deadzone number
function Input.setGamepadDeadzone(deadzone)
    Input.deadzone = deadzone
end


---
---Gets the last gamepad pressed (nil if none).
---Returns the button and the gamepad id.
---
---@overload fun(id):nil, nil
---@param id number (optional)
---@return string, number
function Input.lastGamepadPressed(id)
    if id then
        return Input.glastpressed[id], id
    else
        for gamepad, value in pairs(Input.glastpressed) do
            return value, gamepad
        end
    end

    return nil, nil
end

---
---Gets the last gamepad released (nil if none).
---Returns the button and the gamepad id.
---
---@overload fun(id):nil, nil
---@param id number (optional)
---@return string, number
function Input.lastGamepadReleased(id)
    if id then
        return Input.glastreleased[id], id
    else
        for gamepad, value in pairs(Input.glastreleased) do
            return value, gamepad
        end
    end

    return nil, nil
end


-- GENERAL

---
---Checks if any (mouse, keyboard, gamepad) is down.
---
---@return boolean
function Input.any()
    return Input.anyKey() or Input.anyMouse() or Input.anyGamepad()
end

---
---Checks if any (mouse, keyboard, gamepad) is just pressed.
---
---@return boolean
function Input.anyPressed()
    return Input.anyKeyPressed() or Input.anyMousePressed() or Input.anyGamepadPressed()
end

---
---Checks if any (mouse, keyboard, gamepad) is just released.
---
---@return boolean
function Input.anyReleased()
    return Input.anyKeyReleased() or Input.anyMouseReleased() or Input.anyGamepadReleased()
end

---
---Vibrates the gamepad(s) if possible.
---
---@overload fun(right, left, duration):boolean
---@overload fun(right, left):boolean
---@param right number
---@param left number
---@param duration number
---@param id number (optional)
---@return boolean
function Input.gamepadVibrate(right, left, duration, id)
    if id then
        return Input.gamepads[id]:setVibration(right, left, duration)
    else
        for key, gamepad in pairs(Input.gamepads) do
            return gamepad:setVibration(right, left, duration)
        end
    end
end



---
---Vibrates the device if possible.
---
---@param duration number
function Input.vibrate(duration)
    love.system.vibrate(duration)
end

-- TODO: last pressed/released key


-- Actions
local action = class:extend()

function action:new(name)
    self.name = name
    self.deadzone = nil
    self:unbindAll()
end

function action:check(gamepadId)
    for key, value in pairs(self.key) do
        if Input.key(key) then
            return true
        end
    end

    for key, value in pairs(self.keyPressed) do
        if Input.keyPressed(key) then
            return true
        end
    end

    for key, value in pairs(self.keyReleased) do
        if Input.keyReleased(key) then
            return true
        end
    end

    if self.anyKey then
        if Input.anyKey() then
            return true
        end
    end

    if self.anyKeyPressed then
        if Input.anyKeyPressed() then
            return true
        end
    end

    if self.anyKeyReleased then
        if Input.anyKeyReleased() then
            return true
        end
    end

    for key, value in pairs(self.mouse) do
        if Input.mouse(key) then
            return true
        end
    end

    for key, value in pairs(self.mousePressed) do
        if Input.mousePressed(key) then
            return true
        end
    end

    for key, value in pairs(self.mouseReleased) do
        if Input.mouseReleased(key) then
            return true
        end
    end

    if self.wheelup ~= nil then
        if Input.mouseWheelUp(self.wheelup) then
            return true
        end
    end

    if self.wheeldown ~= nil then
        if Input.mouseWheelDown(self.wheeldown) then
            return true
        end
    end

    if self.wheelright ~= nil then
        if Input.mouseWheelRight(self.wheelright) then
            return true
        end
    end

    if self.wheelleft ~= nil then
        if Input.mouseWheelLeft(self.wheelleft) then
            return true
        end
    end

    if self.anyMouse then
        if Input.anyMouse() then
            return true
        end
    end

    if self.anyMousePressed then
        if Input.anyMousePressed() then
            return true
        end
    end

    if self.anyMouseReleased then
        if Input.anyMouseReleased() then
            return true
        end
    end

    for id, _ in pairs(self.gamepad) do
        for key, _ in pairs(self.gamepad[id]) do
            if id == 0 then
                id = nil
            end
            if Input.gamepad(key, id or gamepadId) then
                return true
            end
        end
    end

    for id, _ in pairs(self.gamepadPressed) do
        for key, _ in pairs(self.gamepadPressed[id]) do
            if id == 0 then
                id = nil
            end
            if Input.gamepadPressed(key, id or gamepadId) then
                return true
            end
        end
    end

    for id, _ in pairs(self.gamepadReleased) do
        for key, _ in pairs(self.gamepadReleased[id]) do
            if id == 0 then
                id = nil
            end
            if Input.gamepadReleased(key, id or gamepadId) then
                return true
            end
        end
    end

    if self.anyGamepad then
        for id, value in pairs(self.anyGamepad) do
            if id == 0 then
                id = nil
            end

            if Input.anyGamepad(id) then
                return true
            end
        end
    end

    if self.anyGamepadPressed then
        for id, value in pairs(self.anyGamepadPressed) do
            if id == 0 then
                id = nil
            end

            if Input.anyGamepad(id) then
                return true
            end
        end
    end

    if self.anyGamepadReleased then
        for id, value in pairs(self.anyGamepadReleased) do
            if id == 0 then
                id = nil
            end

            if Input.anyGamepad(id) then
                return true
            end
        end
    end

    if self.gamepadAxis then
        if self:getAxis() ~= 0 then
            return true
        end
    end

    if self.any then
        if Input.any() then
            return true
        end
    end

    if self.anyPressed then
        if Input.anyPressed() then
            return true
        end
    end

    if self.anyReleased then
        if Input.anyReleased() then
            return true
        end
    end
    

    return false
end


function action:positive()
    if self.parent then
        return self.parent:positive()
    end

    if not self.positiveAction then
        self.positiveAction = action(self.name .. "_positive")
        self.positiveAction.parent = self
    end

    return self.positiveAction
end

function action:negative()
    if self.parent then
        return self.parent:negative()
    end

    if not self.negativeAction then
        self.negativeAction = action(self.name .. "_negative")
        self.negativeAction.parent = self
    end
    
    return self.negativeAction
end


function action:getAxis(gamepadId)
    local p, n, r

    p, n = 0, 0
    
    if self.positiveAction then
        p = self.positiveAction:check(gamepadId) and 1 or 0
    end

    if self.negativeAction then
        n = self.negativeAction:check(gamepadId) and 1 or 0
    end

    r = p - n
    if r == 0 then
        for id, _ in pairs(self.gamepadAxis) do
            for key, _ in pairs(self.gamepadAxis[id]) do
                if id == 0 then
                    id = nil
                end
                r = Input.gamepadAxis(key, id or gamepadId)
                
                if r ~= 0 then
                    return r
                end
            end
        end
    end
    return r
end

function action:getAxisRaw(gamepadId)
    local p, n, r

    p, n = 0, 0
    if self.positiveAction then
        p = self.positiveAction:check(gamepadId) and 1 or 0
    end

    if self.negativeAction then
        n = self.negativeAction:check(gamepadId) and 1 or 0
    end

    r = p - n
    if r == 0 then
        for id, _ in pairs(self.gamepadAxis) do
            for key, _ in pairs(self.gamepadAxis[id]) do
                if id == 0 then
                    id = nil
                end
                r = Input.gamepadAxisRaw(key, id or gamepadId)
                
                if r ~= 0 then
                    return r
                end
            end
        end
    end
    return r
end

function action:unbindAll()
    self.key = {}
    self.keyPressed = {}
    self.keyReleased = {}
    self.anyKey = nil
    self.anyKeyPressed = nil
    self.anyKeyReleased = nil

    self.mouse = {}
    self.mousePressed = {}
    self.mouseReleased = {}
    self.wheelup = nil
    self.wheeldown = nil
    self.wheelright = nil
    self.wheelleft = nil
    self.anyMouse = nil
    self.anyMousePressed = nil
    self.anyMouseReleased = nil

    self.gamepad = {}
    self.gamepadPressed = {}
    self.gamepadReleased = {}
    self.gamepadAxis = {}
    self.anyGamepad = {}
    self.anyGamepadPressed = {}
    self.anyGamepadReleased = {}

    self.any = nil
    self.anyPressed = nil
    self.anyReleased = nil
end

function action:setDeadzone(deadzone)
    self.deadzone = deadzone
    return self
end

function action:bindKey(...)
    for index, value in ipairs({...}) do
        self.key[value] = true
    end
    return self
end

function action:bindKeyPressed(...)
    for index, value in ipairs({...}) do
        self.keyPressed[value] = true
    end
    return self
end

function action:bindKeyReleased(...)
    for index, value in ipairs({...}) do
        self.keyReleased[value] = true
    end
    return self
end

function action:bindAnyKey()
    self.anyKey = true
    return self
end

function action:bindAnyKeyPressed()
    self.anyKeyPressed = true
    return self
end

function action:bindAnyKeyReleased()
    self.anyKeyReleased = true
    return self
end



function action:bindMouse(...)
    for index, value in ipairs({...}) do
        self.mouse[value] = true
    end
    return self
end

function action:bindMousePressed(...)
    for index, value in ipairs({...}) do
        self.mousePressed[value] = true
    end
    return self
end

function action:bindMouseReleased(...)
    for index, value in ipairs({...}) do
        self.mouseReleased[value] = true
    end
    return self
end

function action:bindMouseWheelUp(deadzone)
    self.wheelup = deadzone or 0
    return self
end

function action:bindMouseWheelDown(deadzone)
    self.wheeldown = deadzone or 0
    return self
end

function action:bindMouseWheelRight(deadzone)
    self.wheelright = deadzone or 0
    return self
end

function action:bindMouseWheelLeft(deadzone)
    self.wheelleft = deadzone or 0
    return self
end

function action:bindAnyMouse()
    self.anyMouse = true
    return self
end

function action:bindAnyMousePressed()
    self.anyMousePressed = true
    return self
end

function action:bindAnyMouseReleased()
    self.anyMouseReleased = true
    return self
end



local id, args, count
function action:bindGamepad(...)
    args = {...}
    count = #args
    id = args[count]
    if type(id) == "number" then
        args[count] = nil
    else
        id = 0
    end

    if not self.gamepad[id] then
        self.gamepad[id] = {}
    end

    for index, value in ipairs(args) do
        self.gamepad[id][value] = true
    end
    return self
end

function action:bindGamepadPressed(...)
    args = {...}
    count = #args
    id = args[count]
    if type(id) == "number" then
        args[count] = nil
    else
        id = 0
    end

    if not self.gamepadPressed[id] then
        self.gamepadPressed[id] = {}
    end

    for index, value in ipairs(args) do
        self.gamepadPressed[id][value] = true
    end
    return self
end

function action:bindGamepadReleased(...)
    args = {...}
    count = #args
    id = args[count]
    if type(id) == "number" then
        args[count] = nil
    else
        id = 0
    end

    if not self.gamepadReleased[id] then
        self.gamepadReleased[id] = {}
    end

    for index, value in ipairs(args) do
        self.gamepadReleased[id][value] = true
    end
    return self
end

function action:bindGamepadAxis(...)
    args = {...}
    count = #args
    id = args[count]
    if type(id) == "number" then
        args[count] = nil
    else
        id = 0
    end

    if self.parent then
        if not self.parent.gamepadAxis[id] then
            self.parent.gamepadAxis[id] = {}
        end
    
        for index, value in ipairs(args) do
            self.parent.gamepadAxis[id][value] = true
        end
    else
        if not self.gamepadAxis[id] then
            self.gamepadAxis[id] = {}
        end

        for index, value in ipairs(args) do
            self.gamepadAxis[id][value] = true
        end
    end
    return self
end

function action:bindAnyGamepad(...)
    self.anyGamepad = {...}
    return self
end

function action:bindAnyGamepadPressed(...)
    self.anyGamepadPressed = {...}
    return self
end

function action:bindAnyGamepadReleased(...)
    self.anyGamepadReleased = {...}
    return self
end



function action:bindAny()
    self.any = true
    return self
end

function action:bindAnyPressed()
    self.anyPressed = true
    return self
end

function action:bindAnyReleased()
    self.anyReleased = true
    return self
end


function action:unbindKey(...)
    for index, value in ipairs({...}) do
        self.key[value] = nil
    end
    return self
end

function action:unbindKeyPressed(...)
    for index, value in ipairs({...}) do
        self.keyPressed[value] = nil
    end
    return self
end

function action:unbindKeyReleased(...)
    for index, value in ipairs({...}) do
        self.keyReleased[value] = nil
    end
    return self
end

function action:unbindAnyKey()
    self.anyKey = nil
    return self
end

function action:unbindAnyKeyPressed()
    self.anyKeyPressed = nil
    return self
end

function action:unbindAnyKeyReleased()
    self.anyKeyReleased = nil
    return self
end


function action:unbindMouse(...)
    for index, value in ipairs({...}) do
        self.mouse[value] = nil
    end
    return self
end

function action:unbindMousePressed(...)
    for index, value in ipairs({...}) do
        self.mousePressed[value] = nil
    end
    return self
end

function action:unbindMouseReleased(...)
    for index, value in ipairs({...}) do
        self.mouseReleased[value] = nil
    end
    return self
end

function action:unbindMouseWheelUp()
    self.wheelup = nil
    return self
end

function action:unbindMouseWheelDown()
    self.wheeldown = nil
    return self
end

function action:unbindMouseWheelRight()
    self.wheelright = nil
    return self
end

function action:unbindMouseWheelLeft()
    self.wheelleft = nil
    return self
end

function action:unbindAnyMouse()
    self.anyMouse = nil
    return self
end

function action:unbindAnyMousePressed()
    self.anyMousePressed = nil
    return self
end

function action:unbindAnyMouseReleased()
    self.anyMouseReleased = nil
    return self
end


function action:unbindGamepad(...)
    args = {...}
    count = #args
    id = args[count]
    if type(id) == "number" then
        args[count] = nil
    else
        id = 0
    end

    if self.gamepad[id] then
        for index, value in ipairs(args) do
            self.gamepad[id][value] = nil
        end
    end
    return self
end

function action:unbindGamepadPressed(...)
    args = {...}
    count = #args
    id = args[count]
    if type(id) == "number" then
        args[count] = nil
    else
        id = 0
    end

    if self.gamepadPressed[id] then
        for index, value in ipairs(args) do
            self.gamepadPressed[id][value] = nil
        end
    end
    return self
end

function action:unbindGamepadReleased(...)
    args = {...}
    count = #args
    id = args[count]
    if type(id) == "number" then
        args[count] = nil
    else
        id = 0
    end

    if self.gamepadReleased[id] then
        for index, value in ipairs(args) do
            self.gamepadReleased[id][value] = nil
        end
    end
    return self
end

function action:unbindGamepadAxis(...)
    args = {...}
    count = #args
    id = args[count]
    if type(id) == "number" then
        args[count] = nil
    else
        id = 0
    end

    if self.gamepadAxis[id] then
        for index, value in ipairs(args) do
            self.gamepadAxis[id][value] = nil
        end
    end
    return self
end

function action:unbindAnyGamepad(...)
    for key, value in pairs({...}) do
        self.anyGamepad[key] = nil
    end
    return self
end

function action:unbindAnyGamepadPressed(...)
    for key, value in pairs({...}) do
        self.anyGamepadPressed[key] = nil
    end
    return self
end

function action:unbindAnyGamepadReleased(...)
    for key, value in pairs({...}) do
        self.anyGamepadReleased[key] = nil
    end
    return self
end


function action:unbindAny()
    self.any = nil
    return self
end

function action:unbindAnyPressed()
    self.anyPressed = nil
    return self
end

function action:unbindAnyReleased()
    self.anyReleased = nil
    return self
end


-- Input action functions
function Input.action(name)
    if Input.actions[name] then
        return Input.actions[name]
    else 
        local newAction = action(name)
        Input.actions[name] = newAction
        return newAction
    end
end

function Input.removeAction(name)
    Input.actions[name] = nil
end

function Input.clearActions()
    for key, value in pairs(Input.actions) do
        Input.actions[key] = nil
    end
end

function Input.get(name, gamepadId)
    return Input.actions[name]:check(gamepadId)
end

function Input.getAxis(name, gamepadId)
    return Input.actions[name]:getAxis(gamepadId)
end

function Input.getAxisRaw(name, gamepadId)
    return Input.actions[name]:getAxisRaw(gamepadId)
end

function Input.setConfig(config)
    if config.deadzone then
        Input.setGamepadDeadzone(config.deadzone)
        config.deadzone = nil
    end

    for actionName, settings  in pairs(config) do
        Input._setupAction(Input.action(actionName), settings)
    end
end

function Input.getConfig()
    local config = {}
    config.deadzone = Input.deadzone

    for name, value in pairs(Input.actions) do
        config[name] = Input._getConfigAction(value)
    end

    return config
end

function Input.saveConfig(name)
    local file = name or 'controls.json'
    local content = json.encode(Input.getConfig())
    if not Input.isWeb then
        love.filesystem.write(file, content)
    else
        love.thread.newThread([[
            local file, data = ...
            love.filesystem.write(file, data)
        ]]):start(file, content)
    end
end

function Input.loadConfig(name)
    local file = name or 'controls.json'
    if love.filesystem.getInfo(file) then
        local content = love.filesystem.read(file)
        Input.setConfig(json.decode(content))
    end
end

function Input._getConfigAction(_action)
    local settings = {}

    if _action.deadzone then
        settings.deadzone = _action.deadzone
    end

    local empty
    if _action.key then
        settings.key = {}
        empty = true
        for key, value in pairs(_action.key) do
            empty = false
            table.insert(settings.key, key)
        end

        if empty then
            settings.key = nil
        end
    end

    if _action.keyPressed and #_action.keyPressed > 0 then
        settings.keyPressed = {}
        empty = true
        for key, value in pairs(_action.keyPressed) do
            empty = false
            table.insert(settings.keyPressed, key)
        end

        if empty then
            settings.keyPressed = nil
        end
    end

    if _action.keyReleased then
        settings.keyReleased = {}
        empty = true
        for key, value in pairs(_action.keyReleased) do
            empty = false
            table.insert(settings.keyReleased, key)
        end

        if empty then
            settings.keyReleased = nil
        end
    end

    if _action.anyKey then
        settings.anyKey = 1
    end

    if _action.anyKeyPressed then
        settings.anyKeyPressed = 1
    end

    if _action.anyKeyReleased then
        settings.anyKeyReleased = 1
    end

    if _action.mouse then
        settings.mouse = {}
        empty = true
        for key, value in pairs(_action.mouse) do
            empty = false
            table.insert(settings.mouse, key)
        end

        if empty then
            settings.mouse = nil
        end
    end

    if _action.mousePressed then
        settings.mousePressed = {}
        empty = true
        for key, value in pairs(_action.mousePressed) do
            empty = false
            table.insert(settings.mousePressed, key)
        end

        if empty then
            settings.mousePressed = nil
        end
    end

    if _action.mouseReleased then
        settings.mouseReleased = {}
        empty = true
        for key, value in pairs(_action.mouseReleased) do
            empty = false
            table.insert(settings.mouseReleased, key)
        end

        if empty then
            settings.mouseReleased = nil
        end
    end

    if _action.wheelup ~= nil then
        settings.mouseWheelUp = _action.wheelup
    end

    if _action.wheeldown ~= nil then
        settings.mouseWheelDown = _action.wheeldown
    end

    if _action.wheelright ~= nil then
        settings.mouseWheelRight = _action.wheelright
    end

    if _action.wheelleft ~= nil then
        settings.mouseWheelLeft = _action.wheelleft
    end

    if _action.anyMouse then
        settings.anyMouse = 1
    end

    if _action.anyMousePressed then
        settings.anyMousePressed = 1
    end

    if _action.anyMouseReleased then
        settings.anyMouseReleased = 1
    end

    if _action.gamepad then
        settings.gamepad = {}
        empty = true
        for id, keys in pairs(_action.gamepad) do
            settings.gamepad[id] = {}
            for key, value in pairs(keys) do
                empty = false
                table.insert(settings.gamepad[id], key)
            end
        end

        if empty then
            settings.gamepad = nil
        end
    end

    if _action.gamepadPressed then
        settings.gamepadPressed = {}
        empty = true
        for id, keys in pairs(_action.gamepadPressed) do
            settings.gamepadPressed[id] = {}
            for key, value in pairs(keys) do
                empty = false
                table.insert(settings.gamepadPressed[id], key)
            end
        end

        if empty then
            settings.gamepadPressed = nil
        end
    end

    if _action.gamepadReleased then
        settings.gamepadReleased = {}
        empty = true
        for id, keys in pairs(_action.gamepadReleased) do
            settings.gamepadReleased[id] = {}
            for key, value in pairs(keys) do
                empty = false
                table.insert(settings.gamepadReleased[id], key)
            end
        end

        if empty then
            settings.gamepadReleased = nil
        end
    end

    if _action.gamepadAxis then
        settings.gamepadAxis = {}
        empty = true
        for id, axis in pairs(_action.gamepadAxis) do
            settings.gamepadAxis[id] = {}
            for key, value in pairs(axis) do
                empty = false
                table.insert(settings.gamepadAxis[id], key)
            end
        end

        if empty then
            settings.gamepadAxis = nil
        end
    end

    if _action.anyGamepad then
        settings.anyGamepad = {}
        empty = true
        for id, _ in pairs(_action.anyGamepad) do
            empty = false
            table.insert(settings.anyGamepad, id)
        end

        if empty then
            settings.anyGamepad = nil
        end
    end

    if _action.anyGamepadPressed then
        settings.anyGamepadPressed = {}
        empty = true
        for id, _ in pairs(_action.anyGamepadPressed) do
            empty = false
            table.insert(settings.anyGamepadPressed, id)
        end

        if empty then
            settings.anyGamepadPressed = nil
        end
    end

    if _action.anyGamepadReleased then
        settings.anyGamepadReleased = {}
        empty = true
        for id, _ in pairs(_action.anyGamepadReleased) do
            empty = false
            table.insert(settings.anyGamepadReleased, id)
        end

        if empty then
            settings.anyGamepadReleased = nil
        end
    end

    if _action.any then
        settings.any = 1
    end

    if _action.anyPressed then
        settings.anyPressed = 1
    end

    if _action.anyReleased then
        settings.anyReleased = 1
    end

    if _action.positiveAction then
        settings.positive = Input._getConfigAction(_action.positiveAction)
    end
    
    if _action.negativeAction then
        settings.negative = Input._getConfigAction(_action.negativeAction)
    end
    
    return settings
end

function Input._setupAction(action, settings)
    if settings.key then
        action:bindKey(unpack(settings.key))
    end

    if settings.keyPressed then
        action:bindKeyPressed(unpack(settings.keyPressed))
    end
    
    if settings.keyReleased then
        action:bindKeyReleased(unpack(settings.keyReleased))
    end

    if settings.anyKey then
        action:bindAnyKey()
    end

    if settings.anyKeyPressed then
        action:bindAnyKeyPressed()
    end

    if settings.anyKeyReleased then
        action:bindAnyKeyReleased()
    end




    if settings.mouse then
        action:bindMouse(unpack(settings.mouse))
    end
    
    if settings.mousePressed then
        action:bindMousePressed(unpack(settings.mousePressed))
    end

    if settings.mouseReleased then
        action:bindMouseReleased(unpack(settings.mouseReleased))
    end

    if settings.mouseWheelUp then
        action:bindMouseWheelUp(settings.mouseWheelUp)
    end

    if settings.mouseWheelDown then
        action:bindMouseWheelDown(settings.mouseWheelDown)
    end

    if settings.mouseWheelLeft then
        action:bindMouseWheelLeft(settings.mouseWheelLeft)
    end

    if settings.mouseWheelRight then
        action:bindMouseWheelRight(settings.mouseWheelRight)
    end

    if settings.anyMouse then
        action:bindAnyMouse()
    end

    if settings.anyMousePressed then
        action:bindAnyMousePressed()
    end

    if settings.anyMouseReleased then
        action:bindAnyMouseReleased()
    end




    if settings.gamepad then
        for id, keys in pairs(settings.gamepad) do
            action:bindGamepad(unpack(keys), id)
        end
    end

    if settings.gamepadPressed then
        for id, keys in pairs(settings.gamepadPressed) do
            action:bindGamepadPressed(unpack(keys), id)
        end
    end

    if settings.gamepadReleased then
        for id, keys in pairs(settings.gamepadReleased) do
            action:bindGamepadReleased(unpack(keys), id)
        end
    end
    
    if settings.gamepadAxis then
        for id, axis in pairs(settings.gamepadAxis) do
            action:bindGamepadAxis(unpack(axis), id)
        end
    end

    if settings.anyGamepad then
        for id, keys in pairs(settings.anyGamepad) do
            action:bindAnyGamepad(unpack(keys), id)
        end
    end

    if settings.anyGamepadPressed then
        for id, keys in pairs(settings.anyGamepadPressed) do
            action:bindAnyGamepadPressed(unpack(keys), id)
        end
    end

    if settings.anyGamepadReleased then
        for id, keys in pairs(settings.anyGamepadReleased) do
            action:bindAnyGamepadReleased(unpack(keys), id)
        end
    end

    if settings.any then
        action:bindAny()
    end

    if settings.anyPressed then
        action:bindAnyPressed()
    end

    if settings.anyReleased then
        action:bindAnyReleased()
    end

    action:setDeadzone(settings.deadzone)

    if settings.positive then
        Input._setupAction(action:positive(), settings.positive)
    end
    
    if settings.negative then
        Input._setupAction(action:negative(), settings.negative)
    end
end

-- TODO Sequences
-- TODO swipe

-- SETUP
function Input._keypressed(key)
    Input.kpressed[key] = true
    Input.kdown[key] = true
    Input.klastpressed = key
end

function Input._keyreleased(key)
    Input.kreleased[key] = true
    Input.kdown[key] = nil
    Input.kpressed[key] = false
    Input.klastreleased = key
end

function Input._mousepressed(x, y, button, istouch, presses)
    Input.mpressed[button] = {x, y, istouch, presses}
    Input.mdown[button] = true
    Input.mlastpressed = button
end

function Input._mousereleased(x, y, button, istouch, presses)
    Input.mreleased[button] = {x, y, istouch, presses}
    Input.mdown[button] = nil
    Input.mpressed[button] = false
    Input.mlastreleased = button
end

function Input._mousemoved(x,y, dx, dy)
    Input.mposition[1], Input.mposition[2] = x, y
    Input.mmovement[1], Input.mmovement[2] = dx, dy
end

function Input._wheelmoved(x, y)
    Input.mwheel[1], Input.mwheel[2] = x, y
end

local id
function Input._joystickAdded(joystick)
    if joystick:isGamepad() then
        id = joystick:getID()
        Input.gamepads[id] = joystick
        Input.gamepadsAdded[id] = joystick
        Input.gpressed[id] = {}
        Input.greleased[id] = {}
        Input.gdown[id] = {}
        Input.gaxis[id] = {}
        Input.onGamepadAdded(joystick, id)
    end

end

function Input._joystickRemoved(joystick)
    id = joystick:getID()
    if Input.gamepads[id] then
        Input.gamepads[id] = nil
        Input.gamepadsRemoved[id] = joystick
        Input.gpressed[id] = nil
        Input.greleased[id] = nil
        Input.gdown[id] = nil
        Input.gaxis[id] = nil
        Input.onGamepadRemoved(joystick, id)
    end
end

function Input._gamepadpressed(joystick, button)
    id = joystick:getID()

    Input.gpressed[id][button] = true
    Input.gdown[id][button] = true
    Input.glastpressed[id] = button
end

function Input._gamepadreleased(joystick, button)
    id = joystick:getID()
    Input.greleased[id][button] = true
    Input.gdown[id][button] = nil
    Input.glastreleased[id] = button
end

function Input._gamepadaxis(joystick, axis, value)
    id = joystick:getID()
    Input.gaxis[id][axis] = value
end

function Input.setupKeyboard()
    function love.keypressed(key)
        Input._keypressed(key)
    end

    function love.keyreleased(key)
        Input._keyreleased(key)
    end

    function love.textinput(t)
        Input.tinput = t
    end
end


---
--- Configures LÖVE's mouse callbacks for you.
--- Call once in your main.lua file
---
function Input.setupMouse()
    function love.mousepressed(x, y, button, istouch, presses)
        Input._mousepressed(x, y, button, istouch, presses)
    end

    function love.mousereleased(x, y, button, istouch, presses)
        Input._mousereleased(x, y, button, istouch, presses)
    end

    function love.mousemoved(x, y, dx, dy)
        Input._mousemoved(x, y, dx, dy)
    end

    function love.wheelmoved(x, y)
        Input._wheelmoved(x, y)
    end
end

---
--- Configures LÖVE's gamepad callbacks for you.
--- Call once in your main.lua file
---
function Input.setupGamepad()
    function love.joystickadded(joystick)
        Input._joystickAdded(joystick)
    end

    function love.joystickremoved(joystick)
        Input._joystickRemoved(joystick)
    end

    function love.gamepadpressed(joystick, button)
        Input._gamepadpressed(joystick, button)
    end

    function love.gamepadreleased(joystick, button)
        Input._gamepadreleased(joystick, button)
    end

    function love.gamepadaxis(joystick, axis, value)
        Input._gamepadaxis(joystick, axis, value)
    end
end

---
--- Configures all LÖVE's input callbacks for you.
--- Call once in your main.lua file.
---
function Input.setup()
    Input.setupKeyboard()
    Input.setupMouse()
    Input.setupGamepad()
end

---
--- Updates the input state, should be called at the end of the main update loop.
---
--- @param dt number
function Input.update(dt)
    -- Keybaord
    for key, value in pairs(Input.kpressed) do
        Input.kpressed[key] = nil
    end

    for key, value in pairs(Input.kreleased) do
        Input.kreleased[key] = nil
    end

    Input.tinput = ''
    Input.klastpressed = nil
    Input.klastreleased = nil

    -- Mouse
    for key, value in pairs(Input.mpressed) do
        Input.mpressed[key] = nil
    end

    for key, value in pairs(Input.mreleased) do
        Input.mreleased[key] = nil
    end

    Input.mmovement[1], Input.mmovement[2] = 0, 0
    Input.mwheel[1], Input.mwheel[2] = 0, 0
    Input.mlastpressed = nil
    Input.mlastreleased = nil

    -- Gamepad
    for key, value in pairs(Input.gamepadsAdded) do
        Input.gamepadsAdded[key] = nil
    end

    for key, value in pairs(Input.gamepadsRemoved) do
        Input.gamepadsRemoved[key] = nil
    end

    for id, _ in pairs(Input.gamepads) do
        for key, value in pairs(Input.gpressed[id]) do
            Input.gpressed[id][key] = nil
        end
    
        for key, value in pairs(Input.greleased[id]) do
            Input.greleased[id][key] = nil
        end

        Input.glastpressed[id] = nil
        Input.glastreleased[id] = nil
    end
    
end

-- CALLBACKS

---
--- (CALLBACK) Called when a gamepad is added.
---
--- @param joystick table
--- @param id number
function Input.onGamepadAdded(joystick, id)
    
end

---
--- (CALLBACK) Called when a gamepad is removed.
---
--- @param joystick table
--- @param id number
function Input.onGamepadRemoved(joystick, id)
    
end

return Input