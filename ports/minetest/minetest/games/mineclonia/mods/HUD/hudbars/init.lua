local S = minetest.get_translator("hudbars")
local NS = function(s) return s end

hb = {}

-- TODO: when < minetest 5.9 isn't supported anymore, remove this variable check and replace all occurences of [hud_elem_type_field] with type
local hud_elem_type_field = "type"
if not minetest.features.hud_def_type_field then
	hud_elem_type_field = "hud_elem_type"
end

hb.hudtables = {}

-- number of registered HUD bars
hb.hudbars_count = 0

-- table which records which HUD bar slots have been “registered” so far; used for automatic positioning
hb.registered_slots = {}

hb.settings = {}

function hb.load_setting(sname, stype, defaultval, valid_values)
	local sval
	if stype == "string" then
		sval = minetest.settings:get(sname)
	elseif stype == "bool" then
		sval = minetest.settings:get_bool(sname)
	elseif stype == "number" then
		sval = tonumber(minetest.settings:get(sname))
	end
	if sval ~= nil then
		if valid_values ~= nil then
			local valid = false
			for i=1,#valid_values do
				if sval == valid_values[i] then
					valid = true
				end
			end
			if not valid then
				minetest.log("error", "[hudbars] Invalid value for "..sname.."! Using default value ("..tostring(defaultval)..").")
				return defaultval
			else
				return sval
			end
		else
			return sval
		end
	else
		return defaultval
	end
end

-- Load default settings
dofile(minetest.get_modpath("hudbars").."/default_settings.lua")

if minetest.get_modpath("mcl_experience") and not minetest.is_creative_enabled("") then
	-- reserve some space for experience bar:
	hb.settings.start_offset_left.y = hb.settings.start_offset_left.y - 20
	hb.settings.start_offset_right.y = hb.settings.start_offset_right.y - 20
end

local function player_exists(player)
	return player ~= nil and player:is_player()
end

local function make_label(format_string, format_string_config, label, start_value, max_value)
	local params = {}
	local order = format_string_config.order
	for o=1, #order do
		if order[o] == "label" then
			table.insert(params, label)
		elseif order[o] == "value" then
			if format_string_config.format_value then
				table.insert(params, string.format(format_string_config.format_value, start_value))
			else
				table.insert(params, start_value)
			end
		elseif order[o] == "max_value" then
			if format_string_config.format_max_value then
				table.insert(params, string.format(format_string_config.format_max_value, max_value))
			else
				table.insert(params, max_value)
			end
		end
	end
	local ret
	if format_string_config.textdomain and minetest.translate then
		ret = minetest.translate(format_string_config.textdomain, format_string, unpack(params))
	else
		ret = S(format_string, unpack(params))
	end
	return ret
end

-- Table which contains all players with active default HUD bars (only for internal use)
hb.players = {}

function hb.value_to_barlength(value, max)
	if max == 0 then
		return 0
	else
		if hb.settings.bar_type == "progress_bar" then
			local x
			if value < 0 then x=-0.5 else x = 0.5 end
			local ret = math.modf((value/max) * hb.settings.max_bar_length + x)
			return ret
		else
			local x
			if value < 0 then x=-0.5 else x = 0.5 end
			local ret = math.modf((value/max) * hb.settings.statbar_length + x)
			return ret
		end
	end
end

function hb.get_hudtable(identifier)
	return hb.hudtables[identifier]
end

function hb.get_hudbar_position_index(identifier)
	if hb.settings.sorting[identifier] ~= nil then
		return hb.settings.sorting[identifier]
	else
		local i = 0
		while true do
			if hb.registered_slots[i] ~= true and hb.settings.sorting_reverse[i] == nil then
				return i
			end
			i = i + 1
		end
	end
end

