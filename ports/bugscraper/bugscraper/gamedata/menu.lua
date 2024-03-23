require "util"
local Class = require "class"
local images = require "data.images"
local sounds = require "data.sounds"

-- Help. If you are the poor sod sent to modify the code within 
-- this, be warned: it's a mess.

local MenuItem = Class:inherit()
function MenuItem:init_menuitem(i, x, y)
	self.i = i
	self.x = x
	self.y = y

	self.is_selected = false
end

function MenuItem:update_menuitem(dt)

end

function MenuItem:on_click()
end

------------

local TextMenuItem = MenuItem:inherit()

-- Split into SelectableMenuItem ? Am I becoming a Java dev now?
-- THIS IS A MESS, *HELP*
-- AAAAAAAAAAAAAAAAAAAAAAAAAAAAA
-- Should do:
-- MenuItem
-- -> TextMenuItem
-- -> SelectableMenuItem
--   -> ToggleMenuItem
--   -> SliderMenuItem
function TextMenuItem:init(i, x, y, text, on_click, update_value)
	self:init_textitem(i, x, y, text, on_click, update_value)
end
function TextMenuItem:init_textitem(i, x, y, text, on_click, update_value)
	self:init_menuitem(i, x, y)

	self.ox = 0
	self.oy = 0
	self.text = text or ""
	self.label_text = self.text
	self.value_text = ""

	self.value = nil
	self.type = "text"

	if on_click and type(on_click) == "function" then
		self.on_click = on_click
		self.is_selectable = true
	else
		self.is_selectable = false
	end

	-- -- Custom update value function
	-- if custom_update_value then
	-- 	self.update_value = custom_update_value
	-- end

	self.update_value = update_value or function() end

	-- if default_val ~= nil then
	-- 	self:update_value(default_val)
	-- end
end

function TextMenuItem:update(dt)
	self:update_textitem(dt)
end
function TextMenuItem:update_textitem(dt)
	self:update_value()

	self.ox = lerp(self.ox, 0, 0.3)
	self.oy = lerp(self.oy, 0, 0.3)

	if type(self.value) ~= "nil" then
		self.text = concat(self.label_text, ": ", self.value_text)
	else
		self.text = self.label_text
	end
end

function TextMenuItem:draw()
	self:draw_textitem()
end
function TextMenuItem:draw_textitem()
	gfx.setColor(1, 1, 1, 1)
	local th = get_text_height(self.text)
	if self.is_selected then
		-- rect_color_centered(COL_LIGHT_YELLOW, "fill", self.x, self.y+th*0.4, get_text_width(self.text)+8, th/4)
		-- rect_color_centered(COL_WHITE, "fill", self.x, self.y, get_text_width(self.text)+32, th)
		print_centered_outline(COL_WHITE, COL_ORANGE, self.text, self.x + self.ox, self.y + self.oy)
		-- print_centered(self.text, self.x, self.y)
	else
		if not self.is_selectable then
			local v = 0.5
			gfx.setColor(v, v, v, 1)
		end
		print_centered(self.text, self.x, self.y + self.oy)
	end
	gfx.setColor(1, 1, 1, 1)
end

function TextMenuItem:set_selected(val, diff)
	self.is_selected = val
	if val then
		self.oy = sign(diff or 1) * 4
	end
end

function TextMenuItem:after_click()
	options:update_options_file()
	audio:play("menu_select")
	self.oy = -4
end

--------

local SliderMenuItem = TextMenuItem:inherit()

function SliderMenuItem:init(i, x, y, text, on_click, values, update_value)
	self:init_textitem(i, x, y)

	self.ox = 0
	self.oy = 0
	self.text = text or ""
	self.label_text = self.text
	self.value_text = ""

	self.values = values
	self.value_index = 1
	self.value = values[1]
	self.value_text = tostring(self.value)

	self.on_click = on_click
	self.is_selectable = true

	self.update_value = update_value
end

