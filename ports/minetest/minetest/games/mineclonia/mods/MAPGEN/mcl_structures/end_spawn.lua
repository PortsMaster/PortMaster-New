local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)


mcl_structures.register_structure("end_spawn_obsidian_platform",{
	static_pos ={mcl_vars.mg_end_platform_pos},
	place_func = function(pos,def,pr)
		local obby = minetest.find_nodes_in_area(vector.offset(pos,-2,0,-2),vector.offset(pos,2,0,2),{"air","mcl_end:end_stone"})
		local air = minetest.find_nodes_in_area(vector.offset(pos,-2,1,-2),vector.offset(pos,2,3,2),{"air","mcl_end:end_stone"})
		minetest.bulk_set_node(obby,{name="mcl_core:obsidian"})
		minetest.bulk_set_node(air,{name="air"})
		return true
	end,
})

mcl_structures.register_structure("end_exit_portal",{
	static_pos = { mcl_vars.mg_end_exit_portal_pos },
	filenames = {
		modpath.."/schematics/mcl_structures_end_exit_portal.mts"
	},
	after_place = function(pos,def,pr,blockseed)
		if  minetest.settings:get_bool("only_peaceful_mobs", false) then
			return
		end
		local p1 = vector.offset(pos,-16,-16,-16)
		local p2 = vector.offset(pos,16,21,16)
		minetest.emerge_area(p1,p2,function(blockpos, action, calls_remaining, param)
			if calls_remaining > 0 then return end
			minetest.bulk_set_node(minetest.find_nodes_in_area(p1,p2,{"mcl_portals:portal_end"}),{name="air"})
			local obj = minetest.add_entity(vector.offset(pos,3, 11, 3), "mobs_mc:enderdragon")
			if obj then
				local dragon_entity = obj:get_luaentity()
				dragon_entity._portal_pos = pos
				if blockseed ~= -1 then
					dragon_entity._initial = true
				end
			else
				minetest.log("error", "[mcl_mapgen_core] ERROR! Ender dragon doesn't want to spawn")
			end
			minetest.fix_light(p1,p2)
		end)
	end
})
mcl_structures.register_structure("end_exit_portal_open",{
	filenames = {
		modpath.."/schematics/mcl_structures_end_exit_portal.mts"
	},
	after_place  = function(pos,def,pr)
		local p1 = vector.offset(pos,-16,-16,-16)
		local p2 = vector.offset(pos,16,16,16)
		minetest.fix_light(p1,p2)
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
	local nn = minetest.find_nodes_in_area(vector.offset(pos,-width/2,0,-width/2),vector.offset(pos,width/2,0,width/2),{"air","group:solid"})
	table.sort(nn,function(a, b)
		return vector.distance(pos, a) < vector.distance(pos, b)
	end)
	local nodes = {}
	for i = 1,math.ceil(#nn*0.55) do
		get_tower(nn[i],height,nodes)
	end
	minetest.bulk_set_node(nodes,{ name="mcl_core:obsidian"} )
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
	minetest.bulk_set_node(nodes,{ name="mcl_panes:bar_flat"} )
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
	place_func = function(pos,def,pr)
		local d = pr:next(6,12)
		local h = d * pr:next(4,6)
		local p1 = vector.offset(pos, -d / 2, 0, -d / 2)
		local p2 = vector.offset(pos, d / 2, h + d, d / 2)
		minetest.emerge_area(p1, p2, function(blockpos, action, calls_remaining, param)
			if calls_remaining ~= 0 then return end
			local s = make_endspike(pos,d,h)
			minetest.set_node(vector.offset(s,0,1,0),{name="mcl_core:bedrock"})
			minetest.add_entity(vector.offset(s,0,2,0),"mcl_end:crystal")
			if pr:next(1,3) == 1 then
				make_cage(vector.offset(s,0,1,0),d)
			end
		end)
		return true
	end,
})
