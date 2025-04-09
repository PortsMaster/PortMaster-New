---@class Script:Classic
local Script = Classic:extend("Script")

local env = {Script = Script}

local closedEnv = setmetatable({}, {
	__index = function() error("closed") end,
	__newindex = function() error("closed") end,
})

-- Scripts are untrusted, it can have malicious code into it
-- This limits, but not fully prevent this problem
local function errformat(s)
	local info = debug.getinfo(3, "Sln")
	local file = info.short_src or "unknown file"
	local line = tostring(info.currentline) or "unknown line"

	print(string.format("%s:%s: %s isn't allowed on scripts", file, line, s))
end

local redirect = {
	require = function() errformat("require"); return {} end,
	loxreq = function() errformat("loxreq"); return {} end,
	dofile = function() errformat("dofile"); return {} end,
	loadfile = function() errformat("loadfile"); return {} end,
	loadstring = function() errformat("loadstring"); return {} end,
	load = function() errformat("load"); return {} end,

	rawset = function() errformat("rawset"); return false end,
	rawget = function() errformat("rawget"); return false end,
	rawequal = function() errformat("rawequal"); return false end,
	setfenv = function() errformat("setfenv"); return false end,
	getfenv = function() errformat("getfenv"); return false end,

	os = {
		execute = function() errformat("os.execute"); return false end,
		remove = function() errformat("os.remove"); return false end,
		rename = function() errformat("os.rename"); return false end,
		tmpname = function() errformat("os.tmpname"); return false end,
		setenv = function() errformat("os.setenv"); return false end,
		getenv = function() errformat("os.getenv"); return false end
	},
	string = {
		dump = function() errformat("string.dump"); return "" end
	}
}

function Script.addToEnv(k, v) env[k] = redirect[k] or v end

for k, f in pairs(_G) do env[k] = redirect[k] or f end
for k, f in pairs(os) do env.os[k] = redirect.os[k] or f end
for k, f in pairs(string) do env.string[k] = redirect.string[k] or f end
env._G = env

-- Even through you can't use require directly, you can use
-- Script(path).chunk() instead. It works the same way, but
-- it can be reloaded.

local chunkMt = {__index = env}

Script.Event_Continue = 1
Script.Event_Cancel = 2

function Script:new(path, notFoundMsg)
	self.path = path
	self.variables = {}
	self.notFoundMsg = (notFoundMsg == nil and true or false)
	self.closed = false
	self.chunk = nil
	self.__failedfunc = {}

	local s, err = pcall(function()
		local p, vars = path, self.variables

		local chunk = paths.getLua(p)
		if chunk then
			setfenv(chunk, setmetatable(vars, chunkMt))
			chunk()
		else
			if not self.notFoundMsg then return end
			print("Script not found for " .. paths.getPath(p))
			self.closed = true
			return
		end

		if not p:endsWith("/") then p = p .. "/" end
		vars.close = function() self:close() end
		vars.Event_Continue = Script.Event_Continue
		vars.Event_Cancel = Script.Event_Cancel
		vars.SCRIPT_PATH = Script.p
		vars.state = game.getState()

		self.chunk = chunk
	end)

	if not s then
		print(string.format('Failed to load script: %s', err))
		self.closed = true
	end
end

function Script:set(var, value)
	if self.closed then return end
	self.variables[var] = value
end

function Script:call(func, ...)
	if self.closed then return true end

	if self.__failedfunc[func] then return end

	local f = self.variables[func]
	if f and type(f) == "function" then
		local s, err = pcall(f, ...)
		if s then
			if err ~= nil and pcall(type, err) then
				return err
			end
			return true
		else
			print(string.format('Script failed at %s: %s', func, err))
			self.__failedfunc[func] = true
		end
	end
	return
end

function Script:close()
	if self.variables then table.clear(self.variables) end
	if self.chunk then setfenv(self.chunk, closedEnv) end
	self.closed = true
	self.variables = nil
	self.chunk = nil
	self.__failedfunc = nil
end

return Script