function hb.register_hudbar(identifier, text_color, label, textures, default_start_value, default_start_max, default_start_hidden, format_string, format_string_config, direction)
	minetest.log("action", "hb.register_hudbar: "..tostring(identifier))
	local hudtable = {}
	local pos, offset
	local index = math.floor(hb.get_hudbar_position_index(identifier))
	local direction = tonumber(direction) or 0
	hb.registered_slots[index] = true
	if hb.settings.alignment_pattern == "stack_up" then
		pos = hb.settings.pos_left
		offset = {
			x = direction == 0 and hb.settings.start_offset_left.x or -hb.settings.start_offset_right.x,
			y = hb.settings.start_offset_left.y - hb.settings.vmargin * index
		}
	elseif hb.settings.alignment_pattern == "stack_down" then
		pos = hb.settings.pos_left
		offset = {
			x = direction == 0 and hb.settings.start_offset_right.x or -hb.settings.start_offset_left.x,
			y = hb.settings.start_offset_left.y + hb.settings.vmargin * index
		}
	else
		if index % 2 == 0 then
			pos = hb.settings.pos_left
			offset = {
				x = direction == 0 and hb.settings.start_offset_left.x or (-42+24)/(-258.0) * hb.settings.start_offset_left.x - 24,
				y = hb.settings.start_offset_left.y - hb.settings.vmargin * (index/2)
			}
		else
			pos = hb.settings.pos_right
			offset = {
				x = direction == 0 and hb.settings.start_offset_right.x or (234+24)/(16) * hb.settings.start_offset_right.x - 24,
				y = hb.settings.start_offset_right.y - hb.settings.vmargin * ((index-1)/2)
			}
		end
	end
	if format_string == nil then
		format_string = NS("@1: @2/@3")
	end
	if format_string_config == nil then
		format_string_config = {}
	end
	if format_string_config.order == nil then
		format_string_config.order = { "label", "value", "max_value" }
	end
	if format_string_config.format_value == nil then
		format_string_config.format_value = "%d"
	end
	if format_string_config.format_max_value == nil then
		format_string_config.format_max_value = "%d"
	end

	hudtable.add_all = function(player, hudtable, start_value, start_max, start_hidden)
		if start_value == nil then start_value = hudtable.default_start_value end
		if start_max == nil then start_max = hudtable.default_start_max end
		if start_hidden == nil then start_hidden = hudtable.default_start_hidden end
		local ids = {}
		local state = {}
		local name = player:get_player_name()
		local bgscale, iconscale, text, barnumber, bgiconnumber
		if start_max == 0 or start_hidden then
			bgscale = { x=0, y=0 }
		else
			bgscale = { x=1, y=1 }
		end
		if start_hidden then
			iconscale = { x=0, y=0 }
			barnumber = 0
			bgiconnumber = 0
			text = ""
		else
			iconscale = { x=1, y=1 }
			barnumber = hb.value_to_barlength(start_value, start_max)
			bgiconnumber = hb.settings.statbar_length
			text = make_label(format_string, format_string_config, label, start_value, start_max)
		end
		if hb.settings.bar_type == "progress_bar" then
			ids.bg = player:hud_add({
				[hud_elem_type_field] = "image",
				position = pos,
				scale = bgscale,
				text = "hudbars_bar_background.png",
				alignment = {x=1,y=1},
				offset = { x = offset.x - 1, y = offset.y - 1 },
				z_index = 0,
			})
			if textures.icon ~= nil then
				ids.icon = player:hud_add({
					[hud_elem_type_field] = "image",
					position = pos,
					scale = iconscale,
					text = textures.icon,
					alignment = {x=-1,y=1},
					offset = { x = offset.x - 3, y = offset.y },
					z_index = 1,
				})
			end
		end
		local bar_image, bgicon, bar_size
		if hb.settings.bar_type == "progress_bar" then
			bar_image = textures.bar
			-- NOTE: Intentionally set to nil. For some reason, on some systems,
			-- the progress bar is displaced when the bar_size is set explicitly here.
			-- On the other hand, setting this to nil is deprecated in MT 5.0.0 due to
			-- a debug log warning, but nothing is explained in lua_api.txt.
			-- This section is a potential bug magnet, please watch with care!
			-- The size of the bar image is expected to be exactly 2×16 pixels.
			bar_size = nil
		elseif hb.settings.bar_type == "statbar_classic" or hb.settings.bar_type == "statbar_modern" then
			bar_image = textures.icon
			bgicon = textures.bgicon
			bar_size = {x=24, y=24}
		end
		ids.bar = player:hud_add({
			[hud_elem_type_field] = "statbar",
			position = pos,
			text = bar_image,
			text2 = bgicon,
			number = barnumber,
			item = bgiconnumber,
			alignment = {x=-1,y=-1},
			offset = offset,
			direction = direction,
			size = bar_size,
			z_index = 1,
		})
		if hb.settings.bar_type == "progress_bar" then
			ids.text = player:hud_add({
				[hud_elem_type_field] = "text",
				position = pos,
				text = text,
				alignment = {x=1,y=1},
				number = text_color,
				direction = direction,
				offset = { x = offset.x + 2,  y = offset.y - 1},
				z_index = 2,
		})
		end
		-- Do not forget to update hb.get_hudbar_state if you add new fields to the state table
		state.hidden = start_hidden
		state.value = start_value
		state.max = start_max
		state.text = text
		state.barlength = hb.value_to_barlength(start_value, start_max)

		local main_error_text =
			"[hudbars] Bad initial values of HUD bar identifier “"..tostring(identifier).."” for player "..name..". "

		if start_max < start_value then
			minetest.log("error", main_error_text.."start_max ("..start_max..") is smaller than start_value ("..start_value..")!")
		end
		if start_max < 0 then
			minetest.log("error", main_error_text.."start_max ("..start_max..") is smaller than 0!")
		end
		if start_value < 0 then
			minetest.log("error", main_error_text.."start_value ("..start_value..") is smaller than 0!")
		end

		hb.hudtables[identifier].hudids[name] = ids
		hb.hudtables[identifier].hudstate[name] = state
	end

	hudtable.identifier = identifier
	hudtable.format_string = format_string
	hudtable.format_string_config = format_string_config
	hudtable.label = label
	hudtable.hudids = {}
	hudtable.hudstate = {}
	hudtable.default_start_hidden = default_start_hidden
	hudtable.default_start_value = default_start_value
	hudtable.default_start_max = default_start_max

	hb.hudbars_count= hb.hudbars_count + 1

	hb.hudtables[identifier] = hudtable
