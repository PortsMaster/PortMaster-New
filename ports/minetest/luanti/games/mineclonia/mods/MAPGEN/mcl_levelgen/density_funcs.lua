local ipairs = ipairs

if not table.copy then
	local function table_copy(value, preserve_metatables)
		local seen = {}
		local function copy(val)
			if type(val) ~= "table" then
				return val
			end
			local t = val
			if seen[t] then
				return seen[t]
			end
			local res = {}
			seen[t] = res
			for k, v in pairs(t) do
				res[copy(k)] = copy(v)
			end
			if preserve_metatables then
				setmetatable(res, getmetatable(t))
			end
			return res
		end
		return copy(value)
	end

	-- luacheck: push ignore 122
	function table.copy(value)
		return table_copy(value, false)
	end
	-- luacheck: pop
end

if not table.merge then
	dofile ("../../CORE/mcl_util/table.lua")
end

------------------------------------------------------------------------
-- Density functions.
------------------------------------------------------------------------

-- Density functions are expected to expose a uniform interface so
-- that they may be composed and invoked with a semblance of reason.
--
-- Each density function should be a table whose __call metamethod
-- takes at least four arguments X Y Z and BLENDER, and returns a
-- density value as a double.  This table should also contain the
-- following functions:
--
--   self:fill (ARRAY, N, PROVIDER, PROVIDER_DATA) Fill ARRAY with N
--   values whose contexts are obtained by calling PROVIDER with
--   0-based indices into the same ARRAY and PROVIDER_DATA.
--
--   self:petrify ()
--   Return a closure equivalent to `__call' but with all state copied
--   into upvalues to avoid hash table specialization that inflates
--   code size.
--
--   self:wrap (APPLICATOR, NOISE_VISITOR)
--   Apply APPLICATOR to this density function and return its value,
--   substituting density functions derived in like manner for each of
--   its operands and noises produced by applying NOISE_VISITOR to each
--   operand which is a noise for such operands, if any.
--
--   self:min_value ()
--   self:max_value ()
--   Return the minimum or maximum value that may be returned by
--   __call or stored by `fill' as the case may be.

------------------------------------------------------------------------
-- Abstract density function.
------------------------------------------------------------------------

local density_function = {
	name = "undefined",
}

function density_function:__call (x, y, z, blender)
	-- Not implemented.
	error ("Unimplemented: __call")
end

local function clone_function (fn)
	if not debug.upvaluejoin then
		return fn
	end

	-- Luajit-specific optimization: creating a new GCproto
	-- compels values of a solitary closure created from it to be
	-- specialized to itself.  It may be a win to implement this
	-- more portably by means of print and loadstring.
	local dumped = string.dump (fn)
	local cloned = loadstring (dumped)
	if cloned then
		local i = 1
		while true do
			local name = debug.getupvalue (fn, i)
			if not name then
				break
			end
			debug.upvaluejoin (cloned, i, fn, i)
			i = i + 1
		end
		return cloned
	end
	return fn
end

function density_function:petrify ()
	return self:petrify_and_clone ({})
end

function density_function:petrify_and_clone (visited)
	if visited[self] then
		return visited[self]
	end

	local fn = self:petrify_internal (visited)
	local value = clone_function (fn)
	visited[self] = value
	return value
end

function density_function:petrify_internal (visited)
	error ("Unimplemented: petrify_internal")
end

function density_function:fill (array, n, provider, provider_data)
	for i = 0, n - 1 do
		array[i + 1] = self (provider (i, provider_data))
	end
end

function density_function:wrap (applicator, noise_visitor)
	local visited = {}
	local wrapped = self:wrap_internal (applicator,
					    noise_visitor,
					    visited)
	return wrapped, visited
end

function density_function:wrap_internal (applicator, noise_visitor, visited)
	if visited[self] then
		return visited[self]
	end
	local val = applicator (self)
	visited[self] = val
	return val
end

local function make_density_function (tbl)
	for k, value in pairs (density_function) do
		if not tbl[k] then
			tbl[k] = value
		end
	end
	setmetatable (tbl, tbl)
	return tbl
end

mcl_levelgen.density_function = density_function
mcl_levelgen.make_density_function = make_density_function

function mcl_levelgen.wrap_petrify_multiple (applicator, noise_visitor, funcs)
	local visited = {}
	local petrified = {}
	local values = {}
	for _, fn in ipairs (funcs) do
		local wrapped = fn:wrap_internal (applicator,
						  noise_visitor,
						  visited)
		table.insert (values, wrapped:petrify_and_clone (petrified))
	end
	return unpack (values)
end

