------------------------------------------------------------------------
-- Minecraft-style Perlin noise.
------------------------------------------------------------------------

local ipairs = ipairs
local gradients = {
	1, 1, 0,
	-1, 1, 0,
	1, -1, 0,
	-1, -1, 0,
	1, 0, 1,
	-1, 0, 1,
	1, 0, -1,
	-1, 0, -1,
	0, 1, 1,
	0, -1, 1,
	0, 1, -1,
	0, -1, -1,
	1, 1, 0,
	0, -1, 1,
	-1, 1, 0,
	0, -1, -1,
}

local ffi, ct_permutations

if mcl_levelgen.use_ffi then
	ffi = require ("ffi")
	local c_gradients = ffi.new ("double[49]")
	for i = 1, #gradients do
		c_gradients[i] = gradients[i]
	end
	gradients = c_gradients
	ct_permutations = ffi.typeof ("double[257]")
end

local floor = math.floor
local band = bit.band

local function dotproduct (vecno, x, y, z)
	local n = band (vecno, 0xf)
	local i = n + n + n
	local x0, y0, z0 = gradients[i + 1],
		gradients[i + 2],
		gradients[i + 3]
	return x0 * x + y0 * y + z0 * z
end

local function fade (value)
	return value * value * value * (value * (value * 6.0 - 15.0) + 10.0)
end

local function lerp1d (u, s1, s2)
	return (s2 - s1) * u + s1
end

local function lerp2d (u, v, s1, s2, s3, s4)
	return lerp1d (v, lerp1d (u, s1, s2), lerp1d (u, s3, s4))
end

local function lerp3d (u, v, w, s1, s2, s3, s4, s5, s6, s7, s8)
	return lerp1d (w, lerp2d (u, v, s1, s2, s3, s4),
		       lerp2d (u, v, s5, s6, s7, s8))
end

mcl_levelgen.lerp1d = lerp1d
mcl_levelgen.lerp2d = lerp2d
mcl_levelgen.lerp3d = lerp3d

function mcl_levelgen.make_octave (rng)
	local xoff = rng:next_double () * 256.0
	local yoff = rng:next_double () * 256.0
	local zoff = rng:next_double () * 256.0
	-- print ("offsets", xoff, yoff, zoff)
	local permutation = ffi and ffi.new (ct_permutations) or {}

	for i = 1, 256 do
		permutation[i] = i - 1
	end

	-- Shuffle permutation list.
	for i = 0, 255 do
		local x = rng:next_within (256 - i)
		local v1 = permutation[i + 1]
		local v2 = permutation[i + x + 1]
		permutation[i + 1] = v2
		permutation[i + x + 1] = v1
		-- print (string.format ("  %d  <->  %d", i, i + x))
	end

	return function (x, y, z, yscale, ymax, get_yorigin)
		if get_yorigin then
			return yoff
		end

		-- print ("inputs", x, y, z, xoff, yoff, zoff)

		local x = x + xoff
		local y = y + yoff
		local z = z + zoff
		local gridx = floor (x)
		local gridy = floor (y)
		local gridz = floor (z)
		local fractx = x - gridx
		local real_fracty = y - gridy
		local fractz = z - gridz
		local fracty_base = 0.0

		if yscale ~= 0.0 then
			local m = real_fracty
			if ymax >= 0.0 and ymax < real_fracty then
				m = ymax
			end
			fracty_base = floor (m / yscale + 1e-7) * yscale
		end
		local fracty = real_fracty - fracty_base

		local x = gridx
		local y = gridy
		local z = gridz
		local x1 = permutation[band (x, 0xff) + 1]
		local x2 = permutation[band ((x + 1), 0xff) + 1]
		local y1 = permutation[band ((x1 + y), 0xff) + 1]
		local y2 = permutation[band ((x1 + y + 1), 0xff) + 1]
		local x2y1 = permutation[band ((x2 + y), 0xff) + 1]
		local x2y2 = permutation[band ((x2 + y + 1), 0xff) + 1]

		-- 8 corners of the cube.
		local s1 = dotproduct (permutation[band ((y1 + z), 0xff) + 1],
				       fractx, fracty, fractz)
		local s2 = dotproduct (permutation[band ((x2y1 + z), 0xff) + 1],
				       fractx - 1.0, fracty, fractz)
		local s3 = dotproduct (permutation[band ((y2 + z), 0xff) + 1],
				       fractx, fracty - 1.0, fractz)
		local s4 = dotproduct (permutation[band ((x2y2 + z), 0xff) + 1],
				       fractx - 1.0, fracty - 1.0, fractz)
		local s5 = dotproduct (permutation[band ((y1 + z + 1), 0xff) + 1],
				       fractx, fracty, fractz - 1.0)
		local s6 = dotproduct (permutation[band ((x2y1 + z + 1), 0xff) + 1],
				       fractx - 1.0, fracty, fractz - 1.0)
		local s7 = dotproduct (permutation[band ((y2 + z + 1), 0xff) + 1],
				       fractx, fracty - 1.0, fractz - 1.0)
		local s8 = dotproduct (permutation[band ((x2y2 + z + 1), 0xff) + 1],
				       fractx - 1.0, fracty - 1.0, fractz - 1.0)
		local u = fade (fractx)
		local v = fade (real_fracty)
		local z = fade (fractz)
		return lerp3d (u, v, z, s1, s2, s3, s4, s5, s6, s7, s8)
	end
