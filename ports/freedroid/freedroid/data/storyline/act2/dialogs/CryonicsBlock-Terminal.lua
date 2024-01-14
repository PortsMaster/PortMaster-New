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
		Npc:says(_"[b]Main Cryonics Containment Gate[/b]", "NO_WAIT")
		Npc:says(_"This is a security area. Please identify or logout.")
		hide("node1")
		show("node0", "node99")
	end,

	{
		id = "node0",
		--; TRANSLATORS: command, use lowercase here
		text = _"identify",
		code = function()
			cli_says(_"Identification: ")
			if (takeover(18)) then
				play_sound("effects/Menu_Item_Deselected_Sound_0.ogg")
				Tux:says(_"Tux", "NO_WAIT")
				Npc:says(_"[b]ERROR[/b] Unable to execute open.exe.")
				Npc:says(_"Try using commands: chkdsk logout")
				hide("node0") show("node1")
			else
				Tux:says(_"Tux", "NO_WAIT")
				play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
				Npc:says(_"Credentials invalid. Disconnection forced.")
				end_dialog()
			end
		end,
	},
	{
		id = "node1",
		--; TRANSLATORS: command, use lowercase here
		text = _"chkdsk",
		code = function()
			Npc:says(_"[b]ERROR[/b] Because this terminal was designed not to fail, if failure does occur, there are no tools provided to repair it.", "NO_WAIT")
			Npc:says(_"[b]ERROR[/b] 'chkdsk' is not recognized as an internal or external command, operable program or batch file.")
			hide("node1")
		end,
	},
	{
		id = "node99",
		--; TRANSLATORS: command, use lowercase here
		text = _"logout",
		code = function()
			cli_says(_"Goodbye")
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		end,
	},
}
