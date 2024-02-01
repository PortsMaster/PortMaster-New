--[[ command_binding_manager.lua
	version 1.0.2
	12 Feb 2021
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script manages keyboard and joypad inputs, binding them to commands, saving them to
	the settings.dat file in the quest write directory (preserving them from one playthrough
	to the next). Also allows for creating custom commands beyond the built-in ones from the
	Solarus engine.
	
	Usage:
	local commands_manager = require"scripts/misc/command_binding_manager"
	commands_manager:init() --call in at least one script after sol.main:on_started() and before first use
--]]

require("scripts/multi_events")
local settings = require("scripts/settings")

local manager = {}

local BUILTIN_COUNT = 9
local COMMAND_NAMES = {
  "up", "down", "left", "right", "action", "attack", "item_1", "item_2", "pause",
  --custom commands:
  "next_menu", "prev_menu", "menu_1", "menu_2", "menu_3", "menu_4",
}
--reverse lookup: built-in commands set to true, custom commands false
for i,command in ipairs(COMMAND_NAMES) do COMMAND_NAMES[command] = i<=BUILTIN_COUNT end

local JOYPAD_INPUTS = {
  button = true,
  axis = true,
  hat = true,
}

--list of valid hat directions as strings
local HAT_DIRECTIONS = {
  up = true,
  left = true,
  right = true,
  down = true,
}

--convert hat direction as integer (0-7) to string
local HAT_CONVERSIONS = {
  [0] = "right",
  [1] = "right",
  [2] = "up",
  [3] = "left",
  [4] = "left",
  [5] = "left",
  [6] = "down",
  [7] = "right",
}

--command names as keys with joypad buttons as values
local DEFAULT_KEY_BINDS = {
  up = "up",
  down = "down",
  left = "left",
  right = "right",
  action = "space",
  attack = "c",
  pause = "d",
  item_1 = "x",
  item_2 = "v",
  --custom commands
  prev_menu = "f",
  next_menu = "g",
  menu_1 = "f2",
  menu_2 = "f3",
  menu_3 = "f4",
  menu_4 = "f5",
}

--command names as keys with joypad buttons as values
local DEFAULT_BUTTON_BINDS = {
  up = nil,
  down = nil,
  left = nil,
  right = nil,
  action = nil,
  attack = nil,
  pause = nil,
  item_1 = nil,
  item_2 = nil,
  --custom_commands
  prev_menu = nil,
  next_menu = nil,
}

--Do not allow binding to these keys
local FORBIDDEN_KEYS = {
  escape = true,
  f1 = true,
  f11 = true,
  ['left meta'] = true,
  ['right meta'] = true,
  ['\\'] = true,
}

local JOYPAD_INPUTS = {"button", "axis", "hat"}
for i,input in ipairs(JOYPAD_INPUTS) do JOYPAD_INPUTS[input] = true end --reverse lookup

--convenience
local math__floor = math.floor

local is_capturing_input = false --intercept key & button presses while true when capturing input
local capture_command --(string) name of command currently being captured, or nil if not set
local capture_cb --function to call after command captured, or nil of not set

--(table, key/value) given keyboard key or joypad string (string) as key, find command (string) as value
local binds_lookup = {}

--// Call once from any script after sol.main:on_started() but before using the settings manager script
  --ensures default settings are applied for when new settings file is created
  --Okay to call multiple times but additional calls do nothing
local is_loaded
function manager:init()
  if not is_loaded then
    --check if default bindings set (set exactly once after creating new settings file)
    local custom_settings_value = settings:get_value"custom_settings"
    if custom_settings_value == true then --v1.0.0 of settings.dat
      --clear existing bindings (old version of settings.dat file)
      for i,command in ipairs(COMMAND_NAMES) do
        settings:set_value("keyboard_"..command, nil)
        settings:set_value("joypad_"..command, nil)
      end
      custom_settings_value = nil
    end

    if not custom_settings_value then
      --set default bindings
      for command,value in pairs(DEFAULT_BUTTON_BINDS) do
        settings:set_value("joypad_"..command, value)
      end
      for command,value in pairs(DEFAULT_KEY_BINDS) do
        settings:set_value("keyboard_"..command, value)
      end
      settings:set_value("custom_settings", "bindings_applied") --default bindings now set
        --v1.0.0 sets value to true
        --v1.0.1 sets value to "bindings_applied"
      settings:save()
    end
    
    --read back all saved commands and store in memory
    for command,_ in pairs(DEFAULT_KEY_BINDS) do
      local key = settings:get_value("keyboard_"..command)
      if key then binds_lookup[key] = command end
      
      local joypad_string = settings:get_value("joypad_"..command)
      if joypad_string then binds_lookup[joypad_string] = command end
    end
    is_loaded = true
  end
end

