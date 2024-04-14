-- Global namespace for functions

mcl_fire = {}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

local has_mcl_portals = minetest.get_modpath("mcl_portals")

local adjacents = {
	{ x =-1, y = 0, z = 0 },
	{ x = 1, y = 0, z = 0 },
	{ x = 0, y = 1, z = 0 },
	{ x = 0, y =-1, z = 0 },
	{ x = 0, y = 0, z =-1 },
	{ x = 0, y = 0, z = 1 },
}

local function shuffle_table(t)
	for i = #t, 1, -1 do
		local r = math.random(i)
		t[i], t[r] = t[r], t[i]
	end
end
shuffle_table(adjacents)

local function has_flammable(pos)
	for k,v in pairs(adjacents) do
		local p=vector.add(pos,v)
		local n=minetest.get_node_or_nil(p)
		if n and minetest.get_item_group(n.name, "flammable") ~= 0 then
			return p
		end
	end
end

-- When enabled, fire destroys other blocks.
local fire_enabled = minetest.settings:get_bool("enable_fire", true)

-- Help texts
local fire_help, eternal_fire_help
if fire_enabled then
	fire_help = S("Fire is a damaging and destructive but short-lived kind of block. It will destroy and spread towards near flammable blocks, but fire will disappear when there is nothing to burn left. It will be extinguished by nearby water and rain. Fire can be destroyed safely by punching it, but it is hurtful if you stand directly in it. If a fire is started above netherrack or a magma block, it will immediately turn into an eternal fire.")
else
	fire_help = S("Fire is a damaging but non-destructive short-lived kind of block. It will disappear when there is no flammable block around. Fire does not destroy blocks, at least not in this world. It will be extinguished by nearby water and rain. Fire can be destroyed safely by punching it, but it is hurtful if you stand directly in it. If a fire is started above netherrack or a magma block, it will immediately turn into an eternal fire.")
end

if fire_enabled then
	eternal_fire_help = S("Eternal fire is a damaging block that might create more fire. It will create fire around it when flammable blocks are nearby. Eternal fire can be extinguished by punches and nearby water blocks. Other than (normal) fire, eternal fire does not get extinguished on its own and also continues to burn under rain. Punching eternal fire is safe, but it hurts if you stand inside.")
else
	eternal_fire_help = S("Eternal fire is a damaging block. Eternal fire can be extinguished by punches and nearby water blocks. Other than (normal) fire, eternal fire does not get extinguished on its own and also continues to burn under rain. Punching eternal fire is safe, but it hurts if you stand inside.")
end

local function spawn_fire(pos, age)
	minetest.set_node(pos, {name="mcl_fire:fire", param2 = age})
	minetest.check_single_for_falling({x=pos.x, y=pos.y+1, z=pos.z})
end