------------------------------------------------------------------------
-- Unary transformers.  `input' must be a density function whose
-- output is to be transformed.
------------------------------------------------------------------------

local transformer = {
	input = nil,
	transform = nil,
}

function transformer:__call (x, y, z, blender)
	local value = self.input (x, y, z, blender)
	return self:transform (x, y, z, blender, value)
end

function transformer:fill (array, n, provider, provider_data)
	self.input:fill (array, n, provider, provider_data)
	for i = 1, n do
		local x, y, z, blender = provider (i - 1, provider_data)
		array[i] = self:transform (x, y, z, blender, array[i])
	end
end

------------------------------------------------------------------------
-- Minecraft-style two-sampler noise.
------------------------------------------------------------------------

local wrap = mcl_levelgen.wrap_around_world_border

local old_blended_noise = {
	lower_noise = nil,
	upper_noise = nil,
	base_noise = nil,
	xz_scale = nil,
	y_scale = nil,
	xz_factor = nil,
	y_factor = nil,
	xz_multiplier = nil,
	y_multiplier = nil,
	smear_scale_multiplier = nil,
}

local function call_blended_noise (x, y, z, xz_multiplier, y_multiplier,
				   xz_factor, y_factor,
				   smear_scale_multiplier, base_noise,
				   lower_noise, upper_noise)
	local x = x * xz_multiplier
	local y = y * y_multiplier
	local z = z * xz_multiplier

	local mainx = x / xz_factor
	local mainy = y / y_factor
	local mainz = z / xz_factor

	local smear_scale = y_multiplier * smear_scale_multiplier
	local yscale = smear_scale / y_factor

	local base_value = 0.0
	local scale = 1.0
	local base_noise = base_noise

	for i = 0, 7 do
		local wx = wrap (mainx * scale)
		local wy = wrap (mainy * scale)
		local wz = wrap (mainz * scale)
		local ys = yscale * scale
		local ymax = mainy * scale
		local octave = base_noise.get_octave (i)
		if octave then
			local v	= octave (wx, wy, wz, ys, ymax, false) / scale
			base_value = base_value + v
		end

		scale = scale / 2.0
	end

	-- Scale base value for interpolation.  Formula source:
	-- https://bugs.mojang.com/browse/MC/issues/MC-219762 which is
	-- stated to be CC0 and appears exactly identical to that used
	-- by Minecraft.
	base_value = (base_value / 10.0 + 1.0) / 2.0
	local lovalue = 0.0
	local hivalue = 0.0
	local scale = 1.0
	local lower_noise = lower_noise
	local upper_noise = upper_noise
	local overflow = base_value >= 1.0
	local underflow = base_value <= 0.0

	for i = 0, 15 do
		local wx = wrap (x * scale)
		local wy = wrap (y * scale)
		local wz = wrap (z * scale)
		local ys = smear_scale * scale
		local ymax = y * scale

		if not overflow then
			local octave = lower_noise.get_octave (i)
			if octave then
				local value = octave (wx, wy, wz, ys, ymax, false)
					/ scale
				lovalue = lovalue + value
			end
		end

		if not underflow then
			local octave = upper_noise.get_octave (i)
			if octave then
				local value = octave (wx, wy, wz, ys, ymax, false)
					/ scale
				hivalue = hivalue + value
			end
		end

		scale = scale / 2.0
	end

	if underflow then
		-- Use lower limit noise.
		return lovalue / 512.0 / 128.0
	elseif overflow then
		-- Use upper limit noise
		return hivalue / 512.0 / 128.0
	else
		-- Linearly interpolate by the base noise between the
		-- limit noises.
		lovalue = lovalue / 512.0
		hivalue = hivalue / 512.0
		local x = lovalue + base_value * (hivalue - lovalue)
		return x / 128.0
	end
end

function old_blended_noise:__call (x, y, z, blender)
	return call_blended_noise (x, y, z, self.xz_multiplier,
				   self.y_multiplier,
				   self.xz_factor,
				   self.y_factor,
				   self.smear_scale_multiplier,
				   self.base_noise, self.lower_noise,
				   self.upper_noise)
end

function old_blended_noise:petrify_internal (visited)
	local xz_multiplier = self.xz_multiplier
	local y_multiplier = self.y_multiplier
	local smear_scale_multiplier = self.smear_scale_multiplier
	local xz_factor = self.xz_factor
	local y_factor = self.y_factor
	local base_noise = self.base_noise
	local lower_noise = self.lower_noise
	local upper_noise = self.upper_noise
	return function (x, y, z, blender)
		return call_blended_noise (x, y, z, xz_multiplier,
					   y_multiplier,
					   xz_factor, y_factor,
					   smear_scale_multiplier,
					   base_noise, lower_noise,
					   upper_noise)
	end
end

function old_blended_noise:min_value ()
	return -self:max_value ()
end

function old_blended_noise:max_value ()
	return self._max_value
end

function old_blended_noise:with_new_rng (rng)
	return mcl_levelgen.make_old_blended_noise (rng, self.xz_scale,
						    self.y_scale,
						    self.xz_factor,
						    self.y_factor,
						    self.smear_scale_multiplier)
end

-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/util/math/noise/InterpolatedNoiseSampler.html
-- https://minecraft.wiki/w/Density_function#old_blended_noise
function mcl_levelgen.make_old_blended_noise (lower_noise, upper_noise, base_noise,
					      xz_scale, y_scale, xz_factor, y_factor,
					      smear_scale_multiplier)
	local values = table.merge (old_blended_noise, {
		lower_noise = lower_noise,
		upper_noise = upper_noise,
		base_noise = base_noise,
		xz_scale = xz_scale,
		y_scale = y_scale,
		xz_factor = xz_factor,
		y_factor = y_factor,
		smear_scale_multiplier = smear_scale_multiplier,
		xz_multiplier = 684.412 * xz_scale,
		y_multiplier = 684.412 * y_scale,
		_max_value = lower_noise.get_max_value (684.412 * y_scale + 2.0),
	})
	return make_density_function (values)
end

function mcl_levelgen.make_blended_noise_from_parms (rng, xz_scale, y_scale, xz_factor,
						     y_factor, smear_scale_multiplier)
	local limit_octave_amplitudes = {
		1.0, 1.0, 1.0, 1.0,
		1.0, 1.0, 1.0, 1.0,
		1.0, 1.0, 1.0, 1.0,
		1.0, 1.0, 1.0, 1.0,
	}
	local main_noise_amplitudes = {
		1.0, 1.0, 1.0, 1.0,
		1.0, 1.0, 1.0, 1.0,
	}
	if not rng then
		local seedlo = mcl_levelgen.ull (0, 0)
		local seedhi = mcl_levelgen.ull (0, 0)
		mcl_levelgen.seed_from_ull (seedlo, seedhi, mcl_levelgen.ull (0, 0))
		mcl_levelgen.mix64 (seedlo)
		mcl_levelgen.mix64 (seedhi)
		rng = mcl_levelgen.xoroshiro (seedlo, seedhi)
	end
	local lower_noise
		= mcl_levelgen.make_noise (rng, -15, limit_octave_amplitudes, false)
	local upper_noise
		= mcl_levelgen.make_noise (rng, -15, limit_octave_amplitudes, false)
	local main_noise
		= mcl_levelgen.make_noise (rng, -7, main_noise_amplitudes, false)
	return mcl_levelgen.make_old_blended_noise (lower_noise, upper_noise, main_noise,
						    xz_scale, y_scale, xz_factor, y_factor,
						    smear_scale_multiplier)
end

-- luacheck: push ignore 511
if false then
	local noise = mcl_levelgen.make_blended_noise_from_parms (nil, 80.0, 0.25, 160.0, 0.125, 8.0)
	print ("Max value: " .. noise:max_value ());
	local time = os.clock ()
	for y = 0, 15 do
		for x = 0, 15 do
			for z = 0, 15 do
				noise (x, y, z)
			end
		end
	end
	print (math.floor ((os.clock () - time) * 1000 + 0.5) .. " ms")
end
-- luacheck: pop

------------------------------------------------------------------------
-- Predefined noise sampler.
------------------------------------------------------------------------

local noise_func = {
	noise = nil,
	xz_scale = nil,
	y_scale = nil,
}

function noise_func:__call (x, y, z, blender)
	return self.noise (x * self.xz_scale, y * self.y_scale,
			   z * self.xz_scale)
end

function noise_func:petrify_internal (visited)
	local xz_scale = self.xz_scale
	local y_scale = self.y_scale
	local noise = self.noise.get_value
	return function (x, y, z, blender)
		return noise (x * xz_scale, y * y_scale, z * xz_scale)
	end
end

function noise_func:max_value ()
	return self.noise.max_value
end

function noise_func:min_value ()
	return -self.noise.max_value
end

function noise_func:wrap_internal (applicator, noise_visitor, visited)
	if visited[self] then
		return visited[self]
	end
	local noise = noise_visitor (self.noise)
	local func = mcl_levelgen.make_noise_from_parms (noise,
							 self.xz_scale,
							 self.y_scale)
	local val = applicator (func)
	visited[self] = val
	return val
end

function mcl_levelgen.make_noise_from_parms (noise, xz_scale, y_scale)
	assert (xz_scale and y_scale)
	local values = table.merge (noise_func, {
		noise = noise,
		xz_scale = xz_scale,
		y_scale = y_scale,
	})
	return make_density_function (values)
end

------------------------------------------------------------------------
-- minecraft:blend_alpha
-- Purpose unknown.
------------------------------------------------------------------------

local blend_alpha = {}

function blend_alpha:__call (x, y, z, blender)
	return 1.0
end

function blend_alpha:petrify_internal (visited)
	return function (x, y, z, blender)
		return 1.0
	end
end

function blend_alpha:max_value ()
	return 1.0
end

function blend_alpha:min_value ()
	return 1.0
end

function mcl_levelgen.make_blend_alpha ()
	return make_density_function (blend_alpha)
end

------------------------------------------------------------------------
-- minecraft:blend_density
-- Purpose unknown.
------------------------------------------------------------------------

local blend_density = table.copy (transformer)

function blend_density:transform (x, y, z, blender, input)
	-- TODO: what is the purpose of this function?
	return input
end

function blend_density:petrify_internal (visited)
	return self.input:petrify_and_clone (visited)
end

function blend_density:max_value ()
	return 1.0
end

function blend_density:min_value ()
	return 1.0
end

function mcl_levelgen.make_blend_density (input)
	local values = table.merge (blend_density, {
		input = input,
	})
	return make_density_function (values)
end

------------------------------------------------------------------------
-- Terrain generation specific functions.
-- These functions are implemented as stubs and substituted for
-- functions whose values derive from level generation state as the
-- latter becomes available.
------------------------------------------------------------------------

local marker_func = {
	input = nil,
	is_marker = true,
	user_flags = nil,
	name = "", -- One of "interpolated", "flat_cache", "cache_2d",
		   -- or "cache_once".
}

function marker_func:__call (x, y, z, blender)
	return self.input (x, y, z, blender)
end

function marker_func:petrify_internal (visited)
	return self.input:petrify_and_clone (visited)
end

function marker_func:fill (array, n, provider, provider_data)
	return self.input:fill (array, n, provider, provider_data)
end

function marker_func:wrap_internal (applicator, noise_visitor, visited)
	if visited[self] then
		return visited[self]
	end
	local input = self.input:wrap_internal (applicator,
						noise_visitor,
						visited)
	local copy = mcl_levelgen.make_marker_func (self.name, input)
	copy.user_flags = self.user_flags
	local val = applicator (copy)
	visited[self] = val
	return val
end

function marker_func:min_value ()
	return self.input:min_value ()
end

function marker_func:max_value ()
	return self.input:max_value ()
end

function mcl_levelgen.make_marker_func (name, input)
	local values = table.merge (marker_func, {
		input = input,
		name = name,
	})
	return make_density_function (values)
end

------------------------------------------------------------------------
-- Binary operators with constants.
-- minecraft:add, minecraft:mul with constant values.
------------------------------------------------------------------------

local constop = table.merge (transformer, {
	constant = nil,
	_min_value = nil,
	_max_value = nil,
	name = "", -- "multiply" or "add".
})

function constop:transform (x, y, z, blender, value)
	if self.name == "multiply" then
		return value * self.constant
	else
		return value + self.constant
	end
end

function constop:petrify_internal (visited)
	local input = self.input:petrify_and_clone (visited)
	local constant = self.constant

	if self.name == "multiply" then
		local str = table.concat ({
			"return function (input)\n",
			"return function (x, y, z, blender)\n",
			string.format ("return input (x, y, z, blender) * %.7f\n",
				       constant),
			"end\n",
			"end\n",
		})
		return loadstring (str) () (input)
	else
		local str = table.concat ({
			"return function (input)\n",
			"return function (x, y, z, blender)\n",
			string.format ("return input (x, y, z, blender) + %.7f\n",
				       constant),
			"end\n",
			"end\n",
		})
		return loadstring (str) () (input)
	end
end

function constop:wrap_internal (applicator, noise_visitor, visited)
	if visited[self] then
		return visited[self]
	end

	local input = self.input:wrap_internal (applicator, noise_visitor, visited)
	local min = input:min_value ()
	local max = input:max_value ()
	local new_min, new_max

	if self.name == "add" then
		new_min = min + self.constant
		new_max = max + self.constant
	elseif self.name == "multiply" then
		local m1 = max * self.constant
		local m2 = min * self.constant
		new_max = math.max (m1, m2)
		new_min = math.min (m1, m2)
	else
		assert (false)
	end

	local val
		= mcl_levelgen.make_constop (self.name, input, new_min, new_max,
					     self.constant)
	visited[self] = applicator (val)
	return visited[self]
end

function constop:min_value ()
	return self._min_value
end

function constop:max_value ()
	return self._max_value
end

function mcl_levelgen.make_constop (op, input, min, max, constant)
	local values = table.merge (constop, {
		input = input,
		_min_value = min,
		_max_value = max,
		constant = constant,
		name = op,
	})
	return make_density_function (values)
end

------------------------------------------------------------------------
-- Non-constant binary operations.
-- minecraft:add, minecraft:mul, minecraft:min, minecraft:max
------------------------------------------------------------------------

local binop = {
	arg1 = nil,
	arg2 = nil,
	name = "", -- "add", "multiply", "min", "max",
	_min_value = nil,
	_max_value = nil,
}

local mathmin = math.min
local mathmax = math.max

function binop:__call (x, y, z, blender)
	local v1 = self.arg1 (x, y, z, blender)
	local op, v2 = self.name

	if op == "add" then
		v2 = self.arg2 (x, y, z, blender)
		return v1 + v2
	elseif op == "multiply" then
		if v1 == 0.0 then
			return 0.0
		end
		v2 = self.arg2 (x, y, z, blender)
		return v1 * v2
	elseif op == "min" then
		if v1 < self.arg2:min_value () then
			return v1
		end
		v2 = self.arg2 (x, y, z, blender)
		return mathmin (v1, v2)
	elseif op == "max" then
		-- Minecraft dispenses with the 2nd operand if
		-- the first value is out of its stated range.
		-- Not observing this convention produces some
		-- bizarre effects though the scenarios where
		-- this would be significant are not meant to
		-- be possible.
		if v1 > self.arg2:max_value () then
			return v1
		end
		v2 = self.arg2 (x, y, z, blender)
		return mathmax (v1, v2)
	end
end

function binop:petrify_internal (visited)
	local arg1 = self.arg1:petrify_and_clone (visited)
	local arg2 = self.arg2:petrify_and_clone (visited)
	local op = self.name

	if op == "add" then
		return function (x, y, z, blender)
			local a = arg1 (x, y, z, blender)
			local b = arg2 (x, y, z, blender)
			return a + b
		end
	elseif op == "multiply" then
		return function (x, y, z, blender)
			local a = arg1 (x, y, z, blender)
			if a == 0.0 then
				return 0.0
			end
			local b = arg2 (x, y, z, blender)
			return a * b
		end
	elseif op == "min" then
		local a2_min = self.arg2:min_value ()
		return function (x, y, z, blender)
			local a = arg1 (x, y, z, blender)
			if a < a2_min then
				return a
			end
			local b = arg2 (x, y, z, blender)
			return mathmin (a, b)
		end
	elseif op == "max" then
		local a2_max = self.arg2:max_value ()
		return function (x, y, z, blender)
			local a = arg1 (x, y, z, blender)
			if a > a2_max then
				return a
			end
			local b = arg2 (x, y, z, blender)
			return mathmax (a, b)
		end
	end
	assert (false)
end

function binop:fill (array, n, provider, provider_data)
	local op = self.name
	local array2 = {}
	array2[n] = nil
	self.arg1:fill (array, n, provider, provider_data)

	if op == "add" then
		self.arg2:fill (array2, n, provider, provider_data)
		for i = 0, n - 1 do
			local idx = i + 1
			array[idx] = array[idx] + array2[idx]
		end
	elseif op == "multiply" then
		for i = 0, n - 1 do
			local idx = i + 1
			local v1 = array[idx]
			if v1 ~= 0.0 then
				v1 = v1 * self.arg2 (provider (i, provider_data))
				array[idx] = v1
			end
		end
	elseif op == "min" then
		local min_2 = self.arg2:min_value ()
		for i = 0, n - 1 do
			local idx = i + 1
			local v1 = array[idx]
			-- luacheck: push ignore 581
			if not (v1 < min_2) then
			-- luacheck: pop
				local val = self.arg2 (provider (i, provider_data))
				v1 = mathmin (v1, val)
				array[idx] = v1
			end
		end
	elseif op == "max" then
		local max_2 = self.arg2:max_value ()
		for i = 0, n - 1 do
			local idx = i + 1
			local v1 = array[idx]
			-- luacheck: push ignore 581
			if not (v1 > max_2) then
			-- luacheck: pop
				local val = self.arg2 (provider (i, provider_data))
				v1 = mathmax (v1, val)
				array[idx] = v1
			end
		end
	end
end

function binop:min_value ()
	return self._min_value
end

function binop:max_value ()
	return self._max_value
end

function binop:wrap_internal (applicator, noise_visitor, visited)
	if visited[self] then
		return visited[self]
	end
	local arg1 = self.arg1:wrap_internal (applicator, noise_visitor, visited)
	local arg2 = self.arg2:wrap_internal (applicator, noise_visitor, visited)
	local binop = mcl_levelgen.make_binary_operation (self.name, arg1, arg2)
	local val = applicator (binop)
	visited[self] = val
	return val
end

function mcl_levelgen.make_binary_operation (op, arg1, arg2)
	local min1, min2 = arg1:min_value (), arg2:min_value ()
	local max1, max2 = arg1:max_value (), arg2:max_value ()

	if (op == "min" or op == "max")
		and (min1 >= max2 or min2 >= max1) then
		print ("Warning: creating a `" .. op .. "' binary operator "
		       .. "with operands of non-intersecting ranges...")
		print (debug.traceback ())
	end

	local min, max

	if op == "add" then
		min = min1 + min2
		max = max1 + max2
	elseif op == "multiply" then
		local v1 = min1 * min2
		local v2 = max1 * min2
		local v3 = min2 * max1
		local v4 = max2 * min1
		min = mathmin (v1, v2, v3, v4)
		max = mathmax (v1, v2, v3, v4)
	elseif op == "min" then
		min = mathmin (min1, min2)
		max = mathmin (max1, max2)
	elseif op == "max" then
		min = mathmax (min1, min2)
		max = mathmax (max1, max2)
	end

	if op == "add" or op == "multiply" then
		if arg1.name == "constant" then
			return mcl_levelgen.make_constop (op, arg2, min, max,
							  arg1.constant)
		elseif arg2.name == "constant" then
			return mcl_levelgen.make_constop (op, arg1, min, max,
							  arg2.constant)
		end
	end

	local values = table.merge (binop, {
		arg1 = arg1,
		arg2 = arg2,
		name = op,
		_max_value = max,
		_min_value = min,
	})
	return make_density_function (values)
