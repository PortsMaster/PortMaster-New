local pairs = pairs
local ipairs = ipairs

local rshift = bit.rshift
local lshift = bit.lshift

local band = bit.band

------------------------------------------------------------------------
-- Structure extents AreaStore serialization.
--
-- The map (not individual levels) is divided into 1024 x 1024 areas,
-- in which it is assumed that no more than 65536 structure pieces may
-- exist.  This execrable arrangement exists because Minetest's
-- built-in area index is not capable of serializing AreaStores with
-- more than this quantity of values.
------------------------------------------------------------------------

local structure_extents = { }
local storage = core.get_mod_storage ()

for i = 1, 4096 do
	structure_extents[i] = AreaStore ()
	local str = storage:get_string ("structure_extents_" .. i)
	if str and str ~= "" then
		local ok, err = pcall (core.decompress, str, "zstd")
		if ok then
			ok, err = structure_extents[i]:from_string (err)
		end
		if not ok then
			local blurb = {
				"[mcl_levelgen]: Failed to load structure extents for area ",
				i, ": ", err,
			}
			core.log ("error", table.concat (blurb))
		end
	end
end

local function get_structure_extents (pos)
	local x, z = pos.x, pos.z
	local id = lshift (rshift (x + 32768, 10), 6)
		+ rshift (z + 32768, 10)
	return structure_extents[id + 1]
end

local function get_structure_extents_raw (x, z)
	local id = lshift (rshift (x + 32768, 10), 6)
		+ rshift (z + 32768, 10)
	return structure_extents[id + 1]
end

local function save_structure_extents ()
	local nbytes = 0
	for i = 1, 4096 do
		local store = structure_extents[i]
		local str = store:to_string ()
		local data = core.compress (str, "zstd")
		storage:set_string ("structure_extents_" .. i, data)
		nbytes = nbytes + #data
	end
	core.log ("info", ("[mcl_levelgen]: Structure extents occupy " .. nbytes
			   .. " bytes compressed"))
end

core.register_on_shutdown (save_structure_extents)

function mcl_levelgen.get_structures_at (pos, include_corners)
	local extents = get_structure_extents (pos)
	if extents then
		return extents:get_areas_for_pos (pos, include_corners, true)
	else
		return {}
	end
end

local function unpack6 (aabb)
	return aabb[1], aabb[2], aabb[3], aabb[4], aabb[5], aabb[6]
end

local v1, v2 = vector.zero (), vector.zero ()

function mcl_levelgen.save_structure_pieces (pieces)
	for _, piece in ipairs (pieces) do
		local x1, y1, z1, x2, y2, z2 = unpack6 (piece)
		local sid = piece[7]
		v1.x, v1.y, v1.z = x1, y1, z1
		v2.x, v2.y, v2.z = x2, y2, z2

		local sx1 = band (v1.x, -1024)
		local sz1 = band (v1.z, -1024)
		local sx2 = band (v2.x, -1024)
		local sz2 = band (v2.z, -1024)

		for sx = sx1, sx2, 1024 do
			for sz = sz1, sz2, 1024 do
				local store = get_structure_extents_raw (sx, sz)
				assert (store ~= nil)
				local id = store:insert_area (v1, v2, sid)
				if not id then
					local blurb = table.concat ({
							"[mcl_levelgen]: Failed to record structure piece: ",
							sid,
							" spanning ",
							string.format ("(%d,%d,%d) - (%d,%d,%d)",
								       x1, y1, z1, x2, y2, z2),
					})
					core.log ("error", blurb)
				end
			end
		end
	end
end

------------------------------------------------------------------------
-- Migration of old-style structure extents.
------------------------------------------------------------------------

do
	local str = storage:get_string ("structure_extents")
	if str ~= "" then
		local tmp = AreaStore ()
		local data = core.decompress (str, "zstd")
		local ok, _ = tmp:from_string (data)

		if ok then
			local min = vector.new (-32768, -32768, -32768)
			local max = vector.new (32767, 32767, 32767)
			local num_converted = 0
			for _, area in pairs (tmp:get_areas_in_area (min, max, true, true, true)) do
				local store = get_structure_extents (area.min)
				assert (store)
				if store:insert_area (area.min, area.max, area.data) then
					num_converted = num_converted + 1
				end
			end
			core.log ("action", ("[mcl_levelgen]: Converted "
					     .. num_converted .. " old-style structure extents"))
			storage:set_string ("structure_extents", "")
		end
	end
end
