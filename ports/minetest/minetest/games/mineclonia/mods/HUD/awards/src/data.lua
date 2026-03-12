
local storage = core.get_mod_storage()
local __player_data

-- Table Save Load Functions
function awards.save()
	storage:set_string("player_data", core.write_json(__player_data))
end

local function convert_data()
	core.log("warning", "Importing awards data from previous version")

	local old_players = __player_data
	__player_data = {}
	for name, data in pairs(old_players) do
		while name.name do
			name = name.name
		end
		if type(name) == "string" then
			data.name = name
			print("Converting data for " .. name)

			-- Just rename counted
			local counted = {
				chats  = "chat",
				deaths = "death",
				joins  = "join",
			}
			for from, to in pairs(counted) do
				data[to]   = data[from]
				data[from] = nil
			end

			data.death = {
				unknown = data.death,
				__total = data.death,
			}

			-- Convert item db to new format
			local counted_items = {
				count = "dig",
				place = "place",
				craft = "craft",
			}
			for from, to in pairs(counted_items) do
				local ret = {}

				local count = 0
				if data[from] then
					for modname, items in pairs(data[from]) do
						for itemname, value in pairs(items) do
							itemname = modname .. ":" .. itemname
							local key = core.registered_aliases[itemname] or itemname
							ret[key] = value
							count = count + value
						end
					end
				end

				ret.__total = count
				data[from] = nil
				data[to] = ret
			end

			__player_data[name] = data
		end
	end
end

function awards.load()
	local old_save_path = core.get_worldpath().."/awards.txt"
	local file = io.open(old_save_path, "r")
	if file then
		local table = core.deserialize(file:read("*all"))
		if type(table) == "table" then
			__player_data = table
			convert_data()
		else
			__player_data = {}
		end
		file:close()
		os.rename(old_save_path, core.get_worldpath().."/awards.bk.txt")
		awards.save()
	else
		local json = storage:get("player_data")
		__player_data = json and core.parse_json(json) or {}
	end
end

function awards.player(name)
	assert(type(name) == "string")
	local data = __player_data[name] or {}
	__player_data[name] = data

	data.name     = data.name or name
	data.unlocked = data.unlocked or {}
	return data
end

function awards.player_or_nil(name)
	return __player_data[name]
end

function awards.enable(name)
	awards.player(name).disabled = nil
end

function awards.disable(name)
	awards.player(name).disabled = true
end

function awards.clear_player(name)
	__player_data[name] = {}
end
