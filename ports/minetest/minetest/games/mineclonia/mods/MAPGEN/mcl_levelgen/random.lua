if not mcl_levelgen then
	mcl_levelgen = {}
end

------------------------------------------------------------------------
-- 64-bit integers.
------------------------------------------------------------------------

local UINT_MAX = 4294967295
local tonumber = tonumber

local function ull (hi, lo)
	return { lo, hi, }
end

local function normalize (l)
	return (l + UINT_MAX + 1) % (UINT_MAX + 1)
end

local function extull (int)
	return {
		normalize (int),
		(int < 0 or int > 0x7fffffff) and UINT_MAX or 0,
	}
end

local function extkull (ull, int)
	ull[1] = normalize (int)
	ull[2] = (int < 0 or int > 0x7fffffff) and UINT_MAX or 0
end

local bxor = bit.bxor
local band = bit.band
local bnot = bit.bnot
local bor = bit.bor
local rshift = bit.rshift
local lshift = bit.lshift

local ceil = math.ceil
local fmod = math.fmod
local floor = math.floor

local function rtz (n)
	if n < 0 then
		return ceil (n)
	end
	return floor (n)
end

local LONG_MAX_AS_DOUBLE = (2 ^ 63 - 1)
local LONG_MIN_AS_DOUBLE = -(2 ^ 63)

