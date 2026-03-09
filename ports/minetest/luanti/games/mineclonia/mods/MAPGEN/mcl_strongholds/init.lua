if mcl_levelgen.enable_ersatz then
	return
end

-- Generate strongholds.

local generate_in_singlenode = false
-- A total of 128 strongholds are generated in rings around the world origin.
-- This is the list of rings, starting with the innermost ring first.
local stronghold_rings = {
	-- amount: Number of strongholds in ring.
	-- min, max: Minimum and maximum distance from (X=0, Z=0).
	{ amount = 3, min = 1408, max = 2688 },
	{ amount = 6, min = 4480, max = 5760 },
	{ amount = 10, min = 7552, max = 8832 },
	{ amount = 15, min = 10624, max = 11904 },
	{ amount = 21, min = 13696, max = 14976 },
	{ amount = 28, min = 16768, max = 18048 },
	{ amount = 36, min = 19840, max = 21120 },
	{ amount = 9, min = 22912, max = 24192 },
}

local mg_name = core.get_mapgen_setting("mg_name")
local seed = tonumber(core.get_mapgen_setting("seed"))

local function init_strongholds()
	local stronghold_positions = {}
	-- Don't generate strongholds in singlenode
	if (mg_name == "singlenode" and not generate_in_singlenode) then
		return {}
	end
	local pr = PseudoRandom(seed) -- Use PseudoRandom for backwards compatibility
	for s=1, #stronghold_rings do
		local ring = stronghold_rings[s]

		-- Get random angle
		local angle = pr:next(0, 32767)
		-- Scale angle to 0 .. 2*math.pi
		angle = (angle / 32767) * (math.pi*2)
		for _ = 1, ring.amount do
			local dist = pr:next(ring.min, ring.max)
			local y
			if mcl_vars.superflat then
				y = mcl_vars.mg_bedrock_overworld_max + 3
			else
				y = pr:next(mcl_vars.mg_bedrock_overworld_max+1, mcl_vars.mg_overworld_min+48)
			end
			local pos = { x = math.cos(angle) * dist, y = y, z = math.sin(angle) * dist }
			pos = vector.round(pos)
			table.insert(stronghold_positions, pos)

			-- Rotate angle by (360 / amount) degrees.
			-- This will cause the angles to be evenly distributed in the stronghold ring
			angle = math.fmod(angle + ((math.pi*2) / ring.amount), math.pi*2)
		end
	end
	return stronghold_positions
end

