local S = core.get_translator(core.get_current_modname())

mcl_bossbars = {
	bars = {},
	huds = {},
	static = {},
	colors = {"light_purple", "blue", "red", "green", "yellow", "dark_purple", "white"},
}

mcl_player.register_player_setting("mcl_bossbars:max_bossbars", {
        type = "slider",
	options = {
		{ name = "0", description = S("None") },
		{ min = 1, max = 5 },
		{ name = "9999", description = S("Unlimited") },
	},
	section = "HUD",
	short_desc = S("Maximum number of boss bars to display simultaneously"),
	long_desc = S("Multiple bosses can be active at the same time. To not clutter your screen, you may limit the number of simultaneously displayed boss bars."),
	ui_default = "4",
})

function mcl_bossbars.recalculate_colors()
	local sorted = {}
	local colors = mcl_bossbars.colors
	local color_count = #colors
	local frame_count = color_count * 2
	for i, color in ipairs(colors) do
		local idx = i * 2 - 1
		local image = "(mcl_bossbars.png"
			.. "^[transformR270"
			.. "^[verticalframe:" .. frame_count .. ":" .. (idx - 1)
			.. "^(mcl_bossbars_empty.png"
			.. "^[lowpart:%d:mcl_bossbars.png"
			.. "^[transformR270"
			.. "^[verticalframe:" .. frame_count .. ":" .. idx .. "))^[resize:1456x40"
		local _, hex = mcl_util.get_color(color)
		sorted[color] = {
			image = image,
			hex = hex,
		}
	end
	mcl_bossbars.colors_sorted = sorted
end

local function get_color_info(color, percentage)
	local cdef = mcl_bossbars.colors_sorted[color]
	return cdef.hex, string.format(cdef.image, percentage)
end

local last_id = 0

function mcl_bossbars.add_bar(player, def, dynamic, priority)
	local name = player:get_player_name()
	local bars = mcl_bossbars.bars[name]
	local bar = {text = def.text, priority = priority or 0, timeout = def.timeout}
	bar.color, bar.image = get_color_info(def.color, def.percentage)
	if dynamic then
		for _, other in pairs(bars) do
			if not other.id and other.color == bar.color and (other.original_text or other.text) == bar.text and other.image == bar.image then
				if not other.count then
					other.count = 1
					other.original_text = other.text
				end
				other.count = other.count + 1
				other.text = other.original_text .. " x" .. other.count
				return
			end
		end
	end
	table.insert(bars, bar)
	if not dynamic then
		bar.raw_color = def.color
		bar.id = last_id + 1
		last_id = bar.id
		mcl_bossbars.static[bar.id] = bar
		return bar.id
	end
end

function mcl_bossbars.remove_bar(id)
	mcl_bossbars.static[id].id = nil
	mcl_bossbars.static[id] = nil
end

function mcl_bossbars.update_bar(id, def, priority)
	local old = mcl_bossbars.static[id]
	old.color, old.image = get_color_info(def.color or old.raw_color, def.percentage or old.percentage)
	old.text = def.text or old.text
	old.priority = priority or old.priority
end

function mcl_bossbars.update_boss(object, name, color)
	local ent = object:get_luaentity()
	local props = object:get_properties()
	if not ent or not ent.is_mob then
		props.health = object:get_hp()
	else
		props.health = ent.health
	end

	local bardef = {
		color = color,
		text = props.nametag,
		percentage = math.floor(props.health / props.hp_max * 100),
	}

	if not bardef.text or bardef.text == "" then
		bardef.text = name
	end

	local pos = object:get_pos()
	for player in mcl_util.connected_players() do
		local d = vector.distance(pos, player:get_pos())
		if d <= 80 then
			mcl_bossbars.add_bar(player, bardef, true, d)
		end
	end
end

core.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	mcl_bossbars.huds[name] = {}
	mcl_bossbars.bars[name] = {}
end)

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	mcl_bossbars.huds[name] = nil
	for _, bar in pairs(mcl_bossbars.bars[name] or {}) do
		if bar.id then
			mcl_bossbars.static[bar.id] = nil
		end
	end
	mcl_bossbars.bars[name] = nil
end)

mcl_player.register_globalstep(function(player, dtime)
	local name = player:get_player_name()
	local bars = mcl_bossbars.bars[name]
	local huds = mcl_bossbars.huds[name]
	local max_bars = tonumber(mcl_player.get_player_setting(player, "mcl_bossbars:max_bossbars", 4)) or 4
	table.sort(bars, function(a, b) return a.priority < b.priority end)
	local huds_new = {}
	local bars_new = {}
	local i = 0

	while #huds > 0 or #bars > 0 do
		local bar = table.remove(bars, 1)
		local hud = table.remove(huds, 1)

		if bar and bar.id then
			if bar.timeout then
				bar.timeout = bar.timeout - dtime
			end
			if not bar.timeout or bar.timeout > 0 then
				table.insert(bars_new, bar)
			end
		end

		if bar and not hud then
			if i < max_bars then
				hud = {
					color = bar.color,
					image = bar.image,
					text = bar.text,
					text_id = player:hud_add({
						type = "text",
						text = bar.text,
						number = bar.color,
						position = {x = 0.5, y = 0},
						alignment = {x = 0, y = 1},
						offset = {x = 0, y = i * 40},
					}),
					image_id = player:hud_add({
						type = "image",
						text = bar.image,
						position = {x = 0.5, y = 0},
						alignment = {x = 0, y = 1},
						offset = {x = 0, y = i * 40 + 25},
						scale = {x = 0.375, y = 0.375},
					}),
				}
			end
		elseif hud and not bar then
			player:hud_remove(hud.text_id)
			player:hud_remove(hud.image_id)
			hud = nil
		else
			if bar.text ~= hud.text then
				player:hud_change(hud.text_id, "text", bar.text)
				hud.text = bar.text
			end

			if bar.color ~= hud.color then
				player:hud_change(hud.text_id, "number", bar.color)
				hud.color = bar.color
			end

			if bar.image ~= hud.image then
				player:hud_change(hud.image_id, "text", bar.image)
				hud.image = bar.image
			end
		end

		table.insert(huds_new, hud)
		i = i + 1
	end

	mcl_bossbars.huds[name] = huds_new
	mcl_bossbars.bars[name] = bars_new
end)

mcl_bossbars.recalculate_colors()
