------------------------------------------------------------------------
-- New MCL villagers.
------------------------------------------------------------------------

local mob_class = mcl_mobs.mob_class
local F = core.formspec_escape
local S = core.get_translator ("mobs_mc")
local mob_griefing = mobs_mc.is_mob_griefing_enabled("villager")
local is_valid = mcl_util.is_valid_objectref
local villager_verbose
	= core.settings:get_bool ("villager_verbose", false)
local villager_debug
	= core.settings:get_bool ("villager_debug", false)
local scale_chance = mcl_mobs.scale_chance

mobs_mc.jobsites = {}

------------------------------------------------------------------------
-- Abstract Villager.
------------------------------------------------------------------------

local WIELD_POSITION = vector.copy ({
	x = 0,
	y = 1.26138 * 2.75 + math.sin (math.rad (-135)) * -0.4 * 2.75,
	z = math.cos (math.rad (-135)) * -0.4 * 2.75,
})

local villager_base = {
	type = "npc",
	_spawn_category = "misc",
	hp_min = 20,
	hp_max = 20,
	head_swivel = "Head_Control",
	bone_eye_height = 6.47817,
	head_eye_height = 1.62,
	curiosity = 10,
	runaway = true,
	collisionbox = {-0.25, 0.0, -0.25, 0.25, 1.90, 0.25},
	visual = "mesh",
	mesh = "mobs_mc_villager.b3d",
	textures = {
		"mobs_mc_villager.png",
	},
	makes_footstep_sound = true,
	movement_speed = 10.0,
	drops = {},
	can_despawn = false,
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 35,
		nitwit_start = 41, nitwit_end = 81, nitwit_speed = 40,
		sleep_start = 82, sleep_end = 82, sleep_speed = 0,
	},
	sounds = {
		random = "mobs_mc_villager",
		damage = "mobs_mc_villager_hurt",
		distance = 10,
	},
	wielditem_info = {
		position = WIELD_POSITION,
		rotation = vector.new (135, 0, 0),
		bone = "arm",
	},
	can_wield_items = "no_pickup",
	_inventory_size = 8,
	_trades = {},
	persistent = true,
	floats = 1,
}

------------------------------------------------------------------------
-- Abstract Villager visuals.
------------------------------------------------------------------------

function villager_base:wielditem_transform (info, stack)
	local rot, pos, size
		= mob_class.wielditem_transform (self, info, stack)
	size.x = size.x / 1.5
	size.y = size.y / 1.5
	return rot, pos, size
end

------------------------------------------------------------------------
-- Abstract Villager trading.
------------------------------------------------------------------------

local trade_class = {
	wanted1 = "",
	wanted2 = "",
	offered = "",
	uses = 0,
	max_uses = 1,
	reward_xp = true,
	price_multiplier = 0,
	special_price_diff = 0,
	demand = 0,
	xp = 0,
	tier = 0,
}

local trade_class_meta = {
	__index = trade_class,
}

function trade_class:get_wanted1 ()
	local stack = ItemStack (self.wanted1)
	if stack:is_empty () then
		return stack
	end
	local max = stack:get_stack_max ()
	local count = stack:get_count ()
	local greed = self.price_multiplier
	local gouge = math.max (0, math.floor (count * self.demand) * greed)
		+ self.special_price_diff
	local total = math.min (math.max (1, gouge + stack:get_count ()), max)
	stack:set_count (total)
	return stack
end

function trade_class:get_wanted2 ()
	local stack = ItemStack (self.wanted2)
	if stack:is_empty () then
		return stack
	end
	local max = stack:get_stack_max ()
	local count = stack:get_count ()
	local greed = self.price_multiplier
	local gouge = math.max (0, math.floor (count * self.demand) * greed)
		+ self.special_price_diff
	local total = math.min (math.max (1, gouge + stack:get_count ()), max)
	stack:set_count (total)
	return stack
end

function trade_class:get_offered ()
	local stack = ItemStack (self.offered)
	if mcl_enchanting.is_enchanted (stack:get_name ()) then
		mcl_enchanting.load_enchantments (stack)
	end
	return stack
end

function trade_class:is_locked ()
	return self.uses >= self.max_uses
end

function trade_class:update_demand ()
	-- Increase demand if the item was sold out, and reduce it if
	-- there was a surplus.
	self.demand = self.demand + (self.uses - (self.max_uses - self.uses))
end

function mobs_mc.make_villager_trade (tbl)
	local copy = table.copy (tbl)
	setmetatable (copy, trade_class_meta)
	assert (copy.update_demand)
	return copy
end

local function eval_item (item)
	if type (item) == "function" then
		return item ()
	else
		return item
	end
end

function mobs_mc.trade_from_table (pr, trade, reward_xp)
	local wanted1 = ItemStack (eval_item (trade[1][1]))
	wanted1:set_count (pr:next (trade[1][2], trade[1][3]))

	local wanted2 = ItemStack ()
	if trade[1][4] then
		wanted2 = ItemStack (eval_item (trade[1][4]))
		wanted2:set_count (pr:next (trade[1][5], trade[1][6]))
	end

	local offered = ItemStack (eval_item (trade[2][1]))
	offered:set_count (pr:next (trade[2][2], trade[2][3]))

	local name = offered:get_name ()
	if mcl_enchanting.is_enchanted (name) then
		if mcl_enchanting.is_book (name) then
			offered = mcl_enchanting.enchant_uniform_randomly (offered, {
				"soul_speed",
			}, pr)
		else
			mcl_enchanting.enchant_randomly (offered, pr:next (5, 19),
							 false, false, true, pr)
			mcl_enchanting.unload_enchantments (offered)
		end
	end

	return mobs_mc.make_villager_trade ({
		wanted1 = wanted1:to_string (),
		wanted2 = wanted2:to_string (),
		offered = offered:to_string (),
		max_uses = trade[3] or 12,
		xp = trade[4] or 1,
		reward_xp = reward_xp,
		price_multiplier = trade[5] or 0.0,
	})
end

function villager_base:mob_activate (staticdata, dtime)
	self._trading_with = {}
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	if not rawget (self, "_gossips") then
		self._gossips = {}
	end
	if not rawget (self, "_reputation") then
		self._reputation = {}
	end
	if not rawget (self, "_trades") then
		self._trades = {}
	else
		for _, trade in pairs (self._trades) do
			setmetatable (trade, trade_class_meta)
		end
	end
	if not self._inventory then
		self._inventory = {
			"",
			"",
			"",
			"",
			"",
			"",
			"",
			"",
		}
	end
	return true
end

local function get_trading_inventory (player)
	local trade_inv_name = "mobs_mc:trade_" .. player:get_player_name ()
	return core.get_inventory ({
		type = "detached",
		name = trade_inv_name,
	})
end

-- Return a single itemstack in the given inventory to the player's
-- main inventory, or drop it when there's no space left.

local function return_item (itemstack, dropper, pos, inv_p)
	if dropper:is_player () then
		-- Return to main inventory
		if inv_p:room_for_item ("main", itemstack) then
			inv_p:add_item ("main", itemstack)
		else
			-- Drop item on the ground
			local v = dropper:get_look_dir ()
			local p = {
				x = pos.x,
				y = pos.y + 1.2,
				z = pos.z,
			}
			p.x = p.x + (math.random (1,3) * 0.2)
			p.z = p.z + (math.random (1,3) * 0.2)
			local obj = core.add_item (p, itemstack)
			if obj then
				v.x = v.x * 4
				v.y = v.y * 4 + 2
				v.z = v.z * 4
				obj:set_velocity (v)
				obj:get_luaentity ()._insta_collect = false
			end
		end
	else
		-- Fallback for unexpected cases.
		core.add_item (pos, itemstack)
	end
	return itemstack
end

local function return_fields (player)
	local inv_t = get_trading_inventory (player)
	local inv_p = player:get_inventory ()
	if not inv_t or not inv_p then
		return
	end
	for i = 1, inv_t:get_size ("input") do
		local stack = inv_t:get_stack ("input", i)
		return_item (stack, player, player:get_pos (), inv_p)
		stack:clear ()
		inv_t:set_stack ("input", i, stack)
	end
	inv_t:set_stack ("output", 1, "")
end

mobs_mc.return_trading_fields = return_fields

function villager_base:trading_stopped (player)
end

function villager_base:stop_trading ()
	for player, _ in pairs (self._trading_with) do
		if is_valid (player) then
			local formname = "mobs_mc:trading_formspec"
			return_fields (player)
			core.close_formspec (player:get_player_name (), formname)
		end
		self:trading_stopped (player)
	end
end

function villager_base:is_trading ()
	for _, _ in pairs (self._trading_with) do
		return true
	end
	return false
end

function villager_base:on_deactivate (removal)
	mob_class.on_deactivate (self, removal)
	self:stop_trading ()
end

function villager_base:get_staticdata_table ()
	local supertable = mob_class.get_staticdata_table (self)
	if supertable then
		supertable._trading_with = nil
	end
	return supertable
end

function villager_base:update_trades (trades)
	self._trades = trades
	for key, value in pairs (self._trading_with) do
		if value < 1 or value > #trades then
			value = nil
		end
		self:show_trade_formspec (key, value)
	end
end

function villager_base:show_trade_progress_bar ()
	return true
end

function villager_base:tier_progress ()
	return 0
end

function villager_base:get_tier_name (id)
	return "Unknown tier"
end

function villager_base:get_dialog_label ()
	return mcl_util.get_object_name (self.object)
end

------------------------------------------------------------------------
-- Trading logic.
------------------------------------------------------------------------

local trading_players = {}

function villager_base:on_transaction (trade, player)
end

function villager_base:validate_transaction (inv, player, trade_id)
	local trade = self._trades[trade_id]
	assert (trade)

	local wanted1 = trade:get_wanted1 ()
	local wanted2 = trade:get_wanted2 ()

	if not inv:contains_item ("input", wanted1)
		and not inv:contains_item ("input", wanted2) then
		return 0
	end

	local stacktype = inv:get_stack ("output", 1)
	local desired = trade:get_offered ()
	if stacktype == desired and desired:get_count () > 0 then
		return desired:get_count ()
	else
		return 0
	end
end

function villager_base:complete_transaction (inv, player, trade_id)
	local trade = self._trades[trade_id]
	assert (trade)
	local wanted1 = trade:get_wanted1 ()
	local wanted2 = trade:get_wanted2 ()

	-- It's pointless to enforce purchase costs at this juncture,
	-- as by the call to on_take it is already too late to alter
	-- the outcome of the inventory operation.  They are instead
	-- enforced by validate_transaction.
	inv:remove_item ("input", wanted1)
	inv:remove_item ("input", wanted2)
	trade.uses = trade.uses + 1
	if trade.reward_xp then
		local xp = 3 + math.random (3)
		mcl_experience.throw_xp (self.object:get_pos (), xp)
	end
	self:on_transaction (trade, player)
	awards.unlock (player:get_player_name (), "mcl:whatAdeal")

	-- If any output items remain, drop them at the player.
	local output = inv:get_stack ("output", 1)
	if output:get_count () >= 0 then
		local player_pos = player:get_pos ()
		mcl_util.drop_item_stack (player_pos, output)
	end
end

local inv_class = {}

function inv_class:allow_take (listname, index, stack, player)
	if listname == "input" then
		return stack:get_count ()
	elseif listname == "output" then
		-- Whom is this player trading with?
		local merchant = trading_players[player]
		if not merchant or not is_valid (merchant) then
			return 0
		end
		-- What is being bartered?
		local entity = merchant:get_luaentity ()
		local trade_id = entity._trading_with[player]
		if not trade_id or not entity._trades[trade_id] then
			return 0
		end

		-- Don't permit taking less than the entire offer.
		local count = stack:get_count ()
		local offer = self:get_stack ("output", index)
		if count ~= offer:get_count () then
			return 0
		end

		return entity:validate_transaction (self, player, trade_id)
	else
		return 0
	end
end

function inv_class:allow_move (from_list, from_index, to_list, to_index, count, player)
	return from_list == "input" and to_list == "input" and count or 0
end

function inv_class:allow_put (listname, _, stack, player)
	if listname == "input" then
		local merchant = trading_players[player]
		if not merchant or not is_valid (merchant) then
			return 0
		end
		-- Is there anything that is being bartered?
		local entity = merchant:get_luaentity ()
		local trade_id = entity._trading_with[player]
		if not trade_id or not entity._trades[trade_id] then
			return 0
		end
		return stack:get_count ()
	end

	return 0
end

function inv_class:on_put (listname, index, stack, player)
	local merchant = trading_players[player]
	if not merchant or not is_valid (merchant) then
		return
	end
	-- Is there anything that is being bartered?
	local entity = merchant:get_luaentity ()
	local trade_id = entity._trading_with[player]
	if not trade_id or not entity._trades[trade_id] then
		return
	end
	entity:update_offer (self, player, trade_id, true)
end

function inv_class:on_take (listname, index, stack, player)
	if listname == "input" or listname == "output" then
		local merchant = trading_players[player]
		if not merchant or not is_valid (merchant) then
			return
		end
		-- Is there anything that is being bartered?
		local entity = merchant:get_luaentity ()
		local trade_id = entity._trading_with[player]
		if not trade_id or not entity._trades[trade_id] then
			return
		end
		if listname == "output" then
			core.sound_play ("mobs_mc_villager_accept", {
				to_player = player:get_player_name (),
				object = self.object,
			}, true)
			entity:complete_transaction (self, player, trade_id)
			entity:update_offer (self, player, trade_id, false)
			entity:show_trade_formspec (player, trade_id)
		else
			entity:update_offer (self, player, trade_id, false)
			core.sound_play ("mobs_mc_villager_deny", {
				to_player = player:get_player_name (),
				object = self.object,
			}, true)
		end
		return
	end
end

local function move_stack (inv1, list1, inv2, list2, stack, pos)
	if stack and inv1:contains_item (list1, stack)
		and inv2:room_for_item (list2, stack) then
		return inv2:add_item (list2, inv1:remove_item (list1, stack))
	elseif pos and not inv2:room_for_item (list2, stack) then
		mcl_util.drop_item_stack (pos, stack)
		inv1:remove_item (list1, stack)
	end
end

local function move_index (inv1, list1, inv2, list2, index, pos)
	local stacktype = inv1:get_stack (list1, index)
	move_stack (inv1, list1, inv2, list2, stacktype, pos)
end

function villager_base:set_trade (player, inv, id)
	local trade = self._trades[id]
	if not trade then
		return
	end
	self._trading_with[player] = id
	local wanted1 = trade:get_wanted1 ()
	local wanted2 = trade:get_wanted2 ()
	inv:set_stack ("wanted", 1, wanted1)
	inv:set_stack ("wanted", 2, wanted2)
	local offered = trade:get_offered ()
	inv:set_stack ("offered", 1, offered)

	local p_inv = player:get_inventory ()
	local pos = player:get_pos ()
	-- Eject items previously given as input.
	move_index (inv, "input", p_inv, "main", 1, pos)
	move_index (inv, "input", p_inv, "main", 2, pos)

	-- Move items from the player's inventory into the input
	-- slots.
	move_stack (p_inv, "main", inv, "input", wanted1, pos)
	move_stack (p_inv, "main", inv, "input", wanted2, pos)
end

function villager_base:update_offer (inv, player, idx, sounds)
	local name = player:get_player_name ()
	local trade = self._trades[idx]
	if not trade then
		return
	end
	local wanted1 = trade:get_wanted1 ()
	local wanted2 = trade:get_wanted2 ()
	local sound = {
		to_player = name,
		object = self.object,
	}
	if not trade:is_locked ()
		and inv:contains_item ("input", wanted1)
		and (wanted2:is_empty () or inv:contains_item ("input", wanted2)) then
		inv:set_stack ("output", 1, trade:get_offered ())
		if sounds then
			core.sound_play ("mobs_mc_villager_accept",
					     sound, true)
		end
	else
		inv:set_stack ("output", 1, ItemStack ())
		core.sound_play ("mobs_mc_villager_deny",
				     sound, true)
	end
end

------------------------------------------------------------------------
-- Trading formspec management.
------------------------------------------------------------------------

-- Trade spec templates, some with args to use with string.format
-- arg 1 = %s = title
-- arg 2 = %s = total xp width
-- arg 3 = %i = scroller max val
local fs_header_template = [[
formspec_version[6]
size[15.2,9.3]
position[0.5,0.5]

label[7.5,0.3;%s]
style_type[label;textcolor=white]

background[6.3,0.55;5.9,0.2;mcl_inventory_bar.png]
background[6.3,0.55;%s,0.2;mcl_inventory_bar_fill.png]

scrollbaroptions[min=1;max=%i;thumbsize=1]
scrollbar[3.3,0.05;0.4,9.1;vertical;trade_scroller;1]
scroll_container[0.1,0.1;3.2,9.5;trade_scroller;vertical]

]]

-- arg 1 = %s = title
-- arg 3 = %i = scroller max val
local fs_header_no_bar_template = [[
formspec_version[6]
size[15.2,9.3]
position[0.5,0.5]

label[7.5,0.3;%s]
style_type[label;textcolor=white]

scrollbaroptions[min=1;max=%i;thumbsize=1]
scrollbar[3.3,0.05;0.4,9.1;vertical;trade_scroller;1]
scroll_container[0.1,0.1;3.2,9.5;trade_scroller;vertical]

]]


