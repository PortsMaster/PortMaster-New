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
		TutorialTerminal_year = os.date("%Y") + 45 -- current year + 45
		TutorialTerminal_date_1 = string.format(_"Day %d, %02d:%02d", day, hour, minute)
		TutorialTerminal_prompt = "guest@example.com: ~ #"

		cli_says(_"Login : ", "NO_WAIT")
		--; TRANSLATORS: username, maybe this should stay in lowercase letters?
		Tux:says(_"guest", "NO_WAIT")
		cli_says(_"Entering as guest", "NO_WAIT")
		Npc:says("", "NO_WAIT")
		if (TutorialTerminal_date == nil) then
			--; TRANSLATORS: %s = a date ,  %d = a year number
			Npc:says(_"First login from /dev/ttySO on %s %d", TutorialTerminal_date_1, TutorialTerminal_year, "NO_WAIT")
		else
			--; TRANSLATORS: %s = a date ,  %d = a year number
			Npc:says(_"Last login from /dev/ttyS0 on %s %d", TutorialTerminal_date, TutorialTerminal_year, "NO_WAIT")
		end
		TutorialTerminal_date = TutorialTerminal_date_1

		if (cmp_obstacle_state("TutorialDoor", "closed")) then
			Npc:says(_"Gate status: CLOSED", "NO_WAIT")
			show("node0")
		elseif (cmp_obstacle_state("TutorialDoor", "opened")) then
			Npc:says(_"Gate status: OPEN", "NO_WAIT")
			show("node10")
		else
			Npc:says("GAME BUG. PLEASE REPORT, TUTORIAL-TERMINAL EveryTime LuaCode")
		end
		cli_says(TutorialTerminal_prompt, "NO_WAIT")
		show("node99")
	end,

	{
		id = "node0",
		--; TRANSLATORS: command,  use lowercase here
		text = _"open gate",
		echo_text = false,
		code = function()
			--; TRANSLATORS: command,  use lowercase here
			Tux:says(_"open gate", "NO_WAIT")
			Npc:says(_"Access granted. Opening gate ...")
			Npc:says(_"Gate status: OPEN")
			change_obstacle_state("TutorialDoor", "opened")
			cli_says(TutorialTerminal_prompt, "NO_WAIT")
			hide("node0") show("node10")
		end,
	},
	{
		id = "node10",
		--; TRANSLATORS: command,  use lowercase here
		text = _"close gate",
		echo_text = false,
		code = function()
			--; TRANSLATORS: command,  use lowercase here
			Tux:says(_"close gate", "NO_WAIT")
			Npc:says(_"Access granted. Closing gate ...")
			Npc:says(_"Gate status: CLOSED")
			change_obstacle_state("TutorialDoor", "closed")
			cli_says(TutorialTerminal_prompt, "NO_WAIT")
			hide("node10") show("node0")
		end,
	},
	{
		id = "node99",
		--; TRANSLATORS: command,  use lowercase here
		text = _"logout",
		echo_text = false,
		code = function()
			--; TRANSLATORS: command,  use lowercase here
			Tux:says(_"logout", "NO_WAIT")
			Npc:says(_"Exiting...")
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			if (cmp_obstacle_state("TutorialDoor", "opened")) and
			   (TutorialTom_start_chat == nil) then
					TutorialTom_start_chat = true
					start_chat("TutorialTom")
			end
			end_dialog()
		end,
	},
}
