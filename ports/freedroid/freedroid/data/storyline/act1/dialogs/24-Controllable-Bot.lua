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
PURPOSE = "$$NAME$$ is used for debugging Aftertakeover features.",
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0")
	end,

	EveryTime = function()
		ControllableBot_try_again = true
		ControllableBot_response_is = nil

		while (ControllableBot_try_again) do
			ControllableBot_response = user_input_string("enter target waypoint or bot state. states: follow-tux, fixed, free, home, patrol")
			if (ControllableBot_response == "follow-tux" ) or
			   (running_benchmark()) then
				-- missing characters are missing
				ControllableBot_response = "follow_tux"
				ControllableBot_response_is = "state"
			elseif (ControllableBot_response == "fixed" ) or
			       (ControllableBot_response == "free" ) or
			       (ControllableBot_response == "home" ) or
			       (ControllableBot_response == "patrol" ) or
			       (running_benchmark()) then
				ControllableBot_response_is = "state"
			end

			if (ControllableBot_response == "24-A1" ) or
			   (ControllableBot_response == "24-A2" ) or
			   (ControllableBot_response == "24-A3" ) or
			   (ControllableBot_response == "24-A4" ) or
			   (ControllableBot_response == "24-B1" ) or
			   (ControllableBot_response == "24-B2" ) or
			   (ControllableBot_response == "24-B3" ) or
			   (ControllableBot_response == "24-B4" ) or
			   (ControllableBot_response == "24-C1" ) or
			   (ControllableBot_response == "24-C2" ) or
			   (ControllableBot_response == "24-C3" ) or
			   (ControllableBot_response == "24-C4" ) or
			   (ControllableBot_response == "24-D1" ) or
			   (ControllableBot_response == "24-D2" ) or
			   (ControllableBot_response == "24-D3" ) or
			   (ControllableBot_response == "24-D4" ) or
			   (running_benchmark()) then
				ControllableBot_response_is = "waypoint"
			end

			if (ControllableBot_response_is == "state") or
			   (running_benchmark()) then
				if not (running_benchmark()) then -- sucks but can't be helped currently afaik
					Npc:set_state(ControllableBot_response)
				end
				ControllableBot_try_again = false
				end_dialog()
			elseif (ControllableBot_response_is == "waypoint") or
			       (running_benchmark()) then
				Npc:set_state("free")
				Npc:set_destination(ControllableBot_response)
				ControllableBot_try_again = false
				end_dialog()
			else
				Npc:says("WARNING, '%s' not a valid map label.", ControllableBot_response)
				Npc:says("Please retry.")
			end
		end
	end,

	{
		id = "node0",
		text = "Hiiiiiii!!!",
		code = function()
			hide("node0")
		end,
	},
	{
		id = "node99",
		text = "logout",
		code = function()
			end_dialog()
		end,
	},
}
