---@diagnostic disable: duplicate-set-field, discard-returns
-- LUA 5.2-LUA 5.3 and LUA 5.0 BELOW REIMPLEMENTATIONS
bit32, utf8 = bit32 or bit, utf8 or require "utf8"
bit = bit or bit32

local __string__, __number__, __table__ = "string", "number", "table"
local __integer__, __float__ = "integer", "float"
local table_insert = table.insert

local split_t
local function gsplit(s) table_insert(split_t, s) end
function string:split(sep, t)
	split_t = t or {}
	self:gsub((sep and sep ~= "") and "([^" .. sep .. "]+)" or ".", gsplit)
	return split_t
end

function string:replace(pattern, rep) -- note: you could just do gsub instead of replace
	return self:gsub("%" .. pattern, rep)
end

-- see https://luajit.org/extensions.html
local s, table_new = pcall(require, "table.new")
if not s then function table_new( --[[narray, nhash]]) return {} end end
table.new = table_new

local s, table_clear = pcall(require, "table.clear")
if not s then function table_clear(t) for i in pairs(t) do t[i] = nil end end end
table.clear = table_clear

local table_move = table.move
if not table_move then
	function table_move(a, f, e, t, b)
		b = b or a; for i = f, e do b[i + t - 1] = a[i] end
		return b
	end

	table.move = table_move
end

local function table_find(t, value)
	for i = 1, #t do if t[i] == value then return i end end
end
table.find = table_find

local table_remove = table.remove or function(t, pos)
	local n = #t; if pos == nil then pos = n end;
	local v = t[pos]; if pos < n then table_move(t, pos + 1, n, pos) end;
	t[n] = nil; return v
end
function table.remove(t, pos)
	if pos == nil or type(pos) == __number__ then return table_remove(t, pos) end
	local j, v = 1
	for i = j, #t do
		if t[i] and pos(t, i, j) then
			v, t[i] = t[i]
		else
			if i ~= j then t[j], t[i] = t[i] end
			j = j + 1
		end
	end
	return v
end

function table.reverse(t)
	local n = #t + 1
	for i = 1, (n - 1) / 2 do t[i], t[n - i] = t[n - i], t[i] end
end

function table.delete(t, obj)
	local index = table_find(t, obj)
	if index then
		table_remove(t, index)
		return true
	end
	return false
end

local math_min, math_max, math_floor, math_ceil, math_random =
	math.min, math.max, math.floor, math.ceil, math.random
local function math_round(x) return x >= 0 and math_floor(x + .5) or math_ceil(x - .5) end
math.round = math_round

