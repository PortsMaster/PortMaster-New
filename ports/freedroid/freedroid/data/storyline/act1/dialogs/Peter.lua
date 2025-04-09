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
PERSONALITY = { "Belligerent", "Resentful" },
BACKSTORY = "$$NAME$$ is being held prisoner in the inner citadel for being apart of a resistance movement against the Red Guard."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0")
	end,

	EveryTime = function()
		if (Tux:has_met("Peter")) then
			Tux:says_random(_"Hello.",
							_"Hi there.", "NO_WAIT")
			Npc:says_random(_"Well, hello again.",
							_"Hello hello.",
							_"Welcome back.")
		end
		show("node99")

		if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
			Npc:says(_"HAHAHA! I heard the bots are dead! You fascists will now all die in hands of a civilian revolution, resistance will prevail, just wait! HAHAHA!")
		end

	end,

	{
		id = "node0",
		text = _"Why are you here?",
		code = function()
			Npc:says(_"I'm a political prisoner.")
			Npc:says(_"Those red fascists put me here.")
			Npc:says(_"And I guess you are a fascist too, as only Red Guard members are allowed in here.")
			hide("node0") show("node1")
		end,
	},
	{
		id = "node1",
		text = _"What is a fascist?",
		echo_text = false,
		code = function()
			Tux:says(_"What is ...", "NO_WAIT")
			Npc:says(_"LALALALALA - I'm not hearing you. I have my fingers in my ears and just go - LALALALALA")
		end,
	},
	{
		id = "node99",
		text = _"Talk to you later.",
		code = function()
			Npc:says(_"Not in your life, Fascist!")
			end_dialog()
		end,
	},
}