end

function hb.init_hudbar(player, identifier, start_value, start_max, start_hidden)
	if not player_exists(player) then return false end
	local hudtable = hb.get_hudtable(identifier)
	hb.hudtables[identifier].add_all(player, hudtable, start_value, start_max, start_hidden)
	return true
end

function hb.change_hudbar(player, identifier, new_value, new_max_value, new_icon, new_bgicon, new_bar, new_label, new_text_color)
	if new_value == nil and new_max_value == nil and new_icon == nil and new_bgicon == nil and new_bar == nil and new_label == nil and new_text_color == nil then
		return true
	end
	if not player_exists(player) then
		return false
	end

	local name = player:get_player_name()
	local hudtable = hb.get_hudtable(identifier)
	if not hudtable.hudstate[name] then
		return false
	end
	local value_changed, max_changed = false, false

	if new_value ~= nil then
		if new_value ~= hudtable.hudstate[name].value then
			hudtable.hudstate[name].value = new_value
			value_changed = true
		end
	else
		new_value = hudtable.hudstate[name].value
	end
	if new_max_value ~= nil then
		if new_max_value ~= hudtable.hudstate[name].max then
			hudtable.hudstate[name].max = new_max_value
			max_changed = true
		end
	else
		new_max_value = hudtable.hudstate[name].max
	end

	if hb.settings.bar_type == "progress_bar" then
		if new_icon ~= nil and hudtable.hudids[name].icon ~= nil then
			player:hud_change(hudtable.hudids[name].icon, "text", new_icon)
		end
		if new_bgicon ~= nil and hudtable.hudids[name].bgicon ~= nil then
			player:hud_change(hudtable.hudids[name].bgicon, "text", new_bgicon)
		end
		if new_bar ~= nil then
			player:hud_change(hudtable.hudids[name].bar , "text", new_bar)
		end
		if new_label ~= nil then
			hudtable.label = new_label
			local new_text = make_label(hudtable.format_string, hudtable.format_string_config, new_label, hudtable.hudstate[name].value, hudtable.hudstate[name].max)
			player:hud_change(hudtable.hudids[name].text, "text", new_text)
		end
		if new_text_color ~= nil then
			player:hud_change(hudtable.hudids[name].text, "number", new_text_color)
		end
	else
		if new_icon ~= nil and hudtable.hudids[name].bar ~= nil then
			player:hud_change(hudtable.hudids[name].bar, "text", new_icon)
		end
		if new_bgicon ~= nil and hudtable.hudids[name].bg ~= nil then
			player:hud_change(hudtable.hudids[name].bg, "text", new_bgicon)
		end
	end

	local main_error_text =
		"[hudbars] Bad call to hb.change_hudbar, identifier: “"..tostring(identifier).."”, player name: “"..name.."”. "
	if new_max_value < new_value then
		minetest.log("error", main_error_text.."new_max_value ("..new_max_value..") is smaller than new_value ("..new_value..")!")
	end
	if new_max_value < 0 then
		minetest.log("error", main_error_text.."new_max_value ("..new_max_value..") is smaller than 0!")
	end
	if new_value < 0 then
		minetest.log("error", main_error_text.."new_value ("..new_value..") is smaller than 0!")
	end

	if hudtable.hudstate[name].hidden == false then
		if max_changed and hb.settings.bar_type == "progress_bar" then
			if hudtable.hudstate[name].max == 0 then
				player:hud_change(hudtable.hudids[name].bg, "scale", {x=0,y=0})
			else
				player:hud_change(hudtable.hudids[name].bg, "scale", {x=1,y=1})
			end
		end

		if value_changed or max_changed then
			local new_barlength = hb.value_to_barlength(new_value, new_max_value)
			if new_barlength ~= hudtable.hudstate[name].barlength then
				player:hud_change(hudtable.hudids[name].bar, "number", hb.value_to_barlength(new_value, new_max_value))
				hudtable.hudstate[name].barlength = new_barlength
			end

			if hb.settings.bar_type == "progress_bar" then
				local new_text = make_label(hudtable.format_string, hudtable.format_string_config, hudtable.label, new_value, new_max_value)
				if new_text ~= hudtable.hudstate[name].text then
					player:hud_change(hudtable.hudids[name].text, "text", new_text)
					hudtable.hudstate[name].text = new_text
				end
			end
		end
	end
	return true