-- arg 1 = %f = H
-- arg 2 = %s = level
local fs_level_template = [[
style_type[label;textcolor=#323232]
label[0.1,%f2;%s]
style_type[label;textcolor=white]

]]

-- arg 1 = %f = H for container
-- arg 2 = %i = trade number
-- arg 3 = %s = wanted 1
-- arg 4 = %s = wanted 1 tooltip
-- arg 5 = %s = wanted 1 count
local fs_trade_start_template = [[
container[0.1,%f2]
	button[0.0,0.0;3.05,0.6;trade_%i;]

	item_image[0.02,0.03;0.5,0.5;%s]
	tooltip[0.1,0.0;0.5,0.5;%s]
	label[0.3,0.35;%s]

]]

-- arg 1 = %s = wanted 2
-- arg 2 = %s = wanted 2 tooltip
-- arg 3 = %s = wanted 2 count
local fs_trade_wants2_template = [[

	item_image[0.6,0.03;0.5,0.5;%s]
	tooltip[0.6,0.1;0.5,0.5;%s]
	label[0.8,0.35;%s]

]]

-- This should be what is in mcl_inventory_button9_pressed with the pressed button
-- image used as the unpressed option
local fs_trade_pushed_template = [[
	style_type[button;border=false;bgimg=mcl_inventory_button9_pressed.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]

]]

-- This should be what is in mcl_inventory_button9
local fs_trade_unpush_template = [[
	style_type[button;border=false;bgimg=mcl_inventory_button9.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]

]]

local fs_trade_arrow_template = [[
	image[1.8,0.15;0.5,0.32;gui_crafting_arrow.png]

]]

local fs_trade_disabled_template = [[
	image[1.8,0.15;0.5,0.32;mobs_mc_trading_formspec_disabled.png]

]]

-- arg 1 = %s = offered
-- arg 2 = %s = offered tooltip
-- arg 3 = %s = offered count
local fs_trade_end_template = [[
	item_image[2.5,0.03;0.5,0.5;%s]
	tooltip[2.5,0.0;0.5,0.5;%s]
	label[2.8,0.35;%s]

container_end[]

]]

local fs_footer_template = [[

scroll_container_end[]

image[9.5,1.0;1.0,0.5;gui_crafting_arrow.png]
image[9.5,2.25;1.0,0.5;gui_crafting_arrow.png]

]] ..
mcl_formspec.get_itemslot_bg_v4(6.4,2.0,2,1)
..
mcl_formspec.get_itemslot_bg_v4(11.1,2.0,1,1)
..
mcl_formspec.get_itemslot_bg_v4(3.97,3.98,9,3)
..
mcl_formspec.get_itemslot_bg_v4(3.97,7.98,9,1)
 ..
[[

 list[current_player;main;3.97,3.98;9,3;9]
 list[current_player;main;3.97,7.98;9,1;]

]]

-- arg 1 = %s = wanted
-- arg 2 = %s = wanted tooltip
-- arg 3 = %s = wanted count
local fs_wants_template = [[

	item_image[6.4,0.75;1.0,1.0;%s]
	tooltip[6.4,0.75;1.0,1.0;%s]
	label[7.20,1.7;%s]

]]

-- arg 1 = %s = wanted 2
-- arg 2 = %s = wanted 2 tooltip
-- arg 3 = %s = wanted 2 count
local fs_wants2_template = [[

	item_image[7.6,0.75;1.0,1.0;%s]
	tooltip[7.6,0.75;1.0,1.0;%s]
	label[8.5,1.7;%s]

]]

-- arg 1 = %s = offered
-- arg 2 = %s = offered tooltip
-- arg 3 = %s = offered count
local fs_offered_template = [[

	item_image[11.1,0.75;1.0,1.0;%s]
	tooltip[11.1,0.75;1.0,1.0;%s]
	label[11.95,1.7;%s]

]]

-- arg 1 = %s = tradeinv
-- arg 2 = %s = tradeinv
-- arg 3 = %s = tradeinv
-- arg 4 = %s = tradeinv
local fs_footer_template2 = [[

list[%s;input;6.4,2.0;2,1;]
list[%s;output;11.1,2.0;1,1;]
listring[%s;output]
listring[current_player;main]
listring[%s;input]
listring[current_player;main]
]]

local button_buffer = 0.65

local function count_string (count)
	if count == 1 then
		count = ""
	end
	return tostring (count)
end

function villager_base:show_trade_formspec (player, tradenum)
	local current = trading_players[player]
	if current and is_valid (current) and current ~= self.object then
		return false
	end

	if not self._trades then
		return false
	elseif not tradenum then
		tradenum = 0
	end

	local playername = player:get_player_name ()
	local trade_inv_name = "mobs_mc:trade_" .. playername
	local formspec_name = F ("detached:" .. trade_inv_name)
	local inv = core.get_inventory ({
		type = "detached",
		name = trade_inv_name,
	})
	if not inv then
		return false
	end

	trading_players[player] = self

	local formspec = {
		false,
	}
	local best_tier = 0
	local h = 0.0
	local trade_str = {}
	local str

	local trades = self._trades
	for i, trade in ipairs (trades) do
		local wanted1 = trade:get_wanted1 ()
		local wanted2 = trade:get_wanted2 ()
		local offered = trade:get_offered ()

		if best_tier ~= trade.tier then
			best_tier = trade.tier

			h = h + 0.3
			local name = self:get_tier_name (best_tier)
			str = string.format (fs_level_template, h, name)
			table.insert (formspec, str)
			h = h + 0.2
		end

		if i == tradenum then
			table.insert (formspec, fs_trade_pushed_template)
			str = string.format (fs_wants_template, wanted1:get_name (),
					     F (wanted1:get_description ()),
					     count_string (wanted1:get_count ()))
			table.insert (trade_str, str)
			if not wanted2:is_empty () then
				str = string.format (fs_wants2_template, wanted2:get_name (),
						     F (wanted2:get_description ()),
						     count_string (wanted2:get_count ()))
				table.insert (trade_str, str)
			end
			str = string.format (fs_offered_template, offered:get_name (),
					     F (offered:get_description ()),
					     count_string (offered:get_count ()))
			table.insert (trade_str, str)
		end

		str = string.format (fs_trade_start_template, h, i,
				     wanted1:get_name (),
				     F (wanted1:get_description ()),
				     count_string (wanted1:get_count ()))
		table.insert (formspec, str)

		if not wanted2:is_empty () then
			str = string.format (fs_trade_wants2_template,
					     wanted2:get_name (),
					     F (wanted2:get_description ()),
					     count_string (wanted2:get_count ()))
			table.insert (formspec, str)
		end

		if trade:is_locked () then
			table.insert (formspec, fs_trade_disabled_template)
		else
			table.insert (formspec, fs_trade_arrow_template)
		end

		str = string.format (fs_trade_end_template,
				     offered:get_name (),
				     F (offered:get_description ()),
				     count_string (offered:get_count ()))
		table.insert (formspec, str)

		if i == tradenum then
			table.insert (formspec, fs_trade_unpush_template)
		end
		h = h + button_buffer
	end

	local header
	local title = self:get_dialog_label ()
	local label = core.colorize ("#313131", title)
	if self:show_trade_progress_bar () then
		local progress = self:tier_progress ()
		header = string.format (fs_header_template,
					F (label), progress * 5.9,
					h * 10)
	else
		header = string.format (fs_header_no_bar_template,
					F (label), h * 10)
	end
	formspec[1] = header
	table.insert (formspec, fs_footer_template)
	if #trade_str > 0 then
		local tradestr = table.concat (trade_str)
		table.insert (formspec, tradestr)
		str = string.format (fs_footer_template2,
				     formspec_name, formspec_name,
				     formspec_name, formspec_name)
		table.insert (formspec, str)
	end

	core.sound_play ("mobs_mc_villager_trade", {
		to_player = playername,
		object = self.object,
	}, true)
	str = table.concat (formspec)
	core.show_formspec (playername, "mobs_mc:trading_formspec", str)
	trading_players[player] = self.object
	self._trading_with[player] = tradenum
	return true
end

core.register_on_player_receive_fields (function (player, formname, fields)
	if formname == "mobs_mc:trading_formspec" then
		if fields.quit then
			return_fields (player)
			local trader = trading_players[player]
			if trader and is_valid (trader) then
				local entity = trader:get_luaentity ()
				entity._trading_with[player] = nil
				entity:trading_stopped (player)
			end
			trading_players[player] = nil
		else
			local trader = trading_players[player]
			if not trader or not is_valid (trader) then
				return
			end
			local entity = trader:get_luaentity ()
			local inv = get_trading_inventory (player)
			if not inv then
				return
			end

			for i, _ in pairs (entity._trades) do
				if fields["trade_" .. i] then
					entity:set_trade (player, inv, i)
					entity:update_offer (inv, player, i, false)
					entity:show_trade_formspec (player, i)
					break
				end
			end
		end
	end
end)

core.register_on_joinplayer (function (player)
	local playername = player:get_player_name ()
	local inv_name = "mobs_mc:trade_" .. playername
	local inv = core.get_inventory ({
		type = "detached",
		name = inv_name,
	})
	if not inv then
		inv = core.create_detached_inventory (inv_name, inv_class,
							  playername)
	end
	inv:set_size ("input", 2)
	inv:set_size ("output", 1)
	inv:set_size ("wanted", 2)
	inv:set_size ("offered", 1)
end)

core.register_on_leaveplayer (function (player)
	local trading = trading_players[player]
	if trading and is_valid (trading) then
		local entity = trading:get_luaentity ()
		entity._trading_with[player] = nil
		return_fields (player)
		entity:trading_stopped (player)
	end
	trading_players[player] = nil
end)

mobs_mc.villager_base = villager_base

------------------------------------------------------------------------
-- Villagers proper.
------------------------------------------------------------------------

local villager = table.merge (villager_base, {
      description = S("Villager"),
      can_wield_items = true,
      can_open_doors = true,
      tracking_distance = 48.0,
      view_range = 48.0,
      _head_rot_limit = math.rad (110),
      ----------------------------------------
      -- Villager identity.
      ----------------------------------------
      _home = nil,
      _job_site = nil,
      _provisional_job_site = nil,
      _bell = nil,
      _profession = nil,
      ----------------------------------------
      -- Villager variables.
      ----------------------------------------
      _last_slept_gmt = 0,
      _last_awoken_gmt = 0,
      _last_labored_gmt = 0,
      _last_alarm_gmt = 0,
      _last_gossip_decay_gmt = 0,
      _last_gossip_gmt = 0,
      _last_golem_gmt = 0,
      _last_restock_gmt = -1,
      _last_restock_day = -1,
      _food_level = 0,
      ----------------------------------------
      -- Villager data.
      -- The metatable values of these fields
      -- are replaced in mob_activate or ai_init.
      ----------------------------------------
      _villager_type = "plains",
      _retry_counters = {},
      _gossips = {},
      _reputation = {},
      _xp = 0,
      _riches = 0,
      _tier = 1,
      _levelup_in = 0.0,
      _restocks_remaining = 2,
})

local pr = PcgRandom (os.time () - 472)
local r = 1 / 2147483647

local villager_professions = {
	{
		description = S ("Armorer"),
		name = "armorer",
		poi = "mcl_villages:armorer",
		group = "mcl_blast_furnace:blast_furnace",
		texture = "mobs_mc_villager_profession_armorer.png",
		extra_pick_up = {},
	},
	{
		description = S ("Butcher"),
		name = "butcher",
		poi = "mcl_villages:butcher",
		group = "mcl_smoker:smoker",
		texture = "mobs_mc_villager_profession_butcher.png",
		extra_pick_up = {},
	},
	{
		description = S ("Cartographer"),
		name = "cartographer",
		poi = "mcl_villages:cartographer",
		group = "mcl_cartography_table:cartography_table",
		texture = "mobs_mc_villager_profession_cartographer.png",
		extra_pick_up = {},
	},
	{
		description = S ("Cleric"),
		name = "cleric",
		poi = "mcl_villages:cleric",
		group = "group:brewing_stand",
		texture = "mobs_mc_villager_profession_cleric.png",
		extra_pick_up = {},
	},
	{
		description = S ("Farmer"),
		name = "farmer",
		poi = "mcl_villages:farmer",
		group = "group:composter",
		texture = "mobs_mc_villager_profession_farmer.png",
		extra_pick_up = {
			"mcl_bone_meal:bone_meal",
			"mcl_farming:wheat_item",
			"mcl_farming:wheat_seeds",
			"mcl_farming:beetroot_seeds",
		},
	},
	{
		description = S ("Fisherman"),
		name = "fisherman",
		poi = "mcl_villages:fisherman",
		group = "group:barrel",
		texture = "mobs_mc_villager_profession_fisherman.png",
		extra_pick_up = {},
	},
	{
		description = S ("Fletcher"),
		name = "fletcher",
		poi = "mcl_villages:fletcher",
		group = "mcl_fletching_table:fletching_table",
		texture = "mobs_mc_villager_profession_fletcher.png",
		extra_pick_up = {},
	},
	{
		description = S ("Leatherworker"),
		name = "leatherworker",
		poi = "mcl_villages:leatherworker",
		group = "group:cauldron",
		texture = "mobs_mc_villager_profession_leatherworker.png",
		extra_pick_up = {},
	},
	{
		description = S ("Librarian"),
		name = "librarian",
		poi = "mcl_villages:librarian",
		group = "group:lectern",
		texture = "mobs_mc_villager_profession_librarian.png",
		extra_pick_up = {},
	},
	{
		description = S ("Mason"),
		name = "mason",
		poi = "mcl_villages:mason",
		group = "mcl_stonecutter:stonecutter",
		texture = "mobs_mc_villager_profession_mason.png",
		extra_pick_up = {},
	},
	{
		description = S ("Shepherd"),
		name = "shepherd",
		poi = "mcl_villages:shepherd",
		group = "mcl_loom:loom",
		texture = "mobs_mc_villager_profession_shepherd.png",
		extra_pick_up = {},
	},
	{
		description = S ("Toolsmith"),
		name = "toolsmith",
		poi = "mcl_villages:toolsmith",
		group = "mcl_smithing_table:table",
		texture = "mobs_mc_villager_profession_toolsmith.png",
		extra_pick_up = {},
	},
	{
		description = S ("Weaponsmith"),
		name = "weaponsmith",
		poi = "mcl_villages:weaponsmith",
		group = "mcl_grindstone:grindstone",
		texture = "mobs_mc_villager_profession_weaponsmith.png",
		extra_pick_up = {},
	},
	{
		description = S ("Nitwit"),
		name = "nitwit",
		poi = nil,
		group = nil,
		texture = "mobs_mc_villager_profession_nitwit.png",
		extra_pick_up = {},
	},
}

local professions_by_name = {}

local jobsite_groups, jobsite_names = {}
for _, profession in pairs (villager_professions) do
	professions_by_name[profession.name] = profession
	table.insert (jobsite_groups, profession.group)
	table.insert (mobs_mc.jobsites, profession.group)
end

core.register_on_mods_loaded (function ()
	jobsite_names = mcl_util.construct_node_list (jobsite_groups)
	for _, profession in ipairs (villager_professions) do
		profession.group_names
			= mcl_util.construct_node_list ({profession.group,})
	end
end)

local function get_profession (job_site_name)
	for _, profession in pairs (villager_professions) do
		if profession.group then
			if job_site_name == profession.group then
				return profession
			elseif profession.group:sub (1, 6) == "group:" then
				local len = #profession.group
				local group = profession.group:sub (7, len)

				if core.get_item_group (job_site_name, group) > 0 then
					return profession
				end
			end
		end
	end
	return nil
end

function mobs_mc.register_villager (profession, poi, trades, gifts)
	table.insert (villager_professions, profession)
	-- It appears that the search cache needn't be reinitialized
	-- after alterations to jobsite_groups, as
	-- mcl_util.make_node_search_cache saves a reference to the
	-- list and only resolves it after mods are loaded.
	table.insert (jobsite_groups, profession.group)
	table.insert (mobs_mc.jobsites, profession.group)

	professions_by_name[profession.name] = profession
	mobs_mc.villager_trades[profession.name] = trades
	mobs_mc.villager_gift_tables[profession.name] = gifts

	mcl_villages.register_poi (profession.poi, poi)
end

------------------------------------------------------------------------
-- Villager visuals.
------------------------------------------------------------------------

local villager_type_overlays = {
	taiga = "mobs_mc_villager_taiga.png",
	swamp = "mobs_mc_villager_swamp.png",
	snowy = "mobs_mc_villager_snow.png",
	savanna = "mobs_mc_villager_savanna.png",
	plains = "mobs_mc_villager_plains.png",
	jungle = "mobs_mc_villager_jungle.png",
	desert = "mobs_mc_villager_desert.png",
}

local badge_textures = {
	"mobs_mc_stone.png",
	"mobs_mc_iron.png",
	"mobs_mc_gold.png",
	"mobs_mc_emerald.png",
	"mobs_mc_diamond.png",
}

function villager:get_overlaid_texture ()
	local overlay = villager_type_overlays[self._villager_type]
	local profession = self._profession
		and professions_by_name[self._profession]
	local textures = {}

	table.insert (textures, "mobs_mc_villager_base.png")
	if overlay ~= "" then
		table.insert (textures, overlay)
	end
	if profession and profession.texture then
		table.insert (textures, profession.texture)

		local badge = badge_textures[self._tier]
		if badge then
			table.insert (textures, badge)
		end
	end
	return table.concat (textures, "^")
end

function villager:update_textures ()
	self.base_texture = {
		self:get_overlaid_texture (),
	}
	self:set_textures (self.base_texture)
	self.base_mesh = self.initial_properties.mesh
	self.base_size = self.initial_properties.visual_size
	self.base_colbox = self.initial_properties.collisionbox
	self.base_selbox = self.initial_properties.selectionbox
end

function villager:angry_villager_effect ()
	local cbox = self.collisionbox
	local self_pos = self.object:get_pos ()
	local x, y, z = self_pos.x, self_pos.y, self_pos.z
	local particlespawner = {
		time = 1.5,
		amount = 24,
		pos = {
			min = {
				x = x + cbox[1] - 0.2,
				y = y + cbox[2] + 0.2,
				z = z + cbox[3] - 0.2,
			},
			max = {
				x = x + cbox[4] + 0.2,
				y = y + cbox[5] + 0.2,
				z = z + cbox[6] + 0.2,
			},
		},
		exptime = {
			min = 0.9,
			max = 1.5,
		},
		size = {
			max = 2.8,
			min = 1.8,
		},
		texture = "mcl_particles_angry_villager.png",
	}
	core.add_particlespawner (particlespawner)
end

function villager:happy_villager_effect ()
	local cbox = self.collisionbox
	local self_pos = self.object:get_pos ()
	local x, y, z = self_pos.x, self_pos.y, self_pos.z
	local particlespawner = {
		time = 1.5,
		amount = 24,
		pos = {
			min = {
				x = x + cbox[1] - 0.2,
				y = y + cbox[2] + 0.2,
				z = z + cbox[3] - 0.2,
			},
			max = {
				x = x + cbox[4] + 0.2,
				y = y + cbox[5] + 0.2,
				z = z + cbox[6] + 0.2,
			},
		},
		exptime = {
			min = 0.9,
			max = 1.5,
		},
		size = {
			max = 2.8,
			min = 1.8,
		},
		texture = "mcl_particles_bonemeal.png^[colorize:#00EE00:125",
	}
	core.add_particlespawner (particlespawner)
end

function villager:terrified_villager_effect ()
	local cbox = self.collisionbox
	local particlespawner = {
		time = 1.5,
		amount = 12,
		pos = {
			min = {
				x = cbox[1] - 0.1,
				y = cbox[5] - 0.1,
				z = cbox[3] - 0.1,
			},
			max = {
				x = cbox[4] + 0.1,
				y = cbox[5] + 0.1,
				z = cbox[6] + 0.1,
			},
		},
		exptime = {
			min = 0.9,
			max = 1.5,
		},
		size = {
			max = 2.8,
			min = 1.8,
		},
		texpool = {
			"mobs_mc_wolf_splash_0.png",
			"mobs_mc_wolf_splash_1.png",
			"mobs_mc_wolf_splash_2.png",
			"mobs_mc_wolf_splash_3.png",
		},
		vel = {
			min = vector.new (-1.0, 1.7, -1.0),
			max = vector.new (1.0, 1.7, 1.0),
		},
		acc = {
			min = vector.new (0, -9.81, 0),
			max = vector.new (0, -9.81, 0),
		},
		attached = self.object,
	}
	core.add_particlespawner (particlespawner)
end

function villager:on_grown ()
	if self._sleeping_pose then
		self.collisionbox = {
			-0.25, 0, -0.25, 0.25, 0.3, 0.25,
		}
		self.object:set_properties ({
			collisionbox = self.collisionbox,
		})
		self:set_animation ("sleep")
	end
end

function villager:mob_sound (soundname, is_opinion, fixed_pitch)
	if soundname ~= "random" or not self._sleeping_pose then
		mob_class.mob_sound (self, soundname, is_opinion, fixed_pitch)
	end
end

function villager:begin_sleep ()
	self._sleeping_pose = true
	self._last_slept_gmt = core.get_gametime ()
	self.collisionbox = {
		-0.25, 0, -0.25, 0.25, 0.3, 0.25,
	}
	self.object:set_properties ({
		collisionbox = self.collisionbox,
	})
	self:cancel_navigation ()
	self:halt_in_tracks (true, true)
	self:set_animation ("sleep")
end

function villager:wake_up ()
	self._sleeping_pose = false
	self.collisionbox
		= table.copy (self.initial_properties.collisionbox)
	if self.child then
		for i, value in pairs (self.collisionbox) do
			self.collisionbox[i] = value * 0.5
		end
	end
	self.object:set_properties ({
		collisionbox = self.collisionbox,
	})
	if self:navigation_finished () then
		self:set_animation ("stand")
	else
		self:set_animation ("walk")
	end
	self._last_awoken_gmt = core.get_gametime ()
end

------------------------------------------------------------------------
-- Villager trading.
------------------------------------------------------------------------

local DEFAULT_PRICE_MULTIPLIER = 0.05

local function E (f, t)
	return { "mcl_core:emerald", f or 1, t or f or 1 }
end

local villager_trades = {
	farmer = {
		{
			{ { "mcl_farming:wheat_item", 20, 20, }, E(), 16, 2 },
			{ { "mcl_farming:potato_item", 26, 26, }, E(), 16, 2 },
			{ { "mcl_farming:carrot_item", 22, 22, }, E(), 16, 2 },
			{ { "mcl_farming:beetroot_item", 15, 15 }, E(), 16, 2 },
			{ E(), { "mcl_farming:bread", 6, 6 }, 16, 1 },
		},

		{
			{ { "mcl_farming:pumpkin", 6, 6 }, E(), 12, 10 },
			{ E(), { "mcl_farming:pumpkin_pie", 4, 4 }, 12, 5 },
			{ E(), { "mcl_core:apple", 4, 4 }, 16, 5 },
		},

		{
			{ { "mcl_farming:melon", 4, 4 }, E(), 12, 20 },
			{ E(3), {"mcl_farming:cookie", 18, 18 }, 12, 10},
		},

		{
			{ E(), { "mcl_cake:cake", 1, 1 }, 12, 15 },
			{ E(), { "mcl_sus_stew:stew", 1, 1 }, 12, 15 },
		},

		{
			{ E(3), { "mcl_farming:carrot_item_gold", 3, 3 }, 12, 30 },
			{ E(4), { "mcl_potions:speckled_melon", 3, 3 }, 12, 30 },
		},
	},
	fisherman = {
		{
			{ { "mcl_mobitems:string", 20, 20 }, E(), 16, 2 },
			{ { "mcl_core:coal_lump", 10, 10 }, E(), 16, 2 },
			{ { "mcl_core:emerald", 1, 1, "mcl_fishing:fish_raw", 6, 6 }, { "mcl_fishing:fish_cooked", 6, 6 }, 16, 1 },
			{ E(3), { "mcl_buckets:bucket_cod", 1, 1 }, 16, 1 },
		},

		{
			{ { "mcl_fishing:fish_raw", 15, 15 }, E(), 16, 10 },
			{ { "mcl_core:emerald", 1, 1, "mcl_fishing:salmon_raw", 6, 6 }, { "mcl_fishing:salmon_cooked", 6, 6 }, 16, 5 },
			{ E(2), {"mcl_campfires:campfire_lit", 1, 1 }, 12, 5 },
		},

		{
			{ { "mcl_fishing:salmon_raw", 13, 13 }, E(), 16, 20 },
			{ E(8,22), { "mcl_fishing:fishing_rod_enchanted", 1, 1 }, 3, 10, 0.2, },
		},

		{
			{ { "mcl_fishing:clownfish_raw", 6, 6 }, E(), 12, 30 },
		},

		{
			{ { "mcl_fishing:pufferfish_raw", 4, 4 }, E(), 12, 30 },

			--Boat cherry?
			{ { "mcl_boats:boat", 1, 1 }, E(), 12, 30 },
			{ { "mcl_boats:boat_acacia", 1, 1 }, E(), 12, 30 },
			{ { "mcl_boats:boat_spruce", 1, 1 }, E(), 12, 30 },
			{ { "mcl_boats:boat_dark_oak", 1, 1 }, E(), 12, 30 },
			{ { "mcl_boats:boat_birch", 1, 1 }, E(), 12, 30 },
		},
	},
	fletcher = {
		{
			{ { "mcl_core:stick", 32, 32 }, E(), 16, 2 },
			{ E(), { "mcl_bows:arrow", 16, 16 }, 12, 1 },
			{ { "mcl_core:emerald", 1, 1, "mcl_core:gravel", 10, 10 }, { "mcl_core:flint", 10, 10 }, 12, 1 },
		},

		{
			{ { "mcl_core:flint", 26, 26 }, E(), 12, 10 },
			{ E(2), { "mcl_bows:bow", 1, 1 }, 12, 5 },
		},

		{
			{ { "mcl_mobitems:string", 14, 14 }, E(), 16, 20 },
			{ E(3), { "mcl_bows:crossbow", 1, 1 }, 12, 10 },
		},

		{
			{ { "mcl_mobitems:feather", 24, 24 }, E(), 16, 30 },
			{ E(7, 21) , { "mcl_bows:bow_enchanted", 1, 1 }, 3, 15 },
		},

		{
			--FIXME: supposed to be tripwire hook{ { "tripwirehook", 8, 8 }, E(), 12, 30 },
			{ E(8, 22) , { "mcl_bows:crossbow_enchanted", 1, 1 }, 3, 15 },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:healing_arrow", 5, 5 }, 12, 30 },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:harming_arrow", 5, 5 }, 12, 30 },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:night_vision_arrow", 5, 5 }, 12, 30 },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:swiftness_arrow", 5, 5 }, 12, 30 },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:slowness_arrow", 5, 5 }, 12, 30 },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:leaping_arrow", 5, 5 }, 12, 30 },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:poison_arrow", 5, 5 }, 12, 30 },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:regeneration_arrow", 5, 5 }, 12, 30 },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:strength_arrow", 5, 5 }, 12, 30 },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:weakness_arrow", 5, 5 }, 12, 30 },
			--FIXME: { { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:slow_falling_arrow", 5, 5 }, 12, 30 },
			--FIXME: { { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:turtle_master_arrow", 5, 5 }, 12, 30 },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:invisibility_arrow", 5, 5 }, 12, 30 },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:water_breathing_arrow", 5, 5 }, 12, 30 },
			{ { "mcl_core:emerald", 2, 2, "mcl_bows:arrow", 5, 5 }, { "mcl_potions:fire_resistance_arrow", 5, 5 }, 12, 30 },
		},
	},
	shepherd = {
		{
			{ { "mcl_wool:white", 18, 18 }, E(), 16, 2 },
			{ { "mcl_wool:brown", 18, 18 }, E(), 16, 2 },
			{ { "mcl_wool:black", 18, 18 }, E(), 16, 2 },
			{ { "mcl_wool:grey", 18, 18 }, E(), 16, 2 },
			{ E(2), { "mcl_tools:shears", 1, 1 }, 12, 1 },
		},

		{
			{ { "mcl_dyes:black", 12, 12 }, E(), 16, 10 },
			{ { "mcl_dyes:dark_grey", 12, 12 }, E(), 16, 10 },
			{ { "mcl_dyes:green", 12, 12 }, E(), 16, 10 },
			{ { "mcl_dyes:lightblue", 12, 12 }, E(), 16, 10 },
			{ { "mcl_dyes:white", 12, 12 }, E(), 16, 10 },

			{ E(), { "mcl_wool:white", 1, 1 }, 16, 5 },
			{ E(), { "mcl_wool:grey", 1, 1 }, 16, 5 },
			{ E(), { "mcl_wool:silver", 1, 1 }, 16, 5 },
			{ E(), { "mcl_wool:black", 1, 1 }, 16, 5 },
			{ E(), { "mcl_wool:yellow", 1, 1 }, 16, 5 },
			{ E(), { "mcl_wool:orange", 1, 1 }, 16, 5 },
			{ E(), { "mcl_wool:red", 1, 1 }, 16, 5 },
			{ E(), { "mcl_wool:magenta", 1, 1 }, 16, 5 },
			{ E(), { "mcl_wool:purple", 1, 1 }, 16, 5 },
			{ E(), { "mcl_wool:blue", 1, 1 }, 16, 5 },
			{ E(), { "mcl_wool:cyan", 1, 1 }, 16, 5 },
			{ E(), { "mcl_wool:lime", 1, 1 }, 16, 5 },
			{ E(), { "mcl_wool:green", 1, 1 }, 16, 5 },
			{ E(), { "mcl_wool:pink", 1, 1 }, 16, 5 },
			{ E(), { "mcl_wool:light_blue", 1, 1 }, 16, 5 },
			{ E(), { "mcl_wool:brown", 1, 1 }, 16, 5 },

			{ E(), { "mcl_wool:white_carpet", 4, 4 }, 16, 5 },
			{ E(), { "mcl_wool:grey_carpet", 4, 4 }, 16, 5 },
			{ E(), { "mcl_wool:silver_carpet", 4, 4 }, 16, 5 },
			{ E(), { "mcl_wool:black_carpet", 4, 4 }, 16, 5 },
			{ E(), { "mcl_wool:yellow_carpet", 4, 4 }, 16, 5 },
			{ E(), { "mcl_wool:orange_carpet", 4, 4 }, 16, 5 },
			{ E(), { "mcl_wool:red_carpet", 4, 4 }, 16, 5 },
			{ E(), { "mcl_wool:magenta_carpet", 4, 4 }, 16, 5 },
			{ E(), { "mcl_wool:purple_carpet", 4, 4 }, 16, 5 },
			{ E(), { "mcl_wool:blue_carpet", 4, 4 }, 16, 5 },
			{ E(), { "mcl_wool:cyan_carpet", 4, 4 }, 16, 5 },
			{ E(), { "mcl_wool:lime_carpet", 4, 4 }, 16, 5 },
			{ E(), { "mcl_wool:green_carpet", 4, 4 }, 16, 5 },
			{ E(), { "mcl_wool:pink_carpet", 4, 4 }, 16, 5 },
			{ E(), { "mcl_wool:light_blue_carpet", 4, 4 }, 16, 5 },
			{ E(), { "mcl_wool:brown_carpet", 4, 4 }, 16, 5 },
		},

		{
			{ { "mcl_dyes:red", 12, 12 }, E(), 16, 20 },
			{ { "mcl_dyes:grey", 12, 12 }, E(), 16, 20 },
			{ { "mcl_dyes:pink", 12, 12 }, E(), 16, 20 },
			{ { "mcl_dyes:yellow", 12, 12 }, E(), 16, 20 },
			{ { "mcl_dyes:orange", 12, 12 }, E(), 16, 20 },

			{ E(3), { "mcl_beds:bed_red_bottom", 1, 1 }, 12, 10 },
			{ E(3), { "mcl_beds:bed_blue_bottom", 1, 1 }, 12, 10 },
			{ E(3), { "mcl_beds:bed_cyan_bottom", 1, 1 }, 12, 10 },
			{ E(3), { "mcl_beds:bed_grey_bottom", 1, 1 }, 12, 10 },
			{ E(3), { "mcl_beds:bed_silver_bottom", 1, 1 }, 12, 10 },
			{ E(3), { "mcl_beds:bed_black_bottom", 1, 1 }, 12, 10 },
			{ E(3), { "mcl_beds:bed_yellow_bottom", 1, 1 }, 12, 10 },
			{ E(3), { "mcl_beds:bed_green_bottom", 1, 1 }, 12, 10 },
			{ E(3), { "mcl_beds:bed_magenta_bottom", 1, 1 }, 12, 10 },
			{ E(3), { "mcl_beds:bed_orange_bottom", 1, 1 }, 12, 10 },
			{ E(3), { "mcl_beds:bed_purple_bottom", 1, 1 }, 12, 10 },
			{ E(3), { "mcl_beds:bed_brown_bottom", 1, 1 }, 12, 10 },
			{ E(3), { "mcl_beds:bed_pink_bottom", 1, 1 }, 12, 10 },
			{ E(3), { "mcl_beds:bed_lime_bottom", 1, 1 }, 12, 10 },
			{ E(3), { "mcl_beds:bed_light_blue_bottom", 1, 1 }, 12, 10 },
			{ E(3), { "mcl_beds:bed_white_bottom", 1, 1 }, 12, 10 },
		},

		{
			{ { "mcl_dyes:dark_green", 12, 12 }, E(), 16, 30 },
			{ { "mcl_dyes:brown", 12, 12 }, E(), 16, 30 },
			{ { "mcl_dyes:blue", 12, 12 }, E(), 16, 30 },
			{ { "mcl_dyes:violet", 12, 12 }, E(), 16, 30 },
			{ { "mcl_dyes:cyan", 12, 12 }, E(), 16, 30 },
			{ { "mcl_dyes:magenta", 12, 12 }, E(), 16, 30 },

			{ E(3), { "mcl_banners:banner_item_white", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_grey", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_silver", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_black", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_red", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_yellow", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_green", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_cyan", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_blue", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_magenta", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_orange", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_purple", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_brown", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_pink", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_lime", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_light_blue", 1, 1 }, 12, 15 },
		},

		{
			{ E(2), { "mcl_paintings:painting", 3, 3 }, 12, 30 },
		},
	},
	librarian = {
		{
			{ { "mcl_core:paper", 24, 24 }, E(), 16, 2 },
			{ { "mcl_core:emerald", 5, 64, "mcl_books:book", 1, 1 }, { "mcl_enchanting:book_enchanted", 1 ,1 }, 12, 1 },
			{ E(9), { "mcl_books:bookshelf", 1 ,1 }, 12, 1 },
		},

		{
			{ { "mcl_books:book", 4, 4 }, E(), 12, 10 },
			{ { "mcl_core:emerald", 5, 64, "mcl_books:book", 1, 1 }, { "mcl_enchanting:book_enchanted", 1 ,1 }, 12, 5 },
			{ E(), { "mcl_lanterns:lantern_floor", 1, 1 }, 12, 5 },
		},

		{
			{ { "mcl_mobitems:ink_sac", 5, 5 }, E(), 12, 20 },
			{ { "mcl_core:emerald", 5, 64, "mcl_books:book", 1, 1 }, { "mcl_enchanting:book_enchanted", 1 ,1 }, 12, 10},
			{ E(), { "mcl_core:glass", 4, 4 }, 12, 10 },
		},

		{
			{ { "mcl_books:writable_book", 1, 1 }, E(), 12, 30 },
			{ E(5), { "mcl_clock:clock", 1, 1 }, 12, 15 },
			{ E(4), { "mcl_compass:compass", 1 ,1 }, 12, 15 },
		},

		{
			{ { "mcl_core:emerald", 5, 45, "mcl_books:book", 1, 1 }, { "mcl_enchanting:book_enchanted", 1 ,1 }, 12, 30 },
			{ E(20), { "mcl_mobs:nametag", 1, 1 }, 12, 30 },
		}
	},
	cartographer = {
		{
			{ { "mcl_core:paper", 24, 24 }, E(), 16, 2 },
			{ E(7), { "mcl_maps:empty_map", 1, 1 }, 12, 1 },
		},

		{
			{ { "mcl_panes:pane_natural_flat", 11, 11 }, E(), 16, 10 },
			--{ { "mcl_core:emerald", 13, 13, "mcl_compass:compass", 1, 1 }, { "FIXME:ocean explorer map" 1, 1 }, 12, 5 },
		},

		{
			{ { "mcl_compass:compass", 1, 1 }, E(), 12, 20 },
			--{ { "mcl_core:emerald", 14, 14, "mcl_compass:compass", 1, 1 }, { "FIXME:woodland explorer map" 1, 1 }, 12, 10 },
		},

		{
			{ E(7), { "mcl_itemframes:frame", 1, 1 }, 12, 15 },

			{ E(3), { "mcl_banners:banner_item_white", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_grey", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_silver", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_black", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_red", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_yellow", 1, 1 }, 12, 15},
			{ E(3), { "mcl_banners:banner_item_green", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_cyan", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_blue", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_magenta", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_orange", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_purple", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_brown", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_pink", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_lime", 1, 1 }, 12, 15 },
			{ E(3), { "mcl_banners:banner_item_light_blue", 1, 1 }, 12, 15 },
		},

		{
			{ E(8), { "mcl_banners:pattern_globe", 1, 1 }, 12, 30 },
		},
	},
	armorer = {
		{
			{ { "mcl_core:coal_lump", 15, 15 }, E(), 16, 2 },
			{ E(5), { "mcl_armor:helmet_iron", 1, 1 }, 12, 1, 0.2 },
			{ E(9), { "mcl_armor:chestplate_iron", 1, 1 }, 12, 1, 0.2,  },
			{ E(7), { "mcl_armor:leggings_iron", 1, 1 }, 12, 1, 0.2, },
			{ E(4), { "mcl_armor:boots_iron", 1, 1 }, 12, 1, 0.2, },
		},

		{
			{ { "mcl_core:iron_ingot", 4, 4 }, E(), 12, 10 },
			{ { "mcl_core:emerald", 36, 36 }, { "mcl_bells:bell", 1, 1 }, 12, 5, 0.2, },
			{ E(3), { "mcl_armor:leggings_chain", 1, 1 }, 12, 5, 0.2, },
			{ E(), { "mcl_armor:boots_chain", 1, 1 }, 12, 5, 0.2, },
		},

		{
			{ { "mcl_buckets:bucket_lava", 1, 1 }, E(), 12, 20, },
			{ { "mcl_core:diamond", 1, 1 }, E(), 12, 20, },
			{ E(), { "mcl_armor:helmet_chain", 1, 1 }, 12, 10, 0.2, },
			{ E(4), { "mcl_armor:chestplate_chain", 1, 1 }, 12, 10, 0.2, },
			{ E(5), { "mcl_shields:shield", 1, 1 }, 12, 10, 0.2, },
		},

		{
			{ E(19, 33), { "mcl_armor:leggings_diamond_enchanted", 1, 1 } , 3, 15, 0.2, },
			{ E(13, 27), { "mcl_armor:boots_diamond_enchanted", 1, 1 }, 3, 15, 0.2, },
		},

		{
			{ E(13, 27), { "mcl_armor:helmet_diamond_enchanted", 1, 1 }, 3, 30, 0.2, },
			{ E(21, 35), { "mcl_armor:chestplate_diamond_enchanted", 1, 1 }, 3, 30, 0.2, },
		},
	},
	leatherworker = {
		{
			{ { "mcl_mobitems:leather", 6, 6 }, E(), 16, 2 },
			{ E(3), { "mcl_armor:leggings_leather", 1, 1 }, 12, 1 },
			{ E(7), { "mcl_armor:chestplate_leather", 1, 1 }, 12, 1 },
		},

		{
			{ { "mcl_core:flint", 26, 26 }, E(), 12, 10 },
			{ E(5), { "mcl_armor:helmet_leather", 1, 1 }, 12, 5 },
			{ E(4), { "mcl_armor:boots_leather", 1, 1 }, 12, 5 },
		},

		{
			{ { "mcl_mobitems:rabbit_hide", 9, 9 }, E(), 12, 20 },
			{ E(7), { "mcl_armor:chestplate_leather", 1, 1 }, 12, 1 },
		},

		{
			--{ { "FIXME: scute", 4, 4 }, E(), 12, 30 },
			{ { "mcl_core:emerald", 6, 6 }, { "mcl_mobitems:leather_horse_armor", 1, 1 }, 12, 15 },
		},

		{
			{ E(6), { "mcl_mobitems:saddle", 1, 1 }, 12, 30 },
			{ E(5), { "mcl_armor:helmet_leather", 1, 1 }, 12, 30 },
		},
	},
	butcher = {
		{
			{ { "mcl_mobitems:chicken", 14, 14 }, E(), 16, 2 },
			{ { "mcl_mobitems:porkchop", 7, 7 }, E(), 16, 2 },
			{ { "mcl_mobitems:rabbit", 4, 4 }, E(), 16, 2 },
			{ E(), { "mcl_mobitems:rabbit_stew", 1, 1 }, 12, 1 },
		},

		{
			{ { "mcl_core:coal_lump", 15, 15 }, E(), 16, 2 },
			{ E(), { "mcl_mobitems:cooked_porkchop", 5, 5 }, 16, 5 },
			{ E(), { "mcl_mobitems:cooked_chicken", 8, 8 }, 16, 5 },
		},

		{
			{ { "mcl_mobitems:mutton", 7, 7 }, E(), 16, 20 },
			{ { "mcl_mobitems:beef", 10, 10 }, E(), 16, 20 },
		},

		{
			{ { "mcl_ocean:dried_kelp_block", 10, 10 }, E(), 12, 30 },
		},

		{
			{ { "mcl_farming:sweet_berry", 10, 10 }, E(), 12, 30 },
		},
	},
	weaponsmith = {
		{
			{ { "mcl_core:coal_lump", 15, 15 }, E(), 16, 2 },
			{ E(3), { "mcl_tools:axe_iron", 1, 1 }, 12, 1, 0.2, },
			{ E(7, 21), { "mcl_tools:sword_iron_enchanted", 1, 1 }, 3, 1 },
		},

		{
			{ { "mcl_core:iron_ingot", 4, 4 }, E(), 12, 10 },
			{ E(36), { "mcl_bells:bell", 1, 1 }, 12, 5, 0.2 },
		},

		{
			{ { "mcl_core:flint", 24, 24 }, E(), 12, 20 },
		},

		{
			{ { "mcl_core:diamond", 1, 1 }, E(), 12, 30 },
			{ E(17, 31), { "mcl_tools:axe_diamond_enchanted", 1, 1 }, 3, 15, 0.2, },
		},

		{
			{ E(13, 27), { "mcl_tools:sword_diamond_enchanted", 1, 1 }, 3, 30, 0.2, },
		},
	},
	toolsmith = {
		{
			{ { "mcl_core:coal_lump", 15, 15 }, E(), 16, 2 },
			{ E(), { "mcl_tools:axe_stone", 1, 1 }, 12, 1, 0.2, },
			{ E(), { "mcl_tools:shovel_stone", 1, 1 }, 12, 1, 0.2, },
			{ E(), { "mcl_tools:pick_stone", 1, 1 }, 12, 1, 0.2, },
			{ E(), { "mcl_farming:hoe_stone", 1, 1 }, 12, 1, 0.2, },
		},

		{
			{ { "mcl_core:iron_ingot", 4, 4 }, E(), 12, 10 },
			{ E(36), { "mcl_bells:bell", 1, 1 }, 12, 5, 0.2 },
		},

		{
			{ { "mcl_core:flint", 30, 30 }, E(), 12, 20 },
			{ E(6, 20), { "mcl_tools:axe_iron_enchanted", 1, 1 }, 3, 10, 0.2, },
			{ E(7, 21), { "mcl_tools:shovel_iron_enchanted", 1, 1 }, 3, 10, 0.2, },
			{ E(8, 22), { "mcl_tools:pick_iron_enchanted", 1, 1 }, 3, 10, 0.2, },
			{ E(4), { "mcl_farming:hoe_diamond", 1, 1 }, 3, 10, 0.2, },
		},

		{
			{ { "mcl_core:diamond", 1, 1 }, E(), 12, 30 },
			{ E(17, 31), { "mcl_tools:axe_diamond_enchanted", 1, 1 }, 3, 15, 0.2, },
			{ E(10, 24), { "mcl_tools:shovel_diamond_enchanted", 1, 1 }, 3, 15, 0.2, },
		},

		{
			{ E(18, 32), { "mcl_tools:pick_diamond_enchanted", 1, 1 }, 3, 30, 0.2, },
		},
	},
	cleric = {
		{
			{ { "mcl_mobitems:rotten_flesh", 32, 32 }, E(), 16, 12 },
			{ E(), { "mcl_redstone:redstone", 2, 2  }, 12, 1 },
		},

		{
			{ { "mcl_core:gold_ingot", 3, 3 }, E(), 12, 10 },
			{ E(), { "mcl_core:lapis", 1, 1 }, 12, 5 },
		},

		{
			{ { "mcl_mobitems:rabbit_foot", 2, 2 }, E(), 12, 20 },
			{ E(4), { "mcl_nether:glowstone", 1, 1 }, 12, 10 },
		},

		{
			--{ { "FIXME: scute", 4, 4 }, E(), 12, 30 },
			{ { "mcl_potions:glass_bottle", 9, 9 }, E(), 12, 30 },
			{ E(5), { "mcl_throwing:ender_pearl", 1, 1 }, 12, 15 },
		},

		{
			{ { "mcl_nether:nether_wart_item", 22, 22 }, E(), 12, 30 },
			{ E(3), { "mcl_experience:bottle", 1, 1 }, 12, 30 },
		},
	},
	mason = {
		{
			{ { "mcl_core:clay_lump", 10, 10 }, E(), 16, 2  },
			{ E(), { "mcl_core:brick", 10, 10 }, 16, 1 },
		},

		{
			{ { "mcl_core:stone", 20, 20 }, E(), 16, 10 },
			{ E(), { "mcl_core:stonebrickcarved", 4, 4 }, 16, 5 },
		},

		{
			{ { "mcl_core:granite", 16, 16 }, E(), 16, 20 },
			{ { "mcl_core:andesite", 16, 16 }, E(), 16, 20 },
			{ { "mcl_core:diorite", 16, 16 }, E(), 16, 20 },
			{ E(), { "mcl_core:andesite_smooth", 4, 4 }, 16, 10 },
			{ E(), { "mcl_core:granite_smooth", 4, 4 }, 16, 10 },
			{ E(), { "mcl_core:diorite_smooth", 4, 4 }, 16, 10 },
			{ E(), { "mcl_dripstone:dripstone_block", 4, 4 }, 16, 10 },
		},

		{
			{ { "mcl_nether:quartz", 12, 12 }, E(), 12, 30 },
			{ E(), { "mcl_colorblocks:hardened_clay_white", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:hardened_clay_grey", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:hardened_clay_silver", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:hardened_clay_black", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:hardened_clay_red", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:hardened_clay_yellow", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:hardened_clay_green", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:hardened_clay_cyan", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:hardened_clay_blue", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:hardened_clay_magenta", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:hardened_clay_orange", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:hardened_clay_brown", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:hardened_clay_pink", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:hardened_clay_light_blue", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:hardened_clay_lime", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:hardened_clay_purple", 1, 1 }, 12, 15 },

			{ E(), { "mcl_colorblocks:glazed_terracotta_white", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:glazed_terracotta_grey", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:glazed_terracotta_silver", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:glazed_terracotta_black", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:glazed_terracotta_red", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:glazed_terracotta_yellow", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:glazed_terracotta_green", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:glazed_terracotta_cyan", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:glazed_terracotta_blue", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:glazed_terracotta_magenta", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:glazed_terracotta_orange", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:glazed_terracotta_brown", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:glazed_terracotta_pink", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:glazed_terracotta_light_blue", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:glazed_terracotta_lime", 1, 1 }, 12, 15 },
			{ E(), { "mcl_colorblocks:glazed_terracotta_purple", 1, 1 }, 12, 15 },
		},

		{
			{ E(), { "mcl_nether:quartz_pillar", 1, 1 }, 12, 30 },
			{ E(), { "mcl_nether:quartz_block", 1, 1 }, 12, 30 },
		},
	},
}
mobs_mc.villager_trades = villager_trades

-- Assign the default price multiplier of 0.05 to all trades where
-- such a multiplier is not already specified.
for _, trade_list in pairs (villager_trades) do
	for _, tier_list in pairs (trade_list) do
		for _, trade in pairs (tier_list) do
			if not trade[5] then
				trade[5] = DEFAULT_PRICE_MULTIPLIER
			end
		end
	end
end

local tier_thresholds = {
	0, 10, 70, 150, 250,
}
local tier_names = {
	S("Novice"),
	S("Apprentice"),
	S("Journeyman"),
	S("Expert"),
	S("Master"),
}
local MAX_TIER = #tier_thresholds

function villager:get_tier_name (tier)
	return tier_names[tier] or "Unknown"
end

function villager:show_trade_progress_bar ()
	return self._tier < MAX_TIER
end

function villager:tier_progress (name)
	local next_tier = self._tier + 1
	local threshold = tier_thresholds[next_tier] or 0
	local this_threshold = tier_thresholds[self._tier]
	return math.min (1.0, (self._xp - this_threshold)
			 / (threshold - this_threshold))
end

function villager:on_transaction (trade, player)
	self._xp = self._xp + trade.xp

	if tier_thresholds[self._tier + 1]
		and self._xp >= tier_thresholds[self._tier + 1] then
		self._levelup_in = 2.0
		mcl_experience.throw_xp (self.object:get_pos (), 5)
	end

	self:record_gossip (player:get_player_name (), "trading", 2)
end

function villager:reload_trades ()
	if not self._profession or self._profession == "nitwit" then
		self:update_trades ({})
		return
	end

	local trades = villager_trades[self._profession]
	assert (trades)
	local villager_trades = {}
	for tier, trade_list in ipairs (trades) do
		if tier > self._tier then
			break
		end

		for _, trade in ipairs (trade_list) do
			local trade_object
				= mobs_mc.trade_from_table (pr, trade, true)
			trade_object.tier = tier
			table.insert (villager_trades, trade_object)
		end
	end
	self:update_trades (villager_trades)
end

function villager:activate_trades ()
	local by_tier = villager_trades[self._profession]
	assert (by_tier)
	local trades = by_tier[self._tier]
	if trades then
		for _, trade in ipairs (trades) do
			local trade_object
				= mobs_mc.trade_from_table (pr, trade, true)
			trade_object.tier = self._tier
			table.insert (self._trades, trade_object)
		end
	end
	self:update_trades (self._trades)
end

function villager:apply_player_prices (player)
	local name = player:get_player_name ()
	local reputation = self._reputation[name] or 0
	local hero_of_the_village
		= mcl_potions.has_effect (player, "hero_of_village")

	for _, trade in pairs (self._trades) do
		local diff = math.floor (trade.price_multiplier * -reputation)
		trade.special_price_diff = diff
		if hero_of_the_village then
			local wanted1 = trade:get_wanted1 ()
			local discount = math.floor ((0.3 + 1/16) * wanted1:get_count ())
			diff = diff - math.max (discount, 1)
			trade.special_price_diff = diff
		end
	end
end

function villager:revert_special_prices ()
	for _, trade in pairs (self._trades) do
		trade.special_price_diff = 0
	end
end

function villager:show_trade_formspec (player, tradenum)
	if table.getn (self._trading_with) >= 1 then
		return false
	end
	self:apply_player_prices (player)
	return villager_base.show_trade_formspec (self, player, tradenum)
end

function villager:trading_stopped ()
	self:revert_special_prices ()
end

function villager:level_up ()
	self._tier = self._tier + 1
	assert (self._tier <= MAX_TIER)

	self:activate_trades ()
	mcl_potions.give_effect_by_level ("regeneration", self.object, 1, 10)
	self.base_texture[1] = self:get_overlaid_texture ()
	self:set_textures (self.base_texture)
end

function villager:check_restock (gmt, day)
	if (self._last_restock_day ~= -1
		and day > self._last_restock_day)
		or (gmt - self._last_restock_gmt >= 600
			and self._last_restock_gmt ~= -1) then
		self:next_working_day ()
	else
		if self._last_restock_gmt == -1 then
			self._last_restock_gmt = gmt
		end
		if self._restocks_remaining == 2
			or (self._restocks_remaining > 0
				and gmt - self._last_restock_gmt > 120) then
			self:restock_if_needed ()
		end
	end
end

function villager:needs_restock ()
	for _, trade in pairs (self._trades) do
		if trade.uses > 0 then
			return true
		end
	end
	return false
end

function villager:restock_if_needed ()
	if not self:needs_restock () then
		return
	end

	-- Update demand and unlock trades.
	for _, trade in pairs (self._trades) do
		trade:update_demand ()
		trade.uses = 0
	end
	self:update_trades (self._trades)
	self._last_restock_gmt = core.get_gametime ()
	self._last_restock_day = core.get_day_count ()
	self._restocks_remaining = self._restocks_remaining - 1
end

function villager:next_working_day ()
	-- Update demand and supply yesterday's deficits.
	for _, trade in pairs (self._trades) do
		for i = 1, self._restocks_remaining do
			trade:update_demand ()
			trade.uses = 0
		end
	end
	self:update_trades (self._trades)
	self._restocks_remaining = 2
	self._last_restock_day = core.get_day_count ()
	self._last_restock_gmt = core.get_gametime ()
end

function villager:check_head_swivel (self_pos, dtime, clear)
	if self.object.set_bone_override and self._head_nod_timeout then
		self.object:set_bone_override ("Head_Control", nil)
		self._old_head_swivel_vector = nil
	else
		mob_class.check_head_swivel (self, self_pos, dtime, clear)
	end
end

function villager:do_custom (dtime)
	if self._head_nod_timeout then
		local t = self._head_nod_timeout - dtime
		if t <= 0 then
			t = nil
		end
		self._head_nod_timeout = t
	end
end

function villager:set_animation (anim, custom_frame)
	if self._head_nod_timeout then
		anim = "nitwit"
	end
	mob_class.set_animation (self, anim, custom_frame)
end

function villager:on_rightclick (clicker)
	if self.child or not self._profession
		or self._profession == "nitwit" then
		if not self._sleeping_pose then
			self._current_animation = nil
			if self.object.set_bone_override then
				self.object:set_bone_override ("Head_Control", nil)
			end
			self:set_animation ("nitwit")
			self._head_nod_timeout = 1.0
		end

		core.sound_play ("mobs_mc_villager_deny", {
			to_player = clicker:get_player_name (),
			object = self.object,
		}, true)
	else
		if #self._trades == 0 then
			self:reload_trades ()
		end
		self:show_trade_formspec (clicker, 0)
	end
end

------------------------------------------------------------------------
-- Villager mechanics.
------------------------------------------------------------------------

local function villager_log (str)
	if villager_verbose then
		core.chat_send_all (str)
	end
end

local desert_p, jungle_p, savannah_p, snowy_p, taiga_p, swamp_p

core.register_on_mods_loaded (function ()
	desert_p = mcl_biome_dispatch.make_biome_test ({
		"#is_badlands",
		"Desert",
	})
	jungle_p = mcl_biome_dispatch.make_biome_test ({
		"#is_jungle",
	})
	snowy_p = mcl_biome_dispatch.make_biome_test ({
		"DeepFrozenOcean",
		"FrozenOcean",
		"FrozenPeaks",
		"FrozenRiver",
		"Grove",
		"IceSpikes",
		"JaggedPeaks",
		"SnowyBeach",
		"SnowyPlains",
		"SnowySlopes",
		"SnowyTaiga",
	})
	savannah_p = mcl_biome_dispatch.make_biome_test ({
		"#is_savannah",
	})
	taiga_p = mcl_biome_dispatch.make_biome_test ({
		"OldGrowthPineTaiga",
		"OldGrowthSpruceTaiga",
		"Taiga",
		"WindsweptForest",
		"WindsweptGravellyHills",
		"WindsweptHills",
	})
	swamp_p = mcl_biome_dispatch.make_biome_test ({
		"Swamp",
		"MangroveSwamp",
	})
end)

local function villager_type_from_biome (name)
	if not name then
		return "plains"
	end

	if desert_p (name) then
		return "desert"
	elseif jungle_p (name) then
		return "jungle"
	elseif savannah_p (name) then
		return "savanna"
	elseif snowy_p (name) then
		return "snowy"
	elseif taiga_p (name) then
		return "taiga"
	elseif swamp_p (name) then
		return "swamp"
	else
		return "plains"
	end
end

function villager:on_spawn ()
	if not rawget (self, "_villager_type") then
		-- Villagers converted from Zombie Villagers or
		-- otherwise spawned with a profession shouldn't
		-- exhibit a 1/100 probability of generating as
		-- nitwits.
		if pr:next (1, 100) == 1 then
			self:set_profession ("nitwit")
		end

		local self_pos = self.object:get_pos ()
		local biomename = mcl_biome_dispatch.get_biome_name (self_pos)
		local villager_type = villager_type_from_biome (biomename)
		self._villager_type = villager_type
		self.base_texture[1] = self:get_overlaid_texture ()
		self:set_textures (self.base_texture)
	end

	-- As usual the MC Wiki is incorrect in stating that naturally
	-- spawned zombie villagers retain their professions after
	-- curing if they cannot locate a job block.  Testing in MC
	-- 1.20.6 reveals that their professions are reset
	-- immediately.

	if self._profession and self._profession ~= "nitwit"
		and self._xp == 0 then
		self:update_trades ({})
		self:reset_profession ()
	end
end

function villager:set_profession (name)
	local profession = professions_by_name[name]

	if self._profession ~= name then
		self.description = profession.description
		self._profession = name
		self.base_texture[1] = self:get_overlaid_texture ()
		self:set_textures (self.base_texture)
		self:reload_trades ()
	end
end

function villager:reset_profession (name)
	self._profession = nil
	self._description = villager.description
	self.base_texture[1] = self:get_overlaid_texture ()
	self:set_textures (self.base_texture)
	self:set_wielditem (ItemStack ())
end

function villager:mob_activate (staticdata, dtime)
	if not villager_base.mob_activate (self, staticdata, dtime) then
		return false
	end
	-- This villager type was only possible for a short period
	-- during development.
	if self._villager_type == "default" then
		self._villager_type = "plains"
	end
	if self._profession then
		local profession = professions_by_name[self._profession]
		self.description = profession.description
	end
	return true
end

function villager:receive_damage (mcl_reason, damage)
	if mob_class.receive_damage (self, mcl_reason, damage) then
		self._panic_time = 2.0

		-- Murders are reported in `on_die'.
		if mcl_reason.source and self.health > 0 then
			self._panic_source = mcl_reason.source

			if mcl_reason.source:is_player () then
				local name = mcl_reason.source:get_player_name ()
				self:record_gossip (name, "minor_negative", 25)
				self:angry_villager_effect ()
			end
		end
		return true
	end
	return false
end

function villager:report_murder (name)
	local self_pos = self.object:get_pos ()
	local villagers = self:run_sensor (self_pos, "nearby_villagers")
	for _, villager in pairs (villagers) do
		local entity = villager:get_luaentity ()
		if entity then
			entity:record_gossip (name, "major_negative", 25)
		end
	end
end

local function relinquish_provisional_poi (pos)
	local poi = mcl_villages.get_poi (pos)
	if poi then
		mcl_villages.remove_poi (poi.id)
	end
end

function villager:relinquish_pois ()
	self:validate_job_sites ()
	self:relinquish_job_site ()
	self:relinquish_bell ()
	self:relinquish_home ()

	if self._provisional_job_site then
		relinquish_provisional_poi (self._provisional_job_site)
		self._provisional_job_site = nil
	end
end

local zombie_types = {
	"mobs_mc:husk",
	"mobs_mc:baby_husk",
	"mobs_mc:zombie",
	"mobs_mc:baby_zombie",
	"mobs_mc:villager_zombie",
	"mobs_mc:drowned",
	"mobs_mc:baby_drowned",
}

function villager:export_villager_data ()
	return {
		xp = self._xp,
		tier = self._tier,
		profession = self._profession,
		villager_type = self._villager_type,
		gossips = self._gossips,
		reputation = self._reputation,
		trades = self._trades,
	}
end

function villager:on_die (_, mcl_reason)
	self:relinquish_pois ()
	if mcl_reason.source and mcl_reason.source:is_player () then
		local name = mcl_reason.source:get_player_name ()
		self:record_gossip (name, "major_negative", 25)
		self:report_murder (name)
	elseif mcl_vars.difficulty >= 2
		and mcl_reason.mob_name
		and table.indexof (zombie_types, mcl_reason.mob_name) ~= -1
		and (mcl_vars.difficulty > 2 or pr:next (1, 2) == 1) then
		self:replace_with ("mobs_mc:villager_zombie", false, {
			_previous_incarnation = self:export_villager_data (),
		})
	end
end

function villager:_on_lightning_strike ()
	if mcl_vars.difficulty > 0 then
		if self:replace_with ("mobs_mc:witch", false) then
			self:relinquish_pois ()
		end
	end
end

function villager:conceive_child (mate_entity, bed)
	local random = pr:next (1, 2147483647) * r
	local villager_type
	if random < 0.5 then
		local self_pos = self.object:get_pos ()
		local biomename = mcl_biome_dispatch.get_biome_name (self_pos)
		villager_type = villager_type_from_biome (biomename)
	elseif random < 0.75 then
		villager_type = self._villager_type
	else
		villager_type = mate_entity._villager_type
	end

	local staticdata = core.serialize ({
		child = true,
		_villager_type = villager_type,
	})
	local self_pos = self.object:get_pos ()
	local villager = core.add_entity (self_pos, "mobs_mc:villager", staticdata)
	if villager then
		local entity = villager:get_luaentity ()
		entity:claim_home (bed)
		return true
	end
	return false
end

------------------------------------------------------------------------
-- Villager gossip.
------------------------------------------------------------------------

-- https://minecraft.wiki/w/Villager#Gossiping
local gossip_types = {
	major_negative = {
		rep_multiplier = -5,
		max_value = 100,
		daily_decay = 10,
		transfer_decay = 10,
	},
	minor_negative = {
		rep_multiplier = -1,
		max_value = 100,
		daily_decay = 20,
		transfer_decay = 20,
	},
	minor_positive = {
		rep_multiplier = 1,
		max_value = 25,
		daily_decay = 1,
		transfer_decay = 5,
	},
	major_positive = {
		rep_multiplier = 1,
		max_value = 20,
		daily_decay = 0,
		transfer_decay = 20,
	},
	trading = {
		rep_multiplier = 1,
		max_value = 20,
		daily_decay = 2,
		transfer_decay = 20,
	},
}

function villager:evaluate_player_reputation (playername)
	local reputation = 0
	for gossiptype, gossip in pairs (self._gossips[playername]) do
		local info = gossip_types[gossiptype]
		assert (info)
		reputation = reputation + gossip * info.rep_multiplier
	end

	self._reputation[playername] = reputation
end

function villager:record_gossip (playername, gossiptype, n)
	if not self._gossips[playername] then
		self._gossips[playername] = {}
	end
	local info = gossip_types[gossiptype]
	local value = self._gossips[playername][gossiptype] or 0
	value = math.min (math.max (0, value + n), info.max_value)
	self._gossips[playername][gossiptype] = value
	self:evaluate_player_reputation (playername)
end

function villager:decay_gossips_1 ()
	for player, gossips in pairs (self._gossips) do
		for gossiptype, value in pairs (gossips) do
			local info = gossip_types[gossiptype]
			local newvalue = value - info.daily_decay
			gossips[gossiptype]
				= newvalue > 1 and newvalue or nil
		end

		self:evaluate_player_reputation (player)
	end
end

function villager:decay_gossips ()
	-- One would expect these memories to fade whenever a villager
	-- climbs into bed, but it is not so in Minecraft.
	local t = self._last_gossip_decay_gmt
	local gmt = core.get_gametime ()
	if t == 0 then
		self._last_gossip_decay_gmt = gmt
	elseif gmt - t >= 1200 then
		self:decay_gossips_1 ()
		self._last_gossip_decay_gmt = gmt
	end
end

function villager:copy_gossips (interlocutor)
	for player, gossips in pairs (interlocutor._gossips) do
		local self_gossip = self._gossips[player] or {}
		for gossiptype, value in pairs (gossips) do
			local info = gossip_types[gossiptype]
			local new = math.max (value - info.transfer_decay, 0)
			local self_value = self_gossip[gossiptype] or 0
			self_gossip[gossiptype]
				= math.min (math.max (new, self_value), info.max_value)
		end
		self._gossips[player] = self_gossip
		self:evaluate_player_reputation (player)
	end
end

function villager:gossip_with (self_pos, interlocutor)
	villager_log (table.concat {
		self._profession or "unemployed",
		" gossips with ",
		interlocutor._profession or "unemployed",
	})

	local old = table.copy (self._reputation)

	local gmt = core.get_gametime ()
	if (gmt - interlocutor._last_gossip_gmt) >= 60 then
		interlocutor._last_gossip_gmt = gmt
		interlocutor:copy_gossips (self)
	end

	self:maybe_summon_golem (self_pos, 5)

	local debugstring = {}
	for player, rep in pairs (old) do
		if self._reputation[player] ~= rep then
			local str = string.format ("  %s: %d => %d", player, rep, self._reputation[player])
			table.insert (debugstring, str)
		end
	end
	villager_log (table.concat (debugstring, "\n"))
end

------------------------------------------------------------------------
-- Villager inventories.
------------------------------------------------------------------------

local villager_wanted_items = {
	"mcl_farming:bread",
	"mcl_farming:potato_item",
	"mcl_farming:carrot_item",
	"mcl_farming:beetroot_item",
}

function villager:should_pick_up (stack)
	local item_name = stack:get_name ()

	if table.indexof (villager_wanted_items, item_name) ~= -1 then
		return self:has_inventory_space (stack)
	elseif self._profession then
		local profession
			= professions_by_name[self._profession]
		assert (profession)
		return table.indexof (profession.extra_pick_up, item_name) ~= -1
			and self:has_inventory_space (stack)
	end
	return false
end

local function check_item_timeout (self, itementity)
	return itementity._dropped_by_villager ~= self.object
		or not itementity._dropped_by_villager_gmt
		or (itementity._dropped_by_villager_gmt
			> core.get_gametime () - 2)
end

function villager:default_pickup (object, stack, _, _)
	local entity = object:get_luaentity ()
	if not check_item_timeout (self, entity) then
		return
	end
	if self:should_pick_up (stack) then
		local remainder = self:add_to_inventory (stack)
		villager_log (table.concat {
			self._profession or "unemployed",
			" received ",
			stack:to_string (),
		})
		if remainder:is_empty () then
			object:remove ()
		else
			local entity = object:get_luaentity ()
			entity.itemstring = remainder:to_string ()
		end

		return true
	end
	return false
end

------------------------------------------------------------------------
-- Villager AI.
------------------------------------------------------------------------

local bed_search_cache
	= mcl_util.make_node_search_cache ("limit_size", {"group:bed_bottom",})
local poi_search_cache
	= mcl_util.make_node_search_cache ("limit_size", jobsite_groups)
local bell_search_cache
	= mcl_util.make_node_search_cache ("limit_size", {"group:bell",})

function mobs_mc.notify_bed_placed (pos)
	bed_search_cache:notify_placed (pos)
end

function mobs_mc.notify_bed_deleted (pos)
	bed_search_cache:notify_deleted (pos)
end

local function manhattan3d (self, v1, v2)
	local v = self:gwp_align_start_pos (v1)
	local d = math.abs (v.x - v2.x)
		+ math.abs (v.y - v2.y)
		+ math.abs (v.z - v2.z)
	return d
end

local hash_pos = core.hash_node_position

local function find_nearest_village_section (section, min_heat)
	-- "Mob AI uses these definitions in various cases. For
	-- example, when a villager is not in a village and needs to
	-- return to one, it sets out in the direction of increasing
	-- proximity.  When an iron golem patrols the village, it
	-- frequently looks for a village subchunk within a 5×5×5 cube
	-- of itself to walk to."
	--
	-- Ref: https://minecraft.wiki/w/Village_mechanics
	local v = vector.zero ()
	local closest, heat
	for x = -2, 2 do
		for y = -2, 2 do
			for z = -2, 2 do
				v.x = section.x + x
				v.y = section.y + y
				v.z = section.z + z
				local candidate = mcl_villages.get_poi_heat_of_section (v)
				if candidate >= min_heat and (not closest or candidate >= heat) then
					heat = candidate
					closest = vector.copy (v)
				end
			end
		end
	end
	return closest, heat
end

local function check_bell_occupancy (bell)
	local meta = core.get_meta (bell)
	return meta:get_int ("mcl_villages:bell_users") <= 32
end

function villager:post_relinquish_job_site ()
	-- Reset profession if this villager has not
	-- yet traded.
	if self._xp == 0 then
		self:stop_trading ()
		self:update_trades ({})
		self:reset_profession ()
	end
end

function villager:relinquish_job_site (reason)
	if self._job_site then
		local profession = professions_by_name[self._profession]
		assert (profession)
		local poi = mcl_villages.get_poi (self._job_site)
		if poi and poi.data == profession.poi then
			mcl_villages.remove_poi (poi.id)
		end
		self._job_site = nil
		self:report_lost_poi ("job_site", reason)
		self:post_relinquish_job_site ()
	end
end

local BED_POI = "mcl_villages:bed"

function villager:relinquish_home (reason)
	if self._home then
		local poi = mcl_villages.get_poi (self._home)
		if poi and poi.data == BED_POI then
			mcl_villages.remove_poi (poi.id)
		end
		self._home = nil
		self:report_lost_poi ("home", reason)
	end
end

local BELL_POI = "mcl_villages:bell"

-- N.B.: the bell's user count is liable to disagree with the number
-- of users in existence in the vanishingly improbable scenario that a
-- bell POI is invalidated and replaced by a new bell, and the said
-- bell is re-acquired before its disappearance is registered by all
-- of its users.
function villager:relinquish_bell (reason)
	local pos = self._bell

	if not pos then
		return
	end

	local poi = mcl_villages.get_poi (pos)
	if poi and poi.data == BELL_POI then
		local meta = core.get_meta (pos)
		local remaining_users
			= math.max (meta:get_int ("mcl_villages:bell_users") - 1, 0)
		meta:set_int ("mcl_villages:bell_users", remaining_users)

		if remaining_users <= 0 then
			mcl_villages.remove_poi (poi.id)
		end
	end
	self._bell = nil
	self:report_lost_poi ("bell", reason)
end

local function acquire_bell (pos, limit)
	local poi = mcl_villages.get_poi (pos)
	local meta = core.get_meta (pos)
	if poi and poi.data == BELL_POI then
		local users = meta:get_int ("mcl_villages:bell_users")
		if users <= (limit or 32) - 1 then
			meta:set_int ("mcl_villages:bell_users", users + 1)
			return true
		end
		return false
	else
		if mcl_villages.insert_poi (pos, BELL_POI) then
			meta:set_int ("mcl_villages:bell_users", 0)
			return true
		end
	end
end

function villager:who_are_you_looking_at ()
	local customer = self:get_trading_with ()
	if customer then
		self._locked_object = customer
	elseif self._lovemaking then
		self._locked_object = self._lovemaking
	elseif self._visiting_wanted_item then
		self._locked_object = self._visiting_wanted_item
	elseif self._interaction_target then
		self._locked_object = self._interaction_target
	else
		self._locked_object = nil
	end

	if self.ai_idle_time > 2.0 and self._locked_object
		and is_valid (self._locked_object) then
		self.ai_idle_time = 1.0
		self:look_at (self._locked_object:get_pos ())
	end
end

-- See https://minecraft.wiki/w/Villager#Panicking
local alarm_distances = {
	["mobs_mc:baby_drowned"] = 8.0,
	["mobs_mc:baby_husk"] = 8.0,
	["mobs_mc:baby_zombie"] = 8.0,
	["mobs_mc:drowned"] = 8.0,
	["mobs_mc:husk"] = 8.0,
	["mobs_mc:illusioner"] = 12.0,
	["mobs_mc:pillager"] = 15.0,
	["mobs_mc:ravager"] = 12.0,
	["mobs_mc:vex"] = 8.0,
	["mobs_mc:villager_zombie"] = 8.0,
	["mobs_mc:vindicator"] = 10.0,
	["mobs_mc:zoglin"] = 10.0,
	["mobs_mc:zombie"] = 8.0,
}

local mature_plants = {
	"mcl_farming:wheat",
	"mcl_farming:potato",
	"mcl_farming:beetroot",
	"mcl_farming:carrot",
}

local function is_mature_crop_or_air (nodeinfo)
	if nodeinfo.name == "air" then
		return true
	else
		return table.indexof (mature_plants, nodeinfo.name) ~= -1
	end
end

local function is_mature_crop (nodeinfo)
	return table.indexof (mature_plants, nodeinfo.name) ~= -1
end

local function is_farmland (nodeinfo)
	return nodeinfo.name == "mcl_farming:soil_wet"
		or nodeinfo.name == "mcl_farming:soil"
end

local soil_groups = {
	"mcl_farming:soil_wet",
	"mcl_farming:soil",
}

local villager_seeds = {
	"mcl_farming:wheat_seeds",
	"mcl_farming:potato_item",
	"mcl_farming:carrot_item",
	"mcl_farming:beetroot_seeds",
}

local function sense_nearby_jobsites (self, self_pos)
	local profession = self._profession
		and professions_by_name[self._profession]
	local aa = vector.offset (self_pos, -48, -32, -48)
	local bb = vector.offset (self_pos, 48, 32, 48)
	local names = profession and profession.group_node_names
		or jobsite_names
	local result = poi_search_cache:find_nodes_in_area (aa, bb, names)
	local persist = 2.0 + pr:next (0, 20) / 20
	return result, persist
end

local function sense_free_jobsites (self, self_pos)
	local nodes = self:run_sensor (self_pos, "nearby_jobsites")
	local sites = {}
	for _, node in ipairs (nodes) do
		local hash = hash_pos (node)
		if self:should_retry (hash) then
			self:process_retry_attempt (hash)
			local poi = mcl_villages.get_poi (node)
			if not poi then
				table.insert (sites, node)
			end
		end
	end
	table.sort (sites, self._compare_distance)
	if #sites > 5 then
		sites[6] = nil
	end
	return sites
end

local function sense_nearby_beds (self, self_pos)
	local aa = vector.offset (self_pos, -48, -32, -48)
	local bb = vector.offset (self_pos, 48, 32, 48)
	local nodes
		= bed_search_cache:find_nodes_in_area (aa, bb)
	local result = nodes
	local persist = 2.0 + pr:next (0, 40) / 40
	return result, persist
end

local function sense_nearby_hideout (self, self_pos)
	local nearby
		= core.find_node_near (self_pos, 32, {"group:bed_bottom"}, true)
		or self._home
	local persist = 2.0 + pr:next (0, 40) / 40
	return nearby, persist
end

local function sense_nearby_raid_hideout (self, self_pos)
	local nearby
		= core.find_node_near (self_pos, 24, {"group:bed_bottom"}, true)
		or self._home
	local persist = 2.0 + pr:next (0, 40) / 40
	return nearby, persist
end

local function sense_free_beds (self, self_pos)
	local nodes = self:run_sensor (self_pos, "nearby_beds")
	local sites = {}
	for _, node in ipairs (nodes) do
		local hash = hash_pos (node)
		if self:should_retry (hash) then
			self:process_retry_attempt (hash)
			local poi = mcl_villages.get_poi (node)
			if not poi then
				table.insert (sites, node)
			end
		end
	end
	table.sort (sites, self._compare_distance)
	if #sites > 5 then
		sites[6] = nil
	end
	return sites
end

local cid_bells

core.register_on_mods_loaded (function ()
	cid_bells = mcl_levelgen.construct_cid_list ({
		"group:bell",
	})
end)

local function sense_nearby_bells (self, self_pos)
	local aa = vector.offset (self_pos, -48, -32, -48)
	local bb = vector.offset (self_pos, 48, 32, 48)
	local result = bell_search_cache:find_nodes_in_area (aa, bb, cid_bells)
	local persist = 2.0 + pr:next (0, 20) / 20
	return result, persist
end

local function sense_free_bells (self, self_pos)
	local nodes = self:run_sensor (self_pos, "nearby_bells")
	local sites = {}
	for _, node in ipairs (nodes) do
		local hash = hash_pos (node)
		if self:should_retry (hash) then
			self:process_retry_attempt (hash)
			local poi = mcl_villages.get_poi (node)
			if not poi or (poi.data == BELL_POI
				       and check_bell_occupancy (node)) then
				table.insert (sites, node)
			end
		end
	end
	table.sort (sites, self._compare_distance)
	if #sites > 5 then
		sites[6] = nil
	end
	return sites
end

local WANTED_ITEM_RANGE = 8.0

local function sense_visible_wanted_items (self, self_pos)
	local items = {}
	for object in core.objects_inside_radius (self_pos, WANTED_ITEM_RANGE) do
		local entity = object:get_luaentity ()
		if entity and entity.name == "__builtin:item"
			and check_item_timeout (self, entity) then
			local stack = ItemStack (entity.itemstring)
			if self:should_pick_up (stack)
				and self:target_visible (self_pos, object) then
				table.insert (items, object)
			end
		end
	end
	table.sort (items, self._compare_object_distance)
	local persist = 0.7 + pr:next (0, 12) / 20
	return items, persist
end

local ENTITY_VIEW_RANGE = 16.0

local function sense_visible_living_entities (self, self_pos)
	local entities = {}
	for object in core.objects_inside_radius (self_pos, ENTITY_VIEW_RANGE) do
		local entity = object:get_luaentity ()
		if object ~= self.object
			and (object:is_player () or (entity and entity.is_mob)) then
			if self:target_visible (self_pos, object) then
				table.insert (entities, object)
			end
		end
	end
	return entities
end

local function sense_nearby_cats (self, self_pos)
	local entities
		= self:run_sensor (self_pos, "visible_living_entities")
	local cats = {}
	for _, object in pairs (entities) do
		local entity = object:get_luaentity ()
		if entity and entity.name == "mobs_mc:cat" then
			table.insert (cats, object)
		end
	end
	return cats
end

local function sense_nearby_villagers (self, self_pos)
	local entities
		= self:run_sensor (self_pos, "visible_living_entities")
	local villagers = {}
	for _, object in pairs (entities) do
		local entity = object:get_luaentity ()
		if entity and entity.name == "mobs_mc:villager" then
			table.insert (villagers, object)
		end
	end
	return villagers
end

local function sense_villagers_at_bell (self, self_pos)
	local result
	if not self._bell then
		result = {}
	else
		local entities
			= self:run_sensor (self_pos, "nearby_villagers")
		local villagers = {}
		for _, object in pairs (entities) do
			local pos = object:get_pos ()
			if vector.distance (pos, self._bell) <= 8.0
				and vector.distance (pos, self_pos) <= 16.0 then
				table.insert (villagers, object)
			end
		end
		table.sort (villagers, self._compare_object_distance)
		result = villagers
	end
	return result
end

local function sense_find_a_home (self, self_pos)
	local nodes = self:run_sensor (self_pos, "nearby_beds")

	if #nodes == 0 then
		return nil
	else
		-- If the closest bed is within 2 blocks of
		-- this mob and is within line of sight, do
		-- nothing.
		local eye_height = self:get_eye_height ()
		local eye_pos = vector.offset (self_pos, 0, eye_height, 0)
		local offset = vector.offset (nodes[1], 0, 0.1, 0)
		if vector.distance (self_pos, offset) <= 2.0
			and self:line_of_sight (eye_pos, offset) then
			return nil
		else
			-- Locate a reachable bed and head there.
			local list = {}
			local i = 0
			for _, item in ipairs (nodes) do
				-- find_a_home should not be impeded
				-- by the sensor for nearby beds.
				local hash = hash_pos (item) + 281474976710656
				if self:should_retry (hash) then
					i = i + 1
					list[i] = nodes[i]
					self:process_retry_attempt (hash)
				end
			end

			if i > 0 then
				local _, closest = self:find_path_and_target (list, 1.0)
				return closest
			end
			return nil
		end
	end
end

local function sense_nearest_hostile (self, self_pos)
	local nearby = self:run_sensor (self_pos, "visible_living_entities")
	local nearest, nearest_dist = nil, nil
	for _, object in pairs (nearby) do
		local entity = object:get_luaentity ()
		if entity then
			local distance
				= vector.distance (object:get_pos (), self_pos)
			if not nearest_dist or distance < nearest_dist then
				local hostile_dist
					= alarm_distances[entity.name]
				if hostile_dist and distance < hostile_dist then
					nearest = object
					nearest_dist = distance
				end
			end
		end
	end
	return nearest
end

local function sense_nearby_farmland (self, self_pos)
	local pos = mcl_util.get_nodepos (self_pos)
	local aa = vector.offset (pos, -4, -2, -4)
	local bb = vector.offset (pos, 4, 2, 4)
	local nodes = core.find_nodes_in_area (aa, bb, soil_groups)
	table.shuffle (nodes)
	local persist = 1.0 + math.random (0, 20) / 20
	return nodes, persist
end

local function sense_harvestable_farmland (self, self_pos)
	local pos = mcl_util.get_nodepos (self_pos)
	local aa = vector.offset (pos, -2, -2, -2)
	local bb = vector.offset (pos, 2, 0, 2)
	local nodes = core.find_nodes_in_area (aa, bb, soil_groups)
	table.shuffle (nodes)
	local valid = {}
	for _, node in pairs (nodes) do
		local above = vector.offset (node, 0, 1, 0)
		local info = core.get_node (above)

		if is_mature_crop_or_air (info) then
			table.insert (valid, node)

			if #valid >= 5 then
				break
			end
		end
	end
	return valid
end

local function sense_random_immature_crop (self, self_pos)
	local pos = mcl_util.get_nodepos (self_pos)
	local aa = vector.offset (pos, -2, -1, -2)
	local bb = vector.offset (pos, 2, 1, 2)
	local nodes = core.find_nodes_in_area (aa, bb, {"group:plant"})
	table.shuffle (nodes)

	for _, pos in pairs (nodes) do
		local node = core.get_node (pos)
		local def = core.registered_nodes[node.name]

		-- XXX: wouldn't better criteria be in order...
		if table.indexof (villager_seeds, def._mcl_baseitem) ~= -1
			and table.indexof (mature_plants, node.name) == -1 then
			return pos
		end
	end
	return nil
end

local function sense_mate (self, self_pos)
	local entities
		= self:run_sensor (self_pos, "visible_living_entities")
	local mates = {}

	for _, object in pairs (entities) do
		local entity = object:get_luaentity ()
		if entity and entity.name == "mobs_mc:villager"
			and vector.distance (self_pos, object:get_pos ()) <= 8.0
			and not entity._lovemaking
			and entity:breeding_possible () then
			table.insert (mates, object)
		end
	end
	if #mates >= 1 then
		return mates[pr:next (1, #mates)]
	end
	return nil
end

local function sense_visible_children (self, self_pos)
	local entities = self:run_sensor (self_pos, "nearby_villagers")
	local children = {}

	for _, villager in ipairs (entities) do
		local entity = villager:get_luaentity ()
		if entity and entity.child then
			table.insert (children, villager)
		end
	end

	local persist = 1.5 + pr:next (0, 10) / 20
	return children, persist
end

local function sense_jumpable_bed (self, self_pos)
	local nearby
		= core.find_node_near (self_pos, 16, {"group:bed_bottom"}, true)
	local persist = 1.5 + pr:next (0, 20) / 20
	return nearby, persist
end

local function sense_villagers_requesting_golem (self, self_pos)
	local aa = vector.offset (self_pos, -10, -10, -10)
	local bb = vector.offset (self_pos, 10, 10, 10)
	local villagers = {}
	local gmt = core.get_gametime ()
	for object in core.objects_in_area (aa, bb) do
		local entity = object:get_luaentity ()
		if entity and entity.name == "mobs_mc:villager"
			and entity:desires_golem (gmt) then
			table.insert (villagers, object)
		end
	end
	local persist = 0.75 + pr:next (0, 10) / 20
	return villagers, persist
end

local function sense_nearby_visible_players (self, self_pos)
	local players = {}
	for object in mcl_util.connected_players (self_pos, 4) do
		if self:target_visible (self_pos, object) then
			table.insert (players, object)
		end
	end
	table.sort (players, self._compare_object_distance)
	local persist = 0.75 + pr:next (0, 10) / 20
	return players, persist
end

local function sense_nearby_visible_heroes (self, self_pos)
	local players = {}
	for object in mcl_util.connected_players (self_pos, self.view_range) do
		if mcl_potions.has_effect (object, "hero_of_village")
			and self:target_visible (self_pos, object) then
			table.insert (players, object)
		end
	end
	table.sort (players, self._compare_object_distance)
	local persist = 2.0 + pr:next (0, 10) / 20
	return players, persist
end

local function sense_active_raid (self, self_pos)
	local persist = 0.75 + pr:next (0, 10) / 20
	return mcl_raids.find_active_raid (self_pos), persist
end

-- local us_time = 0

function villager:run_sensor (self_pos, name)
	local result = nil
	local persist = 0

	if self._sensing[name] then
		return self._sensing[name][2]
	elseif name == "nearby_jobsites" then
		-- local clock = core.get_us_time ()
		result, persist = sense_nearby_jobsites (self, self_pos)
		-- us_time = us_time + (core.get_us_time () - clock)
	elseif name == "free_jobsites" then
		result = sense_free_jobsites (self, self_pos)
	elseif name == "nearby_beds" then
		-- local clock = core.get_us_time ()
		result, persist = sense_nearby_beds (self, self_pos)
		-- us_time = us_time + (core.get_us_time () - clock)
	elseif name == "nearby_hideout" then
		result, persist = sense_nearby_hideout (self, self_pos)
	elseif name == "nearby_raid_hideout" then
		result, persist = sense_nearby_raid_hideout (self, self_pos)
	elseif name == "free_beds" then
		result = sense_free_beds (self, self_pos)
	elseif name == "nearby_bells" then
		-- local clock = core.get_us_time ()
		result, persist = sense_nearby_bells (self, self_pos)
		-- us_time = us_time + (core.get_us_time () - clock)
	elseif name == "free_bells" then
		result = sense_free_bells (self, self_pos)
	elseif name == "visible_wanted_items" then
		result, persist = sense_visible_wanted_items (self, self_pos)
	elseif name == "visible_living_entities" then
		result = sense_visible_living_entities (self, self_pos)
	elseif name == "nearby_cats" then
		result = sense_nearby_cats (self, self_pos)
	elseif name == "nearby_villagers" then
		result = sense_nearby_villagers (self, self_pos)
	elseif name == "villagers_at_bell" then
		result = sense_villagers_at_bell (self, self_pos)
	elseif name == "find_a_home" then
		result = sense_find_a_home (self, self_pos)
	elseif name == "nearest_hostile" then
		result = sense_nearest_hostile (self, self_pos)
	elseif name == "nearby_farmland" then
		result, persist = sense_nearby_farmland (self, self_pos)
	elseif name == "harvestable_farmland" then
		result = sense_harvestable_farmland (self, self_pos)
	elseif name == "random_immature_crop" then
		result = sense_random_immature_crop (self, self_pos)
	elseif name == "mate" then
		result = sense_mate (self, self_pos)
	elseif name == "visible_children" then
		result, persist = sense_visible_children (self, self_pos)
	elseif name == "jumpable_bed" then
		result, persist = sense_jumpable_bed (self, self_pos)
	elseif name == "villagers_requesting_golem" then
		result, persist = sense_villagers_requesting_golem (self, self_pos)
	elseif name == "nearby_visible_players" then
		result, persist = sense_nearby_visible_players (self, self_pos)
	elseif name == "nearby_visible_heroes" then
		result, persist = sense_nearby_visible_heroes (self, self_pos)
	elseif name == "active_raid" then
		result, persist = sense_active_raid (self, self_pos)
	end
	self._sensing[name] = {
		persist, result,
	}
	return result
end

-- local max_10_steps = 0.0
-- local step_count = 0

-- core.register_globalstep (function (dtime)
-- 	max_10_steps = math.max (max_10_steps, us_time)
-- 	us_time = 0.0

-- 	if step_count + 1 > 10 then
-- 		print (max_10_steps)
-- 		step_count = 0
-- 		max_10_steps = 0
-- 	else
-- 		step_count = step_count + 1
-- 	end
-- end)

function villager:do_navigate (self_pos, dtime, target, bonus,
				ongoing, tolerance, timeout)
	if not ongoing then
		self:session_navigate (target, bonus, tolerance or 1.0)
		return true
	else
		local state
			= self:poll_navigation_state (self_pos, dtime, timeout,
							target)
		if state == "wait" then
			return true
		end
		local dist = vector.distance (self_pos, target)
		return false, state, dist
	end
end

function villager:find_path_and_target (pois, tolerance)
	local context = self:gwp_initialize (pois, 64, tolerance)

	if not context then
		return nil
	end

	self:gwp_cycle (context, math.huge)
	local path, partial = self:gwp_reconstruct (context)
	if not partial then
		return path, vector.copy (path.target)
	else
		return nil
	end
end

function villager:seen_hostile_lately (self_pos)
	if self._seen_hostile then
		return self._seen_hostile[2]
	end

	local hostile = self:run_sensor (self_pos, "nearest_hostile")

	if hostile then
		self._seen_hostile = {
			0.65,
			true,
		}
		return true
	end
	self._seen_hostile = {
		0.65,
		false,
	}
	return false
end

function villager:slept_recently_enough_for_golem (gmt)
	return self._last_slept_gmt ~= 0
		and gmt - self._last_slept_gmt < 1200
end

function villager:detect_golem (self_pos, dtime)
	if self:check_timer ("detect_golem", 2.0) then
		local nearby_entities
			= self:run_sensor (self_pos, "visible_living_entities")

		for _, obj in pairs (nearby_entities) do
			local entity = obj:get_luaentity ()
			if entity and entity.name == "mobs_mc:iron_golem" then
				self._last_golem_gmt = core.get_gametime ()
				break
			end
		end
	end
end

function villager:seen_golem_lately (gmt)
	return gmt - self._last_golem_gmt < 30
end

function villager:desires_golem (gmt)
	return self:slept_recently_enough_for_golem (gmt)
		and not self:seen_golem_lately (gmt)
end

function villager:summon_golem (self_pos)
	local aa = vector.offset (self_pos, -8, -5, -8)
	local bb = vector.offset (self_pos, 8, 5, 8)
	local nn = core.find_nodes_in_area_under_air (aa, bb, {
		"group:solid", "group:water"
	})
	table.shuffle (nn)
	for _, n in pairs (nn) do
		local half = 1/2
		local air = core.find_nodes_in_area(
			vector.offset(n, -half, 1, -half),
			vector.offset(n, half, 3, half),
			{"air"}
		)
		local required_air = 2*3*2
		local nb = core.get_node(vector.offset(n,0,-1,0))
		local nb_solid = core.get_item_group(nb.name, "solid") == 1
		if #air >= required_air and nb_solid then
			local spawnpos = vector.offset(n,-0.5,0.5,-0.5)
			if core.get_item_group(core.get_node(n).name, "water") ~= 0 then
				spawnpos = vector.offset(spawnpos,0,-1,0)
			end
			local golem = core.add_entity (spawnpos, "mobs_mc:iron_golem")
			if golem then
				return true
			end
		end
	end

	return false
end

function villager:maybe_summon_golem (self_pos, n_villagers)
	local gmt = core.get_gametime ()
	if self:desires_golem (gmt) then
		-- Attempt to locate a minimum of five villagers (if
		-- not panicking) or three villagers (if panicking)
		-- within 10 blocks also requesting a golem.

		local villagers
			= self:run_sensor (self_pos, "villagers_requesting_golem")
		villager_log (table.concat {
			"Requesting golem: ",
			#villagers, "/", n_villagers, " present",
		})
		if #villagers >= n_villagers and self:summon_golem (self_pos) then
			for _, villager in pairs (villagers) do
				local entity = villager:get_luaentity ()
				if entity then
					entity._last_golem_gmt = gmt
				end
			end
		end
	end
	return
end

function villager:start_panic (self_pos, dtime)
	if self._panic_time or self:seen_hostile_lately (self_pos) then
		if self:check_timer ("golem_summon", 5.0) then
			self:maybe_summon_golem (self_pos, 3)
		end

		if self._special_schedule ~= "PANIC" then
			self._special_schedule = "PANIC"
			self._interaction_target = nil
			self._breed_target = nil
			self:replace_activity (nil)
		end
	end
end

function villager:answer_bell (self_pos, dtime)
	if self._special_schedule ~= "BELL_RANG" then
		if self._last_alarm_gmt ~= 0 then
			if mcl_raids.find_active_raid (self_pos) then
				return
			end
			local time = core.get_gametime ()
			if time - self._last_alarm_gmt <= 15 then
				self._special_schedule = "BELL_RANG"
				self._interaction_target = nil
				self._breed_target = nil
				self:replace_activity (nil)
			else
				self._last_alarm_gmt = 0
			end
		end
	end
end

function villager:report_lost_poi (name, reason)
	if villager_debug then
		local villager_name
			= core.get_translated_string ("en", self:get_dialog_label ())
		local blurb = "[mobs_mc]: Villager "
			.. villager_name .. " lost poi "
			.. name .. " for reason: " .. (reason or "unspecified")
		core.log ("action", blurb)
	end
end

function villager:validate_job_sites ()
	if self._provisional_job_site then
		local pos = self._provisional_job_site
		local poi = mcl_villages.get_poi (pos)

		-- This job site vanished or was claimed.
		if not poi or poi.data ~= "mcl_villages:provisional_poi" then
			self._provisional_job_site = nil
			self._sensing["nearby_jobsites"] = nil
		end
	end
	if self._job_site then
		local pos = self._job_site
		local poi = mcl_villages.get_poi (pos)
		local profession = professions_by_name[self._profession]

		-- A self._profession of nil has been observed in
		-- certain old villagers with job sites.
		if not profession or not poi or poi.data ~= profession.poi then
			self:report_lost_poi ("job_site", "POI destroyed")
			self._job_site = nil
			self._sensing["nearby_jobsites"] = nil
			self:post_relinquish_job_site ()
		end
	end
	if self._home then
		local pos = self._home
		local poi = mcl_villages.get_poi (pos)
		if not poi or poi.data ~= BED_POI then
			self:report_lost_poi ("home", "POI destroyed")
			self._home = nil
			self._sensing["nearby_beds"] = nil
		end
	end
	if self._bell then
		local pos = self._bell
		local poi = mcl_villages.get_poi (pos)
		if not poi or poi.data ~= BELL_POI then
			self:report_lost_poi ("bell", "POI destroyed")
			self._bell = nil
			self._sensing["nearby_bells"] = nil
		end
	end
end

function villager:get_trading_with ()
	for player, _ in pairs (self._trading_with) do
		return player
	end
	return nil
end

function villager:interact_with_customer (self_pos, dtime)
	local customer = self:get_trading_with ()
	if self._entertaining_customer then
		if customer then
			self:look_at (customer:get_pos ())
		end
		return customer ~= nil
	elseif customer and is_valid (customer) then
		local pos = customer:get_pos ()
		self:gopath (pos, 0.5, nil, 2.0)
		self._entertaining_customer = true
		return "_entertaining_customer"
	end
end

function villager:visit_wanted_item (self_pos, dtime)
	if self._visiting_wanted_item then
		local item = self._visiting_wanted_item
		local pos = item:get_pos ()
		if not pos then
			self._visiting_wanted_item = nil
			return false
		end

		local continue, _, distance
			= self:do_navigate (self_pos, dtime, pos, 0.5, true)
		if continue then
			return true
		end
		if distance < 1.75 then
			local entity = item:get_luaentity ()
			assert (entity.name == "__builtin:item")
			local stack = ItemStack (entity.itemstring)
			self:default_pickup (item, stack, nil, nil)
		end
		self._visiting_wanted_item = false
		return false
	else
		local items = self:run_sensor (self_pos, "visible_wanted_items")
		for _, item in ipairs (items) do
			-- Verify that the item is still desired and
			-- available.
			if is_valid (item) then
				local entity = item:get_luaentity ()
				local stack = ItemStack (entity.itemstring)
				if self:should_pick_up (stack) then
					local pos = item:get_pos ()
					if self:do_navigate (self_pos, dtime, pos, 0.5, false) then
						self._visiting_wanted_item = item
						return "_visiting_wanted_item"
					end
				end
			end
		end
		return false
	end
end

local function acquire_provisional_poi (pos)
	mcl_villages.insert_poi (pos, "mcl_villages:provisional_poi")
end

local function remove_provisional_poi (pos)
	local poi = mcl_villages.get_poi (pos)
	assert (poi)

	mcl_villages.remove_poi (poi.id)
end

function villager:claim_poi (target, node)
	local node = node or core.get_node (target)
	local profession = get_profession (node.name)
	if not profession or (self._profession
				and self._profession ~= profession.name) then
		core.log ("warning", table.concat ({
			"Attempting to claim an invalid job site: ",
			vector.to_string (target),
			" (type = ",
			node.name,
			", current profession = ",
			self._profession or "unemployed",
			")",
		}))
	else
		if mcl_villages.insert_poi (target, profession.poi) then
			self._job_site = vector.copy (target)
			self._wander_time = 0
			self:happy_villager_effect ()
			self:set_profession (profession.name)
		end
	end
end

function villager:acquire_job_site (self_pos, dtime)
	if self._job_site or self.child then
		return false
	end

	local _, target = nil, self._provisional_job_site

	if self._acquiring_job_site then
		local t = self._acquiring_job_site - dtime
		if not target then
			self._acquiring_job_site = nil
			return false
		end

		local result, _, dist
			= self:do_navigate (self_pos, dtime, target, 0.5, true)
		if not result then
			if dist < 2 then
				remove_provisional_poi (target)
				self:claim_poi (target, nil)
			else
				relinquish_provisional_poi (target)
				local hash = hash_pos (target)
				self:abandon_for (hash, 60)
			end
			self._provisional_job_site = nil
			self._acquiring_job_site = nil
			return false
		end

		if t <= 0 then
			-- Timeout.
			relinquish_provisional_poi (target)
			local hash = hash_pos (target)
			self:abandon_for (hash, 60)
			self:cancel_navigation ()
			self:halt_in_tracks ()
			self._provisional_job_site = nil
			self._acquiring_job_site = false
			return false
		end

		self._acquiring_job_site = t
		return true
	elseif self._profession ~= "nitwit" then
		-- Locate a free nearby job site.
		if not self._job_site and not target then
			local sites = self:run_sensor (self_pos, "free_jobsites")

			if #sites > 0 then
				_, target
					= self:find_path_and_target (sites, 1)

				if target then
					self._provisional_job_site = target
					acquire_provisional_poi (target)
				end
			end
		end

		if self._schedule_name == "IDLE"
			or self._schedule_name == "WORK"
			or self._schedule_name == "PLAY" then
			if target and self:do_navigate (self_pos, dtime, target,
							0.5, false) then
				self._acquiring_job_site = 60.0
				return "_acquiring_job_site"
			end
		elseif target and vector.distance (self_pos, target) < 2.0 then
			remove_provisional_poi (target)
			self:claim_poi (target, nil)
			self._provisional_job_site = nil
			return nil
		end

		return false
	end
end

function villager:claim_home (home)
	if mcl_villages.insert_poi (home, BED_POI) then
		self._home = vector.copy (home)
		return true
	end
end

function villager:claim_bell (bell)
	if acquire_bell (bell) then
		self._bell = vector.copy (bell)
		return true
	end
end

-- XXX: is it necessary to resolve situations where two villagers
-- acquire the same bed or work site during gaps in work site
-- accounting?

function villager:acquire_bed (self_pos, dtime)
	if not self._home and self:check_timer ("acquire_bed", 1.0) then
		local beds = self:run_sensor (self_pos, "free_beds")

		if #beds > 0 then
			local _, target = self:find_path_and_target (beds, 1)
			if target then
				if self:claim_home (target) then
					self:happy_villager_effect ()
				end
			end
		end
	end
end

function villager:acquire_bell (self_pos, dtime)
	if not self._bell and not self.child
		and self:check_timer ("acquire_bell", 1.0) then
		local bells = self:run_sensor (self_pos, "free_bells")

		if #bells > 0 then
			local _, target = self:find_path_and_target (bells, 6)
			if target then
				if self:claim_bell (target) then
					self:happy_villager_effect ()
				end
			end
		end
	end
end

function villager:near_map_boundaries ()
	-- Return whether this villager is so near the perimeter of
	-- the loaded area of the map that any failure to navigate is
	-- most likely to be a result of the map being unloaded.

	if self._near_map_boundaries ~= nil then
		return self._near_map_boundaries
	end

	local node_pos = self.object:get_pos ()
	node_pos.x = math.floor (node_pos.x + 0.5)
	node_pos.y = math.floor (node_pos.y + 0.5)
	node_pos.z = math.floor (node_pos.z + 0.5)
	if not core.get_node_or_nil (node_pos) then
		self._near_map_boundaries = true
		return true
	end
	node_pos.x = node_pos.x + 16
	if not core.get_node_or_nil (node_pos) then
		self._near_map_boundaries = true
		return true
	end
	node_pos.x = node_pos.x - 32
	if not core.get_node_or_nil (node_pos) then
		self._near_map_boundaries = true
		return true
	end
	node_pos.x = node_pos.x + 16
	node_pos.z = node_pos.z + 16
	if not core.get_node_or_nil (node_pos) then
		self._near_map_boundaries = true
		return true
	end
	node_pos.z = node_pos.z - 32
	if not core.get_node_or_nil (node_pos) then
		self._near_map_boundaries = true
		return true
	end
	self._near_map_boundaries = false
	return false
end

local function generate_wander_to (poi_field, activity_name, time_field, time_limit,
			wander_threshold, tolerance, relinquish_job_site, start_conditions)
	return function (self, self_pos, dtime)
		local poi = self[poi_field]
		local phase = self[activity_name]
		if phase then
			if not poi then
				self[activity_name] = nil
				self[time_field] = nil
				return false
			end

			-- Move in the direction of the job site/POI.
			-- If the entire process consumes more than
			-- one minute (or rather TIME_LIMIT) and the
			-- job site is loaded, relinquish the job
			-- site.
			local t = self[time_field] + dtime
			self[time_field] = t

			if t > time_limit then
				if not self:near_map_boundaries () then
					relinquish_job_site (self, "wander timeout")
				end
				self[activity_name] = nil
				self[time_field] = nil
				return false
			end

			if manhattan3d (self, self_pos, poi) < wander_threshold then
				if phase == 0 then
					self[activity_name] = 1
					self:session_navigate (poi, 0.5, tolerance)
				else
					local status = self:poll_navigation_state (self_pos, dtime)

					if status == "arrived" then
						self[activity_name] = false
						self[time_field] = nil
						return false
					end

					if status == "failed" then
						if not self:near_map_boundaries () then
							relinquish_job_site (self, "wander timeout within near threshold")
						end
						self[activity_name] = nil
						self[time_field] = nil
						return false
					end
				end
				return true
			end

			local status = self:poll_navigation_state (self_pos, dtime)
			if phase == 0 and status == "arrived" then
				local dir = vector.direction (self_pos, poi)
				local target
					= self:target_in_direction (self_pos, 15, 7, dir, math.pi / 2)
				if target then
					self:session_navigate (target, 0.5, 0.0)
				end
			end
			self[activity_name] = 0
			return true
		elseif poi
			and start_conditions (self)
			and not self:near_map_boundaries ()
			and manhattan3d (self, self_pos, poi) > tolerance then
			self[activity_name] = 0

			if not self[time_field] then
				self[time_field] = 0
			else
				self[time_field] = self[time_field] + dtime
			end
			return activity_name
		end
	end
end

villager.wander_home
	= generate_wander_to ("_home", "_wander_home", "_home_wander_time", 60, 100,
			      1, villager.relinquish_home, function () return true end)

function villager:check_wake_up (self_pos, dtime)
	if not self._villager_sleeping and self._sleeping_pose then
		self:wake_up ()
	end
end

local function not_bed_bottom (name)
	return core.get_item_group (name, "bed") ~= 1
end

local function is_bed_occupied (bed_pos)
	for object in core.objects_inside_radius (bed_pos, 0.5) do
		local entity = object:get_luaentity ()
		if entity and entity.name == "mobs_mc:villager"
			and entity._villager_sleeping
			and entity._home
			and vector.equals (entity._home, bed_pos) then
			return true
		end
	end
	return false
end

local function get_sleep_position (bed_pos)
	local bed = core.get_node (bed_pos)
	if not_bed_bottom (bed.name) or is_bed_occupied (bed_pos) then
		return nil
	end
	local dir = core.facedir_to_dir (bed.param2)
	local offset = vector.multiply (dir, 0.35)
	local yaw = math.atan2 (dir.z, dir.x) + math.pi / 2
	return vector.offset (vector.add (offset, bed_pos), 0, 0.06, 0), yaw
end

function villager:sleep (self_pos, dtime)
	if self._villager_sleeping then
		local home = self._home
		if not home then
			self:wake_up ()
			self._villager_sleeping = false
			return false
		end
		local node = core.get_node (home)
		if (node.name ~= "ignore"
		    and not_bed_bottom (node.name))
			or vector.distance (self_pos, home) >= 0.5 then
			self:wake_up ()
			self._villager_sleeping = false
			return false
		end
		return true
	else
		local home = self._home
		local gametime = core.get_gametime ()

		if (gametime - self._last_slept_gmt) >= 6
			and home
			and vector.distance (self_pos, home) < 2.0 then
			local position, yaw = get_sleep_position (home)
			if position then
				self.object:set_pos (position)
				self:set_yaw (yaw)
				self:gwp_close_memorized_doors ()
				self:begin_sleep ()
				self._villager_sleeping = true
				return "_villager_sleeping"
			end
		end

		return false
	end
end

function villager:find_a_home (self_pos, dtime)
	if self._finding_a_home then
		local home = self._finding_a_home
		local node = core.get_node (home)
		if self._home or core.get_item_group (node.name, "bed") == 0 then
			self._finding_a_home = nil
			return false
		end
		if not self:do_navigate (self_pos, dtime, home, 0.5, true, 1.0) then
			self._finding_a_home = nil
			return false
		end
		return true
	elseif not self._home
		and not self._shuffling_indoors
		and self:check_timer ("find_a_home", 1.0) then
		local home = self:run_sensor (self_pos, "find_a_home")
		if home and self:do_navigate (self_pos, dtime, home, 0.5, false, 1.0) then
			self._finding_a_home = home
			return "_finding_a_home"
		end
	end
end

function villager:find_shuffle_position (node_pos)
	for z = -1, 1 do
		for x = -1, 1 do
			for y = -1, 1 do
				if z ~= 0 or x ~= 0 or y ~= 0 then
					local node = vector.offset (node_pos, z, x, y)
					if not mcl_weather.is_outdoor (node)
						and self:gwp_classify_for_movement (node) == "WALKABLE" then
						return node
					end
				end
			end
		end
	end
	return nil
end

function villager:shuffle_indoors (self_pos, dtime)
	if self._shuffling_indoors then
		local pos = self._shuffling_indoors
		if type (pos) == "table" then
			if self:do_navigate (self_pos, dtime, pos, 0.5, true, 0.0) then
				return true
			end

			-- Cooldown...
			self._shuffling_indoors = pr:next (20, 40) / 20
		else
			local t = self._shuffling_indoors - dtime
			self._shuffling_indoors = t

			if t <= 0 then
				self._shuffling_indoors = nil
				return false
			end
		end
		return true
	elseif not self._home
		and pr:next (1, 100) == 1
		and not self._finding_a_home then
		local self_pos = self.object:get_pos ()
		local x, y, z = math.floor (self_pos.x + 0.5),
			math.floor (self_pos.y + 1.0),
			math.floor (self_pos.z + 0.5)
		local node_pos = vector.new (x, y, z)

		if mcl_weather.is_outdoor (node_pos) then
			return false
		else
			local pos = self:find_shuffle_position (node_pos)
			if pos and self:do_navigate (self_pos, dtime, pos, 0.5, false, 0.0) then
				self._shuffling_indoors = pos
				return "_shuffling_indoors"
			end
			return false
		end
	end
	return false
end

function villager:return_to_village (self_pos, dtime)
	if self._returning_to_village then
		local selected = self._returning_to_village
		if self:do_navigate (self_pos, dtime, selected, 0.5,
					true, 0.0) then
			return true
		end
		self._return_success = true
		self._returning_to_village = nil
		return false
	elseif not self._home and (pr:next (1, 50) or self._return_success) then
		local node_pos = mcl_util.get_nodepos (self_pos)
		local heat = mcl_villages.get_poi_heat (node_pos)
		self._return_success = false
		if heat >= 5 then
			return false
		end

		local section_pos = mcl_villages.section_position (node_pos)
		local section, new_heat = find_nearest_village_section (section_pos, 0)
		local selected = nil

		if section and new_heat > heat then
			local center = mcl_villages.center_of_section (section)
			local dir = vector.direction (self_pos, center)
			selected = self:target_in_direction (self_pos, 10, 7, dir,
							math.pi / 2)
		end

		if selected and self:do_navigate (self_pos, dtime, selected, 0.5,
						false, 0.0) then
			self._returning_to_village = selected
			return "_returning_to_village"
		end
		return false
	end
end

function villager:compost (composter)
	local compost_total = 20
	local total_wheat = 0
	local total_beetroot = 0

	for i, item in ipairs (self._inventory) do
		if compost_total <= 0 then
			break
		end

		local stack = ItemStack (item)
		local name = stack:get_name ()
		local take
		if name == "mcl_farming:beetroot_seeds" then
			local count = stack:get_count ()
			total_beetroot = total_beetroot + count
			local take_max
				= math.min (total_beetroot - 10, compost_total)
			take = math.min (math.max (take_max, 0), count)
		elseif name == "mcl_farming:wheat_seeds" then
			local count = stack:get_count ()
			total_wheat = total_wheat + count
			local take_max
				= math.min (total_wheat - 10, compost_total)
			take = math.min (math.max (take_max, 0), count)
		else
			take = 0
		end

		compost_total = compost_total - take

		for _ = 1, take do
			if mcl_composters.farmer_add_compost (composter, nil, stack) then
				stack:take_item ()
				self._inventory[i] = stack:to_string ()
			end
		end
	end
end

function villager:craft_bread (self_pos)
	if not self:has_items ("mcl_farming:bread", 37) then
		local n_wheat = self:count_items ("mcl_farming:wheat_item")
		local pcs = math.min (3, math.floor (n_wheat / 3))

		if pcs > 0 then
			local stack
				= self:remove_item ("mcl_farming:wheat_item", pcs * 3)
			local count = math.floor (stack:get_count () / 3)
			local itemstring
				= string.format ("mcl_farming:bread %d", count)
			local stack = ItemStack (itemstring)
			local rem = self:add_to_inventory (stack)
			if not rem:is_empty () then
				mcl_util.drop_item_stack (self_pos, rem)
			end
		end
	end
end

function villager:use_workstation (self_pos, job_site)
	local gmt = core.get_gametime ()
	local day = core.get_day_count ()
	self._last_labored_gmt = gmt
	self:check_restock (gmt, day)

	if self._profession == "farmer" then
		if core.is_protected (job_site, "") then
			return
		end

		self:compost (job_site)
		self:craft_bread (self_pos)
	end
end

function villager:work_at_job_site (self_pos, dtime)
	local job_site = self._job_site
	if self._working_at_job_site then
		local t = self._working_at_job_site - dtime
		if not job_site
			or vector.distance (self_pos, job_site) >= 1.73
			or t <= 0 then
			self._working_at_job_site = nil
			return false
		end

		self._working_at_job_site = t
		return true
	elseif job_site
		and pr:next (1, 2) == 1
		and self:check_timer ("work_at_jobsite", 15)
		and vector.distance (self_pos, job_site) < 1.73 then
		self:use_workstation (self_pos, job_site)
		self:look_at (job_site)
		self._working_at_job_site = 10 + pr:next (0, 10)
		return "_working_at_job_site"
	end
end

function villager:visit_job_site (self_pos, dtime)
	if self._visiting_job_site then
		local job_site = self._job_site
		if job_site and self:do_navigate (self_pos, dtime, job_site,
						0.4, true) then
			return true
		end
		self._visiting_job_site = false
		self._wander_time = 0
		return false
	elseif self._job_site
		and manhattan3d (self, self_pos, self._job_site) <= 25
		and vector.distance (self_pos, self._job_site) >= 1.73
		and self:do_navigate (self_pos, dtime, self._job_site,
			0.4, false) then
		self._visiting_job_site = true
		return "_visiting_job_site"
	end
end

function villager:acceptable_pacing_target (target)
	if self._schedule_name == "WORK" then
		local job_site = self._job_site
		return not job_site
			or manhattan3d (self, target, job_site) <= 9.0
	end
	if self._active_activity == "_playing_tag" then
		return mcl_villages.get_poi_heat (target) >= 5
	end
	return true
end

local SOLID_PACING_GROUPS = mcl_mobs.SOLID_PACING_GROUPS

function villager:pace_around_poi (self_pos, dtime)
	if self._pacing_around_poi then
		local target = self._pacing_around_poi
		if not self:do_navigate (self_pos, dtime, target, 0.4, true) then
			self._pacing_around_poi = false
			return false
		end
		return true
	elseif self._job_site
		and vector.distance (self_pos, self._job_site) < 6
		and self:check_timer ("pace_around_poi", 9.0) then
		local target = self:pacing_target (self_pos, 8, 6, SOLID_PACING_GROUPS)
		if target then
			if self:do_navigate (self_pos, dtime, target, 0.4, false) then
				self._pacing_around_poi = target
				return "_pacing_around_poi"
			end
		end
	end
	return false
end

function villager:move_to_farmland (self_pos, dtime)
	if self._moving_to_farmland then
		local target = self._moving_to_farmland
		if not self:do_navigate (self_pos, dtime, target, 0.5, true) then
			self._moving_to_farmland = false
			return false
		end
		return true
	elseif self._profession == "farmer"
		and self:check_timer ("move_to_farmland", 5.0) then
		local farmland = self:run_sensor (self_pos, "nearby_farmland")
		if #farmland > 0 then
			local farmland = farmland[pr:next (1, #farmland)]
			local above = vector.offset (farmland, 0, 1, 0)
			local class = self:gwp_classify_for_movement (above)
			if class == "WALKABLE"
				and self:do_navigate (self_pos, dtime, above, 0.5, false) then
				self._moving_to_farmland = above
				return "_moving_to_farmland"
			end
		end
		return false
	end
end

function villager:get_farmable_seed ()
	for i, item in ipairs (self._inventory) do
		local stack = ItemStack (item)
		if table.indexof (villager_seeds, stack:get_name ()) ~= -1 then
			local seed = stack:take_item ()
			self._inventory[i] = stack:to_string ()
			return seed
		end
	end

	return nil
end

function villager:farm (self_pos, dtime)
	if self._farming then
		local t = self._farmed_for + dtime
		self._farmed_for = t

		local cooldown = self._farming_cooldown - dtime
		self._farming_cooldown = cooldown

		if not self._target_farmland then
			if t > 10.0 then
				self._farming = false
				self._target_farmland = nil
				return false
			end
			if cooldown > 0.0 then
				return true
			end
			local n_blocks = #self._farming
			if n_blocks <= 0 then
				local farmland
					= self:run_sensor (self_pos, "harvestable_farmland")
				if #farmland > 0 then
					self._farming = farmland
					n_blocks = #farmland
				else
					return true
				end
			end
			local next_target = self._farming[n_blocks]
			self._farming[n_blocks] = nil
			self._farming_cooldown = 0.0

			if self:do_navigate (self_pos, dtime, next_target, 0.5, false) then
				self._target_farmland = next_target
				return true
			end
		else
			local target = self._target_farmland
			local continue, _, dist
				= self:do_navigate (self_pos, dtime, target, 0.5, true)

			if continue then
				return true
			end

			if dist < 1.75 then
				local above = vector.offset (target, 0, 1, 0)
				local node = core.get_node (above)
				if is_mature_crop (node)
					and not core.is_protected (above, "") then
					core.dig_node (above, self.object)
				elseif node.name == "air"
					and not core.is_protected (above, "") then
					local seed = self:get_farmable_seed ()
					local node = core.get_node (target)
					if seed and is_farmland (node) then
						local def = seed:get_definition ()
						local plant = def._mcl_places_plant
						assert (plant)
						local what = {
							name = plant,
						}
						core.place_node (above, what, self.object)
					elseif seed then
						self:add_to_inventory (seed)
					end
				end
			end
			self._target_farmland = nil
			self._farming_cooldown = 1.0
			return true
		end
	elseif mob_griefing
		and self._profession == "farmer"
		and self._job_site
		and vector.distance (self_pos, self._job_site) then
		local farmland = self:run_sensor (self_pos, "harvestable_farmland")
		if #farmland > 0 then
			self._farming = farmland
			self._farmed_for = 0
			self._farming_cooldown = 0
			return "_farming"
		end
	end

	return false
end

function villager:fertilize_farmland (self_pos, dtime)
	if self._fertilizing_farmland then
		local t = self._fertilizing_for + dtime
		self._fertilizing_for = t
		local t1 = self._fertilize_cooldown - dtime
		self._fertilize_cooldown = t1

		if t >= 4.0 then
			self._fertilizing_farmland = false
			self._fertilize_farmland = nil
			return false
		end

		local target = self._fertilize_farmland

		if not target then
			if t1 > 0 then
				return true
			end

			target = self:run_sensor (self_pos, "random_immature_crop")
			self._fertilize_cooldown = 1.0
			if target and self:do_navigate (self_pos, dtime, target, 0.5, false) then
				self._fertilize_farmland = target
			else
				return true
			end
		end

		local continue, _, dist
			= self:do_navigate (self_pos, dtime, target, 0.5, true)

		if continue then
			return true
		end

		local stack, idx
		for i, slot in ipairs (self._inventory) do
			stack = ItemStack (slot)
			if stack:get_name () == "mcl_bone_meal:bone_meal" then
				idx = i
				break
			end
		end

		if idx and dist <= 1.5 then
			local node = core.get_node (target)
			local def = core.registered_nodes[node.name]
			if def._on_bone_meal
				and table.indexof (villager_seeds,
						   def._mcl_baseitem) ~= -1 then
				if def._on_bone_meal (stack, nil, nil, target, node) then
					mcl_bone_meal.add_bone_meal_particle (target)
					stack:take_item ()
					self._inventory[idx] = stack:to_string ()
				end
			end
		end
		self._fertilize_farmland = nil
		return true
	elseif mob_griefing
		and self._profession == "farmer"
		and self:check_timer ("start_bone_meal", 1.0)
		and not self._bone_meal_cooldown then
		local items = self:count_items ("mcl_bone_meal:bone_meal")
		if items <= 0 then
			return false
		else
			local target
				= self:run_sensor (self_pos, "random_immature_crop")
			if target and self:do_navigate (self_pos, dtime, target, 0.5, false) then
				self._fertilizing_farmland = true
				self._fertilize_farmland = target
				self._fertilize_cooldown = 1.0
				self._fertilizing_for = 0.0
				return "_fertilizing_farmland"
			end
		end
		return false
	end
end

local function evaluate_one_dispatch (a, b)
	return a[1] < b[1]
end

local function evaluate_dispatch (list)
	local list_1 = {}
	for _, entry in pairs (list) do
		local weight = entry[1]
		local random = pr:next (0, 2147483647) * r
		-- Higher weights yield lower priorities.
		local priority = -math.pow (random, weight)
		table.insert (list_1, {
			priority,
			entry[2],
		})
	end
	table.sort (list_1, evaluate_one_dispatch)
	return list_1
end

local function build_random_dispatch (name, functions_with_weights)
	local table_field = "_" .. name .. "_dispatch_table"
	local active_field = "_" .. name .. "_active_activity"
	local fn_field = "_" .. name .. "_active_function"

	return function (self, self_pos, dtime, moveresult)
		if self._active_activity
			and self._active_activity == self[active_field] then
			local fn = self[fn_field]
			assert (fn)
			local status, uninterruptible
				= fn (self, self_pos, dtime, moveresult)
			return status, uninterruptible
		else
			local disp = self[table_field]
			if not disp then
				disp = evaluate_dispatch (functions_with_weights)
			end
			for _, item in ipairs (disp) do
				local fn = item[2]
				local status, uninterruptible
					= fn (self, self_pos, dtime, moveresult)
				-- If status is a boolean rather than
				-- a string, the task is already
				-- running.  Do not terminate it
				-- immediately, but permit tasks that
				-- appear earlier in the generated
				-- dispatch table to override it.
				if status == true then
					self[table_field] = disp
					return status, uninterruptible
				elseif status then
					disp = evaluate_dispatch (functions_with_weights)
					self[active_field] = status
					self[fn_field] = fn
					self[table_field] = disp
					return status, uninterruptible
				end
			end
			self[table_field] = disp
			return false
		end
	end
end

villager.dispatch_work = build_random_dispatch ("work", {
	{ 2, villager.pace_around_poi,		},
	{ 5, villager.move_to_farmland,		},
	{ 2, villager.farm,			},
	{ 4, villager.fertilize_farmland,	},
	{ 5, villager.visit_job_site,		},
	{ 7, villager.work_at_job_site,		},
})

villager.wander_to_job_site
	= generate_wander_to ("_job_site", "_wandering_to_job_site", "_wander_time", 60, 100,
			      9, villager.relinquish_job_site, function (self)
					      return not self._pacing_around_poi
							and not self._visiting_job_site
							and not self._visiting_wanted_item
			     end)

local function sufficient_for_trade (a, b)
	if a:get_count () >= b:get_count ()
		and a:get_name () == b:get_name () then
		return true
	end

	return false
end

function villager:clear_wielditem (self_pos, dtime)
	if self._wielditem ~= "" then
		self:set_wielditem (ItemStack (""))
		self._displayed_trades = nil
		self._wielditem_timer = nil
		self._player_wielditem = nil
	end
end

function villager:preview_trades_1 (wielditem)
	if wielditem:is_empty () then
		self._displayed_trades = nil
		self._wielditem_timer = nil
		return nil
	end
	if wielditem ~= self._player_wielditem then
		-- Recompute the list of items to be displayed.
		self._displayed_trades = {}

		if not self._trades then
			self:reload_trades ()
		end

		for _, trade in ipairs (self._trades) do
			local wanted1 = trade:get_wanted1 ()
			local wanted2 = trade:get_wanted2 ()
			if sufficient_for_trade (wielditem, wanted1)
				or (not wanted2:is_empty ()
					and sufficient_for_trade (wielditem, wanted2)) then
				table.insert (self._displayed_trades, trade:get_offered ())
			end
		end

		self._wielditem_timer = 0.0
		self._player_wielditem = wielditem
	end
	return self._displayed_trades
end

function villager:preview_trades (self_pos, dtime)
	if not self._is_baby and self._profession then
		local target = self._interaction_target
		if target and target:is_player ()
			and vector.distance (self_pos, target:get_pos ()) <= 4.1 then
			local wielditem = target:get_wielded_item ()
			local trades = self:preview_trades_1 (wielditem)

			if trades and #trades > 0 then
				local t = (self._wielditem_timer or 0.0) + dtime
				local item = trades[1 + (math.floor (t / 2) % #trades)]
				self._wielditem_timer = t
				self:set_wielditem (item)
				return
			end
		else
			self._player_wielditem = nil
			self._displayed_trades = nil
		end
		if self._wielditem ~= "" then
			self:set_wielditem (ItemStack ())
		end
	end
end

local villager_gift_tables = {
	armorer = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				itemstring = "mcl_armor:helmet_chain"
			},
			{
				itemstring = "mcl_armor:chestplate_chain"
			},
			{
				itemstring = "mcl_armor:leggings_chain"
			},
			{
				itemstring = "mcl_armor:boots_chain"
			},
		},
	},
	butcher = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				itemstring = "mcl_mobitems:cooked_chicken"
			},
			{
				itemstring = "mcl_mobitems:cooked_mutton"
			},
			{
				itemstring = "mcl_mobitems:cooked_porkchop"
			},
			{
				itemstring = "mcl_mobitems:cooked_rabbit"
			},
			{
				itemstring = "mcl_mobitems:cooked_beef"
			},
		},
	},
	cartographer = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				itemstring = "mcl_maps:empty_map"
			},
			{
				itemstring = "mcl_core:paper"
			},
		},
	},
	cleric = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				itemstring = "mcl_core:lapis"
			},
			{
				itemstring = "mcl_redstone:redstone"
			},
		}
	},
	farmer = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				itemstring = "mcl_farming:bread"
			},
			{
				itemstring = "mcl_farming:cookie"
			},
			{
				itemstring = "mcl_farming:pumpkin_pie"
			},
		}
	},
	fisherman = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				itemstring = "mcl_fishing:fish_raw"
			},
			{
				itemstring = "mcl_fishing:salmon_raw"
			},
		},
	},
	fletcher = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				itemstring = "mcl_bows:arrow",
				weight = 26,
			},
			{
				itemstring = "mcl_potions:fire_resistance_arrow"
			},
			{
				itemstring = "mcl_potions:harming_arrow"
			},
			{
				itemstring = "mcl_potions:healing_arrow"
			},
			{
				itemstring = "mcl_potions:invisibility_arrow"
			},
			{
				itemstring = "mcl_potions:leaping_arrow"
			},
			{
				itemstring = "mcl_potions:night_vision_arrow"
			},
			{
				itemstring = "mcl_potions:poison_arrow"
			},
			{
				itemstring = "mcl_potions:regeneration_arrow"
			},
			{
				itemstring = "mcl_potions:slowness_arrow"
			},
			{
				itemstring = "mcl_potions:strength_arrow"
			},
			{
				itemstring = "mcl_potions:swiftness_arrow"
			},
			{
				itemstring = "mcl_potions:water_breathing_arrow"
			},
			{
				itemstring = "mcl_potions:weakness_arrow"
			},
		},
	},
	leatherworker = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				itemstring = "mcl_mobitems:leather"
			},
		}
	},
	librarian = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				itemstring = "mcl_books:book"
			},
		}
	},
	mason = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				itemstring = "mcl_core:clay"
			},
		},
	},
	shepherd = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				itemstring = "mcl_wool:black"
			},
			{
				itemstring = "mcl_wool:blue"
			},
			{
				itemstring = "mcl_wool:brown"
			},
			{
				itemstring = "mcl_wool:cyan"
			},
			{
				itemstring = "mcl_wool:green"
			},
			{
				itemstring = "mcl_wool:grey"
			},
			{
				itemstring = "mcl_wool:light_blue"
			},
			{
				itemstring = "mcl_wool:lime"
			},
			{
				itemstring = "mcl_wool:magenta"
			},
			{
				itemstring = "mcl_wool:orange"
			},
			{
				itemstring = "mcl_wool:pink"
			},
			{
				itemstring = "mcl_wool:purple"
			},
			{
				itemstring = "mcl_wool:red"
			},
			{
				itemstring = "mcl_wool:silver"
			},
			{
				itemstring = "mcl_wool:white"
			},
			{
				itemstring = "mcl_wool:yellow"
			},
		},
	},
	toolsmith = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				itemstring = "mcl_tools:axe_stone"
			},
			{
				itemstring = "mcl_farming:hoe_stone"
			},
			{
				itemstring = "mcl_tools:pick_stone"
			},
			{
				itemstring = "mcl_tools:shovel_stone"
			},
		},
	},
	weaponsmith = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				itemstring = "mcl_tools:axe_stone"
			},
			{
				itemstring = "mcl_tools:axe_gold"
			},
			{
				itemstring = "mcl_tools:axe_iron"
			},
		},
	},
}
mobs_mc.villager_gift_tables = villager_gift_tables

function villager:throw_gifts (self_pos, recipient, pos)
	local items
	if self.child then
		items = {ItemStack ("mcl_flowers:poppy")}
	else
		local profession_table = self._profession
			and villager_gift_tables[self._profession]
		if profession_table then
			items = mcl_loot.get_loot (profession_table, pr)
		else
			items = {ItemStack ("mcl_farming:wheat_seeds")}
		end
	end

	for _, item in pairs (items) do
		local throwing_pos
			= vector.offset (self_pos, 0, 1.9 * 0.6, 0)
		local dir = vector.direction (self_pos, pos)
		local obj = core.add_item (throwing_pos, item)

		-- Indicate that this item should not be collected by
		-- this mob for at least two seconds.
		if obj then
			local entity = obj:get_luaentity ()
			entity._dropped_by_villager = self.object
			entity._dropped_by_villager_gmt
				= core.get_gametime ()
			dir = vector.multiply (dir, 6.0)
			obj:set_velocity (dir)
		end
	end
end

function villager:salute_hero (self_pos, dtime)
	if self._saluting_hero then
		local hero = self._saluting_hero
		if not hero or not is_valid (hero) then
			self._saluting_hero = nil
			return false
		end
		self._interaction_target = hero

		local hero_pos = hero:get_pos ()
		local state = self:poll_navigation_state (self_pos, dtime, nil, hero_pos)
		if state == "wait" then
			return true
		elseif state == "arrived" then
			self:look_at (hero_pos)
			self:throw_gifts (self_pos, hero, hero_pos)
			self._hero_cooldown = (600 + pr:next (0, 6000)) / 20
		end
		self._saluting_hero = nil
		return false
	elseif not self._hero_cooldown then
		local heroes = self:run_sensor (self_pos, "nearby_visible_heroes")
		if heroes[1] then
			self._saluting_hero = heroes[1]
			self._interaction_target = heroes[1]
			self:session_navigate (heroes[1]:get_pos (), 0.5, 5.0)
			return "_saluting_hero"
		end

		return nil
	end
end

local FOLLOWERS_PER_LEADER = 5

local function is_leader (child)
	local entity = child:get_luaentity ()
	return entity and entity._playing_tag == true
end

local function get_poi_heat (pos)
	local nodepos = mcl_util.get_nodepos (pos)
	return mcl_villages.get_poi_heat (nodepos)
end

local function count_pursuers (child, children)
	local n_pursuers = 0
	for _, child in ipairs (children) do
		local entity = child:get_luaentity ()
		if entity and entity._playing_tag == child then
			n_pursuers = n_pursuers + 1
			if n_pursuers > FOLLOWERS_PER_LEADER then
				break
			end
		end
	end
	return n_pursuers
end

function villager:play_tag (self_pos, dtime)
	if self._playing_tag then
		-- Is leader?
		if self._playing_tag == true then
			local t = self._tag_time - dtime
			if t <= 0 then
				self._tag_time = nil
				self._playing_tag = nil
				return false
			end
			self._tag_time = t

			if self:navigation_finished ()
				and self:check_timer ("switch_tag_target", 0.5) then
				-- Continue to pace randomly.
				local target
					= self:pacing_target (self_pos, 14, 8, SOLID_PACING_GROUPS)
				if target then
					self:gopath (target, 0.6, nil, 0.5)
				end
			end

			return true
		else
			local leader = self._playing_tag
			if not is_valid (leader) then
				self._playing_tag = nil
				return false
			end
			local entity = leader:get_luaentity ()
			if entity._playing_tag ~= true then
				self._playing_tag = nil
				return false
			end

			-- Follow the leader.
			local position = leader:get_pos ()
			local distance = vector.distance (self_pos, position)
			if distance > 1.5 then
				local initialized = not self:navigation_finished ()
				if not self:do_navigate (self_pos, dtime, position, 0.6,
							 initialized, 1.0)
					and not initialized then
					-- Navigation failed.
					self._playing_tag = nil
					return false
				end
			elseif not self:navigation_finished () then
				self:cancel_navigation ()
				self:halt_in_tracks ()
			end
			return true
		end
	elseif pr:next (1, 10) == 1 and get_poi_heat (self_pos) >= 5 then
		local children = self:run_sensor (self_pos, "visible_children")

		-- Find and join any group with fewer than 5 members.
		for _, child in pairs (children) do
			if is_leader (child) then
				if count_pursuers (child, children) < FOLLOWERS_PER_LEADER then
					local pos = child:get_pos ()
					if vector.distance (self_pos, pos) <= 1.5
						or self:do_navigate (self_pos, dtime, pos,
									0.6, false, 1.0) then
						self._playing_tag = child
						self._interaction_target = child
						return "_playing_tag"
					end
				end
			end
		end

		-- Select a child at random and initiate a game of
		-- tag.
		local available_children = {}
		for _, child in ipairs (children) do
			local entity = child:get_luaentity ()
			if entity and not entity._playing_tag then
				table.insert (available_children, entity)
			end
		end
		if #available_children > 0 then
			local i = pr:next (1, #available_children)
			local chaser = available_children[i]

			if chaser:begin_chasing (self.object, self_pos, dtime) then
				self._playing_tag = true
				self._tag_time = pr:next (80, 200) / 20
				return "_playing_tag"
			end
		end

		return false
	end
end

function villager:begin_chasing (leader, leader_pos, dtime)
	local self_pos = self.object:get_pos ()
	if vector.distance (self_pos, leader_pos) <= 1.5
		or self:do_navigate (self_pos, dtime, leader_pos,
					0.6, false, 1.0) then
		self._playing_tag = leader
		self._interaction_target = leader
		self:replace_activity ("_playing_tag")
		return true
	end
	return false
end

function villager:interact_with (self_pos, dtime)
	if self._interacting_with then
		local target = self._interaction_target
		if not target then
			self._interacting_with = false
			return false
		end
		-- This is guaranteed to be valid by the test in
		-- ai_step.
		local pos = target:get_pos ()
		local continue
			= self:do_navigate (self_pos, dtime, pos, 0.5, true, 2)
		if continue then
			return true
		end
		self._interacting_with = false
		return false
	elseif not self._pacing_around_village and not self._bouncing_on_bed
		and pr:next (1, 120) == 1 then
		local available_types = {
			"nearby_cats",
			"nearby_villagers",
		}
		local n_types = #available_types
		local sensor = available_types[pr:next (1, n_types)]
		local objects = self:run_sensor (self_pos, sensor)

		if #objects > 0 then
			local object = objects[pr:next (1, #objects)]
			local pos = object:get_pos ()

			if pos and self:do_navigate (self_pos, dtime, pos, 0.5, false, 2) then
				self._interaction_target = object
				self._interacting_with = true
				self:look_at (pos)
				return "_interacting_with"
			end
		end
	end

	return false
end

local function generate_pace_around_village (activity_name, bonus, range_xz, range_y, always, start_condition)
	return function (self, self_pos, dtime)
		if self[activity_name] then
			if self:navigation_finished () then
				self[activity_name] = false
				return false
			end
			return true
		elseif not self._interacting_with
			and (always or pr:next (1, 120) == 1)
			and (not start_condition
			     or start_condition (self, self_pos)) then
			local section = mcl_villages.section_position (self_pos)
			local heat = mcl_villages.get_poi_heat_of_section (section)
			local pos
			local xz = range_xz
			local y = range_y

			if heat >= 5 then
				pos = self:pacing_target (self_pos, xz, y, SOLID_PACING_GROUPS)
			else
				local target = find_nearest_village_section (section, 5)
				if target and not vector.equals (target, section) then
					local center = mcl_villages.center_of_section (target)
					local dir = vector.direction (self_pos, center)
					pos = self:target_in_direction (self_pos, xz, y, dir, math.pi / 2)
				else
					pos = self:pacing_target (self_pos, xz, y, SOLID_PACING_GROUPS)
				end
			end

			if pos and self:gopath (pos, bonus) then
				self[activity_name] = true
				return activity_name
			end

			return false
		end
	end
end

villager.pace_around_village
	= generate_pace_around_village ("_pacing_around_village", 0.5, 10, 7, false,
				        function (self, self_pos)
						return not self._bouncing_on_bed
				        end)

villager.village_aware_pacing
	= generate_pace_around_village ("_village_aware_pacing", 0.5, 10, 7, false,
					function (self, self_pos)
						local heat = mcl_villages.get_poi_heat (self_pos)
						return heat <= 4 and not self._home
					end)

local function is_y_colliding_with_bed (moveresult)
	for _, collision in pairs (moveresult.collisions) do
		if collision.axis == "y" and collision.type == "node" then
			local node = core.get_node (collision.node_pos)
			if core.get_item_group (node.name, "bed") > 0 then
				return true
			end
		end
	end
	return false
end

function villager:bounce_on_bed (self_pos, dtime, moveresult)
	if self._bouncing_on_bed == 0 then
		local t = self._bouncing_for + dtime
		if t > 10 then
			self._bouncing_on_bed = nil
			return false
		end
		self._bouncing_for = t
		local wanted = self._bouncing_wanted
		local continue, _, _
			= self:do_navigate (self_pos, dtime, wanted, 0.5, true, 0.0)
		if continue then
			return true
		end
		self._bouncing_on_bed = 1
		self._bouncing_for = 0.0
	end
	if self._bouncing_on_bed == 1 then
		local touching_ground
			= moveresult.touching_ground or moveresult.stand_end
		local t = self._bouncing_for + dtime
		self._bouncing_for = t

		-- Wait for movement to settle somewhat before testing
		-- for a bed.
		if t < 0.75 then
			return true
		end

		if touching_ground then
			if t > self._jump_count * 1.5 + 0.75
				or not is_y_colliding_with_bed (moveresult) then
				self._bouncing_on_bed = false
				return false
			end

			self._jump = true
		end
		return true
	elseif self.child and pr:next (1, 230) == 1
		and self:check_timer ("bed_bounce", 3.0) then
		local bed = self:run_sensor (self_pos, "jumpable_bed")
		if bed then
			local above = vector.offset (bed, 0, 1, 0)
			-- Attempt to pathfind to the node above
			-- (which is to say, onto) this bed.
			if self:do_navigate (self_pos, dtime, above, 0.5, false, 0.0) then
				self._bouncing_on_bed = 0
				self._bouncing_wanted = above
				self._bouncing_for = 0.0
				self._jump_count = pr:next (3, 7)
				return "_bouncing_on_bed"
			end
		end
	end

	return false
end

function villager:gaze_at_player (self_pos, dtime)
	if not self._interaction_target then
		local players = self:run_sensor (self_pos, "nearby_visible_players")
		if #players > 0 then
			self._interaction_target = players[1]
		end
	end
end

function villager:visit_bell (self_pos, dtime)
	if self._visiting_bell then
		local job_site = self._bell
		if job_site and self:do_navigate (self_pos, dtime, job_site,
						0.4, true, 6.0) then
			return true
		end
		self._visiting_bell = false
		return false
	elseif not self._pacing_around_poi
		and not self._working_at_bell
		and self._bell
		and manhattan3d (self, self_pos, self._bell) <= 25
		and manhattan3d (self, self_pos, self._bell) >= 10
		and self:do_navigate (self_pos, dtime, self._bell,
			0.4, false, 6.0) then
		self._visiting_bell = true
		return "_visiting_bell"
	end
end

function villager:pace_around_bell (self_pos, dtime)
	if self._pacing_around_bell then
		local target = self._pacing_around_bell
		if not self:do_navigate (self_pos, dtime, target, 0.4, true) then
			self._pacing_around_bell = false
			return false
		end
		return true
	else
		local t = math.max (0, (self._bell_pace_cooldown or 0) - dtime)
		self._bell_pace_cooldown = t
		if not self._visiting_bell
			and not self._socializing_at_bell
			and self._bell
			and pr:next (1, 200) == 1
			and self._bell_pace_cooldown == 0
			and vector.distance (self_pos, self._bell) < 4 then
			local target = self:pacing_target (self_pos, 4, 4, SOLID_PACING_GROUPS)
			if target then
				if self:do_navigate (self_pos, dtime, target, 0.4, false) then
					self._pacing_around_bell = target
					self._bell_pace_cooldown = 9.0
					return "_pacing_around_bell"
				end
			end
			self._bell_wander_time = 0.0
		end
	end
	return false
end

function villager:socialize_at_bell (self_pos, dtime)
	if self._socializing_at_bell then
		local target = self._interaction_target
		if not target then
			self._socializing_at_bell = false
			return false
		end
		-- This is guaranteed to be valid by the test in
		-- ai_step.
		local pos = target:get_pos ()
		local continue
			= self:do_navigate (self_pos, dtime, pos, 0.3, true)
		if continue then
			return true
		end
		self._socializing_at_bell = false
		return false
	elseif not self._pacing_around_bell
		and pr:next (1, 100) == 1 then
		local villagers
			= self:run_sensor (self_pos, "villagers_at_bell")
		if #villagers > 0 then
			local villager = villagers[1]
			local pos = villager:get_pos ()

			self._interaction_target = villager
			self._socializing_at_bell = true
			self:look_at (pos)
			self:do_navigate (self_pos, dtime, pos, 0.3, false)
			return "_socializing_at_bell"
		end
	end
	return false
end

local villager_food_points = {
	["mcl_farming:bread"] = 4,
	["mcl_farming:potato_item"] = 1,
	["mcl_farming:carrot_item"] = 1,
	["mcl_farming:beetroot_item"] = 1,
}

local villager_food_items = {
	"mcl_farming:bread",
	"mcl_farming:potato_item",
	"mcl_farming:carrot_item",
	"mcl_farming:beetroot_item",
}

function villager:count_food_points ()
	local points = 0
	for _, slot in pairs (self._inventory) do
		local stack = ItemStack (slot)
		local name = stack:get_name ()
		if villager_food_points[name] then
			local add = villager_food_points[name]
				* stack:get_count ()
			points = points + add
		end
	end
	return points
end

function villager:has_surplus_food ()
	return self:count_food_points () > 24
end

function villager:need_more_food ()
	return self:count_food_points () < 12
end

local function intersection_of (a, b)
	local intersection = {}
	for _, item in ipairs (a) do
		if table.indexof (b, item) ~= -1 then
			table.insert (intersection, item)
		end
	end
	return intersection
end

function villager:get_villager_trades (target_entity)
	if target_entity._profession and self._profession then
		local profession
			= villager_professions[target_entity._profession]
		local my_profession
			= villager_professions[self._profession]
		if profession and my_profession then
			return intersection_of (profession.extra_pick_up,
						my_profession.extra_pick_up)
		end
	end
	return {}
end

function villager:throw_some_of (self_pos, target_pos, items)
	local stack = ItemStack ()

	for i, slot in ipairs (self._inventory) do
		local item = ItemStack (slot)

		if not item:is_empty ()
			and table.indexof (items, item:get_name ()) ~= -1 then
			local stacksize = item:get_stack_max ()
			local count = item:get_count ()
			local num_to_retain = math.min (24, stacksize / 2)

			if count > num_to_retain then
				stack = item:take_item (count - num_to_retain)
				self._inventory[i] = item:to_string ()
				break
			end
		end
	end

	if not stack:is_empty () then
		villager_log ("Throwing: " .. stack:to_string ())
		local throwing_pos
			= vector.offset (self_pos, 0, 1.9 * 0.6, 0)
		local dir = vector.direction (self_pos, target_pos)
		local obj = core.add_item (throwing_pos, stack)

		-- Indicate that this item should not be collected by
		-- this mob for at least two seconds.
		if obj then
			local entity = obj:get_luaentity ()
			entity._dropped_by_villager = self.object
			entity._dropped_by_villager_gmt
				= core.get_gametime ()
			dir = vector.multiply (dir, 4.0)
			obj:set_velocity (dir)
		end
	end
end

function villager:gossip_and_trade (self_pos, dtime)
	if self._gossiping then
		local target = self._interaction_target
		local entity = target and target:get_luaentity ()
		if not entity or entity.name ~= "mobs_mc:villager" then
			self._gossiping = false
			return false
		end

		if type (self._gossiping) == "number" then
			local t = self._gossiping - dtime
			if t <= 0 then
				self._gossiping = false
				self._interaction_target = nil
				return false
			end
			self._gossiping = t
			self:look_at (target:get_pos ())
			return true
		end

		local target_pos = target:get_pos ()
		local continue, _, dist
			= self:do_navigate (self_pos, dtime, target_pos, 0.5, true, 2.0)
		if continue then
			return true
		end

		if dist < 3.0 then
			self:look_at (target_pos)

			local entity = target:get_luaentity ()
			self:gossip_with (self_pos, entity)

			if self:has_surplus_food () and entity:need_more_food () then
				villager_log (table.concat {
					       "Throwing surplus food to ",
					       entity._profession or "unemployed",
					       " with ",
					       entity:count_food_points (),
					       " food points",
				})
				self:throw_some_of (self_pos, target_pos, villager_food_items)
			end
			if entity._profession == "farmer"
				and self:count_items ("mcl_farming:wheat_item") > 32 then
				self:throw_some_of (self_pos, target_pos, {"mcl_farming:wheat_item"})
			end
			if #self._gossip_trades > 0 then
				self:throw_some_of (self_pos, target_pos, self._gossip_trades)
			end
			self._gossiping = pr:next (40, 80) / 20
			return true
		end
		self._interaction_target = nil
		self._gossiping = false
		return false
	elseif self._interaction_target then
		local target = self._interaction_target
		local entity = target:get_luaentity ()
		if entity and entity.name == "mobs_mc:villager" then
			-- What have I to trade?
			local trades = self:get_villager_trades (entity)
			local target_pos = target:get_pos ()
			self._gossip_trades = trades
			if self:do_navigate (self_pos, dtime, target_pos, 0.5, false, 2.0)
				and entity:begin_gossip (self_pos, self.object, trades, dtime) then
				self._gossiping = true
				return "_gossiping"
			else
				self:cancel_navigation ()
				self._interaction_target = nil
				return false
			end
		end
		return false
	end
end

function villager:begin_gossip (pos, initiator, trades, dtime)
	local self_pos = self.object:get_pos ()
	if self:do_navigate (self_pos, dtime, pos, 0.5, false, 2.0) then
		self._gossiping = "accosted"
		self._interaction_target = initiator
		self._gossip_trades = trades
		self:replace_activity ("_gossiping")
		return true
	end
	return false
end

local HUNGER_THRESHOLD = 12

function villager:eat_before_breeding ()
	local old_level = self._food_level
	if self._food_level < HUNGER_THRESHOLD then
		for i, slot in ipairs (self._inventory) do
			local stack = ItemStack (slot)
			local name = stack:get_name ()
			local points = villager_food_points[name]

			if points then
				local temp = HUNGER_THRESHOLD - self._food_level
				local wanted = math.ceil (temp / points)
				local avail = stack:get_count () * points
				local consume = math.min (avail, wanted)
				local taken = stack:take_item (consume)
				villager_log (table.concat {
					"Consuming ", consume, " of ",
					taken:get_name (),
				})
				self._inventory[i] = stack:to_string ()
				self._food_level
					= self._food_level + taken:get_count () * points
				if self._food_level >= HUNGER_THRESHOLD then
					break
				end
			end
		end
	end
	villager_log (table.concat {
		self._profession or "unemployed",
		" with ",
		old_level,
		" gained ",
		self._food_level - old_level,
		" food points by eating",
	})
end

function villager:breeding_possible ()
	return self._food_level + self:count_food_points () > HUNGER_THRESHOLD
		and not self._sleeping and not self.child
end

function villager:digest_before_breeding ()
	self._food_level = self._food_level - 12
	return false
end

function villager:make_love (self_pos, dtime)
	if self._lovemaking then
		local mate = self._lovemaking
		local mate_pos = mate:get_pos ()
		local entity = mate:get_luaentity ()

		-- Detect whether this mob has been abandoned by its
		-- mate.
		if not mate_pos or entity._lovemaking ~= self.object then
			villager_log (table.concat {
				self._profession or "unemployed",
				" was abandoned by ",
				entity and (entity._profession or "unemployed")
					or "unloaded",
			})
			self._lovemaking = nil
			self._birth_time = nil
			return false
		end

		local t
		if self._birth_time then
			t = self._birth_time - dtime
			self._birth_time = t
		end

		if vector.distance (self_pos, mate_pos) > 2.5 then
			local initialized = not self:navigation_finished ()
			local continue, _, _
				= self:do_navigate (self_pos, dtime, mate_pos, 0.5,
							initialized, 2.0)
			if not continue then
				self._lovemaking = nil
				self._birth_time = nil
				return false
			end
		else
			if not self:navigation_finished () then
				self:cancel_navigation ()
				self:halt_in_tracks ()
			end
			self:look_at (mate_pos)
			if self._birth_time then
				-- Is it time to conceive?
				if t <= 0 then
					villager_log (table.concat {
						self._profession or "unemployed",
						" is about to conceive with ",
						entity._profession or "unemployed",
					})

					self:eat_before_breeding ()
					entity:eat_before_breeding ()
					self:digest_before_breeding ()
					entity:digest_before_breeding ()
					local beds = self:run_sensor (self_pos, "free_beds")
					if #beds >= 1 then
						if not self:conceive_child (entity, beds[1]) then
							self:angry_villager_effect ()
						end
					else
						self:angry_villager_effect ()
						entity:angry_villager_effect ()
					end
					self._lovemaking = nil
					entity._lovemaking = nil
					self._birth_time = nil
					return false
				elseif pr:next (1, 45) == 1 then
					mcl_mobs.effect (vector.offset (self_pos, 0, 1.7, 0),
						5, "heart.png", 2, 4, 2.0, 0.1)
					mcl_mobs.effect (vector.offset (mate_pos, 0, 1.7, 0),
						5, "heart.png", 2, 4, 2.0, 0.1)
				end
			end
		end

		return true
	elseif not self.child and pr:next (1, 120) == 1
		and self:check_timer ("breeding", 1.0)
		and self:breeding_possible () then
		local mate = self:run_sensor (self_pos, "mate")

		if mate then
			local mate_pos = mate:get_pos ()
			if self:do_navigate (self_pos, dtime, mate_pos, 0.5, false, 2.0) then
				local entity = mate:get_luaentity ()
				if not entity:begin_lovemaking (self.object, dtime) then
					self:cancel_navigation ()
					return false
				end

				self._lovemaking = mate
				self._birth_time
					= pr:next (275, 325) / 20
				villager_log (table.concat {
					self._profession or "unemployed",
					" begins breeding with ",
					entity._profession or "unemployed",
				})
				return "_lovemaking"
			end
		end
	end
	return false
end

function villager:begin_lovemaking (object, dtime)
	local obj_pos = object:get_pos ()
	local self_pos = self.object:get_pos ()

	if self:do_navigate (self_pos, dtime, obj_pos, 0.5, false) then
		self._lovemaking = object
		self._birth_time = nil
		self:replace_activity ("_lovemaking")
		return true
	end
	return false
end

function villager:answer_raid (self_pos, dtime)
	if self:check_timer ("answer_raid", 1.0)
		and self._special_schedule ~= "PANIC" then
		local raid = self:run_sensor (self_pos, "active_raid")
		if raid then
			local new_schedule
			if raid.status ~= "ongoing"
				or mcl_raids.is_wave_active (raid) then
				new_schedule = "RAID"
			else
				new_schedule = "PRE_RAID"
			end
			if new_schedule ~= self._special_schedule then
				self._special_schedule = new_schedule
				self._interaction_target = nil
				self._breed_target = nil
				self:replace_activity (nil)
			end
		end
	end
end

function villager:reset_raid (self_pos, dtime)
	if not self:run_sensor (self_pos, "active_raid") then
		self._special_schedule = nil
	end
end

function villager:ring_bell (self_pos, dtime)
	local chance = scale_chance (95, dtime)
	if self._bell and pr:next (1, chance) == 1 then
		local distance
			= vector.distance (self_pos, self._bell)
		-- 3.0 in Minecraft...
		if distance < 6.0 then
			local node = core.get_node (self._bell)
			if core.get_item_group (node.name, "bell") >= 1 then
				mcl_bells.ring_once (self._bell)
			end
		end
	end
end

function villager:visit_bell_for_raid (self_pos, dtime)
	if self._visiting_bell_for_raid then
		local job_site = self._bell
		if job_site and self:do_navigate (self_pos, dtime, job_site,
						0.75, true, 6.0) then
			return true
		end
		self._visiting_bell_for_raid = false
		return false
	elseif not self._pacing_around_poi
		and self._bell
		and manhattan3d (self, self_pos, self._bell) >= 10
		and pr:next (1, 6) == 1
		and self:do_navigate (self_pos, dtime, self._bell,
			0.75, false, 6.0) then
		self._visiting_bell_for_raid = true
		return "_visiting_bell_for_raid"
	end
end

-- Frantically run about in the near vicinity.
villager.run_around_village
	= generate_pace_around_village ("_run_around_village", 0.75, 2, 2, true)

-- TODO: launch fireworks after moving into the open.

function villager:raid_was_defeated (self_pos)
	local raid = self:run_sensor (self_pos, "active_raid")
	return raid and raid.status == "victory"
end

villager.pace_triumphant
	= generate_pace_around_village ("_pace_triumphant", 0.55, 10, 7, true,
				        villager.raid_was_defeated)

function villager:locate_cover_fast (self_pos, dtime)
	if self._moving_to_cover_fast then
		local hideout = self._moving_to_cover_fast
		local continue, _, dist
			= self:do_navigate (self_pos, dtime, hideout, 0.7, true)
		if continue then
			return true
		end

		if dist <= 2.0 then
			local t = self._time_passed_by_cover + dtime
			self._time_passed_by_cover = t

			if t >= 15 then
				self._moving_to_cover_fast = nil
				return false
			end
		elseif self:check_timer ("hideout_resume", 0.5) then
			-- Attempt to return to the hideout.
			self:do_navigate (self_pos, dtime, hideout, 0.7, false)
		end

		return true
	else
		local raid = self:run_sensor (self_pos, "active_raid")
		if raid and raid.status == "ongoing" then
			local hideout = self:run_sensor (self_pos, "nearby_hideout")
			if hideout and self:do_navigate (self_pos, dtime,
						hideout, 0.7, false) then
				self._moving_to_cover_fast = hideout
				self._time_passed_by_cover = 0.0
				return "_moving_to_cover_fast"
			end
		end

		return false
	end
end

villager.wander_to_bell
	= generate_wander_to ("_bell", "_wander_to_bell", "_bell_wander_time", 45, 100,
			      6, villager.relinquish_bell, function (self)
				      return not self._visiting_wanted_item
			      end)

function villager:locate_cover (self_pos, dtime)
	-- Time out after two minutes.
	local gametime = core.get_gametime ()
	if gametime - self._last_alarm_gmt > 120 then
		self._moving_to_cover = false
		self._special_schedule = nil
		return false
	end

	if self._moving_to_cover then
		local hideout = self._moving_to_cover
		local continue, _, dist
			= self:do_navigate (self_pos, dtime, hideout, 0.6, true)
		if continue then
			return true
		end

		if dist <= 2.0 then
			local t = self._time_passed_by_cover + dtime
			self._time_passed_by_cover = t

			if t >= 15 then
				self._special_schedule = nil
				self._moving_to_cover = nil
				return false
			end
		elseif self:check_timer ("hideout_resume", 0.5) then
			-- Attempt to return to the hideout.
			self:do_navigate (self_pos, dtime, hideout, 0.6, false)
		end

		return true
	else
		local hideout = self:run_sensor (self_pos, "nearby_hideout")
		if hideout and self:do_navigate (self_pos, dtime, hideout, 0.6, false) then
			self._moving_to_cover = hideout
			self._time_passed_by_cover = 0.0
			return "_moving_to_cover"
		end

		return false
	end
end

function villager:calm_down (self_pos, dtime)
	if not self._panic_time
		and not self._panic_source
		and not self:seen_hostile_lately (self_pos) then
		self._special_schedule = nil
	elseif self:check_timer ("golem_summon", 5.0) then
		self:maybe_summon_golem (self_pos, 3)
	end
end

function villager:avoid_hostiles (self_pos, dtime)
	local hostile = self._avoiding_hostile
	if hostile then
		if not is_valid (hostile) then
			self._avoiding_hostile = nil
			return false
		end

		local target = self._avoid_target
		if self:do_navigate (self_pos, dtime, target, 0.75, true) then
			return true
		end
		self._avoiding_hostile = nil
		return false
	else
		local hostile = self._panic_source
			or self:run_sensor (self_pos, "nearest_hostile")
		if hostile then
			local hostile_pos = hostile:get_pos ()
			if vector.distance (self_pos, hostile_pos) > 6.0 then
				return false
			end
			local target = self:target_away_from (self_pos, hostile_pos)
			if target and self:do_navigate (self_pos, dtime, target,
							0.75, false) then
				self._avoid_target = target
				self._avoiding_hostile = hostile
				return "_avoiding_hostile"
			end
		end
		return false
	end
end

villager.panic = generate_pace_around_village ("_panicking", 0.75, 2, 2, true)

function villager:on_deactivate (removal)
	if removal then
		self:relinquish_pois ()
	end
	mob_class.on_deactivate (self, removal)
end

------------------------------------------------------------------------
-- Villager schedules and AI mechanics.
------------------------------------------------------------------------

local SYNCHRONOUS_BASE_PRIORITY = 50

local function get_schedule_items_core (self, list)
	table.insert (list, { 0, self.start_panic, false, })
	table.insert (list, { 0, self.answer_bell, false, })
	table.insert (list, { 0, self.answer_raid, false, })
	table.insert (list, { 0, self.validate_job_sites, false, })
	table.insert (list, { 0, self.check_wake_up, false, })
	table.insert (list, { 0, self.detect_golem, false, })
	table.insert (list, { 1, self.interact_with_customer, true, })
	table.insert (list, { 5, self.visit_wanted_item, true, })
	table.insert (list, { 2, self.acquire_job_site, true, })
	table.insert (list, { 10, self.acquire_bed, false, })
	table.insert (list, { 10, self.acquire_bell, false, })
end

local function get_schedule_items_sleep (self, list)
	table.insert (list, { 10, self.clear_wielditem, false, })
	table.insert (list, { 2, self.wander_home, true, })
	table.insert (list, { 3, self.sleep, true, })
	table.insert (list, { 5, self.find_a_home, true, })
	table.insert (list, { 5, self.shuffle_indoors, true, })
	table.insert (list, { 5, self.return_to_village, true, })
	table.insert (list, { 6, self.village_aware_pacing, true, })
end

local function get_schedule_items_work (self, list)
	table.insert (list, { 2, self.wander_to_job_site, true, })
	table.insert (list, { 3, self.salute_hero, true, })
	table.insert (list, { 5, self.dispatch_work, true, })
	table.insert (list, { 10, self.gaze_at_player, false, })
	table.insert (list, { 10, self.preview_trades, false, })
end

local function get_schedule_items_play (self, list)
	table.insert (list, { 5, self.play_tag, true, })
	table.insert (list, { 5, self.interact_with, true, })
	table.insert (list, { 5, self.pace_around_village, true, })
	table.insert (list, { 5, self.bounce_on_bed, true, })
end

local function get_schedule_items_socialize (self, list)
	table.insert (list, { 2, self.pace_around_bell, true, })
	table.insert (list, { 2, self.socialize_at_bell, true, })
	table.insert (list, { 3, self.salute_hero, true, })
	table.insert (list, { 3, self.wander_to_bell, true, })
	table.insert (list, { 3, self.gossip_and_trade, true, })
	table.insert (list, { 10, self.gaze_at_player, false, })
	table.insert (list, { 10, self.preview_trades, false, })
end

local function get_schedule_items_idle (self, list)
	table.insert (list, { 2, self.make_love, true, })
	table.insert (list, { 2, self.salute_hero, true, })
	table.insert (list, { 2, self.interact_with, true, })
	table.insert (list, { 2, self.gossip_and_trade, true, })
	table.insert (list, { 2, self.pace_around_village, true, })
	table.insert (list, { 2, self.bounce_on_bed, true, })
	table.insert (list, { 3, self.gaze_at_player, false, })
	table.insert (list, { 3, self.preview_trades, false, })
end

local function get_schedule_items_before_raid (self, list)
	table.insert (list, { 10, self.clear_wielditem, false, })
	table.insert (list, { 11, self.ring_bell, false, })
	table.insert (list, { 99, self.reset_raid, false, })
	table.insert (list, { 0, self.visit_bell_for_raid, true, })
	table.insert (list, { 0, self.run_around_village, true, })
end

local function get_schedule_items_during_raid (self, list)
	table.insert (list, { 10, self.clear_wielditem, false, })
	table.insert (list, { 99, self.reset_raid, false, })
	table.insert (list, { 0, self.pace_triumphant, true, })
	table.insert (list, { 1, self.locate_cover_fast, true, })
end

local function get_schedule_items_bell_rang (self, list)
	table.insert (list, { 10, self.clear_wielditem, false, })
	table.insert (list, { 1, self.locate_cover, true, })
end

local function get_schedule_items_panic (self, list)
	table.insert (list, { 10, self.clear_wielditem, false, })
	table.insert (list, { 0, self.calm_down, false, })
	table.insert (list, { 1, self.avoid_hostiles, true, })
	table.insert (list, { 3, self.panic, true, })
end

villager.ai_functions = {}
villager._child_schedule = {
	{ 10,		get_schedule_items_idle,	"IDLE",		},
	{ 3000,		get_schedule_items_play,	"PLAY",		},
	{ 6000,		get_schedule_items_idle,	"IDLE",		},
	{ 10000,	get_schedule_items_play,	"PLAY",		},
	{ 12000,	get_schedule_items_sleep,	"SLEEP",	},
}
villager._schedule = {
	{ 10,		get_schedule_items_idle,	"IDLE",		},
	{ 3000,		get_schedule_items_work,	"WORK",		},
	{ 6000,		get_schedule_items_socialize,	"SOCIALIZE",	},
	{ 10000,	get_schedule_items_idle,	"IDLE",		},
	{ 12000,	get_schedule_items_sleep,	"SLEEP",	},
}
villager._special_schedules = {
	PANIC = get_schedule_items_panic,
	PRE_RAID = get_schedule_items_before_raid,
	RAID = get_schedule_items_during_raid,
	BELL_RANG = get_schedule_items_bell_rang,
}

local function compare_by_priority (a, b)
	local sync_a = a[3] and SYNCHRONOUS_BASE_PRIORITY or 0
	local sync_b = b[3] and SYNCHRONOUS_BASE_PRIORITY or 0
	return a[1] + sync_a < b[1] + sync_b
end

function villager:get_staticdata_table ()
	local supertable = villager_base.get_staticdata_table (self)
	if supertable then
		supertable.ai_functions = nil
		supertable._schedule_name = nil
		supertable._retry_counters = nil
		supertable._sensing = nil
		supertable._seen_hostile = nil
		supertable._work_dispatch_table = nil
		supertable._work_active_activity = nil
		supertable._work_active_function = nil
		supertable._seen_hostile = nil
		supertable._head_nod_timeout = nil
		supertable._wielditem = nil
		supertable._player_wielditem = nil
		supertable._displayed_trades = nil
		supertable._wielditem_timer = nil
		supertable._near_map_boundaries = nil

		if supertable._trades then
			-- It is possible for supertable._trade not to
			-- be a table, if this is a mob that has still
			-- to be converted.
			if type (supertable._trades) == "table" then
				supertable._trades = table.copy (supertable._trades)
				for i, trade in ipairs (supertable._trades) do
					-- Remove player-specific pricing data.
					supertable._trades[i].special_price_diff = 0
				end
			end
		end
	end
	return supertable
end

local stable_sort = table.stable_sort

function villager:schedule ()
	local tod = core.get_timeofday () * 24000
	local minecraft_tod
		= (tod - 6000 + self._stagger_schedules_by) % 24000
	local ai_functions = {}
	local schedule_function = get_schedule_items_idle
	local schedule_name = "NONE"

	if self._special_schedule then
		schedule_name
			= self._special_schedule
		schedule_function
			= self._special_schedules[self._special_schedule]
		assert (schedule_function)
	else
		local list = not self.child
			and self._schedule or self._child_schedule
		for _, item in ipairs (list) do
			local tod = item[1]
			if tod <= minecraft_tod then
				schedule_function = item[2]
				schedule_name = item[3]
			else
				break
			end
		end
	end

	if schedule_name == self._schedule_name then
		return
	end

	self._stagger_schedules_by = pr:next (-10, 10)
	self._tod = tod
	self._last_schedule_function = schedule_function
	self._schedule_name = schedule_name
	get_schedule_items_core (self, ai_functions)
	schedule_function (self, ai_functions)
	stable_sort (ai_functions, compare_by_priority)
	for i, item in ipairs (ai_functions) do
		assert (item[2])
		ai_functions[i] = item[2]
	end
	self.ai_functions = ai_functions
end

function villager:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	local self_pos = self.object:get_pos ()

	if self._interaction_target
		and not is_valid (self._interaction_target) then
		self._interaction_target = nil
	elseif self._interaction_target then
		local pos = self._interaction_target:get_pos ()
		if vector.distance (pos, self_pos) >= self.view_range
			or not self:target_visible (self_pos, self._interaction_target) then
			self._interaction_target = nil
		end
	end

	if self._panic_source then
		local pos = self._panic_source:get_pos ()
		if not pos or vector.distance (pos, self_pos) > 6.0 then
			self._panic_source = nil
		end
	end

	if self._panic_time then
		local t = self._panic_time - dtime
		if t <= 0 then
			t = nil
		end
		self._panic_time = t
	end

	if self._seen_hostile then
		local t = self._seen_hostile[1] - dtime
		if t <= 0 then
			self._seen_hostile = nil
		else
			self._seen_hostile[1] = t
		end
	end

	if self._bone_meal_cooldown then
		local t = self._bone_meal_cooldown - dtime
		if t <= 0 then
			t = nil
		end
		self._bone_meal_cooldown = t
	end

	if self._levelup_in > 0.0 then
		local t = self._levelup_in - dtime
		if t <= 0 then
			self:level_up ()
		end
		self._levelup_in = t
	end

	if self._hero_cooldown then
		local t = self._hero_cooldown - dtime
		if t <= 0 then
			t = nil
		end
		self._hero_cooldown = t
	end

	local chance = scale_chance (100, dtime)
	if pr:next (1, chance) == 1 then
		local raid = self:run_sensor (self_pos, "active_raid")
		if raid and raid.status == "ongoing" then
			self:terrified_villager_effect ()
		end
	end

	self._near_map_boundaries = nil
	self:tick_retry (dtime)
	self:decay_gossips ()
end

function villager:step_sensing (dtime)
	for key, value in pairs (self._sensing) do
		local t = value[1] - dtime
		if t <= 0 then
			self._sensing[key] = nil
		else
			value[1] = t
		end
	end
end

function villager:run_ai (dtime, moveresult)
	self:step_sensing (dtime)
	local self_pos = self.object:get_pos ()
	self._compare_distance = function (a, b)
		local d1 = vector.distance (a, self_pos)
		local d2 = vector.distance (b, self_pos)
		return d1 < d2
	end
	self._compare_object_distance = function (a, b)
		local d1 = vector.distance (a:get_pos (), self_pos)
		local d2 = vector.distance (b:get_pos (), self_pos)
		return d1 < d2
	end
	mob_class.run_ai (self, dtime, moveresult)
	self:schedule ()

	if villager_debug then
		self:apply_debug_nametag ()
	end
end

function villager:apply_debug_nametag ()
	local info = {}
	table.insert (info, self.description)
	if self._tod then
		table.insert (info, string.format ("Current schedule (%s): ",
						   math.floor (self._tod)))
		table.insert (info, self._schedule_name or "NONE")
	end
	table.insert (info, "Active activity: ")
	table.insert (info, self._active_activity or "NONE")

	if self._active_activity then
		table.insert (info, "  :" .. tostring (self[self._active_activity]))
	end
	if self._home then
		table.insert (info, "Home: " .. vector.to_string (self._home))
	end
	if self._job_site then
		table.insert (info, "Job site: " .. vector.to_string (self._job_site))
	end
	if self._bell then
		table.insert (info, "Bell: " .. vector.to_string (self._bell))
	end

	for player, rep in pairs (self._reputation) do
		table.insert (info, string.format ("  %s: %d", player, rep))
	end

	self.object:set_nametag_attributes ({
		text = table.concat (info, "\n")
	})
end

function villager:abandon_for (counter, time)
	self._retry_counters[counter] = {
		delay = time,
		previous = time,
	}
end

function villager:process_retry_attempt (counter)
	local info = self._retry_counters[counter]
	local current = info and info.previous or 0
	local new = math.min (current + (pr:next (0, 40) + 40) / 20, 20)
	self._retry_counters[counter] = {
		delay = new,
		previous = new,
	}
	return
end

function villager:should_retry (counter)
	local info = self._retry_counters[counter]
	return not info or info.delay <= 0
end

function villager:tick_retry (dtime)
	local list = self._retry_counters
	for k, v in pairs (list) do
		v.delay = v.delay - dtime

		if v.delay < -500 then
			list[k] = nil
		end
	end
end

function villager:init_ai ()
	mob_class.init_ai (self)
	self._retry_counters = {}
	self._sensing = {}
	self._schedule_name = nil
	self._acquiring_job_site = nil
	self._finding_a_home = nil
	self._shuffling_indoors = nil
	self._returning_to_village = nil
	self._working_at_job_site = nil
	self._pacing_around_poi = nil
	self._visiting_job_site = nil
	self._interacting_with = nil
	self._visiting_bell = nil
	self._visiting_bell_for_raid = nil
	self._moving_to_cover = nil
	self._moving_to_cover_fast = nil
	self._pace_triumphant = nil
	self._run_around_village = nil
	self._pacing_around_poi = nil
	self._socializing_at_bell = nil
	self._avoiding_hostile = nil
	self._village_aware_pacing = nil
	self._villager_sleeping = nil
	self._farming = nil
	self._moving_to_farmland = nil
	self._fertilizing_farmland = nil
	self._gossiping = false
	self._seen_hostile = nil
	self._lovemaking = nil
	self._playing_tag = nil
	self._entertaining_customer = nil
	self._visiting_wanted_item = nil
	self._saluting_hero = nil
	self._stagger_schedules_by = pr:next (0, 60)
	self:schedule ()
end

------------------------------------------------------------------------
-- Villager pathfinding.
------------------------------------------------------------------------

-- Many village buildings in mcl are generated with spaces comprising
-- two nodes' worth of clearance formed by a pair of slabs or slablike
-- blocks.  In order to navigate these passageways, villagers
-- specifically depart from Minecraft pathfinding behavior by
-- accounting for walkable spaces formed by a pair of lower and upper
-- slabs, disabling this classic mob trap.

local gwp_basic_node_classes = mcl_mobs.gwp_basic_node_classes
local gwp_classify_node_1 = mcl_mobs.gwp_classify_node_1
local gwp_get_node = mcl_mobs.gwp_get_node
local hashpos = mcl_mobs.gwp_hashpos

local is_top_slab = {}
local is_bottom_slab = {}

core.register_on_mods_loaded (function ()
	for name, _ in pairs (core.registered_nodes) do
		local value = mcl_mobs.gwp_name_to_nodevalue (name)
		if core.get_item_group(name, "slab_top") > 0 then
			is_top_slab[value] = true
		elseif core.get_item_group(name, "slab") > 0 or core.get_item_group(name, "bed") > 0 then
			is_bottom_slab[value] = true
		end
	end
end)

local function is_pos_top_slab_or_open (pos)
	local node = gwp_get_node (pos)
	return is_top_slab[node]
		or gwp_basic_node_classes[node] == "OPEN"
end

local function is_pos_below_bottom_slab (pos)
	pos.y = pos.y - 2
	local node = gwp_get_node (pos)
	return is_bottom_slab[node]
end

local function is_pos_bottom_slab (pos)
	local node = gwp_get_node (pos)
	return is_bottom_slab[node]
end

local GWP_JUMP_HEIGHT = 1.125

function villager:gwp_essay_jump (context, target, parent, floor)
	if context.mob_height > 1 then
		-- If the target is a SLAB, the distance between the
		-- top of the SLAB and the ground height of the parent
		-- node must not exceed the maximum jump height.
		--
		-- If the parent is also a slab, the said ground
		-- height may be incremented by 0.5.

		if is_pos_bottom_slab (parent) then
			floor = floor + 0.5
		end
		if is_pos_bottom_slab (target)
			and target.y - floor > GWP_JUMP_HEIGHT then
			return nil
		end
	end
	return mob_class.gwp_essay_jump (self, context, target, parent, floor)
end

local gwp_classify_node_scratch = vector.zero ()

function villager:gwp_classify_node (context, pos)
	local hash = hashpos (context, pos.x, pos.y, pos.z)
	local cache = context.class_cache[hash]

	-- This is very expensive, as core.get_node conses too
	-- much.
	if cache then
		return cache
	end

	local x, y, z = pos.x, pos.y, pos.z
	local vector = gwp_classify_node_scratch
	local penalties = self.gwp_penalties
	local b_height = context.mob_height - 1

	vector.x = x
	vector.y = y
	vector.z = z

	if b_height == 0 then
		cache = gwp_classify_node_1 (self, pos)
	else
		local class = gwp_classify_node_1 (self, vector)
		if penalties[class] < 0.0 and class ~= "SLAB" then
			cache = class
		else
			cache = class

			-- Classify the node above.
			vector.y = y + 1
			local class_1 = gwp_classify_node_1 (self, vector)

			-- Is this air?  If the surface is a bottom
			-- slab with an air node above, it is perhaps
			-- walkable if the node above the air is open
			-- or a matching top slab.
			if class == "SLAB" and class_1 == "WALKABLE" then
				vector.y = y + 2
				local is_top = is_pos_top_slab_or_open (vector)

				if is_top then
					cache = "WALKABLE"
				end
			-- To enable mobs to ``descend'' from a
			-- walkable surface composed of a slab into a
			-- walkable slab created by the condition
			-- above, classify nodes above such slabs as
			-- drops, if a mob actually at the position of
			-- this drop would not be obstructed.
			elseif class == "WALKABLE" and class_1 == "OPEN"
				and is_pos_below_bottom_slab (vector) then
				cache = "OPEN"
			elseif penalties[class] >= 0.0
				and (penalties[class_1] > penalties[class]
					or penalties[class_1] < 0.0) then
				cache = class_1
			end
		end
	end

	context.class_cache[hash] = cache
	return cache
end

function villager:gwp_align_start_pos (pos)
	local nodepos = mcl_util.get_nodepos (pos)
	local is_bottom_slab = is_pos_bottom_slab (pos)

	if not self.child and is_bottom_slab then
		return nodepos
	else
		local offset = vector.offset (pos, 0.5, 1.0, 0.5)
		return vector.apply (offset, math.floor)
	end
end

local function check_slab (self, node)
	if not self.child and is_pos_bottom_slab (node) then
		return 0
	end
	return nil
end

function villager:gwp_reconstruct_path (context, arrival)
	local list = {arrival}
	-- Adjust waypoint position so as to center the mob on the
	-- path.  Account for "walkable" slab nodes generated to
	-- enable navigation in certain village buildings.
	local x_offset = context.mob_width * 0.5 - 0.5
	local y_offset = check_slab (self, arrival) or context.y_offset
	arrival.x = arrival.x + x_offset
	arrival.z = arrival.z + x_offset
	arrival.y = arrival.y + y_offset
	arrival.x_offset = x_offset
	arrival.y_offset = y_offset
	while arrival.referrer ~= nil do
		table.insert (list, arrival.referrer)
		arrival = arrival.referrer
		-- Adjust waypoint position so as to center the mob on
		-- the path.
		y_offset = check_slab (self, arrival)
			or context.y_offset
		arrival.x = arrival.x + x_offset
		arrival.z = arrival.z + x_offset
		arrival.y = arrival.y + y_offset
		arrival.x_offset = x_offset
		arrival.y_offset = y_offset
	end
	return list
end

------------------------------------------------------------------------
-- Upgrading old villagers.
------------------------------------------------------------------------

local function is_old_trade_list (trades)
	return type (trades) ~= "table"
end

function villager:claim_poi_for_upgrade (old_jobsite)
	local poi = mcl_villages.get_poi (old_jobsite)
	if poi and poi.data ~= "mcl_villages:provisional_poi" then
		local template = {
			"[mobs_mc] Failed to upgrade work site of old ",
			self._profession or "unemployed",
			" at ",
			vector.to_string (old_jobsite),
			" as it has already been claimed.",
		}
		core.log ("warning", table.concat (template))
	else
		-- Verify that this mob's profession matches the poi
		-- block type before laying claim to the POI.
		local node = core.get_node (old_jobsite)
		local profession = get_profession (node.name)
		if not profession or (node.name ~= "ignore"
				      and profession.name ~= self._profession) then
			local template = {
				"[mobs_mc] The type of the work site ",
				vector.to_string (old_jobsite),
				" belonging to an old ",
				self._profession or "unemployed",
				" has changed and it could not be reclaimed.",
			}
			core.log ("warning", table.concat (template))
		else
			-- If a provisional POI exists now (as when a new
			-- villager has decided to attempt to claim it),
			-- delete it.
			if poi then
				mcl_villages.remove_poi (poi.id)
			end
			if mcl_villages.insert_poi (old_jobsite, profession.poi) then
				self._job_site = old_jobsite
				self._jobsite = nil
				self._wander_time = 0
			end
		end
	end
end

local function identify_bottom_piece_of_bed (old_bed)
	local node = core.get_node (old_bed)
	if node.name == "ignore" then
		-- Assume that this was a bottom piece.
		return old_bed
	elseif core.get_item_group (node.name, "bed") == 1 then
		return old_bed
	elseif core.get_item_group (node.name, "bed") == 2 then
		local dir = core.facedir_to_dir (node.param2)
		local bottom_piece = vector.subtract (old_bed, dir)
		local node1 = core.get_node (bottom_piece)
		if core.get_item_group (node1.name, "bed") == 1 then
			return bottom_piece
		end
	end
	return nil
end

function villager:claim_home_for_upgrade (old_bed)
	local bottom = identify_bottom_piece_of_bed (old_bed)
	if not bottom then
		local template = {
			"[mobs_mc] An old ",
			self._profession or "unemployed",
			"'s bed disappeared while being upgraded",
		}
		core.log ("warning", table.concat (template))
		return
	end

	local poi = mcl_villages.get_poi (bottom)
	if poi then
		local template = {
			"[mobs_mc] Failed to upgrade bed of old ",
			self._profession or "unemployed",
			" at ",
			vector.to_string (bottom),
			" as it has already been claimed",
		}
		core.log ("warning", table.concat (template))
	else
		self:claim_home (bottom)
		self._bed = nil
	end
end

local function search_upward_for_bell (bell_pos)
	-- If this is an ignore node, assume that the bell is two
	-- nodes above the old _bell field.
	local data = core.get_node (bell_pos)
	if data.name == "ignore" then
		return vector.offset (bell_pos, 0, 2, 0)
	end

	for i = 0, 8 do
		local node = vector.offset (bell_pos, 0, i, 0)
		if core.get_item_group (core.get_node (node).name, "bell") > 0 then
			return node
		end
	end
	return nil
end

function villager:claim_bell_for_upgrade (old_bell)
	local old_bell = search_upward_for_bell (old_bell)
	if not old_bell then
		local template = {
			"[mobs_mc] Bell claimed by old ",
			self._profession or "unemployed",
			" at ",
			old_bell and vector.to_string (old_bell)
				or "(unknown)",
			" vanished prior to upgrade.",
		}
		core.log ("warning", table.concat (template))
	else
		-- Don't limit the number of users coming from an
		-- upgrade.
		if not acquire_bell (old_bell, math.huge) then
			self._bell = nil
		end
	end
end

local function convert_old_trades (tradestring, tier)
	if type (tradestring) ~= "string" then
		return {}
	end
	local trades = core.deserialize (tradestring)
	local new_trades = {}
	for _, trade in ipairs (trades) do
		-- Limit these trades to those belonging to the
		-- current tier.
		if trade.tier <= tier then
			local trade_object = mobs_mc.make_villager_trade ({
				wanted1 = trade.wanted[1],
				wanted2 = trade.wanted[2] or "",
				offered = ItemStack (trade.offered):to_string (),
				uses = trade.trade_counter or 0,
				max_uses = trade.max_uses or 12,
				xp = trade.xp or 1,
				reward_xp = true,
				price_multiplier = DEFAULT_PRICE_MULTIPLIER,
				tier = trade.tier,
			})
			table.insert (new_trades, trade_object)
		end
	end
	return new_trades
end

function villager:post_load_staticdata ()
	mob_class.post_load_staticdata (self)
	local is_old_villager
	-- Awful heuristic for detecting old villagers.
		= self._jobsite or self._bed or (self.state and self._bell)
		or is_old_trade_list (self._trades)
		or self._trading_players
		or self._locked_trades
		or self._max_trade_tier
		or self._profession == "unemployed"
		or self._profession == "tool_smith"
		or self._profession == "weapon_smith"

	if is_old_villager then
		if self._profession == "unemployed" then
			self._profession = nil
		elseif self._profession == "tool_smith" then
			self._profession = "toolsmith"
		elseif self._profession == "weapon_smith" then
			self._profession = "weaponsmith"
		end

		if self._jobsite
			and self._profession
			and self._profession ~= "nitwit" then
			self:claim_poi_for_upgrade (self._jobsite)
		end

		if self._bed then
			self:claim_home_for_upgrade (self._bed)
		end

		if self._bell then
			self:claim_bell_for_upgrade (self._bell)
		end

		if self._trade_xp then
			self._xp = self._trade_xp
			self._tier = MAX_TIER
			for i, threshold in ipairs (tier_thresholds) do
				if self._xp < threshold then
					self._tier = i - 1
					break
				end
			end
		end

		if self._trades then
			self._trades
				= convert_old_trades (self._trades, self._tier)
		end

		self._jobsite = nil
		self._bed = nil
		self.state = nil
		self._trading_players = nil
		self._locked_trades = nil
		self._max_trade_tier = nil
		self._trade_xp = nil
		self._id = nil

		-- Old villagers had `_child_animation' lists that are
		-- not appropriate now.
		self.animation = nil
	end
end

function villager:actionable_on_rightclick (player)
	return true
end

mcl_mobs.register_mob ("mobs_mc:villager", villager)

------------------------------------------------------------------------
-- Villager spawning.
------------------------------------------------------------------------

mcl_mobs.register_egg ("mobs_mc:villager", S("Villager"), "#563d33", "#bc8b72", 0)