-- Meant to be equivalent to `(long) (double) d' in Java.
local function dtoull (ull, d)
	if d >= LONG_MAX_AS_DOUBLE then
		ull[2] = 0x7fffffff
		ull[1] = 0xffffffff
		return
	elseif d <= LONG_MIN_AS_DOUBLE then
		ull[2] = 0x80000000
		ull[1] = 0x00000000
		return
	end

	local x = rtz (d)
	local hi = floor (x / 0x100000000)
	local lo = fmod (x, 0x100000000)
	ull[1] = normalize (lo)
	ull[2] = normalize (hi)
end

local function addull (a, b)
	local a_lo, a_hi = a[1], a[2]
	local b_lo, b_hi = b[1], b[2]

	local lo, hi = a_lo + b_lo, 0
	if b_lo > UINT_MAX - a_lo then
		lo = lo % (UINT_MAX + 1)
		hi = 1
	end
	hi = (hi + a_hi + b_hi) % (UINT_MAX + 1)
	a[1] = lo
	a[2] = hi
end

local function ltull (a, b) -- B < A
	return b[2] < a[2] or (b[2] == a[2] and b[1] < a[1])
end

local function andull (a, b)
	a[1] = normalize (band (a[1], b[1]))
	a[2] = normalize (band (a[2], b[2]))
end

local function xorull (a, b)
	a[1] = normalize (bxor (a[1], b[1]))
	a[2] = normalize (bxor (a[2], b[2]))
end

local function addkull (a, k)
	local a_lo, a_hi = a[1], a[2]

	local lo, hi = a_lo + k, 0
	if k > UINT_MAX - a_lo then
		lo = lo % (UINT_MAX + 1)
		hi = 1
	end
	hi = (hi + a_hi) % (UINT_MAX + 1)
	a[1] = lo
	a[2] = hi
end

local function negull (x)
	local lo, hi = normalize (bnot (x[1])),
		normalize (bnot (x[2]))
	if lo == UINT_MAX then
		lo, hi = 0, (hi + 1) % (UINT_MAX + 1)
	else
		lo = lo + 1
	end
	x[1] = lo
	x[2] = hi
end

local function subull (a, b)
	local subtrahend = { b[1], b[2], }
	negull (subtrahend)
	addull (a, subtrahend)
end

local USHORT_MAX = 65535

local function divull (a, d) -- NOTE: d <= 0x7fff
	local a_lo, a_hi = a[1], a[2]
	local a1 = band (a_lo, USHORT_MAX)
	local a2 = rshift (a_lo, 16)
	local a3 = band (a_hi, USHORT_MAX)
	local a4 = rshift (a_hi, 16)
	local r, q4, q3, q2, q1

	q4, r = floor (a4 / d), fmod (a4, d)
	q3, r = floor ((a3 + lshift (r, 16)) / d),
		fmod (a3 + lshift (r, 16), d)
	q2, r = floor ((a2 + lshift (r, 16)) / d),
		fmod (a2 + lshift (r, 16), d)
	q1, r = floor ((a1 + lshift (r, 16)) / d),
		fmod (a1 + lshift (r, 16), d)
	a[1] = normalize (bor (lshift (q2, 16), q1))
	a[2] = normalize (bor (lshift (q4, 16), q3))
	return normalize (r)
end

local function mulull (a, m)
	local a_lo, a_hi = a[1], a[2]
	local a1 = band (a_lo, USHORT_MAX)
	local a2 = rshift (a_lo, 16)
	local a3 = band (a_hi, USHORT_MAX)
	local a4 = rshift (a_hi, 16)
	local p1, p2, p3, p4
	local mullo = band (m, USHORT_MAX)
	local mulhi = rshift (m, 16)

	-- Long multiplication of low word.
	p1 = a1 * mullo
	p2 = a1 * mulhi
	p3 = a2 * mullo
	p4 = a2 * mulhi

	-- Add products of low word handling carry.
	a_lo = p1 -- lo*lo
	a_hi = p4 -- hi*hi

	-- p3 + p2 = lo*hi + hi*lo = 47:16
	-- Check carry.
	if p3 > UINT_MAX - p2 then
		a_hi = a_hi + 65536
	end

	-- Bits 47:16.
	local hilo = (p3 + p2) % (1 + UINT_MAX)
	a_lo = a_lo + (hilo * 65536) % (1 + UINT_MAX) -- lshift (hilo, 16)
	a_hi = a_hi + band (rshift (hilo, 16), USHORT_MAX)

	if a_lo > UINT_MAX then
		-- Carry into a_hi.
		a_lo = a_lo % (1 + UINT_MAX)
		a_hi = a_hi + 1
	end

	-- Long multiplication of hi word.
	p1 = a3 * mullo
	p2 = a3 * mulhi
	p3 = a4 * mullo
	p4 = a4 * mulhi

	local hi = p4
	a_hi = a_hi + p1
	if a_hi > UINT_MAX then
		hi = hi + 1
		a_hi = a_hi % (1 + UINT_MAX)
	end

	local hilo = (p2 + p3) % (1 + UINT_MAX)
	if p2 > UINT_MAX - p3 then
		hi = hi + 65536
	end
	a_hi = a_hi + (hilo * 65536) % (1 + UINT_MAX) -- lshift (hilo, 16)
	if a_hi > UINT_MAX then
		hi = hi + 1
		a_hi = a_hi % (1 + UINT_MAX)
	end
	hi = hi + rshift (hilo, 16)

	a[1] = a_lo
	a[2] = a_hi

	return (hi % (1 + UINT_MAX))
end

local function detect_luajit ()
	local fn = loadstring ([[
local x = 0x3ull
x = bit.band (x, 0x1ull)
return x == 0x1ull
]])
	return fn and fn ()
end
mcl_levelgen.detect_luajit = detect_luajit

local function shlull (a, k)
	local hi, lo = a[2], a[1]
	if k >= 32 then
		hi = lo
		lo = 0
		k = k - 32
	end
	hi = band (lshift (hi, k), UINT_MAX)
	local rem = rshift (lo, 32 - k)
	a[2] = normalize (bor (hi, rem))
	lo = k == 32 and 0 or lshift (lo, k)
	a[1] = normalize (lo)
end

local function shrull (a, k) -- logical shift right
	local lo, hi = a[1], a[2]
	if k >= 32 then
		lo = hi
		hi = 0
		k = k - 32
	end
	local rem = lshift (hi, 32 - k)
	hi = k ~= 32 and rshift (hi, k) or 0
	lo = rshift (lo, k)
	a[1] = normalize (bor (lo, rem))
	a[2] = normalize (hi)
end

local function ashrull (a, k) -- arithmetic shift right
	local lo, hi = a[1], a[2]
	local n, s = k, band (hi, 0x80000000) ~= 0
	if k >= 32 then
		lo = hi
		hi = 0
		k = k - 32
	end
	local rem = lshift (hi, 32 - k)
	hi = k ~= 32 and rshift (hi, k) or 0
	lo = rshift (lo, k)

	-- Sign extend.
	if s then
		local n = 64 - n
		if n < 32 then
			local lomask = lshift (UINT_MAX, n)
			lo = bor (lomask, lo)
			hi = UINT_MAX
		elseif n < 64 then
			local himask = lshift (UINT_MAX, n - 32)
			hi = bor (himask, hi)
		end
	end

	a[1] = normalize (bor (lo, rem))
	a[2] = normalize (hi)
end

local function rotlull (a, k)
	local lo, hi = a[1], a[2]
	shlull (a, k)
	a[1], lo = lo, a[1]
	a[2], hi = hi, a[2]
	shrull (a, (64 - k))
	a[1] = normalize (bor (a[1], lo))
	a[2] = normalize (bor (a[2], hi))
end

local function equalull (a, b)
	return a[1] == b[1] and a[2] == b[2]
end

local function zeroull (x)
	return x[1] == 0 and x[2] == 0
end

local function tostringull (x)
	local x = { x[1], x[2], }
	local chars = {}
	while not zeroull (x) do
		local r = divull (x, 10)
		table.insert (chars, string.char (48 + r))
	end
	local str = ""
	for i = 0, #chars - 1 do
		str = str .. chars[#chars - i]
	end
	return str
end

local function stringtoull (x, str)
	local n, tmp = #str, ull (0, 0)
	x[1], x[2] = 0, 0

	for i = 1, n do
		local value = string.byte (str:sub (i, i))
		if value < 48 or value > 57 then
			return false
		end
		if mulull (x, 10) ~= 0 then
			return false
		end
		local lo, hi = x[1], x[2]
		tmp[1], tmp[2] = value - 48, 0
		addull (x, tmp)
		tmp[1], tmp[2] = lo, hi
		if ltull (tmp, x) then
			return false
		end
	end
	return true
end

local tmp = ull (0, 0)

local function mul2ull (a, b)
	local lo, hi = a[1], a[2]
	local lb, hb = b[1], b[2]
	mulull (a, lb)
	a[1], lo = lo, a[1]
	a[2], hi = hi, a[2]
	mulull (a, hb)
	shlull (a, 32)
	tmp[1] = lo
	tmp[2] = hi
	addull (a, tmp)
end

if detect_luajit () then
	local str = [[
	local bxor = bit.bxor
	local band = bit.band
	local bnot = bit.bnot
	local bor = bit.bor
	local rshift = bit.rshift
	local lshift = bit.lshift
	local rol = bit.rol
	local arshift = bit.arshift
	local UINT_MAX = 4294967295
	local tonumber = tonumber

	local function mulull (a, m)
		local a_lo, a_hi = a[1], a[2]

		-- Long multiplication of two 32 bit operands into a
		-- 64 bit product.
		local m1 = m * 1ull
		local lo = a_lo * m1
		local hi = a_hi * m1
		local excess = rshift (hi, 32)
		local lohi = rshift (lo, 32)
		local carry

		hi = band (hi, 0xffffffffull)
		carry = rshift ((UINT_MAX - lohi) - hi, 63)
		excess = excess + carry
		hi = band (hi + lohi, 0xffffffffull)
		a[1] = tonumber (band (lo, 0xffffffffull))
		a[2] = tonumber (hi)
		return tonumber (excess)
	end

	local function addull (a, b)
		local along = 0x100000000ull * a[2] + a[1]
		local blong = 0x100000000ull * b[2] + b[1]
		local value = along + blong
		a[1] = tonumber (band (value, 0xffffffffull))
		a[2] = tonumber (rshift (value, 32))
	end

	local function addkull (a, k)
		local along = 0x100000000ull * a[2] + a[1]
		local value = along + k
		a[1] = tonumber (band (value, 0xffffffffull))
		a[2] = tonumber (rshift (value, 32))
	end

	-- Avoid expensive normalization by performing unsigned
	-- arithmetic.
	local function andull (a, b)
		a[1] = tonumber (band (a[1] * 1ull, b[1] * 1ull))
		a[2] = tonumber (band (a[2] * 1ull, b[2] * 1ull))
	end

	local function xorull (a, b)
		a[1] = tonumber (bxor (a[1] * 1ull, b[1] * 1ull))
		a[2] = tonumber (bxor (a[2] * 1ull, b[2] * 1ull))
	end

	local function rotlull (a, k)
		local along = 0x100000000ull * a[2] + a[1]
		local value = rol (along, k)
		a[1] = tonumber (band (value, 0xffffffffull))
		a[2] = tonumber (rshift (value, 32))
	end

	local function shrull (a, k)
		local along = 0x100000000ull * a[2] + a[1]
		local value = rshift (along, k)
		a[1] = tonumber (band (value, 0xffffffffull))
		a[2] = tonumber (rshift (value, 32))
	end

	local function ashrull (a, k)
		local along = 0x100000000ull * a[2] + a[1]
		local value = arshift (along, k)
		a[1] = tonumber (band (value, 0xffffffffull))
		a[2] = tonumber (rshift (value, 32))
	end

	local function shlull (a, k)
		local along = 0x100000000ull * a[2] + a[1]
		local value = lshift (along, k)
		a[1] = tonumber (band (value, 0xffffffffull))
		a[2] = tonumber (rshift (value, 32))
	end

	local function mul2ull (a, b)
		local along = 0x100000000ull * a[2] + a[1]
		local blong = 0x100000000ull * b[2] + b[1]
		local value = along * blong
		a[1] = tonumber (band (value, 0xffffffffull))
		a[2] = tonumber (rshift (value, 32))
	end
	return mulull, addull, addkull, andull, xorull,
		rotlull, shrull, ashrull, shlull, mul2ull
]]
	local fn = loadstring (str)
	mulull, addull, addkull, andull, xorull,
		rotlull, shrull, ashrull, shlull, mul2ull = fn ()
end

local function lj_test_assert (cond)
	assert (cond, [[PRNG validation failed.
Your LuaJIT installation (or Lua interpreter) is out-of-date and does not generate pseudo-random numbers correctly.  Mineclonia will not function under such a configuration in order to avoid scenarios where structure or level generation proceeds erroneously or inconsistently.  Please refer to https://luajit.org/install.html for details as regards updating your LuaJIT installation.]])
end

-- Tests.
if true then
	local x = ull (UINT_MAX, UINT_MAX)
	lj_test_assert (tostringull (x) == "18446744073709551615")

	local x = ull (0, UINT_MAX - 1)
	addull (x, ull (0, 2))
	lj_test_assert (tostringull (x) == tostring (UINT_MAX + 1))
	local x = ull (UINT_MAX, UINT_MAX)
	addull (x, ull (65535, 1))
	lj_test_assert (tostringull (x) == "281470681743360")
	local x = ull (UINT_MAX, UINT_MAX)
	negull (x)
	lj_test_assert (tostringull (x) == "1")
	local x = ull (0, 473902)
	subull (x, ull (0, 473904))
	local y = ull (0, 2)
	negull (y)
	lj_test_assert (equalull (x, y))
	lj_test_assert (tostringull (ull (2654435769, 2135587861)) == "11400714819323198485")
	lj_test_assert (tostringull (ull (1779033703, 4089235721)) == "7640891576956012809")

	local x = ull (0, UINT_MAX)
	shlull (x, 32)
	lj_test_assert (tostringull (x) == "18446744069414584320")
	shlull (x, 31)
	lj_test_assert (tostringull (x) == "9223372036854775808")
	local y = ull (0, UINT_MAX)
	shlull (y, 24)
	lj_test_assert (tostringull (y) == "72057594021150720")
	shlull (y, 8)
	lj_test_assert (tostringull (y) == "18446744069414584320")
	local y = ull (0, 1)
	shlull (y, 63)
	lj_test_assert (tostringull (y) == "9223372036854775808")

	local x = ull (UINT_MAX, 0)
	shrull (x, 32)
	lj_test_assert (tostringull (x) == tostring (UINT_MAX))

	local x = ull (0xffff, 0xffff0000)
	rotlull (x, 32)
	lj_test_assert (tostringull (x) == "18446462598732906495")

	local x = ull (0x8416021, 0x7307451e)
	rotlull (x, 17)
	lj_test_assert (tostringull (x) == "13853888353868189826")

	local x = ull (0x8416021, 0x7307451e)
	shrull (x, 47)
	lj_test_assert (tostringull (x) == "4226")

	local x = ull (0x9e3779b9, 0x7f4a7c15)
	shlull (x, 49)
	lj_test_assert (tostringull (x) == "17882105270427975680")

	local x = ull (0x9e3779b9, 0x7f4a7c15)
	shrull (x, 15)
	lj_test_assert (tostringull (x) == "347922205179540")

	local x = ull (0x9e3779b9, 0x7f4a7c15)
	lj_test_assert (divull (x, 2) == 1)
	lj_test_assert (tostringull (x) == "5700357409661599242")

	local x = ull (0x9e3779b9, 0x7f4a7c15)
	lj_test_assert (divull (x, 17) == 15)
	lj_test_assert (tostringull (x) == "670630283489599910")

	local x = ull (0x9e3779b9, 0x7f4a7c15)
	lj_test_assert (divull (x, 0x7fff) == 21333)
	lj_test_assert (tostringull (x) == "347932823246656")

	local x = ull (1024, 546633999)
	mulull (x, 64)
	lj_test_assert (tostringull (x) == "281509961286592")

	local x = ull (1024, 546633999)
	lj_test_assert (mulull (x, 0xffffffff) == 1024)
	lj_test_assert (tostringull (x) == "2347770749993551601")

	local x = ull (1024, 546633999)
	lj_test_assert (mulull (x, 0xffffaaaa) == 1024)
	lj_test_assert (tostringull (x) == "2251683482738776566")

	dtoull (x, 1.000000001 * 9.223372e18)
	lj_test_assert (tostringull (x) == "9223372009223372800")

	dtoull (x, -1.000000001 * 9.223372e18)
	lj_test_assert (tostringull (x) == "9223372064486178816")

	dtoull (x, -1.6168570900701e+18)
	lj_test_assert (tostringull (x) == "16829886983639451648")

	dtoull (x, -6.772123677161575 * 1034383538)
	lj_test_assert (tostringull (x) == "18446744066704578368")

	dtoull (x, -6.43123677161575 * 1034383538)
	lj_test_assert (tostringull (x) == "18446744067057186171")

	local x = ull (0xffffffff, 0xffffffff)
	local z = ull (0xffffffff, 0xffffffff)
	ashrull (x, 32)
	lj_test_assert (equalull (x, z))

	local x = ull (0xffffffff, 0xffffffff)
	local z = ull (0, 0xffffffff)
	shrull (x, 32)
	lj_test_assert (equalull (x, z))
end

mcl_levelgen.tostringull = tostringull
mcl_levelgen.ull = ull
mcl_levelgen.addull = addull
mcl_levelgen.addkull = addkull
mcl_levelgen.negull = negull
mcl_levelgen.subull = subull
mcl_levelgen.divull = divull
mcl_levelgen.mulull = mulull
mcl_levelgen.ashrull = ashrull
mcl_levelgen.shrull = shrull
mcl_levelgen.shlull = shlull
mcl_levelgen.rotlull = rotlull
mcl_levelgen.andull = andull
mcl_levelgen.xorull = xorull
mcl_levelgen.extull = extull
mcl_levelgen.extkull = extkull
mcl_levelgen.dtoull = dtoull
mcl_levelgen.stringtoull = stringtoull
mcl_levelgen.ltull = ltull

------------------------------------------------------------------------
-- Rng-number generator interface.
-- These wrappers for the built-in RNGs are not supported.
------------------------------------------------------------------------

local function djb (str)
	local h = 5381

	for c in str:gmatch (".") do
		h = math.fmod (h * 32 + h + string.byte (c), 2147483648)
	end
	return h
end

function mcl_levelgen.wrap_pr (pr)
	local r = 1 / 2147483647
	return {
		next_long = function (self)
			local max = 2147483647
			return ull (0, pr:next (0, max))
		end,
		next_boolean = function (self)
			return pr:next (1, 2) == 1
		end,
		next_integer = function (self)
			return pr:next (-2147483648, 2147483647)
		end,
		next_within = function (self, y)
			return pr:next (0, y - 1)
		end,
		next_float = function (self)
			return pr:next (0, 2147483647) * r
		end,
		next_double = function (self)
			return pr:next (0, 2147483647) * r
		end,
		fork = function (self)
			local pr = PcgRandom (self:next_integer (2147483647))
			return mcl_levelgen.wrap_pr (pr)
		end,
		fork_positional = function (self)
			local seed = self:next_integer (2147483647)
			return function (pos_or_string)
				if type (pos_or_string) == "string" then
					local hash = djb (pos_or_string)
					local variant = bxor (hash, seed)
					return mcl_levelgen.wrap_pr (PcgRandom (variant))
				else
					local node = core.hash_node_position (pos_or_string)
					local variant = bit.bxor (node, seed)
					return mcl_levelgen.wrap_pr (PcgRandom (variant))
				end
			end
		end,
		consume = function (self, n)
			for i = 1, n do
				pr:next (0, 2147483647)
			end
		end,
	}
end

function mcl_levelgen.wrap_random ()
	local r = 1 / 2147483647
	return {
		next_long = function (self)
			local max = 2147483647
			return ull (0, math.random (0, max))
		end,
		next_boolean = function (self)
			return math.random (1, 2) == 1
		end,
		next_integer = function (self)
			return math.random (-2147483648, 2147483647)
		end,
		next_within = function (self, y)
			return math.random (0, y - 1)
		end,
		next_float = function (self)
			return math.random (0, 2147483647) * r
		end,
		next_double = function (self)
			return math.random (0, 2147483647) * r
		end,
		fork = function (self)
			return self
		end,
		fork_positional = function (self)
			return function (pos)
				return self
			end
		end,
		consume = function (self, n)
		end,
	}
end

local mathsqrt = math.sqrt
local mathlog = math.log

local function marsaglia_polar_function (next_double)
	local spare = nil
	return function ()
		if spare then
			local v = spare
			spare = nil
			return v
		end

		local u, v, s
		repeat
			u = 2.0 * next_double () - 1.0
			v = 2.0 * next_double () - 1.0
			s = u * u + v * v
		until not (s >= 1.0 or s == 0.0)
		s = mathsqrt (-2.0 * mathlog (s) / s)
		spare = v * s
		return u * s
	end, function ()
		spare = nil
	end
end

------------------------------------------------------------------------
-- Minecraft-compatible Xoroshiro++ 128-bit RNG.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/util/math/random/Xoroshiro128PlusPlusRandom.html
------------------------------------------------------------------------

-- https://www.spigotmc.org/threads/fast-implementation-of-random-class.226728/
-- Pseudocode:
--
--    private static long
--    mix64 (long n)
--    {
--      n = (n ^ n >>> 30) * -4658895280553007687L;
--      n = (n ^ n >>> 27) * -7723592293110705685L;
--      return n ^ n >>> 31;
--    }

local function mix64 (n)
	local tmp = { n[1], n[2], }
	shrull (tmp, 30)
	xorull (n, tmp)
	tmp[1], tmp[2] = n[1], n[2]
	mulull (n, 0xbf58476d)
	mulull (tmp, 0x1ce4e5b9)
	shlull (n, 32)
	addull (n, tmp)
	tmp[1], tmp[2] = n[1], n[2]
	shrull (tmp, 27)
	xorull (n, tmp)
	tmp[1], tmp[2] = n[1], n[2]
	mulull (n, 0x94d049bb)
	shlull (n, 32)
	mulull (tmp, 0x133111eb)
	addull (n, tmp)
	tmp[1], tmp[2] = n[1], n[2]
	shrull (tmp, 31)
	xorull (n, tmp)
end

mcl_levelgen.mix64 = mix64

local HI_ADDEND = ull (0x9e3779b9, 0x7f4a7c15)
local LO_XOREND = ull (0x6a09e667, 0xf3bcc909)

local function seed_from_ull (lo, hi, ull)
	lo[1] = ull[1]
	lo[2] = ull[2]
	xorull (lo, LO_XOREND)
	hi[1] = lo[1]
	hi[2] = lo[2]
	addull (hi, HI_ADDEND)
end

mcl_levelgen.seed_from_ull = seed_from_ull

local function seed_from_string (lo, hi, str)
	local w1, w2, w3, w4
	local hash = mcl_levelgen.md5.sum (str)

	w1 = lshift (hash:byte (1), 24)
		+ lshift (hash:byte (2), 16)
		+ lshift (hash:byte (3), 8)
		+ hash:byte (4)
	w2 = lshift (hash:byte (5), 24)
		+ lshift (hash:byte (6), 16)
		+ lshift (hash:byte (7), 8)
		+ hash:byte (8)
	w3 = lshift (hash:byte (9), 24)
		+ lshift (hash:byte (10), 16)
		+ lshift (hash:byte (11), 8)
		+ hash:byte (12)
	w4 = lshift (hash:byte (13), 24)
		+ lshift (hash:byte (14), 16)
		+ lshift (hash:byte (15), 8)
		+ hash:byte (16)
	lo[1] = normalize (w2)
	lo[2] = normalize (w1)
	hi[1] = normalize (w4)
	hi[2] = normalize (w3)

	-- print ("seed_from_string (" .. str .. "): lo "
	--        .. tostringull (lo)
	--        .. " hi " .. tostringull (hi))
end

mcl_levelgen.seed_from_string = seed_from_string

local function sext (int)
	return band (int, 0x80000000) ~= 0 and UINT_MAX or 0
end

local tmp = ull (0, 0)

local function seed_from_position (seed, x, y, z)
	extkull (tmp, z)
	extkull (seed, x)
	mulull (seed, 3129871)
	seed[2] = sext (seed[1])
	mulull (tmp, 116129781)
	xorull (seed, tmp)
	extkull (tmp, y)
	xorull (seed, tmp)
	tmp[1] = seed[1]
	tmp[2] = seed[2]
	mul2ull (seed, tmp)
	mulull (seed, 42317861)
	mulull (tmp, 11)
	addull (seed, tmp)
	ashrull (seed, 16)
end

if true and detect_luajit () then
	local str = [[
	local rshift = bit.rshift
	local arshift = bit.arshift
	local lshift = bit.lshift
	local bxor = bit.bxor
	local band = bit.band
	local tonumber = tonumber

	local function lj_seed_from_position (seed, x, y, z)
		local x, y, z = x * 1ll * 1ull, y * 1ll * 1ull, z * 1ll * 1ull
		local xf = arshift (lshift (x * 3129871ull, 32), 32)
		local zf = z * 116129781ull
		local t1 = bxor (xf, bxor (zf, y))
		local value = arshift (t1 * t1 * 42317861ull + t1 * 11ull, 16)
		seed[1] = tonumber (band (value, 0xffffffff))
		seed[2] = tonumber (rshift (value, 32))
	end
	return lj_seed_from_position
]]
	local fn = loadstring (str)
	local lj_seed_from_position = fn ()
	if true then
		local backup = math.random ()
		math.randomseed (0)
		for i = 1, 100 do
			local x = math.random (-0x8000, 0x7fff)
			local y = math.random (-0x8000, 0x7fff)
			local z = math.random (-0x8000, 0x7fff)
			local ull1 = ull (0, 0)
			local ull2 = ull (0, 0)
			seed_from_position (ull1, x, y, z)
			lj_seed_from_position (ull2, x, y, z)
			lj_test_assert (equalull (ull1, ull2))
		end
		math.randomseed (backup)
	end
	seed_from_position = lj_seed_from_position
end

mcl_levelgen.seed_from_position = seed_from_position

local function xoroshiro_scale (bound, fn)
	local ilong = fn ()
	ilong[2] = 0
	mulull (ilong, bound)
	if ilong[1] < bound then
		local rem = fmod (normalize (-bound), bound)
		while ilong[1] < rem do
			ilong = fn ()
			ilong[2] = 0
			mulull (ilong, bound)
		end
	end
	return ilong[2]
end

function mcl_levelgen.xoroshiro_function (seedlo, seedhi)
	if zeroull (seedlo) and zeroull (seedhi) then
		seedlo[2], seedlo[1] = 0x9e3779b9, 0x7f4a7c15
		seedlo[2], seedlo[1] = 1779033703, 4089235721
	end
	local lo1, hi1 = { nil, nil, }, { nil, nil, }

	-- print ("seed: " .. tostringull (seedlo)
	--        .. " " .. tostringull (seedhi))

	local function getlong ()
		lo1[1] = seedlo[1]
		lo1[2] = seedlo[2]
		addull (lo1, seedhi)
		rotlull (lo1, 17)
		addull (lo1, seedlo)
		hi1[1] = seedhi[1]
		hi1[2] = seedhi[2]
		xorull (hi1, seedlo)
		rotlull (seedlo, 49)
		xorull (seedlo, hi1)
		local h1l, h1h = hi1[1], hi1[2]
		shlull (hi1, 21)
		xorull (seedlo, hi1)
		seedhi[1] = h1l
		seedhi[2] = h1h
		rotlull (seedhi, 28)
		return lo1
	end
	return getlong
end

local function unpack2 (x)
	return x[1], x[2]
end

function mcl_levelgen.xoroshiro (seedlo, seedhi)
	local seedlo = { seedlo[1], seedlo[2], }
	local seedhi = { seedhi[1], seedhi[2], }
	local fn = mcl_levelgen.xoroshiro_function (seedlo, seedhi)
	local r24 = 1 / 0xffffff
	local r53 = 1 / 0x1fffffffffffff
	local scratch = { nil, nil, }

	local function next_double (_)
		local ull = fn ()
		shrull (ull, 11)
		return (ull[2] * (UINT_MAX + 1) + ull[1]) * r53
	end
	local next_gaussian, reset_gaussian
		= marsaglia_polar_function (next_double)

	-- It is guaranteed that `next_integer' and `next_within' may
	-- safely be cached.
	return {
		next_long = fn,
		next_integer = function (self)
			local ull = fn ()
			return bor (ull[1], 0) -- Sign conversion only.
		end,
		next_within = function (self, y)
			return xoroshiro_scale (y, fn)
		end,
		next_boolean = function (self)
			return band (fn ()[1], 1) ~= 0
		end,
		next_float = function (self)
			local ull = fn ()
			shrull (ull, 40)
			return ull[1] * r24
		end,
		next_double = next_double,
		fork = function (self)
			local lo1, hi1 = unpack2 (fn ())
			local lo2, hi2 = unpack2 (fn ())
			return mcl_levelgen.xoroshiro (ull (hi1, lo1),
						       ull (hi2, lo2))
		end,
		fork_into = function (self, other)
			local lo1, hi1 = unpack2 (fn ())
			local lo2, hi2 = unpack2 (fn ())
			local data = other.reseeding_data
			local hi_seed = data[6]
			local lo_seed = data[5]
			if zeroull (lo_seed) and zeroull (hi_seed) then
				lo_seed[2], lo_seed[1] = 0x9e3779b9, 0x7f4a7c15
				hi_seed[2], hi_seed[1] = 1779033703, 4089235721
			else
				lo_seed[1] = lo1
				lo_seed[2] = hi1
				hi_seed[1] = lo2
				hi_seed[2] = hi2
			end
			other:reset_gaussian ()
		end,
		fork_positional = function (self)
			local lo1, hi1 = unpack2 (fn ())
			local lo2, hi2 = unpack2 (fn ())

			local function factory (pos_or_string)
				if type (pos_or_string) == "string" then
					local lo, hi = ull (nil, nil), ull (nil, nil)
					seed_from_string (lo, hi, pos_or_string)

					local lo_seed = ull (hi1, lo1)
					local hi_seed = ull (hi2, lo2)
					xorull (lo_seed, lo)
					xorull (hi_seed, hi)
					-- print ("Seed: ", pos_or_string, tostringull (lo_seed),
					--        tostringull (hi_seed))
					return mcl_levelgen.xoroshiro (lo_seed, hi_seed)
				else
					local hash = ull (nil, nil)
					seed_from_position (hash, pos_or_string.x,
							    pos_or_string.y,
							    pos_or_string.z)
					local lo_seed = ull (hi1, lo1)
					local hi_seed = ull (hi2, lo2)
					xorull (lo_seed, hash)
					return mcl_levelgen.xoroshiro (lo_seed, hi_seed)
				end
			end

			local function create_reseedable (_)
				local lo_seed = ull (hi1, lo1)
				local hi_seed = ull (hi2, lo2)
				local tbl, lo_seed, hi_seed
					= mcl_levelgen.xoroshiro (lo_seed, hi_seed)
				tbl.reseeding_data = { lo1, hi1, lo2, hi2,
						       lo_seed, hi_seed, }
				return tbl
			end
			local tbl = {
				factory = factory,
				create_reseedable = create_reseedable,
			}
			setmetatable (tbl, {
				__call = function (_, pos_or_string)
					return factory (pos_or_string)
				end,
			})
			return tbl
		end,
		consume = function (self, n)
			for i = 1, n do
				fn ()
			end
		end,
		reseed_positional = function (self, x, y, z)
			local reseeding_data = self.reseeding_data
			-- The next two arrays hold the state retained
			-- by the RNG function as upvalues.
			local hi_seed = reseeding_data[6]
			local lo_seed = reseeding_data[5]
			local hi2 = reseeding_data[4]
			local lo2 = reseeding_data[3]
			local hi1 = reseeding_data[2]
			local lo1 = reseeding_data[1]

			seed_from_position (scratch, x, y, z)
			hi_seed[1] = lo2
			hi_seed[2] = hi2
			lo_seed[1] = lo1
			lo_seed[2] = hi1
			xorull (lo_seed, scratch)
			if zeroull (lo_seed) and zeroull (hi_seed) then
				seedlo[2], seedlo[1] = 0x9e3779b9, 0x7f4a7c15
				hi_seed[2], hi_seed[1] = 1779033703, 4089235721
			end
			reset_gaussian ()
		end,
		reseeding_data = {
			false, false, false, false,
			seedlo, seedhi,
		},
		reseed = function (self, ull)
			seed_from_ull (seedlo, seedhi, ull)
			mix64 (seedlo)
			mix64 (seedhi)
			if zeroull (seedlo) and zeroull (seedhi) then
				seedlo[2], seedlo[1] = 0x9e3779b9, 0x7f4a7c15
				seedhi[2], seedhi[1] = 1779033703, 4089235721
			end
			reset_gaussian ()
		end,
		next_gaussian = next_gaussian,
		reset_gaussian = reset_gaussian,
	}, seedlo, seedhi