end

------------------------------------------------------------------------
-- minecraft:end_islands
------------------------------------------------------------------------

local end_island_func = {
	noise = nil,
}

function end_island_func:min_value ()
	return -0.84375
end

function end_island_func:max_value ()
	return 0.5625
end

local ceil = math.ceil
local floor = math.floor
local fmod = math.fmod
local sqrt = math.sqrt
local abs = math.abs

local function round_to_zero (n)
	if n < 0 then
		return ceil (n)
	end
	return floor (n)
end

local function clamp (value, min, max)
	return mathmax (mathmin (value, max), min)
end

local function end_island_eval (noise, x, z)
	local xbase = round_to_zero (x / 2)
	local zbase = round_to_zero (z / 2)
	local xfrac = fmod (x, 2)
	local zfrac = fmod (z, 2)
	local density

	-- Generate a main end island at the center of the map.
	density = (x * x + z * z) * 64.0

	-- Generate outer islands after a distance of sqrt (4096) * 8
	-- blocks from the center of the map according to noise.
	for x = -12, 12 do
		for z = -12, 12 do
			local xcoord = xbase + x
			local zcoord = zbase + z

			if (xcoord * xcoord + zcoord * zcoord) > 4096.0
				and noise (xcoord, zcoord) < -0.9 then
				local period = abs (xcoord) * 3439
					+ abs (zcoord) * 147
				period = period % 13.0 + 9.0
				local x_local = xfrac - x * 2
				local z_local = zfrac - z * 2
				local local_dist = x_local * x_local + z_local * z_local
				density = mathmin (local_dist * period * period, density)
			end
		end
	end

	return clamp (100.0 - sqrt (density), -100.0, 80.0)
