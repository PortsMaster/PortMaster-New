mcl_structures.registered_structures = {}
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

--local place_queue = {}
local disabled_structures = minetest.settings:get("mcl_disabled_structures")
if disabled_structures then	disabled_structures = disabled_structures:split(",")
else disabled_structures = {} end

local peaceful = minetest.settings:get_bool("only_peaceful_mobs", false)
local mob_cap_player = tonumber(minetest.settings:get("mcl_mob_cap_player")) or 75
local mob_cap_animal = tonumber(minetest.settings:get("mcl_mob_cap_animal")) or 10

local logging = minetest.settings:get_bool("mcl_logging_structures",true)

local mg_name = minetest.get_mapgen_setting("mg_name")

local rotations = {
	"0",
	"90",
	"180",
	"270"
}

function mcl_structures.is_disabled(structname)
	return table.indexof(disabled_structures,structname) ~= -1
end

local function ecb_place(blockpos, action, calls_remaining, param)
	if calls_remaining >= 1 then return end
	minetest.place_schematic(param.pos, param.schematic, param.rotation, param.replacements, param.force_placement, param.flags)
	if param.after_placement_callback and param.p1 and param.p2 then
		param.after_placement_callback(param.p1, param.p2, param.size, param.rotation, param.pr, param.callback_param)
	end
end

