require("serialize")

local saver_script = "scripts/saves-binary.lua"

local Saver = {}
Saver.__index = Saver

-- Ќазвани€ полей, которые будут сохранены из stat.
local statFields = {"lives", "score", "weapon", "bonuses", "active_char", "passive_char", "kills", "wakabas"}

local function getFileName(save_name)
	return ("saves/"..(save_name or "1")..".sav")
end

function Saver:doesExist(save_name)
	local file = io.open(getFileName(save_name))
	if file then io.close(file) end
	return file ~= nil
end

function Saver:getSlotName(save_name)
	savedata = { filename = getFileName(save_name), mode = "i" }
	local savedata = dofile( saver_script )
	--local savedata = {}
	if not savedata then savedata = {} end
	local ret = {}
	table.insert( ret, save_name )
	table.insert( ret, " - " )
	table.insert( ret, savedata.mapname or "UNKNOWN MAP" )
	table.insert( ret, " - " )
	table.insert( ret, savedata.date or "UNKNOWN DATE" )
	return table.concat( ret )
end

function Saver:saveGame(save_name, info)
	savedata = { filename = getFileName(save_name), mode = "w" }
	saveinfo = info or {}
	dofile( saver_script )
end

function Saver:loadGame(save_name)
	savedata = { filename = getFileName(save_name), mode = "r" }
	dofile( saver_script )
end

return Saver