minetest.register_node("mcl_fire:fire", {
	description = S("Fire"),
	_doc_items_longdesc = fire_help,
	drawtype = "firelike",
	tiles = {
		{
			name = "fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	inventory_image = "fire_basic_flame.png",
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 1,
	groups = {fire = 1, dig_immediate = 3, not_in_creative_inventory = 1, dig_by_piston=1, destroys_items=1, set_on_fire=8},
	floodable = true,
	on_flood = function(pos, oldnode, newnode)
		if minetest.get_item_group(newnode.name, "water") ~= 0 then
			minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		end
	end,
	drop = "",
	sounds = {},
	-- Turn into eternal fire on special blocks, light Nether portal (if possible), start burning timer
	on_construct = function(pos)
		local bpos = {x=pos.x, y=pos.y-1, z=pos.z}
		local under = minetest.get_node(bpos).name

		local dim = mcl_worlds.pos_to_dimension(bpos)
		if under == "mcl_nether:magma" or under == "mcl_nether:netherrack" or (under == "mcl_core:bedrock" and dim == "end") then
			minetest.swap_node(pos, {name = "mcl_fire:eternal_fire"})
		end

		if has_mcl_portals then
			mcl_portals.light_nether_portal(pos)
		end
	end,
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_fire:eternal_fire", {
	description = S("Eternal Fire"),
	_doc_items_longdesc = eternal_fire_help,
	drawtype = "firelike",
	tiles = {
		{
			name = "fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	inventory_image = "fire_basic_flame.png",
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 1,
	groups = {fire = 1, dig_immediate = 3, not_in_creative_inventory = 1, dig_by_piston = 1, destroys_items = 1, set_on_fire=8},
	floodable = true,
	on_flood = function(pos, oldnode, newnode)
		if minetest.get_item_group(newnode.name, "water") ~= 0 then
			minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		end
	end,
	-- Start burning timer and light Nether portal (if possible)
	on_construct = function(pos)
		if has_mcl_portals then --Calling directly minetest.get_modpath consumes 4x more compute time
			mcl_portals.light_nether_portal(pos)
		end
	end,
	sounds = {},
	drop = "",
	_mcl_blast_resistance = 0,
})

--
-- Sound
--

local handles = {}
local timer = 0

-- Parameters

local radius = 8 -- Flame node search radius around player
local cycle = 3 -- Cycle time for sound updates

-- Update sound for player

function mcl_fire.update_player_sound(player)
	local player_name = player:get_player_name()
	-- Search for flame nodes in radius around player
	local ppos = player:get_pos()
	local areamin = vector.subtract(ppos, radius)
	local areamax = vector.add(ppos, radius)
	local fpos, num = minetest.find_nodes_in_area(
		areamin,
		areamax,
		{"mcl_fire:fire", "mcl_fire:eternal_fire"}
	)
	-- Total number of flames in radius
	local flames = (num["mcl_fire:fire"] or 0) +
		(num["mcl_fire:eternal_fire"] or 0)
	-- Stop previous sound
	if handles[player_name] then
		minetest.sound_fade(handles[player_name], -0.4, 0.0)
		handles[player_name] = nil
	end
	-- If flames
	if flames > 0 then
		-- Find centre of flame positions
		local fposmid = fpos[1]
		-- If more than 1 flame
		if #fpos > 1 then
			local fposmin = areamax
			local fposmax = areamin
			for i = 1, #fpos do
				local fposi = fpos[i]
				if fposi.x > fposmax.x then
					fposmax.x = fposi.x
				end
				if fposi.y > fposmax.y then
					fposmax.y = fposi.y
				end
				if fposi.z > fposmax.z then
					fposmax.z = fposi.z
				end
				if fposi.x < fposmin.x then
					fposmin.x = fposi.x
				end
				if fposi.y < fposmin.y then
					fposmin.y = fposi.y
				end
				if fposi.z < fposmin.z then
					fposmin.z = fposi.z
				end
			end
			fposmid = vector.divide(vector.add(fposmin, fposmax), 2)
		end
		-- Play sound
		local handle = minetest.sound_play(
			"fire_fire",
			{
				pos = fposmid,
				to_player = player_name,
				gain = math.min(0.06 * (1 + flames * 0.125), 0.18),
				max_hear_distance = 32,
				loop = true, -- In case of lag
			}
		)
		-- Store sound handle for this player
		if handle then
			handles[player_name] = handle
		end
	end
end

-- Cycle for updating players sounds

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < cycle then
		return
	end

	timer = 0
	local players = minetest.get_connected_players()
	for n = 1, #players do
		mcl_fire.update_player_sound(players[n])
	end
end)

-- Stop sound and clear handle on player leave

minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	if handles[player_name] then
		minetest.sound_stop(handles[player_name])
		handles[player_name] = nil
	end
end)

-- [...]a fire that is not adjacent to any flammable block does not spread, even to another flammable block within the normal range.
-- https://minecraft.fandom.com/wiki/Fire#Spread

local function check_aircube(p1,p2)
	local nds=minetest.find_nodes_in_area(p1,p2,{"air"})
	shuffle_table(nds)
	for k,v in pairs(nds) do
		if has_flammable(v) then return v end
	end
end

-- [...] a fire block can turn any air block that is adjacent to a flammable block into a fire block. This can happen at a distance of up to one block downward, one block sideways (including diagonals), and four blocks upward of the original fire block (not the block the fire is on/next to).
local function get_ignitable(pos)
	return check_aircube(vector.add(pos,vector.new(-1,-1,-1)),vector.add(pos,vector.new(1,4,1)))
end
-- Fire spreads from a still lava block similarly: any air block one above and up to one block sideways (including diagonals) or two above and two blocks sideways (including diagonals) that is adjacent to a flammable block may be turned into a fire block.
local function get_ignitable_by_lava(pos)
	return check_aircube(vector.add(pos,vector.new(-1,1,-1)),vector.add(pos,vector.new(1,1,1))) or check_aircube(vector.add(pos,vector.new(-2,2,-2)),vector.add(pos,vector.new(2,2,2))) or nil
end

--
-- ABMs
--

-- Extinguish all flames quickly with water and such

minetest.register_abm({
	label = "Extinguish fire",
	nodenames = {"mcl_fire:fire", "mcl_fire:eternal_fire"},
	neighbors = {"group:puts_out_fire"},
	interval = 3,
	chance = 1,
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.remove_node(pos)
		minetest.sound_play("fire_extinguish_flame",
			{pos = pos, max_hear_distance = 16, gain = 0.15}, true)
	end,
})

-- Enable the following ABMs according to 'enable fire' setting
if not fire_enabled then

	-- Occasionally remove fire if fire disabled
	-- NOTE: Fire is normally extinguished in timer function
	minetest.register_abm({
		label = "Remove disabled fire",
		nodenames = {"mcl_fire:fire"},
		interval = 10,
		chance = 10,
		catch_up = false,
		action = minetest.remove_node,
	})

else -- Fire enabled

	-- Fire Spread
	minetest.register_abm({
		label = "Ignite flame",
		nodenames ={"mcl_fire:fire","mcl_fire:eternal_fire"},
		interval = 7,
		chance = 12,
		catch_up = false,
		action = function(pos)
			local p = get_ignitable(pos)
			if p then
				spawn_fire(p)
				shuffle_table(adjacents)
			end
		end
	})

	--lava fire spread
	minetest.register_abm({
		label = "Ignite fire by lava",
		nodenames = {"mcl_core:lava_source","mcl_nether:nether_lava_source"},
		neighbors = {"group:flammable"},
		interval = 15,
		chance = 9,
		catch_up = false,
		action = function(pos)
			local p=get_ignitable_by_lava(pos)
			if p then
				spawn_fire(p)
			end
		end,
	})

	minetest.register_abm({
		label = "Remove fires",
		nodenames = {"mcl_fire:fire"},
		interval = 7,
		chance = 3,
		catch_up = false,
		action = function(pos)
			local p=has_flammable(pos)
			if p then
				local n=minetest.get_node_or_nil(p)
				if n and minetest.get_item_group(n.name, "flammable") < 1 then
					minetest.remove_node(pos)
				end
			else
				minetest.remove_node(pos)
			end
		end,
	})

	-- Remove flammable nodes around basic flame
	minetest.register_abm({
		label = "Remove flammable nodes",
		nodenames = {"mcl_fire:fire","mcl_fire:eternal_fire"},
		neighbors = {"group:flammable"},
		interval = 5,
		chance = 18,
		catch_up = false,
		action = function(pos)
			local p = has_flammable(pos)
			if not p then
				return
			end

			local nn = minetest.get_node(p).name
			local def = minetest.registered_nodes[nn]
			local fgroup = minetest.get_item_group(nn, "flammable")

			if def and def._on_burn then
				def._on_burn(p)
			elseif fgroup ~= -1 then
				spawn_fire(p)
				minetest.check_for_falling(p)
			end
		end
	})
end

-- Set pointed_thing on (normal) fire.
-- * pointed_thing: Pointed thing to ignite
-- * player: Player who sets fire or nil if nobody
-- * allow_on_fire: If false, can't ignite fire on fire (default: true)
function mcl_fire.set_fire(pointed_thing, player, allow_on_fire)
	local pname
	if player == nil then
		pname = ""
	else
		pname = player:get_player_name()
	end

	if minetest.is_protected(pointed_thing.above, pname) then
		minetest.record_protection_violation(pointed_thing.above, pname)
		return
	end

	local n_pointed = minetest.get_node(pointed_thing.under)
	if allow_on_fire == false and minetest.get_item_group(n_pointed.name, "fire") ~= 0 then
		return
	end

	local n_fire = minetest.get_node(pointed_thing.above)
	if n_fire.name ~= "air" then
		return
	end

	local n_below = minetest.get_node(vector.offset(pointed_thing.above, 0, -1, 0))
	if minetest.get_item_group(n_below.name, "water") ~= 0 then
		return
	end

	minetest.set_node(pointed_thing.above, {name="mcl_fire:fire"})
end

minetest.register_alias("mcl_fire:basic_flame", "mcl_fire:fire")
minetest.register_alias("fire:basic_flame", "mcl_fire:fire")
minetest.register_alias("fire:permanent_flame", "mcl_fire:eternal_fire")

dofile(modpath.."/flint_and_steel.lua")
dofile(modpath.."/fire_charge.lua")