function manager:get_command_keyboard_binding(command)
  assert(type(command)=="string", "Bad argument #1 to 'get_command_keyboard_binding' (string expected)")
  assert(COMMAND_NAMES[command]~=nil, "Bad argument #1 to 'get_command_keyboard_binding', invalid command: "..command)
  
  local game = sol.main.get_game()
  if game and COMMAND_NAMES[command] then
    return game:get_command_keyboard_binding(command)
  else return settings:get_value("keyboard_"..command) end
end

local function set_key_bind(command, key)
  local old_command = binds_lookup[key] --command that used to be bound to this key
  local old_key = settings:get_value("keyboard_"..command) --key that command used to be bound to
  
  --swap key bindings
  settings:set_value("keyboard_"..command, key)
  if old_command then settings:set_value("keyboard_"..old_command, old_key) end
  
  --swap reverse lookup too
  binds_lookup[key] = command
  if old_key then binds_lookup[old_key] = old_command end

  --swap built-in commands if applicable
  local game = sol.main.get_game()
  if game then
    --overwrite existing built-in commands in savegame data
    if COMMAND_NAMES[command] then
      game:set_command_keyboard_binding(command, key)
    end
    if COMMAND_NAMES[old_command] then
      game:set_command_keyboard_binding(old_command, old_key or nil)
    end
  end --NOTE: else will be assigned when game starts
end
function manager:set_command_keyboard_binding(command, key)
  assert(type(command)=="string", "Bad argument #1 to 'set_command_keyboard_binding' (string expected)")
  assert(COMMAND_NAMES[command]~=nil, "Bad argument #1 to 'get_command_keyboard_binding', invalid command: "..command)
  assert(not key or type(key)=="string", "Bad argument #2 to 'set_command_keyboard_binding' (string or nil expected)")
  --if invalid key then sol.input.is_key_pressed() throws an error
  assert(pcall(function() sol.input.is_key_pressed(key) end), "Bad argument #2 to 'set_command_keyboard_binding', invalid key: "..key)
  
  set_key_bind(command, key)
  settings:save()
end

function manager:get_command_joypad_binding(command)
  assert(type(command)=="string", "Bad argument #1 to 'get_command_keyboard_binding' (string expected)")
  assert(COMMAND_NAMES[command]~=nil, "Bad argument #1 to 'get_command_keyboard_binding', invalid command: "..command)
  
  local game = sol.main.get_game()
  if game and COMMAND_NAMES[command] then
    return game:get_command_joypad_binding(command)
  else return settings:get_value("joypad_"..command) end
end

local function set_joypad_bind(command, joypad_string)
  local old_command = binds_lookup[joypad_string]
  local old_joypad_string = settings:get_value("joypad_"..command)
  
  --swap joypad bindings
  settings:set_value("joypad_"..command, joypad_string)
  if old_command then settings:set_value("joypad_"..old_command, old_joypad_string) end
  
  --swap reverse lookup too
  binds_lookup[joypad_string] = command
  if old_joypad_string then binds_lookup[old_joypad_string] = old_command end
  
  --swap built-in commands if applicable
  local game = sol.main.get_game()
  if game then
    --overwrite existing built-in commands in savegame data
    if COMMAND_NAMES[command] then
      game:set_command_joypad_binding(command, joypad_string)
    end
    if COMMAND_NAMES[old_command] then
      game:set_command_joypad_binding(old_command, old_joypad_string or nil)
    end
  end --NOTE: else will be assigned when game starts
end
function manager:set_command_joypad_binding(command, joypad_string)
  assert(type(command)=="string", "Bad argument #1 to 'set_command_keyboard_binding' (string expected)")
  assert(COMMAND_NAMES[command]~=nil, "Bad argument #1 to 'get_command_keyboard_binding', invalid command: "..command)
  assert(not joypad_string or type(joypad_string)=="string", "Bad argument #2 to 'set_command_joypad_binding' (string or nil expected)")

  --test if valid joypad_string
  local input_type, index, direction = joypad_string:match"^(%S+)%s(%S+)%s?(%S*)$"
  assert(input_type, "Bad argument #2 to 'set_command_joypad_binding', invalid joypad string: "..joypad_string)
  assert(JOYPAD_INPUTS[input_type], "Bad argument #2 to 'set_command_joypad_binding', invalid input type: "..input_type)
  local index_num = tonumber(index)
  assert(index_num, "Bad argument #2 to 'set_command_joypad_binding', invalid index (number expected)")
  index_num = math__floor(index_num)
  assert(index_num>=0, "Bad argument #2 to 'set_command_joypad_binding' (index value must not be negative)")
  if input_type=="button" then
    assert(direction=="", "Bad argument #2 to 'set_command_joypad_binding', must not specify direction for button input")
  elseif input_type=="axis" then
    assert(direction=="-" or direction=="+", "Bad argument #2 to 'set_command_joypad_binding', direction must be - or + for axis input")
  elseif input_type=="hat" then
    assert(HAT_DIRECTIONS[direction], "Bad argument #2 to 'set_command_joypad_binding', direction not valid: "..direction)
  end

  set_joypad_bind(command, joypad_string)
  settings:save()
