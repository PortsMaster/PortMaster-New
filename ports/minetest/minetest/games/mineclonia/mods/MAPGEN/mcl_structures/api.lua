mcl_structures.registered_structures = {}
local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

local disabled_structures = core.settings:get("mcl_disabled_structures")
if disabled_structures then	disabled_structures = disabled_structures:split(",")
else disabled_structures = {} end

local peaceful = core.settings:get_bool("only_peaceful_mobs", false)
local mob_cap_player = tonumber(core.settings:get("mcl_mob_cap_player")) or 75
local mob_cap_animal = tonumber(core.settings:get("mcl_mob_cap_animal")) or 10
local mobs_spawn = core.settings:get_bool("mobs_spawn", true) ~= false

local logging = core.settings:get_bool("mcl_logging_structures",true)
mcl_structures.DBG = false

local rotations = {
	"0",
	"90",
	"180",
	"270"
}

local EMPTY_SCHEMATIC = { size = {x = 0, y = 0, z = 0}, data = { } }

function mcl_structures.is_disabled(structname)
	return table.indexof(disabled_structures,structname) ~= -1
end

local function ecb_place(blockpos, action, calls_remaining, param) ---@diagnostic disable-line: unused-local
	if calls_remaining >= 1 then return end
	core.place_schematic(param.pos, param.schematic, param.rotation, param.replacements, param.force_placement, param.flags)
	if param.after_placement_callback and param.p1 and param.p2 then
		param.after_placement_callback(param.p1, param.p2, param.size, param.rotation, param.pr, param.callback_param)
	end
end

