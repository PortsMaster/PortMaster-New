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
	EveryTime = function()
		play_sound("effects/Menu_Item_Deselected_Sound_0.ogg")
		if (not Terminal_connected) then
			show("node0")
			Terminal_connected = true
			cli_says(_"Welcome to this terminal.")
		else
			Tux:says_random(_"Hello.",
							_"Hi there.", "NO_WAIT")
			Npc:says_random(_"Well, hello again.",
							_"Hello hello.",
							_"Welcome back.")
		end
		show("node99")
	end,

	{
		id = "node0",
		--; TRANSLATORS: command, user lowercase here
		text = _"help",
		code = function()
			cli_says(_"Available commands: help, logout")
		end,
	},
	{
		id = "node99",
		--; TRANSLATORS: command, user lowercase here
		text = _"logout",
		code = function()
			cli_says(_"Goodbye")
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		end,
	},
}