end

function manager:get_command_from_key(key)
  assert(type(key)=="string", "Bad argument #1 to 'get_command_from_key' (string expected)")
  return binds_lookup[key]
end

function manager:get_command_from_joypad(joypad_string)
  assert(type(joypad_string)=="string", "Bad argument #1 to 'get_command_from_joypad' (string expected)")
  return binds_lookup[joypad_string]
end

function manager:get_command_from_button(button)
  local button_value = tonumber(button)
  assert(button_value, "Bad argument #1 to 'get_command_from_button' (number expected)")
  button_value = math__floor(button_value)
  assert(button_value>=0, "Bad argument #1 to 'get_command_from_button', number value must be non-negative")
  
  local joypad_string = string.format("button %d", button_value)
  return binds_lookup[joypad_string]
end

function manager:get_command_from_axis(axis, state)
  local axis_value = tonumber(axis)
  assert(axis_value, "Bad argument #1 to 'get_command_from_axis' (number expected)")
  axis_value = math__floor(axis_value)
  assert(axis_value>=0, "Bad argument #1 to 'get_command_from_axis', number value must be non-negative")
  
  local state_value = tonumber(state)
  assert(state_value, "Bad argument #2 to 'get_command_from_axis' (number expected)")
  state_value = math__floor(state_value)
  assert(state_value>=-1 and state_value<=1, "Bad argument #2 to 'get_command_from_axis', number value must be between -1 and 1")
  if state_value==0 then return end
  
  local joypad_string = string.format("axis %d %s", axis_value, state_value<0 and "-" or "+")
  return binds_lookup[joypad_string]
end

function manager:get_command_from_hat(hat, direction8)
  local hat_value = tonumber(hat)
  assert(hat_value, "Bad argument #1 to 'get_command_from_hat' (number expected)")
  hat_value = math__floor(hat_value)
  assert(hat_value>=0, "Bad argument #1 to 'get_command_from_hat', number must be non-negative")
  
  local dir8_value = tonumber(direction8)
  assert(dir8_value, "Bad argument #2 to 'get_command_from_hat' (number expected)")
  dir8_value = math__floor(dir8_value)
  if dir8_value==-1 then return end --ignore neutral hat position
  assert(dir8_value>=0, "Bad argument #2 to 'get_command_from_hat', number value must be non-negative")
  assert(dir8_value<=7, "Bad argument #2 to 'get_command_from_hat', number value must not be greater than 7")
  
  local dir_string = HAT_CONVERSIONS[dir8_value]
  local joypad_string = string.format("hat %d %s", hat_value, dir_string)
  return binds_lookup[joypad_string]
end

function manager:capture_command_binding(command, callback)
  is_capturing_input = true
  capture_command = command
  capture_cb = callback
end

local function stop_capturing(input_type, key)
  --stop capturing input
  is_capturing_input = false
  if capture_cb then
    capture_cb(capture_command, key)
    capture_cb = nil
  end
  capture_command = nil
end

sol.main:register_event("on_key_pressed", function(self, key, modifiers)
  local handled = false --tentative
  if is_capturing_input then
    --bind captured input
    if not key or not FORBIDDEN_KEYS[key] then --ignore escape and function keys
      manager:set_command_keyboard_binding(capture_command, key)
    end

    stop_capturing("keyboard", key)
    handled = true
  end

  return handled
end)

sol.main:register_event("on_joypad_button_pressed")
sol.main:register_event("on_joypad_axis_moved")
sol.main:register_event("on_joypad_hat_moved")

--// Resets all control bindings to defaults
function manager:reset_defaults()
  is_loaded = nil
  binds_lookup = {}

  settings:set_value("custom_settings", "bindings_applied")

  --erase all bindings from settings.dat
  for _,command in ipairs(COMMAND_NAMES) do
    settings:set_value("keyboard_"..command, nil)
    settings:set_value("joypad_"..command, nil)
  end

  self:init() --copies default bindings to settings file

  --if game active then copy built-in commands to game
  local game = sol.main.get_game()
  if game then
    copy_to_game(game)
  end
end

--copy bindings over to game when game is started
local game_meta = sol.main.get_metatable"game"
game_meta:register_event("on_started", function(game)
  copy_to_game(game)
end)

return manager

--[[ Copyright 2020-2021 Llamazing
  [] 
  [] This program is free software: you can redistribute it and/or modify it under the
  [] terms of the GNU General Public License as published by the Free Software Foundation,
  [] either version 3 of the License, or (at your option) any later version.
  [] 
  [] It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  [] without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  [] PURPOSE.  See the GNU General Public License for more details.
  [] 
  [] You should have received a copy of the GNU General Public License along with this
  [] program.  If not, see <http://www.gnu.org/licenses/>.
  ]]
