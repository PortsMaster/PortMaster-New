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
PERSONALITY = { "Robotic" },
MARKERS = { NPCID1 = "Kevin" },
PURPOSE = "$$NAME$$ defends $$NPCID1$$\'s compound and mows the lawn.",
RELATIONSHIP = {
	{ actor = "$$NPCID1$$", text = "$$NAME$$ is owned by $$NPCID1$$." },
}
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		fuel = 97
	end,

	EveryTime = function()

		if (Kevin_entering_from_back) then
			Npc:says(_"Intruder detected.")
			Npc:says(_"[b]Security mode:[/b] ACTIVATED")
			end_dialog()
			return
		end

		Npc:says(_"Welcome to Kevin's personal lawnmower.")
		Npc:says(_"Your connection with this bot has been logged and reported to Kevin.")
		Npc:says(_"Please state your name for identification.")
		Npc:says(_"WARNING: ANY ABUSE WILL BE PUNISHED!")

		if (fuel < 5) then
			Npc:set_state("fixed")
			Npc:says(_"WARNING:", "NO_WAIT")
			Npc:says(_"Less than [b]5%%[/b] fuel remaining!", "NO_WAIT")
			Npc:says(_"All movement suppressed...")
			Npc:says(_"Scanning area for possible compatible energy sources...")
			hide("node5", "node6")
			if (Tux:has_item_backpack("Barf's Energy Drink")) then
				Npc:says(_"Compatible energy source found!")
				Npc:says(_"[b]Barf's Energy Drink[/b]")
				show("node50", "node51")
			else
				Npc:says(_"Could not detect compatible energy source.")
				Npc:says(_"Recommended energy source: [b]Barf's Energy Drink[/b]")
				Npc:says(_"Resuming hibernation...")
				end_dialog()
			end
		end

		if (fuel > 4) and
		   (fuel <= 97) then
			fuel = math.floor(fuel*0.7-2)
			if (fuel < 0) then
				fuel = 0
			end
		end

		show("node5", "node6", "node99")
	end,

	{
		id = "node5",
		text = _"I'll state my name.",
		echo_text = false,
		code = function()
			Tux:says(Tux:get_player_name())
			Npc:says(_"Identifying as %s", Tux:get_player_name(), "NO_WAIT")
			if (Kevins_Lawnmower_tux_login_granted) then
				Npc:says(_"Welcome to Kevin's lawnmower.")
				show("node20")
				hide("node5", "node6", "node30", "node30", "node31")
			else
				Npc:says(_"Verification failed!")
				Npc:says(_"WARNING: LOGIN ATTEMPT REPORTED. THERE WILL BE CONSEQUENCES!")
				Kevins_Lawnmower_tux_login = true
				Tux:heat(15)
				end_dialog()
			end
		end,
	},
	{
		id = "node6",
		text = _"I'll try 'Kevin'.",
		echo_text = false,
		code = function()
			Tux:says(_"Kevin")
			Npc:says(_"Identifying as Kevin...", "NO_WAIT")
			Npc:says(_"Identification failed!", "NO_WAIT")
			Npc:says(_"Liar!", "NO_WAIT")
			Npc:says(_"WARNING: ABUSE REPORTED!")
			Npc:says(_"PUNISHMENT IN 3 SECONDS!")
			Npc:says(_"IN 2 SECONDS!")
			Npc:says(_"IN 1 SECOND!")
			Npc:says(_"DIE!")
			Kevins_Lawnmower_tux_login_kevin_attempt = true
			Tux:heat(25)
			end_dialog()
		end,
	},
	{
		id = "node20",
		text = _"help",
		code = function()
			Tux:says(_"Available commands:", "NO_WAIT")
			Npc:says(_"help", "NO_WAIT")
			Npc:says(_"version", "NO_WAIT")
			Npc:says(_"fuel_level", "NO_WAIT")
			Npc:says(_"exit", "NO_WAIT")
			show("node30", "node31", "node20")
		end,
	},
	{
		id = "node30",
		text = _"version",
		echo_text = false,
		code = function()
			Tux:says(_"version", "NO_WAIT")
			Npc:says(_"printing version...", "NO_WAIT")
			Npc:says(_"MowOS 0.4.2", "NO_WAIT")
			hide("node30")
		end,
	},
	{
		id = "node31",
		text = _"fuel_level",
		echo_text = false,
		code = function()
			Tux:says(_"fuel_level", "NO_WAIT")
			Npc:says(_"Printing fuel level...")
			if (fuel < 5) then
				--; TRANSLATORS: '%%' is not a typo
				Npc:says(_"WARNING, less than [b]5%%[/b] fuel remaining!")
			elseif (fuel <= 97) then
				--; TRANSLATORS: '%%' is not a typo, %s = number
				Npc:says(_"[b]%s[/b]%% remaining", fuel)
			else
				Npc:says(_"Tank completely refilled.")
			end
			hide("node31")
		end,
	},
	{
		id = "node50",
		text = _"It can have one drink...",
		echo_text = false,
		code = function()
			Tux:says(_"So, where do I have to put in the drink...?", "NO_WAIT")
			Tux:says(_"Ah, here!", "NO_WAIT")
			Npc:says(_"[b]glug glug glug[/b]")
			Npc:says(_"Tank refilled.")
			Npc:says(_"Fuel status:")
			--; TRANSLATORS: '%%' is not a typo
			Npc:says(_"[b]100[/b]%%!")
			Npc:says(_"This will approximately suffice for:")
			Npc:says(_"1 month and 14 days.")
			Npc:says(_"Dropping waste product of last fuel filling...")
			Npc:says(_"Done.")
			Tux:del_item("Barf's Energy Drink", 1)
			Tux:add_item("Tungsten spikes", 2)
			fuel = 100
			Npc:set_state("home")
			hide("node50", "node51")
		end,
	},
	{
		id = "node51",
		text = _"No, I cannot spare any drinks!",
		echo_text = false,
		code = function()
			Tux:says(_"Sorry, tin can.")
			Npc:says(_"Import error: [b]null[/b] fuel received.", "NO_WAIT")
			--; TRANSLATORS: '%%' is not a typo
			Npc:says(_"WARNING, less than [b]5[/b]%% fuel remaining!")
			Npc:says(_"Resuming hibernation...")
			hide("node50", "node51")
			end_dialog()
		end,
	},
	{
		id = "node99",
		text = _"exit",
		echo_text = false,
		code = function()
			Tux:says(_"exit", "NO_WAIT")
			Npc:says(_"exiting...")
			hide("node31", "node30", "node20", "node50", "node51")
			end_dialog()
		end,
	},
}
