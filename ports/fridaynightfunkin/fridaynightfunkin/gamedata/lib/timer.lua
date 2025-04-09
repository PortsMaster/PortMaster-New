--[[
Copyright (c) 2010-2013 Matthias Richter
Edited by Stilic for FNF-LÖVE

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]
--
local Timer = {}
Timer.__index = Timer

function Timer:setSpeed(speed) self.speed = speed end

function Timer:updateHandle(handle, dt)
	-- handle: {
	--   time = <number>,
	--   after = <function>,
	--   during = <function>,
	--   limit = <number>,
	--   count = <number>,
	-- }
	dt = dt * self.speed
	handle.time = handle.time + dt
	handle.during(dt, math.max(handle.limit - handle.time, 0))

	while handle.time >= handle.limit and handle.count > 0 do
		if handle.after(handle.after) == false then
			handle.count = 0
			break
		end
		handle.time = handle.time - handle.limit
		handle.count = handle.count - 1
	end
end

function Timer:update(dt)
	-- timers may create new timers, which leads to undefined behavior
	-- in pairs() - so we need to put them in a different table first
	local to_update = {}
	for handle in pairs(self.functions) do to_update[handle] = handle end

	for handle in pairs(to_update) do
		if self.functions[handle] then
			self:updateHandle(handle, dt)
			if handle.count == 0 then self.functions[handle] = nil end
		end
	end
end

function Timer:during(delay, during, after)
	local handle = {
		time = 0,
		during = during,
		after = after or __NULL__,
		limit = delay,
		count = 1
	}
	self.functions[handle] = true
	return handle
end

function Timer:after(delay, func) return self:during(delay, __NULL__, func) end

function Timer:every(delay, after, count)
	local count = count or math.huge -- exploit below: math.huge - 1 = math.huge
	local handle = {
		time = 0,
		during = __NULL__,
		after = after,
		limit = delay,
		count = count
	}
	self.functions[handle] = true
	return handle
end

function Timer:cancel(handle) self.functions[handle] = nil end

function Timer:cancelTweensOf(subject)
	-- same as for the update function
	local to_check = {}
	for handle in pairs(self.functions) do to_check[handle] = handle end

	for handle in pairs(to_check) do
		if self.functions[handle] and handle.subject == subject then
			self:cancel(handle)
		end
	end
end

function Timer:clear() self.functions = {} end

function Timer:script(f)
	local co = coroutine.wrap(f)
	co(function(t)
		self:after(t, co)
		coroutine.yield()
	end)
end

local function func_tween(tween, self, len, subject, target, method, after,
						  setters_and_getters, delay, ...)
	-- recursively collects fields that are defined in both subject and target into a flat list
	-- re-use of ref is confusing
	local to_func_tween = {}
	local function set_and_get(subject, k, v)
		setters_and_getters = setters_and_getters or {}

		local setter, getter
		if setters_and_getters[k] then
			setter, getter = unpack(setters_and_getters[k])
		else
			setter = subject['set' .. k]
			getter = subject['get' .. k]
		end
		assert(setter and getter,
			"key's value in subject is nil with no set/getter")

		if to_func_tween[subject] == nil then to_func_tween[subject] = {} end

		ref = {getter(subject)}
		to_func_tween[subject][k] = {ref, setter}
		if type(v) == 'number' or #ref == 1 then v = {v} end
		return ref, v
	end

	local function tween_collect_payload(subject, target, out)
		for k, v in pairs(target) do
			-- this might not be the smoothest way to do this
			local ref = subject[k]
			if ref == nil then ref, v = set_and_get(subject, k, v) end
			assert(type(v) == type(ref), 'Type mismatch in field "' .. k ..
				'". ' .. type(v) .. ' vs ' .. type(ref))
			if type(v) == 'table' then
				tween_collect_payload(ref, v, out)
			else
				local ok, delta = pcall(function()
					return (v - ref) * 1
				end)
				assert(ok, 'Field "' .. k ..
					'" does not support arithmetic operations')
				out[#out + 1] = {subject, k, delta}
			end
		end
		return out
	end

	method = tween[method or 'linear'] -- see __index
	local payload, t, args = tween_collect_payload(subject, target, {}), 0,
		{...}

	local last_s = 0
	local handle
	handle = self:after((delay or 0), function()
		handle.timer = self:during(len, function(dt)
			t = t + dt
			local s = method(math.min(1, t / len), unpack(args))
			local ds = s - last_s
			last_s = s
			for _, info in ipairs(payload) do
				local ref, key, delta = unpack(info)
				ref[key] = ref[key] + delta * ds
			end
			for ref, t in pairs(to_func_tween) do
				for key, value in pairs(t) do
					local setter_args, setter = unpack(value)
					if not pcall(function()
							setter(ref, unpack(setter_args))
						end) then
						setter(unpack(setter_args))
					end
				end
			end
		end, after)
	end)
	handle.subject = subject
	return handle
end

local function plain_tween(tween, self, len, subject, target, method, after, ...)
	return
		func_tween(tween, self, len, subject, target, method, after, nil, ...)
end

local function def_tween(func)
	return setmetatable({
		-- helper functions
		out = function(f) -- 'rotates' a function
			return function(s, ...) return 1 - f(1 - s, ...) end
		end,
		chain = function(f1, f2) -- concatenates two functions
			return function(s, ...)
				return (s < .5 and f1(2 * s, ...) or 1 + f2(2 * s - 1, ...)) *
					.5
			end
		end,

		-- useful tweening functions
		linear = function(s) return s end,
		quad = function(s) return s * s end,
		cubic = function(s) return s * s * s end,
		quart = function(s) return s * s * s * s end,
		quint = function(s) return s * s * s * s * s end,
		sine = function(s) return 1 - math.cos(s * math.pi / 2) end,
		expo = function(s) return 2 ^ (10 * (s - 1)) end,
		circ = function(s) return 1 - math.sqrt(1 - s * s) end,

		back = function(s, bounciness)
			bounciness = bounciness or 1.70158
			return s * s * ((bounciness + 1) * s - bounciness)
		end,

		bounce = function(s) -- magic numbers ahead
			local a, b = 7.5625, 1 / 2.75
			return math.min(a * s ^ 2, a * (s - 1.5 * b) ^ 2 + .75,
				a * (s - 2.25 * b) ^ 2 + .9375,
				a * (s - 2.625 * b) ^ 2 + .984375)
		end,

		elastic = function(s, amp, period)
			amp, period = amp and math.max(1, amp) or 1, period or .3
			return (-amp *
					math.sin(
						2 * math.pi / period * (s - 1) - math.asin(1 / amp))) *
				2 ^ (10 * (s - 1))
		end

	}, {

		-- register new tween
		__call = func,

		-- fetches function and generated compositions for method `key`
		__index = function(tweens, key)
			if type(key) == 'function' then return key end

			assert(type(key) == 'string', 'Method must be function or string.')
			if rawget(tweens, key) then return rawget(tweens, key) end

			local function construct(pattern, f)
				local method = rawget(tweens, key:match(pattern))
				if method then return f(method) end
				return nil
			end

			local out, chain = rawget(tweens, 'out'), rawget(tweens, 'chain')
			return construct('^in%-([^-]+)$', function(...)
					return ...
				end) or construct('^out%-([^-]+)$', out) or
				construct('^in%-out%-([^-]+)$',
					function(f)
						return chain(f, out(f))
					end) or
				construct('^out%-in%-([^-]+)$',
					function(f)
						return chain(out(f), f)
					end) or error('Unknown interpolation method: ' .. key)
		end
	})
end

Timer.speed = 1

Timer.tween = def_tween(plain_tween)
Timer.func_tween = def_tween(func_tween)

-- Timer instancing
function Timer.new()
	return setmetatable({functions = {}, speed = Timer.speed, tween = Timer.tween}, Timer)
end

-- default instance
local default = Timer.new()

-- module forwards calls to default instance
local module = {}
for k in pairs(Timer) do
	if k ~= "__index" then
		module[k] = function(...) return default[k](default, ...) end
	end
end
module.tween = setmetatable({}, {
	__index = Timer.tween,
	__newindex = function(k, v) Timer.tween[k] = v end,
	__call = function(t, ...) return default:tween(...) end
})

return setmetatable(module, {__call = Timer.new})
