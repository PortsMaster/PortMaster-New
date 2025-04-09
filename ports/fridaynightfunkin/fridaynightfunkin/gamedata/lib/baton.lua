local baton = {
	_VERSION = 'Baton v1.0.2',
	_DESCRIPTION = 'Input library for LÖVE.',
	_URL = 'https://github.com/tesselode/baton',
	_LICENSE = [[
		MIT License

		Copyright (c) 2020 Andrew Minnich

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
	]]
}

-- string parsing functions --

-- splits a source definition into type and value
-- example: 'button:a' -> 'button', 'a'
local function parseSource(source)
	return source:match '(.+):(.+)'
end

-- splits an axis value into axis and direction
-- example: 'leftx-' -> 'leftx', '-'
local function parseAxis(value)
	return value:match '(.+)([%+%-])'
end

-- splits a joystick hat value into hat number and direction
-- example: '2rd' -> '2', 'rd'
local function parseHat(value)
	return value:match '(%d)(.+)'
end

--[[
	-- source functions --

	each source function checks the state of one type of input
	and returns a value from 0 to 1. for binary controls, such
	as keyboard keys and gamepad buttons, they return 1 if the
	input is held down and 0 if not. for analog controls, such
	as "leftx+" (the left analog stick held to the right), they
	return a number from 0 to 1.

	source functions are split into keyboard/mouse functions
	and joystick/gamepad functions. baton treats these two
	categories slightly differently.
]]

local sourceFunction = {keyboardMouse = {}, joystick = {}}

-- checks whether a keyboard key is down or not
function sourceFunction.keyboardMouse.key(key)
	return (love.keyboard and love.keyboard.isDown(key)) and 1 or 0
end

-- checks whether a keyboard key is down or not,
-- but it takes a scancode as an input
function sourceFunction.keyboardMouse.sc(sc)
	return (love.keyboard and love.keyboard.isScancodeDown(sc)) and 1 or 0
end

-- checks whether a mouse buttons is down or not.
-- note that baton doesn't detect mouse movement, just the buttons
function sourceFunction.keyboardMouse.mouse(button)
	return (love.mouse and love.mouse.isDown(tonumber(button))) and 1 or 0
end

-- checks the position of a joystick axis
function sourceFunction.joystick.axis(joystick, value)
	local axis, direction = parseAxis(value)
	-- "a and b or c" is ok here because b will never be boolean
	value = tonumber(axis) and joystick:getAxis(tonumber(axis)) or joystick:getGamepadAxis(axis)
	if direction == '-' then value = -value end
	return value > 0 and value or 0
end

-- checks whether a joystick button is held down or not
-- can take a number or a GamepadButton string
function sourceFunction.joystick.button(joystick, button)
	-- i'm intentionally not using the "a and b or c" idiom here
	-- because joystick.isDown returns a boolean
	if tonumber(button) then
		return joystick:isDown(tonumber(button)) and 1 or 0
	else
		return joystick:isGamepadDown(button) and 1 or 0
	end
end

-- checks the direction of a joystick hat
function sourceFunction.joystick.hat(joystick, value)
	local hat, direction = parseHat(value)
	return joystick:getHat(hat) == direction and 1 or 0
end

-- checks if its belong in joystick or keyboardMouse
function sourceFunction.checkType(type)
	return (type == "axis" or type == "button" or type == "hat") and "joystick" or "keyboardMouse"
end

--[[
	-- player class --

	the player object takes a configuration table and handles input
	accordingly. it's called a "player" because it makes sense to use
	multiple of these for each player in a multiplayer game, but
	you can use separate player objects to organize inputs
	however you want.
]]

local Player = {}
Player.__index = Player


-- internal functions --
-- sets the player's config to a user-defined config table
-- and sets some defaults if they're not already defined
function Player:_loadConfig(config)
	if not config then
		error('No config table provided', 4)
	end
	if not config.controls then
		error('No controls specified', 4)
	end
	config.pairs = config.pairs or {}
	config.deadzone = config.deadzone or .5
	config.squareDeadzone = config.squareDeadzone or false
	self.config = config
end

-- initializes a control object for each control defined in the config
function Player:_initControls()
	self._controls = {}
	self._sourceControls = {keyboardMouse = {}, joystick = {}}
	self._pressBinds = {}
	self._releaseBinds = {}
	for controlName, sources in pairs(self.config.controls) do
		self._controls[controlName] = {
			sources = sources,
			rawValue = 0,
			value = 0,
			down = false,
			downPrevious = false,
			pressed = false,
			released = false,
			debounce = false,
			pressBinds = {},
			releaseBinds = {},
		}
		for _, source in pairs(sources) do
			local type, value = parseSource(source)
			type = sourceFunction.checkType(type)
			self._sourceControls[type][value] = self._sourceControls[type][value] or {}
			table.insert(self._sourceControls[type][value], controlName)
		end
	end
end

-- initializes an axis pair object for each axis pair defined in the config
function Player:_initPairs()
	self._pairs = {}
	for pairName, controls in pairs(self.config.pairs) do
		self._pairs[pairName] = {
			controls = controls,
			rawX = 0,
			rawY = 0,
			x = 0,
			y = 0,
			down = false,
			downPrevious = false,
			pressed = false,
			released = false
		}
	end
