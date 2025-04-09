if not savedata then 
	Log("[BINARY SAVE]: no savedata!")
	return 
end
require("serialize")
require("routines")

math.randomseed( os.time() )

local FILE_MODE = { r = "r", w = "w", i = "r" }
local VERSION = 1
local HEADER = "iiC SAV GAEM "
--local KEY = 2*math.random( 0, 127 )+1
local KEY = 1
local SAVETEXT = ""
local savefile = io.open( savedata.filename or "BAD FILENAME", FILE_MODE[savedata.mode or "i"] )
local HEADER_LENGTH = #HEADER+5
local CONTROL_SIZE = 3
local SAFE_CONTROL_SIZE
local DECRYPTED_SAVETEXT
local CONTROL_SAVEDATA

if not savefile then
	Log("[BINARY SAVE] Cannot open file!")
	return
end

function save( str )
	SAVETEXT = SAVETEXT..str
	savefile:write( str )
end

function writeHeader()
	save( HEADER )
	save( getChar( KEY ).." " )
	save( getChar( math.floor(VERSION/256) ) )
	save( getChar( VERSION ) )
end

local function writeString( str )
	save( str )
end

function encryptString( str )
	local enc = ""
	for i=1, #str do
		enc = enc .. getChar( KEY * ((string.byte( str, i ) + math.floor(KEY/2) % 256) ) )
		enc = enc .. getChar( KEY * string.byte( str, i ) + math.floor(KEY/2) + math.random(-10, 10) )
	end
	writeString( enc )
end

