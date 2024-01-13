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
PURPOSE = "$$NAME$$ is the first bot Tux encounters in the game. It starts the first fight during the introduction."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	EveryTime = function()
		Npc:says(_"Target Acquired...","NO_WAIT")
		Npc:says(_"Scanning...")
		Npc:says(_"Non-Human Lifeform Identified","NO_WAIT")
		Npc:says(_"Species Identified: Linarian")
		Npc:says(_"Current Status: Unknown")
		show("node0", "node1", "node2")
	end,

	{
		id = "node0",
		text = _"Hello there.",
		code = function()
			predilect='amicable'
			next("node99")
		end,
	},
	{
		id = "node1",
		text = _"What's up?",
		code = function()
			predilect='interrogative'
			next("node99")
		end,
	},
	{
		id = "node2",
		text = _"Die!",
		code = function()
			predilect='aggressive'
			next("node99")
		end,
	},
	{
		id = "node99",
		code = function()
			play_sound("effects/bot_sounds/First_Contact_Sound_3.ogg")
			Npc:says(_"Uploading Status...")
			Npc:set_faction("ms")
			if (predilect == 'amicable') then
				Npc:says(_"Target attempts to engage discourse. Unacceptable outcomes predicted. Threat identified.")
			elseif (predilect == 'interrogative') then
				Npc:says(_"Target is inquisitive. Threat identified.")
			elseif (predilect == 'aggressive') then
				Npc:says(_"Target issues verbal threat.","NO_WAIT")
			end
			Npc:says(_"Linarian is hostile. Destroy!")
			end_dialog()
		end,
	},
}
