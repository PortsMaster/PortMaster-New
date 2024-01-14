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
PURPOSE = "$$NAME$$ is the narrator NPC used to explain the crash."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		Tux:says(_"Ouch, my head...")
		Tux:says(_"Where... am I? My head is dizzy...")
		Tux:says("...")
		Tux:says(_"Ah, I remember now. I was on a flight, on my way to fight against MegaSys president.")
		Tux:says(_"...Have I lost?")
		cli_says(_"*deep breath*")
		Tux:says(_"No, I did not even reached the location. The stratopod started acting strangely and crashed.")
		Tux:says(_"I better get up, and find out where I am.")
		Tux:assign_quest("Where Am I?", _" The pilot wasn't so experienced as he told. He only played FlightGear a couple of times. By the look of things, I must have crashed. I should explore these lands now.")
	end,

	EveryTime = function()
		end_dialog()
		show("node99") -- Double-check
	end,

	{
		id = "node99",
		text = _"...",
		code = function()
			end_dialog()
		end,
	},
}
