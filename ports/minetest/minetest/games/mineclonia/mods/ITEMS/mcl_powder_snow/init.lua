local S = core.get_translator(core.get_current_modname())

core.register_node("mcl_powder_snow:powder_snow", {
	description = S("Powder Snow"),
	_doc_items_longdesc = S("This is a block of snow thats extra fluffy, this means players can sink in it"),
	_doc_items_hidden = false,
	tiles = {"powder_snow.png"},
	groups = {shovely=2, snow_cover=1, not_in_creative_inventory = 1, disable_suffocation = 1,no_spawning_inside = 1,},
	sounds = mcl_sounds.node_sound_snow_defaults(),
	post_effect_color = "#CFD7DBFF",
	walkable = false,
	move_resistance = 3,
	is_ground_content = false, -- set to false to potentially create huge drops into caves >:)
	on_construct = mcl_core.on_snow_construct,
	after_destruct = mcl_core.after_snow_destruct,
	on_rightclick = function(pos, _, clicker, itemstack, pointed_thing)
		if itemstack:get_name() ==  "mcl_buckets:bucket_empty" then
			core.set_node(pos, {name = "air"})
			if not core.is_creative_enabled(clicker:get_player_name()) then
				if itemstack:get_count() == 1 then
					itemstack = ItemStack("mcl_powder_snow:bucket_powder_snow")
				else
					local inv = clicker:get_inventory()
					if inv:room_for_item("main", "mcl_powder_snow:bucket_powder_snow") then
						inv:add_item("main", "mcl_powder_snow:bucket_powder_snow")
					else
						core.add_item(clicker:get_pos(), "mcl_powder_snow:bucket_powder_snow")
					end
					itemstack:take_item()
				end
			end
		elseif itemstack:get_definition().type == "node" then
			core.item_place_node(itemstack, clicker, pointed_thing)
		end

		return itemstack
	end,
	_mcl_hardness = 0.1,
	_mcl_silk_touch_drop = false,
})

mcl_buckets.register_liquid({
	id = "powder_snow",
	source_take = {"mcl_powder_snow:powder_snow"},
	source_place = "mcl_powder_snow:powder_snow",
	bucketname = "mcl_powder_snow:bucket_powder_snow",
	inventory_image = "bucket_powder_snow.png",
	name = S("Powder Snow Bucket"),
	longdesc = S("This bucket is filled powder snow"),
	usagehelp = S("Place it to empty the bucket and place powder snow. Obtain by right clicking on a block of powder snow with an empty bucket."),
	tt_help = S("Places a powder snow block"),
})

local freezing_stages =
{
	"freezing_1.png",
	"freezing_2.png",
	"freezing_3.png",
}

-- key value pair
-- key: ObjectRef of the player
-- value: list of hud ids
local freezing_players = {}

local function remove_freezing_hud(player)
	local freezing_data = freezing_players[player]
	if freezing_data and #freezing_data > 0 then
		for _, hud_id in pairs(freezing_data) do
			player:hud_remove(hud_id)
		end
	end

	freezing_players[player] = nil
end

local function show_freezing_hud(player, level)
	remove_freezing_hud(player)
	if not freezing_players[player] then
		freezing_players[player] = {}
	end
	local freezing_data = freezing_players[player]

	freezing_data[1] = player:hud_add({
		type = "image",
		position = {x = 0, y = 0},
		scale = {x = 2, y = 2},
		text = freezing_stages[level],
		alignment = {x = 1, y = 1},
		offset = {x = 0, y = 0},
		z_index = 4,
	})

	freezing_data[2] = player:hud_add({
		type = "image",
		position = {x = 1, y = 0},
		scale = {x = 2, y = 2},
		text = freezing_stages[level] .. "^[transform4",
		alignment = {x = -1, y = 1},
		offset = {x = 0, y = 0},
		z_index = 4,
	})

	freezing_data[3] = player:hud_add({
		type = "image",
		position = {x = 0, y = 1},
		scale = {x = 2, y = 2},
		text = freezing_stages[level] .. "^[transform6",
		alignment = {x = 1, y = -1},
		offset = {x = 0, y = 0},
		z_index = 4,
	})

	freezing_data[4] = player:hud_add({
		type = "image",
		position = {x = 1, y = 1},
		scale = {x = 2, y = 2},
		text = freezing_stages[level] .. "^[transform6^[transform4",
		alignment = {x = -1, y = -1},
		offset = {x = 0, y = 0},
		z_index = 4,
	})
end

local function player_has_leather_armor(player)
	local armor_list = player:get_inventory():get_list("armor")
	for i = 2, 5 do
		if core.get_item_group(armor_list[i]:get_name(), "armor_leather") == 1 then
			return true
		end
	end
	return false
end

mcl_player.register_globalstep_slow(function(player, dtime)
	local player_pos = player:get_pos()
	local player_meta = player:get_meta()
	local time_in_snow = tonumber(player_meta:get("time_in_snow"))

	if core.get_node(player_pos).name == "mcl_powder_snow:powder_snow" and not player_has_leather_armor(player) then
		if not time_in_snow then
			time_in_snow = 0
		end

		time_in_snow = math.min(time_in_snow + 0.5, 7)

		if time_in_snow > 5 then
			show_freezing_hud(player, 3)
			mcl_damage.damage_player(player, 0.5, {type = "freeze"})
			hb.change_hudbar(player, "health", nil, nil, "frozen_heart.png")
		elseif time_in_snow == 3 then
			show_freezing_hud(player, 2)
		elseif time_in_snow == 1 then
			show_freezing_hud(player, 1)
		end

		player_meta:set_string("time_in_snow", tostring(time_in_snow))
	elseif time_in_snow then
		time_in_snow = time_in_snow - 0.5

		if time_in_snow <= 0 then
			remove_freezing_hud(player)
			player_meta:set_string("time_in_snow", "")
			return
		else
			if time_in_snow == 1 then
				show_freezing_hud(player, 1)
			elseif time_in_snow == 3 then
				hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_health.png")
				show_freezing_hud(player, 2)
			end
		end

		player_meta:set_string("time_in_snow", tostring(time_in_snow))
	end
end)

core.register_on_joinplayer(function(player)
	local time_in_snow = tonumber(player:get_meta():get("time_in_snow"))

	if not time_in_snow then return end

	if time_in_snow > 5 then
		show_freezing_hud(player, 3)
		core.after(0, function() hb.change_hudbar(player, "health", nil, nil, "frozen_heart.png") end)
	elseif time_in_snow > 3 then
		show_freezing_hud(player, 2)
	elseif time_in_snow > 1 then
		show_freezing_hud(player, 1)
	end
end)

core.register_on_leaveplayer(function(player)
	freezing_players[player] = nil
end)

core.register_on_respawnplayer(function(player)
	remove_freezing_hud(player)
	hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_health.png")
end)