function readFile()
	SAVETEXT = savefile:read("*all")
	CONTROL_SAVEDATA = SAVETEXT
	local newtext = ""
	local ch = ""
	local i = #HEADER+1
	while i <= #SAVETEXT do
		if string.byte( SAVETEXT, i ) == 255 then --65 97
			ch = string.byte( SAVETEXT, i+1 )
			if ch == 255 then
				newtext = newtext .. string.char(33)
			elseif ch >= 65 and ch < 97 then
				newtext = newtext .. string.char(ch-65)
			elseif ch >= 97 then
				newtext = newtext .. string.char(ch-97)
			end
			i = i+1
		else
			newtext = newtext .. string.sub( SAVETEXT, i, i )
		end
		i = i+1
	end
	SAVETEXT = string.sub(SAVETEXT, 1, #HEADER) .. newtext
end

function convertVersion( old_version )
	local local_version
	while local_version < VERSION do
		if local_version == 1 then
			SAVEDATA = string.sub( SAVEDATA, HEADER_LENGTH )
		end
		local_version = local_version + 1
	end
end

function readHeader()
	local seq = string.sub( SAVETEXT, 1, #HEADER )
	if seq ~= HEADER then
		Log("[BINARY SAVE] Bad header in file "..savedata.filename..", your savegame may be corrupt.")
		return false;
	end
	KEY = tonumber( string.byte(SAVETEXT, #HEADER+1) )
	local seq = 256*(tonumber(string.byte(SAVETEXT, #HEADER+3)) or -1) + (tonumber(string.byte(SAVETEXT, #HEADER+4)) or -1)
	if seq < 0 then
		Log("[BINARY SAVE] Bad header in file "..savedata.filename..", your savegame may be corrupt.")
		return false;
	end
	if seq > VERSION then
		Log("[BINARY SAVE] Save format version is wrong, possibly too new for this engine version or corrupted.")
		return false;
	elseif seq < VERSION then
		convertVersion( seq )
	else
		SAVETEXT = string.sub( SAVETEXT, HEADER_LENGTH )
	end
	return true;
end

function getChar( num )
	local ret = num % 256
	if ret < 26 then
			return string.char(255)..string.char(ret+65)
	elseif ret < 32 then
			return string.char(255)..string.char(ret+97)
	elseif ret == 255 then
			return string.char(255)..string.char(255)
	else
			return string.char(ret)
	end
end

function decodeChar( code )
	local ret = ''
	for i=0,255 do
		if (KEY * ((i + math.floor(KEY/2) % 256))) % 256 == code then
			ret = string.char( i )
			break
		end
	end
	return ret
end

function decryptString()
	local dec = ""
	for i=1, math.floor((#SAVETEXT-CONTROL_SIZE)/2) do
		dec = dec .. decodeChar(string.byte( SAVETEXT, 2*i-1 ))
	end
	DECRYPTED_SAVETEXT = dec
end

function safeString( str )
	local safe = {}
	local code
	for i=1,#str do
		code = string.byte( str, i )
		if code == 255 and string.byte( str, i+1 ) == 1 then
			i = i + 1
			table.insert( safe, "===ISZERO===" )
		elseif code == 255 and string.byte( str, i+1 ) == 255 then
			table.insert( safe, "===IS255===" )
			i = i + 1
		else
			table.insert( safe, string.char( code ) )
		end
	end
	return table.concat(safe)
end

function controlBytes( str )
	print(str)
	local control1 = 0
	local control2 = 1
	for i=1, #str do
		control1 = (control1 + string.byte( str, i )) % 256
		control2 = ((control2 * (string.byte( str, i )+1)) % 256)+1
	end
	return { control1, control2, (control1+control2) % 256 }
end

function endSave()
	local ret = nil
	if savedata.mode == "w" then
		local control = controlBytes( SAVETEXT )
		local contra = {}
		for i=1, CONTROL_SIZE do
			save( getChar(control[i]) )
			table.insert( contra, getChar(control[i]) )
		end
		local contro = table.concat(contra)
	elseif savedata.mode == "r" or savedata.mode == "i" then
		SAFE_CONTROL_SIZE = CONTROL_SIZE
		for i = #SAVETEXT-CONTROL_SIZE+1,#SAVETEXT do
			if string.byte(SAVETEXT, i, i) < 32 then
				SAFE_CONTROL_SIZE = SAFE_CONTROL_SIZE + 1
			elseif string.byte(SAVETEXT, i, i) == 255 then
				SAFE_CONTROL_SIZE = SAFE_CONTROL_SIZE + 1
			end
		end
		local savebytes = string.sub( SAVETEXT, #SAVETEXT-CONTROL_SIZE+1 )
		local control = controlBytes( string.sub(CONTROL_SAVEDATA, 1, #CONTROL_SAVEDATA-SAFE_CONTROL_SIZE) )
		local correct = true
		for i=1, CONTROL_SIZE do
			if control[i] ~=  string.byte( SAVETEXT, #SAVETEXT-CONTROL_SIZE+i ) then
				correct = false
				break
			end
		end
		assert(correct or savedata.mode == "i", "[BINARY SAVE] Savefile "..savedata.filename.." is corrupt! Purge it with fire!")
		savedata.data = DECRYPTED_SAVETEXT
		ret = applySave( savedata.mode )
	end
	savefile:close()
	savedata.data = nil
	return ret
end

function formSave()
	local save = {}
	save.difficulty = difficulty or 1
	save.nextLevelName = (Loader or {map_name = "NO LOADER"} ).map_name or "NO MAP NAME"
	
	if Loader then Loader.savePlrInfo() end
	local st = {}
	for key, value in pairs(stat) do
		st[key] = value
	end
	for key, value in pairs(mapvar) do
		st[key] = value
	end
	st.tmp = nil
	st.threads = nil
	st.char = nil
	save.stat = st
	
	save.info = saveinfo or {}
	save.info.date = os.date()
	savedata.data = "local "..serialize("save", save, true, true).."return save"
	--Log("formSave:\n", savedata.data )
end

function applySave( mode )
	--Log("apply save: ", mode)
	if mode == "r" then
		--Log("apply_save: ", savedata.data)
		--Log("apply_save: ", serialize("savedata", savedata))
		local save = assert(loadstring(savedata.data))()
		--Log("applySave:  ",serialize("save", save))
		difficulty = save.difficulty or 1
		if Loader then
			
			--Log("applySave after startGame")
			stat = shallow_copy(save.stat)
			--Log("applySave: ",serialize("stat", stat))
			
			if not mapvar then mapvar = {} end
			for k,v in pairs(stat) do mapvar[k] = v end	

			--Log("applySave after applying stat ")
		
			Loader.loadPlrInfo()
			--Log(serialize("mapvar", mapvar))
			
			Loader.startGame(save.nextLevelName, true)
					
			-- for key, value in ipairs(save.plr) do 
				-- if value then
					-- SetPlayerAltWeapon(key, value.altWeaponName)
					-- SetPlayerAmmo(key, value.ammo)
					-- SetPlayerHealth(key, value.health)
				-- end
			-- end
		end
		return nil
	else
		local env = {}
		local untrusted_function, message = loadstring(savedata.data)
		if not untrusted_function then return nil end
		setfenv(untrusted_function, env)
		local success, save = pcall(untrusted_function)
		if not success then return end
		return save.info or {}
	end
end

if ( savedata.mode == "w" ) then
	formSave()
	writeHeader()
	encryptString( savedata.data )
elseif ( savedata.mode == "r" ) or ( savedata.mode == "i" ) then
	readFile()
	if not readHeader() then return end
	decryptString()
end
return endSave()