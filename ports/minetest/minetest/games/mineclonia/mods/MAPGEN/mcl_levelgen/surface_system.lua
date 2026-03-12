------------------------------------------------------------------------
-- Surface rules
--
-- Surface rules are composable trees of boolean conditions yielding
-- block states akin to density functions that are evaluated once per
-- solid node to derive a suitable block state from a node, its
-- surroundings in its chunk, and biome characteristics.
--
-- Such context vectors are of the form:
--
--   {
--     X, Y, Z, BIOME_NAME,
--     PRELIMINARY_SURFACE_XZ00,
--     PRELIMINARY_SURFACE_XZ10,
--     PRELIMINARY_SURFACE_XZ01,
--     PRELIMINARY_SURFACE_XZ11,
--     HEIGHTMAP,
--     SURFACE_DEPTH,
--     STONE_DEPTH_BELOW,
--     STONE_DEPTH_ABOVE,
--     WATER_HEIGHT,
--   }
--
------------------------------------------------------------------------

local function verbose_print (...)
	if mcl_levelgen.verbose then
		print (...)
	end
end

local cid_air, cid_water_source, cid_lava_source, cid_nether_lava_source
if core and core.get_content_id then
	cid_air = core.CONTENT_AIR
	if core.register_on_mods_loaded then
		core.register_on_mods_loaded (function ()
			cid_water_source = core.get_content_id ("mcl_core:water_source")
			cid_lava_source = core.get_content_id ("mcl_core:lava_source")
			cid_nether_lava_source
				= core.get_content_id ("mcl_nether:nether_lava_source")
		end)
	else
		cid_water_source = core.get_content_id ("mcl_core:water_source")
		cid_lava_source = core.get_content_id ("mcl_core:lava_source")
		cid_nether_lava_source
			= core.get_content_id ("mcl_nether:nether_lava_source")
	end
else
	cid_air = 0
	cid_water_source = 1
	cid_lava_source = 4
	cid_nether_lava_source = 4
end

local X = 1
local Y = 2
local Z = 3
local BIOME_NAME = 4
local PRELIMINARY_SURFACE_XZ00 = 5
local PRELIMINARY_SURFACE_XZ10 = 6
local PRELIMINARY_SURFACE_XZ01 = 7
local PRELIMINARY_SURFACE_XZ11 = 8
local HEIGHTMAP = 9
local SURFACE_DEPTH = 10
local STONE_DEPTH_BELOW = 11
local STONE_DEPTH_ABOVE = 12
local WATER_HEIGHT = 13

local surface_rule = {
	is_surface_rule = true,
}
local surface_condition = {
	is_surface_condition = true,
}

local function make_surface_rule (tbl)
	assert (tbl.is_surface_rule)
	return tbl
end

local function make_surface_condition (tbl)
	assert (tbl.is_surface_condition)
	return tbl
end

------------------------------------------------------------------------
-- Above Preliminary Surface
-- minecraft:above_preliminary_surface
------------------------------------------------------------------------

local above_preliminary_surface = table.merge (surface_condition, {
	name = "mcl_levelgen:above_preliminary_surface",
})
local lerp2d = mcl_levelgen.lerp2d
local floor = math.floor
local band = bit.band

local function get_min_surface_level (ctx, system)
	-- Lerp within this section.
	local xz11 = ctx[PRELIMINARY_SURFACE_XZ11]
	local xz01 = ctx[PRELIMINARY_SURFACE_XZ01]
	local xz10 = ctx[PRELIMINARY_SURFACE_XZ10]
	local xz00 = ctx[PRELIMINARY_SURFACE_XZ00]
	local val = lerp2d (band (ctx[X], 0xf) / 16.0,
			    band (ctx[Z], 0xf) / 16.0,
			    xz00, xz10, xz01, xz11)
	return floor (val) + ctx[SURFACE_DEPTH] - 8
end

local function closures_for_above_preliminary_surface (condition)
	return { get_min_surface_level, }
end

local function assemble_above_preliminary_surface (val, condition, get_min_surface_level)
	return string.format ("%s = ctx[Y] >= %s", val,
			      string.format ("floor (%s (ctx, system))",
					     get_min_surface_level))
end

make_surface_condition (above_preliminary_surface)

function mcl_levelgen.above_preliminary_surface_cond ()
	return above_preliminary_surface
end

------------------------------------------------------------------------
-- Hole
-- minecraft:hole
------------------------------------------------------------------------

local hole = table.merge (surface_condition, {
	name = "mcl_levelgen:hole",
})

local function assemble_hole (val, condition)
	return string.format ("%s = ctx[SURFACE_DEPTH] <= 0", val)
end

make_surface_condition (hole)

function mcl_levelgen.hole_cond ()
	return hole
end

------------------------------------------------------------------------
-- Noise Threshold
-- minecraft:noise_threshold
------------------------------------------------------------------------

local noise_threshold = table.merge (surface_condition, {
	name = "mcl_levelgen:noise_threshold",
	noise = nil,
	min_threshold = 0,
	max_threshold = 0,
})

function mcl_levelgen.noise_threshold_cond (noise, min_threshold, max_threshold)
	local values = table.merge (noise_threshold, {
		noise = noise,
		min_threshold = min_threshold,
		max_threshold = max_threshold,
	})
	assert (noise.left and noise.right)
	return make_surface_condition (values)
end

------------------------------------------------------------------------
-- Unary Not
-- minecraft:not
------------------------------------------------------------------------

local notcond = table.merge (surface_condition, {
	name = "mcl_levelgen:not",
	target = nil,
})

function mcl_levelgen.not_cond (target)
	local values = table.merge (notcond, {
		target = target,
	})
	assert (target.is_surface_condition)
	return make_surface_condition (values)
end

------------------------------------------------------------------------
-- Steep (Hillside Detector)
-- minecraft:steep
------------------------------------------------------------------------

local steep = table.merge (surface_condition, {
	name = "mcl_levelgen:steep",
})
local mathmin = math.min
local mathmax = math.max
local unpack_height_map = mcl_levelgen.unpack_height_map
local steep_chunksize = 5
local steep_x_origin, steep_z_origin

local function hindex (heightmap, x, z)
	local idx = x * steep_chunksize + z + 1
	local surface, _ = unpack_height_map (heightmap[idx])
	return surface
end

local function steep_exists (ctx, system)
	local x, z = ctx[X] - steep_x_origin, ctx[Z] - steep_z_origin

	-- XXX: this reads as though it would only detect precipices
	-- down the north and east faces of a mountain.

	-- Compute Z's position within its chunk.
	local zchunk = band (z, 15)

	-- Compute sampling positions confined to the same chunk.
	local zmin = band (z, -16) + mathmax (zchunk - 1, 0)
	local zmax = band (z, -16) + mathmin (zchunk + 1, 15)

	local heightmap = ctx[HEIGHTMAP]
	if hindex (heightmap, x, zmax)
		>= hindex (heightmap, x, zmin) + 4 then
		return true
	else
		-- Repeat along the X axis.
		local xchunk = band (x, 15)
		local xmin = band (x, -16) + mathmax (xchunk - 1, 0)
		local xmax = band (x, -16) + mathmin (xchunk + 1, 15)
		return hindex (heightmap, xmin, z)
			>= hindex (heightmap, xmax, z) + 4
	end
