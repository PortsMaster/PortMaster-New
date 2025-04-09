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
PURPOSE = "Another shop keeper."
BACKSTORY = "$$NAME$$ probably breaks current storyline, and its fate is undecided."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0")
	end,

	EveryTime = function()
		if (Tux:has_met("Karol")) then
			show("node1")
			if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				Npc:says(_"Commerce today is slower than usual. I wonder if something happened.")
			end
		end

		show("node99")
	end,

	{
		id = "node0",
		text = _"Hello. Can I buy something from you?",
		code = function()
			Npc:says(_"Hi, yes, you can buy stuff from me.")
			Npc:says(_"My name is Karol. I sell mostly tools which are needed to manufacture bots.")
			Npc:set_name("Karol - Shop owner")
			hide("node0") show("node1", "node2")
		end,
	},
	{
		id = "node1",
		text = _"What are your offers today?",
		code = function()
			Npc:says(_"Take a look.")
			trade_with("Karol")
		end,
	},
	{
		id = "node2",
		text = _"Can I buy droid parts? Like Entropy Inverters?",
		code = function()
			Npc:says(_"Sorry, these are all sold out.")
			Npc:says(_"But I think a shipment will come by the next month.")
            Tux:says(_"I can't wait that long.")
            Npc:says(_"There is nothing I can do about it. Try exchanging with another worker, maybe?")
			hide("node2")
		end,
	},
	{
		id = "node99",
		text = _"See you later.",
		code = function()
			Npc:says(_"Bye bye.")
			end_dialog()
		end,
	},
}