end

function Player:_init(config)
	self:_loadConfig(config)
	self:_initControls()
	self:_initPairs()
	self._activeDevice = 'none'
end

--[[
	detects the active device (keyboard/mouse or joystick).
	if the keyboard or mouse is currently being used, joystick
	inputs will be ignored. this is to prevent slight axis movements
	from adding errant inputs when someone's using the keyboard.

	the active device is saved to player._activeDevice, which is then
	used throughout the rest of the update loop to check only
	keyboard or joystick inputs.
]]
function Player:_setActiveDevice()
	-- if the joystick is unset, then we should make sure _activeDevice
	-- isn't "joy" anymore, otherwise there will be an error later
	-- when we try to query a joystick that isn't there
	if self._activeDevice == 'joy' and not self.config.joystick then
		self._activeDevice = 'none'
	end
	for _, control in pairs(self._controls) do
		for _, source in ipairs(control.sources) do
			local type, value = parseSource(source)
			if sourceFunction.keyboardMouse[type] then
				if sourceFunction.keyboardMouse[type](value) > self.config.deadzone then
					self._activeDevice = 'kbm'
					return
				end
			elseif self.config.joystick and sourceFunction.joystick[type] then
				if sourceFunction.joystick[type](self.config.joystick, value) > self.config.deadzone then
					self._activeDevice = 'joy'
				end
			end
		end
	end
end

--[[
	gets the value of a control by running the appropriate source functions
	for all of its sources. does not apply deadzone.
]]
function Player:_getControlRawValue(control)
	local rawValue = 0
	for _, source in ipairs(control.sources) do
		local type, value = parseSource(source)
		if sourceFunction.keyboardMouse[type] and self._activeDevice == 'kbm' then
			if sourceFunction.keyboardMouse[type](value) == 1 then
				return 1
			end
		elseif sourceFunction.joystick[type] and self._activeDevice == 'joy' then
			rawValue = rawValue + sourceFunction.joystick[type](self.config.joystick, value)
			if rawValue >= 1 then
				return 1
			end
		end
	end
	return rawValue
end

--[[
	updates each control in a player. saves the value with and without deadzone
	and the down/pressed/released state.
]]
function Player:_updateControls()
	for _, control in pairs(self._controls) do
		control.rawValue = self:_getControlRawValue(control)
		control.value = control.rawValue >= self.config.deadzone and control.rawValue or 0
		control.downPrevious = control.down
		control.down = control.value > 0
		if not control.debounce then
			control.pressed = control.down and not control.downPrevious
			control.released = control.downPrevious and not control.down
		end
		control.debounce = false
	end
end

--[[
	updates each axis pair in a player. saves the value with and without deadzone
	and the down/pressed/released state.
]]
function Player:_updatePairs()
	for _, pair in pairs(self._pairs) do
		-- get raw x and y
		local l = self._controls[pair.controls[1]].rawValue
		local r = self._controls[pair.controls[2]].rawValue
		local u = self._controls[pair.controls[3]].rawValue
		local d = self._controls[pair.controls[4]].rawValue
		pair.rawX, pair.rawY = r - l, d - u

		-- limit to 1
		local len = math.sqrt(pair.rawX ^ 2 + pair.rawY ^ 2)
		if len > 1 then
			pair.rawX, pair.rawY = pair.rawX / len, pair.rawY / len
		end

		-- deadzone
		if self.config.squareDeadzone then
			pair.x = math.abs(pair.rawX) > self.config.deadzone and pair.rawX or 0
			pair.y = math.abs(pair.rawY) > self.config.deadzone and pair.rawY or 0
		else
			pair.x = len > self.config.deadzone and pair.rawX or 0
			pair.y = len > self.config.deadzone and pair.rawY or 0
		end

		-- down/pressed/released
		pair.downPrevious = pair.down
		pair.down = pair.x ~= 0 or pair.y ~= 0
		pair.pressed = pair.down and not pair.downPrevious
		pair.released = pair.downPrevious and not pair.down
	end
end

function Player:_pressControls(names, source, type, ...)
	for _, bind in pairs(self._pressBinds) do
		bind(source, type, ...)
	end

	local control
	for _, name in pairs(names) do
		control = self._controls[name]
		control.rawValue = self:_getControlRawValue(control)
		control.value = control.rawValue >= self.config.deadzone and control.rawValue or 0
		control.down = true
		control.pressed = true
		control.released = false
		control.debounce = true
		for _, bind in pairs(control.pressBinds) do
			bind(...)
		end
	end
end

function Player:_releaseControls(names, source, type, ...)
	for _, bind in pairs(self._releaseBinds) do
		bind(source, type, ...)
	end

	local control
	for _, name in pairs(names) do
		control = self._controls[name]
		control.rawValue = self:_getControlRawValue(control)
		control.value = control.rawValue >= self.config.deadzone and control.rawValue or 0
		control.downPrevious = true
		control.down = false
		control.pressed = false
		control.released = true
		control.debounce = true
		for _, bind in pairs(control.releaseBinds) do
			bind(...)
		end
	end