end

local function closures_for_steep (cond)
	return { steep_exists, }
end

local function assemble_steep (val, condition, steep_exists)
	return string.format ("%s = %s (ctx, system)", val, steep_exists)
end

steep = make_surface_condition (steep)

function mcl_levelgen.steep_cond ()
	return steep
end

------------------------------------------------------------------------
-- "Temperature" a.k.a. "experiences snowfall"
-- minecraft:temperature
------------------------------------------------------------------------

local temperature = table.merge (surface_condition, {
	name = "mcl_levelgen:temperature",
})
local is_temp_snowy = mcl_levelgen.is_temp_snowy

local function assemble_temperature (val, condition, is_temp_snowy)
	local str = " (ctx[BIOME_NAME], ctx[X], ctx[Y], ctx[Z])"
	return string.format ("%s = %s %s", val, is_temp_snowy, str)
end

local function closures_for_temperature (cond)
	return { is_temp_snowy, }
end

temperature = make_surface_condition (temperature)

function mcl_levelgen.temperature_cond ()
	return temperature
end

------------------------------------------------------------------------
-- Biome
-- minecraft:biome
------------------------------------------------------------------------

local biome = table.merge (surface_condition, {
	name = "mcl_levelgen:biome",
	biome = nil,
	biome1 = nil,
	biome2 = nil,
})

function mcl_levelgen.biome_cond (name, name1, name2)
	assert (mcl_levelgen.registered_biomes[name])
	assert (not name1 or mcl_levelgen.registered_biomes[name1])
	assert (not name2 or mcl_levelgen.registered_biomes[name2])
	local values = table.merge (biome, {
		biome = name,
		biome1 = name1,
		biome2 = name2,
	})
	return make_surface_condition (values)
end

------------------------------------------------------------------------
-- Stone depth check
-- minecraft:stone_depth_check
------------------------------------------------------------------------

local stone_depth_check = table.merge (surface_condition, {
	name = "mcl_levelgen:stone_depth_check",
	surface_type = nil, -- "floor" or "ceiling".
	add_surface_depth = false,
	secondary_depth_range = 0,
	offset = 0.0,
})

local function map_surface_depth (val, max)
	return (val + 1.0) / 2.0 * max
end

local function closures_for_stone_depth_check (cond)
	return { map_surface_depth, }
end

local function assemble_stone_depth_check (val, cond, map_surface_depth)
	local str = val .. " = "
	if cond.surface_type == "ceiling" then
		str = str .. "ctx[STONE_DEPTH_BELOW] <= "
	else
		str = str .. "ctx[STONE_DEPTH_ABOVE] <= "
	end
	local base_offset = 1 + cond.offset
	str = str .. base_offset
	if cond.add_surface_depth then
		str = str .. " + ctx[SURFACE_DEPTH]"
	end
	if cond.secondary_depth_range ~= 0.0 then
		str = str .. string.format (" + %s (%s, %d)",
					    map_surface_depth,
					    "system:get_secondary_surface (ctx[X], ctx[Z])",
					    cond.secondary_depth_range)
	end
-- 	str = str .. "\n" .. [[
-- if ctx[X] == -977 and ctx[Y] == 32 and ctx[Z] == -314 then
-- 	print (ctx, ctx[STONE_DEPTH_BELOW], ctx[SURFACE_DEPTH])
-- end
-- ]]
	return str
end

function mcl_levelgen.stone_depth_check_cond (offset, add_surface_depth,
					      secondary_depth_range, surface_type)
	assert (surface_type == "floor" or surface_type == "ceiling")
	local values = table.merge (stone_depth_check, {
		surface_type = surface_type,
		add_surface_depth = add_surface_depth,
		secondary_depth_range = secondary_depth_range,
		offset = offset,
	})
	return make_surface_condition (values)
end

------------------------------------------------------------------------
-- Water surface check.
-- minecraft:water
------------------------------------------------------------------------

local water = table.merge (surface_condition, {
	name = "mcl_levelgen:water",
	plane_or_axis = "y",
	offset = 0,
	surface_depth_multiplier = 0, -- -20 to 20.
	add_stone_depth = false,
})

local huge = math.huge

local function assemble_water (val, cond)
	local template = "if ctx[WATER_HEIGHT] == -huge then\n %s = true\nelse\n%s\nend"
	local ytest = "ctx[Y]"
	if cond.add_stone_depth then
		ytest = ytest .. " + ctx[STONE_DEPTH_ABOVE]"
	end
	local ydepth = "ctx[WATER_HEIGHT]"
	if cond.offset ~= 0 then
		ydepth = ydepth .. " + " .. cond.offset
	end
	if cond.surface_depth_multiplier ~= 0 then
		ydepth = ydepth .. " + ctx[SURFACE_DEPTH] * "
			.. cond.surface_depth_multiplier
	end
	local test = string.format ("%s = %s >= %s", val, ytest, ydepth)
	local str = string.format (template, val, test)
	return str
end

function mcl_levelgen.water_cond (offset, surface_depth_multiplier,
				  add_stone_depth)
	local values = table.merge (water, {
		offset = offset,
		surface_depth_multiplier = surface_depth_multiplier,
		add_stone_depth = add_stone_depth,
	})
	return make_surface_condition (values)
end

------------------------------------------------------------------------
-- Vertical gradient
-- minecraft:vertical_gradient
------------------------------------------------------------------------

local vertical_gradient = table.merge (surface_condition, {
	name = "mcl_levelgen:vertical_gradient",
	rng = nil,
	true_at_and_below = 0.0,
	false_at_and_above = 1.0,
})

local function compute_vertical_gradient (ctx, rng, below, above, total)
	local y = ctx[Y]
	if y <= below then
		return true
	elseif y >= above then
		return false
	else
		local x = 1.0 - (y - below) / total
		rng:reseed_positional (ctx[X], y, ctx[Z])
		local value = rng:next_float ()
		return value < x
	end
end

local function closures_for_vertical_gradient (cond)
	return { compute_vertical_gradient, cond.rng, }
end

local function assemble_vertical_gradient (val, cond, vertical_gradient, rng)
	return string.format ("%s = %s (ctx, %s, %.7f, %.7f, %.7f)",
			      val, vertical_gradient, rng,
			      cond.true_at_and_below,
			      cond.false_at_and_above,
			      (cond.false_at_and_above
			       - cond.true_at_and_below))
end

function mcl_levelgen.make_vertical_gradient (preset, resource_key, true_at_and_below,
					      false_at_and_above)
	local factory_1
		= preset.factory (resource_key):fork_positional ()
	local rng = factory_1:create_reseedable ()
	assert (type (true_at_and_below) == "number"
		and type (false_at_and_above) == "number")
	local values = table.merge (vertical_gradient, {
		rng = rng,
		true_at_and_below = true_at_and_below,
		false_at_and_above = false_at_and_above,
	})
	return make_surface_condition (values)
end

------------------------------------------------------------------------
-- Vertical anchor condition
-- minecraft:y_above
------------------------------------------------------------------------

local y_above = table.merge (surface_condition, {
	name = "mcl_levelgen:y_above",
	anchor = 0,
	surface_depth_multiplier = 0,
	add_stone_depth = false,
})

