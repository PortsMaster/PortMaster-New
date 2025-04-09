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
		local day, hour, minute = game_date()
		DSB_PowerControlGate1_year = os.date("%Y") + 45 -- current year + 45
		DSB_PowerControlGate1_date_1 = string.format(_"Day %d, %02d:%02d", day, hour, minute)
		DSB_PowerControlGate1_prompt = "guest@gate1.pc.dsb.ms: ~ #"

		cli_says(_"Login : ", "NO_WAIT")
		Tux:says(_"admin", "NO_WAIT")
		cli_says(_"Password : ", "NO_WAIT")
		Tux:says(_"*******", "NO_WAIT")
		Npc:says(_"[b]Login failed. Entering as Guest[/b]")
		Npc:says(" ", "NO_WAIT")
		Npc:says(_"Welcome to [b]Power Control Gate 1 Terminal[/b]!", "NO_WAIT")
		Npc:says(" ", "NO_WAIT")
		if (DSB_PowerControlGate1_date == nil) then
		--; TRANSLATORS: %s = a date ,  %d = a year number
			Npc:says(_"First login from /dev/ttySO on %s %d", DSB_PowerControlGate1_date_1, DSB_PowerControlGate1_year, "NO_WAIT")
		else
			--; TRANSLATORS: %s = a date ,  %d = a year number
			Npc:says(_"Last login from /dev/ttyS0 on %s %d", DSB_PowerControlGate1_date, DSB_PowerControlGate1_year, "NO_WAIT")
		end
		DSB_PowerControlGate1_date = DSB_PowerControlGate1_date_1

		cli_says(DSB_PowerControlGate1_prompt, "NO_WAIT")
		if (cmp_obstacle_state("DSB-PCGate1", "closed")) then
			show("node0")
		elseif (cmp_obstacle_state("DSB-PCGate1", "opened")) then
			show("node10")
		else
			Npc:says(_"GAME BUG. PLEASE REPORT.")
		end
		show("node99")
	end,

	{
		id = "node0",
		text = _"open gate",
		code = function()
			--if (not dsb_pc_access) then
			Npc:says(_"Gate status: CLOSED", "NO_WAIT")
			Npc:says(_"Security Access to this area denied.")
			Npc:says(_"Contact personnel in the Machine Deck Control Room if you believe this to be an error.")
			--else
			-- Npc:says(_"Gate status: CLOSED", "NO_WAIT")
			-- Npc:says(_"Access granted. Opening gate ...")
			--- Npc:says(_"Gate status: OPEN")
			-- change_obstacle_state("DSB-PCGate1", "opened")
			-- hide("node0") show("node10")
			--end
			cli_says(DSB_PowerControlGate1_prompt, "NO_WAIT")
		end,
	},
	{
		id = "node10",
		text = _"close gate",
		code = function()
			Npc:says(_"Gate status: OPEN", "NO_WAIT")
			Npc:says(_"Access granted. Closing gate ...")
			Npc:says(_"Gate status: CLOSED")
			change_obstacle_state("DSB-PCGate1", "closed")
			cli_says(DSB_PowerControlGate1_prompt, "NO_WAIT")
			hide("node10") show("node0")
		end,
	},
	{
		id = "node99",
		text = _"logout",
		code = function()
			Npc:says(_"Exiting", "NO_WAIT")
			Npc:says_random(_"Have a nice day.",
							_"Have a wonderful day.",
							_"We hope your day will be most productive.")
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		end,
	},
}
