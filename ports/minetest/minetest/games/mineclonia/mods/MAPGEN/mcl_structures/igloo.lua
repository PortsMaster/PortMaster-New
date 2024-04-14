local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

function mcl_structures.generate_igloo_top(pos, pr)
	-- Furnace does ot work atm because apparently meta is not set. Need a bit of help with fixing this for furnaces, bookshelves, and brewing stands.
	local newpos = {x=pos.x,y=pos.y-2,z=pos.z}
	local path = modpath.."/schematics/mcl_structures_igloo_top.mts"
	local rotation = tostring(pr:next(0,3)*90)
	return mcl_structures.place_schematic(newpos, path, rotation, nil, true, nil, function()
		local p1 = vector.offset(pos,-5,-5,-5)
		local p2 = vector.offset(pos,5,5,5)
		mcl_structures.construct_nodes(p1,p2,{"mcl_furnaces:furnace","mcl_books:bookshelf"})
	end), rotation
end

local function spawn_mobs(p1,p2,vi,zv)
	local mc = minetest.find_nodes_in_area_under_air(p1,p2,{"mcl_core:stonebrickmossy"})
	if #mc == 2 then
		local vp = mc[1]
		local zp = mc[2]
		if not vi and zv and zv:get_pos() and vector.distance(mc[1],zv:get_pos()) < 2 then
			vp = mc[2]
		elseif not zv and vi and vi:get_pos() and vector.distance(mc[2],vi:get_pos()) < 2 then
			zp = mc[1]
		elseif zv and vi then
			return
		end
		vi = minetest.add_entity(vector.offset(vp,0,1,0),"mobs_mc:villager")
		zv = minetest.add_entity(vector.offset(zp,0,1,0),"mobs_mc:villager_zombie")
		if vi and vi:get_pos() and zv and zv:get_pos() then
			minetest.after(1,spawn_mobs,p1,p2,vi,zv)
		end
	end
end

function mcl_structures.generate_igloo_basement(pos, orientation, loot, pr)
	-- TODO: Add monster eggs
	local path = modpath.."/schematics/mcl_structures_igloo_basement.mts"
	mcl_structures.place_schematic(pos, path, orientation, nil, true, nil, function()
		local p1 = vector.offset(pos,-5,-5,-5)
		local p2 = vector.offset(pos,5,5,5)
		mcl_structures.fill_chests(p1,p2,loot,pr)
		mcl_structures.construct_nodes(p1,p2,{"mcl_brewing:stand_000","mcl_books:bookshelf"})
		spawn_mobs(p1,p2)
	end, pr)
end