end

if true then
	local x = mcl_levelgen.xoroshiro (ull (0, 1000),
					  ull (0, 1000))
	local factory = x:fork_positional ()
	local reseedable = factory:create_reseedable ()

	for i = 1, 100 do
		local x, y, z = x:next_within (1000) - 500,
			x:next_within (1000) - 500,
			x:next_within (1000) - 500
		reseedable:reseed_positional (x, y, z)
		local factory_value
			= factory ({x = x, y = y, z = z,}):next_long ()
		local value = reseedable:next_long ()
		lj_test_assert (equalull (value, factory_value))
	end

	local seed1 = ull (0, 0)
	local seed2 = ull (0, 0)
	local x = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))
	stringtoull (seed1, "3948575739")
	stringtoull (seed2, "18413248036093821064")
	x:reseed (seed1)
	lj_test_assert (tostringull (x:next_long ()) == "1166925898593515289")
	lj_test_assert (tostringull (x:next_long ()) == "3959461064507847451")
	lj_test_assert (tostringull (x:next_long ()) == "12831638853348124801")
	x:reseed (seed2)
	lj_test_assert (tostringull (x:next_long ()) == "17696910518188760863")
	lj_test_assert (tostringull (x:next_long ()) == "4876660131927854451")
	lj_test_assert (tostringull (x:next_long ()) == "2153688626528828990")

	local seed = ull (0, 0)
	stringtoull (seed, "300980754")
	seed_from_ull (seed1, seed2, seed)
	mix64 (seed1)
	mix64 (seed2)
	local x = mcl_levelgen.xoroshiro (seed1, seed2)
	local abs = math.abs
	local D = 16e-15
	lj_test_assert (abs (x:next_gaussian () - 0.05778929000253813) < D)
	lj_test_assert (abs (x:next_gaussian () - -0.0010128593488433443) < D)
	lj_test_assert (abs (x:next_gaussian () - -0.1341293654492881) < D)
	lj_test_assert (abs (x:next_gaussian () - -0.78415967880207) < D)
	lj_test_assert (abs (x:next_gaussian () - 0.6635210098754315) < D)
	lj_test_assert (abs (x:next_gaussian () - -0.26174819256398935) < D)
