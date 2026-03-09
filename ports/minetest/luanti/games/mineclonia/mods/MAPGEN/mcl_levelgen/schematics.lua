------------------------------------------------------------------------
-- Schematic initialization.
------------------------------------------------------------------------

local lshift = bit.lshift
local rshift = bit.rshift
local band = bit.band
local bor = bit.bor

local portable_schematics = {}
local portable_schematics_loaded = false
mcl_levelgen.portable_schematics = portable_schematics

local cid_ignore = core and core.CONTENT_IGNORE or 5000

function mcl_levelgen.register_portable_schematic (id, specifier, normalize_yprob)
	if portable_schematics_loaded then
		error ("register_portable_schematic mustn't be called after mods have been loaded")
	elseif portable_schematics[id] then
		error ("Schematic already registered: " .. id)
	end
	-- Is this schematic already valid?
	local data
	if type (specifier) == "table" and specifier.data then
		-- Reuse this table, as core.read_schematic will
		-- delete `data' otherwise.
		data = specifier
	else
		data = core.read_schematic (specifier, {
			write_yslice_prob = "all",
		})
	end
	if normalize_yprob then
		for y = 1, data.size.y do
			data.yslice_prob[y] = {
				prob = 0xff,
			}
		end
	end
	portable_schematics[id] = data
end

if core and core.register_on_mods_loaded and core.get_player_by_name then
	core.register_on_mods_loaded (function ()
		portable_schematics_loaded = true
		core.ipc_set ("mcl_levelgen:portable_schematics", portable_schematics)
	end)
end

local function encode_schem_data (cid, param2, probability, force_place)
	if cid > 32767 then
		-- If you encounter this error, please create a more
		-- accommodating data packing scheme.
		error ("Schematic contains content with unrepresentable CID: " .. cid)
	end

	assert (cid <= 32767 and param2 <= 255 and probability <= 255)
	local force_place = force_place and 1 or 0
	return bor (lshift (force_place, 31), lshift (cid, 16),
		    lshift (param2, 8), probability)
end

local function decode_schem_data (data)
	local force_place = rshift (data, 31) ~= 0
	local cid = band (rshift (data, 16), 0x7fff)
	local param2 = band (rshift (data, 8), 0xff)
	local probability = band (data, 0xff)
	return cid, param2, probability, force_place
end

mcl_levelgen.encode_schem_data = encode_schem_data
mcl_levelgen.decode_schem_data = decode_schem_data

function mcl_levelgen.initialize_portable_schematics ()
	local schematics
		= core.ipc_get ("mcl_levelgen:portable_schematics")
	assert (type (schematics) == "table")

	-- Post-process the schematic's data.
	for key, schematic in pairs (schematics) do
		for i, elem in ipairs (schematic.data) do
			if not core.registered_nodes[elem.name] then
				schematic.data[i]
					= encode_schem_data (cid_ignore, 0, 0, false)
			else
				local cid = core.get_content_id (elem.name)
				schematic.data[i]
					= encode_schem_data (cid, elem.param2,
							     elem.prob,
							     elem.force_place)
			end
		end
		portable_schematics[key] = schematic
	end
end

------------------------------------------------------------------------
-- Default schematic processors.
------------------------------------------------------------------------

local indexof = table.indexof

function mcl_levelgen.block_rot_processor (integrity, rottable_cids)
	return function (x, y, z, rng, cid_existing, param2_existing,
			 cid, param2)
		assert (cid and param2)
		if (rottable_cids and indexof (rottable_cids, cid) == -1)
			or rng:next_float () <= integrity then
			return cid, param2
		end
		return nil, nil
	end
end

function mcl_levelgen.block_rule_processor (rules)
	local default = function (_, _, _)
		return true
	end
	local default_pos_predicate = function (_, _, _)
		return true
	end

	for _, rule in ipairs (rules) do
		rule.input_predicate = rule.input_predicate
			or default
		rule.loc_predicate = rule.loc_predicate
			or default
		rule.pos_predicate = rule.pos_predicate
			or default_pos_predicate
		assert (type (rule.cid) == "number")
		assert (type (rule.param2) == "number")
	end

	return function (x, y, z, rng, cid_existing,
			 param2_existing, cid, param2)
		for _, rule in ipairs (rules) do
			if rule.input_predicate (rng, cid, param2)
				and rule.loc_predicate (rng, cid_existing,
							param2_existing)
				and rule.pos_predicate (x, y, z, cid_existing,
							param2_existing,
							cid, param2) then
				return rule.cid, rule.param2
			end
		end
		assert (cid and param2)
		return cid, param2
	end
end

function mcl_levelgen.protected_blocks_processor (protected_cids)
	return function (x, y, z, rng, cid_existing, param2_existing,
			 cid, param2)
		if indexof (protected_cids) ~= -1 then
			return nil, nil
		end
		assert (cid and param2)
		return cid, param2
	end
end

-- function mcl_levelgen.capped_processor (limit, delegate)
-- 	local count = 0
-- 	local processor = function (x, y, z, rng, cid_existing,
-- 				    param2_existing, cid, param2)
-- 		if count < limit then
-- 			local cid_1, param2_1
-- 				= delegate (x, y, z, rng, cid_existing,
-- 					    param2_existing, cid, param2)
-- 			if cid_1 and param2_1
-- 				and (cid ~= cid_1 or param2 ~= param2_1) then
-- 				count = count + 1
-- 			end
-- 			return cid_1, param2_1
-- 		end
-- 		return cid, param2
-- 	end
-- 	local metatable = {
-- 		__call = processor,
-- 	}
-- 	local tbl = {
-- 		initialize = function ()
-- 			count = 0
-- 		end,
-- 	}
-- 	setmetatable (tbl, metatable)
-- 	return tbl
-- end

function mcl_levelgen.wall_update_processor ()
	if not mcl_levelgen.is_levelgen_environment then
		return function (x, y, z, rng, cid_existing, param2_existing,
				 cid, param2)
			return cid, param2
		end
	end
	local wall_p = mcl_levelgen.wall_p
	local notify_generated = mcl_levelgen.notify_generated
	if mcl_levelgen.load_feature_environment then
		return function (x, y, z, rng, cid_existing, param2_existing,
				 cid, param2)
			if wall_p (cid) then
				notify_generated ("mcl_walls:update_walls", x, y, z,
						  { x = x, y = y, z = z, }, true)
			end
			return cid, param2
		end
	else
		return function (x, y, z, rng, cid_existing, param2_existing,
				 cid, param2)
			if wall_p (cid) then
				notify_generated ("mcl_walls:update_walls", x, y, z,
						  { x = x, y = y, z = z, }, true)
			end
			return cid, param2
		end
	end
end