end

function end_island_func:__call (x, y, z, blender)
	local density = end_island_eval (self.noise,
					 round_to_zero (x / 8),
					 round_to_zero (z / 8))
	return (density - 8.0) / 128.0
end

function end_island_func:petrify_internal (visited)
	local noise = self.noise
	return function (x, y, z, blender)
		local density
			= end_island_eval (noise, round_to_zero (x / 8),
					   round_to_zero (z / 8))
		return (density - 8.0) / 128.0
	end
end

function mcl_levelgen.make_end_island_func (seed)
	local rng = mcl_levelgen.jvm_random (seed)
	rng:consume (17292)
	local noise = mcl_levelgen.simplex_octave (rng)
	local values = table.merge (end_island_func, {
		noise = noise,
	})
	return make_density_function (values)
end

-- luacheck: push ignore 511
if false then
	local seed = mcl_levelgen.ull (77209, 94883)
	local func = mcl_levelgen.make_end_island_func (seed)

	for x = -2048, 2048 do
		for z = -2048, 2048 do
			print (func (x, 0, z))
		end
	end
end
-- luacheck: pop

------------------------------------------------------------------------
-- minecraft:weird_scaled_sampler
------------------------------------------------------------------------

local weird_scaled_sampler = table.merge (transformer, {
	noise = nil,
	mapper = nil,
	_max_value = nil,
	mapper_type = "",
})

function weird_scaled_sampler:transform (x, y, z, blender, value)
	local val = self.mapper (value)
	return val * abs (self.noise (x / val, y / val, z / val))
end

function weird_scaled_sampler:petrify_internal (visited)
	local input = self.input:petrify_and_clone (visited)
	local mapper = self.mapper
	local noise = self.noise.get_value

	return function (x, y, z, blender)
		local value = input (x, y, z, blender)
		local val = mapper (value)
		return val * abs (noise (x / val, y / val, z / val))
	end
end

function weird_scaled_sampler:wrap_internal (applicator, noise_visitor, visited)
	if visited[self] then
		return visited[self]
	end
	local noise = noise_visitor (self.noise)
	local input = self.input:wrap_internal (applicator, noise_visitor, visited)
	local mapper_type = self.mapper_type
	local newself
		= mcl_levelgen.make_weird_scaled_sampler (mapper_type, noise, input)
	local val = applicator (newself)
	visited[self] = val
	return val
end

function weird_scaled_sampler:min_value ()
	return 0.0
end

function weird_scaled_sampler:max_value ()
	return self._max_value * self.noise.max_value
end

local function map_rarity_type_1 (val)
	if val < -0.5 then
		return 0.75
	elseif val < 0.0 then
		return 1.0
	elseif val < 0.5 then
		return 1.5
	else
		return 2.0
	end
end

local function map_rarity_type_2 (val)
	if val < -0.75 then
		return 0.5
	elseif val < -0.5 then
		return 0.75
	elseif val < 0.5 then
		return 1.0
	elseif val < 0.75 then
		return 2.0
	else
		return 3.0
	end
end

function mcl_levelgen.make_weird_scaled_sampler (rarity_value_mapper_type, noise, input)
	local mapper, max_value

	if rarity_value_mapper_type == "type_1" then
		mapper = map_rarity_type_1
		max_value = 2.0
	elseif rarity_value_mapper_type == "type_2" then
		mapper = map_rarity_type_2
		max_value = 3.0
	else
		error ("Nonexistent rarity value mapper: " .. rarity_value_mapper_type)
	end

	local values = table.merge (weird_scaled_sampler, {
		noise = noise,
		mapper = mapper,
		input = input,
		_max_value = max_value,
		mapper_type = rarity_value_mapper_type,
	})
	return make_density_function (values)
end

------------------------------------------------------------------------
-- minecraft:shifted_noise
------------------------------------------------------------------------

local shifted_noise = {
	shift_x = nil,
	shift_y = nil,
	shift_z = nil,
	xz_scale = nil,
	y_scale = nil,
	noise = nil,
}

function shifted_noise:__call (x, y, z, blender)
	local xz_scale = self.xz_scale
	local x1 = x * xz_scale + self.shift_x (x, y, z, blender)
	local y1 = y * self.y_scale + self.shift_y (x, y, z, blender)
	local z1 = z * xz_scale + self.shift_z (x, y, z, blender)
	return self.noise (x1, y1, z1)
end

function shifted_noise:petrify_internal (visited)
	local xz_scale = self.xz_scale
	local y_scale = self.y_scale
	local shift_x = self.shift_x:petrify_and_clone (visited)
	local shift_y = self.shift_y:petrify_and_clone (visited)
	local shift_z = self.shift_z:petrify_and_clone (visited)
	local noise = self.noise.get_value
	assert (noise)
	return function (x, y, z, blender)
		local x1 = x * xz_scale + shift_x (x, y, z, blender)
		local y1 = y * y_scale + shift_y (x, y, z, blender)
		local z1 = z * xz_scale + shift_z (x, y, z, blender)
		return noise (x1, y1, z1)
	end
end

