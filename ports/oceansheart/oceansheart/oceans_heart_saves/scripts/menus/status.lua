local multi_events = require"scripts/multi_events"
local button_menu = require"scripts/menus/button_mapping"
local controls_display_switch = require"scripts/menus/controls_display_switch"
local settings = require"scripts/settings"

local status_screen = {x=0,y=0}
multi_events:enable(status_screen)

local cursor_index
local MAX_INDEX = 6
local music_level = 0
local sound_level = 0
local dialog_size = 3

local font, font_size = require("scripts/language_manager"):get_menu_font()

local background_image = sol.surface.create("menus/status_background.png")
local cursor_sprite = sol.sprite.create("menus/cursor")
local screenshake_toggle_sprite = sol.sprite.create"menus/toggle_switch"
local music_sprite = sol.sprite.create("menus/slider")
local sound_sprite = sol.sprite.create("menus/slider")
local dialog_size_sprite = sol.sprite.create("menus/slider")
local stats_box = sol.surface.create(144, 48)
local text_surface = sol.text_surface.create({
        font = font, font_size = font_size,
        vertical_alignment = "top",
        horizontal_alignment = "left",
})


local button_text_surfaces = {}
local stat_name_surfaces = {}
local options_strings = {}

local stat_variables = {
  "sword_damage", "defense", "bow_damage"
}
local stat_names = {
  "menu.status.stats.sword_damage", "menu.status.stats.armor_level", "menu.status.stats.bow_damage"
}



--// Gets/sets the x,y position of the menu in pixels
function status_screen:get_xy() return self.x, self.y end
function status_screen:set_xy(x, y)
	x = tonumber(x)
	assert(x, "Bad argument #2 to 'set_xy' (number expected)")
	y = tonumber(y)
	assert(y, "Bad argument #3 to 'set_xy' (number expected)")
	
	self.x = math.floor(x)
	self.y = math.floor(y)
end


function status_screen:on_started()
  font, font_size = require("scripts/language_manager"):get_menu_font()

  for i=1, #stat_names do
    stat_name_surfaces[i] = sol.text_surface.create({
        font = font, font_size = font_size,
        vertical_alignment = "top",
        horizontal_alignment = "left",
    })
    --stat_name_surfaces[i]:set_text_key(stat_names[i])
  end

    options_strings = {
        sol.language.get_string("menu.status.save") or "Save",
        sol.language.get_string("menu.status.quit") or "Quit",
        sol.language.get_string("menu.status.controls") or "Controls",
        sol.language.get_string("menu.status.screenshake") or "Screenshake",
        sol.language.get_string("menu.status.music") or "Music",
        sol.language.get_string("menu.status.sounds") or "Sounds",
        sol.language.get_string("menu.status.dialog_size") or "Dialog Size",
    }
  for i=1, #options_strings do
    button_text_surfaces[i] = sol.text_surface.create({
        font = font, font_size = font_size,
        vertical_alignment = "top",
        horizontal_alignment = "left",
    })
    button_text_surfaces[i]:set_text(options_strings[i])
  end

  local game = sol.main.get_game()
  status_screen:update_volume_levels()
  local dialog_size_options = {
    big = 3,
    little = 2,
    really_little = 1,
  }
  dialog_size = (dialog_size_options[game:get_value("dialog_box_size_mode")] or 3)
  cursor_index = 0
  local game = sol.main.get_game()
  assert(game, "Error: cannot start status menu because no game is currently running")

  if game:get_value("screenshake_disabled") then
    screenshake_toggle_sprite:set_animation("off")
  else
    screenshake_toggle_sprite:set_animation("on")
  end

  for i=1, #stat_variables do
    local label = stat_names[i]
    local number = game:get_value(stat_variables[i])
    stat_name_surfaces[i]:set_text(
      sol.language.get_string(label) .. ": " .. number
    )
  end
  if not game:has_item"bow" then
    stat_name_surfaces[3]:set_text("-")
  end
  if not game:has_ability"sword" then
    stat_name_surfaces[1]:set_text("-")
  end
end


function status_screen:on_command_pressed(command)
  local handled = false
  if command == "up" then
    sol.audio.play_sound("cursor")
    cursor_index = cursor_index -1
    if cursor_index < 0 then cursor_index = MAX_INDEX end
    handled = true
  elseif command == "down" then
    sol.audio.play_sound("cursor")
    cursor_index = cursor_index + 1
    if cursor_index > MAX_INDEX then cursor_index = 0 end
    handled = true
  elseif command == "action" then
    status_screen:process_selection()
    handled = true
  elseif command == "left" then
    if cursor_index >= 3 then
      status_screen:process_direction("left")
      handled = true
    end
  elseif command == "right" then
    if cursor_index >= 3 then
      status_screen:process_direction("right")
      handled = true
    end
  end
  return handled