function mcl_structures.generate_igloo(pos, def, pr)
	-- Place igloo
	local success, rotation = mcl_structures.generate_igloo_top(pos, pr)
	-- Place igloo basement with 50% chance
	local r = pr:next(1,2)
	if r == 1 then
		-- Select basement depth
		local dim = mcl_worlds.pos_to_dimension(pos)
		--local buffer = pos.y - (mcl_vars.mg_lava_overworld_max + 10)
		local buffer
		if dim == "nether" then
			buffer = pos.y - (mcl_vars.mg_lava_nether_max + 10)
		elseif dim == "end" then
			buffer = pos.y - (mcl_vars.mg_end_min + 1)
		elseif dim == "overworld" then
			buffer = pos.y - (mcl_vars.mg_lava_overworld_max + 10)
		else
			return success
		end
		if buffer <= 19 then
			return success
		end
		local depth = pr:next(19, buffer)
		local bpos = {x=pos.x, y=pos.y-depth, z=pos.z}
		-- trapdoor position
		local tpos
		local dir, tdir
		if rotation == "0" then
			dir = {x=-1, y=0, z=0}
			tdir = {x=1, y=0, z=0}
			tpos = {x=pos.x+7, y=pos.y-2, z=pos.z+3}
		elseif rotation == "90" then
			dir = {x=0, y=0, z=-1}
			tdir = {x=0, y=0, z=-1}
			tpos = {x=pos.x+3, y=pos.y-2, z=pos.z+1}
		elseif rotation == "180" then
			dir = {x=1, y=0, z=0}
			tdir = {x=-1, y=0, z=0}
			tpos = {x=pos.x+1, y=pos.y-2, z=pos.z+3}
		elseif rotation == "270" then
			dir = {x=0, y=0, z=1}
			tdir = {x=0, y=0, z=1}
			tpos = {x=pos.x+3, y=pos.y-2, z=pos.z+7}
		else
			return success
		end
		local function set_brick(pos)
			local c = pr:next(1, 3) -- cracked chance
			local m = pr:next(1, 10) -- chance for monster egg
			local brick
			if m == 1 then
				if c == 1 then
					brick = "mcl_monster_eggs:monster_egg_stonebrickcracked"
				else
					brick = "mcl_monster_eggs:monster_egg_stonebrick"
				end
			else
				if c == 1 then
					brick = "mcl_core:stonebrickcracked"
				else
					brick = "mcl_core:stonebrick"
				end
			end
			minetest.set_node(pos, {name=brick})
		end
		local ladder_param2 = minetest.dir_to_wallmounted(tdir)
		local real_depth = 0
		-- Check how deep we can actuall dig
		for y=1, depth-5 do
			real_depth = real_depth + 1
			local node = minetest.get_node({x=tpos.x,y=tpos.y-y,z=tpos.z})
			local def = minetest.registered_nodes[node.name]
			if not (def and def.walkable and def.liquidtype == "none" and def.is_ground_content) then
				bpos.y = tpos.y-y+1
				break
			end
		end
		if real_depth <= 6 then
			return success
		end
		-- Generate ladder to basement
		for y=1, real_depth-1 do
			set_brick({x=tpos.x-1,y=tpos.y-y,z=tpos.z  })
			set_brick({x=tpos.x+1,y=tpos.y-y,z=tpos.z  })
			set_brick({x=tpos.x  ,y=tpos.y-y,z=tpos.z-1})
			set_brick({x=tpos.x  ,y=tpos.y-y,z=tpos.z+1})
			minetest.set_node({x=tpos.x,y=tpos.y-y,z=tpos.z}, {name="mcl_core:ladder", param2=ladder_param2})
		end
		-- Place basement
		mcl_structures.generate_igloo_basement(bpos, rotation, def.loot, pr)
		-- Place hidden trapdoor
		minetest.after(5, function(tpos, dir)
			minetest.set_node(tpos, {name="mcl_doors:trapdoor", param2=20+minetest.dir_to_facedir(dir)}) -- TODO: more reliable param2
		end, tpos, dir)
	end
	return success
end

mcl_structures.register_structure("igloo",{
	place_on = {"mcl_core:snowblock","mcl_core:snow","group:grass_block_snow"},
	fill_ratio = 0.01,
	sidelen = 16,
	chunk_probability = 250,
	solid_ground = true,
	make_foundation = true,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 0,
	y_offset = 0,
	biomes = { 	"ColdTaiga", "IcePlainsSpikes",	"IcePlains" },
	place_func = mcl_structures.generate_igloo,
	loot = {
		["mcl_chests:chest_small"] = {{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "mcl_core:apple_gold", weight = 1 },
			}
		},
		{
			stacks_min = 2,
			stacks_max = 8,
			items = {
				{ itemstring = "mcl_core:coal_lump", weight = 15, amount_min = 1, amount_max = 4 },
				{ itemstring = "mcl_core:apple", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_farming:wheat_item", weight = 10, amount_min = 2, amount_max = 3 },
				{ itemstring = "mcl_core:gold_nugget", weight = 10, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 10 },
				{ itemstring = "mcl_tools:axe_stone", weight = 2 },
				{ itemstring = "mcl_core:emerald", weight = 1 },
				{ itemstring = "mcl_core:apple_gold", weight = 1 },
			}
		}},
	}
})
