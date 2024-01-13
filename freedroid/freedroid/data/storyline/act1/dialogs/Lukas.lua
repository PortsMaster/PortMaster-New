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
PERSONALITY = { "Militaristic", "Helpful" },
PURPOSE = "$$NAME$$ will sell Tux more capable weapons and armor after Tux has joined the Red Guard.",
BACKSTORY = "$$NAME$$ is the Red Guard\'s Quartermaster/Storesman",
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0")
	end,

	EveryTime = function()
		if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
			Npc:says(_"Hey, if it isn't our hero! Do you need ammo? A new gun, maybe? Or armor, yes, you definitely should get a new one!", "NO_WAIT")
		end
		show("node99")
	end,

	{
		id = "node0",
		text = _"Hi! I'm new here.",
		code = function()
			Npc:says(_"A newcomer! Great! We can always use more people. Welcome to the Red Guard! I'm Lukas. I'm in charge of our little armory here.")
			hide("node0") show("node1", "node2", "node3")
		end,
	},
	{
		id = "node1",
		text = _"Spencer said you'd be able to provide me with better armor and equipment.",
		code = function()
			Npc:says(_"Of course. As a member of the Guard, you're entitled to wear one of our suits of armor.")
			Npc:says(_"There are two kinds or armor, a heavy Red Guard robe and a light version of the same thing, though we also trade guns.")
			Npc:says_random(_"Now, what will it be?",
							_"So, what do you want to buy?")
			trade_with("Lukas")
			show("node4")
		end,
	},
	{
		id = "node2",
		text = _"I am interested in buying ammo.",
		code = function()
			Npc:says(_"Of course. Because ammo is always at high demand, we sell them separately.")
			Npc:says_random(_"Now, what will it be?",
							_"So, what do you want to buy?")
			trade_with("Benjamin") -- Not sure if this usage was intended when trade_with() was implemented
			show("node4")
		end,
	},
	{
		id = "node3",
		text = _"What do you do all day here at the armory?",
		code = function()
			Npc:says(_"Oh, there's always something to do. Don't worry. I'm pretty occupied keeping the place in order.")
			hide("node3")
		end,
	},
	{
		id = "node4",
		text = _"I'd like to buy an exterminator.",
		code = function()
			Npc:says(_"Haha, good one.")
			if (Tux:has_item_equipped("The Super Exterminator!!!") or
				Tux:has_item_equipped("Exterminator")) then
				Npc:says(_"You are already using one. It is on your hands!")
				Npc:says(_"Stop trying to make a fool of me.")
			else
				Npc:says(_"Sorry, they are not for sale.")
				Tux:says(_"I'll get one for free?")
				if (not HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
					Npc:says(_"You are the funniest Linarian I've ever seen.")
					Npc:says(_"If the only one.")
					Npc:says(_"Now go, kill some bots.")
				else
					Npc:says(_"Why would you need one, anyway? The bots are all dead.")
					Npc:says(_"While I agree you deserve one, only Spencer can authorize that. Sorry.")
				end
			end
			hide("node4")
		end,
	},
	{
		id = "node99",
		text = _"See you later!",
		code = function()
			end_dialog()
		end,
	},
}
