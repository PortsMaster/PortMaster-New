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
PERSONALITY = { "Silent" },
BACKSTORY = "$$NAME$$ is part of the Special Area across bridge on level 42. He locked himself on the portal room after his brother went missing (probably dead). It is suspected that he hates bots for killing his brother, but at the same time, it's also suspected that he is working with the 999 across the portal. The real reason is unknown, however, as he won't speak (yet), even to the dev team. Probably due a vow of silence, either because his brother death, or because he's working with the 999 which is a bot (this wasn't on original patch) "
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
		text = "Hello there.",
		code = function()
			Npc:says(_"...")
			hide("node0")
		end,
	},
	{
		id = "node99",
		text = "Bye.",
		code = function()
			Npc:says(_"...")
			end_dialog()
		end,
	},
}