end

function hb.hide_hudbar(player, identifier)
	if not player_exists(player) then return false end
	local name = player:get_player_name()
	local hudtable = hb.get_hudtable(identifier)
	if hudtable == nil then return false end
	if hudtable.hudstate[name].hidden == true then return true end
	if hb.settings.bar_type == "progress_bar" then
		if hudtable.hudids[name].icon ~= nil then
			player:hud_change(hudtable.hudids[name].icon, "scale", {x=0,y=0})
		end
		player:hud_change(hudtable.hudids[name].bg, "scale", {x=0,y=0})
		player:hud_change(hudtable.hudids[name].text, "text", "")
	end
	player:hud_change(hudtable.hudids[name].bar, "number", 0)
	player:hud_change(hudtable.hudids[name].bar, "item", 0)
	hudtable.hudstate[name].hidden = true
	return true
end

function hb.unhide_hudbar(player, identifier)
	if not player_exists(player) then return false end
	local name = player:get_player_name()
	local hudtable = hb.get_hudtable(identifier)
	if hudtable == nil then return false end
	if hudtable.hudstate[name].hidden == false then return true end
	local value = hudtable.hudstate[name].value
	local max = hudtable.hudstate[name].max
	if hb.settings.bar_type == "progress_bar" then
		if hudtable.hudids[name].icon ~= nil then
			player:hud_change(hudtable.hudids[name].icon, "scale", {x=1,y=1})
		end
		if hudtable.hudstate[name].max ~= 0 then
			player:hud_change(hudtable.hudids[name].bg, "scale", {x=1,y=1})
		end
		player:hud_change(hudtable.hudids[name].text, "text", make_label(hudtable.format_string, hudtable.format_string_config, hudtable.label, value, max))
	elseif hb.settings.bar_type == "statbar_modern" then
		player:hud_change(hudtable.hudids[name].bar, "scale", {x=1,y=1})
	end
	player:hud_change(hudtable.hudids[name].bar, "number", hb.value_to_barlength(value, max))
	player:hud_change(hudtable.hudids[name].bar, "item", hb.value_to_barlength(max, max))
	hudtable.hudstate[name].hidden = false
	return true
end