function mcl_structures.place_schematic(pos, schematic, rotation, replacements, force_placement, flags, after_placement_callback, pr, callback_param)
	if type(schematic) ~= "table" and not mcl_util.file_exists(schematic) then
		minetest.log("warning","[mcl_structures] schematic file "..tostring(schematic).." does not exist.")
		return end
	local s = loadstring(minetest.serialize_schematic(schematic, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic")()
	if s and s.size then
		local x, z = s.size.x, s.size.z
		if rotation then
			if rotation == "random" and pr then
				rotation = rotations[pr:next(1,#rotations)]
			end
			if rotation == "random" then
				x = math.max(x, z)
				z = x
			elseif rotation == "90" or rotation == "270" then
				x, z = z, x
			end
		end
		local p1 = {x=pos.x    , y=pos.y           , z=pos.z    }
		local p2 = {x=pos.x+x-1, y=pos.y+s.size.y-1, z=pos.z+z-1}
		minetest.log("verbose", "[mcl_structures] size=" ..minetest.pos_to_string(s.size) .. ", rotation=" .. tostring(rotation) .. ", emerge from "..minetest.pos_to_string(p1) .. " to " .. minetest.pos_to_string(p2))
		local param = {pos=vector.new(pos), schematic=s, rotation=rotation, replacements=replacements, force_placement=force_placement, flags=flags, p1=p1, p2=p2, after_placement_callback = after_placement_callback, size=vector.new(s.size), pr=pr, callback_param=callback_param}
		minetest.emerge_area(p1, p2, ecb_place, param)
		return true
	end
end

function mcl_structures.get_struct(file)
	local localfile = modpath.."/schematics/"..file
	local file, errorload = io.open(localfile, "rb")
	if errorload then
		minetest.log("error", "[mcl_structures] Could not open this struct: "..localfile)
		return nil
	end

	local allnode = file:read("*a")
	file:close()

	return allnode
end

-- Call on_construct on pos.
-- Useful to init chests from formspec.
local function init_node_construct(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	if def and def.on_construct then
		def.on_construct(pos)
		return true
	end
	return false
end
mcl_structures.init_node_construct = init_node_construct

function mcl_structures.fill_chests(p1,p2,loot,pr)
	for it,lt in pairs(loot) do
		if it ~= "SUS" then --don't try to generate loot for "sus nodes" here, this happens when a player brushes a suspicious node
			local nodes = minetest.find_nodes_in_area(p1, p2, it)
			for _,p in pairs(nodes) do
				local lootitems = mcl_loot.get_multi_loot(lt, pr)
				mcl_structures.init_node_construct(p)
				local meta = minetest.get_meta(p)
				local inv = meta:get_inventory()
				mcl_loot.fill_inventory(inv, "main", lootitems, pr)
			end
		end
	end
end

local function generate_loot(pos, def, pr)
	local hl = def.sidelen
	local p1 = vector.offset(pos,-hl,-hl,-hl)
	local p2 = vector.offset(pos,hl,hl,hl)
	if def.loot then mcl_structures.fill_chests(p1,p2,def.loot,pr) end
end

function mcl_structures.construct_nodes(p1,p2,nodes)
	local nn=minetest.find_nodes_in_area(p1,p2,nodes)
	for _,p in pairs(nn) do
		mcl_structures.init_node_construct(p)
	end
end

local function construct_nodes(pos,def,pr)
	return mcl_structures.construct_nodes(vector.offset(pos,-def.sidelen/2,0,-def.sidelen/2),vector.offset(pos,def.sidelen/2,def.sidelen,def.sidelen/2),def.construct_nodes)
end


function mcl_structures.find_lowest_y(pp)
	local y = 31000
	for _,p in pairs(pp) do
		if p.y < y then y = p.y end
	end
	return y
end

function mcl_structures.find_highest_y(pp)
	local y = -31000
	for _,p in pairs(pp) do
		if p.y > y then y = p.y end
	end
	return y
end
--[[

local function smooth_cube(nn,pos,plane,amnt)
	local r = {}
	local amnt = amnt or 9
	table.sort(nn,function(a, b)
		if false or plane then
			return vector.distance(vector.new(pos.x,0,pos.z), vector.new(a.x,0,a.z)) < vector.distance(vector.new(pos.x,0,pos.z), vector.new(b.x,0,b.z))
		else
			return vector.distance(pos, a) < vector.distance(pos, b)
		end
	end)
	for i=1,math.max(1,#nn-amnt) do table.insert(r,nn[i]) end
	return r
end

local function find_ground(pos,nn,gn)
	local r = 0
	for _,v in pairs(nn) do
		local p=vector.new(v)
		repeat
			local n = minetest.get_node(p).name
			p = vector.offset(p,0,-1,0)
		until not n or n == "mcl_core:bedrock" or n == "ignore" or n == gn
	--minetest.log(tostring(pos.y - p.y))
		if pos.y - p.y > r then r = pos.y - p.y end
	end
	return r
end

local function get_foundation_nodes(ground_p1,ground_p2,pos,sidelen,node_stone)
	local replace = {"air","group:liquid","mcl_core:snow","group:tree","group:leaves","group:plant","grass_block","group:dirt"}
	local depth = find_ground(pos,minetest.find_nodes_in_area(ground_p1,ground_p2,replace),node_stone)
	local nn = smooth_cube(minetest.find_nodes_in_area(vector.offset(ground_p1,0,-1,0),vector.offset(ground_p2,0,-depth,0),replace),vector.offset(pos,0,-depth,0),true,sidelen * 64)
	local stone = {}
	local filler = {}
	local top = {}
	local dust = {}
	for l,v in pairs(nn) do
		if v.y == ground_p1.y - 1 then
			table.insert(filler,v)
			table.insert(top,vector.offset(v,0,1,0))
			table.insert(dust,vector.offset(v,0,2,0))
		elseif v.y < ground_p1.y -1 and v.y > ground_p2.y -4 then table.insert(filler,v)
		elseif v.y < ground_p2.y - 3 and v.y > ground_p2.y -5 then
			if math.random(3) == 1 then
				table.insert(filler,v)
			else
				table.insert(stone,v)
			end
		else
			table.insert(stone,v)
		end
	end
	return stone,filler,top,dust
end

local function foundation(ground_p1,ground_p2,pos,sidelen)
	local node_stone = "mcl_core:stone"
	local node_filler = "mcl_core:dirt"
	local node_top = "mcl_core:dirt_with_grass" or minetest.get_node(ground_p1).name
	local node_dust = nil

	local b = minetest.registered_biomes[minetest.get_biome_name(minetest.get_biome_data(pos).biome)]
	--minetest.log(dump(b.node_top))
	if b then
		if b.node_top then node_top = b.node_top end
		if b.node_filler then node_filler = b.node_filler end
		if b.node_stone then node_stone = b.node_stone end
		if b.node_dust then node_dust = b.node_dust end
	end

	local stone,filler,top,dust = get_foundation_nodes(ground_p1,ground_p2,pos,sidelen,node_stone)
	minetest.bulk_set_node(top,{name=node_top},node_stone)

	if node_dust then
		minetest.bulk_set_node(dust,{name=node_dust})
	end
	minetest.bulk_set_node(filler,{name=node_filler})
	minetest.bulk_set_node(stone,{name=node_stone})
end
]]

--[[
local function process_queue()
	if #place_queue < 1 then return end
	local s = table.remove(place_queue)
	mcl_structures.place_schematic(s.pos, s.file, s.rot, nil, true, "place_center_x,place_center_z",function(s)
		if s.after_place then
			s.after_place(s.pos,s.def,s.pr)
		end
	end,s.pr)
	minetest.after(0.5,process_queue)
end
--]]

function mcl_structures.spawn_mobs(mob,spawnon,p1,p2,pr,n,water)
	n = n or 1
	local sp = {}
	if water then
		local nn = minetest.find_nodes_in_area(p1,p2,spawnon)
		for k,v in pairs(nn) do
			if minetest.get_item_group(minetest.get_node(vector.offset(v,0,1,0)).name,"water") > 0 then
				table.insert(sp,v)
			end
		end
	else
		sp = minetest.find_nodes_in_area_under_air(p1,p2,spawnon)
	end
	table.shuffle(sp)
	for i,node in pairs(sp) do
		if not peaceful and i <= n then
			local pos = vector.offset(node,0,1,0)
			if pos then
				minetest.add_entity(pos,mob)
			end
		end
		minetest.get_meta(node):set_string("spawnblock","yes")
	end
end

function mcl_structures.place_structure(pos, def, pr, blockseed, rot)
	if not def then	return end
	local log_enabled = logging and not def.terrain_feature
	local y_offset = 0
	if type(def.y_offset) == "function" then
		y_offset = def.y_offset(pr)
	elseif def.y_offset then
		y_offset = def.y_offset
	end
	local pp = vector.offset(pos,0,y_offset,0)
	if def.solid_ground and def.sidelen then
		local ground_p1 = vector.offset(pos,-def.sidelen/2,-1,-def.sidelen/2)
		local ground_p2 = vector.offset(pos,def.sidelen/2,-1,def.sidelen/2)

		local solid = minetest.find_nodes_in_area(ground_p1,ground_p2,{"group:solid"})
		if #solid < ( def.sidelen * def.sidelen ) then
			if def.make_foundation then
				mcl_util.create_ground_turnip(vector.offset(pos, 0, -1, 0), def.sidelen, def.sidelen)
			else
				if log_enabled then
					minetest.log("warning","[mcl_structures] "..def.name.." at "..minetest.pos_to_string(pp).." not placed. No solid ground.")
				end
				return false
			end
		end
	end
	if def.on_place and not def.on_place(pos,def,pr,blockseed) then
		if log_enabled then
			minetest.log("warning","[mcl_structures] "..def.name.." at "..minetest.pos_to_string(pp).." not placed. Conditions not satisfied.")
		end
		return false
	end
	if def.filenames then
		if #def.filenames <= 0 then return false end
		local r = pr:next(1,#def.filenames)
		local file = def.filenames[r]
		if file then
			local rot = rotations[pr:next(1,#rotations)]
			local ap = function(pos,def,pr,blockseed) end

			if def.daughters then
				ap = function(pos,def,pr,blockseed)
					for _,d in pairs(def.daughters) do
						local p = vector.add(pos,d.pos)
						local rot = d.rot or 0
						mcl_structures.place_schematic(p, d.files[pr:next(1,#d.files)], rot, nil, true, "place_center_x,place_center_z",function()
							if def.loot then generate_loot(pp,def,pr,blockseed) end
							if def.construct_nodes then construct_nodes(pp,def,pr,blockseed) end
							if def.after_place then
								def.after_place(pos,def,pr)
							end
						end,pr)
					end
				end
			elseif def.after_place then
				ap = def.after_place
			end
			mcl_structures.place_schematic(pp, file, rot,  def.replacements, true, "place_center_x,place_center_z",function(p1, p2, size, rotation)
				if not def.daughters then
					if def.loot then generate_loot(pp,def,pr,blockseed) end
					if def.construct_nodes then construct_nodes(pp,def,pr,blockseed) end
				end
				return ap(pp,def,pr,blockseed,p1,p2,size,rotation)
			end,pr)
			if log_enabled then
				minetest.log("action","[mcl_structures] "..def.name.." placed at "..minetest.pos_to_string(pp))
			end
			return true
		end
	elseif def.place_func and def.place_func(pp,def,pr,blockseed) then
		if not def.after_place or ( def.after_place  and def.after_place(pp,def,pr,blockseed) ) then
			if def.loot then generate_loot(pp,def,pr,blockseed) end
			if def.construct_nodes then construct_nodes(pp,def,pr,blockseed) end
			if log_enabled then
				minetest.log("action","[mcl_structures] "..def.name.." placed at "..minetest.pos_to_string(pp))
			end
			return true
		end
	end
	if log_enabled then
		minetest.log("warning","[mcl_structures] placing "..def.name.." failed at "..minetest.pos_to_string(pos))
	end
end

function mcl_structures.register_structure(name,def,nospawn) --nospawn means it will be placed by another (non-nospawn) structure that contains it's structblock i.e. it will not be placed by mapgen directly
	if mcl_structures.is_disabled(name) then return end
	local structblock = "mcl_structures:structblock_"..name
	local flags = "place_center_x, place_center_z, force_placement"
	local sbgroups = { structblock = 1, not_in_creative_inventory=1 }
	if def.flags then flags = def.flags end
	def.name = name
	if nospawn then
		sbgroups.structblock = nil
		sbgroups.structblock_lbm = 1
	else
		if def.place_on then
			minetest.register_on_mods_loaded(function() --make sure all previous decorations and biomes have been registered
				def.deco = minetest.register_decoration({
					name = "mcl_structures:deco_"..name,
					decoration = structblock,
					deco_type = "simple",
					place_on = def.place_on,
					spawn_by = def.spawn_by,
					num_spawn_by = def.num_spawn_by,
					sidelen = 80,
					fill_ratio = def.fill_ratio,
					noise_params = def.noise_params,
					flags = flags,
					biomes = def.biomes,
					y_max = def.y_max,
					y_min = def.y_min
				})
				minetest.register_node(":"..structblock, {drawtype="airlike", walkable = false, pointable = false,groups = sbgroups,sunlight_propagates = true,})
				def.structblock = structblock
				def.deco_id = minetest.get_decoration_id("mcl_structures:deco_"..name)
				minetest.set_gen_notify({decoration=true}, { def.deco_id })
				--catching of gennotify happens in mcl_mapgen_core

			end)
		end
	end
	mcl_structures.registered_structures[name] = def
end

function mcl_structures.register_structure_spawn(def)
	--name,y_min,y_max,spawnon,biomes,chance,interval,limit
	minetest.register_abm({
		label = "Spawn "..def.name,
		nodenames = def.spawnon,
		min_y = def.y_min or -31000,
		max_y = def.y_max or 31000,
		interval = def.interval or 60,
		chance = def.chance or 5,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local limit = def.limit or 7
			if active_object_count_wider > limit + mob_cap_animal then return end
			if active_object_count_wider > mob_cap_player then return end
			local p = vector.offset(pos,0,1,0)
			if minetest.get_node(p).name ~= "air" then return end
			if minetest.get_meta(pos):get_string("spawnblock") == "" then return end
			if mg_name ~= "singlenode" and def.biomes then
				if table.indexof(def.biomes,minetest.get_biome_name(minetest.get_biome_data(p).biome)) == -1 then
					return
				end
			end
			local mobdef = minetest.registered_entities[def.name]
			if mobdef.can_spawn and not mobdef.can_spawn(p) then return end
			minetest.add_entity(p,def.name)
		end,
	})
end

--lbm for secondary structures (structblock included in base structure)
minetest.register_lbm({
	name = "mcl_structures:struct_lbm",
	run_at_every_load = true,
	nodenames = {"group:structblock_lbm"},
	action = function(pos, node)
		minetest.remove_node(pos)
		local name = node.name:gsub("mcl_structures:structblock_","")
		local def = mcl_structures.registered_structures[name]
		if not def then return end
		mcl_structures.place_structure(pos)
	end
})