local function assemble_y_above (val, cond)
	local ytest = "ctx[Y]"
	if cond.add_stone_depth then
		ytest = ytest .. " + ctx[STONE_DEPTH_ABOVE]"
	end
	local ydepth = tostring (cond.anchor)
	if cond.surface_depth_multiplier ~= 0 then
		ydepth = ydepth .. " + ctx[SURFACE_DEPTH] * "
			.. cond.surface_depth_multiplier
	end
	local test = string.format ("%s = %s >= %s", val, ytest, ydepth)
	return test
end

function mcl_levelgen.y_above_cond (anchor, surface_depth_multiplier,
				    add_stone_depth)
	local values = table.merge (y_above, {
		anchor = anchor,
		surface_depth_multiplier = surface_depth_multiplier,
		add_stone_depth = add_stone_depth,
	})
	return make_surface_condition (values)
end

------------------------------------------------------------------------
-- Banded lands ("badlands") surface rule
-- minecraft:bandlands
------------------------------------------------------------------------

local bandlands = table.merge (surface_rule, {
	name = "mcl_levelgen:bandlands",
})

bandlands = make_surface_rule (bandlands)

function mcl_levelgen.bandlands_rule ()
	return bandlands
end

------------------------------------------------------------------------
-- Block rule
-- minecraft:block
------------------------------------------------------------------------

local block_rule = table.merge (surface_rule, {
	name = "mcl_levelgen:block",
	cid = nil,
	param2 = nil,
})

function mcl_levelgen.block_rule (cid, param2)
	assert (cid and param2)
	local values = table.merge (block_rule, {
		cid = cid,
		param2 = param2,
	})
	return make_surface_rule (values)
end

------------------------------------------------------------------------
-- Sequence rule
-- minecraft:sequence
------------------------------------------------------------------------

-- This produces a shallow copy of TBL.

local function copy (tbl)
	local copy = {}
	for key, value in pairs (tbl) do
		copy[key] = value
	end
	return copy
end

local sequence_rule = table.merge (surface_rule, {
	name = "mcl_levelgen:sequence",
	rules = {},
})

function mcl_levelgen.sequence_rule (rules)
	local values = table.merge (sequence_rule, {
		rules = copy (rules),
	})
	for _, item in ipairs (rules) do
		assert (item.is_surface_rule)
	end
	return make_surface_rule (values)
end

------------------------------------------------------------------------
-- Condition rule
-- minecraft:condition
------------------------------------------------------------------------

local condition_rule = table.merge (surface_rule, {
	name = "mcl_levelgen:condition",
	if_true = nil,
	then_run = nil,
})

function mcl_levelgen.condition_rule (if_true, then_run)
	assert (if_true.is_surface_condition and if_true.name)
	assert (then_run.is_surface_rule and then_run.name)
	local values = table.merge (condition_rule, {
		if_true = if_true,
		then_run = then_run,
	})
	return make_surface_rule (values)
end

------------------------------------------------------------------------
-- Surface rule compilation.
--
-- Surface rules are converted into biome-specific closures by a
-- compilation process that open codes all tests and proceeds to
-- perform some elementary simplification.
------------------------------------------------------------------------

local encode_node = mcl_levelgen.encode_node

local function indexof (list, val)
	for i, v in ipairs (list) do
		if v == val then
			return i
		end
	end
	return -1
end

local debug_surface_rules = false

