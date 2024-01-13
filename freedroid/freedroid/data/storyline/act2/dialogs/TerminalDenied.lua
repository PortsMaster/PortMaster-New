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
		Npc:says(_"[b]Loading terminal...[/b]")
		if (Tux:has_item("PC LOAD LETTER")) then
			if ((not bot_exists("Stone")) and (Act2_ColemakAwake)) then
				show("node0")
			else
				Npc:says_random(_"[b]Access Denied.[/b]",
								_"[b]Connection Refused.[/b]",
								_"[b]Forbidden.[/b]",
								_"[b]Terminal Corrupted.[/b]",
								_"[b]ERROR: Declined.[/b]")
				end_dialog()
			end
		else
			Npc:says(_"[b]No instructions to load this terminal.[/b]")
			Tux:says(_"help", "NO_WAIT")
			Npc:says(_"This terminal needs instructions to be loaded. Instructions could be requested at last floor of factory north from town.")
			Npc:says(_"[b]WARNING:[/b] People capable of issuing authorization are all dead, killed by at weakest Battle droids.")
			-- Not everyone survives: Look for dead bodies. Battle necessary: Battle Droids. Auth -- You won't find it at last floor.
			end_dialog()
		end
		show("node99") -- Better safe than sorry.
	end,

	{
		id = "node0",
		--; TRANSLATORS: command, user lowercase here
		text = _"help",
		code = function()
			Npc:says(_"[b]Available commands: help, freeze, unfreeze, logout[/b]")
			show("node1", "node2")
		end,
	},
	{
		id = "node1",
		--; TRANSLATORS: command, user lowercase here
		text = _"freeze",
		code = function()
			Npc:says(_"[b]Failure: Either the capsule is in use or too damaged to follow proper freezing protocols.[/b]")
		end,
	},
	{
		id = "node2",
		--; TRANSLATORS: command, user lowercase here
		text = _"unfreeze",
		code = function()
			Npc:says(_"[b]WARNING: Decryonization in progress![/b]")
			Npc:says(_"[b]...[/b]")
			Npc:says(_"[b]...[/b]")
			--; TRANSLATORS: Keep First Letter (Of Word) Case Please.
			Npc:says(_"[b]...Initiating Final Unfreezing Sequences...[/b]")
			Npc:says(_"[b]Removing remaining fluids...[/b]", "NO_WAIT")
			Npc:says(_"[b]Heating chamber to 300 K...[/b]", "NO_WAIT")
			Npc:says(_"[b]WARNING: PATIENT ID #851 'Stone' HAS BEEN UNCRYONIZED![/b]")
			hide("node0", "node1", "node2")
			create_droid("StoneStartGameSquare", "PRO", "civilian", "Stone")
			set_bot_destination("StoneStartGameSquare", "Stone")
			start_chat("Stone")
			end_dialog()
		end,
	},
	{
		id = "node99",
		--; TRANSLATORS: command, use lowercase here
		text = _"logout",
		code = function()
			cli_says(_"Goodbye")
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			hide("node0", "node1", "node2")
			end_dialog()
		end,
	},
}