end

local WORLD_BORDER = 33554432 -- #x2000000
local floor = math.floor

local function wrap_around_world_border (x)
	return x - floor (x / WORLD_BORDER + 0.5) * WORLD_BORDER
end
mcl_levelgen.wrap_around_world_border = wrap_around_world_border

-- https://maven.fabricmc.net/docs/yarn-1.20.4+build.1/net/minecraft/util/math/noise/OctavePerlinNoiseSampler.html
function mcl_levelgen.make_noise (rng, first_octave, amplitudes, fork_noise)
	local samplers = {}
	local n_amplitudes = #amplitudes
	local persistence, lacunarity

	if fork_noise then
		local factory = rng:fork_positional ()
		for i = 0, n_amplitudes - 1 do
			local idx = i + 1
			if amplitudes[idx] ~= 0 then
				local octave = first_octave + i
				local rng = factory ("octave_" .. octave)
				samplers[idx] = mcl_levelgen.make_octave (rng)
			end
		end
	else
		local base = mcl_levelgen.make_octave (rng)
		local complement = -first_octave
		if complement >= 0 and complement < n_amplitudes then
			local amplitude_first = amplitudes[complement + 1]
			if amplitude_first ~= 0.0 then
				-- print ("Creating " .. complement)
				samplers[complement + 1] = base
			end
		end

		local i = complement - 1
		while i >= 0 do
			if i < n_amplitudes then
				local amplitude = amplitudes[i + 1]
				if amplitude ~= 0.0 then
					local base = mcl_levelgen.make_octave (rng)
					-- print ("Creating " .. i)
					samplers[i + 1] = base
				else
					rng:consume (262)
				end
			else
				rng:consume (262)
			end
			i = i - 1
		end
	end

	-- See https://minecraft.wiki/w/Noise and the Yarn docs.
	persistence = math.pow (2.0, first_octave)
	lacunarity = math.pow (2.0, n_amplitudes - 1)
		/ (math.pow (2.0, n_amplitudes) - 1.0)

	-- print ("l and s: " .. persistence .. " " .. lacunarity)

	local function get_value (x, y, z, yscale, ymax, use_origin)
		local val = 0.0
		local persistence, lacunarity = persistence, lacunarity

		for i = 1, n_amplitudes do
			local sampler = samplers[i]
			if sampler then
				local xs = wrap_around_world_border (x * persistence)
				local ys = wrap_around_world_border (y * persistence)
				local zs = wrap_around_world_border (z * persistence)
				if use_origin then
					ys = -sampler (nil, nil, nil, nil, nil, true)
				end
				local v1 = sampler (xs, ys, zs, yscale, ymax)
				val = val + amplitudes[i] * v1 * lacunarity
			end
			persistence = persistence * 2.0
			lacunarity = lacunarity / 2.0
		end

		return val
	end

	local function get_max_value (amp_scale)
		local lacunarity = lacunarity
		local val = 0.0
		for i = 1, n_amplitudes do
			local sampler = samplers[i]
			if sampler then
				val = val + amplitudes[i] * amp_scale * lacunarity
			end
			lacunarity = lacunarity / 2.0
		end
		return val
	end

	local function get_octave (n)
		return samplers[n_amplitudes - n]
	end

	local tbl = {
		samplers = samplers,
		persistence = persistence,
		lacunarity = lacunarity,
		max_value = get_max_value (2.0),
		get_value = get_value,
		get_max_value = get_max_value,
		get_octave = get_octave,
	}
	-- print ("max_value: " .. tbl.max_value)
	setmetatable (tbl, {
		__call = function (_, x, y, z, yscale, ymax, use_origin)
			return get_value (x, y, z, yscale, ymax, use_origin)
		end,
	})
	return tbl
