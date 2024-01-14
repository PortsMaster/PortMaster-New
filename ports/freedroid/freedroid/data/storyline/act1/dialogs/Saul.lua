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

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		Tux:says(_"Hello! I'm new here.")
		Npc:says(_"Hey! How did you get here?! This should not be possible on a normal gameplay.")
		Tux:says(_"Erm, I, uhm, cheated. Or maybe I've found a bug. Or both.")
		Npc:says(_"Anyway, I am Saul, leader of the Resistance faction! We fight against corruption and the oppression of the Red Guard!")
		Tux:says(_"Cool! Can I join?")
		Npc:says(_"Not yet, you see, we're still not ready for the show.")
		Npc:says(_"But you can help us with the preparatives, if you want.")
	end,

	EveryTime = function()
		Npc:says(_"Contact information can be found at [b]https://www.freedroid.org/Contact[/b]")
		end_dialog()
	end,

	-- No one really knows why we keep adding a node99 to all dialog files.
	{
		id = "node99",
		text = _"Exit",
		code = function()
			-- play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		end,
	},
}