end

-- luacheck: push ignore 511
if false then
	local source = mcl_levelgen.xoroshiro (ull (0, 1000), ull (0, 1000))
	print (tostringull (source:next_long ()))
	local factory = source:fork_positional ()
	print (tostringull (source:fork ():next_long ()))
	local source1 = factory ({ x = 140, y = -230, z = 140, })
	print (tostringull (source1:next_long ()))
	print (tostringull (source1:next_long ()))
	print (tostringull (factory ({ x = 334, y = 470, z = -88837, }):next_long ()))

	local seedlo = mcl_levelgen.ull (0, 0)
	local seedhi = mcl_levelgen.ull (0, 0)
	mcl_levelgen.seed_from_ull (seedlo, seedhi, mcl_levelgen.ull (0, 0))
	mcl_levelgen.mix64 (seedlo)
	mcl_levelgen.mix64 (seedhi)
	local rng = mcl_levelgen.xoroshiro (seedlo, seedhi)
	rng:consume (3)
	print ((rng:next_within (256)))
	print ((rng:next_within (255)))
	print ((rng:next_within (254)))
	print ((rng:next_within (253)))
end

if true then
	local source
		= mcl_levelgen.xoroshiro (ull (0, 1000), ull (0, 1000))
	local source_1
		= mcl_levelgen.xoroshiro (ull (0, 1000), ull (0, 1000))
	local other = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))

	for i = 1, 100 do
		local fork = source:fork ()
		source_1:fork_into (other)

		for i = 1, 1000 do
			local a, b = fork:next_integer (3000), other:next_integer (3000)
			lj_test_assert (a == b)
		end
	end
