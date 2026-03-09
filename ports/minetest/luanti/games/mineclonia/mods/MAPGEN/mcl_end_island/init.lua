local width = 200

local noisemap = PerlinNoiseMap({
	offset = 0.5,
	scale = 0.5,
	spread = {x = width + 10, y = width + 10, z = width + 10},
	seed = core.get_mapgen_setting("seed") + 99999,
	octaves = 4,
	persist = 0.85,
}, {x = (width*2)+1, y = 30, z = (width * 2) + 1}):get_3d_map({x = 0, y = 0, z = 0})

local c_end_stone = core.get_content_id("mcl_end:end_stone")
local y_offset = -2

mcl_mapgen_core.register_generator("end_island", function(_, data, _, _, _, area, minp, maxp, _)
	if maxp.y < (-27025 + y_offset) or minp.y > (-27000 + y_offset + 4) or maxp.x < -width or minp.x > width  or maxp.z < -width or minp.z > width then
		return
	end

	for idx in area:iter(math.max(minp.x, -width), math.max(minp.y, -27025 + y_offset + 4), math.max(minp.z, -width), math.min(maxp.x, width), math.min(maxp.y, -27000 + y_offset), math.min(maxp.z, width)) do
		local pos = area:position(idx)
		local y = 27025 + pos.y - y_offset
		if noisemap[pos.x + width + 1][y + 1][pos.z + width + 1] > (math.abs(1 - y / 25) ^ 2 + math.abs(pos.x / width) ^ 2 + math.abs(pos.z / width) ^ 2) then
			data[idx] = c_end_stone
		end
	end
	return true,false,false
end, function(minp,maxp,blockseed)
	if maxp.y < (-27025 + y_offset) or minp.y > (-27000 + y_offset + 4) or maxp.x < -width or minp.x > width  or maxp.z < -width or minp.z > width then
		return
	end
	local nn = core.find_nodes_in_area_under_air(minp,maxp,{"mcl_end:end_stone"})
	local pr = PcgRandom(blockseed)
	table.shuffle(nn)
	if nn and #nn > 0 then
		for i=1,pr:next(1,math.min(5,#nn)) do
			core.add_entity(vector.offset(nn[i],0,1,0),"mobs_mc:enderman")
		end
	end
end, 15, true)
