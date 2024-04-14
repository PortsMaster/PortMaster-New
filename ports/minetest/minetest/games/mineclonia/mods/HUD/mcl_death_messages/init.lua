local S = minetest.get_translator(minetest.get_current_modname())
local NS = function(s) return s end

mcl_death_messages = {
	assist = {},
	messages = {
		in_fire = {
			plain = NS("@1 went up in flames"),
			assist = NS("@1 walked into fire whilst fighting @2"),
		},
		lightning_bolt = {
			plain = NS("@1 was struck by lightning"),
			assist = NS("@1 was struck by lightning whilst fighting @2"),
		},
		on_fire = {
			plain = NS("@1 burned to death"),
			assist = NS("@1 was burnt to a crisp whilst fighting @2"),
		},
		lava = {
			plain = NS("@1 tried to swim in lava"),
			assist = NS("@1 tried to swim in lava to escape @2"),
		},
		hot_floor = {
			plain = NS("@1 discovered the floor was lava"),
			assist = NS("@1 walked into danger zone due to @2"),
		},
		in_wall = {
			plain = NS("@1 suffocated in a wall"),
			assist = NS("@1 suffocated in a wall whilst fighting @2"),
		},
		drown = {
			plain = NS("@1 drowned"),
			assist = NS("@1 drowned whilst trying to escape @2"),
		},
		starve = {
			plain = NS("@1 starved to death"),
			assist = NS("@1 starved to death whilst fighting @2"),
		},
		cactus = {
			plain = NS("@1 was pricked to death"),
			assist = NS("@1 walked into a cactus whilst trying to escape @2"),
		},
		fall = {
			plain = NS("@1 hit the ground too hard"),
			assist = NS("@1 hit the ground too hard whilst trying to escape @2"),
			-- "@1 fell from a high place" -- for fall distance > 5 blocks
			-- "@1 fell while climbing"
			-- "@1 fell off some twisting vines"
			-- "@1 fell off some weeping vines"
			-- "@1 fell off some vines"
			-- "@1 fell off scaffolding"
			-- "@1 fell off a ladder"
		},
		fly_into_wall = {
			plain = NS("@1 experienced kinetic energy"),
			assist = NS("@1 experienced kinetic energy whilst trying to escape @2"),
		},
		out_of_world = {
			plain = NS("@1 fell out of the world"),
			assist = NS("@1 didn't want to live in the same world as @2"),
		},
		generic = {
			plain = NS("@1 died"),
			assist = NS("@1 died because of @2"),
		},
		magic = {
			plain = NS("@1 was killed by magic"),
			assist = NS("@1 was killed by magic whilst trying to escape @2"),
			killer = NS("@1 was killed by @2 using magic"),
			item = NS("@1 was killed by @2 using @3"),
		},
		dragon_breath = {
			plain = NS("@1 was roasted in dragon breath"),
			killer = NS("@1 was roasted in dragon breath by @2"),
		},
		wither = {
			plain = NS("@1 withered away"),
			escape = NS("@1 withered away whilst fighting @2"),
		},
		wither_skull = {
			plain = NS("@1 was killed by magic"),
			killer = NS("@1 was shot by a skull from @2"),
		},
		anvil = {
			plain = NS("@1 was squashed by a falling anvil"),
			escape = NS("@1 was squashed by a falling anvil whilst fighting @2"),
		},
		falling_node = {
			plain = NS("@1 was squashed by a falling block"),
			assist = NS("@1 was squashed by a falling block whilst fighting @2"),
		},
		mob = {
			killer = NS("@1 was slain by @2"),
			item = NS("@1 was slain by @2 using @3"),
		},
		player = {
			killer = NS("@1 was slain by @2"),
			item = NS("@1 was slain by @2 using @3")
		},
		arrow = {
			killer = NS("@1 was shot by @2"),
			item = NS("@1 was shot by @2 using @3"),
		},
		fireball = {
			killer = NS("@1 was fireballed by @2"),
			item = NS("@1 was fireballed by @2 using @3"),
		},
		thorns = {
			killer = NS("@1 was killed trying to hurt @2"),
			item = NS("@1 tried to hurt @2 and died by @3"),
		},
		explosion = {
			plain = NS("@1 blew up"),
			killer = NS("@1 was blown up by @2"),
			item = NS("@1 was blown up by @2 using @3"),
			-- "@1 was killed by [Intentional Game Design]" -- for exploding bed in nether or end
		},
		cramming = {
			plain = NS("@1 was squished too much"),
			assist = NS("@1 was squashed by @2"),	-- surprisingly "escape" is actually the correct subtype
		},
		fireworks = {
			plain = NS("@1 went off with a bang"),
			item = NS("@1 went off with a bang due to a firework fired by @2 from @3"),
		},
		sweet_berry = {
			plain = NS("@1 was poked to death by a sweet berry bush"),
			assist = NS("@1 was poked to death by a sweet berry bush whilst trying to escape @2"),
		},
		-- Missing snowballs: The Minecraft wiki mentions them but it doesn't seem like they have a dedicated death message in MC
	},
}

