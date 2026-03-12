local S = core.get_translator(core.get_current_modname())
local C = core.colorize

mcl_jukebox = {}
mcl_jukebox.registered_records = {}

local HEAR_DISTANCE = 65

-- Player name-indexed table containing the currently heard track
local active_tracks = {}
mcl_jukebox.active_tracks = active_tracks

-- Player name-indexed table containing the current used HUD ID for the “Now playing” message.
local active_huds = {}

-- Player name-indexed table for the “Now playing” message.
-- Used to make sure that core.after only applies to the latest HUD change event
local hud_sequence_numbers = {}

-- get random disc itemstring that is obtainable as creeper loot
function mcl_jukebox.get_random_creeper_loot()
	local _, key = table.random_element(mcl_jukebox.registered_records, function(_, v) return v.id and not v.exclude_from_creeperdrop end)
	return key
end

function mcl_jukebox.register_record_definition(def)
	local itemstring = "mcl_jukebox:record_"..def.id
	mcl_jukebox.registered_records[itemstring] = def
	local entryname = S("Music Disc")
	local longdesc = S("A music disc holds a single music track which can be used in a jukebox to play music.")
	local usagehelp = S("Place a music disc into an empty jukebox to play the music. Use the jukebox again to retrieve the music disc. The music can only be heard by you, not by other players.")
	core.register_craftitem(":"..itemstring, {
		description = S("Music Disc"),
		_tt_help = C(mcl_colors.GRAY, S("@1—@2", def.author, def.title)),
		_doc_items_create_entry = true,
		_doc_items_entry_name = entryname,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		inventory_image = def.texture,
		stack_max = 1,
		groups = { music_record = 1, rarity = def.rarity or 1 },
	})
end

-- Old function, for backwards compatibility reasons still allows the old multi argument way of calling it.
function mcl_jukebox.register_record(title, author, identifier, image, sound, nocreeper)
	if type(title) == "table" then
		return mcl_jukebox.register_record_definition(title)
	end
	return mcl_jukebox.register_record_definition({
		title = title,
		author = author,
		id = identifier,
		texture = image,
		sound = sound,
		exclude_from_creeperdrop = nocreeper
	})
end

local function now_playing(player, name)
	local playername = player:get_player_name()
	local hud = active_huds[playername]
	local text = S("Now playing: @1—@2", mcl_jukebox.registered_records[name].author, mcl_jukebox.registered_records[name].title)

	if not hud_sequence_numbers[playername] then
		hud_sequence_numbers[playername] = 1
	else
		hud_sequence_numbers[playername] = hud_sequence_numbers[playername] + 1
	end

	local id
	if hud then
		id = hud
		player:hud_change(id, "text", text)
	else
		id = player:hud_add({
			type = "text",
			position = { x=0.5, y=0.8 },
			offset = { x=0, y = 0 },
			number = 0x55FFFF,
			text = text,
			z_index = 100,
		})
		active_huds[playername] = id
	end
	core.after(5, function(tab)
		local playername = tab[1]
		local player = core.get_player_by_name(playername)
		local id = tab[2]
		local seq = tab[3]
		if not player or not player:is_player() or not active_huds[playername] or not hud_sequence_numbers[playername] or seq ~= hud_sequence_numbers[playername] then
			return
		end
		if id and id == active_huds[playername] then
			player:hud_remove(active_huds[playername])
			active_huds[playername] = nil
		end
	end, {playername, id, hud_sequence_numbers[playername]})
end

local function check_active_tracks()
	for k,v in pairs(active_tracks) do
		local pos = core.get_position_from_hash(k)
		local player_near = false
		for _ in mcl_util.connected_players(pos, HEAR_DISTANCE) do
			player_near = true
			break
		end
		if not player_near then
			core.sound_stop(v)
			active_tracks[k] = nil
		end
	end

end

core.register_on_leaveplayer(function(player)
	check_active_tracks()
	active_huds[player:get_player_name()] = nil
	hud_sequence_numbers[player:get_player_name()] = nil
end)