end
-- luacheck: pop

------------------------------------------------------------------------
-- Minecraft-compatible JVM LCG.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/util/math/random/Random.html
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/util/math/random/LocalRandom.html
------------------------------------------------------------------------

local MULTIPLIER = ull (5, 3740067437)
local SEED_MASK = ull (0xffff, 0xffffffff)

local function jvm_lcg (seed0)
	local seed, tmp = ull (seed0[2], seed0[1]), ull (0, 0)

	xorull (seed, MULTIPLIER)
	andull (seed, SEED_MASK)

	return function (nbits)
		tmp[1], tmp[2] = seed[1], seed[2]
		mulull (tmp, 0x5)
		shlull (tmp, 32)
		mulull (seed, 0xdeece66d)
		addull (seed, tmp)
		addkull (seed, 11)
		andull (seed, SEED_MASK)
		tmp[1], tmp[2] = seed[1], seed[2]
		-- https://bugs.mojang.com/browse/MC/issues/MC-239059
		ashrull (tmp, 48 - nbits)
		return tmp[1]
	end, seed
end

mcl_levelgen.jvm_lcg = jvm_lcg

local function jvm_hash (str)
	local h = 0
	for c in str:gmatch (".") do
		h = math.fmod (31 * h + string.byte (c), UINT_MAX + 1)
	end
	return h