end

-- luacheck: push ignore 211 311 511
local WIDTH = 1000
local HEIGHT = 1000

if false then
	-- Test octaves.
	local slo = mcl_levelgen.ull (304, 72242039)
	local shi = mcl_levelgen.ull (304, 72242039)
	local rng = mcl_levelgen.xoroshiro (slo, shi)
	local oct1 = mcl_levelgen.make_octave (rng)

	-- Without scale.
	for x = 0, 255 do
		for y = 0, 255 do
			print (oct1 (x, 0, y, 0, 0))
		end
	end

	print (">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")

	-- With scale.
	for x = 0, 255 do
		for y = 0, 255 do
			print (oct1 (x, 0, y, 0.5675, 1.0))
		end
	end

	print ("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")

	-- Test modern noise.

	local continentalness = {
		first_octave = -9,
		amplitudes = {
			1.0, 1.0, 2.0, 2.0, 2.0,
			1.0, 1.0, 1.0,
		}
	}

	local slo = mcl_levelgen.ull (304, 72242039)
	local shi = mcl_levelgen.ull (304, 72242039)
	local rng = mcl_levelgen.xoroshiro (slo, shi)
	local noise = mcl_levelgen.make_noise (rng, continentalness.first_octave,
					       continentalness.amplitudes, true)

	print ("Max value: " .. noise.max_value)

	for x = 0, WIDTH - 1 do
		for y = 0, HEIGHT - 1 do
			local val = noise (x / WIDTH, 0, y / HEIGHT, 0, 0, false)
			print (val)
		end
	end

	-- Test legacy noise.

	local seed = mcl_levelgen.ull (0, 585454123)
	local rng = mcl_levelgen.jvm_random (seed)
	local noise = mcl_levelgen.make_noise (rng, continentalness.first_octave,
					       continentalness.amplitudes, false)
	print ("Max value: " .. noise.max_value)
	for x = 0, WIDTH - 1 do
		for y = 0, HEIGHT - 1 do
			local val = noise (x / WIDTH, 0, y / HEIGHT, 0.5675, 1.0, true)
			print (val)
		end
	end
end
-- luacheck: pop

------------------------------------------------------------------------
-- Minecraft-style simplex noise.
------------------------------------------------------------------------

local SQRT_3 = math.sqrt (3.0)
local F2 = (SQRT_3 - 1.0) / 2
local G2 = (3.0 - SQRT_3) / 6.0
local R2 = 0.5
local max = math.max

local function vertex_contribution (ghash, x, y)
	local d2 = R2 - x * x - y * y
	local k = max (0, d2)
	return k * k * k * k * dotproduct (ghash, x, y, 0)
end

local function vertex_contribution_3d (ghash, x, y, z, r2)
	local d2 = r2 - x * x - y * y - z * z
	local k = max (0, d2)
	return k * k * k * k * dotproduct (ghash, x, y, z)
end

local rshift = bit.rshift
local ceil = math.ceil

