-- Based on 4itemnames mod by 4aiman

local wield = {}
local wieldindex = {}
local huds = {}
local dtimes = {}
local dlimit = 3  -- HUD element will be hidden after this many seconds

local hudbars_mod = minetest.get_modpath("hudbars")

-- TODO: when < minetest 5.9 isn't supported anymore, remove this variable check and replace all occurences of [hud_elem_type_field] with type
local hud_elem_type_field = "type"
if not minetest.features.hud_def_type_field then
	hud_elem_type_field = "hud_elem_type"
end

local function set_hud(player)
	if not player:is_player() then return end
	local player_name = player:get_player_name()
	-- Fixed offset in config file
	local fixed = tonumber(minetest.settings:get("show_wielded_item_y_offset"))
	local off
	if fixed and fixed ~= -1 then
		-- Manual offset
		off = {x=0, y=-fixed}
	else
		-- Default offset
		off = {x=0, y=-101}

		if hudbars_mod then
			-- Tweak offset if hudbars mod was found

			local rows = math.floor((#hb.get_hudbar_identifiers()-1) / 2) + 1
			local vmargin = tonumber(minetest.settings:get("hudbars_vmargin")) or 24
			off.y = -76 - vmargin*rows
		end

		-- Dirty trick to avoid collision with Minetest's status text (e.g. “Volume changed to 0%”)
		if off.y >= -167 and off.y <= -156 then
			off.y = -181
		end
	end

	huds[player_name] = player:hud_add({
		[hud_elem_type_field] = "text",
		position = {x=0.5, y=1},
		offset = off,
		alignment = {x=0, y=0},
		number = 0xFFFFFF ,
		text = "",
		z_index = 100,
	})
end

minetest.register_on_joinplayer(function(player)
	set_hud(player)

	local name = player:get_player_name()
	wield[name] = player:get_wielded_item():get_name()
	wieldindex[name] = player:get_wield_index()
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	wield[name] = nil
	wieldindex[name] = nil
end)

local function get_first_line(text)
	-- Cut off text after first newline
	local firstnewline = string.find(text, "\n")
	if firstnewline then
		text = string.sub(text, 1, firstnewline-1)
	end
	return text
end

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		local wstack = player:get_wielded_item()
		local wname = wstack:get_name()
		local windex = player:get_wield_index()

		if dtimes[player_name] and dtimes[player_name] < dlimit then
			dtimes[player_name] = dtimes[player_name] + dtime
			if dtimes[player_name] > dlimit and huds[player_name] then
				player:hud_change(huds[player_name], 'text', "")
			end
		end

		-- Update HUD when wielded item or wielded index changed
		if wname ~= wield[player_name] or windex ~= wieldindex[player_name] then
			wieldindex[player_name] = windex
			wield[player_name] = wname
			dtimes[player_name] = 0

			if huds[player_name] then

				-- Get description (various fallback checks for old Minetest versions)
				local def = minetest.registered_items[wname]
				local desc
				if wstack.get_short_description then
					-- get_short_description()
					desc = wstack:get_short_description()
				end
				if (not desc or desc == "") and wstack.get_description then
					-- get_description()
					desc = wstack:get_description()
					desc = get_first_line(desc)
				end
				if (not desc or desc == "") and not wstack.get_description then
					-- Metadata (old versions only)
					local meta = wstack:get_meta()
					desc = meta:get_string("description")
					desc = get_first_line(desc)
				end
				if not desc or desc == "" then
					-- Item definition
					desc = def.description
					desc = get_first_line(desc)
				end
				if not desc or desc == "" then
					-- Final fallback: itemstring
					desc = wname
				end

				-- Print description
				if desc then
					-- Optionally append the 'technical' itemname
					local tech = minetest.settings:get_bool("show_wielded_item_itemname", false)
					if tech and desc ~= "" then
						desc = desc .. " ["..wname.."]"
					end
					player:hud_change(huds[player_name], 'text', desc)
				end
			end
		end
	end
end)