end

mcl_levelgen.jvm_hash = jvm_hash

function mcl_levelgen.jvm_random (seed)
	local fn, seed_storage = jvm_lcg (seed)
	local r24 = 1 / 0xffffff
	local r53 = 1 / 0x1fffffffffffff
	local scratch = ull (nil, nil)
	local scratch1 = ull (nil, nil)

	local function next_double (_)
		local ull = ull (0, fn (26))
		shlull (ull, 27)
		addkull (ull, fn (27))
		return (ull[2] * (UINT_MAX + 1) + ull[1]) * r53
	end
	local next_gaussian, reset_gaussian
		= marsaglia_polar_function (next_double)

	-- It is guaranteed that `next_integer' and `next_within' may
	-- safely be cached.
	return {
		next_long = function (self)
			local hi, lo = fn (32), fn (32)
			scratch[2] = hi
			scratch[1] = 0
			scratch1[2] = sext (lo)
			scratch1[1] = lo
			addull (scratch, scratch1)
			return scratch
		end,
		next_integer = function (self)
			return bor (fn (32), 0) -- Sign conversion only.
		end,
		next_within = function (self, y)
			if band (y, y - 1) == 0 then -- If power of 2.
				-- Use optimized routine.
				extkull (scratch, fn (31))
				extkull (scratch1, y)
				mul2ull (scratch, scratch1)
				ashrull (scratch, 31)
				return scratch[1]
			end

			local n, m
			n = fn (31)
			m = n % y
			while (n - m + (y - 1)) >= 0x7fffffff do
				n = fn (31)
				m = n % y
			end
			return m
		end,
		next_boolean = function (self)
			return fn (1) ~= 0
		end,
		next_float = function (self)
			return fn (24) * r24
		end,
		next_double = next_double,
		fork = function (self)
			return mcl_levelgen.jvm_random (self:next_long ())
		end,
		fork_into = function (self, other)
			other:reseed (self:next_long ())
		end,
		fork_positional = function (self)
			local seed = self:next_long ()
			seed = ull (seed[2], seed[1])

			local function factory (pos_or_string)
				if type (pos_or_string) == "string" then
					local hash = jvm_hash (pos_or_string)
					local hash = extull (hash)
					xorull (hash, seed)
					return mcl_levelgen.jvm_random (hash)
				else
					local hash = ull (nil, nil)
					seed_from_position (hash, pos_or_string.x,
							    pos_or_string.y,
							    pos_or_string.z)
					xorull (hash, seed)
					return mcl_levelgen.jvm_random (hash)
				end
			end

			local function create_reseedable (_)
				local rng, seed_storage
					= mcl_levelgen.jvm_random (seed)
				rng.reseeding_data = {
					seed, seed_storage,
				}
				return rng
			end

			local tbl = {
				factory = factory,
				create_reseedable = create_reseedable,
			}
			setmetatable (tbl, {
				__call = function (_, pos_or_string)
					return factory (pos_or_string)
				end,
			})
			return tbl
		end,
		consume = function (self, n)
			for i = 1, n do
				fn (32)
			end
		end,
		reseed_positional = function (self, x, y, z)
			local data = self.reseeding_data
			local seed, storage = data[1], data[2]
			seed_from_position (scratch1, x, y, z)
			storage[1] = seed[1]
			storage[2] = seed[2]
			xorull (storage, scratch1)
			xorull (storage, MULTIPLIER)
			andull (storage, SEED_MASK)
			reset_gaussian ()
		end,
		reseeding_data = {
			false, seed_storage,
		},
		reseed = function (self, seed)
			local storage = seed_storage
			storage[1] = seed[1]
			storage[2] = seed[2]
			xorull (storage, MULTIPLIER)
			andull (storage, SEED_MASK)
			reset_gaussian ()
		end,
		next_gaussian = next_gaussian,
		reset_gaussian = reset_gaussian,
	}, seed_storage
end

