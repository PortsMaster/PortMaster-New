local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local F = minetest.formspec_escape

local player_tradenum = {}
local player_trading_with = {}

local COMPASS = "mcl_compass:compass"
if minetest.registered_aliases[COMPASS] then
	COMPASS = minetest.registered_aliases[COMPASS]
end

local tiernames = {
	S("Novice"),
	S("Apprentice"),
	S("Journeyman"),
	S("Expert"),
	S("Master")
}

local function move_stack(inv1, list1, inv2, list2, stack, pos)
	if stack and inv1:contains_item(list1, stack) and inv2:room_for_item(list2, stack) then
		return inv2:add_item(list2, inv1:remove_item(list1, stack))
	elseif pos and not inv2:room_for_item(list2, stack) then
		mcl_util.drop_item_stack(pos, stack)
		inv1:remove_item(list1, stack)
	end
end

local function move_index(inv1, list1, inv2, list2, index, pos)
	move_stack(inv1, list1, inv2, list2, inv1:get_stack(list1, index), pos)
end

function mobs_mc.villager_mob:update_max_tradenum()
	if not self._trades then
		return
	end
	local trades = minetest.deserialize(self._trades)
	for t=1, #trades do
		local trade = trades[t]
		if trade.tier > self._max_trade_tier then
			self._max_tradenum = t - 1
			return
		end
	end
	self._max_tradenum = #trades
end

function mobs_mc.villager_mob:init_trader_vars()
	if not self._max_trade_tier then
		self._max_trade_tier = 1
	end
	if not self._locked_trades then
		self._locked_trades = 0
	end
	if not self._trading_players then
		self._trading_players = {}
	end
end

function mobs_mc.villager_mob:init_trades(inv)
	local profession = mobs_mc.professions[self._profession]
	local trade_tiers = profession.trades
	if trade_tiers == nil then
		-- Empty trades
		self._trades = false
		return
	end

	local max_tier = #trade_tiers
	local trades = {}
	for tiernum=1, max_tier do
		local tier = trade_tiers[tiernum]
		for tradenum=1, #tier do
			local trade = tier[tradenum]
			local wanted1_item = trade[1][1]
			local wanted1_count = math.random(trade[1][2], trade[1][3])
			local offered_item = trade[2][1]
			local offered_count = math.random(trade[2][2], trade[2][3])

			local offered_stack = ItemStack({name = offered_item, count = offered_count})
			if mcl_enchanting.is_enchanted(offered_item) then
				if mcl_enchanting.is_book(offered_item) then
					offered_stack = mcl_enchanting.enchant_uniform_randomly(offered_stack, {"soul_speed"})
				else
					mcl_enchanting.enchant_randomly(offered_stack, math.random(5, 19), false, false, true)
					mcl_enchanting.unload_enchantments(offered_stack)
				end
			end

			local wanted = { wanted1_item .. " " ..wanted1_count }
			if trade[1][4] then
				local wanted2_item = trade[1][4]
				local wanted2_count = math.random(trade[1][5], trade[1][6])
				table.insert(wanted, wanted2_item .. " " ..wanted2_count)
			end

			table.insert(trades, {
				wanted = wanted,
				offered = offered_stack:to_table(),
				tier = tiernum, -- tier of this trade
				traded_once = false, -- true if trade was traded at least once
				trade_counter = 0, -- how often the this trade was mate after the last time it got unlocked
				locked = false, -- if this trade is locked. Locked trades can't be used
			})
		end
	end
	self._trades = minetest.serialize(trades)
	minetest.deserialize(self._trades)
end

function mobs_mc.villager_mob:set_trade(player, inv, concrete_tradenum)
	local trades = minetest.deserialize(self._trades)
	if not trades then
		self:init_trades()
		trades = minetest.deserialize(self._trades)
		if not trades then return end
	end
	local name = player:get_player_name()

	if concrete_tradenum > self._max_tradenum then
		concrete_tradenum = self._max_tradenum
	elseif concrete_tradenum < 1 then
		concrete_tradenum = 1
	end
	player_tradenum[name] = concrete_tradenum
	local trade = trades[concrete_tradenum]
	local wanted1 = ItemStack(trade.wanted[1])
	local wanted2 = ItemStack(trade.wanted[2])
	inv:set_stack("wanted", 1, wanted1)
	local offered = ItemStack(trade.offered)

	-- Only load enchantments for enchanted items; fixes unnecessary metadata being applied to regular items from villagers.
	if mcl_enchanting.is_enchanted(offered:get_name()) then
		mcl_enchanting.load_enchantments(offered)
	end
	inv:set_stack("offered", 1, offered)
	if trade.wanted[2] then
		inv:set_stack("wanted", 2, wanted2)
	else
		inv:set_stack("wanted", 2, "")
	end

	local plinv = player:get_inventory()
	local pos = player:get_pos()
	 move_index(inv, "input", plinv, "main", 1, pos)
	 move_index(inv, "input", plinv, "main", 2, pos)
	if wanted1 then
		move_stack(plinv, "main", inv, "input", wanted1)
	end
	if wanted2 then
		move_stack(plinv, "main", inv, "input", wanted2)
	end
