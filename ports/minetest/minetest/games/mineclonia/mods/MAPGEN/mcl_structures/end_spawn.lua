local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)


mcl_structures.register_structure("end_spawn_obsidian_platform",{
	static_pos ={mcl_vars.mg_end_platform_pos},
	place_func = function(pos, _, _)
		local obby = {}
		local air = {}
		for x = -2, 2 do for z = -2, 2 do
			table.insert(obby, vector.offset(pos, x, 0, z))
		end end
		for x = -2, 2 do for y = 1, 3 do for z = -2, 2 do
			table.insert(air, vector.offset(pos, x, y, z))
		end end end
		mcl_util.bulk_swap_node(obby,{name="mcl_core:obsidian"})
		mcl_util.bulk_swap_node(air,{name="air"})
		return true
	end,
})

mcl_structures.register_structure("end_exit_portal",{
	static_pos = { mcl_vars.mg_end_exit_portal_pos },
	filenames = {
		modpath.."/schematics/mcl_structures_end_exit_portal.mts"
	},
	after_place = function(pos, _, _, blockseed)
		local p1 = vector.offset(pos,-16,-16,-16)
		local p2 = vector.offset(pos,16,21,16)
		core.emerge_area(p1,p2,function(_, _, calls_remaining)
			if calls_remaining > 0 then return end
			mcl_util.bulk_swap_node(core.find_nodes_in_area(p1,p2,{"mcl_portals:portal_end", "mcl_torches:torch_wall"}),{name="air"})
			local obj = core.add_entity(vector.offset(pos,3, 11, 3), "mobs_mc:enderdragon")
			if obj then
				local dragon_entity = obj:get_luaentity()
				dragon_entity._portal_pos = pos
				if blockseed ~= -1 then
					dragon_entity._initial = true
				end
			else
				core.log("error", "[mcl_mapgen_core] ERROR! Ender dragon doesn't want to spawn")
			end
			core.fix_light(p1,p2)
		end)
	end
})

mcl_structures.register_structure("end_exit_portal_deferred",{
	static_pos = { mcl_vars.mg_end_exit_portal_pos },
	filenames = {
		modpath.."/schematics/mcl_structures_end_exit_portal.mts"
	},
	after_place = function(pos, _, _, blockseed)
		local p1 = vector.offset(pos,-16,-16,-16)
		local p2 = vector.offset(pos,16,21,16)
		core.emerge_area(p1,p2,function(_, _, calls_remaining)
			if calls_remaining > 0 then return end
			mcl_util.bulk_swap_node(core.find_nodes_in_area(p1,p2,{"mcl_portals:portal_end", "mcl_torches:torch_wall"}),{name="air"})
			core.fix_light(p1,p2)
		end)
	end
})

mcl_structures.register_structure("end_exit_portal_open",{
	filenames = {
		modpath.."/schematics/mcl_structures_end_exit_portal.mts"
	},
	after_place  = function(pos, _, _)
		local p1 = vector.offset(pos,-16,-16,-16)
		local p2 = vector.offset(pos,16,16,16)
		core.fix_light(p1,p2)
	end
})
mcl_structures.register_structure("end_gateway_portal",{
	filenames = {
		modpath.."/schematics/mcl_structures_end_gateway_portal.mts"
	},
})

local function get_tower(p,h,tbl)
	for i = 1,h do
		table.insert(tbl,vector.offset(p,0,i,0))
	end
end

local function make_endspike(pos,width,height)
	local nn = core.find_nodes_in_area(vector.offset(pos,-width/2,0,-width/2),vector.offset(pos,width/2,0,width/2),{"air","group:solid"})
	table.sort(nn,function(a, b)
		return vector.distance(pos, a) < vector.distance(pos, b)
	end)
	local nodes = {}
	for i = 1,math.ceil(#nn*0.55) do
		get_tower(nn[i],height,nodes)
	end
	mcl_util.bulk_swap_node(nodes,{ name="mcl_core:obsidian"} )
	return vector.offset(pos,0,height,0)
end

function make_cage(pos,width)
	local nodes = {}
	local r = math.max(1,math.floor(width/2) - 2)
	for x=-r,r do for y = 0,width do for z = -r,r do
		if x == r or x == -r or z==r or z == -r then
			table.insert(nodes,vector.add(pos,vector.new(x,y,z)))
		end
	end end end
	mcl_util.bulk_swap_node(nodes,{ name="mcl_panes:bar_flat"} )
	for _,p in pairs(nodes) do
		mcl_panes.update_pane(p)
	end
end

local function get_points_on_circle(pos,r,n)
	local rt = {}
	for i=1, n do
		table.insert(rt,vector.offset(pos,r * math.cos(((i-1)/n) * (2*math.pi)),0,  r* math.sin(((i-1)/n) * (2*math.pi)) ))
	end
	return rt
end

mcl_structures.register_structure("end_spike",{
	static_pos =get_points_on_circle(vector.offset(mcl_vars.mg_end_exit_portal_pos,0,-20,0),43,10),
	place_func = function(pos, _,pr)
		local d = pr:next(6,12)
		local h = d * pr:next(4,6)
		local p1 = vector.offset(pos, -d / 2, 0, -d / 2)
		local p2 = vector.offset(pos, d / 2, h + d, d / 2)
		core.emerge_area(p1, p2, function(_, _, calls_remaining)
			if calls_remaining ~= 0 then return end
			local s = make_endspike(pos,d,h)
			core.swap_node(vector.offset(s,0,1,0),{name="mcl_core:bedrock"})
			core.add_entity(vector.offset(s,0,2,0),"mcl_end:crystal")
			if pr:next(1,3) == 1 then
				make_cage(vector.offset(s,0,1,0),d)
			end
		end)
		return true
	end,
})
