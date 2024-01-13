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
		Cryo_Terminal_prompt = "guest@cryo-solutions: ~ # "
		Npc:says(_"Welcome to [b]Cryonic Solutions[/b]!", "NO_WAIT")
		Npc:says_random(_"We freeze you today, so you can see tomorrow!",
						_"Take the fast trip to the future with Cryonic Solutions!", "NO_WAIT")
		Npc:says(_"Please make your selection to learn more!", "NO_WAIT")
		if (not Cryo_term_unlocked) then
			show("node0", "node1", "node2", "node3")
			if (cryo_outergate_code) then
				show("node50")
			end
		else
			Npc:says(_"Admin mode.", "NO_WAIT")
			Cryo_Terminal_prompt = "admin@cryo-solutions: ~ # "
			show("node51", "node60")
		end
		cli_says(Cryo_Terminal_prompt, "NO_WAIT")
		show("node99")
	end,

	{
		id = "node0",
		text = _"About",
		code = function()
			Npc:says(_"Cryonic Solutions is a full service cryonic company.", "NO_WAIT")
			Npc:says(_"We provide not only full cryostasis, but post-stasis reintegration into the world of tomorrow!")
			Npc:says(_"Take the fast trip to the future with Cryonic Solutions!")
			--; TRANSLATORS: %d = a year
			Npc:says(_"Cryonic Solutions, since %d, is the name people trust in cryonics!", os.date("%w") + 2011)
			cli_says(Cryo_Terminal_prompt, "NO_WAIT")
			hide("node0")
		end,
	},
	{
		id = "node1",
		text = _"Appointments and visiting hours",
		code = function()
			Npc:says(_"Cryonic Solutions operates 24 hours a day every day of the year.")
			Npc:says(_"However, for the safety of our clients, visiting hours are restricted.", "NO_WAIT")
			Npc:says(_"Visiting hours for family and friends are by appointment only [b]Monday-Thursday 10:00-14:00[/b].")
			Npc:says(_"Prospective clients are welcome to make appointments from [b]15:00-17:00 Fridays[/b].", "NO_WAIT")
			cli_says(Cryo_Terminal_prompt, "NO_WAIT")
			hide("node1")
		end,
	},
	{
		id = "node2",
		text = _"Pricing",
		code = function()
			Npc:says(_"Seeing the distant future is priceless.")
			Npc:says(_"But we here at Cryonic Solutions understand that you and your loved ones have a budget. So we offer a wide range of products to make your trip to the future affordable.")
			Npc:says(_"Make an appointment today!")
			cli_says(Cryo_Terminal_prompt, "NO_WAIT")
			hide("node2")
		end,
	},
	{
		id = "node3",
		text = _"Advantages",
		code = function()
			Npc:says(_"Are you looking to experience a whole new reality?")
			Npc:says(_"Or are you interested in finding out what happens?")
			Npc:says(_"Or maybe you want to see what compound interest can do for you?")
			Npc:says(_"These are just some of the many advantages of taking the fast trip to the future with Cryonic Solutions!")
			cli_says(Cryo_Terminal_prompt, "NO_WAIT")
			hide("node3")
		end,
	},
	{
		id = "node50",
		text = "*#06#",
		code = function()
			Cryo_term_unlocked = true
			Npc:says(_"Enter command code", "NO_WAIT")
			cli_says("> ")
			Tux:says("09F911029D74E35BD84156C5635688C0")
			Npc:says(_"Unlocked. Entering admin mode...")
			Cryo_Terminal_prompt = "admin@cryo-solutions: ~ # "
			cli_says(Cryo_Terminal_prompt, "NO_WAIT")
			hide("node0", "node1", "node2", "node3", "node50") show("node51", "node60")
		end,
	},
	{
		id = "node51",
		text = _"Guest mode",
		code = function()
			Cryo_term_unlocked = false
			Npc:says(_"Entering user mode...")
			Cryo_Terminal_prompt = "guest@cryo-solutions: ~ # "
			cli_says(Cryo_Terminal_prompt, "NO_WAIT")
			hide("node51", "node60", "node70", "node80") show("node0", "node1", "node2", "node3")
		end,
	},
	{
		id = "node60",
		text = _"Gate status",
		code = function()
			if (cmp_obstacle_state("CryoOuterGate", "closed")) then
				Npc:says(_"Cryo Complex Gates status: CLOSED", "NO_WAIT")
				show("node70")
			elseif (cmp_obstacle_state("CryoOuterGate", "opened")) then
				Npc:says(_"Cryo Complex Gates status: OPEN", "NO_WAIT")
				show("node80")
		--	else -- when the door was half-opened or closed and we tried to access it, we hit this code
		--		Npc:says("GAME BUG. PLEASE REPORT, Cryo-Terminal node 60")
			end
			cli_says(Cryo_Terminal_prompt, "NO_WAIT")
		end,
	},
	{
		id = "node70",
		text = _"Open gates",
		code = function()
			Npc:says(_"Access granted. Opening gates ...")
			Npc:says(_"Cryo Complex Gates status: OPEN")
			change_obstacle_state("CryoOuterGate", "opened")
			change_obstacle_state("CryoInnerGate", "opened")
			cli_says(Cryo_Terminal_prompt, "NO_WAIT")
			hide("node70") show("node80")
		end,
	},
	{
		id = "node80",
		text = _"Close gates",
		code = function()
			Npc:says(_"Access granted. Closing gates ...")
			Npc:says(_"Cryo Complex Gates status: CLOSED")
			change_obstacle_state("CryoOuterGate", "closed")
			change_obstacle_state("CryoInnerGate", "closed")
			cli_says(Cryo_Terminal_prompt, "NO_WAIT")
			hide("node80") show("node70")
		end,
	},
	{
		id = "node99",
		text = _"Leave",
		code = function()
			Npc:says(_"Exiting Session")
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		end,
	},
}
