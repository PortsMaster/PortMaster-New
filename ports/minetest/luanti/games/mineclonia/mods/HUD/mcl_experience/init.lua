mcl_experience = {
	on_add_xp = {},
}

local modpath = core.get_modpath(core.get_current_modname())

dofile(modpath .. "/command.lua")
dofile(modpath .. "/orb.lua")
dofile(modpath .. "/bottle.lua")

-- local storage

local hud_bars = {}
local hud_levels = {}
local caches = {}

-- helpers

local function xp_to_level(xp)
	local xp = xp or 0
	local a, b, c, D

	if xp > 1507 then
		a, b, c = 4.5, -162.5, 2220 - xp
	elseif xp > 352 then
		a, b, c = 2.5, -40.5, 360 - xp
	else
		a, b, c = 1, 6, -xp
	end

	D = b * b - 4 * a * c

	if D == 0 then
		return math.floor(-b / 2 / a)
	elseif D > 0 then
		local v1, v2 = -b / 2 / a, math.sqrt(D) / 2 / a
		return math.floor(math.max(v1 - v2, v1 + v2))
	end

	return 0
end

local function level_to_xp(level)
	if level >= 1 and level <= 16 then
		return math.floor(math.pow(level, 2) + 6 * level)
	elseif level >= 17 and level <= 31 then
		return math.floor(2.5 * math.pow(level, 2) - 40.5 * level + 360)
	elseif level >= 32 then
		return math.floor(4.5 * math.pow(level, 2) - 162.5 * level + 2220)
	end

	return 0
end

local function calculate_bounds(level)
	return level_to_xp(level), level_to_xp(level + 1)
end

local function xp_to_bar(xp, level)
	local xp_min, xp_max = calculate_bounds(level)

	return (xp - xp_min) / (xp_max - xp_min)
end

local function bar_to_xp(bar, level)
	local xp_min, xp_max = calculate_bounds(level)

	return xp_min + bar * (xp_max - xp_min)
end

local function get_time()
	return core.get_us_time() / 1000000
end

-- api

function mcl_experience.get_level(player)
	return caches[player].level
end

function mcl_experience.set_level(player, level)
	local cache = caches[player]

	if level ~= cache.level then
		mcl_experience.set_xp(player, math.floor(bar_to_xp(xp_to_bar(mcl_experience.get_xp(player), cache.level), level)))
	end
end

function mcl_experience.get_xp(player)
	return player:get_meta():get_int("xp")
end

function mcl_experience.set_xp(player, xp)
	player:get_meta():set_int("xp", xp)

	mcl_experience.update(player)
end

function mcl_experience.add_xp(player, xp)
	for _, cb in ipairs(mcl_experience.on_add_xp) do
		xp = cb.func(player, xp) or xp

		if xp == 0 then
			break
		end
	end

	local cache = caches[player]
	local old_level = cache.level

	mcl_experience.set_xp(player, mcl_experience.get_xp(player) + xp)

	local current_time = get_time()

	if current_time - cache.last_time > 0.01 then
		local name = player:get_player_name()

		if old_level == cache.level then
			core.sound_play("mcl_experience", {
				to_player = name,
				gain = 0.1,
				pitch = math.random(75, 99) / 100,
			})

			cache.last_time = current_time
		else
			core.sound_play("mcl_experience_level_up", {
				to_player = name,
				gain = 0.2,
			})

			cache.last_time = current_time + 0.2
		end
	end
end

function mcl_experience.throw_xp(pos, total_xp)
	local i, j = 0, 0
	local obs = {}
	while i < total_xp and j < 100 do
		local xp = math.min(math.random(1, math.min(32767, total_xp - math.floor(i / 2))), total_xp - i)
		local obj = core.add_entity(pos, "mcl_experience:orb", tostring(xp))

		if not obj then
			return false
		end

		obj:set_velocity(vector.new(
			math.random(-2, 2) * math.random(),
			math.random( 2, 5),
			math.random(-2, 2) * math.random()
		))

		i = i + xp
		j = j + 1
		table.insert(obs,obj)
	end
	return obs
end

function mcl_experience.remove_hud(player)
	if hud_bars[player] then
		player:hud_remove(hud_bars[player])
		hud_bars[player] = nil
	end
	if hud_levels[player] then
		player:hud_remove(hud_levels[player])
		hud_levels[player] = nil
	end
end

function mcl_experience.setup_hud(player)
	if hud_bars[player] and hud_levels[player] then return end
	mcl_experience.remove_hud(player)
	caches[player] = {
		last_time = get_time(),
	}

	if not core.is_creative_enabled(player:get_player_name()) then
		hud_bars[player] = player:hud_add({
			type = "image",
			position = {x = 0.5, y = 1},
			offset = {x = (-9 * 28) - 3, y = -(48 + 24 + 16 - 5)},
			scale = {x = 0.35, y = 0.375},
			alignment = {x = 1, y = 1},
			z_index = 11,
		})

		hud_levels[player] = player:hud_add({
			type = "text",
			position = {x = 0.5, y = 1},
			number = 0x80FF20,
			offset = {x = 0, y = -(48 + 24 + 24)},
			z_index = 12,
		})
	end
end

function mcl_experience.update(player)
	local xp = mcl_experience.get_xp(player)
	local cache = caches[player]

	cache.level = xp_to_level(xp)

	if not core.is_creative_enabled(player:get_player_name()) then
		if not hud_bars[player] then
			mcl_experience.setup_hud(player)
		end

		player:hud_change(hud_bars[player], "text", "(mcl_experience_bar_background.png^[lowpart:"
			.. math.floor(math.floor(xp_to_bar(xp, cache.level) * 18) / 18 * 100)
			.. ":mcl_experience_bar.png)^[resize:40x1456^[transformR270"
		)

		if cache.level == 0 then
			player:hud_change(hud_levels[player], "text", "")
		else
			player:hud_change(hud_levels[player], "text", tostring(cache.level))
		end
	end
end

function mcl_experience.register_on_add_xp(func, priority)
	table.insert(mcl_experience.on_add_xp, {func = func, priority = priority or 0})
end

-- callbacks

core.register_on_joinplayer(function(player)
	mcl_experience.setup_hud(player)
	mcl_experience.update(player)
end)

core.register_on_leaveplayer(function(player)
    hud_bars[player] = nil
    hud_levels[player] = nil
    caches[player] = nil
end)

core.register_on_dieplayer(function(player)
	if not core.settings:get_bool("mcl_keepInventory", false) then
		mcl_experience.throw_xp(player:get_pos(), mcl_experience.get_xp(player))
		mcl_experience.set_xp(player, 0)
	end
end)

core.register_on_mods_loaded(function()
	table.sort(mcl_experience.on_add_xp, function(a, b) return a.priority < b.priority end)
end)

mcl_gamemode.register_on_gamemode_change(function(p, _, gm)
	if gm == "survival" then
		 mcl_experience.setup_hud(p)
		 mcl_experience.update(p)
	elseif gm == "creative" then
		 mcl_experience.remove_hud(p)
	end
end)

core.register_chatcommand("set_xp", {
	privs = { debug = true },
	description = "Set experience of current player",
	params = "<xp>",
	func = function(pn,param)
		local player = core.get_player_by_name(pn)
		local num = tonumber(param)
		local rt = false
		if num then
			mcl_experience.set_xp(player, num)
		end
		return rt, "XP for player "..pn..": "..tostring(mcl_experience.get_xp(player))
	end,
})
