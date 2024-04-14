mcl_villages = {}
mcl_villages.modpath = minetest.get_modpath(minetest.get_current_modname())

local village_chance = tonumber(minetest.settings:get("mcl_villages_village_chance")) or 100

dofile(mcl_villages.modpath.."/const.lua")
dofile(mcl_villages.modpath.."/utils.lua")
dofile(mcl_villages.modpath.."/foundation.lua")
dofile(mcl_villages.modpath.."/buildings.lua")
dofile(mcl_villages.modpath.."/paths.lua")

dofile(mcl_villages.modpath .. "/api.lua")

--
-- load settlements on server
--
mcl_villages.grundstellungen()

local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_alias("mcl_villages:stonebrickcarved", "mcl_core:stonebrickcarved")
minetest.register_alias("mcl_villages:structblock", "air")

--
-- on map generation, try to build a settlement
--
local function build_a_settlement(minp, maxp, blockseed)
	local pr = PseudoRandom(blockseed)

	local settlement_info = mcl_villages.create_site_plan_new(minp, maxp, pr)

	if not settlement_info then
		return
	end

	mcl_villages.terraform_new(settlement_info, pr)
	mcl_villages.place_schematics_new(settlement_info, pr, blockseed)

	-- TODO when run here minetest.find_path regularly fails :(
	--mcl_villages.paths_new(blockseed)
	--minetest.log("Completed village for " .. minetest.pos_to_string(minp))
end

local function ecb_village(blockpos, action, calls_remaining, param)
	if calls_remaining >= 1 then return end
	local minp, maxp, blockseed = param.minp, param.maxp, param.blockseed
	build_a_settlement(minp, maxp, blockseed)
end

-- Disable natural generation in singlenode.
local mg_name = minetest.get_mapgen_setting("mg_name")
if mg_name ~= "singlenode" then
	mcl_mapgen_core.register_generator("villages", nil, function(minp, maxp, blockseed)
		if maxp.y < 0 then return end

		if village_chance == 0 then
			return
		end
		local pr = PseudoRandom(blockseed)
		if pr:next(1, village_chance) == 1 then
			local big_minp = vector.offset(minp, -16, -16, -16)
			local big_maxp = vector.offset(maxp, 16, 16, 16)
			minetest.emerge_area(
				vector.copy(big_minp),
				vector.copy(big_maxp),
				ecb_village,
				{ minp = vector.copy(minp), maxp = vector.copy(maxp), blockseed = blockseed }
			)
		end
	end)
end

minetest.register_on_mods_loaded(function()
	local olfunc = minetest.registered_chatcommands["spawnstruct"].func
	minetest.registered_chatcommands["spawnstruct"].func = function(pn,p)
		if p == "village" then
			local pl = minetest.get_player_by_name(pn)
			local pos = vector.round(pl:get_pos())
			local minp = vector.subtract(pos, mcl_villages.half_map_chunk_size)
			local maxp = vector.add(pos, mcl_villages.half_map_chunk_size)
			build_a_settlement(minp, maxp, math.random(0,32767))
		else
			return olfunc(pn,p)
		end
	end
	minetest.registered_chatcommands["spawnstruct"].params = minetest.registered_chatcommands["spawnstruct"].params .. "|village"
end)

-- This is a light source so that lamps don't get placed near it
minetest.register_node("mcl_villages:building_block", {
	drawtype = "airlike",
	groups = { not_in_creative_inventory = 1 },
	light_source = 14,

	-- Somethings don't work reliably when done in the map building
	-- so we use a timer to run them later when they work more reliably
	-- e.g. spawning mobs, running minetest.find_path
	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		local minp = minetest.string_to_pos(meta:get_string("minp"))
		local maxp = minetest.string_to_pos(meta:get_string("maxp"))
		local node_type = meta:get_string("node_type")
		local blockseed = meta:get_string("blockseed")
		local has_beds = meta:get_int("has_beds") > 0 and true or false
		local has_jobs = meta:get_int("has_jobs") > 0 and true or false
		local is_belltower = meta:get_int("is_belltower") > 0 and true or false
		local bell_pos = minetest.string_to_pos(meta:get_string("bell_pos"))
		minetest.get_node_timer(pos):stop()
		minetest.set_node(pos, { name = node_type })
		mcl_villages.post_process_building(minp, maxp, blockseed, has_beds, has_jobs, is_belltower, bell_pos)
		return false
	end,
})

-- This should not run if the timer for the bell is still active
-- But how we would know that ...
minetest.register_lbm({
	name = "mcl_villages:clear_remains",
	run_at_every_load = true,
	nodenames = { "mcl_villages:no_paths" },
	action = minetest.remove_node,
})

-- This makes the temporary node invisble unless in creative mode
local drawtype = "airlike"
if minetest.is_creative_enabled("") then
	drawtype = "glasslike"
end

minetest.register_node("mcl_villages:no_paths", {
	description = S(
		"Prevent paths from being placed during villager generation. Replaced by air after village path generation"
	),
	walkable = true,
	paramtype = "light",
	drawtype = drawtype,
	inventory_image = "mcl_core_barrier.png",
	wield_image = "mcl_core_barrier.png",
	tiles = { "mcl_core_barrier.png" },
	is_ground_content = false,
	groups = { creative_breakable = 1, not_solid = 1 },
})

minetest.register_node("mcl_villages:path_endpoint", {
	description = S("Mark the node as a good place for paths to connect to"),
	is_ground_content = false,
	tiles = { "wool_white.png" },
	wield_image = "wool_white.png",
	wield_scale = { x = 1, y = 1, z = 0.5 },
	groups = { handy = 1, supported_node = 1, deco_block = 1 },
	sounds = mcl_sounds.node_sound_wool_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	stack_max = 64,
	drawtype = "nodebox",
	walkable = true,
	node_box = {
		type = "fixed",
		fixed = {
			{ -8 / 16, -8 / 16, -8 / 16, 8 / 16, -7 / 16, 8 / 16 },
		},
	},
	_mcl_hardness = 0.1,
	_mcl_blast_resistance = 0.1,
})

local schem_path = mcl_villages.modpath .. "/schematics/"

mcl_villages.register_bell({ name = "belltower", mts = schem_path .. "new_villages/belltower.mts", yadjust = 1 })

mcl_villages.register_well({
	name = "well",
	mts = schem_path .. "new_villages/well.mts",
	yadjust = -1,
})

for i = 1, 6 do
	mcl_villages.register_lamp({
		name = "lamp",
		mts = schem_path .. "new_villages/lamp_" .. i .. ".mts",
		yadjust = 1,
	})
end

mcl_villages.register_building({
	name = "house_big",
	mts = schem_path .. "new_villages/house_4_bed.mts",
	min_jobs = 6,
	max_jobs = 99,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "house_large",
	mts = schem_path .. "new_villages/house_3_bed.mts",
	min_jobs = 4,
	max_jobs = 99,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "house_medium",
	mts = schem_path .. "new_villages/house_2_bed.mts",
	min_jobs = 2,
	max_jobs = 99,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "house_small",
	mts = schem_path .. "new_villages/house_1_bed.mts",
	min_jobs = 1,
	max_jobs = 99,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "blacksmith",
	mts = schem_path .. "new_villages/blacksmith.mts",
	num_others = 8,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "butcher",
	mts = schem_path .. "new_villages/butcher.mts",
	num_others = 8,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "farm",
	mts = schem_path .. "new_villages/farm.mts",
	num_others = 3,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "fish_farm",
	mts = schem_path .. "new_villages/fishery.mts",
	num_others = 8,
	yadjust = -2,
})

mcl_villages.register_building({
	name = "fletcher",
	mts = schem_path .. "new_villages/fletcher.mts",
	num_others = 8,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "library",
	mts = schem_path .. "new_villages/library.mts",
	num_others = 15,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "map_shop",
	mts = schem_path .. "new_villages/cartographer.mts",
	num_others = 15,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "mason",
	mts = schem_path .. "new_villages/mason.mts",
	num_others = 8,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "mill",
	mts = schem_path .. "new_villages/mill.mts",
	num_others = 8,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "tannery",
	mts = schem_path .. "new_villages/leather_worker.mts",
	num_others = 8,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "tool_smith",
	mts = schem_path .. "new_villages/toolsmith.mts",
	num_others = 8,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "weapon_smith",
	mts = schem_path .. "new_villages/weaponsmith.mts",
	num_others = 8,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "chapel",
	mts = schem_path .. "new_villages/chapel.mts",
	num_others = 8,
	min_jobs = 1,
	max_jobs = 9,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "church",
	mts = schem_path .. "new_villages/church.mts",
	num_others = 20,
	min_jobs = 10,
	max_jobs = 99,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "farm_small",
	mts = schem_path .. "new_villages/farm_small_1.mts",
	num_others = 3,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "farm_small2",
	mts = schem_path .. "new_villages/farm_small_2.mts",
	num_others = 3,
	yadjust = 1,
})

mcl_villages.register_building({
	name = "farm_large",
	mts = schem_path .. "new_villages/farm_large_1.mts",
	num_others = 6,
	yadjust = 1,
})

for _, crop_type in pairs(mcl_villages.get_crop_types()) do
	for count = 1, 8 do
		local tile = crop_type .. "_" .. count .. ".png"
		minetest.register_node("mcl_villages:crop_" .. crop_type .. "_" .. count, {
			description = S("A place to plant @1 crops", crop_type),
			is_ground_content = false,
			tiles = { tile },
			wield_image = tile,
			wield_scale = { x = 1, y = 1, z = 0.5 },
			groups = { handy = 1, supported_node = 1, deco_block = 1 },
			--sounds = mcl_sounds.node_sound_wool_defaults(),
			paramtype = "light",
			sunlight_propagates = true,
			stack_max = 64,
			drawtype = "nodebox",
			walkable = true,
			node_box = {
				type = "fixed",
				fixed = {
					{ -8 / 16, -8 / 16, -8 / 16, 8 / 16, -7 / 16, 8 / 16 },
				},
			},
			_mcl_hardness = 0.1,
			_mcl_blast_resistance = 0.1,
		})
	end
end

mcl_villages.register_crop({
	type = "grain",
	node = "mcl_farming:wheat_1",
	biomes = {
		acacia = 10,
		bamboo = 10,
		desert = 10,
		jungle = 10,
		plains = 10,
		savanna = 10,
		spruce = 10,
	},
})

mcl_villages.register_crop({
	type = "root",
	node = "mcl_farming:carrot_1",
	biomes = {
		acacia = 10,
		bamboo = 6,
		desert = 10,
		jungle = 6,
		plains = 6,
		spruce = 10,
	},
})

mcl_villages.register_crop({
	type = "root",
	node = "mcl_farming:potato_1",
	biomes = {
		acacia = 6,
		bamboo = 10,
		desert = 6,
		jungle = 10,
		plains = 10,
		spruce = 6,
	},
})

mcl_villages.register_crop({
	type = "root",
	node = "mcl_farming:beetroot_0",
	biomes = {
		acacia = 3,
		bamboo = 3,
		desert = 3,
		jungle = 3,
		plains = 3,
		spruce = 3,
	},
})

mcl_villages.register_crop({
	type = "gourd",
	node = "mcl_farming:melontige_1",
	biomes = {
		bamboo = 10,
		jungle = 10,
	},
})

mcl_villages.register_crop({
	type = "gourd",
	node = "mcl_farming:pumpkin_1",
	biomes = {
		acacia = 10,
		bamboo = 5,
		desert = 10,
		jungle = 5,
		plains = 10,
		spruce = 10,
	},
})

for name, def in pairs(minetest.registered_nodes) do
	if def.groups["flower"] and not def.groups["double_plant"] and name ~= "mcl_flowers:wither_rose" then
		mcl_villages.register_crop({
			type = "flower",
			node = name,
			biomes = {
				acacia = 10,
				bamboo = 6,
				desert = 10,
				jungle = 6,
				plains = 6,
				spruce = 10,
			},
		})
	end
end
