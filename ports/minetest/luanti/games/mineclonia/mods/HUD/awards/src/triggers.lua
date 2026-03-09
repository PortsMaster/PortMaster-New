-- AWARDS
--
-- Copyright (C) 2013-2015 rubenwardy
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
-- You should have received a copy of the GNU Lesser General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
--

-- Don't actually use translator here. We define empty S() to fool the update_translations script
-- into extracting those strings for the templates. Actual translation is done in api_triggers.lua.
local S = function (str)
	return str
end

-- Check if a player object is valid for awards.
local function player_ok(player)
	return player and player.is_player and player:is_player() and not player.is_fake_player
end

awards.register_trigger("chat", {
	type = "counted",
	progress = S("@1/@2 chat messages"),
	auto_description = { S("Send a chat message"), S("Chat @1 times") },
})
core.register_on_chat_message(function(name, message)
	local player = core.get_player_by_name(name)
	if not player_ok(player) or string.find(message, "/")  then
		return
	end

	awards.notify_chat(player)
end)


awards.register_trigger("join", {
	type = "counted",
	progress = S("@1/@2 joins"),
	auto_description = { S("Join once"), S("Join @1 times") },
})
core.register_on_joinplayer(awards.notify_join)


awards.register_trigger("death", {
	type = "counted_key",
	progress = S("@1/@2 deaths"),
	auto_description = { S("Die once of @1"), S("Die @1 times of @2") },
	auto_description_total = { S("Die @1 times."), S("Mine @1 times") },
	get_key = function(_, def)
		return def.trigger.reason
	end,
})
core.register_on_dieplayer(function(player, reason)
	if reason then
		reason = reason.type
	else
		reason = "unknown"
	end
	awards.notify_death(player, reason)
end)


awards.register_trigger("dig", {
	type = "counted_key",
	progress = S("@1/@2 dug"),
	auto_description = { S("Mine: @1"), S("Mine: @1×@2") },
	auto_description_total = { S("Mine @1 block."), S("Mine @1 blocks.") },
	get_key = function(_, def)
		return core.registered_aliases[def.trigger.node] or def.trigger.node
	end,
	key_is_item = true,
})
core.register_on_dignode(function(pos, node, player)
	if not player_ok(player) or not pos or not node then
		return
	end

	local node_name = node.name
	node_name = core.registered_aliases[node_name] or node_name
	awards.notify_dig(player, node_name)
end)


awards.register_trigger("place", {
	type = "counted_key",
	progress = S("@1/@2 placed"),
	auto_description = { S("Place: @1"), S("Place: @1×@2") },
	auto_description_total = { S("Place @1 block."), S("Place @1 blocks.") },
	get_key = function(_, def)
		return core.registered_aliases[def.trigger.node] or def.trigger.node
	end,
	key_is_item = true,
})
core.register_on_placenode(function(pos, node, player)
	if not player_ok(player) or not pos or not node then
		return
	end

	local node_name = node.name
	node_name = core.registered_aliases[node_name] or node_name
	awards.notify_place(player, node_name)
end)


awards.register_trigger("craft", {
	type = "counted_key",
	progress = S("@1/@2 crafted"),
	auto_description = { S("Craft: @1"), S("Craft: @1×@2") },
	auto_description_total = { S("Craft @1 item"), S("Craft @1 items.") },
	get_key = function(_, def)
		return core.registered_aliases[def.trigger.item] or def.trigger.item
	end,
	key_is_item = true,
})
core.register_on_craft(function(itemstack, player)
	if not player_ok(player) or itemstack:is_empty() then
		return
	end

	local itemname = itemstack:get_name()
	itemname = core.registered_aliases[itemname] or itemname
	awards.notify_craft(player, itemname, itemstack:get_count())
end)


awards.register_trigger("eat", {
	type = "counted_key",
	progress = S("@1/@2 eaten"),
	auto_description = { S("Eat @1"), S("Eat @1×@2") },
	auto_description_total = { S("Eat @1 item"), S("Eat @1 items.") },
	get_key = function(_, def)
		return core.registered_aliases[def.trigger.item] or def.trigger.item
	end,
	key_is_item = true,
})
core.register_on_item_eat(function(_, _, itemstack, player, _)
	if not player_ok(player) or itemstack:is_empty() then
		return
	end

	local itemname = itemstack:get_name()
	itemname = core.registered_aliases[itemname] or itemname
	awards.notify_eat(player, itemname)
end)

awards.register_trigger ("structure", {
	type = "custom",
	progress = "",
	auto_description = {
		S ("Enter one of the titular structures"),
		S ("Enter one of the titular structures"),
	},
	on_register = function (self, award)
		table.insert (self.on, {
			name = award.name,
			structure = assert (award.trigger.structure),
		})
	end,
})

local function test_player_structures (dtime)
	local get_structures_at = mcl_levelgen.get_structures_at

	for player in mcl_util.connected_players () do
		for _, trigger in ipairs (awards.on.structure) do
			if type (trigger) == "table" then
				local structure = trigger.structure
				local pos = mcl_util.get_nodepos (player:get_pos ())
				for _, entry in pairs (get_structures_at (pos, false)) do
					if entry.data == structure then
						awards.unlock (player:get_player_name (),
							       trigger.name)
						break
					end
				end
			end
		end
	end
end

if mcl_levelgen.levelgen_enabled or mcl_levelgen.enable_ersatz then
	core.register_globalstep (test_player_structures)
end
