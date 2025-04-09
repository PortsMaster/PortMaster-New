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

    gamepads = {},
    gamepadsAdded = {},
    gamepadsRemoved = {},
    gpressed = {},
    greleased = {},
    gdown = {},
    gaxis = {},
    deadzone = 0.03,
}

--  ##ROADMAP##
-- [x] Keyboard support (held, pressed, released)
-- [x] Mouse support (held, pressed, released, wheel, movement)
-- [x??] Gamepad support (I don't have a physical controller to fully test it myself)
-- [-] actions (working fine)
-- [-] Config (save, load)
-- [ ] Touch (and related functions)
-- [ ] Swipe
-- [ ] Sequences

-- TODO
-- [-] last key pressed/released
-- [] Gamepad vibration


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
function Input.mouseWheelUp()
    return Input.mwheel[2] > 0
end

---
---Checks if the mouse wheel is going down.
---
---@return boolean
function Input.mouseWheelDown()
    return Input.mwheel[2] < 0
end

---
---Checks if the mouse wheel is going right.
---
---@return boolean
function Input.mouseWheelRight()
    return Input.mwheel[1] > 0
end

---
---Checks if the mouse wheel is going left.
---
---@return boolean
function Input.mouseWheelLeft()
    return Input.mwheel[1] < 0
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



-- TODO: last mouse action

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
---@param button string
---@param id number
---@return boolean
function Input.gamepad(button, id)
    if id then
        if Input.gamepadIsConnected(id) then
            return Input.gdown[id][button]
        end
    end

    for id, _ in pairs(Input.gamepads) do
        if Input.gdown[id][button] then
            return true
        end
    end
    return false
end


---
---* `Input.gamepadPressed(button)`:Checks if a button is just pressed on all gamepads.
---* `Input.gamepadPressed(button, id)`: Checks if a button is just pressed on a specific gamepad.
---
---@overload fun(button:string):boolean
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
---@param axis string
---@param id number
function Input.gamepadAxis(axis, id)
    local r
    if id then
        if Input.gamepadIsConnected(id) then
            r = Input.gaxis[id][axis] or 0
            if r > Input.deadzone then
                return r
            elseif r < -Input.deadzone then
                return r
            else
                return 0
            end
        end
    else
        for id, _ in pairs(Input.gamepads) do
            r = Input.gaxis[id][axis] or 0
            if r > Input.deadzone then
                return r
            elseif r < -Input.deadzone then
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
---@param axis string
---@param id number
function Input.gamepadAxisRaw(axis, id)
    local r
    if id then
        if Input.gamepadIsConnected(id) then
            r = Input.gaxis[id][axis] or 0
            if r > Input.deadzone then
                return 1
            elseif r < -Input.deadzone then
                return -1
            else
                return 0
            end
        end
    else
        for id, _ in pairs(Input.gamepads) do
            r = Input.gaxis[id][axis] or 0
            if r > Input.deadzone then
                return 1
            elseif r < -Input.deadzone then
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
---@param id number
---@return boolean
function Input.anyGamepad(id)
    if id then
        if Input.gamepadIsConnected(id) then
            for _,_ in Input.gdown[id] do
                return true
            end
        end
    end
    
    for id, _ in pairs(Input.gamepads) do
        for _,_ in pairs(Input.gdown[id]) do
            return true
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
---@return boolean
function Input.anyGamepadPressed(id)
    if id then
        if Input.gamepadIsConnected(id) then
            for _,_ in Input.gpressed[id] do
                return true
            end
        end
    end
    
    for id, _ in pairs(Input.gamepads) do
        for _,_ in pairs(Input.gpressed[id]) do
            return true
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
---@return boolean
function Input.anyGamepadReleased(id)
    if id then
        if Input.gamepadIsConnected(id) then
            for _,_ in Input.greleased[id] do
                return true
            end
        end
    end
    
    for id, _ in pairs(Input.gamepads) do
        for _,_ in pairs(Input.greleased[id]) do
            return true
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

-- TODO: last gamepad action

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


-- TODO: last pressed/released key


-- Actions
local action = class:extend()

function action:new(name)
    self.name = name
    self:unbindAll()
end

function action:check()
    for key, value in pairs(self.keys) do
        if Input.key(key) then
            return true
        end
    end

    for key, value in pairs(self.keysPressed) do
        if Input.keyPressed(key) then
            return true
        end
    end

    for key, value in pairs(self.keysReleased) do
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

    if self.wheelup then
        if Input.mouseWheelUp() then
            return true
        end
    end

    if self.wheeldown then
        if Input.mouseWheelDown() then
            return true
        end
    end

    if self.wheelright then
        if Input.mouseWheelRight() then
            return true
        end
    end

    if self.wheelleft then
        if Input.mouseWheelLeft() then
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
            if Input.gamepad(key, id) then
                return true
            end
        end
    end

    for id, _ in pairs(self.gamepadPressed) do
        for key, _ in pairs(self.gamepadPressed[id]) do
            if id == 0 then
                id = nil
            end
            if Input.gamepadPressed(key, id) then
                return true
            end
        end
    end

    for id, _ in pairs(self.gamepadReleased) do
        for key, _ in pairs(self.gamepadReleased[id]) do
            if id == 0 then
                id = nil
            end
            if Input.gamepadReleased(key, id) then
                return true
            end
        end
    end

    if self.anyGamepad then
        if Input.anyGamepad() then
            return true
        end
    end

    if self.anyGamepadPressed then
        if Input.anyGamepadPressed() then
            return true
        end
    end

    if self.anyGamepadReleased then
        if Input.anyGamepadReleased() then
            return true
        end
    end

    if self.gamepadAxis then
        return self:getAxis() ~= 0
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


function action:getAxis()
    local p, n, r

    p, n = 0, 0
    
    if self.positiveAction then
        p = self.positiveAction:check() and 1 or 0
    end

    if self.negativeAction then
        n = self.negativeAction:check() and 1 or 0
    end

    r = p - n
    if r == 0 then
        for id, _ in pairs(self.gamepadAxis) do
            for key, _ in pairs(self.gamepadAxis[id]) do
                if id == 0 then
                    id = nil
                end
                r = Input.gamepadAxis(key, id)
                
                if r ~= 0 then
                    return r
                end
            end
        end
    end
    return r
end

function action:getAxisRaw()
    local p, n, r

    p, n = 0, 0
    
    if self.positiveAction then
        p = self.positiveAction:check() and 1 or 0
    end

    if self.negativeAction then
        n = self.negativeAction:check() and 1 or 0
    end

    r = p - n
    if r == 0 then
        for id, _ in pairs(self.gamepadAxis) do
            for key, _ in pairs(self.gamepadAxis[id]) do
                if id == 0 then
                    id = nil
                end
                r = Input.gamepadAxisRaw(key, id)
                
                if r ~= 0 then
                    return r
                end
            end
        end
    end
    return r
end

function action:unbindAll()
    self.keys = {}
    self.keysPressed = {}
    self.keysReleased = {}
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
    self.anyGamepad = nil
    self.anyGamepadPressed = nil
    self.anyGamepadReleased = nil

    self.any = nil
    self.anyPressed = nil
    self.anyReleased = nil
end

function action:bindKey(...)
    for index, value in ipairs({...}) do
        self.keys[value] = true
    end
    return self
end

function action:bindKeyPressed(...)
    for index, value in ipairs({...}) do
        self.keysPressed[value] = true
    end
    return self
end

function action:bindKeyReleased(...)
    for index, value in ipairs({...}) do
        self.keysReleased[value] = true
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

function action:bindMouseWheelUp()
    self.wheelup = true
    return self
end

function action:bindMouseWheelDown()
    self.wheeldown = true
    return self
end

function action:bindMouseWheelRight()
    self.wheelright = true
    return self
end

function action:bindMouseWheelLeft()
    self.wheelleft = true
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

function action:bindAnyGamepad()
    self.anyGamepad = true
    return self
end

function action:bindAnyGamepadPressed()
    self.anyGamepadPressed = true
    return self
end

function action:bindAnyGamepadReleased()
    self.anyGamepadReleased = true
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
        self.keys[value] = nil
    end
    return self
end

function action:unbindKeyPressed(...)
    for index, value in ipairs({...}) do
        self.keysPressed[value] = nil
    end
    return self
end

function action:unbindKeyReleased(...)
    for index, value in ipairs({...}) do
        self.keysReleased[value] = nil
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

function action:unbindAnyGamepad()
    self.anyGamepad = nil
    return self
end

function action:unbindAnyGamepadPressed()
    self.anyGamepadPressed = nil
    return self
end

function action:unbindAnyGamepadReleased()
    self.anyGamepadReleased = nil
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
    local newAction
    if Input.actions[name] then
        return Input.actions[name]
    else 
        newAction = action(name)
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

function Input.get(name)
    return Input.actions[name]:check()
end

function Input.getAxis(name)
    return Input.actions[name]:getAxis()
end

function Input.getAxisRaw(name)
    return Input.actions[name]:getAxisRaw()
end

function Input.config(config)
    if config.deadzone then
        Input.setGamepadDeadzone(config.deadzone)
        config.deadzone = nil
    end

    for actionName, settings  in pairs(config) do
        Input._setupAction(Input.action(actionName), settings)
    end
end

-- TODO: Write config files to the disk
-- TODO: Load config files from the disk 

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
        action:bindMouseWheelUp()
    end

    if settings.mouseWheelDown then
        action:bindMouseWheelDown()
    end

    if settings.mouseWheelLeft then
        action:bindMouseWheelLeft()
    end

    if settings.mouseWheelRight then
        action:bindMouseWheelRight()
    end


    if settings.gamepad then
        action:bindGamepad(unpack(settings.gamepad), settings.id)
    end

    if settings.gamepadPressed then
        action:bindGamepadPressed(unpack(settings.gamepadPressed), settings.id)
    end

    if settings.gamepadReleased then
        action:bindGamepadReleased(unpack(settings.gamepadReleased), settings.id)
    end
    
    if settings.gamepadAxis then
        action:bindGamepadAxis(unpack(settings.gamepadAxis), settings.id)
    end



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
    Input.klastreleased = key
end

function Input._mousepressed(x, y, button, istouch, presses)
    Input.mpressed[button] = {x, y, istouch, presses}
    Input.mdown[button] = tonumber
end

function Input._mousereleased(x, y, button, istouch, presses)
    Input.mreleased[button] = {x, y, istouch, presses}
    Input.mdown[button] = nil
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

    -- TODO joystick support
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
    
    -- TODO joystick support
end

function Input._gamepadpressed(joystick, button)
    id = joystick:getID()

    Input.gpressed[id][button] = true
    Input.gdown[id][button] = true
end

function Input._gamepadreleased(joystick, button)
    id = joystick:getID()
    Input.greleased[id][button] = true
    Input.gdown[id][button] = nil
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