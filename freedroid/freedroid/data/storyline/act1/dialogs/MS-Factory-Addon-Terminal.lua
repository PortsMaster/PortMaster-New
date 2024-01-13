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
		terminal = "user@product_enhancer: ~ # "

		cli_says(_"Login : ", "NO_WAIT")
		-- ; TRANSLATORS: 'user' should perhaps not be translated
		Tux:says(_"user", "NO_WAIT")
		cli_says(_"Password : ", "NO_WAIT")
		if (not has_ms_addon_password ) then
			Tux:says("*******", "NO_WAIT")
			Npc:says(_"Incorrect password or username")
			Tux:says(_"Mmmh...")
			cli_says(_"Password : ", "NO_WAIT")
			Tux:says("***********", "NO_WAIT")
			Npc:says(_"Incorrect password or username")
			cli_says(_"Password : ", "NO_WAIT")
			Tux:says("**", "NO_WAIT")
			Npc:says(_"Login succeeded!")
			Tux:says(_"Oh well....")
		else
			Tux:says("**", "NO_WAIT")
			Npc:says(_"Login succeeded!")
		end
		Npc:says(_"Last login from /dev/ttyS0 on Fri, 9 dec 2059.", "NO_WAIT")
		cli_says(terminal, "NO_WAIT")
		has_ms_addon_password = true
		show("node10", "node20", "node99")
	end,

	{
		id = "node10",
		text = _"craft --addon",
		code = function()
			craft_addons()
			cli_says(terminal, "NO_WAIT")
		end,
	},
	{
		id = "node20",
		text = _"assemble --item --addon",
		code = function()
			upgrade_items()
			cli_says(terminal, "NO_WAIT")
		end,
	},
	{
		id = "node99",
		text = _"logout",
		code = function()
			Npc:says(_"Exiting", "NO_WAIT")
			Npc:says(_"M$ - What will be next?")
			hide("node10", "node20")
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		end,
	},
}
