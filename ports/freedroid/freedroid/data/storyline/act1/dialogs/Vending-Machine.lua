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
		Npc:says(_"[b][OK][/b] Waking up from sleep mode...", "NO_WAIT")
		Npc:says(_"[b][OK][/b] Obtaining ware table...", "NO_WAIT")
		Npc:says(_"[b][OK][/b] Loading graphical user interface...", "NO_WAIT")
		Npc:says(_"[b][OK][/b] Preparing trade...", "NO_WAIT")
		trade_with("Vending-Machine")
		Npc:says(_"Trade done.", "NO_WAIT")
		Npc:says(_"[b][OK][/b] Shutting down graphical user interface...", "NO_WAIT")
		Npc:says(_"[b][OK][/b] Entering sleep mode...", "NO_WAIT")
		end_dialog()
		play_sound("effects/Menu_Item_Selected_Sound_1.ogg") -- there is no node 99 selectable so just play this here
	end,

	{
		id = "node99",
		text = _"Exit",
		code = function()
			-- play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		end,
	},
}
