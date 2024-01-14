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
PERSONALITY = { "Militaristic","Consiliatory" },
MARKERS = { NPCID1 = "Town-NorthGateGuard" },
PURPOSE = "$$NAME$$ is another guard at the main entrance to town.",
BACKSTORY = "$$NAME$$ explains to Tux $$NPCID1$$\'s abrasiveness."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0")
	end,

	EveryTime = function()
		show("node99")
	end,

	{
		id = "node0",
		text = _"Hi! I'm new here.",
		code = function()
			Npc:says(_"Ah, a newcomer. I gather you were treated rather harshly by my friend at the gate? My apologies, he lost his little sister in the Great Assault. He never got over it.")
			Npc:says(_"So, stranger, welcome here. You might want to talk to Chandra or to Spencer, they can tell you a lot about our current situation.")
			Npc:says(_"The town is presently ruled by the Red Guard. We are the police and the soldiers here.")
			Npc:says(_"There is only one law concerning outsiders here: Don't be stupid.")
			Npc:says(_"I think that is enough of an introduction for now.")
			hide("node0") show("node1")
		end,
	},
	{
		id = "node1",
		text = _"What are you doing here?",
		code = function()
			Npc:says(_"I'm on guard duty right now.")
			Npc:says(_"There have been no attacks for a while now. It is too quiet, I think something big is about to happen.")
			if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				Tux:says(_"Of course. I killed all bots.")
				Npc:says(_"No, not that. Something tells me it's not over, at least, not yet. Call it instinct, I simply can't rest.")
				Npc:says(_"I'll stay in guard for a while more, even if Spencer told me to rest. Feel free to walk outside, though. It's just a bad omen, nothing more.")
			end
			hide("node1")
		end,
	},
	{
		id = "node99",
		text = _"I'll be going, then.",
		code = function()
			Npc:says(_"Goodbye.")
			show("node1")
			end_dialog()
		end,
	},
}