-- Jukebox crafting
core.register_craft({
	output = "mcl_jukebox:jukebox",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "mcl_core:diamond", "group:wood"},
		{"group:wood", "group:wood", "group:wood"},
	}
})

local function play_record(pos, itemstack, player)
	local item_name = itemstack:get_name()
	-- ensure the jukebox uses the new record names for old records
	local name = core.registered_aliases[item_name] or item_name
	local ph = core.hash_node_position(pos)
	if mcl_jukebox.registered_records[name] then
		if active_tracks[ph] then
			core.sound_stop(active_tracks[ph])
			active_tracks[ph] = nil
		end
		active_tracks[ph] = core.sound_play(mcl_jukebox.registered_records[name].sound, {
			gain = 1,
			pos = pos,
			max_hear_distance = HEAR_DISTANCE,
		})
		now_playing(player, name)
		return true
	end
	return false
end

-- Jukebox
core.register_node("mcl_jukebox:jukebox", {
	description = S("Jukebox"),
	_tt_help = S("Uses music discs to play music"),
	_doc_items_longdesc = S("Jukeboxes play music when they're supplied with a music disc."),
	_doc_items_usagehelp = S("Place a music disc into an empty jukebox to insert the music disc and play music. If the jukebox already has a music disc, you will retrieve this music disc first. The music can only be heard by you, not by other players."),
	tiles = {"mcl_jukebox_top.png", "mcl_jukebox_side.png", "mcl_jukebox_side.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	groups = {handy=1,axey=1, container=7, deco_block=1, material_wood=1, flammable=-1, unmovable_by_piston = 1},
	is_ground_content = false,
	on_construct = function(pos)
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 1)
	end,
	on_rightclick= function(pos, _, clicker, itemstack, _)
		if not clicker then return itemstack end
		local cname = clicker:get_player_name()
		local ph = core.hash_node_position(pos)
		if core.is_protected(pos, cname) then
			core.record_protection_violation(pos, cname)
			return itemstack
		end
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		if not inv:is_empty("main") then
			-- Jukebox contains a disc: Stop music and remove disc
			if active_tracks[ph] then
				core.sound_stop(active_tracks[ph])
			end
			local lx = pos.x
			local ly = pos.y+1
			local lz = pos.z
			local record = inv:get_stack("main", 1)
			local dropped_item = core.add_item({x=lx, y=ly, z=lz}, record)
			-- Rotate record to match with “slot” texture
			dropped_item:set_yaw(math.pi/2)
			inv:set_stack("main", 1, "")
			if active_tracks[ph] then
				core.sound_stop(active_tracks[ph])
				active_tracks[ph] = nil
			end
			if active_huds[cname] then
				clicker:hud_remove(active_huds[cname])
				active_huds[cname] = nil
			end
			mcl_redstone.update_comparators(pos)
		else
			inv:set_size("main", 1) -- if the inventory isn't initialized it registers as empty - initialize it to be sure so discs are not "swallowed" by the jukebox
			-- Jukebox is empty: Play track if player holds music record
			local playing = play_record(pos, itemstack, clicker)
			if playing then
				local put_itemstack = ItemStack(itemstack)
				put_itemstack:set_count(1)
				inv:set_stack("main", 1, put_itemstack)
				itemstack:take_item()
				mcl_redstone.update_comparators(pos)
			end
		end
		return itemstack
	end,
	allow_metadata_inventory_move = function(pos, _, _, _, _, count, player)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return 0
		else
			return count
		end
	end,
	allow_metadata_inventory_take = function(pos, _, _, stack, player)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	allow_metadata_inventory_put = function(pos, _, _, stack, player)
		local name = player:get_player_name()
		if core.is_protected(pos, name) then
			core.record_protection_violation(pos, name)
			return 0
		else
			return stack:get_count()
		end
	end,
	after_dig_node = function(pos, _, oldmetadata, digger)
		local name = digger:get_player_name()
		local meta = core.get_meta(pos)
		local meta2 = meta
		local ph = core.hash_node_position(pos)
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		local stack = inv:get_stack("main", 1)
		if not stack:is_empty() then
			local p = {x=pos.x+math.random(0, 10)/10-0.5, y=pos.y, z=pos.z+math.random(0, 10)/10-0.5}
			local dropped_item = core.add_item(p, stack)
			-- Rotate record to match with “slot” texture
			dropped_item:set_yaw(math.pi/2)
			if active_tracks[ph] then
				core.sound_stop(active_tracks[ph])
				active_tracks[ph] = nil
			end
			if active_huds[name] then
				digger:hud_remove(active_huds[name])
				active_huds[name] = nil
			end
		end
		meta:from_table(meta2:to_table())
	end,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,
	_mcl_burntime = 15
})

