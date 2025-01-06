--[[ map_banner.lua
	version 1.0.1
	27 Aug 2020
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script draws the name of the current map on the the screen along with an optional
	banner (color fill). The displayed map name is a strings.dat entry with a key matching
	"location.map_id_suffix", where the map_id_suffix is the substring of the map_id after
	the last "/" character.
	
	Usage:
	local map_banner = require"scripts/menus/map_banner"
	sol.menu.start(map, map_banner)
--]]

local multi_events = require"scripts/multi_events"
local swipe_fade = require"scripts/fx/swipe_fade"
local language_manager = require"scripts/language_manager"

local menu = {}
multi_events:enable(menu)

--Configuration Settings
local Y_POSITION = 64 --(number, non-negative integer) number of pixels away from top/bottom edge (whichever is farther away from player)
local X_POSITION = 8 --(number, integer) number of pixels away from left edge if positive, or right edge if negative
local GRADIENT_WIDTH = 48 --(number, non-negative integer, optional) number of pixels for gradual transition to fully transparent on banner
	--use 0 for instant transition, use nil/false to have banner span full screen
local BANNER_COLOR = {60, 50, 0, 100} --yellowish --(table, array) RGBA values (0-255) for the banner color
local BANNER_SPEED = 256 --(number, positive integer) movement speed in pixels per second of the banner sliding on-screen
local TEXT_FADE_IN_FRAME_DELAY = 20 --(number, non-negative integer) delay time in milliseconds between text fade in frames, multiply by 31 to get total delay
local ACTIVE_DELAY = 2000 --(number, non-negative integer) delay time from end of fade in to start of swipe fade out in milliseconds
local SWIPE_TIME = 1200 --(number, non-negative integer) duration of the swipe fade-out of text in milliseconds
local FADE_OUT_WAIT = 500 --(number, non-negative integer) delay time in milliseconds between starting the swipe fade out (of text) and regular fade out
local FADE_OUT_FRAME_DELAY = 40 --(number, non-negative integer) delay time in milliseconds between fade out frames, multiply by 31 to get total delay

assert(not GRADIENT_WIDTH or GRADIENT_WIDTH >=0, "Error in 'map_banner': GRADIENT_WIDTH cannot be negative)")

--variables
local font, font_size, banner_height = language_manager:get_banner_font() --tentative until game starts
	--banner_height (number, non-negative integer, optional) height of banner in pixels, 0 or nil/false for no banner
local text_x, text_y
local banner_x, banner_Y
local delay_timer, swipe_timer, fade_timer

local banner_surface --(sol.surface) banner drawn behind map name text
local text_surface = sol.text_surface.create{ --(sol.text_surface) text of map name
	font = font,
	font_size = font_size,
	color = {255, 255, 255},
	horizontal_alignment = X_POSITION >= 0 and "left" or "right",
	vertical_alignment = "middle",
}
text_surface:fade_out(0) --start not visible

--update font each time a game starts
local game_meta = sol.main.get_metatable"game"
game_meta:register_event("on_started", function()
	local current_language = sol.language.get_language()
	font, font_size, banner_height = language_manager:get_banner_font()
	text_surface:set_font(font)
	if font_size then text_surface:set_font_size(font_size) end
	assert(not banner_height or banner_height >= 0, "Error in 'map_banner': banner_height cannot be negative)")
end)

--restore to initial conditions
local function reset()
	text_surface:set_shader(nil) --remove shader
	text_surface:fade_out(0)
	banner_surface = nil
	
	--stop any previously active timers
	if delay_timer then delay_timer:stop(); delay_timer = nil end
	if swipe_timer then swipe_timer:stop(); swipe_timer = nil end
	if fade_timer then fade_timer:stop(); fade_timer = nil end
end

