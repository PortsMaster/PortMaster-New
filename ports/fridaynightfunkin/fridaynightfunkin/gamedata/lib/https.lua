local OS, https = love.system.getOS(), "https"

if OS == "Windows" then
	if love.filesystem.getInfo("lib/windows/https.dll", "file") then
		https = "lib/windows/https"
	end
elseif OS == "Linux" then
	if love.filesystem.getInfo("lib/linux/https.so", "file") then
		https = "lib/linux/https"
	end
elseif OS == "OS X" then
	if love.filesystem.getInfo("lib/osx/https.so", "file") then
		https = "lib/osx/https"
	end
end

local success, v = pcall(package.loadlib, https, "luaopen_https")
if success then
	return v
else
	local __NULL__ = function() end
	return setmetatable({}, {__index = function() return __NULL__ end})
end