mcl_structures.register_structure("end_shrine",{
	static_pos = init_strongholds(),
	sidelen = 32,
	filenames = {
		core.get_modpath("mcl_structures").."/schematics/mcl_structures_end_portal_room_simple.mts"
	},
	loot = {
		["mcl_chests:chest_small" ] ={{
			stacks_min = 2,
			stacks_max = 3,
			items = {
				{ itemstring = "mcl_core:apple", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_farming:bread", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_core:iron_ingot", weight = 10, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_throwing:ender_pearl", weight = 10, amount_min = 1, amount_max = 1 },
				{ itemstring = "mesecons:wire_00000000_off", weight = 5, amount_min = 4, amount_max = 9 },
				{ itemstring = "mcl_core:gold_ingot", weight = 5, amount_min = 1, amount_max = 3 },

				{ itemstring = "mcl_tools:pick_iron", weight = 5, amount_min = 1, amount_max=3 },
				{ itemstring = "mcl_tools:sword_iron", weight = 5, amount_min = 1, amount_max=3 },

				{ itemstring = "mcl_armor:helmet_iron", weight = 5, amount_min = 1, amount_max=3 },
				{ itemstring = "mcl_armor:chestplate_iron", weight = 5, amount_min = 1, amount_max=3 },
				{ itemstring = "mcl_armor:leggings_iron", weight = 5, amount_min = 1, amount_max=3 },
				{ itemstring = "mcl_armor:boots_iron", weight = 5, amount_min = 1, amount_max=3 },

				{ itemstring = "mcl_core:diamond", weight = 3, amount_min = 1, amount_max = 3 },

				{ itemstring = "mcl_jukebox:record_7", weight = 1, },
				{ itemstring = "mcl_books:book", weight = 1, func = function(stack, pr)
					mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "mcl_mobitems:leather", weight = 1, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_mobitems:saddle", weight = 1, },
				{ itemstring = "mcl_mobitems:copper_horse_armor", weight = 1, },
				{ itemstring = "mcl_mobitems:iron_horse_armor", weight = 1, },
				{ itemstring = "mcl_mobitems:gold_horse_armor", weight = 1, },
				{ itemstring = "mcl_mobitems:diamond_horse_armor", weight = 1, },
				{ itemstring = "mcl_core:apple_gold", weight = 1, },
			}
		},
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "mcl_armor:eye", weight = 1, amount_min = 1, amount_max = 1 },
			}
		}}
	},
	after_place = function(pos, def, pr)
		local p1 = vector.subtract(pos, (def.sidelen or 12) /2 )
		local p2 = vector.add(pos, (def.sidelen or 12) / 2)
		local spawners = core.find_nodes_in_area(p1, p2, "mcl_mobspawners:spawner")
		for s=1, #spawners do
			--local meta = core.get_meta(spawners[s])
			mcl_mobspawners.setup_spawner(spawners[s], "mobs_mc:silverfish")
		end

		-- Shuffle stone brick types
		local bricks = core.find_nodes_in_area(p1, p2, "mcl_core:stonebrick")
		for b=1, #bricks do
			local r_bricktype = pr:next(1, 100)
			local r_infested = pr:next(1, 100)
			local bricktype
			if r_infested <= 5 then
				if r_bricktype <= 30 then -- 30%
					bricktype = "mcl_monster_eggs:monster_egg_stonebrickmossy"
				elseif r_bricktype <= 50 then -- 20%
					bricktype = "mcl_monster_eggs:monster_egg_stonebrickcracked"
				else -- 50%
					bricktype = "mcl_monster_eggs:monster_egg_stonebrick"
				end
			else
				if r_bricktype <= 30 then -- 30%
					bricktype = "mcl_core:stonebrickmossy"
				elseif r_bricktype <= 50 then -- 20%
					bricktype = "mcl_core:stonebrickcracked"
				end
				-- 50% stonebrick (no change necessary)
			end
			if bricktype then
				core.swap_node(bricks[b], { name = bricktype })
			end
		end

		-- Also replace stairs
		local stairs = core.find_nodes_in_area(p1, p2, {"mcl_stairs:stair_stonebrick", "mcl_stairs:stair_stonebrick_outer", "mcl_stairs:stair_stonebrick_inner"})
		for s=1, #stairs do
			local stair = core.get_node(stairs[s])
			local r_type = pr:next(1, 100)
			if r_type <= 30 then -- 30% mossy
				if stair.name == "mcl_stairs:stair_stonebrick" then
					stair.name = "mcl_stairs:stair_stonebrickmossy"
				elseif stair.name == "mcl_stairs:stair_stonebrick_outer" then
					stair.name = "mcl_stairs:stair_stonebrickmossy_outer"
				elseif stair.name == "mcl_stairs:stair_stonebrick_inner" then
					stair.name = "mcl_stairs:stair_stonebrickmossy_inner"
				end
				core.swap_node(stairs[s], stair)
			elseif r_type <= 50 then -- 20% cracky
				if stair.name == "mcl_stairs:stair_stonebrick" then
					stair.name = "mcl_stairs:stair_stonebrickcracked"
				elseif stair.name == "mcl_stairs:stair_stonebrick_outer" then
					stair.name = "mcl_stairs:stair_stonebrickcracked_outer"
				elseif stair.name == "mcl_stairs:stair_stonebrick_inner" then
					stair.name = "mcl_stairs:stair_stonebrickcracked_inner"
				end
				core.swap_node(stairs[s], stair)
			end
			-- 50% no change
		end

		-- Randomly add ender eyes into end portal frames, but never fill the entire frame
		local frames = core.find_nodes_in_area(p1, p2, "mcl_portals:end_portal_frame")
		local eyes = 0
		for f=1, #frames do
			local r_eye = pr:next(1, 10)
			if r_eye == 1 then
				eyes = eyes + 1
				if eyes < #frames then
					local frame_node = core.get_node(frames[f])
					frame_node.name = "mcl_portals:end_portal_frame_eye"
					core.swap_node(frames[f], frame_node)
				end
			end
		end
	end,
})
