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
		RRGateTerminal_prompt = "guest@management.rrf: ~ #"

		cli_says(_"Login : ", "NO_WAIT")
		--; TRANSLATORS: username, maybe this should stay in lowercase letters?
		Tux:says(_"guest", "NO_WAIT")
		cli_says(_"Entering as guest", "NO_WAIT")
		Npc:says("", "NO_WAIT")

		if (cmp_obstacle_state("RRF-F9-ShortcutTrapdoor", "closed")) then
			Npc:says(_"Shortcuts: DISABLED", "NO_WAIT")
			show("node0") hide("node10")
		elseif (cmp_obstacle_state("RRF-F9-ShortcutTrapdoor", "opened")) then
			Npc:says(_"Shortcuts: ENABLED", "NO_WAIT")
			Npc:says(_"[b]NOTE[/b] The lift to Factory Core is at Floor 3.", "NO_WAIT")
			show("node10") hide("node0")
		else
			Npc:says("GAME BUG. PLEASE REPORT, RRF_MANAGMENTTERMINAL F9 EveryTime LuaCode")
			hide("node0", "node10")
		end


		if (cmp_obstacle_state("RRF-F6Gate", "closed")) then
			Npc:says(_"Currently, maximum access is set to Security Development Office.", "NO_WAIT")
			show("node30") hide("node40")
		elseif (cmp_obstacle_state("RRF-F6Gate", "opened")) then
			Npc:says(_"Currently, there is no maximum access set.", "NO_WAIT")
			Npc:says(_"[b]WARNING[/b] People may die if they get lost!", "NO_WAIT")
			show("node40") hide("node30")
		else
			Npc:says("GAME BUG. PLEASE REPORT, RRF_MANAGMENTTERMINAL F6 EveryTime LuaCode")
			hide("node30", "node40")
		end

		cli_says(RRGateTerminal_prompt, "NO_WAIT")
		show("node99")
	end,

	{
		id = "node0",
		--; TRANSLATORS: command,  use lowercase here
		text = _"enable shortcuts",
		echo_text = false,
		code = function()
			--; TRANSLATORS: command,  use lowercase here
			Tux:says(_"enable shortcuts", "NO_WAIT")
			if (Tux:has_item("MS Stock Certificate")) then
				Npc:says(_"MS Stock Certificate found and validated. Welcome, [b]Will Gapes[/b]!", "NO_WAIT")
				Npc:says(_"Shortcuts status: ENABLED")
				change_obstacle_state("RRF-F9-ShortcutTrapdoor", "opened")
			else
				Npc:says(_"I'm afraid you are not authorized to do so.")
				Npc:says(_"Please contact your Chief Officer in order to change this setting.")
			end
			cli_says(RRGateTerminal_prompt, "NO_WAIT")
			hide("node0") show("node10")
		end,
	},
	{
		id = "node10",
		--; TRANSLATORS: command,  use lowercase here
		text = _"disable shortcuts",
		echo_text = false,
		code = function()
			--; TRANSLATORS: command,  use lowercase here
			Tux:says(_"disable shortcuts", "NO_WAIT")
			if (Tux:has_item("MS Stock Certificate")) then
				Npc:says(_"MS Stock Certificate found and validated. Thanks for visiting, [b]Will Gapes[/b]!", "NO_WAIT")
				Npc:says(_"Shortcuts status: DISABLED")
				change_obstacle_state("RRF-F9-ShortcutTrapdoor", "closed")
			else
				Npc:says(_"I'm afraid you are not authorized to do so.")
				Npc:says(_"Please contact your Chief Officer in order to change this setting.")
			end
			cli_says(RRGateTerminal_prompt, "NO_WAIT")
			hide("node10") show("node0")
		end,
	},
	{
		id = "node30",
		--; TRANSLATORS: command,  use lowercase here
		text = _"disable maximum access",
		echo_text = false,
		code = function()
			--; TRANSLATORS: command,  use lowercase here
			Tux:says(_"disable maximum access", "NO_WAIT") -- misleading on purpose
			Npc:says(_"[b]SECURITY WARNING[/b] Control Gate is now disabled.", "NO_WAIT")
			Npc:says(_"[b]WARNING[/b] People may die if they get lost!")
			change_obstacle_state("RRF-F6Gate", "opened")
			cli_says(RRGateTerminal_prompt, "NO_WAIT")
			hide("node30") show("node40")
		end,
	},
	{
		id = "node40",
		--; TRANSLATORS: command,  use lowercase here
		text = _"enable maximum access",
		echo_text = false,
		code = function()
			--; TRANSLATORS: command,  use lowercase here
			Tux:says(_"enable maximum access", "NO_WAIT")
			Npc:says(_"[b]SECURITY[/b] Control Gate is now enabled.") -- No one needs to die!
			change_obstacle_state("RRF-F6Gate", "closed")
			cli_says(RRGateTerminal_prompt, "NO_WAIT")
			hide("node40") show("node30")
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
			end_dialog()
		end,
	},
}