function mcl_levelgen.simplex_octave (rng)
	local xoff = rng:next_double () * 256.0
	local yoff = rng:next_double () * 256.0
	local zoff = rng:next_double () * 256.0
	local floor = math.floor
	local permutation = {}

	for i = 1, 256 do
		permutation[i] = i - 1
	end

	-- Shuffle permutation list.
	for i = 0, 255 do
		local x = rng:next_within (256 - i)
		local v1 = permutation[i + 1]
		local v2 = permutation[i + x + 1]
		permutation[i + 1] = v2
		permutation[i + x + 1] = v1
	end

	local function p (x)
		return permutation[x % 256 + 1]
	end

	-- Derived from Stefan Gustavson's public domain
	-- implementation of 2-dimensional and 3-dimensional simplex
	-- noise.

	local function value2d (_, x, y)
		local skew = (x + y) * F2
		local xskew = floor (x + skew)
		local yskew = floor (y + skew)
		local unskew = (xskew + yskew) * G2
		local cellx = xskew - unskew
		local celly = yskew - unskew
		local intx = x - cellx
		local inty = y - celly
		local sign = rshift (ceil (intx - inty) - 1, 31)
		local xfirst = 1 - sign
		local yfirst = sign
		local v1x, v1y = intx - xfirst + G2,
			inty - yfirst + G2
		local v2x, v2y = intx - 1.0 + G2 * 2,
			inty - 1.0 + G2 * 2
		local xhash = xskew % 256
		local yhash = yskew % 256
		local dir0 = p (xhash + p (yhash)) % 12
		local dir1 = p (xhash + xfirst + p (yhash + yfirst)) % 12
		local dir2 = p (xhash + 1 + p (yhash + 1)) % 12
		return 70.0 * (vertex_contribution (dir0, intx, inty)
			       + vertex_contribution (dir1, v1x, v1y)
			       + vertex_contribution (dir2, v2x, v2y))
	end

	local F3 = 1/3
	local G3 = 1/6

	local function value3d (x, y, z)
		local skew = (x + y + z) * F3
		local xs = x + skew
		local ys = y + skew
		local zs = z + skew
		local i = floor (xs)
		local j = floor (ys)
		local k = floor (zs)
		local t = (i + j + k) * G3
		local X0 = i - t
		local Y0 = j - t
		local Z0 = k - t
		local x0 = x - X0
		local y0 = y - Y0
		local z0 = z - Z0
		local i1, j1, k1 -- /* Offsets for second corner of simplex in (i,j,k) coords */
		local i2, j2, k2 -- /* Offsets for third corner of simplex in (i,j,k) coords */
		if x0 >= y0 then
			if y0 >= z0 then
				i1, j1, k1, i2, j2, k2 = 1, 0, 0, 1, 1, 0
			elseif x0 >= z0 then
				i1, j1, k1, i2, j2, k2 = 1, 0, 0, 1, 0, 1
			else
				i1, j1, k1, i2, j2, k2 = 0, 0, 1, 1, 0, 1
			end
		else
			if y0 < z0 then
				i1, j1, k1, i2, j2, k2 = 0, 0, 1, 0, 1, 1
			elseif x0 < z0 then
				i1, j1, k1, i2, j2, k2 = 0, 1, 0, 0, 1, 1
			else
				i1, j1, k1, i2, j2, k2 = 0, 1, 0, 1, 1, 0
			end
		end
		-- /* Offsets for second corner in (x,y,z) coords */
		local x1 = x0 - i1 + G3
		local y1 = y0 - j1 + G3
		local z1 = z0 - k1 + G3
		-- /* Offsets for third corner in (x,y,z) coords */
		local x2 = x0 - i2 + 2.0 * G3
		local y2 = y0 - j2 + 2.0 * G3
		local z2 = z0 - k2 + 2.0 * G3
		-- /* Offsets for last corner in (x,y,z) coords */
		local x3 = x0 - 1.0 + 3.0 * G3
		local y3 = y0 - 1.0 + 3.0 * G3;
		local z3 = z0 - 1.0 + 3.0 * G3;

		local ii = i % 256
		local jj = j % 256
		local kk = k % 256

		local dir0 = p (ii + p (jj + p (kk))) % 12
		local dir1 = p (ii + i1 + p (jj + j1 + p (kk + k1))) % 12
		local dir2 = p (ii + i2 + p (jj + j2 + p (kk + k2))) % 12
		local dir3 = p (ii + 1 + p (jj + 1 + p (kk + 1))) % 12

		-- print (dir0, dir1, dir2, dir3)
		-- print (x0, y0, z0)
		-- print (x1, y1, z1)
		-- print (x2, y2, z2)
		-- print (x3, y3, z3)
		return 32.0 * (vertex_contribution_3d (dir0, x0, y0, z0, 0.6)
			       + vertex_contribution_3d (dir1, x1, y1, z1, 0.6)
			       + vertex_contribution_3d (dir2, x2, y2, z2, 0.6)
			       + vertex_contribution_3d (dir3, x3, y3, z3, 0.6))
	end

	local tbl = {
		xoff = xoff,
		yoff = yoff,
		zoff = zoff,
		value3d = value3d,
	}
	local metatable = {
		__call = value2d,
	}
	setmetatable (tbl, metatable)
	return tbl
