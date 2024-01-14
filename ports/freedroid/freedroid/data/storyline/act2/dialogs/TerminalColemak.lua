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
			Npc:says(_"[b]Loading biologic credentials.[/b]")
			if (not RRTerminal_connected) then
				if (takeover(12)) then -- I prefer a fixed number of charges...
					show("node0")
					RRTerminal_connected = true
					Npc:says(_"[b]Welcome to this terminal.[/b]")
				else
					Npc:says(_"[b]Access Denied.[/b]")
				end
			else
				show("node0")
				if (Act2_DvorakPlanDownload) then
					show("endgame")
				end
				Npc:says(_"[b]Welcome to this terminal.[/b]")
			end
		else
			Npc:says(_"[b]No instructions to load this terminal.[/b]")
			Tux:says(_"help", "NO_WAIT")
			Npc:says(_"This terminal needs instructions to be loaded. Instructions could be requested at the final floors of factory north from town.")
			Npc:says(_"[b]WARNING:[/b] People capable of issuing authorization are all dead, killed by at weakest Battle droids.")
			-- Not everyone survives: Look for dead bodies. Battle necessary: Battle Droids. Authorization -- You won't get it at last floor.
			end_dialog()
		end
		show("node99")
	end,

	{
		id = "node0",
		--; TRANSLATORS: command, user lowercase here
		text = _"help",
		code = function()
			if (not Act2_DvorakPlanDownload) then
				Npc:says(_"[b]Available commands: help, freeze, unfreeze, logout[/b]")
			else
				Npc:says(_"[b]Available commands: help, freeze, unfreeze, download, logout[/b]")
			end
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
			if (Act2_ColemakAwake) then
				Npc:says(_"[b]Failure: Either the capsule is empty or too damaged to follow proper unfreezing protocols.[/b]")
			else
				Npc:says(_"[b]WARNING: Decryonization in progress![/b]")
				Npc:says(_"[b]...[/b]")
				Npc:says(_"[b]...[/b]")
				--; TRANSLATORS: Keep First Letter (Of Word) Case Please.
				Npc:says(_"[b]...Initiating Final Unfreezing Sequences...[/b]")
				Npc:says(_"[b]Removing remaining fluids...[/b]", "NO_WAIT")
				Npc:says(_"[b]Heating chamber to 300 K...[/b]", "NO_WAIT")
				Npc:says(_"[b]Disabling memory eraser...[/b]")
				Npc:says(_"[b]WARNING: PATIENT ID #1337 'Colemak' HAS BEEN UNCRYONIZED![/b]")
				switch_background_music("NewTutorialStage.ogg") -- Things are now weird, so we add weird music!
				Act2_ColemakAwake=true
				Npc:says(_"Current Memory Loss: 0.00%%") -- ???
				Npc:says(_"Security Personnel is on way. Estimated Time Arrival: 0 Second.")

				-- dispatch_event(eid, time) now we have an animation

				-- FIX: Check if they are alive. If not, respawn them to prevent unexpected errors.
				-- Please note current implementation allows them to shoot at you longer!
				if (SecurityChief:is_dead()) then
					create_droid('75-KillTuxPos01','GUB','ms','SecurityChief')
				end
				if (ProgrammingChief:is_dead()) then
					create_droid('75-KillTuxPos02','999','ms','ProgrammingChief')
				end

				-- make the cryo keepers hostile if they aren't already
				SecurityChief:set_faction("ms")
				ProgrammingChief:set_faction("ms")

				-- teletransport them, with delay
				play_sound("effects/new_teleporter_sound.ogg")
				SecurityChief:teleport("75-KillTuxPos01")
				SecurityChief:set_destination("75-KillTuxPos01")
				dispatch_event("75 Guard Turn Hostile", 0.5)

				 -- Colemak will carry scripts from here on.
				end_dialog()
			end
		end,
	},

	{
		id = "endgame",
		--; TRANSLATORS: command, user lowercase here
		text = _"download",
		code = function()
			if (Tux:has_item("PGP key")) then
				switch_background_music("HellFortressTwo.ogg") -- New bgsong.
				Npc:says(_"[b]Now downloading[/b] Dvorak_Plans.lua", "NO_WAIT")
				Npc:says(_"[b]...Done.[/b]")
				play_sound("effects/Menu_Item_Selected_Sound_1.ogg") -- This is where I want sounds to be played!!
				Npc:says(_"[b]Dvorak_Plans.lua[/b]", "NO_WAIT") -- Thanks for playing FreedroidRPG!
				--; TRANSLATORS: %s = Tux:get_player_name()
				Npc:says(_"Using PGP key \"%s\", decrypted successfully.", Tux:get_player_name(), "NO_WAIT")
				Tux:end_quest("Message From An Old Friend", _"I managed to download Dvorak message!")
				Npc:says(_"\n--- Begin Text Message (from Dvorak) ---", "NO_WAIT")
				--; TRANSLATORS: %s = Tux:get_player_name()
				Npc:says(_"Hello, %s. I'm Dvorak.", Tux:get_player_name(), "NO_WAIT")
				Npc:says(_"I'm sure you are dying to talk to me.", "NO_WAIT")
				Npc:says(_"I'll think of something.", "NO_WAIT")
				Npc:says(_"For now you can only listen.", "NO_WAIT")
				Npc:says("You will have to live with it for now.", "NO_WAIT")
				Npc:says("")
				Npc:says(_"Do not worry. I always have a plan.", "NO_WAIT")
				Npc:says(_"First you must rescue me. This is top priority.", "NO_WAIT")
				Npc:says(_"I am looking for some former allies now.", "NO_WAIT")
				Npc:says(_"They'll help you when time comes.", "NO_WAIT")
				Npc:says("")
				--; TRANSLATORS: %s = Tux:get_player_name()
				Npc:says(_"Where to find me? Whoa! Not so fast, %s.", Tux:get_player_name(), "NO_WAIT")
				Npc:says(_"We all want quality. And quality takes time.", "NO_WAIT")
				Npc:says(_"If you can't wait for it, please go for the Contribute section.", "NO_WAIT")
				Npc:says(_"Otherwise, this is all for now, I'm afraid.", "NO_WAIT")
				--; TRANSLATORS: %s = Tux:get_player_name()
				Npc:says(_"Good luck, %s. You'll need.", Tux:get_player_name(), "NO_WAIT")
				Npc:says("")
				Npc:says(_"Dvorak, First AI", "NO_WAIT")
				Npc:says("", "NO_WAIT")

				Npc:says(_"--- End Text Message ---", "NO_WAIT")
				Npc:says("", "NO_WAIT")
				--; TRANSLATORS: %s = Game Version
				Npc:says(_"[b]Thanks for playing FreedroidRPG %s![/b]", get_game_version())

				--display_big_message(_"Thanks for playing FreedroidRPG!")
				display_big_message(_"--- Continues ---")
				win_game()
				end_dialog()
			else
				Npc:says(_"[b]Failure:[/b] You do not have a PGP Key.")
				-- TODO: “no while, no file” → the meaning is you won't get a key if you don't explore first.
				-- TODO: A better wording is yet to be found.
				Npc:says(_"[b]Information:[/b] The comment header of the file says: No while, no file.")
				end_dialog()
			end
		end,
	},
	{
		id = "node99",
		--; TRANSLATORS: command, user lowercase here
		text = _"logout",
		code = function()
			Npc:says(_"[b]Goodbye[/b]")
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		end,
	},
}

