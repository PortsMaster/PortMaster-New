local Keyboard = {
	---@class Keys
	keys = {
		ANY = nil,
		A = "a",
		B = "b",
		C = "c",
		D = "d",
		E = "e",
		F = "f",
		G = "g",
		H = "h",
		I = "i",
		J = "j",
		K = "k",
		L = "l",
		M = "m",
		N = "n",
		O = "o",
		P = "p",
		Q = "q",
		R = "r",
		S = "s",
		T = "t",
		U = "u",
		V = "v",
		W = "w",
		X = "x",
		Y = "y",
		Z = "z",
		ZERO = "0",
		ONE = "1",
		TWO = "2",
		THREE = "3",
		FOUR = "4",
		FIVE = "5",
		SIX = "6",
		SEVEN = "7",
		EIGHT = "8",
		NINE = "9",
		PAGEUP = "pageup",
		PAGEDOWN = "pagedown",
		HOME = "home",
		END = "end",
		INSERT = "insert",
		ESCAPE = "escape",
		MINUS = "-",
		PLUS = "+",
		EQUAL = "=",
		DELETE = "delete",
		BACKSPACE = "backspace",
		LBRACKET = "[",
		RBRACKET = "]",
		BACKSLASH = "\\",
		CAPSLOCK = "capslock",
		SCROLL_LOCK = "scrolllock",
		NUMLOCK = "numlock",
		SEMICOLON = ";",
		QUOTE = "\'",
		ENTER = "return",
		SHIFT = "shift",
		COMMA = ",",
		PERIOD = ".",
		SLASH = "/",
		GRAVEACCENT = "`",
		CONTROL = "ctrl",
		ALT = "alt",
		SPACE = "space",
		UP = "up",
		DOWN = "down",
		LEFT = "left",
		RIGHT = "right",
		TAB = "tab",
		WINDOWS = "windows",
		MENU = "menu",
		PRINTSCREEN = "printscreen",
		BREAK = "pause",
		F1 = "f1",
		F2 = "f2",
		F3 = "f3",
		F4 = "f4",
		F5 = "f5",
		F6 = "f6",
		F7 = "f7",
		F8 = "f8",
		F9 = "f9",
		F10 = "f10",
		F11 = "f11",
		F12 = "f12",
		NUMPADZERO = "kp0",
		NUMPADONE = "kp1",
		NUMPADTWO = "kp2",
		NUMPADTHREE = "kp3",
		NUMPADFOUR = "kp4",
		NUMPADFIVE = "kp5",
		NUMPADSIX = "kp6",
		NUMPADSEVEN = "kp7",
		NUMPADEIGHT = "kp8",
		NUMPADNINE = "kp9",
		NUMPADMINUS = "kp-",
		NUMPADPLUS = "kp+",
		NUMPADPERIOD = "kp.",
		NUMPADMULTIPLY = "kp*",
		NUMPADSLASH = "kp/",
		MODE = "mode"
	},

	---@class {Key}
	keyValues = {},

	---@class justPressed:Keys
	justPressed = {},

	---@class pressed:Keys
	pressed = {},

	---@class justReleased:Keys
	justReleased = {},

	---@class released:Keys
	released = {},

	---@class modifierActive:Keys
	modifierActive = {
		CAPSLOCK = false,
		SCROLL_LOCK = false,
		NUMLOCK = false,
		MODE = false
	},

	---@type {}
	input = {
		---@class {string}
		justPressed = {},

		---@class {string}
		pressed = {},

		---@class {string}
		justReleased = {},

		---@class {string}
		released = {},
	},

	---@type {}
	loveInput = {
		---@class {string}
		justPressed = {},

		---@class {string}
		pressed = {},

		---@class {string}
		justReleased = {},

		---@class {string}
		released = {},
	}
}

local invalidKeys = {
	'escape', 'shift', 'windows', 'alt', 'ctrl', 'pageup', 'pagedown',
	'home', 'end', 'insert', 'delete', 'backspace', 'capslock', 'scrolllock',
	'numlock', 'return', 'left', 'down', 'up', 'right', 'tab', 'menu',
	'printscreen', 'pause', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8',
	'f9', 'f10', 'f11', 'f12'
}
local shiftKeys = {
	["0"] = "!",
	["1"] = "@",
	["2"] = "#",
	["3"] = "$",
	["4"] = "%",
	["5"] = "^",
	["6"] = "&",
	["7"] = "*",
	["8"] = "(",
	["9"] = ")",
	["-"] = "_",
	["="] = "+",
	["["] = "{",
	["]"] = "}",
	[";"] = ":",
	["'"] = '"',
	["`"] = "~",
	[","] = "<",
	["."] = ">",
	["/"] = "?",
	["\""] = "|"
}

