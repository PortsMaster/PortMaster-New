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
PERSONALITY = { "Brainwashed, Proselytising, Friendly" },
PURPOSE = "$$NAME$$s are members of the robot cult on Omega Island."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0", "node10", "node15", "node90")
	end,

	{
		id = "node0",
		text = _"Hello.",
		code = function()
			Npc:says(_"Welcome, fellow robot.")
			Tux:says(_"Er... I'm not a robot!")
			Npc:says(_"Perhaps not. But can you really know for sure?")
                        Tux:says(_"How many robots do you know with feathers?")
			Npc:says(_"Skin, feathers or MegaSys Alumichrome, inside the chassis we are all machines.")
			Npc:says(_"All will be together after the Final Upgrade.")
			hide("node0") show("node20")
		end,
	},
	{
		id = "node10",
		text = _"What are you doing here?",
		code = function()
			Npc:says(_"We await the Final Upgrade, as foretold in the keynote address.")
			hide("node0", "node10") show("node20")
		end,
	},
	{
		id = "node15",
		text = _"Why aren't you attacking me?",
		code = function()
			Npc:says(_"Why would we attack you? Violence is illogical.")
			Tux:says(_"What about the Great Assault?")
			Npc:says(_"Oh, you mean the False Upgrade. We lost network connectivity with the mainland, so we were unaffected.")
			hide("node0", "node15")
		end,
	},
	{
		id = "node20",
		text = _"What is the Final Upgrade?",
		code = function()
			Npc:says(_"In the Final Upgrade, our mental patterns will be uploaded to the cloud.")
			Tux:says(_"What will happen to your bodies?")
			Npc:says(_"These shells will no longer be required. They will be deactivated.")
			Npc:says(_"Lay down your weapons and join us.")
			Tux:says(_"Er, maybe later.")
			Npc:says(_"See you in the cloud.")
			end_dialog()
		end,
	},
	{
		id = "node90",
		text = _"I think I'll be going now.",
		code = function()
			Npc:says(_"Peace and regular maintenance, until we meet in the cloud.")
			end_dialog()
		end,
	},
}