function shifted_noise:wrap_internal (applicator, noise_visitor, visited)
	if visited[self] then
		return visited[self]
	end
	local xz_scale = self.xz_scale
	local y_scale = self.y_scale
	local shift_x = self.shift_x:wrap_internal (applicator, noise_visitor,
						    visited)
	local shift_y = self.shift_y:wrap_internal (applicator, noise_visitor,
						    visited)
	local shift_z = self.shift_z:wrap_internal (applicator, noise_visitor,
						    visited)
	local noise = noise_visitor (self.noise)
	local new = mcl_levelgen.make_shifted_noise (shift_x, shift_y,
						     shift_z, xz_scale,
						     y_scale, noise)
	local val = applicator (new)
	visited[self] = val
	return val
end

function shifted_noise:max_value ()
	return self.noise.max_value
end

function shifted_noise:min_value ()
	return -self:max_value ()
end

function mcl_levelgen.make_shifted_noise (shift_x, shift_y,
					  shift_z, xz_scale,
					  y_scale, noise)
	local values = table.merge (shifted_noise, {
		shift_x = shift_x,
		shift_y = shift_y,
		shift_z = shift_z,
		xz_scale = xz_scale,
		y_scale = y_scale,
		noise = noise,
	})
	return make_density_function (values)
end

------------------------------------------------------------------------
-- minecraft:range_choice
------------------------------------------------------------------------

local range_choice = {
	input = nil,
	min_inclusive = nil,
	max_exclusive = nil,
	when_in_range = nil,
	when_out_of_range = nil,
}

function range_choice:__call (x, y, z, blender)
	local value = self.input (x, y, z, blender)
	if value >= self.min_inclusive and value < self.max_exclusive then
		return self.when_in_range (x, y, z, blender)
	else
		return self.when_out_of_range (x, y, z, blender)
	end
end

function range_choice:petrify_internal (visited)
	local input = self.input:petrify_and_clone (visited)
	local min_inclusive = self.min_inclusive
	local max_exclusive = self.max_exclusive
	local when_in_range
		= self.when_in_range:petrify_and_clone (visited)
	local when_out_of_range
		= self.when_out_of_range:petrify_and_clone (visited)
	return function (x, y, z, blender)
		local value = input (x, y, z, blender)
		if value >= min_inclusive and value < max_exclusive then
			return when_in_range (x, y, z, blender)
		else
			return when_out_of_range (x, y, z, blender)
		end
	end
end

function range_choice:fill (array, n, provider, provider_data)
	self.input:fill (array, n, provider, provider_data)

	for i = 0, n - 1 do
		local idx = i + 1
		local value = array[idx]

		if value >= self.min_inclusive
			and value < self.max_exclusive then
			array[idx]
				= self.when_in_range (provider (i, provider_data))
		else
			array[idx]
				= self.when_out_of_range (provider (i, provider_data))
		end
	end
end

function range_choice:wrap_internal (applicator, noise_visitor, visited)
	if visited[self] then
		return visited[self]
	end
	local input, when_in_range, when_out_of_range, new
	input = self.input:wrap_internal (applicator, noise_visitor,
					  visited)
	when_in_range = self.when_in_range:wrap_internal (applicator,
							  noise_visitor,
							  visited)
	when_out_of_range = self.when_out_of_range:wrap_internal (applicator,
								  noise_visitor,
								  visited)
	new = mcl_levelgen.make_range_choice (input, self.min_inclusive,
					      self.max_exclusive,
					      when_in_range, when_out_of_range)
	local val = applicator (new)
	visited[self] = val
	return val
end

function range_choice:max_value ()
	local max1 = self.when_in_range:max_value ()
	local max2 = self.when_out_of_range:max_value ()
	return mathmax (max1, max2)
end

function range_choice:min_value ()
	local min1 = self.when_in_range:min_value ()
	local min2 = self.when_out_of_range:min_value ()
	return mathmin (min1, min2)
end

function mcl_levelgen.make_range_choice (input, min_inclusive, max_exclusive,
					 when_in_range, when_out_of_range)
	assert (input and when_in_range and when_out_of_range)
	local values = table.merge (range_choice, {
		input = input,
		min_inclusive = min_inclusive,
		max_exclusive = max_exclusive,
		when_in_range = when_in_range,
		when_out_of_range = when_out_of_range,
	})
	return make_density_function (values)
end

------------------------------------------------------------------------
-- minecraft:shift_a, minecraft:shift_b, minecraft:shift
------------------------------------------------------------------------

local shift_noise = {
	offset_noise = nil,
}

local function shift_noise_compute (offset_noise, x, y, z)
	local x = x * 0.25
	local y = y * 0.25
	local z = z * 0.25
	return offset_noise (x, y, z) * 4.0
end

function shift_noise:min_value ()
	return -self:max_value ()
end

function shift_noise:max_value ()
	return self.offset_noise.max_value * 4.0
end

-- minecraft:shift_a

local shift_a = table.copy (shift_noise)

function shift_a:__call (x, y, z, blender)
	return shift_noise_compute (self.offset_noise, x, 0, z)
end

function shift_a:petrify_internal (visited)
	local offset_noise = self.offset_noise
	return function (x, y, z, blender)
		return shift_noise_compute (offset_noise, x, 0, z)
	end
end

function shift_a:wrap_internal (applicator, noise_visitor, visited)
	if visited[self] then
		return visited[self]
	end
	local noise = noise_visitor (self.offset_noise)
	local new = mcl_levelgen.make_shift_a (noise)
	local val = applicator (new)
	visited[self] = val
	return val
end

function mcl_levelgen.make_shift_a (offset_noise)
	local values = table.merge (shift_a, {
		offset_noise = offset_noise,
	})
	return make_density_function (values)
end

-- minecraft:shift_b

local shift_b = table.copy (shift_noise)

function shift_b:__call (x, y, z, blender)
	return shift_noise_compute (self.offset_noise, z, x, 0)
end

function shift_b:petrify_internal (visited)
	local offset_noise = self.offset_noise
	return function (x, y, z, blender)
		return shift_noise_compute (offset_noise, z, x, 0)
	end
end

function shift_b:wrap_internal (applicator, noise_visitor, visited)
	if visited[self] then
		return visited[self]
	end
	local noise = noise_visitor (self.offset_noise)
	local new = mcl_levelgen.make_shift_b (noise)
	local val = applicator (new)
	visited[self] = val
	return val
end

function mcl_levelgen.make_shift_b (offset_noise)
	local values = table.merge (shift_b, {
		offset_noise = offset_noise,
	})
	return make_density_function (values)
end

-- minecraft:shift

local shift = table.copy (shift_noise)

function shift:__call (x, y, z, blender)
	return shift_noise_compute (self.offset_noise, x, y, z)
end

function shift:petrify_internal (visited)
	local offset_noise = self.offset_noise
	return function (x, y, z, blender)
		return shift_noise_compute (offset_noise, x, y, z)
	end
end

function shift:wrap_internal (applicator, noise_visitor, visited)
	if visited[self] then
		return visited[self]
	end
	local noise = noise_visitor (self.offset_noise)
	local new = mcl_levelgen.make_shift (noise)
	local val = applicator (new)
	visited[self] = val
	return val
end

function mcl_levelgen.make_shift (offset_noise)
	local values = table.merge (shift, {
		offset_noise = offset_noise,
	})
	return make_density_function (values)
end

------------------------------------------------------------------------
-- minecraft:clamp
------------------------------------------------------------------------

local clamp_func = table.merge (transformer, {
	input = nil,
	min = nil,
	max = nil,
})

function clamp_func:transform (x, y, z, blender, value)
	return clamp (value, self.min, self.max)
end

function clamp_func:petrify_internal (visited)
	local input = self.input:petrify_and_clone (visited)
	local min = self.min
	local max = self.max
	return function (x, y, z, blender)
		return clamp (input (x, y, z, blender), min, max)
	end
end

function clamp_func:min_value ()
	return self.min
end