local function get_item_killer_message(obj, messages, reason)
	if messages.item then
		local wielded = mcl_util.get_wielded_item(reason.source)
		local itemname = wielded:get_meta():get_string("name")
		if itemname ~= "" then
			itemname = "[" .. itemname .. "]"
			if mcl_enchanting.is_enchanted(wielded:get_name()) then
				itemname = minetest.colorize(mcl_colors.AQUA, itemname)
			end
			return S(messages.item, mcl_util.get_object_name(obj), mcl_util.get_object_name(reason.source), itemname)
		end
	end
end

local function get_plain_killer_message(obj, messages, reason)
	return messages.killer and S(messages.killer, mcl_util.get_object_name(obj), mcl_util.get_object_name(reason.source))
end

local function get_killer_message(obj, messages, reason)
	return reason.source and (get_item_killer_message(obj, messages, reason) or get_plain_killer_message(obj, messages, reason))
end

local function get_assist_message(obj, messages, reason)
	if messages.assist and mcl_death_messages.assist[obj] then
		return S(messages.assist, mcl_util.get_object_name(obj), mcl_death_messages.assist[obj].name)
	end
end

local function get_plain_message(obj, messages, reason)
	if messages.plain then
		return S(messages.plain, mcl_util.get_object_name(obj))
	end
end

local function get_fallback_message(obj, messages, reason)
	return "mcl_death_messages.messages." .. reason.type .. " " .. mcl_util.get_object_name(obj)
end

mcl_damage.register_on_death(function(obj, reason)
	if not minetest.settings:get_bool("mcl_showDeathMessages", true) then
		return
	end

	local send_to

	if obj:is_player() then
		send_to = true
	end

	-- ToDo: add mob death messages for owned mobs, only send to owner (sent_to = "player name")

	if send_to then
		local messages = mcl_death_messages.messages[reason.type] or {}

		local message =
			get_killer_message(obj, messages, reason) or
			get_assist_message(obj, messages, reason) or
			get_plain_message(obj, messages, reason) or
			get_fallback_message(obj, messages, reason)

		if send_to == true then
			minetest.chat_send_all(message)
		else
			minetest.chat_send_player(send_to, message)
		end
	end
end)

mcl_damage.register_on_damage(function(obj, damage, reason)
	if obj:get_hp() - damage > 0 then
		if reason.source then
			mcl_death_messages.assist[obj] = {name = mcl_util.get_object_name(reason.source), timeout = 5}
		else
			mcl_death_messages.assist[obj] = nil
		end
	end
end)

minetest.register_globalstep(function(dtime)
	for obj, tbl in pairs(mcl_death_messages.assist) do
		tbl.timeout = tbl.timeout - dtime
		if not obj:is_player() and not obj:get_luaentity() or tbl.timeout > 0 then
			mcl_death_messages.assist[obj] = nil
		end
	end
end)
