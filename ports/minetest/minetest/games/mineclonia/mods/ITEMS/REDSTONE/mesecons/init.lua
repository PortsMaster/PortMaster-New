-- |\    /| ____ ____  ____ _____   ____         _____
-- | \  / | |    |     |    |      |    | |\   | |
-- |  \/  | |___ ____  |___ |      |    | | \  | |____
-- |      | |        | |    |      |    | |  \ |     |
-- |      | |___ ____| |___ |____  |____| |   \| ____|
-- by Jeija, Uberi (Temperest), sfan5, VanessaE, Hawk777 and contributors
--
--
--
-- This mod adds mesecons[=minecraft redstone] and different receptors/effectors to minetest.
-- See the documentation on the forum for additional information, especially about crafting
--
--
-- For basic development resources, see http://mesecons.net/developers.html
--
--
--
--Quick draft for the mesecons array in the node's definition
--mesecons =
--{
--	receptor =
--	{
--		state = mesecon.state.on/off
--		rules = rules/get_rules
--	},
--	effector =
--	{
--		action_on = function
--		action_off = function
--		action_change = function
--		rules = rules/get_rules
--	},
--	conductor =
--	{
--		state = mesecon.state.on/off
--		offstate = opposite state (for state = on only)
--		onstate = opposite state (for state = off only)
--		rules = rules/get_rules
--	}
--}

-- PUBLIC VARIABLES
mesecon={} -- contains all functions and all global variables
mesecon.queue={} -- contains the ActionQueue
mesecon.queue.funcs={} -- contains all ActionQueue functions

-- Settings
dofile(minetest.get_modpath("mesecons").."/settings.lua")

-- Utilities like comparing positions,
-- adding positions and rules,
-- mostly things that make the source look cleaner
dofile(minetest.get_modpath("mesecons").."/util.lua");

-- Presets (eg default rules)
dofile(minetest.get_modpath("mesecons").."/presets.lua");

-- The ActionQueue
-- Saves all the actions that have to be execute in the future
dofile(minetest.get_modpath("mesecons").."/actionqueue.lua");

-- Internal stuff
-- This is the most important file
-- it handles signal transmission and basically everything else
-- It is also responsible for managing the nodedef things,
-- like calling action_on/off/change
dofile(minetest.get_modpath("mesecons").."/internal.lua");

-- API
-- these are the only functions you need to remember

mesecon.queue:add_function("receptor_on", function (pos, rules)
	mesecon.vm_begin()

	rules = rules or mesecon.rules.default

	-- Call turnon on all linking positions
	for _, rule in pairs(mesecon.flattenrules(rules)) do
		local np = vector.add(pos, rule)
		local rulenames = mesecon.rules_link_rule_all(pos, rule)
		for _, rulename in pairs(rulenames) do
			mesecon.turnon(np, rulename)
		end
	end

	mesecon.vm_commit()
end)

function mesecon.receptor_on(pos, rules)
	mesecon.queue:add_action(pos, "receptor_on", {rules}, nil, rules)
end

mesecon.queue:add_function("receptor_off", function (pos, rules)
	rules = rules or mesecon.rules.default

	-- Call turnoff on all linking positions
	for _, rule in ipairs(mesecon.flattenrules(rules)) do
		local np = vector.add(pos, rule)
		local rulenames = mesecon.rules_link_rule_all(pos, rule)
		for _, rulename in ipairs(rulenames) do
			mesecon.vm_begin()
			mesecon.changesignal(np, minetest.get_node(np), rulename, mesecon.state.off, 2)

			-- Turnoff returns true if turnoff process was successful, no onstate receptor
			-- was found along the way. Commit changes that were made in voxelmanip. If turnoff
			-- returns true, an onstate receptor was found, abort voxelmanip transaction.
			if (mesecon.turnoff(np, rulename)) then
				mesecon.vm_commit()
			else
				mesecon.vm_abort()
			end
		end
	end
end)

function mesecon.receptor_off(pos, rules)
	mesecon.queue:add_action(pos, "receptor_off", {rules}, nil, rules)
end

--Services like turnoff receptor on dignode and so on
dofile(minetest.get_modpath("mesecons").."/services.lua");