function hb.get_hudbar_state(player, identifier)
	if not player_exists(player) then return nil end
	local ref = hb.get_hudtable(identifier).hudstate[player:get_player_name()]
	if not ref then return nil end
	-- Do not forget to update this chunk of code in case the state changes
	local copy = {
		hidden = ref.hidden,
		value = ref.value,
		max = ref.max,
		text = ref.text,
		barlength = ref.barlength,
	}
	return copy
end

function hb.get_hudbar_identifiers()
	local ids = {}
	for id, _ in pairs(hb.hudtables) do
		table.insert(ids, id)
	end
	return ids
end

--register built-in HUD bars
if minetest.settings:get_bool("enable_damage") or hb.settings.forceload_default_hudbars then
	hb.register_hudbar("health", 0xFFFFFF, S("Health"), { bar = "hudbars_bar_health.png", icon = "hudbars_icon_health.png", bgicon = "hudbars_bgicon_health.png" }, 20, 20, false)
	hb.register_hudbar("breath", 0xFFFFFF, S("Breath"), { bar = "hudbars_bar_breath.png", icon = "hudbars_icon_breath.png", bgicon = "hudbars_bgicon_breath.png" }, 10, 10, true, nil, nil, 1)
end

local function hide_builtin(player)
	local flags = player:hud_get_flags()
	flags.healthbar = false
	flags.breathbar = false
	player:hud_set_flags(flags)
end


local function custom_hud(player)
	if minetest.settings:get_bool("enable_damage") or hb.settings.forceload_default_hudbars then
		local hide
		if minetest.settings:get_bool("enable_damage") then
			hide = false
		else
			hide = true
		end
		local hp = player:get_hp()
		local hp_max = player:get_properties().hp_max
		hb.init_hudbar(player, "health", math.min(hp, hp_max), hp_max, hide)
		local breath = player:get_breath()
		local breath_max = player:get_properties().breath_max
		local hide_breath
		if breath >= breath_max and hb.settings.autohide_breath == true then hide_breath = true else hide_breath = false end
		hb.init_hudbar(player, "breath", math.min(breath, breath_max), breath_max, hide_breath or hide)
	end
end

local function update_health(player)
	local hp_max = player:get_properties().hp_max
	local hp = math.min(player:get_hp(), hp_max)
	hb.change_hudbar(player, "health", hp, hp_max)
end

-- update built-in HUD bars
local function update_hud(player)
	if not player_exists(player) then return end
	if minetest.settings:get_bool("enable_damage") then
		if hb.settings.forceload_default_hudbars then
			hb.unhide_hudbar(player, "health")
		end
		--air
		local breath_max = player:get_properties().breath_max
		local breath = player:get_breath()

		if breath >= breath_max and hb.settings.autohide_breath == true then
			hb.hide_hudbar(player, "breath")
		else
			hb.unhide_hudbar(player, "breath")
			hb.change_hudbar(player, "breath", math.min(breath, breath_max), breath_max)
		end
		--health
		update_health(player)
	elseif hb.settings.forceload_default_hudbars then
		hb.hide_hudbar(player, "health")
		hb.hide_hudbar(player, "breath")
	end
end

minetest.register_on_player_hpchange(function(player)
	if hb.players[player:get_player_name()] ~= nil then
		update_health(player)
	end
end)

minetest.register_on_respawnplayer(function(player)
	update_health(player)
	hb.hide_hudbar(player, "breath")
end)

minetest.register_on_joinplayer(function(player)
	hide_builtin(player)
	custom_hud(player)
	hb.players[player:get_player_name()] = player
end)

minetest.register_on_leaveplayer(function(player)
	hb.players[player:get_player_name()] = nil
end)

local main_timer = 0
local timer = 0
minetest.register_globalstep(function(dtime)
	main_timer = main_timer + dtime
	timer = timer + dtime
	if main_timer > hb.settings.tick or timer > 4 then
		if main_timer > hb.settings.tick then main_timer = 0 end
		-- only proceed if damage is enabled
		if minetest.settings:get_bool("enable_damage") or hb.settings.forceload_default_hudbars then
			for _, player in pairs(hb.players) do
				-- update all hud elements
				update_hud(player)
			end
		end
	end
	if timer > 4 then timer = 0 end
end)
