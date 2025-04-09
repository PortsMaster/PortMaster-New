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
		play_sound("effects/Menu_Item_Deselected_Sound_0.ogg")
		local day, hour, minute = game_date()
		DSB_PC_year = os.date("%Y") + 45 -- current year + 45
		DSB_PC_date = string.format(_"Day %d, %02d:%02d", day, hour, minute)
		cli_says(_"Login : ", "NO_WAIT")
		Tux:says(_"admin", "NO_WAIT")
		cli_says(_" Password : ", "NO_WAIT")
		Tux:says(_"*******", "NO_WAIT")
		--; TRANSLATORS: %s = a date , %y = a year
		Npc:says(_"First login from /dev/ttySO on %s %d", DSB_PC_date, DSB_PC_year, "NO_WAIT")
		show("node1")
	end,

	EveryTime = function()
		--; TRANSLATORS: 'admin' should perhaps not be translated
		cli_says(_"admin@main.pc.dsb.ms: ~ #", "NO_WAIT")
		show("node99")
	end,

	{
		id = "node1",
		text = _"powercontrol --halt",
		code = function()
			Npc:says(_"[b]ERROR:[/b] Impossible to shutdown. Please contact Machine Deck.")
			cli_says(_"admin@main.pc.dsb.ms: ~ #", "NO_WAIT")
			hide("node1")
		end,
	},
	{
		id = "node99",
		text = _"logout",
		code = function()
			Npc:says(_"Exiting...")
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		end,
	},
}