if true then
	local x = mcl_levelgen.jvm_random (extull (-44753374))
	local factory = x:fork_positional ()
	local reseedable = factory:create_reseedable ()

	for i = 1, 100 do
		local x, y, z = x:next_within (1000) - 500,
			x:next_within (1000) - 500,
			x:next_within (1000) - 500
		reseedable:reseed_positional (x, y, z)
		local factory_value
			= factory ({x = x, y = y, z = z,}):next_long ()
		local value = reseedable:next_long ()
		lj_test_assert (equalull (value, factory_value))
	end

	local x = mcl_levelgen.jvm_random (extull (0))
	local seed1 = ull (0, 0)
	local seed2 = ull (0, 0)
	stringtoull (seed1, "3948575739")
	stringtoull (seed2, "18413248036093821064")
	x:reseed (seed1)
	lj_test_assert (tostringull (x:next_long ()) == "11919139927092448892")
	lj_test_assert (tostringull (x:next_long ()) == "13835344951310129447")
	lj_test_assert (tostringull (x:next_long ()) == "13590812842237688474")
	x:reseed (seed2)
	lj_test_assert (tostringull (x:next_long ()) == "5543589759440410229")
	lj_test_assert (tostringull (x:next_long ()) == "4799685316607659139")
	lj_test_assert (tostringull (x:next_long ()) == "12852779243211759225")
end

if true then
	local source
		= mcl_levelgen.jvm_random (ull (0, 1000))
	local source_1
		= mcl_levelgen.jvm_random (ull (0, 1000))
	local other = mcl_levelgen.jvm_random (ull (0, 0))

	for i = 1, 100 do
		local fork = source:fork ()
		source_1:fork_into (other)

		for i = 1, 1000 do
			local a, b = fork:next_integer (3000), other:next_integer (3000)
			lj_test_assert (a == b)
		end
	end
end

-- luacheck: push ignore 511
if false then
	local x = mcl_levelgen.jvm_random (extull (-44753374))
	print (x:next_integer (32))
	print (tostringull (x:next_long ()))
	print (x:next_float ())
	print (x:next_double ())
	print (x:next_boolean ())
	print (x:next_boolean ())
	print (x:next_boolean ())
	print (x:next_boolean ())
	print (x:next_boolean ())
	print (x:next_boolean ())
	print (x:next_boolean ())
	print (x:next_boolean ())
	print (x:next_boolean ())
	print (x:next_boolean ())
	print (x:next_within (32))
	print (x:next_within (64))
	print (x:next_within (128))
	print (x:next_within (256))
	print (x:next_within (16777216))
	print (x:next_within (1073741824))
	print (x:next_within (4794287))
	print (x:next_within (4794287))
	print (x:next_within (4794287))
	print (x:next_within (4794287))
	print (x:next_within (4794287))
	print (x:next_within (4794287))
	print (x:next_within (4794287))
	print (x:next_within (4794287))
	print (x:next_within (4794287))
	print (x:next_within (900384))
	print (x:next_within (900384))
	print (x:next_within (900384))
	print (x:next_within (900384))
	print (x:next_within (900384))
	print (x:next_within (900384))
	print (x:next_within (900384))
	print (x:next_within (900384))
	print (x:next_within (0x7fffffff))
	print (x:next_within (0x7fffffff))
	print (x:next_within (0x7fffffff))
	print (x:next_within (0x7fffffff))
	local factory = x:fork_positional ()
	print (factory ({ x = 120, y = 120, z = -370, }):next_integer ())
	print (factory ({ x = 120, y = 120, z = -370, }):next_integer ())
	print (factory ("sticking it to microsoft"):next_integer ())
	print (factory ("========================"):next_integer ())
end
-- luacheck: pop

------------------------------------------------------------------------
-- Biome position randomization.
------------------------------------------------------------------------

-- Simple LCG.
local MULTIPLIER = ull (0x5851f42d, 0x4c957f2d)
local INCREMENT = ull (0x14057b7e, 0xf767814f)

local tmp = ull (0, 0)

local function lcj_next (seed, increment)
	tmp[1] = seed[1]
	tmp[2] = seed[2]

	-- seed = (seed * (seed * MULTIPLIER + INCREMENT))
	mul2ull (tmp, MULTIPLIER)
	addull (tmp, INCREMENT)
	mul2ull (seed, tmp)
	addull (seed, increment)
end

if detect_luajit () then
	local str = [[
	local band = bit.band
	local rshift = bit.rshift
	local tonumber = tonumber
	local function lcj_next (seed, increment)
		local cseed = 0x100000000ull * seed[2] + seed[1]
		local increment
			= 0x100000000ull * increment[2] + increment[1]
		cseed = cseed * (cseed * 0x5851f42d4c957f2dull
				 + 0x14057b7ef767814full)
			+ increment
		seed[1] = tonumber (band (cseed, 0xffffffff))
		seed[2] = tonumber (rshift (cseed, 32))
	end
	return lcj_next
]]
	local fn = loadstring (str)
	lcj_next = fn ()
end

mcl_levelgen.lcj_next = lcj_next

-- luacheck: push ignore 511
if true then
	local seed = ull (99012, 99374)
	local incr = ull (339487593, 444335790)
	local function test (seed, value)
		if false then
			print (seed)
		else
			lj_test_assert (seed == value)
		end
	end
	-- print ("seed: ", tostringull (seed), "incr: ", tostringull (incr))
	lcj_next (seed, incr)
	test (tostringull (seed), "226211238292676308")
	lcj_next (seed, incr)
	test (tostringull (seed), "6872378287299025514")
	lcj_next (seed, incr)
	test (tostringull (seed), "17378588871388729976")
	lcj_next (seed, incr)
	test (tostringull (seed), "1242224386663429366")
	lcj_next (seed, incr)
	test (tostringull (seed), "1805386566417395244")
	lcj_next (seed, incr)
	test (tostringull (seed), "12805274662464243346")
	lcj_next (seed, incr)
	test (tostringull (seed), "14060706522678048432")
	lcj_next (seed, incr)
	test (tostringull (seed), "12111425423540952062")
	lcj_next (seed, incr)
	test (tostringull (seed), "7280341539614422212")
	lcj_next (seed, incr)
	test (tostringull (seed), "7655099306983539706")

	local seed1 = ull (0, 0)
	stringtoull (seed1, "2520521153677540398")
	stringtoull (incr, "162")
	lcj_next (seed1, incr)
	test (tostringull (seed1), "14919993831747797192")
end
-- luacheck: pop

local function biomeseedull (dst, seed)
	local lo, hi = seed[1], seed[2]
	local str = string.char (band (lo, 0xff))
		.. string.char (band (rshift (lo, 0x8), 0xff))
		.. string.char (band (rshift (lo, 0x10), 0xff))
		.. string.char (band (rshift (lo, 0x18), 0xff))
		.. string.char (band (hi, 0xff))
		.. string.char (band (rshift (hi, 0x8), 0xff))
		.. string.char (band (rshift (hi, 0x10), 0xff))
		.. string.char (band (rshift (hi, 0x18), 0xff))
	local shasum = mcl_levelgen.sha.sha256 (str):sub (1, 16)
	lo = 0
	for i = 0, 3 do
		local byte = tonumber (shasum:sub (i * 2 + 1, i * 2 + 2), 16)
		lo = bor (lo, lshift (byte, i * 8))
	end
	hi = 0
	for i = 4, 7 do
		local byte = tonumber (shasum:sub (i * 2 + 1, i * 2 + 2), 16)
		hi = bor (hi, lshift (byte, (i - 4) * 8))
	end
	dst[1] = normalize (lo)
	dst[2] = normalize (hi)
end

mcl_levelgen.biomeseedull = biomeseedull

if true then
	local seed1 = ull (0, 0)
	stringtoull (seed1, "3948575739")
	local seed2 = ull (0, 0)
	stringtoull (seed2, "18413248036093821064")
	biomeseedull (seed1, seed1)
	biomeseedull (seed2, seed2)
	lj_test_assert (tostringull (seed1) == "17623870130031917223")
	lj_test_assert (tostringull (seed2) == "6736552460589820823")