function mcl_structures.place_schematic(pos, schematic, rotation, replacements, force_placement, flags, after_placement_callback, pr, callback_param)
	if type(schematic) ~= "table" and not mcl_util.file_exists(schematic) then
		core.log("warning","[mcl_structures] schematic file "..tostring(schematic).." does not exist.")
		return end
	local s = loadstring(core.serialize_schematic(schematic, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic")()
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
		core.log("verbose", "[mcl_structures] size=" ..core.pos_to_string(s.size) .. ", rotation=" .. tostring(rotation) .. ", emerge from "..core.pos_to_string(p1) .. " to " .. core.pos_to_string(p2))
		local param = {pos=vector.new(pos), schematic=s, rotation=rotation, replacements=replacements, force_placement=force_placement, flags=flags, p1=p1, p2=p2, after_placement_callback = after_placement_callback, size=vector.new(s.size), pr=pr, callback_param=callback_param}
		core.emerge_area(p1, p2, ecb_place, param)
		return true
	end
end

function mcl_structures.get_struct(file)
	local localfile = modpath.."/schematics/"..file
	local file, errorload = io.open(localfile, "rb")
	if errorload then
		core.log("error", "[mcl_structures] Could not open this struct: "..localfile)
		return nil
	end
	if file then
		local allnode = file:read("*a")
		file:close()
		return allnode
	end
end

local is_structure_constructor = false

function mcl_structures.is_structure_constructor ()
	return is_structure_constructor
end

-- Call on_construct on pos.
-- Useful to init chests from formspec.
local function init_node_construct(pos)
	local node = core.get_node(pos)
	local def = core.registered_nodes[node.name]
	if def and def.on_construct then
		is_structure_constructor = true
		def.on_construct(pos)
		is_structure_constructor = false
		return true
	end
	return false
end
mcl_structures.init_node_construct = init_node_construct

function mcl_structures.fill_chests(p1,p2,loot,pr)
	for it,lt in pairs(loot) do
		if it ~= "SUS" then --don't try to generate loot for "sus nodes" here, this happens when a player brushes a suspicious node
			local nodes = core.find_nodes_in_area(p1, p2, it)
			for _,p in pairs(nodes) do
				local lootitems = mcl_loot.get_multi_loot(lt, pr)
				mcl_structures.init_node_construct(p)
				local meta = core.get_meta(p)
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
	local nn=core.find_nodes_in_area(p1,p2,nodes)
	for _,p in pairs(nn) do
		mcl_structures.init_node_construct(p)
	end
	return nn
end

local function construct_nodes(pos, def)
	return mcl_structures.construct_nodes(vector.offset(pos,-def.sidelen/2,0,-def.sidelen/2),vector.offset(pos,def.sidelen/2,def.sidelen,def.sidelen/2),def.construct_nodes)
end


function mcl_structures.find_lowest_y(pp)
	local y = mcl_vars.mapgen_limit
	for _,p in pairs(pp) do
		if p.y < y then y = p.y end
	end
	return y
end

function mcl_structures.find_highest_y(pp)
	local y = -mcl_vars.mapgen_limit
	for _,p in pairs(pp) do
		if p.y > y then y = p.y end
	end
	return y
end

function mcl_structures.spawn_mobs(mob, spawnon, p1 ,p2 ,_ ,n , water)
	n = n or 1
	local sp = {}
	if water then
		local nn = core.find_nodes_in_area(p1,p2,spawnon)
		for _, v in pairs(nn) do
			if core.get_item_group(core.get_node(vector.offset(v,0,1,0)).name,"water") > 0 then
				table.insert(sp,v)
			end
		end
	else
		sp = core.find_nodes_in_area_under_air(p1,p2,spawnon)
	end
	table.shuffle(sp)
	for i,node in pairs(sp) do
		if not peaceful and i <= n then
			local pos = vector.offset(node,0,1,0)
			if pos then
				local sdata = core.serialize ({_structure_generation_spawn = true,})
				local obj = core.add_entity(vector.offset(pos,0,-0.5,0),mob, sdata)
				if obj then
					local entity = obj:get_luaentity ()
					entity.persistent = true
				end
			end
		end
		core.get_meta(node):set_string("spawnblock","yes")
	end
end

function mcl_structures.place_structure(pos, def, pr, blockseed, _)
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

		local solid = core.find_nodes_in_area(ground_p1,ground_p2,{"group:solid"})
		if #solid < ( def.sidelen * def.sidelen ) then
			if def.make_foundation then
				mcl_util.create_ground_turnip(vector.offset(pos, 0, -1, 0), def.sidelen, def.sidelen)
			else
				if log_enabled then
					core.log("warning","[mcl_structures] "..def.name.." at "..core.pos_to_string(pp).." not placed. No solid ground.")
				end
				return false
			end
		end
	end
	if def.on_place and not def.on_place(pos,def,pr,blockseed) then
		if log_enabled then
			core.log("warning","[mcl_structures] "..def.name.." at "..core.pos_to_string(pp).." not placed. Conditions not satisfied.")
		end
		return false
	end
	if def.filenames then
		if #def.filenames <= 0 then return false end
		local r = pr:next(1,#def.filenames)
		local file = def.filenames[r]
		if file then
			local rot = rotations[pr:next(1,#rotations)]
			local ap = function(pos,def,pr,blockseed) end ---@diagnostic disable-line: unused-local

			if def.daughters then
				ap = function(pos,def,pr,blockseed) ---@diagnostic disable-line: unused-local
					for _,d in pairs(def.daughters) do
						local p = vector.add(pos,d.pos)
						local rot = d.rot or 0
						mcl_structures.place_schematic(p, d.files[pr:next(1,#d.files)], rot, nil, true, "place_center_x,place_center_z",function()
							if def.loot then generate_loot(pp,def,pr) end
							if def.construct_nodes then construct_nodes(pp,def) end
							if def.after_place then
								def.after_place(pos,def,pr)
							end
						end,pr)
					end
				end
			elseif def.after_place then
				ap = def.after_place
			end
			mcl_structures.place_schematic(pp, file, rot,  def.replacements, true, "place_center_x,place_center_z",function(p1, p2, size, rotation) ---@diagnostic disable-line: unused-local
				if not def.daughters then
					if def.loot then generate_loot(pp,def,pr) end
					if def.construct_nodes then construct_nodes(pp,def) end
				end
				return ap(pp, def, pr, blockseed)
			end,pr)
			if log_enabled then
				core.log("info","[mcl_structures] "..def.name.." placed at "..core.pos_to_string(pp))
			end
			return true
		end
	elseif def.place_func and def.place_func(pp,def,pr,blockseed) then
		if not def.after_place or ( def.after_place  and def.after_place(pp,def,pr,blockseed) ) then
			if def.loot then generate_loot(pp,def,pr) end
			if def.construct_nodes then construct_nodes(pp, def) end
			if log_enabled then
				core.log("info","[mcl_structures] "..def.name.." placed at "..core.pos_to_string(pp))
			end
			return true
		end
	end
	if log_enabled then
		core.log("warning","[mcl_structures] placing "..def.name.." failed at "..core.pos_to_string(pos))
	end
end

function mcl_structures.register_structure(name,def,nospawn) --nospawn means it will be placed by another (non-nospawn) structure that contains it's structblock i.e. it will not be placed by mapgen directly
	if mcl_structures.is_disabled(name) then return end
	local flags = "place_center_x, place_center_z, force_placement"
	if def.flags then flags = def.flags end
	def.name = name
	if not def.noise_params and def.chunk_probability then
		def.fill_ratio = def.fill_ratio or 1.1/80/80 -- aim for 1 per chunk, control via chunk probability
	end
	if not nospawn and def.place_on then
		core.register_on_mods_loaded(function() --make sure all previous decorations and biomes have been registered
			def.deco = core.register_decoration({
				name = "mcl_structures:deco_"..name,
				deco_type = "schematic",
				schematic = EMPTY_SCHEMATIC,
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
			def.deco_id = core.get_decoration_id("mcl_structures:deco_"..name)
			core.set_gen_notify({decoration=true}, { def.deco_id })
			--catching of gennotify happens in mcl_mapgen_core
		end)
	end
	mcl_structures.registered_structures[name] = def
end

function mcl_structures.register_structure_spawn(def)
	--name,y_min,y_max,spawnon,biomes,chance,interval,limit,underwater
	core.register_abm({
		label = "Spawn "..def.name,
		nodenames = def.spawnon,
		min_y = def.y_min or -mcl_vars.mapgen_limit,
		max_y = def.y_max or mcl_vars.mapgen_limit,
		interval = def.interval or 60,
		chance = def.chance or 5,
		action = function(pos, _, _, active_object_count_wider)
			local limit = def.limit or 7
			if active_object_count_wider > limit + mob_cap_animal then return end
			if active_object_count_wider > mob_cap_player then return end
			if not mobs_spawn then
				return
			end
			local p = vector.offset(pos,0,1,0)
			if not def.underwater and core.get_node(p).name ~= "air" then return end
			if core.get_meta(pos):get_string("spawnblock") == "" then return end
			if def.biomes then
				if table.indexof(def.biomes,core.get_biome_name(core.get_biome_data(p).biome)) == -1 then
					return
				end
			end
			mcl_mobs.spawn_abnormally (p, def.name, {
				_structure_spawn = 1,
			}, "structure")
		end,
	})
end