function menu:on_started()
	local game = sol.main.get_game()
	local map = game:get_map()
	if not map then --don't draw banner if there is not an active map
		sol.menu.stop(self)
		return
	end
	
	reset()
	
	local hero = map:get_hero()
	local camera = map:get_camera()
	local map_id = map:get_id()
	local map_name = map_id:match"^.+%/(.*)$" or map_id
	
	--set map name text
	map_name = sol.language.get_string("location."..map_name)
	
	if not map_name or map_name:len()==0 then --don't draw banner if there isn't a string.dat entry for the map name
		sol.menu.stop(self)
		return
	else text_surface:set_text(map_name) end
	
	--determine position on screen
	local _, hero_y = hero:get_position()
	local _, camera_y = camera:get_position()
	local camera_width, camera_height = camera:get_size()
	local hero_screen_y = hero_y - camera_y --hero's position on screen
	text_y = hero_screen_y >= camera_height/2 and Y_POSITION or camera_height - Y_POSITION
	text_x = X_POSITION >=0 and X_POSITION or camera_width - X_POSITION
	
	--create banner drawn behind text
	if banner_height and banner_height>0 then
		banner_y = text_y - banner_height/2
	
		--create gradient to transparent on edge of banner
		if GRADIENT_WIDTH then --gradually make banner fully transparent at end of banner
			--create surface for banner
			local banner_width,_ = text_surface:get_size()
			local banner_main_width = banner_width + 2*math.abs(X_POSITION) --non-gradient width of banner
			banner_width = banner_main_width + GRADIENT_WIDTH
			banner_surface = sol.surface.create(banner_width, banner_height) --full screen width
			
			--calculate position of banner gradient
			local x_main_start --x coordinate for start of non-gradient portion of banner
			local x_start, x_stop --x start & stop coordinates in pixels for banner gradient
			local gradient_dir --1 or -1 if banner is on left or right side of screen
			if X_POSITION >= 0 then --banner on left side of screen
				x_main_start = 0
				x_start = banner_main_width
				x_stop = banner_width
				gradient_dir = 1
				banner_x = 0 --banner starts at left edge of screen
				banner_surface:set_xy(-banner_width, 0)
			else
				x_main_start = GRADIENT_WIDTH
				x_start = GRADIENT_WIDTH
				x_stop = 1
				gradient_dir = -1
				banner_x = camera_width - banner_width --position of banner left edge to make right edge flush with right side of screen
				banner_surface:set_xy(banner_width, 0)
			end
			
			--draw banner with gradient
			banner_surface:fill_color( --draw non-gradient portion
				BANNER_COLOR,
				x_main_start, 0,
				banner_main_width, banner_height
			)
			for x = x_start,x_stop,gradient_dir do
				local x_alpha = (math.abs(x_stop - x) + 1)/(GRADIENT_WIDTH + 1) --value from 0 to 1 depending on horizontal position
                local alpha_value
                if type(BANNER_COLOR) == "table" and #BANNER_COLOR >= 4 then
                    alpha_value = math.floor((BANNER_COLOR[4] or 255) * x_alpha)
                else
                    BANNER_COLOR = {255, 255, 255, 255}  -- Fallback to a default value if the condition is not met
                    alpha_value = math.floor(255 * x_alpha)  -- Default alpha value if BANNER_COLOR is invalid
                end

                local gradient_color = {
                    BANNER_COLOR[1],
                    BANNER_COLOR[2],
                    BANNER_COLOR[3],
                    alpha_value
                }
				--draw 1 pixel wide segment with alpha reduced by amount proportional to position
				banner_surface:fill_color(gradient_color, x, 0, 1, banner_height)
			end
		else --banner width fills entire screen with no gradient
			banner_x = 0 --banner starts at left edge of screen
			
			banner_surface = sol.surface.create(camera_width, banner_height)
			banner_surface:fill_color(BANNER_COLOR)
			banner_surface:set_xy(X_POSITION>=0 and -camera_width or camera_width, 0) --start with banner offscreen then slide over
		end
	end
	
	--callback function for closing animation
	local function fade_out_cb()
		if sol.menu.is_started(menu) then
			delay_timer = sol.timer.start(map, ACTIVE_DELAY, function() --duration to wait before beginning fade-out
				swipe_timer = swipe_fade:start_effect(text_surface, map, SWIPE_TIME)
				
				--add short delay before beginning banner fade-out
				fade_timer = sol.timer.start(map, FADE_OUT_WAIT, function()
					if banner_surface then
						banner_surface:fade_out(FADE_OUT_FRAME_DELAY, function()
							sol.menu.stop(self)
						end)
					else sol.menu.stop(self) end
				end)
			end)
		end
	end
	
	--begin opening animation, wait, then begin closing animation
	if banner_surface then
		local movement = sol.movement.create"target"
		movement:set_speed(BANNER_SPEED)
		movement:set_target(0, 0)
		movement:start(banner_surface, function()
			text_surface:fade_in(TEXT_FADE_IN_FRAME_DELAY, fade_out_cb)
		end)
	else text_surface:fade_in(TEXT_FADE_IN_FRAME_DELAY, fade_out_cb) end
end

function menu:on_finished()
	reset()
end

function menu:on_draw(dst_surface)
	if banner_surface then banner_surface:draw(dst_surface, banner_x, banner_y) end
	text_surface:draw(dst_surface, text_x, text_y)
end

return menu

--[[ Copyright 2019-2020 Llamazing
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
