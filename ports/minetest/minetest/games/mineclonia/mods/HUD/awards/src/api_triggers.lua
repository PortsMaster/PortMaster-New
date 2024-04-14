-- Copyright (c) 2013-18 rubenwardy. MIT.

local function ngettext(msgid, msgid_plural, n, ...)
	return awards.translator(n==1 and msgid or msgid_plural, ...)
end

local S, NS = awards.translator, ngettext

awards.on = {}

local default_def = {}

function default_def:run_callbacks(player, data, table_func)
	for i = 1, #self.on do
		local res = nil
		local entry = self.on[i]
		if type(entry) == "function" then
			res = entry(player, data)
		elseif type(entry) == "table" and entry.award then
			res = table_func(entry)
		end

		if res then
			awards.unlock(player:get_player_name(), res)
		end
	end
end

function awards.register_trigger(tname, tdef)
	assert(type(tdef) == "table",
			"Passing a callback to register_trigger is not supported in 3.0")

	tdef.name = tname
	for key, value in pairs(default_def) do
		tdef[key] = value
	end

	if tdef.type == "counted" then
		local old_reg = tdef.on_register

		function tdef:on_register(def)
			local tmp = {
				award  = def.name,
				target = def.trigger.target,
			}
			tdef.register(tmp)

			function def.get_progress(_, data)
				local current = math.min(data[tname] or 0, tmp.target)
				return {
					current = current,
					target = tmp.target,
					label = S(tdef.progress, current, tmp.target),
				}
			end

			function def.getDefaultDescription(_)
				local n = def.trigger.target
				return NS(tdef.auto_description[1], tdef.auto_description[2], n, n)
			end

			if old_reg then
				return old_reg(tdef, def)
			end
		end

		function tdef.notify(player)
			assert(player and player.is_player and player:is_player())
			local name = player:get_player_name()
			local data = awards.player(name)

			-- Increment counter
			local currentVal = (data[tname] or 0) + 1
			data[tname] = currentVal

			tdef:run_callbacks(player, data, function(entry)
				if entry.target and entry.award and currentVal and
						currentVal >= entry.target then
					return entry.award
				end
			end)
		end

		awards["notify_" .. tname] = tdef.notify

	elseif tdef.type == "counted_key" then
		if tdef.key_is_item then
			tdef.watched_groups = {}
		end

		-- On award register
		local old_reg = tdef.on_register
		function tdef:on_register(def)
			-- Register trigger
			local tmp = {
				award  = def.name,
				key    = tdef:get_key(def),
				target = def.trigger.target,
			}
			tdef.register(tmp)

			-- If group, add it to watch list
			if tdef.key_is_item and tmp.key and tmp.key:sub(1, 6) == "group:" then
				tdef.watched_groups[tmp.key:sub(7, #tmp.key)] = true
			end

			-- Called to get progress values and labels
			function def.get_progress(_, data)
				data[tname] = data[tname] or {}

				local done
				if tmp.key then
					done = data[tname][tmp.key] or 0
				else
					done = data[tname].__total or 0
				end
				done = math.min(done, tmp.target)

				return {
					current = done,
					target = tmp.target,
					label = S(tdef.progress, done, tmp.target),
				}
			end

			-- Build description if none is specificed by the award
			function def.getDefaultDescription(_)
				local n = def.trigger.target
				if tmp.key then
					local nname = tmp.key
					return NS(tdef.auto_description[1],
							tdef.auto_description[2], n, n, nname)
				else
					return NS(tdef.auto_description_total[1],
							tdef.auto_description_total[2], n, n)
				end
			end

			-- Call on_register in trigger type definition
			if old_reg then
				return old_reg(tdef, def)
			end
		end

		function tdef.notify(player, key, n)
			n = n or 1

			if tdef.key_is_item and key:sub(1, 6) ~= "group:" then
				local itemdef = minetest.registered_items[key]
				if itemdef then
					for groupname,rating in pairs(itemdef.groups or {}) do
						if rating ~= 0 and tdef.watched_groups[groupname] then
							tdef.notify(player, "group:" .. groupname, n)
						end
					end
				end
			end

			assert(player and player.is_player and player:is_player() and key)
			local name = player:get_player_name()
			local data = awards.player(name)

			-- Increment counter
			data[tname] = data[tname] or {}
			local currentVal = (data[tname][key] or 0) + n
			data[tname][key] = currentVal
			data[tname].__total = (data[tname].__total or 0)
			if key:sub(1, 6) ~= "group:" then
				data[tname].__total = data[tname].__total + n
			end

			tdef:run_callbacks(player, data, function(entry)
				local current
				if entry.key == key then
					current = currentVal
				elseif entry.key == nil then
					current = data[tname].__total
				else
					return
				end
				if current >= entry.target then
					return entry.award
				end
			end)
		end

		awards["notify_" .. tname] = tdef.notify

	elseif tdef.type and tdef.type ~= "custom" then
		error("Unrecognised trigger type " .. tdef.type)
	end

	awards.registered_triggers[tname] = tdef

	tdef.on = {}
	tdef.register = function(func)
		table.insert(tdef.on, func)
	end

	-- Backwards compat
	awards.on[tname] = tdef.on
	awards['register_on_' .. tname] = tdef.register
	return tdef
end

function awards.increment_item_counter(data, field, itemname, count)
	itemname = minetest.registered_aliases[itemname] or itemname
	data[field][itemname] = (data[field][itemname] or 0) + (count or 1)
end

function awards.get_item_count(data, field, itemname)
	itemname = minetest.registered_aliases[itemname] or itemname
	return data[field][itemname] or 0
end

function awards.get_total_keyed_count(data, field)
	return data[field].__total or 0
end

function awards.register_on_unlock(func)
	table.insert(awards.on_unlock, func)
end
