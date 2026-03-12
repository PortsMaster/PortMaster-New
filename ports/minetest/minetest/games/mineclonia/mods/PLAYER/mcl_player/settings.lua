local S = core.get_translator(core.get_current_modname())
local D = mcl_util.get_dynamic_translator(core.get_current_modname())
local C = core.colorize
local F = core.formspec_escape

local section_name_color = "#FFFFFF"
local setting_name_color = "#000000"

local function __iterate(t, iterator, ...)
	if select("#", ...) > 0 then
		t:add(...)
	end
	if iterator then
		return __iterate(t, iterator())
	end
end

local stringbuilder_meta = {
	add = function(t, ...)
		for i = 1, select("#", ...) do
			local item = select(i, ...)
			local item_type = type(item)
			if item_type == "table" then
				t:add(unpack(item))
			elseif item_type == "function" then
				__iterate(t, item())
			elseif item_type ~= "nil" then
				t[#t+1] = tostring(item)
			end
		end
	end,
	get = table.concat,
}

local function new_stringbuilder()
	return setmetatable({}, { __index = stringbuilder_meta })
end

local SETTINGS_PREFIX ="mcl_player_settings:"
local setting_types = { boolean = true, enum = true, slider = true }

mcl_player.registered_player_settings_buttons = {}
local player_settings_buttons = mcl_player.registered_player_settings_buttons

function mcl_player.register_player_settings_button(new_def)
	-- maintain buttons in descending def priority order
	if #player_settings_buttons == 0
		or new_def.priority <= player_settings_buttons[#player_settings_buttons].priority then
		-- insert at end
		player_settings_buttons[#player_settings_buttons+1] = new_def
	else
		-- search for insert position
		for i, def in ipairs(player_settings_buttons) do
			if def.priority < new_def.priority then
				table.insert(player_settings_buttons, i, new_def)
				break
			end
		end
	end
end

mcl_player.registered_player_settings = {}
local player_settings = mcl_player.registered_player_settings

function mcl_player.register_player_setting(name, def)
	if player_settings[name] then
		core.log("error", "[mcl_player] duplicate player setting registration for " .. name .. ": " .. debug.traceback())
	elseif not def.short_desc then
		core.log("error", "[mcl_player] player setting " .. name .. " has no description:" .. debug.traceback())
	elseif not (def.type and setting_types[def.type]) then
		core.log("error", "[mcl_player] player setting " .. name .. " has invalid type " .. tostring(def.type) .. ":" .. debug.traceback())
	elseif (def.type == "enum" or def.type == "slider") and not def.options then
		core.log("error", "[mcl_player] enum/slider player setting " .. name .. " has no options:" .. debug.traceback())
	else
		if def.type == "slider" then
			local options = {}
			for _, option in ipairs(def.options) do
				if option.min and option.max then
					for i = option.min, option.max, option.step or 1 do
						options[#options+1] = { name = tostring(i) }
					end
				else
					options[#options+1] = option
				end
			end
			def.options = options
		end
		def._translated_section = def.section and D(def.section) or S("Misc")
		def.section = def.section or "Misc"
		player_settings[name] = def
	end
end

-- TODO: settings cache

function mcl_player.get_player_setting(player, name, default)
	local def = player_settings[name]
	if not def then return nil end

	local setting = SETTINGS_PREFIX .. name
	local value = player:get_meta():get(setting)
	if value == nil then
		return default
	elseif def.type == "boolean" then
		return value == "true"
	else
		return value
	end
end

function mcl_player.set_player_setting(player, name, value)
	local def = player_settings[name]
	if not def then return end
	if value == mcl_player.get_player_setting(player, name) then return end

	local meta = player:get_meta()
	local setting = SETTINGS_PREFIX .. name
	if def.type == "boolean" then
		meta:set_string(setting, value == nil and "" or (value and "true" or "false"))
	else
		meta:set_string(setting, value == nil and "" or value)
	end

	-- report change
	if def.on_change then
		def.on_change(player, name, value)
	end
end

mcl_player.register_player_setting("mcl_player:mobile_ui", {
        type = "boolean",
	section = "Graphics",
	short_desc = S("Adapt UI for a better experience on touchscreen devices"),
	long_desc = S("May enlarge elements, add additional space, and change elements, e.g. add buttons to replace the missing enter key.\nNote that currently this is only implemented for a very limited number of formspecs."),
	ui_default = "false",
})

local function get_sorted_setting_names()
	local names = {}
	for name, _ in pairs(player_settings) do
		names[#names+1] = name
	end
	table.sort(names, function(a, b)
		local defa, defb = player_settings[a], player_settings[b]
		if defa.section == defb.section then
			return defa.short_desc < defb.short_desc
		else
			return defa.section < defb.section
		end
	end)
	return names
end

local function generate_setting_fragment(player, name, def, fs)
	local raw_value = mcl_player.get_player_setting(player, name)
	local value = raw_value == nil and def.ui_default or raw_value
	local tt_ref = name
	local b_size = fs.mobile and 0.5 or 0.25
	local b_size_2 = b_size / 2
	local padding = fs.mobile and 0.125 or 0
	local y = fs.y
	y = y + padding

	local playerinfo = core.get_player_information(player:get_player_name())
	if def.min_protocol_version and def.min_protocol_version >= playerinfo.protocol_version then
		fs:add("label[1,", y, ";", F(C(setting_name_color, S('Setting "@1" is not available on your Luanti version', def.short_desc))), "]")
		fs.y = y + padding
		return
	end

	if raw_value ~= nil then
		fs:add(
			"button[", 0.625 - b_size_2, ",", y - b_size_2, ";", b_size, ",", b_size, ";",
			"__reset__", name, ";X]",
			"tooltip[",
			"__reset__", name, ";",
			S("Revert to default"), "]"
		)
	end
	if def.type == "boolean" then
		fs:add(
			"checkbox[", 1, ",", y, ";",
			name, ";",
			F(C(setting_name_color, def.short_desc)), ";",
			value, "]"
		)
		y = y + 0.5
	elseif def.type == "enum" then
		-- add tooltip to area instead of dropdown to also show it on
		-- the label and additionally prevent the tooltip obscuring the
		-- options when using the mouse to select one
		tt_ref = ("%f,%f;%f,%f"):format(1, y-0.1, 9.3, 0.5)
		local selected
		fs:add(
			"label[1,", y, ";", F(C(setting_name_color, def.short_desc)), "]",
			-- Ugly workaround: override any area tooltips when
			-- mousing over the dropdown options by a hopefully
			-- unobtrusive tooltip
			"tooltip[", name, "; ]",
			"dropdown[1,", y + 0.175, ";9.3,0.3;",
			name, ";"
		)

		for _, option in ipairs(def.options) do
			local name, desc = option.name, option.description
			desc = desc or name
			if name == value then
				selected = desc .. " " .. S("(currently selected)")
			end
			if name == def.ui_default then
				desc = desc .. " " .. S("(default)")
			end
			fs:add(F(desc), ",")
		end
		if not selected then
			-- option list changed, current selected value no longer supported
			selected = value .. " " .. S("(currently selected, but INVALID! PLEASE choose a valid setting)")
		end
		-- add currently selected entry a second time at the end and
		-- select that one to allow change detection
		fs:add(
			F(selected), ";",
			#def.options + 1,
			";true]"
		)
		y = y + 0.85
	elseif def.type == "slider" then
		local sb_height = fs.mobile and 0.5 or 0.25
		-- add tooltip to area to display it not only on the slider itself
		tt_ref = ("%f,%f;%f,%f"):format(1, y-0.1, 9.3, 0.25 + sb_height)
		local count = #def.options
		local selected
		fs:add(
			"label[1,", y, ";", F(C(setting_name_color, def.short_desc)), "]",
			"scroll_container[5.25,", y + 0.05 + sb_height / 2, ";5,0.3;", name, ";vertical;1]"
		)

		for i, option in ipairs(def.options) do
			local name, desc = option.name, option.description or option.name
			if name == value then
				selected = i
			end
			if name == def.ui_default then
				desc = desc .. " " .. S("(default)")
			end
			fs:add(
				"label[0,", i + 0.1, ";", F(desc), "]"
			)
		end
		if not selected then
			count = count + 1
			selected = count
			fs:add(
				"label[0,", count + 0.1, ";", F(value .. " " .. S("(invalid)")), "]"
			)
		end
		fs:add(
			"scroll_container_end[]",
			"scrollbaroptions[thumbsize=1;arrows=show;smallstep=1;min=1;max=", count, "]",
			"scrollbar[1,", y + 0.175, ";4,", sb_height, ";horizontal;", name, ";", selected, "]"
		)
		y = y + 0.6 + sb_height
	end
	if def.long_desc then
		fs:add(
			"tooltip[",
			tt_ref, ";",
			F(def.long_desc), "]"
		)
	end

	fs.y = y + padding
end

local function generate_section_label(section, fs)
	local y = fs.y
	fs:add(
		"label[0.375,", y, ";", F(C(section_name_color, section)), "]",
		"box[0.375,", y + 0.15, ";10,0.025;#FFFFFFFF]"
	 )
	 fs.y = y + 0.5
end

local player_fs_info = {}

local function generate_settings_formspec (player)
	local fs_info = player_fs_info[player]
	local fs = new_stringbuilder()
	fs.mobile = mcl_player.get_player_setting(player, "mcl_player:mobile_ui", false)
	fs:add(
		"formspec_version[6]",
		"size[11.75,10.9]",
		-- Title
		"label[0.375,0.375;",
		F(C(mcl_formspec.label_color, S("Player specific settings and customization"))), "]"
	)

	-- Settings buttons
	local x = 0.5
	for _, def in pairs(player_settings_buttons) do
		fs:add(
			"image_button[", x, ",0.75;1.1,1.1;", def.icon, ";", def.field, ";]",
			"tooltip[", def.field, ";", F(def.description), "]"
		)
		x = x + 1.5
	end

	-- Generic settings area
	x = fs.mobile and 0.625 or 0.5
	local height = 8
	local scroll_factor = 0.01
	fs:add(
		"scroll_container[", x, ",2.5;11,", height, ";_settings_scroll;vertical;", scroll_factor, "]"
	)
	fs.y = 0.0

	local section
	for _, name in ipairs(get_sorted_setting_names()) do
		local def = player_settings[name]
		if def.section ~= section then
			fs.y = fs.y + 0.25
			section = def.section
			generate_section_label(def._translated_section, fs)
		end

		generate_setting_fragment(player, name, def, fs)
	end

	-- scroll factor is 0.01, height is 8
	local width = fs.mobile and 0.5 or 0.25
	local scroll_max = math.ceil(math.max(0, fs.y - height) / scroll_factor)
	local thumb_size = math.floor((height / fs.y) * scroll_max)
	local scroll = 0
	if fs_info then
		if fs_info.scroll_max == scroll_max then
			scroll = fs_info.scroll
		elseif fs_info.scroll_max then
			scroll = math.floor(scroll_max * fs_info.scroll / fs_info.scroll_max)
		end
	end
	fs:add(
		"scroll_container_end[]",
		"scrollbaroptions[", "smallstep=", math.floor(0.5 / scroll_factor),
		";max=", scroll_max,";thumbsize=", thumb_size, "]",
		"scrollbar[", x - width, ",2.5;", width, ",8;vertical;_settings_scroll;", scroll, "]"
	)

	-- remember max scroll to correctly reposition container on change
	player_fs_info[player] = { scroll_max = scroll_max }

	return fs:get()
end

function mcl_player.show_player_settings(player)
	if not player or not player:is_player() then return end

	local formspec = generate_settings_formspec(player)
	core.show_formspec(player:get_player_name(), "mcl_player:settings_formspec", formspec)
end

core.register_on_player_receive_fields(function(player, formname, fields)
		if fields.__mcl_player_settings then
			mcl_player.show_player_settings(player)
			return false
		elseif formname == "mcl_player:settings_formspec" then
			local refresh_fs = false
			for name, def in pairs(player_settings) do
				local value = fields[name]
				if fields["__reset__" .. name] then
					mcl_player.set_player_setting(player, name, nil)
					refresh_fs = true
				elseif value ~= nil then
					-- convert from formspec representation to type
					if def.type == "boolean" then
						mcl_player.set_player_setting(player, name, value == "true")
						refresh_fs = true
					elseif def.type == "enum" then
						local option = def.options[tonumber(value)]
						-- ignore if it was the duplicated entry at the end
						if option then
							mcl_player.set_player_setting(player, name, option.name)
							refresh_fs = true
						end
					elseif def.type == "slider" then
						local event = core.explode_scrollbar_event(value)
						if event.type == "CHG" then
							refresh_fs = mcl_player.get_player_setting(player, name) == nil
							local option = def.options[tonumber(event.value)]
							if option then
								mcl_player.set_player_setting(player, name, option.name)
							end
						end
					end
				end
			end

			if refresh_fs then
				if fields._settings_scroll and player_fs_info[player] then
					local event = core.explode_scrollbar_event(fields._settings_scroll)
					player_fs_info[player].scroll = event.value
				end
				mcl_player.show_player_settings(player)
				return false
			end

			-- no interesting change, let other
			-- on_player_receive_fields handle settings button
			-- presses
		end
end)