end

local function indexof (list, val)
	for i, v in ipairs (list) do
		if v == val then
			return i
		end
	end
	return -1
end

local LONG_MAX_AS_FLOAT = 9.223372e18

-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/util/math/noise/OctaveSimplexNoiseSampler.html
function mcl_levelgen.make_simplex_noise (rng, in_octaves)
	local n_low_octaves = -in_octaves[1]
	local n_octaves = #in_octaves
	local n_high_octaves = in_octaves[n_octaves]
	local octaves_total = n_low_octaves + n_high_octaves + 1

	if octaves_total < 1 then
		error ("Inadequate number of octaves")
	end

	local octaves = {}
	local init_noise = mcl_levelgen.simplex_octave (rng)

	if n_high_octaves >= 0
		and n_high_octaves < octaves_total
		and indexof (in_octaves, 0) ~= -1 then
		octaves[n_high_octaves + 1] = init_noise
	end

	for i = n_high_octaves + 1, octaves_total - 1 do
		if i >= 0 and indexof (in_octaves, n_high_octaves - i) then
			octaves[i + 1] = mcl_levelgen.simplex_octave (rng)
		else
			rng:consume (262)
		end
	end

	if n_high_octaves > 0 then
		-- TODO: this doesn't precisely reproduce Minecraft's
		-- values, but doing so doesn't appear to be
		-- necessary??
		local v2 = init_noise.value3d (init_noise.xoff,
					       init_noise.yoff,
					       init_noise.zoff)
		local seed = mcl_levelgen.ull (nil, nil)
		mcl_levelgen.dtoull (seed, v2 * LONG_MAX_AS_FLOAT)

		local i = n_high_octaves - 1
		while i >= 0 do
			local seed = mcl_levelgen.ull (nil, nil)
			mcl_levelgen.dtoull (seed, v2 * LONG_MAX_AS_FLOAT)
			local rng1 = mcl_levelgen.jvm_random (seed)

			if i < octaves_total and indexof (octaves, n_high_octaves - i) then
				octaves[i + 1] = mcl_levelgen.simplex_octave (rng1)
			else
				rng1:consume (262)
			end
			i = i - 1
		end
	end

	local lacunarity = math.pow (2.0, n_high_octaves)
	local persistence = 1.0 / (math.pow (2.0, octaves_total) - 1.0)
	local function get_value (x, y, use_origin)
		local v = 0.0
		local lacunarity = lacunarity
		local persistence = persistence
		for i = 1, n_octaves do
			local octave = octaves[i]
			if octave then
				local x = x * lacunarity
				local y = y * lacunarity
				if use_origin then
					x = x + octave.xoff
					y = y + octave.yoff
				end
				v = v + octave (x, y) * persistence
			end
			lacunarity = lacunarity / 2
			persistence = persistence * 2
		end
		return v
	end
	local tbl = {
		lacunarity = lacunarity,
		persistence = persistence,
		get_value = get_value,
	}
	setmetatable (tbl, {
		__call = function (_, x, y, use_origin)
			return get_value (x, y, use_origin)
		end,
	})
	return tbl
end