end

------------------------------------------------------------------------
-- Level decoration, structure, and carver randomization.
------------------------------------------------------------------------

-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1
-- /net/minecraft/util/math/random/ChunkRandom.html#setCarverSeed(long,int,int)

-- Temporaries for set_carver_seed and friends.
local tmp, tmp1, cxu, czu = ull (0, 0), ull (0, 0), ull (0, 0), ull (0, 0)

function mcl_levelgen.set_carver_seed (rng, seed, cx, cz)
	rng:reseed (seed)

	local a = rng:next_long ()
	tmp[1], tmp[2], a = a[1], a[2], tmp
	local b = rng:next_long ()

	-- (long) cx * a ^ (long) cz * b ^ seed
	extkull (cxu, cx)
	extkull (czu, cz)
	mul2ull (cxu, a)
	mul2ull (czu, b)
	xorull (cxu, czu)
	xorull (cxu, seed)
	rng:reseed (cxu)
end

if true then
	local lcg = mcl_levelgen.jvm_random (ull (0, 0))
	mcl_levelgen.set_carver_seed (lcg, extull (304853), 25, 45)
	lj_test_assert (lcg:next_within (5000) == 2936)
	lj_test_assert (lcg:next_within (5000) == 4880)
	lj_test_assert (lcg:next_within (5000) == 4375)
	mcl_levelgen.set_carver_seed (lcg, extull (304853), -2503, -1774)
	lj_test_assert (lcg:next_within (5000) == 4611)
	lj_test_assert (lcg:next_within (5000) == 2202)
	lj_test_assert (lcg:next_within (5000) == 4126)
end

function mcl_levelgen.set_population_seed (rng, seed, cx, cz)
	rng:reseed (seed)
	local a = rng:next_long ()
	tmp[1], tmp[2], a = a[1], a[2], tmp
	local b = rng:next_long ()
	tmp1[1], tmp1[2], b = b[1], b[2], tmp1

	-- (long) cx * (a | 1) + (long) cz * (b | 1) ^ seed
	a[1] = normalize (bor (a[1], 1))
	b[1] = normalize (bor (b[1], 1))
	extkull (cxu, cx)
	extkull (czu, cz)
	mul2ull (a, cxu)
	mul2ull (b, czu)
	addull (a, b)
	xorull (a, seed)
	rng:reseed (a)
	return a
end

function mcl_levelgen.set_decorator_seed (rng, pop, index, step)
	czu[1], czu[2] = pop[1], pop[2]
	extkull (cxu, index)
	addull (czu, cxu)
	extkull (cxu, fmod (step * 10000, 0x80000000))
	addull (czu, cxu)
	rng:reseed (czu)
end

if true then
	local lcg = mcl_levelgen.jvm_random (ull (0, 0))
	local pop = mcl_levelgen.set_population_seed (lcg, extull (304853),
						      -11270, 9304)
	lj_test_assert (lcg:next_within (5000) == 1925)
	lj_test_assert (lcg:next_within (5000) == 182)
	lj_test_assert (lcg:next_within (5000) == 75)
	mcl_levelgen.set_decorator_seed (lcg, pop, 33, 11)
	lj_test_assert (lcg:next_within (5000) == 2357)
	lj_test_assert (lcg:next_within (5000) == 4883)
	lj_test_assert (lcg:next_within (5000) == 3244)
end

-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/
-- net/minecraft/util/math/random/ChunkRandom.html#setRegionSeed(long,int,int,int)
-- https://github.com/spawnmason/randar-explanation/issues/3
-- https://www.minecraftforum.net/forums/minecraft-java-edition/seeds/3004110-repeating-decorations-trees-ores-etc-seeds

local REGION_X_MULTIPLIER = ull (0x4f, 0x9939f508)
local REGION_Z_MULTIPLIER = ull (0x1e, 0xf1565bd5)

local rxu, rzu = ull (0, 0), ull (0, 0)

function mcl_levelgen.set_region_seed (rng, level_seed, region_x, region_z,
				       salt)
	extkull (rxu, region_x)
	extkull (rzu, region_z)
	mul2ull (rxu, REGION_X_MULTIPLIER)
	mul2ull (rzu, REGION_Z_MULTIPLIER)
	addull (rxu, rzu)
	addull (rxu, level_seed)
	extkull (rzu, salt)
	addull (rxu, rzu)
	rng:reseed (rxu)
end

if true then
	local lcg = mcl_levelgen.jvm_random (ull (0, 0))
	local level_seed = ull (0, 0)
	stringtoull (level_seed, "3689348814741910323")
	mcl_levelgen.set_region_seed (lcg, level_seed, 353, 192, -77583)
	lj_test_assert (lcg:next_within (5000) == 3651)
	lj_test_assert (lcg:next_within (5000) == 716)
	lj_test_assert (lcg:next_within (5000) == 4205)
	lj_test_assert (lcg:next_within (5000) == 4093)
	stringtoull (level_seed, "194")
	mcl_levelgen.set_region_seed (lcg, level_seed, -442, -757, 1210)
	lj_test_assert (lcg:next_within (5000) == 838)
	lj_test_assert (lcg:next_within (5000) == 4832)
	lj_test_assert (lcg:next_within (5000) == 3972)
	lj_test_assert (lcg:next_within (5000) == 253)
end

local SLIME_CHUNK_MULTIPLIER_1 = ull (0, 0x4c1906)
local SLIME_CHUNK_MULTIPLIER_2 = ull (0, 0x5ac0db)
local SLIME_CHUNK_MULTIPLIER_3 = ull (0, 0x4307a7)
local SLIME_CHUNK_MULTIPLIER_4 = ull (0, 0x5f24f)

local xxu = ull (0, 0)
local xzu = ull (0, 0)
local xsc = ull (0, 0)

function mcl_levelgen.set_slime_chunk_seed (rng, level_seed, region_x, region_z, salt)
	extkull (xxu, region_x)
	extkull (xzu, region_x)
	xsc[1], xsc[2] = level_seed[1], level_seed[2]

	mul2ull (xxu, xxu)
	extkull (xxu, xxu[1])
	mul2ull (xxu, SLIME_CHUNK_MULTIPLIER_1)
	extkull (xxu, xxu[1])
	addull (xsc, xxu)

	mul2ull (xzu, SLIME_CHUNK_MULTIPLIER_2)
	extkull (xzu, xzu[1])
	addull (xsc, xzu)

	extkull (xxu, region_z)
	extkull (xzu, region_z)

	mul2ull (xxu, xxu)
	extkull (xxu, xxu[1])
	mul2ull (xxu, SLIME_CHUNK_MULTIPLIER_3)
	addull (xsc, xxu)

	mul2ull (xzu, SLIME_CHUNK_MULTIPLIER_4)
	extkull (xzu, xzu[1])
	addull (xsc, xzu)
	xorull (xsc, salt)
	rng:reseed (xsc)
end

-- luacheck: push ignore 511
if false then
	local rng = mcl_levelgen.jvm_random (ull (0, 0))
	local level_seed = ull (0, 0)
	local salt = ull (0, 0)
	stringtoull (level_seed, "193039485749")
	stringtoull (salt, "987234911")
	for x = -10, 10 do
		for z = -10, 10 do
			mcl_levelgen.set_slime_chunk_seed (rng, level_seed, x, z, salt)
			print (rng:next_within (10))
		end
	end
end
-- luacheck: pop
