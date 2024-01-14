---------------------------------------------------------------------
-- This file is part of Freedroid
--
-- Freedroid is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- Freedroid is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Freedroid; see the file COPYING. If not, write to the
-- Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
-- MA 02111-1307 USA
----------------------------------------------------------------------
--[[WIKI
PURPOSE = "$$NAME$$ is a character used for Debug purposes"
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

local function dude_dialog_name(filename)
	return string.sub(filename, 1, -(string.len(".lua") + 1))
end

local function dude_create_node(dialogname)
	return {
		id = dialogname,
		text = dialogname,
		enabled = true,
		code = function()
			Tux:says("Starting " .. dialogname)
			start_chat(dialogname)
		end,
	}
end

local function dude_choose_action(this_dialog)
	local actionname = user_input_string("Please enter the dialog name of the desired NPC (Chandra, Bender...) " ..
	                                     "or other action to jump to (redguard, craft, upgrade, shop or exit). " ..
	                                     "If the input is invalid, the game will crash! To abort, enter " ..
	                                     "'continue' or press enter or escape.")
	if (not (actionname == "continue" or actionname == "")) then
		local actionnode = this_dialog:find_node(actionname)
		if (actionnode and actionnode.code) then
			actionnode:code(this_dialog)
		end
	end
end

return {
	FirstTime = function()
		level24obstacles()
		get_town_score()
		Dude_exit_node_count = 0
	end,

	EveryTime = function(this_node, this_dialog)
		Npc:says("Hello.")
		if (tux_has_joined_guard) then
			Npc:says("Red Guard membership: [b]true[/b]")
		else
			Npc:says("Red Guard membership: [b]false[/b]")
		end
		Npc:says("Here you'll be able to access all dialogs that are available ingame.", "NO_WAIT")
		Npc:says("Take care, this may be a little buggy.", "NO_WAIT")
		Npc:says("Don't do this if you are just normally playing.", "NO_WAIT")
		Npc:says("These dialogs can currently be accessed:", "NO_WAIT")
		local node_list = ""
		for idx,node in ipairs(this_dialog.nodes) do
			if (node.id ~= "node0") then
				node_list = node_list .. node.id .. ", "
			end
		end
		Npc:says(string.sub(node_list, 1, -2))

		dude_choose_action(this_dialog)
	end,

	{
		id = "node0",
		enabled = true,
		text = "Show input field again.",
		code = function(this_node, this_dialog)
			dude_choose_action(this_dialog)
			hide("node0")
			show("node0")  -- done on purpose
		end,
	},

	{
		id ="switchact",
		enabled = true,
		text = "Test Game Act switching",
		code = function()
			jump_to_game_act("act2")
			Npc:says("Will switch to Act 2. Closing...")
			end_dialog()
		end,
	},

	{
		id = "delayedevent1",
		enabled = true,
		text = "Test Delayed Events",
		code = function()
			dispatch_event("24 Test Delayed Event 2", 7)
			dispatch_event("24 Test Delayed Event 1", 3)
		end,
	},

	{
		id = "l10n",
		enabled = true,
		text = "Test l10n",
		code = function()
			--; TRANSLATORS: Used to test l10n, so put here anything you want in your language 
			--; TRANSLATORS: (can also be used to test non ASCII characters).
			Npc:says("Untranslated reply.")
		end,
	},
	
	{
		id = "redguard",
		enabled = true,
		text = "Become Red Guard",
		code = function()
			tux_has_joined_guard = true
			Npc:says("You are now a member of the Red Guard.")
		end,
	},

	{
		id = "craft",
		enabled = true,
		text = "Craft addons",
		code = function()
			craft_addons()
		end,
	},

	{
		id = "upgrade",
		enabled = true,
		text = "Upgrade items",
		code = function()
			upgrade_items()
		end,
	},

	{
		id = "shop",
		enabled = true,
		text = "Shop",
		code = function()
			trade_with("Dude")
		end,
	},

	{
		id = "spam",
		enabled = true,
		text = "Spam",
		code = function()
			for spam_number=1,10000 do
				Npc:says(spam_number, "NO_WAIT")
			end
		end,
	},

	{
		generator = function()
			local nodes = {}
			local exclude = {
				-- "subdialogs" can not be run solely
				"614_sub.lua", "c-net-nethack_sub.lua",
				-- dialog of terminals can not be run, currently, because they have no associated 'bot'
				"Cryo-Terminal.lua", "c-net.lua", "DSB-MachineDeckControl.lua",
				"DSB-PowerControlGate1.lua", "HF-FirmwareUpdateServer.lua",
				"MO-HFGateAccessServer.lua", "MS-Factory-Addon-Terminal.lua",
				"Maintenance-Terminal.lua", "MiniFactory-Terminal.lua",
				"Terminal.lua", "TutorialTerminal.lua", "Vending-Machine.lua",
				"DSB-PowerControl.lua" }

			local dircontent = FDutils.system.scandir(FDdialog.dialogs_dirs, ".*%.lua", exclude)
			if (dircontent) then
				for none,filename in ipairs(dircontent) do
					nodes[#nodes + 1] = dude_create_node(dude_dialog_name(filename))
				end
			end

			return nodes
		end
	},

	{
		id = "exit",
		enabled = true,
		text = function()
			return string.format( "Exit this dialog for the %sth time", Dude_exit_node_count + 1)
		end,
		code = function()
			Npc:says("Closing...")
			Dude_exit_node_count = Dude_exit_node_count + 1 -- do the computation of the var now
			end_dialog()
		end,
	},
}