function table.shuffle(t)
	local l, j = #t
	for i = l, 2, -1 do
		j = math_random(i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

function math.clamp(x, min, max) return math_min(math_max(x, min or 0), max or 1) end

function math.type(v)
	return (v >= -2147483648 and v <= 2147483647 and math_floor(v) == v) and
		__integer__ or __float__
end

-- EXTRA FUNCTIONS
math.positive_infinity, math.negative_infinity = math.huge, -math.huge
math.noise = love.math.perlinNoise or love.math.noise
math.simplex = love.math.simplexNoise or math.noise
math.perlin = math.noise

function __NULL__() end

-- https://gist.github.com/FreeBirdLjj/6303864?permalink_comment_id=3400522#gistcomment-3400522
-- edited to support tables inside
function switch(param, case_table)
	for k, v in pairs(case_table) do
		if type(k) == "table" then
			for _, key in ipairs(k) do
				if key == param then return v() end
			end
		else
			if k == param then return v() end
		end
	end
	return (case_table.default or __NULL__)()
end

function tobool(s)
	if s == 1 or s == "true" then return true
	elseif s == -1 then return nil end
	return false
end

function bind(self, callback) return function(...) callback(self, ...) end end

local checktype_str = "bad argument #%d to '%s' (%s expected, got %s)"

function checktype(level, value, arg, functionName, expectedType)
	if type(value) ~= expectedType then
		error(checktype_str:format(arg, functionName, expectedType, type(value)), level + 1)
	end
end

local regex_ext = "%.([^%.]+)$"
local regex_withoutExt = "(.+)%..+$"

function string:hasExt() return self:match(regex_ext) ~= nil end

function string:ext() return self:match(regex_ext) or self end

function string:withoutExt() return self:match(regex_withoutExt) or self end

function string:capitalize() return self:sub(1, 1):upper() .. self:sub(2) end

function string:fileName(parts)
	parts = self:split(package.config:sub(1, 1), parts)
	return parts[#parts]
end

function string:startsWith(prefix) return self:find(prefix, 1, true) == 1 end

function string:endsWith(suffix) return self:find(suffix, 1, true) == #self - #suffix + 1 end

function string:contains(s) return self:find(s) and true or false end

function string:isSpace(pos)
	pos = self:byte(pos); return pos and (pos > 8 and pos < 14 or pos == 32)
end

function string:ltrim()
	local i, r = #self, 1
	while r <= i and self:isSpace(r) do r = r + 1 end
	return self:sub(r)
end

function string:rtrim()
	local r = #self - 1
	while r > 0 and self:isSpace(r) do r = r - 1 end
	return self:sub(1, r)
end

function string:trim() return self:ltrim():rtrim() end

function table.merge(a, b)
	if a and b then
		for i, v in pairs(b) do a[i] = v end
	end
end

function table.keys(t, includeIndices, keys)
	keys = keys or table_new(#t, 0)
	for i in (includeIndices and pairs or ipairs)(t) do table_insert(keys, i) end
	return keys
end

local table_clone
function table_clone(list, clone)
	clone = clone or table_new(#list, 0)
	for i, v in pairs(list) do clone[i] = type(v) == __table__ and table_clone(v) or v end
	return clone
end

table.clone = table_clone

function table.splice(t, start, count, ...)
	local n, removed = #t + 1, {...};
	local c = #removed; start = (start < 1 and n + start or start) + c;
	for i = c, 1, -1 do table_insert(t, start, table_remove(removed, i)) end
	for i = 1, math_min(count or 0, n - start) do
		table_insert(removed, table_remove(t, start))
	end
	return removed
end

function table.random(t)
	if #t == 0 then return nil end
	return t[math.random(1, #t)]
end

local pi = math.pi
function math.fastsin(v)
	v = (v / pi) % 2
	return v <= 1 and -4 * v * (v - 1) or 4 * (v - 1) * (v - 2)
end

function math.fastcos(v)
	v = (v / pi + .5) % 2
	return v <= 1 and -4 * v * (v - 1) or 4 * (v - 1) * (v - 2)
end

function math.aprsin(v)
	v = ((v / pi + 1) % 2) - 1
	return v > 0 and v * (3.1 + v * (0.5 + v * (-7.2 + v * 3.6)))
		or v * (3.1 - v * (0.5 + v * (7.2 + v * 3.6)))
end

function math.aprcos(v)
	v = ((v / pi + 1.5) % 2) - 1
	return v > 0 and v * (3.1 + v * (0.5 + v * (-7.2 + v * 3.6)))
		or v * (3.1 - v * (0.5 + v * (7.2 + v * 3.6)))
end

function math.odd(x) return x % 2 >= 1 end -- 1, 3, etc

function math.even(x) return x % 2 < 1 end -- 2, 4, etc

function math.wrap(x, a, b) return ((x - a) % (b - a)) + a end

function math.lerp(a, b, t) return a + (b - a) * t end

function math.invlerp(a, b, t) return (t - a) / (b - a) end

function math.remapToRange(x, start1, stop1, start2, stop2)
	return start2 + (x - start1) * ((stop2 - start2) / (stop1 - start1))
end

-- please use math.floor/round instead if you want the precision to be 0
function math.truncate(x, precision, round)
	precision = 10 ^ (precision or 2)
	return (round and math_round or math_floor)(precision * x) / precision
end

local intervals, countbytesf = {"B", "KB", "MB", "GB"}, "%.2f %s"
function math.countbytes(x, i)
	i = i or 1
	while x >= 1024 and i < 4 do x, i = x / 1024, i + 1 end
	return countbytesf:format(x, intervals[i])
end

-- LOVE2D EXTRA FUNCTIONS
local love_random = love.math.random
function love.math.randomBool(chance)
	return love_random(0, 100) < (chance or 50)
end

-- Gets the current device
---@return string -- The current device. (`Desktop` or `Mobile`)
function love.system.getDevice()
	local os = love.system.getOS()
	if os == "Android" or os == "iOS" then
		return "Mobile"
	elseif os == "OS X" or os == "Windows" or os == "Linux" then
		return "Desktop"
	end
	return "Unknown"
end

function love.graphics.getFixedScale()
	local winW, winH = love.graphics.getPixelDimensions()
	return math_min(winW / (game.width or 800), winH / (game.height or 600))
end

if love.system.getDevice() == "Desktop" then
	function love.window.getMaxDesktopDimensions()
		local xmax, ymax = 0, 0
		for i = 1, love.window.getDisplayCount() do
			local x, y = love.window.getDesktopDimensions(i)
			if x > xmax then xmax = x end
			if y > ymax then ymax = y end
		end
		return xmax, ymax
	end
else
	love.window.getMaxDesktopDimensions = love.window.getDesktopDimensions
end

if --[[not love.markDeprecated actually this is better and]] debug then
	-- this is stupid
	local __markDeprecated__, __Sl__, __none__ = "markDeprecated", "Sl", ""
	local __functionvariant__, __functionvariantin__ = "functionvariant", "function variant in"
	local __methodvariant__, __methodvariantin__ = "methodvariant", "method variant in"
	local __replaced__, __replcaedby__ = "replcaed", "(replaced by %s)"
	local __renamed__, __renamedto__ = "renamed", "(renamed to %s)"
	local __warning__ = "LOVE - Warning: %s:%d: Using deprecated %s %s %s"
	local deprecated = {}
	local ignore = {
		["love.graphics.stencil"] = true,
		["love.graphics.setStencilTest"] = true
	}
	function love.markDeprecated(level, name, apiname, deprecationtname, replacement)
		checktype(2, level, 1, __markDeprecated__, __number__)
		checktype(2, name, 2, __markDeprecated__, __string__)
		if ignore[name] then return end

		checktype(2, apiname, 3, __markDeprecated__, __string__)
		checktype(2, deprecationtname, 4, __markDeprecated__, __string__)

		local info = debug.getinfo(level + 1, __Sl__)
		if not deprecated[name] then deprecated[name] = {} end
		if deprecated[name][info.source .. info.currentline] then return end

		deprecated[name][info.source .. info.currentline] = true
		local what
		if apiname == __functionvariant__ then
			what = __functionvariantin__
		elseif apiname == __methodvariant__ then
			what = __methodvariantin__
		else
			what = apiname
		end

		local isreplaced, extra = deprecationtname == __replaced__
		if isreplaced or deprecationtname == __renamed__ then
			checktype(2, replacement, 5, __markDeprecated__, __string__)
			extra = (isreplaced and __replacedby__ or __renamedto__):format(replacement)
		end

		print(__warning__:format(info.source:sub(2), info.currentline, what, name, extra or __none__))
	end
end