-- luacheck: push ignore 511
if false then
	local seed = mcl_levelgen.ull (0, 585454123)
	local rng = mcl_levelgen.jvm_random (seed)
	local octave = mcl_levelgen.simplex_octave (rng)
	for x = 0, WIDTH - 1 do
		for z = 0, HEIGHT - 1 do
			print (octave (x, z))
		end
	end

	print ("######################################################")

	local seed = mcl_levelgen.ull (144, 45432)
	local rng = mcl_levelgen.jvm_random (seed)
	local simplex
		= mcl_levelgen.make_simplex_noise (rng, { -2, -1, 0, })
	for x = 0, WIDTH - 1 do
		for z = 0, HEIGHT - 1 do
			print (simplex (x, z))
		end
	end
end
-- luacheck: pop

-- https://maven.fabricmc.net/docs/yarn-1.20.4+build.1/net/minecraft/util/math/noise/DoublePerlinNoiseSampler.html
------------------------------------------------------------------------
-- Minecraft-style offset noise samplers.
------------------------------------------------------------------------

local RIGHT_NOISE_SCALE = 337.0 / 331.0
local TARGET_DEVIATION = 1 / 6

local function expected_deviation (range)
	return 0.1 * (1.0 + 1.0 / (range + 1))
end

function mcl_levelgen.make_normal_noise (rng, first_octave, amplitudes, fork_noise)
	local min = 0x7fffffff;
	local max = -0x80000000;

	-- Count range of active octaves.
	for i = 0, #amplitudes - 1 do
		local idx = i + 1
		if amplitudes[idx] ~= 0.0 then
			min = math.min (min, i)
			max = math.max (max, i)
		end
	end

	-- Create left and right noises.
	local left = mcl_levelgen.make_noise (rng, first_octave, amplitudes,
					      fork_noise)
	local right = mcl_levelgen.make_noise (rng, first_octave, amplitudes,
					       fork_noise)
	local r = TARGET_DEVIATION / expected_deviation (max - min)
	local max_value = (left.max_value + right.max_value) * r

	local left_func = left.get_value
	local right_func = right.get_value
	local function get_value (x, y, z)
		local xr, yr, zr
		xr = x * RIGHT_NOISE_SCALE
		yr = y * RIGHT_NOISE_SCALE
		zr = z * RIGHT_NOISE_SCALE
		return (left_func (x, y, z, 0, 0, false)
			+ right_func (xr, yr, zr, 0, 0, false)) * r
	end

	local tbl = {
		first_octave = first_octave,
		amplitudes = amplitudes,
		max_value = max_value,
		get_value = get_value,
		left = left,
		right = right,
		r = r,
	}
	local metatable = {
		__call = function (_, x, y, z)
			return get_value (x, y, z)
		end,
	}
	setmetatable (tbl, metatable)
	return tbl
end

-- luacheck: push ignore 511
if false then
	-- Test modern noise.

	local continentalness = {
		first_octave = -9,
		amplitudes = {
			1.0, 1.0, 2.0, 2.0, 2.0,
			1.0, 1.0, 1.0,
		}
	}

	local slo = mcl_levelgen.ull (304, 72242039)
	local shi = mcl_levelgen.ull (304, 72242039)
	local rng = mcl_levelgen.xoroshiro (slo, shi)
	local noise
		= mcl_levelgen.make_normal_noise (rng, continentalness.first_octave,
						  continentalness.amplitudes, true)

	print ("Max value, r: " .. noise.max_value .. " " .. noise.r)
	print ("####################################################")
	for y = 0, 255 do
		for x = 0, 255 do
			for z = 0, 255 do
				print (noise (x, y, z))
			end
		end
	end
end

if false then
	-- Test legacy noise.

	local continentalness = {
		first_octave = -9,
		amplitudes = {
			1.0, 1.0, 2.0, 2.0, 2.0,
			1.0, 1.0, 1.0,
		}
	}

	local seed = mcl_levelgen.ull (0, 585454123)
	local rng = mcl_levelgen.jvm_random (seed)
	local noise
		= mcl_levelgen.make_normal_noise (rng, continentalness.first_octave,
						  continentalness.amplitudes, false)

	print ("Max value, r: " .. noise.max_value .. " " .. noise.r)
	print ("####################################################")
	for y = 0, 255 do
		for x = 0, 255 do
			for z = 0, 255 do
				print (noise (x, y, z))
			end
		end
	end
end
-- luacheck: pop
