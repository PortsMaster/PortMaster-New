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
		show("node1")
	end,

	EveryTime = function()
		play_sound("effects/Menu_Item_Deselected_Sound_0.ogg")
		Npc:says(_"[b]The Ice Pass Access Control Terminal[/b]", "NO_WAIT")
		Npc:says(_"This is a security area. Please identify or logout.")
		Npc:says(_"[b]SYSTEM ERROR[/b] A critical error occurred. Please run the chkdsk command.")
		show("node99")
	end,

	{
		id = "node0",
		--; TRANSLATORS: command, use lowercase here
		text = _"identify",
		code = function()
			--play_sound("effects/Menu_Item_Selected_Sound_1.ogg") -- (Success)
			play_sound("effects/Menu_Item_Deselected_Sound_0.ogg") -- (Failure)
			if (not Tux:has_item("PC LOAD LETTER")) then
				Npc:says(_"[b]FATAL ERROR[/b] - PC LOAD LETTER not found within A:\\.")
			elseif (not Tux:has_item("PGP key")) then
				Npc:says(_"[b]FATAL ERROR[/b] - PGP Public Key not found within B:\\.")
			elseif (not Tux:has_item("Arcane Lore")) then
				Npc:says(_"[b]FATAL ERROR[/b] - Linarian Hack Attempt detected. Connection refused.")
			else
				Npc:says(_"[b]POWER SUPPLY ERROR[/b] Insufficient energy to start up.", "NO_WAIT")
				Npc:says(_"[b]GATE ERROR[/b] Unable to ping gate. Please ensure all wires are connected correctly.", "NO_WAIT")
				Npc:says(_"[b]SYSTEM ERROR[/b] Unable to locate auth.bat file - Please run chkdsk command.") -- C:\\ is corrupted, use a defrag.
				Npc:says(_"[b]WARNING[/b] Dangerous bots may be out on the Ice Pass, beware!")
			end
			Npc:says(_"[b]WARNING[/b] Errors detected, please run chkdsk command for more information.")
			hide("node0") show("node2")
		end,
	},
	{
		id = "node1",
		--; TRANSLATORS: command, use lowercase here
		text = _"chkdsk",
		code = function()
			Npc:says(_"Please wait, we are now analyzing the peripheral systems connected to this terminal...")
			Npc:says(_"ping gate ....... [b]FAILURE[/b]", "NO_WAIT")
			Npc:says(_"The gate seems to be disconnected from this terminal, or permanently damaged.")
			Npc:says(_"energy check ....... [b]FAILURE[/b]", "NO_WAIT")
			Npc:says(_"Currently running on emergency power supply. Please wait a while.....")
			Npc:says(_"Maximum power consumption allowed: [b]0.1%%[/b]", "NO_WAIT")
			Npc:says(_"Power Control must allow at least [b]5%%[/b] of power usage in order to gates work.")
			Npc:says(_"ping lab-015 gate ....... [b]FAILURE[/b]", "NO_WAIT")
			Npc:says(_"Secret Laboratory gates are unresponsive. Dangerous bots may be out, beware!")
			Npc:says(_"Please wait, we are now analyzing this terminal filesystem...")
			Npc:says(_"Checking A:\\ ....... [b]FAILURE[/b]", "NO_WAIT")
			Npc:says(_"PC LOAD LETTER not found.")
			Npc:says(_"Checking B:\\ ....... [b]FAILURE[/b]", "NO_WAIT")
			Npc:says(_"PGP key not found.")
			Npc:says(_"Checking C:\\ ....... [b]FAILURE[/b]", "NO_WAIT")
			Npc:says(_"Hard disk may be corrupted or permanently damaged.")
			Npc:says(_"Checking D:\\ ....... [b]SUCCESS[/b]", "NO_WAIT")
			Npc:says(_"Anti-human Hack Attempt System is operating normally.")
			Npc:says(_"Checking E:\\ ....... [b]SUCCESS[/b]", "NO_WAIT")
			Npc:says(_"Anti-linarian Hack Attempt System is operating normally.")
			Tux:says(_"This terminal is so corrupted, that I believe it's better to don't touch it.")
			Tux:says(_"Also, next time, I'll not let it run verbose!")
			hide("node1") show("node0")
		end,
	},
	{
		id = "node2",
		--; TRANSLATORS: command, use lowercase here
		text = _"chkdsk --quiet --silent",
		code = function()
			-- Check for gate and for power control
			Npc:says(_"[b]GATE ERROR[/b] The gate seems to be disconnected from this terminal, or permanently damaged.")
			Npc:says(_"[b]POWER SUPPLY ERROR[/b] Power Control must allow at least [b]5%%[/b] of power usage in order to gates work.")

			-- Check for A: Load Letter
			if (not Tux:has_item("PC LOAD LETTER")) then
				Npc:says(_"[b]BOOT ERROR[/b] PC LOAD LETTER not found.")
			end

			-- Check for B: PGP System
			if (not Tux:has_item("PGP key")) then
				Npc:says(_"[b]AUTHENTICATION ERROR[/b] PGP Public Key not found.")
			end

			-- Check for E: Linarian antihack
			if (not Tux:has_item("Arcane Lore")) then
				Npc:says(_"[b]SECURITY ADVICE[/b] Anti-Linarian Hack Attempt System is Beta. Bugs may show up.")
			end

			-- Check for C: and for lab-015
			Npc:says(_"[b]SYSTEM ERROR[/b] Hard disk may be corrupted or permanently damaged.")
			Npc:says(_"[b]WARNING[/b] Secret Laboratory gates are unresponsive. Dangerous bots may be out, beware!")

			-- Overall analysis
			--Tux:says(_"There are still too many errors. I'll need to fix a few things more before trying to identify myself again.")
			Tux:says(_"I will never manage to fix this many errors. I better forget this terminal for now.")
		end,
	},
	{
		id = "node99",
		--; TRANSLATORS: command, use lowercase here
		text = _"logout",
		code = function()
			cli_says(_"Goodbye")
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		end,
	},
}