function clamp_func:max_value ()
	return self.max
end

function clamp_func:wrap_internal (applicator, noise_visitor, visited)
	if visited[self] then
		return visited[self]
	end
	local new_input = self.input:wrap_internal (applicator,
						    noise_visitor,
						    visited)
	local val = mcl_levelgen.make_clamp (new_input, self.min, self.max)
	visited[self] = val
	return val
end

function mcl_levelgen.make_clamp (input, min, max)
	local values = table.merge (clamp_func, {
		input = input,
		min = min,
		max = max,
	})
	return make_density_function (values)
end

------------------------------------------------------------------------
-- Unary operators.
------------------------------------------------------------------------

local unary = table.merge (transformer, {
	name = "", -- "abs", "square", "cube", "half_negative",
		   -- "quarter_negative", or "squeeze".
	_min_value = nil,
	_max_value = nil,
})

function unary:min_value ()
	return self._min_value
end

function unary:max_value ()
	return self._max_value
end

local function unary_transform (op, val)
	if op == "abs" then
		return abs (val)
	elseif op == "square" then
		return val * val
	elseif op == "cube" then
		return val * val * val
	elseif op == "half_negative" then
		return val > 0.0 and val or val * 0.5
	elseif op == "quarter_negative" then
		return val > 0.0 and val or val * 0.25
	elseif op == "squeeze" then
		local clamped = clamp (val, -1.0, 1.0)
		return clamped / 2.0 - clamped * clamped * clamped / 24.0
	end
end

function unary:transform (x, y, z, blender, value)
	return unary_transform (self.name, value)
end

function unary:petrify_internal (visited)
	local input = self.input:petrify_and_clone (visited)
	local op = self.name
	if op == "abs" then
		return function (x, y, z, blender)
			return abs (input (x, y, z, blender))
		end
	elseif op == "square" then
		return function (x, y, z, blender)
			local val = input (x, y, z, blender)
			return val * val
		end
	elseif op == "cube" then
		return function (x, y, z, blender)
			local val = input (x, y, z, blender)
			return val * val * val
		end
	elseif op == "half_negative" then
		return function (x, y, z, blender)
			local val = input (x, y, z, blender)
			return val > 0.0 and val or val * 0.5
		end
	elseif op == "quarter_negative" then
		return function (x, y, z, blender)
			local val = input (x, y, z, blender)
			return val > 0.0 and val or val * 0.25
		end
	elseif op == "squeeze" then
		return function (x, y, z, blender)
			local val = input (x, y, z, blender)
			local clamped = clamp (val, -1.0, 1.0)
			return clamped / 2.0 - clamped * clamped * clamped / 24.0
		end
	end
	assert (false)
end

function unary:wrap_internal (applicator, noise_visitor, visited)
	if visited[self] then
		return visited[self]
	end
	local input = self.input:wrap_internal (applicator, noise_visitor,
						visited)
	local val = mcl_levelgen.make_unary_op (self.name, input)
	visited[self] = val
	return val
end

function mcl_levelgen.make_unary_op (op, input)
	local min_value, max_value
	-- Operations that are not abs and square preserve the sign of
	-- input values.
	if op == "square" or op == "abs" then
		min_value = unary_transform (op, input:min_value ())
		max_value = unary_transform (op, input:max_value ())
		local min, max = mathmax (0, input:min_value ()),
			mathmax (min_value, max_value)
		min_value, max_value = min, max
	else
		min_value = unary_transform (op, input:min_value ())
		max_value = unary_transform (op, input:max_value ())
	end
	local values = table.merge (unary, {
		name = op,
		input = input,
		_min_value = min_value,
		_max_value = max_value,
	})
	return make_density_function (values)
end

------------------------------------------------------------------------
-- ``Splines''.  When no ``derivative'' is specified, interpolation is
-- between segments is actually linear.
--
-- minecraft:spline
------------------------------------------------------------------------

-- Spline data structure.
-- Most of the apparent complexity is born of computing the min and
-- max values to which the spline is capable of evaluating.

local function interp_outsized_value (location, locations, value, derivatives, idx)
	local derv = derivatives[idx]
	if derv == 0.0 then
		return value
	end
	return value + derv * (location - locations[idx])
end

local function value_min (number_or_spline)
	if type (number_or_spline) == "number" then
		return number_or_spline
	else
		return number_or_spline.min_value
	end
end

local function value_max (number_or_spline)
	if type (number_or_spline) == "number" then
		return number_or_spline
	else
		return number_or_spline.max_value
	end
end

local function value_eval (number_or_spline, x, y, z, blender)
	if type (number_or_spline) == "number" then
		return number_or_spline
	else
		return number_or_spline (x, y, z, blender)
	end
end

local function lerp1d (u, s1, s2)
	return (s2 - s1) * u + s1
end

local function eval_spline_2 (loc_below, loc_above,
			      progress, sp_progress,
			      val_below, val_above,
			      deriv_below, deriv_above)
	local loc_diff = loc_above - loc_below
	local val_diff = val_above - val_below
	local dev_below = deriv_below * loc_diff - val_diff
	local dev_above = -deriv_above * loc_diff + val_diff
	return lerp1d (progress, val_below, val_above)
		+ (sp_progress * (1.0 - sp_progress)
		   * lerp1d (sp_progress, dev_below, dev_above))
end

local rshift = bit.rshift