function mcl_levelgen.compile_surface_rule (rule, biome, system)
	local stmts = {}
	local valno = 0
	local noiseids = {}
	local closureids = {}
	local noises = {}
	local closures = {}
	local captures = {}

	local function valalloc ()
		table.insert (stmts, { "newname", valno, })
		valno = valno + 1
		return valno - 1
	end

	local function insnoise (noise)
		assert (noise.left and noise.right)
		if noiseids[noise] then
			return noiseids[noise]
		end

		captures[valno] = noise.get_value
		noiseids[noise] = valno
		valno = valno + 1
		return valno - 1
	end

	local function insclosure (closure)
		if closureids[closure] then
			return closureids[closure]
		end

		captures[valno] = closure
		closureids[closure] = valno
		table.insert (closures, valno)
		valno = valno + 1
		return valno - 1
	end

	local function compile_condition (ret, condition)
		if condition.name == "mcl_levelgen:above_preliminary_surface" then
			table.insert (stmts, { "callproc", ret,
					       assemble_above_preliminary_surface,
					       closures_for_above_preliminary_surface,
					       condition, })
		elseif condition.name == "mcl_levelgen:hole" then
			table.insert (stmts, { "callproc", ret, assemble_hole, nil,
					       condition, })
		elseif condition.name == "mcl_levelgen:noise_threshold" then
			local noise = valalloc ()
			table.insert (stmts, { "loadnoise", noise, insnoise (condition.noise), })
			table.insert (stmts, { "setrange", ret, noise, condition.min_threshold,
					       condition.max_threshold, })
		elseif condition.name == "mcl_levelgen:not" then
			compile_condition (ret, condition.target)
			table.insert (stmts, { "not", ret, })
		elseif condition.name == "mcl_levelgen:steep" then
			table.insert (stmts, { "callproc", ret, assemble_steep,
					       closures_for_steep, condition, })
		elseif condition.name == "mcl_levelgen:temperature" then
			table.insert (stmts, { "callproc", ret, assemble_temperature,
					       closures_for_temperature, condition, })
		elseif condition.name == "mcl_levelgen:biome" then
			assert (biome)
			if biome ~= condition.biome
				and biome ~= condition.biome1
				and biome ~= condition.biome2 then
				table.insert (stmts, { "setfalse", ret, })
			else
				table.insert (stmts, { "settrue", ret, })
			end
		elseif condition.name == "mcl_levelgen:stone_depth_check" then
			table.insert (stmts, { "callproc", ret, assemble_stone_depth_check,
					       closures_for_stone_depth_check,
					       condition, })
		elseif condition.name == "mcl_levelgen:water" then
			table.insert (stmts, { "callproc", ret, assemble_water, nil,
					       condition, })
		elseif condition.name == "mcl_levelgen:y_above" then
			table.insert (stmts, { "callproc", ret, assemble_y_above, nil,
					       condition, })
		elseif condition.name == "mcl_levelgen:vertical_gradient" then
			table.insert (stmts, { "callproc", ret, assemble_vertical_gradient,
					       closures_for_vertical_gradient, condition, })
		else
			error ("Unknown condition: " .. condition.name)
		end
	end

	local function compile_rule (ret, rule)
		if rule.name == "mcl_levelgen:condition" then
			local retval = valalloc ()
			compile_condition (retval, rule.if_true)
			table.insert (stmts, { "if", retval, })
			compile_rule (ret, rule.then_run)
			table.insert (stmts, { "end", })
		elseif rule.name == "mcl_levelgen:sequence" then
			local depth = 0
			for _, rule1 in ipairs (rule.rules) do
				compile_rule (ret, rule1)
				table.insert (stmts, { "ifnot", ret, })
				depth = depth + 1
			end
			for depth = 1, depth do
				table.insert (stmts, { "end", })
			end
		elseif rule.name == "mcl_levelgen:block" then
			local param2 = rule.param2
			if param2 == "grass_palette_index" then
				local biomes = mcl_levelgen.registered_biomes[biome]
				param2 = biomes.grass_palette_index
				assert (type (param2) == "number")
			end
			table.insert (stmts, { "set", ret, rule.cid, param2, })
		elseif rule.name == "mcl_levelgen:bandlands" then
			local noise = valalloc ()
			local mesa_band_offset_noise = system.mesa_band_offset_noise
			table.insert (stmts, { "loadnoise", noise,
					       insnoise (mesa_band_offset_noise), })
			table.insert (stmts, { "bandlands", ret, noise, })
		else
			error ("Invalid surface rule: " .. rule.name)
		end
	end

	local function count_stmts (stmts)
		local i = 0
		for _, stmt in ipairs (stmts) do
			if stmt[1] ~= "nop" then
				i = i + 1
			end
		end
		return i
	end

	local function assemble_stmts (stmts)
		local lines = {}
		for _, stmt in ipairs (stmts) do
			local str
			if stmt[1] == "newname" then
				str = string.format ("local val%04d", stmt[2])
			elseif stmt[1] == "callproc" then
				local closures = stmt[4]
					and stmt[4] (unpack (stmt, 5))
					or {}
				for i, closure in ipairs (closures) do
					local id = insclosure (closure)
					closures[i] = string.format ("c%04d", id)
				end
				str = stmt[3] (string.format ("val%04d", stmt[2]),
					       unpack (stmt, 5), unpack (closures))
			elseif stmt[1] == "loadnoise" then
				str = string.format ("val%04d = n%04d (ctx[X], 0.0, ctx[Z])",
						     stmt[2], stmt[3])
				if indexof (noises, stmt[3]) == -1 then
					table.insert (noises, stmt[3])
				end
			elseif stmt[1] == "setrange" then
				str = string.format ("val%04d = val%04d >= %.7f and val%04d <= %.7f",
						     stmt[2], stmt[3], stmt[4], stmt[3], stmt[5])
			elseif stmt[1] == "not" then
				str = string.format ("val%04d = not val%04d", stmt[2], stmt[2])
			elseif stmt[1] == "setfalse" then
				str = string.format ("val%04d = false", stmt[2])
			elseif stmt[1] == "settrue" then
				str = string.format ("val%04d = true", stmt[2])
			elseif stmt[1] == "bandlands" then
				local template
					= "system.mesa_bands[(ctx[Y] + 192 + floor (val%04d * 4.0 + 0.5)) %% 192 + 1]"
				local load_mesa_band
					= string.format (template, stmt[3])
				str = string.format ("val%04d = %s", stmt[2], load_mesa_band)
			elseif stmt[1] == "end" then
				str = "end"
			elseif stmt[1] == "if" then
				str = string.format ("if val%04d then", stmt[2])
			elseif stmt[1] == "ifnot" then
				str = string.format ("if not val%04d then", stmt[2])
			-- elseif stmt[1] == "else" then
			-- 	str = string.format ("if \"else\" then", stmt[2])
			elseif stmt[1] == "else" then
				str = "else"
			elseif stmt[1] == "set" then
				if core then
					local encoded = encode_node (stmt[3], stmt[4])
					local name = core.get_name_from_content_id (stmt[3])
					str = string.format ("val%04d = 0x%x -- %s",
							     stmt[2], encoded, name)
				else
					str = string.format ("val%04d = 0x%x -- %s", stmt[2],
							     105030, stmt[3])
				end
			elseif stmt[1] == "move" then
				str = string.format ("val%04d = val%04d", stmt[2],
						     stmt[3])
			else
				error ("Unknown stmt: " .. stmt[1])
			end

			table.insert (lines, str)
		end
		return table.concat (lines, "\n")
	end

	local ret = valalloc ()
	compile_rule (ret, rule)

	local function endif (stmts, i)
		local depth = 0
		for i = i, #stmts do
			if stmts[i][1] == "if" or stmts[i][1] == "ifnot" then
				depth = depth + 1
			elseif stmts[i][1] == "end" then
				assert (depth >= 1)
				if depth == 1 then
					return i
				else
					depth = depth - 1
				end
			end
		end
		assert (false)
	end

	local function kill_dead_code (stmts)
		local qtys = {}
		local qtypdl = {}

		local i = 1
		while i <= #stmts do
			local stmt = stmts[i]
			if stmt[1] == "newname" then
				qtys[stmt[2]] = false
				for _, parent in ipairs (qtypdl) do
					if parent[stmt[2]] ~= false then
						parent[stmt[2]] = nil
					end
				end
			elseif stmt[1] == "setfalse" then
				qtys[stmt[2]] = false
				for _, parent in ipairs (qtypdl) do
					if parent[stmt[2]] ~= false then
						parent[stmt[2]] = nil
					end
				end
			elseif stmt[1] == "move" then
				qtys[stmt[2]] = qtys[stmt[3]]
				for _, parent in ipairs (qtypdl) do
					if parent[stmt[2]] ~= qtys[stmt[3]] then
						parent[stmt[2]] = nil
					end
				end
			elseif stmt[1] == "loadnoise"
				or stmt[1] == "settrue"
				or stmt[1] == "bandlands"
				or stmt[1] == "set" then
				qtys[stmt[2]] = true
				for _, parent in ipairs (qtypdl) do
					if parent[stmt[2]] ~= true then
						parent[stmt[2]] = nil
					end
				end
			elseif stmt[1] == "callproc" or stmt[1] == "not"
				or stmt[1] == "setrange" then
				qtys[stmt[2]] = nil
				for _, parent in ipairs (qtypdl) do
					parent[stmt[2]] = nil
				end
			else
				-- Control flow.  Delete any `if' stmt
				-- whose predicate is known to be
				-- false.  Extract the bodies of any
				-- `if' stmt whose predicate is known
				-- to be true.  Create and push a new
				-- scope otherwise.

				if stmt[1] == "if" or stmt[1] == "ifnot" then
					if (stmt[1] == "if" and qtys[stmt[2]] == false)
						or (stmt[1] == "ifnot" and qtys[stmt[2]] == true)
						or (stmts[i + 1][1] == "end") then
						local term = endif (stmts, i)
						local jout = i - 1
						for j = term + 1, #stmts do
							jout = i + j - (term + 1)
							stmts[jout] = stmts[j]
						end
						for k = jout + 1, #stmts do
							stmts[k] = nil
						end
						i = i - 1
					elseif (stmt[1] == "if") == qtys[stmt[2]] then
						local term = endif (stmts, i)
						local jout = i - 1
						for j = i + 1, #stmts - 1 do
							jout = i + j - (i + 1)
							if j < term then
								stmts[jout] = stmts[j]
							else
								stmts[jout] = stmts[j + 1]
							end
							assert (stmts[jout])
						end
						for k = jout + 1, #stmts do
							stmts[k] = nil
						end
						i = i - 1
					else
						-- Create a new scope and save the existing.
						local qtys1 = copy (qtys)
						qtypdl[#qtypdl + 1], qtys = qtys, qtys1

						-- The conditional
						-- must be true/false
						-- as the case may be.
						qtys[stmt[2]] = stmt[1] == "if"
					end
				elseif stmt[1] == "end" then
					assert (#qtypdl >= 1)
					qtys, qtypdl[#qtypdl] = qtypdl[#qtypdl], nil
				else
					error ("Stmt not known to optimizer: " .. stmt[1])
				end
			end
			i = i + 1
		end
	end

	local function kill_dead_assignments (stmts)
		local qty_read_ops = {}
		local qty_write_ops = {}
		local qtys = {}
		local qtypdl = {}

		local i = 1
		while i <= #stmts do
			local stmt = stmts[i]
			if stmt[1] == "newname" then
				qty_read_ops[stmt[2]] = {}
				qty_write_ops[stmt[2]] = {
					stmt,
				}
				qtys[#qtys + 1] = stmt[2]
			elseif stmt[1] == "if"
				or stmt[1] == "ifnot" then
				local ops = qty_read_ops[stmt[2]]
				assert (ops)
				ops[#ops + 1] = stmt

				-- Open a new scope.
				qtypdl[#qtypdl + 1] = qtys
				qtys = {}
			elseif stmt[1] == "setrange" or stmt[1] == "move"
				or stmt[1] == "bandlands" then
				local r_ops = qty_read_ops[stmt[3]]
				local w_ops = qty_write_ops[stmt[2]]
				assert (r_ops and w_ops)
				r_ops[#r_ops + 1] = stmt
				w_ops[#w_ops + 1] = stmt
			elseif stmt[1] == "settrue"
				or stmt[1] == "setfalse"
				or stmt[1] == "loadnoise"
				or stmt[1] == "set"
				or stmt[1] == "callproc"
				or stmt[1] == "not" then
				local w_ops = qty_write_ops[stmt[2]]
				assert (w_ops)
				w_ops[#w_ops + 1] = stmt
			elseif stmt[1] == "end" then
				assert (#qtypdl >= 1)

				-- Close the current scope, deleting
				-- any instructions which alter or
				-- create values that are never
				-- referenced.

				repeat
					local changed = false
					for _, qty in ipairs (qtys) do
						local ops = qty_read_ops[qty]
						if ops and count_stmts (ops) == 0 then
							-- Nop each statement
							-- in qty_write_ops.
							for _, stmt in ipairs (qty_write_ops[qty]) do
								assert (stmt[1] ~= "end"
									and stmt[1] ~= "if"
									and stmt[1] ~= "ifnot")
								stmt[1] = "nop"
							end
							qty_read_ops[qty] = nil
							changed = true
						end
					end
				until not changed

				for _, qty in ipairs (qtys) do
					qty_read_ops[qty] = nil
					qty_write_ops[qty] = nil
				end

				qtys = qtypdl[#qtypdl]
				qtypdl[#qtypdl] = nil
			else
				error ("Stmt not known to optimizer: " .. stmt[1])
			end
			i = i + 1
		end

		-- Erase no-ops.

		local j = 1
		for i = 1, #stmts do
			if stmts[i][1] ~= "nop" then
				stmts[j] = stmts[i]
				j = j + 1
			end
		end
		for i = j, #stmts do
			stmts[i] = nil
		end
	end

	local function kill_cst_noises (stmts)
		local noiseqtys = {}
		local qtypdl = {}
		for i = 1, #stmts do
			local stmt = stmts[i]

			if stmt[1] == "if" or stmt[1] == "ifnot" then
				-- Open a new scope.
				qtypdl[#qtypdl + 1] = noiseqtys
				noiseqtys = copy (noiseqtys)
			elseif stmt[1] == "loadnoise" then
				if noiseqtys[stmt[3]] then
					stmt[1] = "move"
					stmt[3] = noiseqtys[stmt[3]]
				else
					local qty = stmt[3]
					noiseqtys[qty] = stmt[2]

					for _, parent in ipairs (qtypdl) do
						parent[qty] = nil
					end
				end
			elseif stmt[1] == "end" then
				assert (#qtypdl >= 1)
				noiseqtys = qtypdl[#qtypdl]
				qtypdl[#qtypdl] = nil
			end
		end
	end

	local function propagate_copies (stmts)
		local qtycopies = {}
		local qtypdl = {}

		local function delete_copies (val)
			for i, valno in ipairs (qtycopies) do
				if valno == val then
					qtycopies[i] = nil
				end
			end
			for _, copies in ipairs (qtypdl) do
				for i, valno in ipairs (copies) do
					if valno == val then
						copies[i] = nil
					end
				end
			end
		end

		for i = 1, #stmts do
			local stmt = stmts[i]

			if stmt[1] == "if" or stmt[1] == "ifnot" then
				if qtycopies[stmt[2]] then
					stmt[2] = qtycopies[stmt[2]]
				end

				-- Create a new scope.
				qtypdl[#qtypdl + 1] = qtycopies
				qtycopies = copy (qtycopies)
			elseif stmt[1] == "newname" then
				qtycopies[stmt[2]] = false
			elseif stmt[1] == "move" then
				if qtycopies[stmt[3]] then
					stmt[3] = qtycopies[stmt[3]]
				end
				qtycopies[stmt[2]] = stmt[3]
			elseif stmt[1] == "setrange"
				or stmt[1] == "bandlands" then
				if qtycopies[stmt[3]] then
					stmt[3] = qtycopies[stmt[3]]
				end
				qtycopies[stmt[2]] = false
				delete_copies (stmt[2])
			elseif stmt[1] == "settrue"
				or stmt[1] == "setfalse"
				or stmt[1] == "set"
				or stmt[1] == "callproc"
				or stmt[1] == "not"
				or stmt[1] == "loadnoise" then
				qtycopies[stmt[2]] = false
				delete_copies (stmt[2])
			elseif stmt[1] == "end" then
				assert (#qtycopies >= 1)
				qtycopies = qtypdl[#qtypdl]
				qtypdl[#qtypdl] = nil
			else
				error ("Stmt not known to optimizer: " .. stmt[1])
			end
		end
	end

	-- Create "else" stmts for blocks whose condition is known
	-- to be true upon completion of a preceding block
	local function merge_ifs ()
		local qtys = {}
		local qtypdl = {}
		local lastqtys = {}
		local ifqtys = {}

		local i = 1
		while i <= #stmts do
			local stmt = stmts[i]
			if stmt[1] == "newname" then
				qtys[stmt[2]] = false
				for _, parent in ipairs (qtypdl) do
					if parent[stmt[2]] ~= false then
						parent[stmt[2]] = nil
					end
				end
				lastqtys = nil
			elseif stmt[1] == "setfalse" then
				qtys[stmt[2]] = false
				for _, parent in ipairs (qtypdl) do
					if parent[stmt[2]] ~= false then
						parent[stmt[2]] = nil
					end
				end
				lastqtys = nil
			elseif stmt[1] == "move" then
				qtys[stmt[2]] = qtys[stmt[3]]
				for _, parent in ipairs (qtypdl) do
					if parent[stmt[2]] ~= qtys[stmt[3]] then
						parent[stmt[2]] = nil
					end
				end
				lastqtys = nil
			elseif stmt[1] == "loadnoise"
				or stmt[1] == "bandlands"
				or stmt[1] == "settrue"
				or stmt[1] == "set" then
				qtys[stmt[2]] = true
				for _, parent in ipairs (qtypdl) do
					if parent[stmt[2]] ~= true then
						parent[stmt[2]] = nil
					end
				end
				lastqtys = nil
			elseif stmt[1] == "callproc" or stmt[1] == "not"
				or stmt[1] == "setrange" then
				qtys[stmt[2]] = nil
				for _, parent in ipairs (qtypdl) do
					parent[stmt[2]] = nil
				end
				lastqtys = nil
			else
				-- Control flow.
				if stmt[1] == "if" or stmt[1] == "ifnot" then
					local term = endif (stmts, i)
					-- Create a new scope and save
					-- the existing.
					local qtys1 = copy (qtys)
					qtypdl[#qtypdl + 1], qtys = qtys, qtys1

					-- The conditional must be
					-- true/false as the case may
					-- be.
					qtys[stmt[2]] = stmt[1] == "if"

					if lastqtys
						and not (ifqtys[stmts[i - 1]])
						and ((stmt[1] == "ifnot")
							== lastqtys[stmt[2]]) then
						-- Convert this expression into an `else'.
						stmt[1] = "else"
						stmt[2] = nil
						ifqtys[stmts[term]] = lastqtys
						for i = i, #stmts do
							stmts[i - 1] = stmts[i]
						end
						stmts[#stmts] = nil
						i = i - 1
					end
					lastqtys = nil
				elseif stmt[1] == "end" then
					assert (#qtypdl >= 1)
					lastqtys = qtys
					qtys, qtypdl[#qtypdl] = qtypdl[#qtypdl], nil

					local ifqtys = ifqtys[stmt]
					if ifqtys then
						-- If this stmt
						-- concludes an `else'
						-- branch, merge and
						-- assume its
						-- quantities with
						-- those of the block
						-- preceding it.

						for qty, val in pairs (ifqtys) do
							if lastqtys[qty] == val then
								qtys[qty] = val
							end
						end
					end
				else
					error ("Stmt not known to optimizer: " .. stmt[1])
				end
			end
			i = i + 1
		end
	end

	kill_dead_code (stmts)
	kill_cst_noises (stmts)
	kill_dead_assignments (stmts)
	kill_dead_code (stmts)
	propagate_copies (stmts)
	kill_dead_assignments (stmts)
	kill_dead_code (stmts)
	merge_ifs (stmts)

	local stmts = assemble_stmts (stmts)
	local args = {}

	table.sort (noises)
	table.sort (closures)

	for _, id in ipairs (noises) do
		table.insert (args, string.format ("n%04d", id))
	end
	for _, id in ipairs (closures) do
		table.insert (args, string.format ("c%04d", id))
	end
	local str = table.concat ({
		"return function (" .. table.concat (args, ",") .. ")",
		"local floor = math.floor",
		"local ceil = math.ceil",
		"local X = 1",
		"local Y = 2",
		"local Z = 3",
		"local BIOME_NAME = 4",
		"local PRELIMINARY_SURFACE_XZ00 = 5",
		"local PRELIMINARY_SURFACE_XZ10 = 6",
		"local PRELIMINARY_SURFACE_XZ01 = 7",
		"local PRELIMINARY_SURFACE_XZ11 = 8",
		"local HEIGHTMAP = 9",
		"local SURFACE_DEPTH = 10",
		"local STONE_DEPTH_BELOW = 11",
		"local STONE_DEPTH_ABOVE = 12",
		"local WATER_HEIGHT = 13",
		"local huge, inf = math.huge, math.huge",
		"return function (ctx, system)",
		stmts,
		string.format ("return val%04d", ret),
		"end",
		"end",
	}, "\n")
	local fn, err = loadstring (str)
	local closures_1 = {}
	for _, id in ipairs (noises) do
		table.insert (closures_1, captures[id])
	end
	for _, id in ipairs (closures) do
		table.insert (closures_1, captures[id])
	end
	if not fn then
		print ("Failed to compile surface rule for biome `" .. biome .. "':" .. err)
		print ("==================================================================")
		print (str)
		print ("==================================================================")
		error ("Could not compile surface rule.")
	end
	local fn = fn () (unpack (closures_1))
	if debug_surface_rules then
		print ("Compiled surface rule for biome `" .. biome .. "'")
		print ("=======================SURFACE RULE FUNCTION======================")
		print (str)
		if dump then
			print ("=========================CLOSURES & NOISES========================")
			print (dump (closures_1))
		end
		print ("==================================================================")
	end
	return fn, str
end

------------------------------------------------------------------------
-- Surface systems.
------------------------------------------------------------------------

local surface_system = {
	cid_white_terracotta = nil,
	cid_orange_terracotta = nil,
	cid_terracotta = nil,
	cid_yellow_terracotta = nil,
	cid_brown_terracotta = nil,
	cid_red_terracotta = nil,
	cid_light_gray_terracotta = nil,
	cid_packed_ice = nil,
	cid_snow_block = nil,
	cid_default_block = nil,
	sea_level = nil,
	level_height = nil,
	y_min = nil,
	mesa_bands = {},
	mesa_band_offset_noise = nil,
	rules = {},

	-- Bryce canyon pillars and iceberg noises.
	badlands_pillar_noise = nil,
	badlands_pillar_roof_noise = nil,
	badlands_surface_noise = nil,
	iceberg_pillar_noise = nil,
	iceberg_pillar_roof_noise = nil,
	iceberg_surface_noise = nil,
	rng = nil,
	surface_noise = nil,
	surface_secondary_noise = nil,
}

local function create_terracotta_bands_1 (rng, array, min_interval, cid)
	local lim = 6 + rng:next_within (10)
	for i = 0, lim - 1 do
		local length = min_interval + rng:next_within (3)
		local start = rng:next_within (#array)

		for i = start, mathmin (#array - 1, start + length - 1) do
			array[i + 1] = cid
		end
	end
end

local function create_terracotta_bands (self, rng)
	local array = {}
	for i = 1, 192 do
		array[i] = self.cid_terracotta
	end

	local i = 1
	while i <= 192 do
		local val = rng:next_within (5)
		i = i + val + 1
		if i <= 192 then
			array[i] = self.cid_orange_terracotta
		end
		i = i + 1
	end

	create_terracotta_bands_1 (rng, array, 1, self.cid_yellow_terracotta)
	create_terracotta_bands_1 (rng, array, 2, self.cid_brown_terracotta)
	create_terracotta_bands_1 (rng, array, 1, self.cid_red_terracotta)

	local white_cnt = 9 + rng:next_within (7)
	local idx = 1
	for i = 1, white_cnt do
		if idx > #array then
			break
		end

		array[idx] = self.cid_white_terracotta
		if idx >= 3 and rng:next_boolean () then
			array[idx - 1] = self.cid_light_gray_terracotta
		end
		if idx + 1 <= #array and rng:next_boolean () then
			array[idx + 1] = self.cid_light_gray_terracotta
		end

		idx = idx + rng:next_within (16) + 4
	end
	assert (#array == 192)

	if core then
		verbose_print ("*=*=  Terracotta bands  =*=*")
		for i = 1, #array do
			verbose_print (core.get_name_from_content_id (array[i]))
		end
	end

	for i = 1, #array do
		array[i] = encode_node (array[i], 0)
	end
	return array
end

function surface_system:initialize (preset)
	local getcid

	if core then
		getcid = core.get_content_id
	else
		local mincid = 50
		function getcid (name)
			if name == preset.default_block then
				return 3
			end
			mincid = mincid + 1
			return mincid - 1
		end
	end

	-- Load content IDs.
	self.cid_water = getcid ("mcl_core:water_source")
	self.cid_default_block = getcid (preset.default_block)
	self.cid_white_terracotta
		= getcid ("mcl_colorblocks:hardened_clay_white")
	self.cid_orange_terracotta
		= getcid ("mcl_colorblocks:hardened_clay_orange")
	self.cid_terracotta
		= getcid ("mcl_colorblocks:hardened_clay")
	self.cid_yellow_terracotta
		= getcid ("mcl_colorblocks:hardened_clay_yellow")
	self.cid_brown_terracotta
		= getcid ("mcl_colorblocks:hardened_clay_brown")
	self.cid_red_terracotta
		= getcid ("mcl_colorblocks:hardened_clay_red")
	self.cid_light_gray_terracotta
		= getcid ("mcl_colorblocks:hardened_clay_silver")
	self.cid_packed_ice = getcid ("mcl_core:packed_ice")
	self.cid_snow_block = getcid ("mcl_core:snowblock")

	-- Miscellaneous variables.
	self.sea_level = preset.sea_level
	self.level_height = preset.height
	self.min_y = preset.min_y

	-- Mesa biome bands.
	self.mesa_band_offset_noise = preset.noises.clay_bands_offset
	local clay_rng = preset.factory ("minecraft:clay_bands")
	self.mesa_bands = create_terracotta_bands (self, clay_rng)

	-- RNGs and noises.
	self.rng = preset.factory:create_reseedable ()
	self.surface_noise = preset.noises.surface
	self.surface_secondary_noise = preset.noises.surface_secondary
	self.badlands_pillar_noise = preset.noises.badlands_pillar
	self.badlands_pillar_roof_noise = preset.noises.badlands_pillar_roof
	self.badlands_surface_noise = preset.noises.badlands_surface
	self.iceberg_pillar_noise = preset.noises.iceberg_pillar
	self.iceberg_pillar_roof_noise = preset.noises.iceberg_pillar_roof
	self.iceberg_surface_noise = preset.noises.iceberg_surface
	self.legacy_rng = preset.use_legacy_random_source

	if preset.create_surface_rules then
		local rule_fns = {}
		self.rule_fns = rule_fns
		local rules = preset:create_surface_rules ()
		for _, biome in ipairs (preset:generated_biomes ()) do
			rule_fns[biome]
				= mcl_levelgen.compile_surface_rule (rules, biome, self)
		end
	end
end

function mcl_levelgen.make_surface_system (preset)
	local values = table.copy (surface_system)
	values:initialize (preset)
	return values
end

------------------------------------------------------------------------
-- Surface system processing.
------------------------------------------------------------------------

local bindex = mcl_levelgen.biome_table_index
local abs = math.abs
local ceil = math.ceil
local decode_node = mcl_levelgen.decode_node
local pack_height_map = mcl_levelgen.pack_height_map

-- luacheck: push ignore 581

local function build_bryce_formations (self, x, z, dx, dz, surface_y, heightmap,
				       nodes, chunksize)
	local surface = self.badlands_surface_noise
	local pillar = self.badlands_pillar_noise
	local roof = self.badlands_pillar_roof_noise
	local level_height = self.level_height
	local cid_water = self.cid_water
	local cid_default_block = self.cid_default_block

	local selector
		= mathmin (abs (surface (x, 0, z) * 8.25),
			   pillar (x * 0.2, 0, z * 0.2) * 15.0)
	if not (selector <= 0.0) then
		local height = abs (roof (x * 0.75, 0, z * 0.75) * 1.5)
		local height_adj = mathmin (selector * selector * 2.5,
					    ceil (height * 50.0) + 24.0)
		height_adj = floor (height_adj) + 128

		local index = (dx * level_height + surface_y)
			* chunksize + dz + 1
		if surface_y <= height_adj then
			-- Detect any water between the surface of the
			-- level and the first solid surface.  Punt if
			-- any should be encountered.

			for y = 0, surface_y - 1 do
				local cid, _ = decode_node (nodes[index])
				if cid == cid_water then
					return surface_y
				elseif cid == cid_default_block then
					break
				end
				index = index - chunksize
			end

			local height = mathmin (height_adj, level_height)
			local index = (dx * level_height + height)
				* chunksize + dz + 1
			local default = encode_node (cid_default_block, 0)
			for y = 0, height do
				if decode_node (nodes[index]) ~= cid_air then
					break
				end
				nodes[index] = default
				index = index - chunksize
			end

			-- Update the heightmap.
			local idx = dx * chunksize + dz + 1
			heightmap[idx] = pack_height_map (height + 1,
							  height + 1)
			return height + 1
		end
	end
	return surface_y
end

local toquart = mcl_levelgen.toquart
local context = {}

local function rtz (n)
	if n < 0 then
		return ceil (n)
	end
	return floor (n)
end

local function compute_surface_depth (self, x, z)
	local rng = self.rng
	local value = self.surface_noise (x, 0, z)
	rng:reseed_positional (x, 0, z)
	return rtz (value * 2.75 + 3.0 + rng:next_double () * 0.25)
end

local function update_surface_ctx (self, context, x, z, terrain, update_cache)
	context[X] = x
	context[Z] = z

	-- Update surface depth.
	context[SURFACE_DEPTH] = compute_surface_depth (self, x, z)

	-- Update the preliminary surface depth variables if it
	-- appears appropriate or if invoked from a carver (in which
	-- event there is no guarantee that the request appertains to
	-- the last section to be processed).
	if band (z, 0xf) == 0 or update_cache then
		if update_cache then
			z = band (z, -16)
		end

		local x = band (x, -16)
		context[PRELIMINARY_SURFACE_XZ00]
			= terrain:get_preliminary_surface_level (x, z)
		context[PRELIMINARY_SURFACE_XZ01]
			= terrain:get_preliminary_surface_level (x, z + 16)
		context[PRELIMINARY_SURFACE_XZ10]
			= terrain:get_preliminary_surface_level (x + 16, z)
		context[PRELIMINARY_SURFACE_XZ11]
			= terrain:get_preliminary_surface_level (x + 16, z + 16)
	end
end

local function update_surface_ctx_y (self, context, solid_blocks_from_air,
				     dist_to_bottom_ceiling, liquid_top, y, biome)
	context[Y] = y
	context[STONE_DEPTH_ABOVE] = solid_blocks_from_air
	context[STONE_DEPTH_BELOW] = dist_to_bottom_ceiling
	context[WATER_HEIGHT] = liquid_top
	context[BIOME_NAME] = biome
end

function surface_system:get_secondary_surface (x, z)
	return self.surface_secondary_noise (x, 0, z)
end

local munge_biome_coords = mcl_levelgen.munge_biome_coords
local seed = nil

local function munge_biome_index (x, y, z, level_min, bx, bz)
	local qx, qy, qz = munge_biome_coords (seed, x, y, z)
	qy = qy - toquart (level_min)
	return qx - toquart (bx), qy, qz - toquart (bz)
end

local get_temperature_in_biome = mcl_levelgen.get_temperature_in_biome

local function build_icebergs (self, preliminary_surface, biome, nodes,
			       absx, absz, surface_y, heightmap, idx,
			       heightmap_idx)
	local surface = self.iceberg_surface_noise
	local pillar = self.iceberg_pillar_noise
	local pillar_roof = self.iceberg_pillar_roof_noise
	local selector
		= mathmin (abs (surface (absx, 0.0, absz) * 8.25),
			   pillar (absx * 1.28, 0.0, absz * 1.28) * 15.0)
	if not (selector <= 1.8) then
		local roof = abs (pillar_roof (absx * 1.17, 0.0, absz * 1.17) * 1.5)
		local height = mathmin (selector * selector * 1.2,
					ceil (roof * 40.0) + 14.0)
		local temp_at_sea_level
			= get_temperature_in_biome (biome, absx, 63, absz)
		if temp_at_sea_level > 0.1 then
			height = height - 2.0
		end

		local sea_level = self.sea_level
		local topy, ymin
		if height > 2.0 then
			topy = rtz (height + sea_level)
			ymin = rtz (sea_level - height - 7)
		else
			topy = 0
			ymin = 0
		end

		local rng = self.rng
		rng:reseed_positional (absx, 0, absz)
		local snowdepth = 2 + rng:next_within (4)
		local level_min = self.min_y
		local snow_min = sea_level + 18 + rng:next_within (10)
		local snow = encode_node (self.cid_snow_block, 0)
		local packed_ice = encode_node (self.cid_packed_ice, 0)

		for y = mathmax (surface_y + level_min, topy + 1), preliminary_surface, -1 do
			local height = y - level_min
			local i = idx + height * steep_chunksize
			if (decode_node (nodes[i]) == cid_air
			    and y < topy
			    and rng:next_double () > 0.01)
				or (decode_node (nodes[i]) == cid_water_source
				    and ymin ~= 0.0 and y > ymin and y < sea_level
				    and rng:next_double () > 0.15) then
				if snowdepth >= 0 and y > snow_min then
					nodes[i] = snow
					snowdepth = snowdepth - 1
				else
					nodes[i] = packed_ice
				end

				-- Update the heightmap.
				if height >= surface_y then
					heightmap[heightmap_idx] = pack_height_map (height + 1,
										    height + 1)
					surface_y = height + 1
				end
			end
		end
	end
end

-- luacheck: pop

function surface_system:post_process (terrain, x, y, z, nodes, heightmap, chunksize, biomes)
	steep_chunksize = chunksize
	steep_x_origin = x
	steep_z_origin = z
	seed = terrain.biome_seed
	local legacy_rng = self.legacy_rng
	local height_mul = legacy_rng and 0 or 1
	local level_height = self.level_height
	local level_min = self.min_y
	local context = context

	context[HEIGHTMAP] = heightmap
	for dx = 0, chunksize - 1 do
		for dz = 0, chunksize - 1 do
			local absx = x + dx
			local absz = z + dz
			local surface, _
				= unpack_height_map (heightmap[dx * chunksize + dz + 1])
			local test_location = surface * height_mul + level_min
			local chunk_quart = toquart (chunksize)
			local level_height_chunk = toquart (level_height)
			local idx
			do
				local ix, iy, iz = munge_biome_index (absx,
								      test_location,
								      absz,
								      level_min,
								      x, z)
				idx = bindex (ix, iy, iz, chunk_quart,
					      level_height_chunk,
					      chunk_quart)
			end
			local biome = biomes[idx]

			if biome == "ErodedMesa" then
				surface = build_bryce_formations (self, absx, absz, dx, dz,
								  surface, heightmap, nodes,
								  chunksize)
			end

			-- Begin iteration.
			update_surface_ctx (self, context, absx, absz, terrain, false)
			local solid_blocks_from_air = 0
			local liquid_top = -huge
			local cave_ceiling_pos = huge
			local idx = dx * chunksize * level_height + dz + 1
			local cid_default_block = self.cid_default_block

			for y = mathmin (surface, level_height - 1), 0, -1 do
				local i = idx + chunksize * y
				local node, _ = decode_node (nodes[i])
				if node == cid_air then
					solid_blocks_from_air = 0
					liquid_top = -huge
				elseif node == cid_water_source
					or node == cid_lava_source
					or node == cid_nether_lava_source then
					if liquid_top == -huge then
						liquid_top = y + 1
					end
				else
					if cave_ceiling_pos >= y then
						cave_ceiling_pos = -huge
						for ty = y - 1, 0, -1 do
							local i = idx + chunksize * ty
							local node, _ = decode_node (nodes[i])

							-- If this node is not a solid,
							if not (node ~= cid_air
								and node ~= cid_water_source
								and node ~= cid_lava_source
								and node ~= cid_nether_lava_source) then
								-- designate the node above the "surface below."
								cave_ceiling_pos = ty + 1
								break
							end
						end
					end
					solid_blocks_from_air = solid_blocks_from_air + 1
					local dist_to_bottom_ceiling = y - cave_ceiling_pos + 1

					if node == cid_default_block then
						local idx
						do
							local ix, iy, iz
								= munge_biome_index (absx,
										     y + level_min,
										     absz,
										     level_min,
										     x, z)
							idx = bindex (ix, iy, iz,
								      chunk_quart,
								      level_height_chunk,
								      chunk_quart)
						end
						local biome = biomes[idx]
						update_surface_ctx_y (self, context,
								      solid_blocks_from_air,
								      dist_to_bottom_ceiling,
								      liquid_top + level_min,
								      y + level_min, biome)
						local fn = self.rule_fns[biome]
						local node = fn (context, self)
						if node then
							nodes[i] = node
						end
					end
				end
			end

			if biome == "FrozenOcean" or biome == "DeepFrozenOcean" then
				local level = get_min_surface_level (context, self)
				local idx = dx * chunksize * level_height + dz + 1
				local heightmap_idx = dx * chunksize + dz + 1
				build_icebergs (self, level, biome, nodes, absx, absz,
						surface, heightmap, idx, heightmap_idx)
			end
		end
	end
end

local carver_biomes
local carver_bx, carver_bz, carver_chunksize, carver_terrain

function surface_system:initialize_for_carver (biomes, heightmap, bx, bz, chunksize,
					       terrain)
	carver_biomes = biomes
	carver_bx = bx
	carver_bz = bz
	carver_chunksize = toquart (chunksize)
	carver_terrain = terrain
	context[HEIGHTMAP] = heightmap
end

function surface_system:evaluate_for_carver (x, y, z, submerged)
	local level_min = self.min_y
	local level_height_chunk = toquart (self.level_height)
	local ix, iy, iz = munge_biome_index (x, y, z, level_min,
					      carver_bx, carver_bz)
	local idx = bindex (ix, iy, iz, carver_chunksize,
			    level_height_chunk,
			    carver_chunksize)
	local biome = carver_biomes[idx]
	local fn = self.rule_fns[biome]
	update_surface_ctx (self, context, x, z, carver_terrain, true)
	update_surface_ctx_y (self, context, 1, 1,
			      submerged and y + 1 or -huge, y, biome)
	return fn (context, self)
end
