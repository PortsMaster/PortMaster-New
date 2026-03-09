local sqrt = math.sqrt
local floor = math.floor
local mathmax = math.max

local function sieve_of_eratosthenes (x)
	if x < 2 then
		return nil
	end

	local sieve = {}
	sieve[1] = false
	for i = 2, x do
		sieve[i] = true
	end

	for i = 2, floor (sqrt (x)) do
		if sieve[i] then
			for j = i * i, x, i do
				sieve[j] = false
			end
		end
	end

	return sieve
end

local function isprime (sieve, value)
	local value = sieve[value]
	assert (value ~= nil)
	return value
end

local function next_prime (i, sieve)
	if i % 2 == 0 then
		i = i + 1
	end
	while not isprime (sieve, i) do
		i = i + 2
	end
	return i
end

-- https://github.com/pcordes/allspr/blob/f83fe5a866d784de947321a0be140e815249a9e5/lcg.c#L117

local K = 0.5 - sqrt (3) / 6.0

local function findlcg (maxval)
	local m, a, b, c = maxval
	if m <= 6 then
		b = 0
		c = 1
	else
		local sieve = sieve_of_eratosthenes (maxval + floor (maxval / 2))
		local divlimit = m
		-- b must be a multiple of all of m's prime factors
		-- (so that b+1 may be a valid multiplier as holden by
		-- the Hull-Dobel theorem).
		b = 1
		if m % 2 == 0 then
			b = 2
			while divlimit % 2 == 0 do
				divlimit = floor (divlimit / 2)
			end
		end

		for i = 3, divlimit, 2 do
			if isprime (sieve, i) and m % i == 0 then
				b = b * i
				while divlimit % i == 0 do
					divlimit = floor (divlimit / i)
				end
			end
		end

		-- If m is a mult of 4, b must be also.
		if m % 4 == 0 then
			while b % 4 ~= 0 do
				b = b * 2
			end
		end

		-- Make sure a isn't too small.
		while b < sqrt (m) do
			b = b * 7
		end

		-- Give up otherwise.
		if b == m then
			b = 0
		end

		c = next_prime (floor (mathmax (5, K * m - 2)), sieve)
		while m % c == 0 do
			c = next_prime (c + 1, sieve)
		end
	end

	a = b + 1
	return a, c, m
end

local function lcg_next (a, c, m, state)
	return (a * state + c) % m
end

for i = 1, 1024 do
	local a, c, m = findlcg (i)
	local state = math.random (0, m - 1)
	local seen = {}

	for j = 1, i + 1 do
		print (state, seen[state])
		seen[state] = true
		state = lcg_next (a, c, m, state)
	end
	print ("--> Done: ", i)
end