end


function status_screen:process_selection()
  local game = sol.main.get_game()
  if cursor_index == 0 then --save
    local total_playtime = game:get_value("total_playtime") or 0
    total_playtime = total_playtime + sol.main.get_elapsed_time()
    game:set_value("total_playtime", total_playtime)
    game:set_starting_location(game:get_value"respawn_map")
    game:save()
    sol.audio.play_sound("elixer_upgrade")
    if not game:is_dialog_enabled() then game:start_dialog("_game.game_saved") end

  elseif cursor_index == 1 and not game:is_dialog_enabled() then --quit
    game:start_dialog("_game.save_question", function(answer)
      if answer == 2 then --save first
        game:set_starting_location(game:get_value"respawn_map")
        game:save()
        game:start_dialog("_game.game_saved", function()
          sol.timer.start(game, 100, function() sol.main.reset() end)
        end)
      else --don't save
        sol.timer.start(game, 100, function() sol.main.reset() end)
      end

    end)

  elseif cursor_index == 2 then --controls
    --check OS
    if sol.main.get_os() == "Nintendo Switch" then
      sol.menu.start(game, controls_display_switch)
    else
      sol.menu.start(game, button_menu)
    end

  elseif cursor_index == 3 then --screenshake
    status_screen:process_direction()
  end

  --Save settings in case any were changed
  settings:save()
end

function status_screen:process_direction(direction)
  local game = sol.main.get_game()
  local increment = 0
  if direction == "left" then increment = -10
  elseif direction == "right" then increment = 10 end

  if cursor_index == 3 then --screenshake
    game:set_value("screenshake_disabled", not game:get_value"screenshake_disabled")
    sol.audio.play_sound"cursor_low"
    if game:get_value("screenshake_disabled") then
      screenshake_toggle_sprite:set_animation("off")
    else
      screenshake_toggle_sprite:set_animation("on")
      game:get_map():get_camera():shake()
    end

  elseif cursor_index == 4 then --music
    sol.audio.set_music_volume(sol.audio.get_music_volume() + increment)
    sol.audio.play_sound("cursor_low")

  elseif cursor_index == 5 then --sounds
    sol.audio.set_sound_volume(sol.audio.get_sound_volume() + increment)
    sol.audio.play_sound("cursor_low")

  elseif cursor_index == 6 then --dialog size
    sol.audio.play_sound("cursor_low")
    local dialog_size_options = {"really_little", "little", "big"}
    if direction == "left" then dialog_size = dialog_size - 1
    elseif direction == "right" then dialog_size = dialog_size + 1 end
    if dialog_size > 3 then dialog_size = 3 end
    if dialog_size < 1 then dialog_size = 1 end
    sol.main.get_game():set_value("dialog_box_size_mode", dialog_size_options[dialog_size])
    if dialog_size < 3 then
      game:get_dialog_box():set_position("bottom")
    else
      game:get_dialog_box():set_position("auto")
    end
  end
  status_screen:update_volume_levels()
end

function status_screen:update_volume_levels()
  music_level = sol.audio.get_music_volume()
  sound_level = sol.audio.get_sound_volume()
  local game = sol.main.get_game()
  game:set_value("music_volume", music_level)
  game:set_value("sound_volume", sound_level)
end

local stuff_ox, stuff_oy = 74, 12
function status_screen:on_draw(dst)
  background_image:draw(dst, self.x, self.y)
--  stats_box:draw(dst, 210 + self.x, 162 + self.y)
  cursor_sprite:draw(dst,stuff_ox - 8 + self.x, stuff_oy + 6 + self.y + cursor_index*32)
  screenshake_toggle_sprite:draw(dst, stuff_ox + 30 + self.x, stuff_oy + 118 + self.y)
  music_sprite:draw(dst, stuff_ox + 6 + music_level/2 + self.x, stuff_oy + 150 + self.y)
  sound_sprite:draw(dst, stuff_ox + 6 + sound_level/2 + self.x, stuff_oy + 181 + self.y)
  dialog_size_sprite:draw(dst, stuff_ox + 6 + (dialog_size-1)*25 + self.x, stuff_oy + 213 + self.y)
  
  for i=1, #options_strings do
    button_text_surfaces[i]:draw(dst,stuff_ox +self.x, 12 +self.y+ (i-1)*32)
  end
  for i=1, #stat_names do
    stat_name_surfaces[i]:draw(dst,210 +self.x, 146 +self.y+ (i-1)*16)
  end

end


--Avoid analog stick from jumping wildly:
local joy_avoid_repeat = {-2, -2}
function status_screen:on_joypad_axis_moved(axis, state)  

  local handled = joy_avoid_repeat[axis] == state
  joy_avoid_repeat[axis] = state      

  return handled
end


return status_screen