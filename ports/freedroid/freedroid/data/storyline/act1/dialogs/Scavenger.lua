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
PERSONALITY = { "Irritable, Worried, Industrious" },
PURPOSE = "$$NAME$$ is looking for replacement parts."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	EveryTime = function()
		show("node0")
	end,

	{
		id = "node0",
		text = _"Hello.",
		code = function()
			Npc:says_random(_"I'm looking for replacement parts. You're blocking my light.",
                                        _"Ooh, is that a 45nm plasma transducer coil you're standing on? Please move aside.",
                                        _"You just stepped on a perfectly serviceable quartzite nanocrystal!",
                                        _"Just what this island needs, another #@&*! tourist.")
			Tux:says(_"Sorry.")
			end_dialog()
		end,
	},
}
