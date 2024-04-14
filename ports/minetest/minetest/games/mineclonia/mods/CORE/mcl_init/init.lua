local mod_storage = minetest.get_mod_storage()

-- Some global variables (don't overwrite them!)
mcl_vars = {}

mcl_vars.redstone_tick = 0.1
mcl_vars.mg_overworld_min_old = -62

--- GUI / inventory menu settings
mcl_vars.gui_slots = "listcolors[#9990;#FFF7;#FFF0;#000;#FFF]"
-- nonbg is added as formspec prepend in mcl_formspec_prepend
mcl_vars.gui_nonbg = mcl_vars.gui_slots ..
	"style_type[image_button;border=false;bgimg=mcl_inventory_button9.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]"..
	"style_type[button;border=false;bgimg=mcl_inventory_button9.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]"..
	"style_type[field;textcolor=#323232]"..
	"style_type[label;textcolor=#323232]"..
	"style_type[textarea;textcolor=#323232]"..
	"style_type[checkbox;textcolor=#323232]"

-- Background stuff must be manually added by mods (no formspec prepend)
mcl_vars.gui_bg_color = "bgcolor[#00000000]"
mcl_vars.gui_bg_img = "background9[1,1;1,1;mcl_base_textures_background9.png;true;7]"

-- Legacy
mcl_vars.inventory_header = ""

-- Tool wield size
mcl_vars.tool_wield_scale = { x = 1.8, y = 1.8, z = 1 }

-- Mapgen variables
local mg_name = minetest.get_mapgen_setting("mg_name")
local minecraft_height_limit = 320

local singlenode = mg_name == "singlenode"

-- The classic superflat setting is stored in mod storage so it remains
-- constant after the world has been created.
if not mod_storage:get("mcl_superflat_classic") then
	local superflat = mg_name == "flat" and minetest.get_mapgen_setting("mcl_superflat_classic") == "true"
	mod_storage:set_string("mcl_superflat_classic", superflat and "true" or "false")
end
mcl_vars.superflat = mod_storage:get_string("mcl_superflat_classic") == "true"

-- Calculate mapgen_edge_min/mapgen_edge_max
mcl_vars.chunksize = math.max(1, tonumber(minetest.get_mapgen_setting("chunksize")) or 5)
mcl_vars.MAP_BLOCKSIZE = math.max(1, minetest.MAP_BLOCKSIZE or 16)
mcl_vars.mapgen_limit = math.max(1, tonumber(minetest.get_mapgen_setting("mapgen_limit")) or 31000)
mcl_vars.MAX_MAP_GENERATION_LIMIT = math.max(1, minetest.MAX_MAP_GENERATION_LIMIT or 31000)
local central_chunk_offset = -math.floor(mcl_vars.chunksize / 2)
mcl_vars.central_chunk_offset_in_nodes = central_chunk_offset * mcl_vars.MAP_BLOCKSIZE
mcl_vars.chunk_size_in_nodes = mcl_vars.chunksize * mcl_vars.MAP_BLOCKSIZE
local central_chunk_min_pos = central_chunk_offset * mcl_vars.MAP_BLOCKSIZE
local central_chunk_max_pos = central_chunk_min_pos + mcl_vars.chunk_size_in_nodes - 1
local ccfmin = central_chunk_min_pos - mcl_vars.MAP_BLOCKSIZE -- Fullminp/fullmaxp of central chunk, in nodes
local ccfmax = central_chunk_max_pos + mcl_vars.MAP_BLOCKSIZE
local mapgen_limit_b = math.floor(math.min(mcl_vars.mapgen_limit, mcl_vars.MAX_MAP_GENERATION_LIMIT) / mcl_vars.MAP_BLOCKSIZE)
local mapgen_limit_min = -mapgen_limit_b * mcl_vars.MAP_BLOCKSIZE
local mapgen_limit_max = (mapgen_limit_b + 1) * mcl_vars.MAP_BLOCKSIZE - 1
local numcmin = math.max(math.floor((ccfmin - mapgen_limit_min) / mcl_vars.chunk_size_in_nodes), 0) -- Number of complete chunks from central chunk
local numcmax = math.max(math.floor((mapgen_limit_max - ccfmax) / mcl_vars.chunk_size_in_nodes), 0) -- fullminp/fullmaxp to effective mapgen limits.
mcl_vars.mapgen_edge_min = central_chunk_min_pos - numcmin * mcl_vars.chunk_size_in_nodes
mcl_vars.mapgen_edge_max = central_chunk_max_pos + numcmax * mcl_vars.chunk_size_in_nodes

local function coordinate_to_block(x)
	return math.floor(x / mcl_vars.MAP_BLOCKSIZE)
end

local function coordinate_to_chunk(x)
	return math.floor((coordinate_to_block(x) - central_chunk_offset) / mcl_vars.chunksize)
end

function mcl_vars.pos_to_block(pos)
	return {
		x = coordinate_to_block(pos.x),
		y = coordinate_to_block(pos.y),
		z = coordinate_to_block(pos.z)
	}
end

function mcl_vars.pos_to_chunk(pos)
	return {
		x = coordinate_to_chunk(pos.x),
		y = coordinate_to_chunk(pos.y),
		z = coordinate_to_chunk(pos.z)
	}
end

local k_positive = math.ceil(mcl_vars.MAX_MAP_GENERATION_LIMIT / mcl_vars.chunk_size_in_nodes)
local k_positive_z = k_positive * 2
local k_positive_y = k_positive_z * k_positive_z

function mcl_vars.get_chunk_number(pos) -- unsigned int
	local c = mcl_vars.pos_to_chunk(pos)
	return
		(c.y + k_positive) * k_positive_y +
		(c.z + k_positive) * k_positive_z +
		 c.x + k_positive
end

if not mcl_vars.superflat and not singlenode then
	-- Normal mode
	--[[ Realm stacking (h is for height)
	- Overworld (h>=256)
	- Void (h>=1000)
	- Realm Barrier (h=11), to allow escaping the End
	- End (h>=256)
	- Void (h>=1000)
	- Nether (h=128)
	- Void (h>=1000)
	]]

	-- Overworld
	mcl_vars.mg_overworld_min = -128
	mcl_vars.mg_overworld_max_official = mcl_vars.mg_overworld_min + minecraft_height_limit
	mcl_vars.mg_bedrock_overworld_min = mcl_vars.mg_overworld_min
	mcl_vars.mg_bedrock_overworld_max = mcl_vars.mg_bedrock_overworld_min + 4
	mcl_vars.mg_lava_overworld_max = mcl_vars.mg_overworld_min + 10
	mcl_vars.mg_lava = true
	mcl_vars.mg_bedrock_is_rough = true

elseif singlenode then
	mcl_vars.mg_overworld_min = -130
	mcl_vars.mg_overworld_min_old = -64
	mcl_vars.mg_overworld_max_official = mcl_vars.mg_overworld_min + minecraft_height_limit
	mcl_vars.mg_bedrock_overworld_min = mcl_vars.mg_overworld_min
	mcl_vars.mg_bedrock_overworld_max = mcl_vars.mg_bedrock_overworld_min
	mcl_vars.mg_lava = false
	mcl_vars.mg_lava_overworld_max = mcl_vars.mg_overworld_min
	mcl_vars.mg_bedrock_is_rough = false
else
	-- Classic superflat
	local ground = minetest.get_mapgen_setting("mgflat_ground_level")
	ground = tonumber(ground)
	if not ground then
		ground = 8
	end
	mcl_vars.mg_overworld_min = ground - 3
	mcl_vars.mg_overworld_min_old = mcl_vars.overworld_min
	mcl_vars.mg_overworld_max_official = mcl_vars.mg_overworld_min + minecraft_height_limit
	mcl_vars.mg_bedrock_overworld_min = mcl_vars.mg_overworld_min
	mcl_vars.mg_bedrock_overworld_max = mcl_vars.mg_bedrock_overworld_min
	mcl_vars.mg_lava = false
	mcl_vars.mg_lava_overworld_max = mcl_vars.mg_overworld_min
	mcl_vars.mg_bedrock_is_rough = false
end

-- mg_overworld_min_old is the overworld min value from before map generation
-- depth was increased. It is used for handling map layers in mcl_worlds. Some
-- mapgens do not set it, so for those we use the mg_overworld_min value.
if not mcl_vars.mg_overworld_min_old then
	mcl_vars.mg_overworld_min_old = mcl_vars.mg_overworld_min
end

mcl_vars.mg_overworld_max = mcl_vars.mapgen_edge_max

-- The Nether (around Y = -29000)
mcl_vars.mg_nether_min = -29067 -- Carefully chosen to be at a mapchunk border
mcl_vars.mg_nether_max = mcl_vars.mg_nether_min + 128
mcl_vars.mg_bedrock_nether_bottom_min = mcl_vars.mg_nether_min
mcl_vars.mg_bedrock_nether_top_max = mcl_vars.mg_nether_max
mcl_vars.mg_nether_deco_max = mcl_vars.mg_nether_max -11 -- this is so ceiling decorations don't spill into other biomes as bedrock generation calls minetest.generate_decorations to put netherrack under the bedrock
if not mcl_vars.superflat then
	mcl_vars.mg_bedrock_nether_bottom_max = mcl_vars.mg_bedrock_nether_bottom_min + 4
	mcl_vars.mg_bedrock_nether_top_min = mcl_vars.mg_bedrock_nether_top_max - 4
	mcl_vars.mg_lava_nether_max = mcl_vars.mg_nether_min + 31
else
	-- Thin bedrock in classic superflat mapgen
	mcl_vars.mg_bedrock_nether_bottom_max = mcl_vars.mg_bedrock_nether_bottom_min
	mcl_vars.mg_bedrock_nether_top_min = mcl_vars.mg_bedrock_nether_top_max
	mcl_vars.mg_lava_nether_max = mcl_vars.mg_nether_min + 2
end
if mg_name == "flat" then
	if mcl_vars.superflat then
		mcl_vars.mg_flat_nether_floor = mcl_vars.mg_bedrock_nether_bottom_max + 4
		mcl_vars.mg_flat_nether_ceiling = mcl_vars.mg_bedrock_nether_bottom_max + 52
	else
		mcl_vars.mg_flat_nether_floor = mcl_vars.mg_lava_nether_max + 4
		mcl_vars.mg_flat_nether_ceiling = mcl_vars.mg_lava_nether_max + 52
	end
end

-- The End (surface at ca. Y = -27000)
mcl_vars.mg_end_min = -27073 -- Carefully chosen to be at a mapchunk border
mcl_vars.mg_end_max_official = mcl_vars.mg_end_min + minecraft_height_limit
mcl_vars.mg_end_max = mcl_vars.mg_overworld_min - 2000
mcl_vars.mg_end_platform_pos = { x = 100, y = mcl_vars.mg_end_min + 64, z = 0 }
mcl_vars.mg_end_exit_portal_pos = vector.new(0, mcl_vars.mg_end_min + 71, 0)

-- Realm barrier used to safely separate the End from the void below the Overworld
mcl_vars.mg_realm_barrier_overworld_end_max = mcl_vars.mg_end_max
mcl_vars.mg_realm_barrier_overworld_end_min = mcl_vars.mg_end_max - 11

-- Use MineClone 2-style dungeons
mcl_vars.mg_dungeons = true

-- Set default stack sizes
minetest.nodedef_default.stack_max = 64
minetest.craftitemdef_default.stack_max = 64

-- Set random seed for all other mods (Remember to make sure no other mod calls this function)
math.randomseed(os.time())

local chunks = {} -- intervals of chunks generated
function mcl_vars.add_chunk(pos)
	local n = mcl_vars.get_chunk_number(pos) -- unsigned int
	local prev
	for i, d in pairs(chunks) do
		if n <= d[2] then -- we've found it
			if (n == d[2]) or (n >= d[1]) then return end -- already here
			if n == d[1]-1 then -- right before:
				if prev and (prev[2] == n-1) then
					prev[2] = d[2]
					table.remove(chunks, i)
					return
				end
				d[1] = n
				return
			end
			if prev and (prev[2] == n-1) then --join to previous
				prev[2] = n
				return
			end
			table.insert(chunks, i, {n, n}) -- insert new interval before i
			return
		end
		prev = d
	end
	chunks[#chunks+1] = {n, n}
end
function mcl_vars.is_generated(pos)
	local n = mcl_vars.get_chunk_number(pos) -- unsigned int
	for i, d in pairs(chunks) do
		if n <= d[2] then
			return (n >= d[1])
		end
	end
	return false
end

-- Do minetest.get_node and if it returns "ignore", then try again after loading
-- its area using a voxel manipulator.
function mcl_vars.get_node(pos)
	local node = minetest.get_node(pos)
	if node.name ~= "ignore" then
		return node
	end

	minetest.get_voxel_manip():read_from_map(pos, pos)
	return minetest.get_node(pos)
end

-- Register ABMs to update from old mapgen depth to new. The ABMs are limited in
-- the Y space meaning they will completely stop once all bedrock and void in
-- the relevant areas is gone.
if mcl_vars.mg_overworld_min_old ~= mcl_vars.mg_overworld_min then
	local function get_mapchunk_area(pos)
		local pos1 = pos:divide(5 * 16):floor():multiply(5 * 16)
		local pos2 = pos1:add(5 * 16 - 1)
		return pos1, pos2
	end

	local void_regen_min_y = mcl_vars.mg_overworld_min
	local void_regen_max_y = math.floor(mcl_vars.mg_overworld_min_old / (5 * 16)) * (5 * 16) - 1
	local bedrock_regen_min_y = void_regen_max_y + 1
	local bedrock_regen_max_y = mcl_vars.mg_overworld_min_old + 4

	local void_replaced = {}
	minetest.register_abm({
		label = "Replace old world depth void",
		name = ":mcl_mapgen_core:replace_old_void",
		nodenames = { "mcl_core:void" },
		chance = 1,
		interval = 10,
		min_y = void_regen_min_y,
		max_y = void_regen_max_y,
		action = function(pos, node)
			local pos1, pos2 = get_mapchunk_area(pos)
			local h = minetest.hash_node_position(pos1)
			if void_replaced[h] then
				return
			end
			void_replaced[h] = true

			pos2.y = math.min(pos2.y, void_regen_max_y)
			minetest.after(0, function()
				minetest.delete_area(pos1, pos2)
			end)
		end
	})

	local bedrock_replaced = {}
	minetest.register_abm({
		label = "Replace old world depth bedrock",
		name = ":mcl_mapgen_core:replace_old_bedrock",
		nodenames = { "mcl_core:void", "mcl_core:bedrock" },
		chance = 1,
		interval = 10,
		min_y = bedrock_regen_min_y,
		max_y = bedrock_regen_max_y,
		action = function(pos, node)
			local pos1, pos2 = get_mapchunk_area(pos)
			local h = minetest.hash_node_position(pos1)
			if bedrock_replaced[h] then
				if node.name == "mcl_core:bedrock" then
					node.name = "mcl_deepslate:deepslate"
					minetest.set_node(pos, node)
				end
				return
			end
			bedrock_replaced[h] = true

			pos1.y = math.max(pos1.y, bedrock_regen_min_y)
			pos2.y = math.min(pos2.y, bedrock_regen_max_y)

			minetest.after(0, function()
				local vm = minetest.get_voxel_manip()
				local emin, emax = vm:read_from_map(pos1, pos2)
				local data = vm:get_data()
				local a = VoxelArea:new{
					MinEdge = emin,
					MaxEdge = emax,
				}

				local c_void = minetest.get_content_id("mcl_core:void")
				local c_bedrock = minetest.get_content_id("mcl_core:bedrock")
				local c_deepslate = minetest.get_content_id("mcl_deepslate:deepslate")

				local n = 0
				for z = pos1.z, pos2.z do
					for y = pos1.y, pos2.y do
						for x = pos1.x, pos2.x do
							local vi = a:index(x, y, z)
							if data[vi] == c_void or data[vi] == c_bedrock then
								n = n + 1
								data[vi] = c_deepslate
							end
						end
					end
				end

				vm:set_data(data)
				vm:write_to_map(true)
			end)
		end
	})
end
