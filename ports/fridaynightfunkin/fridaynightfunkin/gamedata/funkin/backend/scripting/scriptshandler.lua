---@class ScriptsHandler:Classic
local ScriptsHandler = Classic:extend("ScriptsHandler")

---Creates a new script handler
function ScriptsHandler:new() self.scripts = {} end

---loads a script then adds it to the handler
---@param file string
function ScriptsHandler:loadScript(file) table.insert(self.scripts, Script(file)) end

---add script to list
---@param script Script
function ScriptsHandler:add(script) table.insert(self.scripts, script) end

---remove script from list
---@param script Script
function ScriptsHandler:remove(script) table.delete(self.scripts, script) end

---loads all scripts in a directory to the handler
---@param ... string
function ScriptsHandler:loadDirectory(...)
	for _, dir in ipairs({...}) do
		for _, file in ipairs(love.filesystem.getDirectoryItems(paths.getPath(dir))) do
			if file:endsWith('.lua') then self:loadScript(string.withoutExt(dir .. "/" .. file)) end
		end
	end
end

---calls a function across all scripts
---@param func string
---@param ... any
function ScriptsHandler:call(func, ...)
	local retValue = Script.Event_Continue
	for _, script in ipairs(self.scripts) do
		local retScript = script:call(func, ...)
		if retScript == Script.Event_Cancel then retValue = Script.Event_Cancel end
	end
	return retValue
end

function ScriptsHandler:event(func, event)
	for _, script in ipairs(self.scripts) do
		script:call(func, event)
		if event.cancelled and not event.__continueCalls then break end
	end
	return event
end

---sets a variable across all scripts
---@param variable string
---@param value any
function ScriptsHandler:set(variable, value)
	for _, script in ipairs(self.scripts) do script:set(variable, value) end
end

function ScriptsHandler:close()
	for _, script in ipairs(self.scripts) do
		script:close()
	end
	self.scripts = nil
end

return ScriptsHandler