function SliderMenuItem:update(dt)
	self.ox = lerp(self.ox, 0, 0.3)
	self.oy = lerp(self.oy, 0, 0.3)
	
	self:update_value()

	if type(self.value) ~= "nil" then
		self.text = concat(self.label_text, ": < ", self.value_text, " >")
	else
		self.text = self.label_text
	end

	if game:button_pressed("left") and self.is_selected then
		self:on_click(-1)
		self:after_click(-1)
	end
	if game:button_pressed("right") and self.is_selected then
		self:on_click(1)
		self:after_click(1)
	end
end

function SliderMenuItem:set_selected(val, diff)
	self.is_selected = val
	if val then
		self.oy = sign(diff or 1) * 4
	end
end

function SliderMenuItem:next_value(diff)
	diff = diff or 1
	self.value_index = mod_plus_1(self.value_index + diff, #self.values)
	self.value = self.values[self.value_index]
	self.value_text = tostring(self.value)
end

function SliderMenuItem:after_click(diff)
	diff = diff or 1
	self.ox = sign(diff) * 6
	options:update_options_file()

	-- TODO: rising pitch or decreasing pitch
	-- + sound preview for music & sfx
	-- audio:play("menu_select)
end


--------

local StatsMenuItem = TextMenuItem:inherit()

function StatsMenuItem:init(i, x, y, text, get_value)
	self:init_textitem(i, x, y, text)
	self.get_value = get_value
	self.value = nil
end

function StatsMenuItem:update(dt)
	self:update_textitem(dt)
	self.value = self:get_value()
	self.value_text = tostring(self.value)
end

--------

local ControlsMenuItem = TextMenuItem:inherit()

function ControlsMenuItem:init(i, x, y, button_name, button_id)
	self:init_textitem(i, x, y, button_name)
	self.button_name = button_name
	self.button_id = button_id
	self.controls = options:get_controls(1, button_id)
	
	self.key = nil
	self.scancode = nil
	
	self.is_waiting_for_input = false
	self.is_selectable = true
end

function ControlsMenuItem:update(dt)
	self:update_textitem(dt)
	
	local controls = options:get_controls(1, self.button_id)
	local controlskey = {}
	for i=1, #controls do
		table.insert(controlskey, love.keyboard.getKeyFromScancode(controls[i]))
	end
	local txt = string.upper(concatsep(controlskey, " / "))

	self.text = concat(table_to_str(self.button_name), ": [", txt, "]")
	if self.is_waiting_for_input then
		self.text = concat(self.button_name, ": [PRESS A KEY]")
	end
end

function ControlsMenuItem:on_click()
	if self.is_waiting_for_input then return end
	if not self.is_selectable then return end

	-- Go in standby mode
	options:update_options_file()
	audio:play("menu_select")
	self.oy = -4
	
	self.is_waiting_for_input = true
	-- self.is_selectable = false
end

function ControlsMenuItem:keypressed(key, scancode, isrepeat)
	if scancode == "escape" then
		self.is_waiting_for_input = false
		-- self.is_selectable = true
	end
	
	-- Apply new key control
	if self.is_waiting_for_input then
		self.is_waiting_for_input = false
		-- self.is_selectable = true
		
		local is_valid = options:check_if_key_in_use(scancode)
		if not is_valid then return end

		self.value = scancode

		self.key = key
		self.scancode = scancode
		options:set_button_bind(1, self.button_id, scancode)
		-- self.value_text = key
	end
end

--------

local CustomDrawMenuItem = MenuItem:inherit()

function CustomDrawMenuItem:init(i, x, y, custom_draw)
	self:init_menuitem(i, x, y)
	self.draw = custom_draw
end

--------

local Menu = Class:inherit()

function Menu:init(game, items, bg_color)
	self.items = {}
	self.is_menu = true

	local th = get_text_height()
	local h = (#items - 1) * th
	local start_y = CANVAS_HEIGHT / 2 - h / 2
	for i, parms in pairs(items) do
		local parm1 = parms[1]
		if type(parm1) == "string" then
			self.items[i] = TextMenuItem:new(i, CANVAS_WIDTH / 2, start_y + (i - 1) * th, unpack(parms))
		else
			local class = table.remove(parms, 1)
			self.items[i] = class:new(i, CANVAS_WIDTH / 2, start_y + (i - 1) * th, unpack(parms))
		end
	end

	self.bg_color = bg_color or { 1, 1, 1, 0 }
end

function Menu:update(dt)
	for i, item in pairs(self.items) do
		item:update(dt)
	end
end

function Menu:draw()
	for i, item in pairs(self.items) do
		item:draw()
	end
end

-----------

function func_set_menu(menu)
	return function()
		game.menu:set_menu(menu)
	end
end

function func_url(url)
	return function()
		love.system.openURL(url)
	end
end

-----------

local MenuManager = Class:inherit()

function MenuManager:init(game)
	self.game = game
	self.menus = {}

	-----------------------------------------------------
	------ [[[[[[[[[[[[[[[[ MENUS ]]]]]]]]]]]]]]]] ------
	-----------------------------------------------------

	-- FIXME: This is messy, eamble multiple types of menuitems
	-- This is so goddamn overengineered and needlessly complicated
	self.menus.title = Menu:new(game, {
		{ ">>>> ELEVATOR DITCH (logo here) <<<<" },
		-- {"********** PAUSED **********"},
		{ "" },
		{ "PLAY", function() game:new_game() end },
		{ "OPTIONS", func_set_menu('options') },
		{ "QUIT", quit_game },
		{ "" },
		{ "" },
	}, { 0, 0, 0, 0.85 })
	
	self.menus.pause = Menu:new(game, {
		{ "<<<<<<<<< PAUSED >>>>>>>>>" },
		-- {"********** PAUSED **********"},
		{ "" },
		{ "RESUME", function() game.menu:unpause() end },
		{ "RETRY", function() game:new_game() end },
		{ "OPTIONS", func_set_menu('options') },
		{ "CREDITS", func_set_menu('credits1') },
		-- { "BACK TO TITLE SCREEN", func_set_menu('title') },
		{ "QUIT", quit_game },
		{ "" },
		{ "" },
	}, { 0, 0, 0, 0.85 })
	if OPERATING_SYSTEM == "Web" then
		-- Disable quitting on web
		self.menus.pause.items[7].is_selectable = false
	end

	self.menus.options = Menu:new(game, {
		{ "<<<<<<<<< OPTIONS >>>>>>>>>" },
		{ "< BACK", func_set_menu("pause")},--function() game.menu:back() end },
		{ "" },
		-- { "CONTROLS...", func_set_menu("controls")},
		-- { ""},
		{ "<<< Audio >>>" },
		{ "SOUND", function(self, option)
			options:toggle_sound()
		end, 
		function(self)
			self.value = options:get("sound_on")
			self.value_text = options:get("sound_on") and "ON" or "OFF"
		end},
		{ SliderMenuItem, "VOLUME", function(self, diff)
			diff = diff or 1
			self.value = (self.value + diff)
			if self.value < 0 then self.value = 20 end
			if self.value > 20 then self.value = 0 end
			
			options:set_volume(self.value/20)
			audio:play("menu_select", nil, 0.8+(self.value/20)*0.4)
		end, range_table(0,20),
		function(self)
			self.value = options:get("volume") * 20
			self.value_text = concat(floor(100 * self.value / 20), "%")

			self.is_selectable = options:get("sound_on")
		end},
		{ SliderMenuItem, "MUSIC VOLUME", function(self, diff)
			diff = diff or 1
			self.value = (self.value + diff)
			if self.value < 0 then self.value = 20 end
			if self.value > 20 then self.value = 0 end
			
			options:set_music_volume(self.value/20)
			audio:play("menu_select", (self.value/20), 0.8+(self.value/20)*0.4)
		end, range_table(0,20),
		function(self)
			self.value = options:get("music_volume") * 20
			self.value_text = concat(floor(100 * self.value / 20), "%")

			self.is_selectable = options:get("sound_on")
		end},
		{ "DISABLE BACKGROUND SOUNDS", function(self, option)
			options:toggle_background_noise()
		end, 
		function(self)
			self.value = options:get("disable_background_noise")
			self.value_text = options:get("disable_background_noise") and "ON" or "OFF"
		end},
		{""},

		-- {"MUSIC: [ON/OFF]", function(self)
		-- 	game:toggle_sound()
		-- end},
		{ "<<< Visuals >>>"},
		{ "FULLSCREEN", function(self)
			options:toggle_fullscreen()
		end,
		function(self)
			self.value = options:get("is_fullscreen")
			self.value_text = options:get("is_fullscreen") and "ON" or "OFF"
		end},

		{ SliderMenuItem, "PIXEL SCALE", function(self, diff)
			diff = diff or 1
			self:next_value(diff)

			local scale = self.value
			
			audio:play("menu_select")
			options:set_pixel_scale(scale)
		end, { "auto", "max whole", 1, 2, 3, 4}, function(self)
			self.value = options:get("pixel_scale")
			self.value_text = tostring(options:get("pixel_scale"))

			if OPERATING_SYSTEM == "Web" then  self.is_selectable = false  end
		end},

		{ "VSYNC", function(self)
			options:toggle_vsync()
		end,
		function(self)
			self.value = options:get("is_vsync")
			self.value_text = options:get("is_vsync") and "ON" or "OFF"
		end},
		{ ""},
		{ "<<< Game >>>"},
		{ "TIMER", function(self)
			options:toggle_timer()
		end,
		function(self)
			self.value = options:get("timer_on")
			self.value_text = options:get("timer_on") and "ON" or "OFF"
		end},

		{ "SHOW MOUSE CURSOR", function(self)
			options:toggle_mouse_visible()
			love.mouse.setVisible(options:get("mouse_visible"))
		end,
		function(self)
			self.value = options:get("mouse_visible")
			self.value_text = options:get("mouse_visible") and "ON" or "OFF"
		end},
		
		{ "PAUSE ON LOST FOCUS", function(self)
			options:toggle_pause_on_unfocus()
			love.mouse.setVisible(options:get("pause_on_unfocus"))
		end,
		function(self)
			self.value = options:get("pause_on_unfocus")
			self.value_text = options:get("pause_on_unfocus") and "ON" or "OFF"
		end},
		
		{ "SCREENSHAKE", function(self)
			options:toggle_screenshake()
			love.mouse.setVisible(options:get("screenshake_on"))
		end,
		function(self)
			self.value = options:get("screenshake_on")
			self.value_text = options:get("screenshake_on") and "ON" or "OFF"
		end},
	}, { 0, 0, 0, 0.85 })

	self.menus.controls = Menu:new(game, {
		{ "<<<<<<<<< CONTROLS >>>>>>>>>" },
		{ "< BACK", func_set_menu("options") },
		{ "" },
		{ "RESET CONTROLS", function() options:reset_controls() end },
		{ "" },
		{ ControlsMenuItem, "LEFT", "left" },
		{ ControlsMenuItem, "RIGHT", "right" },
		{ ControlsMenuItem, "UP", "up" },
		{ ControlsMenuItem, "DOWN", "down" },
		{ ControlsMenuItem, "JUMP", "jump" },
		{ ControlsMenuItem, "SHOOT", "shoot" },
		{ "PAUSE: [ESCAPE]"},
		{ "SELECT: [ENTER]"},

	}, { 0, 0, 0, 0.85 })

	local items = {
		{"********** GAME OVER! **********"},
		{ "" },
		{ StatsMenuItem, "Kills", function(self) return game.stats.kills end },
		{ StatsMenuItem, "Time",  function(self)
			return time_to_string(game.stats.time)
		end },
		{ StatsMenuItem, "Floor", function(self) return concat(game.stats.floor, " / 16") end },
		{ StatsMenuItem, "Max combo", function(self) return concat(game.stats.max_combo) end },
		{ "" },
		{ "RETRY", function() game:new_game() end },
		{ "QUIT", quit_game },
		-- { "BACK TO TITLE SCREEN", func_set_menu("title") },
		{ "" },
		{ "" },
	}
	if OPERATING_SYSTEM == "Web" then
		table.remove(items, 9)
	end
	self.menus.game_over = Menu:new(game, items, { 0, 0, 0, 0.85 })

	self.menus.credits1 = Menu:new(game, {
		{"<<<<<<<<< CREDITS (1/4) >>>>>>>>>"},
		{ "[ NEXT PAGE >>]", func_set_menu("credits2")},
		{ "< BACK TO PAUSE MENU", func_set_menu("pause") },
		{ "" },
		{ "<<< Design, programming & art >>>"},
		{ "Léo Bernard (Yolwoocle)", func_url("https://twitter.com/yolwoocle_")},
		{ "" },
		{ "<<< Special Thanks >>>"},
		{ "Gouspourd", func_url("https://gouspourd.itch.io/")},
		{ "Louie Chapman", func_url("https://louiechapm.itch.io/") },
		{ "SmellyFishstiks", func_url("https://www.lexaloffle.com/bbs/?uid=42184") },
		{ "Made using LÖVE Engine", func_url("https://love2d.org/") },
		{ ""},
		{ "<<< Music >>>"},
		{ "'Galaxy Trip' by Raphaël Marcon / CC BY 4.0", func_url("https://raphytator.itch.io/")},
		{ ""},
		{ "<<< Playtesting >>>"},
		{ "hades140701", function() end },
		-- { "SmellyFishstiks", func_url("https://www.lexaloffle.com/bbs/?uid=42184") },
		-- { "rbts", function() end },
		-- { "Immow", function() end },
		-- { "Kingtut 101", function() end },
	}, { 0, 0, 0, 0.85 })
	
	self.menus.credits2 = Menu:new(game, {
		{"<<<<<<<<< CREDITS (2/4) >>>>>>>>>"},
		{ "[ NEXT PAGE >>]", func_set_menu("credits3")},
		{ "[<< PREV PAGE ]", func_set_menu("credits1")},
		{ "< BACK TO PAUSE MENU", func_set_menu("pause") },
		{ "" },
		
		{ "<<<<< Assets Used >>>>>"},
		{ "Kenney assets, including sound effects and fonts / CC0", func_url("https://kenney.nl/")},
		{ "'Hope Gold' font by somepx / CSL", func_url("https://somepx.itch.io/")},
		{ "'NicoPaint' font by amhuo", func_url("https://emhuo.itch.io/")},
		{ ""},
		{ "<< freesound.org sounds >>"},
		{ "'jf Glass Breaking.wav' by cmusounddesign / CC BY 3.0", func_url("https://freesound.org/people/cmusounddesign/sounds/85168/")},
		{ "'Glass Break' by avrahamy / CC0", func_url("https://freesound.org/people/avrahamy/sounds/141563/")},
		{ "'Glass shard tinkle texture' by el-bee / CC BY 4.0", func_url("https://freesound.org/people/el-bee/sounds/636238/")},
		{ "'Bad Beep (Incorrect)' by RICHERlandTV / CC BY 3.0", func_url("https://freesound.org/people/RICHERlandTV/sounds/216090/")},
	}, { 0, 0, 0, 0.85 })
	
	self.menus.credits3 = Menu:new(game, {
		{"<<<<<<<<< CREDITS (3/4) >>>>>>>>>"},
		{ "[ NEXT PAGE >>]", func_set_menu("credits4")},
		{ "[<< PREV PAGE ]", func_set_menu("credits2")},
		{ "< BACK TO PAUSE MENU", func_set_menu("pause")},
		{ "" },
		{ "'[Keyboard press]' by MattRuthSound / CC BY 3.0", func_url("https://freesound.org/people/MattRuthSound/sounds/561661/")},
		{ "'Paper Throw Into Air(fuller) 2' by RossBell / CC0", func_url("https://freesound.org/people/RossBell/sounds/389442/")},
		{ "'Slime' by Lukeo135 / CC0", func_url("https://freesound.org/people/Lukeo135/sounds/530617/")},
		{ "'brushes_on_snare' by Heigh-hoo / CC0", func_url("https://freesound.org/people/Heigh-hoo/sounds/20297/")},
		{ "'01 Elevator UP' by soundslikewillem / CC BY 4.0", func_url("https://freesound.org/people/soundslikewillem/sounds/340747/")},
		{ "'indsustrial_elevator_door_open' by joedeshon / CC BY 4.0", func_url("https://freesound.org/people/joedeshon/sounds/368737/")},
		{ "'indsustrial_elevator_door_close' by joedeshon / CC BY 4.0", func_url("https://freesound.org/people/joedeshon/sounds/368738/")},
		{ "'Footsteps on gravel' by Joozz / CC BY 4.0", func_url("https://freesound.org/people/Joozz/sounds/531952/")},
		{ "'THE CRASH' by sandyrb / CC BY 4.0", func_url("https://freesound.org/people/sandyrb/sounds/95078/")},
		{ "'Door slam - Gun shot' by coolguy244e / CC BY 4.0", func_url("https://freesound.org/people/coolguy244e/sounds/266915/")},
		-- { "'' by  / CC BY 4.0", func_url("")},
	}, { 0, 0, 0, 0.85 })

	self.menus.credits4 = Menu:new(game, {
		{"<<<<<<<<< CREDITS (4/4) >>>>>>>>>"},
		{ "< BACK TO PAUSE MENU", func_set_menu("pause")},
		{ "[<< PREV PAGE ]", func_set_menu("credits2")},
		{ "" },
		{ "'bee fly' by soundmary / CC BY 4.0", func_url("https://freesound.org/people/soundmary/sounds/194932/")},
		{ "'Pop, Low, A (H1)' by InspectorJ / CC BY 4.0", func_url("https://freesound.org/people/InspectorJ/sounds/411639/")},
		{ "'Crack 1' by JustInvoke / CC BY 3.0", func_url("https://freesound.org/people/JustInvoke/sounds/446118/")},
		{ "'Emergency Siren' by onderwish / CC0", func_url("https://freesound.org/people/onderwish/sounds/470504/")},
		{ "'Wood burning in the stove' by smand / CC0", func_url("https://freesound.org/people/smand/sounds/521118/")},
		{ "'Bike falling down an escalator' by dundass / CC BY 3.0", func_url("https://freesound.org/people/dundass/sounds/509831/")},
		{ "'squishing and squeezing a wet sponge in a bowl' by breadparticles / CC0", func_url("https://freesound.org/people/breadparticles/sounds/575332/#comments")},
		{ "'Insect Bug Smash & Crush' by EminYILDIRIM / CC BY 4.0", func_url("https://freesound.org/people/EminYILDIRIM/sounds/570767/")},
		-- { "'xxx' by xxx / CC BY 4.0", func_url("xxx")},
		{ ""},
		{ "<< Asset Licenses >>"},
		{ "CC0", func_url("https://creativecommons.org/publicdomain/zero/1.0/")},
		{ "CC BY 3.0", func_url("https://creativecommons.org/licenses/by/3.0/")},
		{ "CC BY 4.0", func_url("https://creativecommons.org/licenses/by/4.0/")},
		{ "Common Sense License (CSL)", func_url("http://www.palmentieri.it/somepx/license.txt")},
	}, { 0, 0, 0, 0.85 })

	local items = {
		{ "<<<<<<<<< CONGRATULATIONS! >>>>>>>>>" },
		-- {"********** PAUSED **********"},
		{ "" },
		{ StatsMenuItem, "Kills", function(self) return game.stats.kills end },
		{ StatsMenuItem, "Time",  function(self)
			return time_to_string(game.stats.time)
		end },
		{ StatsMenuItem, "Floor", function(self) return game.stats.floor end },
		{ ""},
		{ "NEW GAME", function() game:new_game() end },
		-- { "CREDITS", func_set_menu('credits1') },
		{ "QUIT", quit_game },
		{ "" },
	}
	if OPERATING_SYSTEM == "Web" or true then
		table.remove(items, 8)
	end
	self.menus.win = Menu:new(game, items, { 0, 0, 0, 0.95 })

	self.cur_menu = nil
	self.cur_menu_name = ""
	self.is_paused = false

	self.sel_n = 1
	self.sel_item = nil

	self.last_menu = "title"
end

function MenuManager:update(dt)
	if self.cur_menu then
		self.cur_menu:update(dt)

		-- Navigate up and down
		if game:button_pressed("up") then self:incr_selection(-1) end
		if game:button_pressed("down") then self:incr_selection(1) end

		-- Update current selection
		self.sel_n = mod_plus_1(self.sel_n, #self.cur_menu.items)
		self.sel_item = self.cur_menu.items[self.sel_n]
		self.sel_item.is_selected = true

		-- On pressed
		local btn = game:button_pressed("shoot") or game:button_pressed("jump") or game:button_pressed("select")
		if btn and self.sel_item and self.sel_item.on_click then
			if not self.sel_item.is_waiting_for_input then
				self.sel_item:on_click()
				self.sel_item:after_click()
			end
		end
	end

	local btn_pressed, player = game:button_pressed("pause")

	if btn_pressed and self.cur_menu_name ~= "controls" then
		self:toggle_pause()
	end
end

function MenuManager:draw()
	if self.cur_menu.bg_color then
		rect_color(self.cur_menu.bg_color, "fill", game.cam_realx-1 or -1, game.cam_realy or -1, CANVAS_WIDTH+2, CANVAS_HEIGHT+2)
	end
	self.cur_menu:draw()
end

function MenuManager:set_menu(menu)
	self.last_menu = self.cur_menu

	-- nil menu
	if menu == nil then
		self.cur_menu = nil
		game:on_unmenu()
		return
	end
	
	local m = self.menus[menu]

	if type(menu) ~= "string" and menu.is_menu then
		m = menu
	end

	if not m then return false, "menu '" .. menu .. "' does not exist" end
	self.cur_menu = m
	self.cur_menu_name = menu

	-- Update selection to first selectable
	local sel, found = self:find_selectable_from(1, 1)
	self:set_selection(sel)

	-- Reset game screenshake
	if game then
		game.cam_x = 0
		game.cam_y = 0
	end

	game:on_menu()
	return true
end

function MenuManager:pause()
	-- Retry if game ended
	if game.is_on_win_screen then
		self:set_menu("win")
		return
	end

	if self.cur_menu == nil then
		self.is_paused = true
		self:set_menu("pause")
	end
end

function MenuManager:unpause()
	self.is_paused = false
	self:set_menu()
	game:on_unmenu()
end

function MenuManager:toggle_pause()
	if self.is_paused then
		self:unpause()
	else
		self:pause()
	end
end

function MenuManager:incr_selection(n)
	if not self.cur_menu then return false, "no current menu" end

	-- Increment selection until valid item
	local sel, found = self:find_selectable_from(self.sel_n, n)

	if not found then
		self.sel_n = self.sel_n + n
		return false, concat("no selectable item found; selection set to n + (", n, ") (", self.sel_n, ")")
	end

	-- Update new selection
	self.sel_item:set_selected(false, n)
	self.sel_n = sel
	self.sel_item = self.cur_menu.items[self.sel_n]
	self.sel_item:set_selected(true, n)
	
	audio:play_var("menu_hover", 0.2, 1)

	return true
end

function MenuManager:find_selectable_from(n, diff)
	diff = diff or 1

	local len = #self.cur_menu.items
	local sel = n

	local limit = len
	local found = false
	while not found and limit > 0 do
		sel = mod_plus_1(sel + diff, len)
		if self.cur_menu.items[sel].is_selectable then found = true end
		limit = limit - 1
	end

	return sel, found
end

function MenuManager:set_selection(n)
	if self.sel_item then self.sel_item:set_selected(false) end
	if not self.cur_menu then return false end

	self.sel_n = n
	self.sel_item = self.cur_menu.items[self.sel_n]
	if not self.sel_item then return false end
	self.sel_item:set_selected(true)

	return true
end

function MenuManager:back()
	self:set_menu(self.last_menu)
end

function MenuManager:keypressed(key, scancode, isrepeat)
	if not self.sel_item then return end
	if not self.sel_item.keypressed then return end
	self.sel_item:keypressed(key, scancode, isrepeat)
end

return MenuManager