mcl_jukebox.register_record({
	title = "The Evil Sister (Jordach's Mix)",
	author = "SoundHelix",
	id = "13",
	texture = "mcl_jukebox_record_13.png",
	sound = "mcl_jukebox_track_1",
	exclude_from_creeperdrop = false,
	comparator_signal = 1,
})
mcl_jukebox.register_record({
	title = "The Energetic Rat (Jordach's Mix)",
	author = "SoundHelix",
	id = "wait",
	texture = "mcl_jukebox_record_wait.png",
	sound = "mcl_jukebox_track_2",
	comparator_signal = 12,
})
mcl_jukebox.register_record({
	title = "Eastern Feeling",
	author = "Jordach",
	id = "blocks",
	texture = "mcl_jukebox_record_blocks.png",
	sound = "mcl_jukebox_track_3",
	comparator_signal = 3,
})
mcl_jukebox.register_record({
	title = "Minetest",
	author = "Jordach",
	id = "far",
	texture = "mcl_jukebox_record_far.png",
	sound = "mcl_jukebox_track_4",
	comparator_signal = 5,
})
mcl_jukebox.register_record({
	title =  "Soaring over the sea",
	author =  "mactonite",
	id = "chirp",
	texture = "mcl_jukebox_record_chirp.png",
	sound = "mcl_jukebox_track_5",
	exclude_from_creeperdrop = true,
	comparator_signal = 4,
})
mcl_jukebox.register_record({
	title = "Winter Feeling",
	author = "Tom Peter",
	id = "strad",
	texture = "mcl_jukebox_record_strad.png",
	sound = "mcl_jukebox_track_6",
	comparator_signal = 9,
})
mcl_jukebox.register_record({
	title = "Synthgroove (Jordach's Mix)",
	author = "HeroOfTheWinds",
	id = "mellohi",
	texture = "mcl_jukebox_record_mellohi.png",
	sound = "mcl_jukebox_track_7",
	comparator_signal = 7,
})
mcl_jukebox.register_record({
	title = "The Clueless Frog (Jordach's Mix)",
	author = "SoundHelix",
	id = "mall",
	texture = "mcl_jukebox_record_mall.png",
	sound = "mcl_jukebox_track_8",
	exclude_from_creeperdrop = true,
	comparator_signal = 6,
})

--add backward compatibility
core.register_alias("mcl_jukebox:record_1", "mcl_jukebox:record_13")
core.register_alias("mcl_jukebox:record_2", "mcl_jukebox:record_wait")
core.register_alias("mcl_jukebox:record_3", "mcl_jukebox:record_blocks")
core.register_alias("mcl_jukebox:record_4", "mcl_jukebox:record_far")
core.register_alias("mcl_jukebox:record_5", "mcl_jukebox:record_chirp")
core.register_alias("mcl_jukebox:record_6", "mcl_jukebox:record_strad")
core.register_alias("mcl_jukebox:record_7", "mcl_jukebox:record_mellohi")
core.register_alias("mcl_jukebox:record_8", "mcl_jukebox:record_mall")