end

-- Trade spec templates, some with args to use with string.format
-- arg 1 = %s = title
-- arg 2 = %i = scroller max val
local fs_header_template = [[
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

local fs_trade_diabled_template = [[
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

-- set to empty for 1 so no number shows
local function count_string(count)
	if count == 1 then
		count = ""
	end
	return count
end

local button_buffer = 0.65

function mobs_mc.villager_mob:show_trade_formspec(playername, tradenum)
	if not self._trades then
		return
	end
	if not tradenum then
		tradenum = 0
	end

	local tradeinv_name = "mobs_mc:trade_" .. playername
	local tradeinv = F("detached:" .. tradeinv_name)

	local profession = mobs_mc.professions[self._profession].name

	local inv = minetest.get_inventory({ type = "detached", name = "mobs_mc:trade_" .. playername })
	if not inv then
		return
	end

	player_trading_with[playername] = self

	local tiername = tiernames[self._max_trade_tier] or S("Master")

	local formspec = ""

	local last_tier = 0
	local h = 0.0
	local trade_str = ""

	for i, trade in pairs(minetest.deserialize(self._trades)) do
		local wanted1 = ItemStack(trade.wanted[1])
		local wanted2 = ItemStack(trade.wanted[2])
		local offered = ItemStack(trade.offered)

		if mcl_enchanting.is_enchanted(offered:get_name()) then
			mcl_enchanting.load_enchantments(offered)
		end

		local row_str = ""
		if last_tier ~= trade.tier then
			if trade.tier > self._max_trade_tier then
				break
			end

			last_tier = trade.tier
			h = h + 0.3
			row_str = string.format(fs_level_template, h, tiernames[trade.tier])
			h = h + 0.2
		end

		if i == tradenum then
			row_str = row_str .. fs_trade_pushed_template

			trade_str = string.format(
				fs_wants_template,
				wanted1:get_name(),
				F(wanted1:get_description()),
				count_string(wanted1:get_count())
			)

			if not wanted2:is_empty() then
				trade_str = trade_str
					.. string.format(
						fs_wants2_template,
						wanted2:get_name(),
						F(wanted2:get_description()),
						count_string(wanted2:get_count())
					)
			end

			trade_str = trade_str
				.. string.format(
					fs_offered_template,
					offered:get_name(),
					F(offered:get_description()),
					count_string(offered:get_count())
				)
		end

		row_str = row_str
			.. string.format(
				fs_trade_start_template,
				h,
				i,
				wanted1:get_name(),
				F(wanted1:get_description()),
				count_string(wanted1:get_count())
			)

		if not wanted2:is_empty() then
			row_str = row_str
				.. string.format(
					fs_trade_wants2_template,
					wanted2:get_name(),
					F(wanted2:get_description()),
					count_string(wanted2:get_count())
				)
		end

		if trade.locked then
			row_str = row_str .. fs_trade_diabled_template
		else
			row_str = row_str .. fs_trade_arrow_template
		end

		row_str = row_str
			.. string.format(
				fs_trade_end_template,
				offered:get_name(),
				F(offered:get_description()),
				count_string(offered:get_count())
			)

		if i == tradenum then
			row_str = row_str .. fs_trade_unpush_template
		end

		formspec = formspec .. row_str
		h = h + button_buffer
	end

	local header =
		string.format(fs_header_template, F(minetest.colorize("#313131", profession .. " - " .. tiername)), h * 10)

	formspec = header .. formspec .. fs_footer_template

	if trade_str ~= "" then
		formspec = formspec .. trade_str
			.. string.format(fs_footer_template2, tradeinv, tradeinv, tradeinv, tradeinv)
	end

	minetest.sound_play("mobs_mc_villager_trade", { to_player = playername, object = self.object }, true)
	minetest.show_formspec(playername, tradeinv_name, formspec)
end

local function update_offer(inv, player, sound)
	local name = player:get_player_name()
	local trader = player_trading_with[name]
	local tradenum = player_tradenum[name]
	if not trader or not tradenum then
		return false
	end
	local trades = minetest.deserialize(trader._trades)
	if not trades then
		return false
	end
	local trade = trades[tradenum]
	if not trade then
		return false
	end
	local wanted1, wanted2 = inv:get_stack("wanted", 1), inv:get_stack("wanted", 2)
	local input1, input2 = inv:get_stack("input", 1), inv:get_stack("input", 2)

	-- BEGIN OF SPECIAL HANDLING OF COMPASS
	-- TODO: Remove these check functions when compass and clock are implemented
	-- as single items.
	local function check_special(special_item, group, wanted1, wanted2, input1, input2)
		if minetest.registered_aliases[special_item] then
			special_item = minetest.registered_aliases[special_item]
		end
		if wanted1:get_name() == special_item then
			local function check_input(input, wanted, group)
				return minetest.get_item_group(input:get_name(), group) ~= 0 and input:get_count() >= wanted:get_count()
			end
			if check_input(input1, wanted1, group) then
				return true
			elseif check_input(input2, wanted1, group) then
				return true
			else
				return false
			end
		end
		return false
	end
	-- Apply above function to all items which we consider special.
	-- This function succeeds if ANY item check succeeds.
	local function check_specials(wanted1, wanted2, input1, input2)
		return check_special(COMPASS, "compass", wanted1, wanted2, input1, input2)
	end
	-- END OF SPECIAL HANDLING OF COMPASS

	if (
			((inv:contains_item("input", wanted1) and
			(wanted2:is_empty() or inv:contains_item("input", wanted2))) or
			-- BEGIN OF SPECIAL HANDLING OF COMPASS
			check_specials(wanted1, wanted2, input1, input2)) and
			-- END OF SPECIAL HANDLING OF COMPASS
			(trade.locked == false)) then
		inv:set_stack("output", 1, inv:get_stack("offered", 1))
		if sound then
			minetest.sound_play("mobs_mc_villager_accept", {to_player = name,object=trader.object}, true)
		end
		return true
	else
		inv:set_stack("output", 1, ItemStack(""))
		if sound then
			minetest.sound_play("mobs_mc_villager_deny", {to_player = name,object=trader.object}, true)
		end
		return false
	end
end

-- Returns a single itemstack in the given inventory to the player's main inventory, or drop it when there's no space left
local function return_item(itemstack, dropper, pos, inv_p)
	if dropper:is_player() then
		-- Return to main inventory
		if inv_p:room_for_item("main", itemstack) then
			inv_p:add_item("main", itemstack)
		else
			-- Drop item on the ground
			local v = dropper:get_look_dir()
			local p = {x=pos.x, y=pos.y+1.2, z=pos.z}
			p.x = p.x+(math.random(1,3)*0.2)
			p.z = p.z+(math.random(1,3)*0.2)
			local obj = minetest.add_item(p, itemstack)
			if obj then
				v.x = v.x*4
				v.y = v.y*4 + 2
				v.z = v.z*4
				obj:set_velocity(v)
				obj:get_luaentity()._insta_collect = false
			end
		end
	else
		-- Fallback for unexpected cases
		minetest.add_item(pos, itemstack)
	end
	return itemstack
end

function mobs_mc.villager.return_fields(player)
	local name = player:get_player_name()
	local inv_t = minetest.get_inventory({type="detached", name = "mobs_mc:trade_"..name})
	local inv_p = player:get_inventory()
	if not inv_t or not inv_p then
		return
	end
	for i=1, inv_t:get_size("input") do
		local stack = inv_t:get_stack("input", i)
		return_item(stack, player, player:get_pos(), inv_p)
		stack:clear()
		inv_t:set_stack("input", i, stack)
	end
	inv_t:set_stack("output", 1, "")
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if string.sub(formname, 1, 14) == "mobs_mc:trade_" then
		local name = player:get_player_name()
		if fields.quit then
			-- Get input items back
			mobs_mc.villager.return_fields(player)
			-- Reset internal "trading with" state
			local trader = player_trading_with[name]
			if trader then
				trader._trading_players[name] = nil
			end
			player_trading_with[name] = nil
		else
			local trader = player_trading_with[name]
			if not trader or not trader.object:get_luaentity() then
				return
			end
			local trades = trader._trades
			if not trades then
				return
			end
			local inv = minetest.get_inventory({type="detached", name="mobs_mc:trade_"..name})
			if not inv then
				return
			end
			for i, trade in pairs(minetest.deserialize(trader._trades)) do
				if fields["trade_" .. i] then
					trader:set_trade(player, inv, i)
					update_offer(inv, player, false)
					trader:show_trade_formspec(name, i)
					break
				end
			end
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	mobs_mc.villager.return_fields(player)
	player_tradenum[name] = nil
	local trader = player_trading_with[name]
	if trader then
		trader._trading_players[name] = nil
	end
	player_trading_with[name] = nil

end)

-- Return true if player is trading with villager, and the villager entity exists
local function trader_exists(playername)
	local trader = player_trading_with[playername]
	return trader ~= nil and trader.object:get_luaentity() ~= nil
end

local trade_inventory = {
	allow_take = function(inv, listname, index, stack, player)
		if listname == "input" then
			return stack:get_count()
		elseif listname == "output" then
			if not trader_exists(player:get_player_name()) then
				return 0
			-- Begin Award Code
			-- May need to be moved if award gets unlocked in the wrong cases.
			elseif trader_exists(player:get_player_name()) then
				awards.unlock(player:get_player_name(), "mcl:whatAdeal")
			-- End Award Code
			end
			-- Only allow taking full stack
			local count = stack:get_count()
			if count == inv:get_stack(listname, index):get_count() then
				-- Also update output stack again.
				-- If input has double the wanted items, the
				-- output will stay because there will be still
				-- enough items in input after the trade
				local wanted1 = inv:get_stack("wanted", 1)
				local wanted2 = inv:get_stack("wanted", 2)
				local input1 = inv:get_stack("input", 1)
				local input2 = inv:get_stack("input", 2)
				wanted1:set_count(wanted1:get_count()*2)
				wanted2:set_count(wanted2:get_count()*2)
				-- BEGIN OF SPECIAL HANDLING FOR COMPASS
				local function special_checks(wanted1, input1, input2)
					if wanted1:get_name() == COMPASS then
						local compasses = 0
						if (minetest.get_item_group(input1:get_name(), "compass") ~= 0) then
							compasses = compasses + input1:get_count()
						end
						if (minetest.get_item_group(input2:get_name(), "compass") ~= 0) then
							compasses = compasses + input2:get_count()
						end
						return compasses >= wanted1:get_count()
					end
					return false
				end
				-- END OF SPECIAL HANDLING FOR COMPASS
				if (inv:contains_item("input", wanted1) and
					(wanted2:is_empty() or inv:contains_item("input", wanted2)))
					-- BEGIN OF SPECIAL HANDLING FOR COMPASS
					or special_checks(wanted1, input1, input2) then
					-- END OF SPECIAL HANDLING FOR COMPASS
					return -1
				else
					-- If less than double the wanted items,
					-- remove items from output (final trade,
					-- input runs empty)
					return count
				end
			else
				return 0
			end
		else
			return 0
		end
	end,
	allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		if from_list == "input" and to_list == "input" then
			return count
		elseif from_list == "output" and to_list == "input" then
			if not trader_exists(player:get_player_name()) then
				return 0
			end
			local move_stack = inv:get_stack(from_list, from_index)
			if inv:get_stack(to_list, to_index):item_fits(move_stack) then
				return count
			end
		end
		return 0
	end,
	allow_put = function(inv, listname, index, stack, player)
		if listname == "input" then
			if not trader_exists(player:get_player_name()) then
				return 0
			else
				return stack:get_count()
			end
		else
			return 0
		end
	end,
	on_put = function(inv, listname, index, stack, player)
		update_offer(inv, player, true)
	end,
	on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		if from_list == "output" and to_list == "input" then
			inv:remove_item("input", inv:get_stack("wanted", 1))
			local wanted2 = inv:get_stack("wanted", 2)
			if not wanted2:is_empty() then
				inv:remove_item("input", inv:get_stack("wanted", 2))
			end
			local name = player:get_player_name()
			local trader = player_trading_with[name]
			minetest.sound_play("mobs_mc_villager_accept", {to_player = name ,object=trader.object}, true)
		end
		update_offer(inv, player, true)
	end,
	on_take = function(inv, listname, index, stack, player)
		local accept
		local name = player:get_player_name()
		if listname == "output" then
			local wanted1 = inv:get_stack("wanted", 1)
			inv:remove_item("input", wanted1)
			local wanted2 = inv:get_stack("wanted", 2)
			if not wanted2:is_empty() then
				inv:remove_item("input", inv:get_stack("wanted", 2))
			end
			-- BEGIN OF SPECIAL HANDLING FOR COMPASS
			if wanted1:get_name() == COMPASS then
				for n=1, 2 do
					local input = inv:get_stack("input", n)
					if minetest.get_item_group(input:get_name(), "compass") ~= 0 then
						input:set_count(input:get_count() - wanted1:get_count())
						inv:set_stack("input", n, input)
						break
					end
				end
			end
			-- END OF SPECIAL HANDLING FOR COMPASS
			local trader = player_trading_with[name]
			local tradenum = player_tradenum[name]

			local trades
			trader._traded = true
			if trader and trader._trades then
				trades = minetest.deserialize(trader._trades)
			end
			if trades then
				local trade = trades[tradenum]
				local unlock_stuff = false
				if not trade.traded_once then
					-- Unlock all the things if something was traded
					-- for the first time ever
					unlock_stuff = true
					trade.traded_once = true
				elseif trade.trade_counter == 0 and math.random(1,5) == 1 then
					-- Otherwise, 20% chance to unlock if used freshly reset trade
					unlock_stuff = true
				end

				local emeralds
				if wanted1:get_name() == "mcl_core:emerald" then
					emeralds = wanted1:get_count()
				elseif wanted2:get_name() == "mcl_core:emerald" then
					emeralds = wanted2:get_count()
				else
					local offered = inv:get_stack("offered", 1)
					emeralds = offered:get_name() == "mcl_core:emerald" and offered:get_count() or 0
				end
				local xp = 2 + math.ceil(emeralds / (64/4)) -- 1..64 emeralds = 3..6 xp

				local update_formspec = false
				if unlock_stuff then
					-- First-time trade unlock all trades and unlock next trade tier
					if trade.tier + 1 > trader._max_trade_tier then
						trader._max_trade_tier = trader._max_trade_tier + 1
						if trader._max_trade_tier > 5 then
							trader._max_trade_tier =  5
						end
						trader:set_textures()
						trader:update_max_tradenum()
						update_formspec = true
						xp = xp + 5
					end

					for t=1, #trades do
						trades[t].locked = false
						trades[t].trade_counter = 0
					end
					trader._locked_trades = 0
					-- Also heal trader for unlocking stuff
					-- TODO: Replace by Regeneration I
					trader.health = math.min((trader.object:get_properties().hp_max or 20), trader.health + 4)
				end

				if not minetest.is_creative_enabled(player:get_player_name()) then
					mcl_experience.throw_xp(trader.object:get_pos(), xp)
				end

				trade.trade_counter = trade.trade_counter + 1
				-- Semi-randomly lock trade for repeated trade (not if there's only 1 trade)
				if trader._max_tradenum > 1 then
					if trade.trade_counter >= 12 then
						trade.locked = true
					elseif trade.trade_counter >= 2 then
						local r = math.random(1, math.random(4, 10))
						if r == 1 then
							trade.locked = true
						end
					end
				end

				if trade.locked then
					inv:set_stack("output", 1, "")
					update_formspec = true
					trader._locked_trades = trader._locked_trades + 1
					-- Check if we managed to lock ALL available trades. Rare but possible.
					if trader._locked_trades >= trader._max_tradenum then
						-- Emergency unlock! Unlock all other trades except the current one
						for t=1, #trades do
							if t ~= tradenum then
								trades[t].locked = false
								trades[t].trade_counter = 0
							end
						end
						trader._locked_trades = 1
						-- Also heal trader for unlocking stuff
						-- TODO: Replace by Regeneration I
						trader.health = math.min((trader.object:get_properties().hp_max or 20), trader.health + 4)
					end
				end
				trader._trades = minetest.serialize(trades)
				if update_formspec then
					trader:show_trade_formspec(name, tradenum)
				end
			else
				minetest.log("error", "[mobs_mc] Player took item from trader output but player_trading_with or player_tradenum is nil!")
			end

			accept = true
		elseif listname == "input" then
			update_offer(inv, player, false)
		end
		local trader = player_trading_with[name]
		if accept then
			minetest.sound_play("mobs_mc_villager_accept", {to_player = name,object=trader.object}, true)
		else
			minetest.sound_play("mobs_mc_villager_deny", {to_player = name,object=trader.object}, true)
		end
	end,
}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	player_tradenum[name] = 1
	player_trading_with[name] = nil

	-- Create or get player-specific trading inventory
	local inv = minetest.get_inventory({type="detached", name="mobs_mc:trade_"..name})
	if not inv then
		inv = minetest.create_detached_inventory("mobs_mc:trade_"..name, trade_inventory, name)
	end
	inv:set_size("input", 2)
	inv:set_size("output", 1)
	inv:set_size("wanted", 2)
	inv:set_size("offered", 1)
end)