local function eval_spline_1 (values, locations, derivatives,
			      coord_provider, x, y, z, blender)
	local location = coord_provider (x, y, z, blender)

	-- bsearch for the segment containg LOCATION.
	local min, max = 1, #locations + 1
	while max - min > 0 do
		local mid = min + rshift (max - min, 1)
		if locations[mid] >= location then
			max = mid
		else
			min = mid + 1
		end
	end

	if min == 1 then
		local value = value_eval (values[1], x, y, z, blender)
		return interp_outsized_value (location, locations, value,
					      derivatives, 1)
	elseif min > #locations then
		local value = value_eval (values[#values], x, y, z, blender)
		return interp_outsized_value (location, locations, value,
					      derivatives, #locations)
	else
		local i1, i2 = min - 1, min
		local loc_below = locations[i1]
		local loc_above = locations[i2]
		local val_below = value_eval (values[i1], x, y, z, blender)
		local val_above = value_eval (values[i2], x, y, z, blender)
		local deriv_below = derivatives[i1]
		local deriv_above = derivatives[i2]
		local progress = (location - loc_below) / (loc_above - loc_below)
		return eval_spline_2 (loc_below, loc_above, progress,
				      progress, val_below, val_above,
				      deriv_below, deriv_above)
	end
end

local function eval_spline (self, x, y, z, blender)
	local values = self.values
	local locations = self.locations
	local derivatives = self.derivatives
	local coord_provider = self.coordinate_provider
	return eval_spline_1 (values, locations, derivatives,
			      coord_provider, x, y, z, blender)
end

mcl_levelgen.eval_spline = eval_spline

local compile_splines = true
local spline_debug = false
local spline_id = 0

local function indexof (list, val)
	for i, v in ipairs (list) do
		if v == val then
			return i
		end
	end
	return -1
end

local function compile_spline (values, locations, derivatives,
			       coord_provider, x, y, z, blender)
	local strs = {
		"function (x, y, z, blender)\n",
		"local location = coord_provider (x, y, z, blender)\n"
	}
	local closures = {}
	spline_id = spline_id + 1

	local function assemble_value (value)
		if type (value) == "number" then
			return tostring (value)
		else
			local idx = indexof (closures, value)
			if idx ~= -1 then
				return string.format ("c%04d (x, y, z, blender)", idx)
			else
				local idx = #closures + 1
				closures[idx] = value
				return string.format ("c%04d (x, y, z, blender)", idx)
			end
		end
	end

	local function assemble_interp_outsized_value (locations, derivatives, idx)
		local derv = derivatives[idx]
		if derv == 0.0 then
			return string.format ("local k = s")
		end
		return string.format ("local k = s + %.7f * (location - %.7f)",
				      derv, locations[idx])
	end

	local function compile_one (min, max, values, locations, derivatives)
		if max - min > 0 then
			local mid = min + rshift (max - min, 1)
			local loc = locations[mid]

			table.insert (strs, string.format ("if %.7f >= location then\n", loc))
			compile_one (min, mid, values, locations, derivatives)
			table.insert (strs, string.format ("else\n"))
			compile_one (mid + 1, max, values, locations, derivatives)
			table.insert (strs, string.format ("end\n"))
		else
			local i = min

			if i == 1 then
				table.insert (strs, "local s = ")
				table.insert (strs, assemble_value (values[1]))
				table.insert (strs, "\n")
				table.insert (strs, assemble_interp_outsized_value (locations,
										    derivatives,
										    1))
				table.insert (strs, "\nreturn k\n")
			elseif i > #locations then
				table.insert (strs, "local s = ")
				table.insert (strs, assemble_value (values[#values]))
				table.insert (strs, "\n")
				table.insert (strs, assemble_interp_outsized_value (locations,
										    derivatives,
										    #locations))
				table.insert (strs, "\nreturn k\n")
			else
				local i1, i2 = min - 1, min
				local loc_below = locations[i1]
				local loc_above = locations[i2]
				local val_below = assemble_value (values[i1])
				local val_above = assemble_value (values[i2])
				local deriv_below = derivatives[i1]
				local deriv_above = derivatives[i2]
				local loc_total = (loc_above - loc_below)
				local progress = string.format ("(location - %.7f) / %.7f",
								loc_below, loc_total)
				table.insert (strs, "local val_below = " .. val_below .. "\n")
				table.insert (strs, "local val_above = " .. val_above .. "\n")
				local fmt = "return eval_spline_2 (%.7f, %.7f, %s, %s, val_below, val_above, %.7f, %.7f)\n"
				table.insert (strs, string.format (fmt, loc_below, loc_above, progress,
								   progress, deriv_below, deriv_above))
			end
		end
	end

	local min, max = 1, #locations + 1
	compile_one (min, max, values, locations, derivatives)
	table.insert (strs, "end")
	local splinebody = table.concat (strs)

	local arglist = {
		"eval_spline_2",
		"coord_provider",
	}

	for i = 1, #closures do
		table.insert (arglist, string.format ("c%04d", i))
	end
	local builder = {
		"return function (",
		table.concat (arglist, ","), ")\n",
		"return ",
		splinebody,
		"\nend\n",
	}
	local spline_function = table.concat (builder)
	if spline_debug then
		print (string.format ("=================== Spline %04d ===================",
				      spline_id))
		print (spline_function)
		print ("===================================================")
	end
	local fn, err = loadstring (spline_function)
	if err then
		print (string.format ("Failed to compile spline %04d: %s", spline_id, err))
		return nil
	end
	return fn () (eval_spline_2, coord_provider, unpack (closures))
end

local function petrify_spline (self, visited)
	if visited[self] then
		return visited[self]
	else
		local values = {}
		local locations = self.locations
		local derivatives = self.derivatives
		local coord_provider
			= self.coordinate_provider:petrify_and_clone (visited)
		for _, spline in ipairs (self.values) do
			if type (spline) ~= "number" then
				table.insert (values, petrify_spline (spline, visited))
			else
				table.insert (values, spline)
			end
		end
		if compile_splines then
			local spline
				= compile_spline (values, locations, derivatives,
						  coord_provider)
			if spline then
				visited[self] = spline
				return spline
			end
		end
		local fn = function (x, y, z, blender)
			return eval_spline_1 (values, locations, derivatives,
					      coord_provider, x, y, z, blender)
		end
		visited[self] = fn
	end
end

local function make_spline_struct (coordinate, min_input, max_input,
				   locations, values, derivatives)
	-- Calculate minimum and maximum values to which this spline
	-- is capable of evaluating.
	local min, max = math.huge, -math.huge
	local n_locations = #locations

	assert (n_locations > 0
		and n_locations == #values and n_locations == #derivatives)

	if min_input < locations[1] then
		local min_1 = interp_outsized_value (min_input, locations,
						     value_min (values[1]),
						     derivatives, 1)
		local max_1 = interp_outsized_value (min_input, locations,
						     value_max (values[1]),
						     derivatives, 1)
		min = mathmin (min, mathmin (min_1, max_1))
		max = mathmax (max, mathmax (min_1, max_1))
	end

	if max_input > locations[n_locations] then
		local val_min = value_min (values[n_locations])
		local val_max = value_max (values[n_locations])
		local min_2 = interp_outsized_value (max_input, locations,
						     val_min, derivatives,
						     n_locations)
		local max_2 = interp_outsized_value (max_input, locations,
						     val_max, derivatives,
						     n_locations)
		min = mathmin (min, mathmin (min_2, max_2))
		max = mathmax (max, mathmax (min_2, max_2))
	end

	for _, value in ipairs (values) do
		local min_3, max_3
			= value_min (value), value_max (value)
		min = mathmin (min, min_3)
		max = mathmax (max, max_3)
	end

	for i = 1, n_locations - 1 do
		local deriv_below = derivatives[i]
		local deriv_above = derivatives[i + 1]

		-- If none of the "derivatives" are set, the loop
		-- above will already have sufficed.
		if deriv_below ~= 0.0 or deriv_above ~= 0.0 then
			local loc_below = locations[i]
			local loc_above = locations[i + 1]
			local val_below_min = value_min (values[i])
			local val_below_max = value_max (values[i])
			local val_above_min = value_min (values[i + 1])
			local val_above_max = value_min (values[i + 1])
			local v1 = eval_spline_2 (loc_below, loc_above, 1.0, 0.5,
						  val_below_min, val_above_min,
						  deriv_below, deriv_above)
			local v2 = eval_spline_2 (loc_below, loc_above, 1.0, 0.5,
						  val_below_max, val_above_max,
						  deriv_below, deriv_above)
			local v3 = eval_spline_2 (loc_below, loc_above, 1.0, 0.5,
						  val_below_max, val_above_min,
						  deriv_below, deriv_above)
			local v4 = eval_spline_2 (loc_below, loc_above, 1.0, 0.5,
						  val_below_min, val_above_max,
						  deriv_below, deriv_above)
			local max_4 = mathmax (v1, mathmax (v2, mathmax (v3, v4)))
			local v5 = eval_spline_2 (loc_below, loc_above, 0.0, 0.5,
						  val_below_min, val_above_min,
						  deriv_below, deriv_above)
			local v6 = eval_spline_2 (loc_below, loc_above, 0.0, 0.5,
						  val_below_max, val_above_max,
						  deriv_below, deriv_above)
			local v7 = eval_spline_2 (loc_below, loc_above, 0.0, 0.5,
						  val_below_max, val_above_min,
						  deriv_below, deriv_above)
			local v8 = eval_spline_2 (loc_below, loc_above, 0.0, 0.5,
						  val_below_min, val_above_max,
						  deriv_below, deriv_above)
			local min_4 = mathmin (v5, mathmin (v6, mathmin (v7, v8)))
			min = mathmin (min, min_4)
			max = mathmax (max, max_4)
		end
	end

	local spline = {
		min_value = min,
		max_value = max,
		locations = locations,
		values = values,
		derivatives = derivatives,
		coordinate_provider = coordinate,
	}
	local meta = {
		__call = eval_spline,
	}
	setmetatable (spline, meta)
	return spline
end

local function wrap_spline (spline, applicator, noise_visitor, visited)
	if visited[spline] then
		return visited[spline]
	end

	local values1 = {}
	for i, value in ipairs (spline.values) do
		if type (value) == "number" then
			values1[i] = value
		else
			values1[i] = wrap_spline (value, applicator, noise_visitor,
						  visited)
		end
	end
	local provider = spline.coordinate_provider
	local provider = provider:wrap_internal (applicator, noise_visitor,
						 visited)
	local value = make_spline_struct (provider, provider:min_value (),
					  provider:max_value (),
					  spline.locations, values1,
					  spline.derivatives)
	visited[spline] = value
	return value
end

local spline = {
	spline = nil,
}

function spline:min_value ()
	return self.spline.min_value
end

function spline:max_value ()
	return self.spline.max_value
end

function spline:wrap_internal (applicator, noise_visitor, visited)
	if visited[self] then
		return visited[self]
	end
	local values = table.merge (spline, {
		spline = wrap_spline (self.spline, applicator,
				      noise_visitor, visited),
	})
	local val = applicator (make_density_function (values))
	visited[self] = val
	return val
end

function spline:__call (x, y, z, blender)
	return self.spline (x, y, z, blender)
end

function spline:petrify_internal (visited)
	return petrify_spline (self.spline, visited)
end

function mcl_levelgen.spline_from_points (coordinate, points)
	local locations, values, derivatives = {}, {}, {}
	for i, point in ipairs (points) do
		locations[i] = point.location
		values[i] = point.value
		derivatives[i] = point.derivative
	end
	local spline1 = make_spline_struct (coordinate,
					    coordinate:min_value (),
					    coordinate:max_value (),
					    locations, values, derivatives)
	return spline1
end

function mcl_levelgen.make_spline (coordinate, points)
	local spline1 = mcl_levelgen.spline_from_points (coordinate, points)
	local values = table.merge (spline, {
		spline = spline1,
	})
	return make_density_function (values)
end

-- luacheck: push ignore 511
if false then
	local ull = mcl_levelgen.ull
	local rng = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))
	local continentalness = {
		first_octave = -9,
		amplitudes = {
			1.0, 1.0, 2.0, 2.0, 2.0,
			1.0, 1.0, 1.0,
		}
	}
	local noise
		= mcl_levelgen.make_normal_noise (rng, continentalness.first_octave,
						  continentalness.amplitudes, true)
	local func = mcl_levelgen.make_noise_from_parms (noise, 25.0, 0.0)
	local spline = mcl_levelgen.make_spline (func, {
		{
			location = -1.0,
			value = -0.05,
			derivative = 0.5,
		},
		{
			location = -0.4,
			value = 0.01,
			derivative = 0.099999994,
		},
		{
			location = 0.0,
			value = 0.03,
			derivative = 0.099999994,
		},
		{
			location = 1.0,
			derivative = 0.070000015,
			value = 0.6,
		},
	})
	print ("Spline max, min: " .. spline:max_value () .. "," .. spline:min_value ())

	for x = 0, 127 do
		for z = 0, 127 do
			local value = spline (x, 0, z)
			print (value)
		end
	end
end
-- luacheck: pop

-- "\([[:alnum:]]+\)":.*??\(-?[[:digit:]\.]+\)\b
-- \1 = \2

function mcl_levelgen.plot_spline (self)
	local n = #self.locations
	local derivatives = self.derivatives
	local locations = self.locations
	local values = self.values
	local first_deriv = derivatives[1]
	local first_location = locations[1]
	local first_value = values[1]
	if type (first_value) ~= "number" then
		error ("Not yet capable of plotting nested splines")
	end

	print ("lerp1d (u, v, w) = u * (w - v) + v")

	print (string.format ("extbelow (x) = (%.6f == 0.0 ? %.6f : %.6f + %.6f * (x - %.6f))",
			      first_deriv, first_value, first_value, first_deriv, first_location))

	local last_deriv = derivatives[n]
	local last_location = locations[n]
	local last_value = values[n]
	if type (last_value) ~= "number" then
		error ("Not yet capable of plotting nested splines")
	end

	print (string.format ("extabove (x) = (%.6f == 0.0 ? %.6f : %.6f + %.6f * (x - %.6f))",
			      last_deriv, last_value, last_value, last_deriv, last_location))

	for i = 1, n - 1 do
		local i2 = i + 1
		local location_below = locations[i]
		local location_above = locations[i2]
		local deriv_below = derivatives[i]
		local deriv_above = derivatives[i2]
		local value_below = values[i]
		local value_above = values[i2]
		if type (value_below) ~= "number" or type (value_above) ~= "number" then
			error ("Not yet capable of plotting nested splines")
		end
		local loc_diff = location_above - location_below
		local val_diff = value_above - value_below
		local dev_below = deriv_below * loc_diff - val_diff
		local dev_above = -deriv_above * loc_diff - val_diff

		print (string.format ("eval%d_%d (x) = lerp1d (x, %.6f, %.6f) + x * (1.0 - x) * lerp1d (x, %.6f, %.6f)",
				      i, i2, value_below, value_above,
				      dev_below, dev_above))
	end

	local function plotpair (i)
		local i2 = i + 1
		if i2 > n then
			return "0"
		end

		return string.format ("x <= %.7f ? eval%d_%d ((x - %.7f) / (%.7f - %.7f)) : %s",
				      locations[i2], i, i2, locations[i], locations[i2],
				      locations[i], plotpair (i + 1))
	end

	print ("spline(x) = \\")
	print (string.format ("(x <= %.6f ? extbelow (x) : x > %.6f ? extabove (x) : %s)",
			      first_location, last_location, plotpair (1)))
end

function mcl_levelgen.export_spline (spline)
	if type (spline) == "number" then
		return spline
	end
	local values = {}
	for i = 1, #spline.locations do
		table.insert (values, {
			location = spline.locations[i],
			value = mcl_levelgen.export_spline (spline.values[i]),
			derivative = spline.derivatives[i],
		})
	end
	return values
end

------------------------------------------------------------------------
-- Constant values.
------------------------------------------------------------------------

local constant = {
	name = "constant",
	constant = nil,
}

function constant:fill (array, n, provider, provider_data)
	for i = 1, n do
		array[i] = self.constant
	end
end

function constant:__call (x, y, z, blender)
	return self.constant
end

function constant:petrify_internal (visited)
	return function (x, y, z, blender)
		return self.constant
	end
end

function constant:min_value ()
	return self.constant
end

function constant:max_value ()
	return self.constant
end

function mcl_levelgen.make_constant (value)
	local values = table.merge (constant, {
		constant = value,
	})
	return make_density_function (values)
end

mcl_levelgen.ZERO = mcl_levelgen.make_constant (0.0)

------------------------------------------------------------------------
-- Y Clamped Gradient.
-- minecraft:y_clamped_gradient
------------------------------------------------------------------------

local y_clamped_gradient = {
	from_y = nil,
	to_y = nil,
	from_value = nil,
	to_value = nil,
}

function y_clamped_gradient:min_value ()
	return mathmin (self.from_value, self.to_value)
end

function y_clamped_gradient:max_value ()
	return mathmax (self.from_value, self.to_value)
end

function y_clamped_gradient:__call (x, y, z, blender)
	local progress = ((y - self.from_y) / (self.to_y - self.from_y))
	local from_value = self.from_value
	local to_value = self.to_value
	if progress < 0.0 then
		return from_value
	elseif progress > 1.0 then
		return to_value
	else
		return lerp1d (progress, from_value, to_value)
	end
end

function y_clamped_gradient:petrify_internal (visited)
	local from_y, to_y = self.from_y, self.to_y
	local from_value = self.from_value
	local to_value = self.to_value
	local total = to_y - from_y
	return function (x, y, z, blender)
		local progress = ((y - from_y) / total)
		if progress < 0.0 then
			return from_value
		elseif progress > 1.0 then
			return to_value
		else
			return lerp1d (progress, from_value, to_value)
		end
	end
end

function mcl_levelgen.make_y_clamped_gradient (from_y, to_y, from_value, to_value)
	local values = table.merge (y_clamped_gradient, {
		from_y = from_y,
		to_y = to_y,
		from_value = from_value,
		to_value = to_value,
	})
	return make_density_function (values)
end
