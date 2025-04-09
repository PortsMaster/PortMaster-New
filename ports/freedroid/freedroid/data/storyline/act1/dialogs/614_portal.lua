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
MARKERS = {  },
BACKSTORY = "$$NAME$$ is part of the Special Area across bridge on level 42. He is a 614 droid guarding the Portal..."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return 
{
	FirstTime = function()
		show("node4")
	end,

	EveryTime = function()
		show("node0", "node5", "node99")
	end,

	------------------------------
	-- 614_sub
	--
	{
		topic = "614_sub",
		generator = include("614_sub"),
	},
	--
	------------------------------

	{
		id = "node0",
		text = _"Who are you?",
		code = function()
			push_topic("614_sub")
			-- call 614_sub subdialog
			next("614_sub.everytime")
		end,
	},
	{
		-- called after the end of 614_sub subdialog
		id = "after-614_sub",
		code = function()
			pop_topic()
			hide("node0")
		end,
	},
	{
		id = "node4",
		text = _"Have you detected any hostile bot activity?",
		code = function()
			Npc:says(_"ERROR: unknown command. Searching for similar commands...")
			Npc:says(_"...")
			Npc:says(_"...")
			Npc:says(_"ERROR! Similar command not found! Using advanced search...")
			Npc:says(_"...")
			Npc:says(_"Executable 'bin/hostile' found. Executing...")
			Tux:says(_"OUCH!")
			play_sound("effects/Influencer_Scream_Sound_0.ogg")
			freeze_tux(5)
			hide("node4")
			end_dialog()
		end,
	},
	{
		id = "node5",
		text = _"What are your orders?",
		code = function()
			Npc:says(_"My orders are to protect the living beings from attacks by hostile bots.")
			Npc:says(_"This has top priority. There are no other priorities.")
			hide("node5")
		end,
	},
	{
		id = "node99",
		text = _"See you later.",
		code = function()
			Npc:says(_"Resuming guard program....")
			end_dialog()
		end,
	},
}