for key, value in pairs(Keyboard.keys) do
	Keyboard.keyValues[value] = key
	Keyboard.released[key] = true
end

function Keyboard.reset()
	table.clear(Keyboard.justPressed)
	table.clear(Keyboard.justReleased)
	table.clear(Keyboard.input.justPressed)
	table.clear(Keyboard.input.justReleased)
	table.clear(Keyboard.loveInput.justPressed)
	table.clear(Keyboard.loveInput.justReleased)

	if love.keyboard.isModifierActive then
		for key in pairs(Keyboard.modifierActive) do
			Keyboard.modifierActive[key] = love.keyboard.isModifierActive(Keyboard.keys[key])
		end
	end
end

function Keyboard.onPressed(key)
	Keyboard.loveInput.justPressed[key] = true
	Keyboard.loveInput.pressed[key] = true
	Keyboard.loveInput.justReleased[key] = nil
	Keyboard.loveInput.released[key] = nil

	if not table.find(invalidKeys, key) then
		local key = key
		if key == 'space' then
			key = ' '
		elseif key:startsWith('kp') and not Keyboard.modifierActive.NUMLOCK then
			key = key:gsub('kp', '')
		end
		if Keyboard.pressed.SHIFT and shiftKeys[key] then
			key = shiftKeys[key]
		end

		Keyboard.input.justPressed[key] = true
		Keyboard.input.pressed[key] = true
		Keyboard.input.justReleased[key] = nil
		Keyboard.input.released[key] = nil
	end

	if key == 'kpenter' then key = "return" end
	if key == 'lshift' or key == 'rshift' then key = 'shift' end
	if key == 'lgui' or key == 'rgui' then key = 'windows' end
	if key == 'lalt' or key == 'ralt' then key = 'alt' end
	if key == 'lctrl' or key == 'rctrl' then key = 'ctrl' end
	if key == "=" then key = "+" end

	local value = Keyboard.keyValues[key]
	if not value then return end
	Keyboard.justPressed[value] = true
	Keyboard.pressed[value] = true
	Keyboard.justReleased[value] = nil
	Keyboard.released[value] = nil

	Keyboard.justPressed.ANY = true
	Keyboard.pressed.ANY = true
	Keyboard.justReleased.ANY = nil
	Keyboard.released.ANY = nil
end

function Keyboard.onReleased(key)
	Keyboard.loveInput.justReleased[key] = true
	Keyboard.loveInput.released[key] = true
	Keyboard.loveInput.justPressed[key] = nil
	Keyboard.loveInput.pressed[key] = nil

	if not table.find(invalidKeys, key) then
		local key = key
		if key == 'space' then
			key = ' '
		elseif key:startsWith('kp') and not Keyboard.modifierActive.NUMLOCK then
			key = key:gsub('kp', '')
		end
		if Keyboard.pressed.SHIFT and shiftKeys[key] then
			key = shiftKeys[key]
		end

		Keyboard.input.justReleased[key] = true
		Keyboard.input.released[key] = true
		Keyboard.input.justPressed[key] = nil
		Keyboard.input.pressed[key] = nil
	end

	if key == 'kpenter' then key = "return" end
	if key == 'lshift' or key == 'rshift' then key = 'shift' end
	if key == 'lgui' or key == 'rgui' then key = 'windows' end
	if key == 'lalt' or key == 'ralt' then key = 'alt' end
	if key == 'lctrl' or key == 'rctrl' then key = 'ctrl' end
	if key == "=" then key = "+" end

	local value = Keyboard.keyValues[key]
	if not value then return end
	Keyboard.justPressed[value] = nil
	Keyboard.pressed[value] = nil
	Keyboard.justReleased[value] = true
	Keyboard.released[value] = true

	Keyboard.justPressed.ANY = nil
	Keyboard.pressed.ANY = nil
	Keyboard.justReleased.ANY = true
	Keyboard.released.ANY = true
end

return Keyboard
