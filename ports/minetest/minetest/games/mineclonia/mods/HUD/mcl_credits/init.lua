local modname = core.get_current_modname()
local S = core.get_translator(modname)

mcl_credits = {
	players = {},
	description = S("A faithful Open Source clone of Minecraft"),
	people = dofile(core.get_modpath(modname) .. "/people.lua"),
}

local function add_hud_element(def, huds, y)
	def.alignment = {x = 0, y = 0}
	def.position = {x = 0.5, y = 0}
	def.offset = {x = 0, y = y}
	def.z_index = 1001
	local id = huds.player:hud_add(def)
	table.insert(huds.ids, id)
	huds.moving[id] = y
	return id
end

function mcl_credits.show(player)
	local name = player:get_player_name()
	if mcl_credits.players[name] then
		return
	end
	local huds = {
		new = true,		-- workaround for MT < 5.5 (sending hud_add and hud_remove in the same tick)
		player = player,
		moving = {},
		ids = {
			player:hud_add({
				type = "image",
				text = "credits_bg.png",
				position = {x = 0, y = 0},
				alignment = {x = 1, y = 1},
				scale = {x = -100, y = -100},
				z_index = 1000,
			}),
			player:hud_add({
				type = "text",
				text = S("Sneak to skip"),
				position = {x = 1, y = 1},
				alignment = {x = -1, y = -1},
				offset = {x = -5, y = -5},
				z_index = 1001,
				number = 0xFFFFFF,
			}),
			player:hud_add({
				type = "text",
				text = "  "..S("Jump to speed up (additionally sprint)"),
				position = {x = 0, y = 1},
				alignment = {x = 1, y = -1},
				offset = {x = -5, y = -5},
				z_index = 1002,
				number = 0xFFFFFF,
			}),
		},
	}
	add_hud_element({
		type = "image",
		text = "mineclonia_logo.png",
		scale = {x = 1, y = 1},
	}, huds, 300)
	add_hud_element({
		type = "text",
		text = mcl_credits.description,
		number = 0x757575,
		scale = {x = 5, y = 5},
	}, huds, 350)
	local y = 450
	for _, group in ipairs(mcl_credits.people) do
		add_hud_element({
			type = "text",
			text = group[1],
			number = group[2],
			scale = {x = 3, y = 3},
		}, huds, y)
		y = y + 25
		for _, name in ipairs(group[3]) do
			y = y + 25
			add_hud_element({
				type = "text",
				text = name,
				number = 0xFFFFFF,
				scale = {x = 1, y = 1},
			}, huds, y)
		end
		y = y + 200
	end
	huds.icon = add_hud_element({
		type = "image",
		text = "mineclonia_icon.png",
		scale = {x = 1, y = 1},
	}, huds, y)
	mcl_credits.players[name] = huds
end

function mcl_credits.hide(player)
	local name = player:get_player_name()
	local huds = mcl_credits.players[name]
	if huds then
		for _, id in pairs(huds.ids) do
			player:hud_remove(id)
		end
	end
	mcl_credits.players[name] = nil
end

core.register_on_leaveplayer(function(player)
	mcl_credits.players[player:get_player_name()] = nil
end)

core.register_globalstep(function(_)
	for _, huds in pairs(mcl_credits.players) do
		local player = huds.player
		local control = player:get_player_control()
		if not huds.new and control.sneak then
			mcl_credits.hide(player)
		else
			local moving = {}
			local any
			for id, y in pairs(huds.moving) do
				y = y - 1

				if control.jump then
					y = y - 2
					if control.aux1 then
						y = y - 5
					end
				end

				if y > -100 then
					if id == huds.icon then
						y = math.max(400, y)
					else
						any = true
					end
					player:hud_change(id, "offset", {x = 0, y = y})
					moving[id] = y
				end
			end
			if not any then
				mcl_credits.hide(player)
			end
			huds.moving = moving
		end
		huds.new = false
	end
end)

core.register_chatcommand("endcredits", {
	description = S("Show the Mineclonia end credits"),
	func = function(name, _)
		mcl_credits.show(core.get_player_by_name(name))

		return true
	end,
})