end

-- public API --

-- resets the configs
function Player:reset(config)
	self:_loadConfig(config)
	self:_initControls()
	self:_initPairs()
end

-- checks for changes in inputs
function Player:update()
	self:_setActiveDevice()
	self:_updateControls()
	self:_updatePairs()
end

-- keyboard presses handler
function Player:onKeyPress(source, ...)
	local names = self._sourceControls.keyboardMouse[source]
	if not names then return end
	self:_pressControls(names, source, 'key', ...)
end

-- keyboard releases handler
function Player:onKeyRelease(source, ...)
	local names = self._sourceControls.keyboardMouse[source]
	if not names then return end
	self:_releaseControls(names, source, 'key', ...)
end

--[[
-- joystick presses handler
function Player:onJoystickPress(joystick, ...)
	local names = self._sourceControls.joystick[source]
	if not names then return end
	self:_pressControls(names, source, 'button', ...)
end

-- joystick releases handler
function Player:onJoystickRelease(source, ...)
	local names = self._sourceControls.joystick[source]
	if not names then return end
	self:_releaseControls(names, source, 'button', ...)
end
]]

-- bind presses callback
function Player:bindPress(bind)
	table.insert(self._pressBinds, bind)
end

-- unbind presses callback
function Player:unbindPress(bind)
	local i = table.find(self._pressBinds, bind)
	if i then
		table.remove(self._pressBinds, i)
	end
end

-- bind releases callback
function Player:bindRelease(bind)
	table.insert(self._releaseBinds, bind)
end

-- unbind releases callback
function Player:unbindRelease(bind)
	local i = table.find(self._releaseBinds, bind)
	if i then
		table.remove(self._releaseBinds, i)
	end
end

-- bind control presses callback
function Player:bindControlPress(name, bind)
	if self._controls[name] then
		table.insert(self._controls[name].pressBinds, bind)
	else
		error('No control with name "' .. name .. '" defined', 3)
	end
end

-- unbind control presses callback
function Player:unbindControlPressed(name, bind)
	if self._controls[name] then
		local i = table.find(self._controls[name].pressBinds, bind)
		if i then
			table.remove(self._controls[name].pressBinds, i)
		end
	else
		error('No control with name "' .. name .. '" defined', 3)
	end
end

-- bind control releases callback
function Player:bindControlRelease(name, bind)
	if self._controls[name] then
		table.insert(self._controls[name].releaseBinds, bind)
	else
		error('No control with name "' .. name .. '" defined', 3)
	end
end

-- unbind control releases callback
function Player:unbindControlPressed(name, bind)
	if self._controls[name] then
		local i = table.find(self._controls[name].releaseBinds, bind)
		if i then
			table.remove(self._controls[name].releaseBinds, i)
		end
	else
		error('No control with name "' .. name .. '" defined', 3)
	end
end

-- gets the controls from key
function Player:getControlsFromSource(source)
	local type, value = parseSource(source)
	return self._sourceControls[sourceFunction.checkType(type)][value]
end

-- gets the value of a control or axis pair without deadzone applied
function Player:getRaw(name)
	if self._pairs[name] then
		return self._pairs[name].rawX, self._pairs[name].rawY
	elseif self._controls[name] then
		return self._controls[name].rawValue
	else
		error('No control with name "' .. name .. '" defined', 3)
	end
end

-- gets the value of a control or axis pair with deadzone applied
function Player:get(name)
	if self._pairs[name] then
		return self._pairs[name].x, self._pairs[name].y
	elseif self._controls[name] then
		return self._controls[name].value
	else
		error('No control with name "' .. name .. '" defined', 3)
	end
end

-- gets whether a control or axis pair is "held down"
function Player:down(name)
	if self._pairs[name] then
		return self._pairs[name].down
	elseif self._controls[name] then
		return self._controls[name].down
	else
		error('No control with name "' .. name .. '" defined', 3)
	end
end

-- gets whether a control or axis pair was pressed this frame
function Player:pressed(name)
	if self._pairs[name] then
		return self._pairs[name].pressed
	elseif self._controls[name] then
		return self._controls[name].pressed
	else
		error('No control with name "' .. name .. '" defined', 3)
	end
end

-- gets whether a control or axis pair was released this frame
function Player:released(name)
	if self._pairs[name] then
		return self._pairs[name].released
	elseif self._controls[name] then
		return self._controls[name].released
	else
		error('No control with name "' .. name .. '" defined', 3)
	end
end

--[[
	gets the currently active device (either "kbm", "joy", or "none").
	this is useful for displaying instructional text. you may have
	a menu that says "press ENTER to confirm" or "press A to confirm"
	depending on whether the player is using their keyboard or gamepad.
	this function allows you to detect which they used most recently.
]]
function Player:getActiveDevice()
	return self._activeDevice
end

-- main functions --

-- creates a new player with the user-provided config table
function baton.new(config)
	local player = setmetatable({}, Player)
	player:_init(config)
	return player
end

return baton
