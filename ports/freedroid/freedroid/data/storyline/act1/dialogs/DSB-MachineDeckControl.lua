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
		cli_says(_"Login : ", "NO_WAIT")
		Tux:says(_"admin", "NO_WAIT")
		cli_says(_"Password : ", "NO_WAIT")
		Tux:says(_"*******", "NO_WAIT")
		local day, hour, minute = game_date()
		DSB_MDC_year = os.date("%Y") + 45 -- current year + 45
		DSB_MDC_date = string.format(_"Day %d, %02d:%02d", day, hour, minute)
		--; TRANSLATORS: %s = a date ,  %d = a year number
		cli_says(_"First login from /dev/ttySO on %s %d", DSB_MDC_date, DSB_MDC_year, "NO_WAIT")
        Npc:says("", "NO_WAIT")
	end,

	EveryTime = function()
		DSB_MachineDeckControl_prompt = "admin@main.mdc.dsb.ms: ~ #"
		cli_says(DSB_MachineDeckControl_prompt, "NO_WAIT")
		if (not Tux:done_quest("Opening access to MS Office")) then
			show("node7")
		end
		show("node99", "node1")
	end,

	{
		id = "node1",
		text = _"passwd",
		code = function()
			Npc:says(_"Changing password for admin. Enter new password: ")
			Npc:says(_"Enter new password again: ")
			Npc:says(_"Password successfully changed.")
			DSB_MDC_password = true
			cli_says(DSB_MachineDeckControl_prompt, "NO_WAIT")
			hide("node1")
		end,
	},
	{
		id = "node7",
		text = _"shieldmgr --disable --force",
		code = function()
			Npc:says(_"Disabling disruptor shield... ")
			Npc:says(_"Shield disabled.")
			if (DSB_MDC_password) then
				Tux:end_quest("Opening access to MS Office", _"I've taken over the control terminal and disabled the disruptor shield. Now, I should go to the Hell Fortress and hack the MS firmware update system.")
				hide("node7")
				play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
				end_dialog()
			else
				Npc:says(_"WARNING: Another user is using this computer.")
				Npc:says(_"Disruptor shield is active.")
			end
			cli_says(DSB_MachineDeckControl_prompt, "NO_WAIT")
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
