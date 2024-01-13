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
		show("node1", "node3")
	end,

	EveryTime = function()
		local day, hour, minute = game_date()
		SACD_year = os.date("%Y") + 45 -- current year + 45
		SACD_date_1 = string.format(_"Day %d, %02d:%02d", day, hour, minute)
		if (not SACD_login) then
			Tux:update_quest("Tania's Escape", _"I have found the Secret Area Control Datacenter.")
			Tux:add_xp(1000)
			SACD_login = true
		end
		cli_says(_"Login : ", "NO_WAIT")
		Tux:says(_"admin", "NO_WAIT")
		cli_says(_" Password : ", "NO_WAIT")
		Tux:says(_"*******", "NO_WAIT")
		if (SACD_date == nil) then
			--; TRANSLATORS: %s = a date %d = a year
			Npc:says(_"First login from /dev/ttySO on %s %d", SACD_date_1, SACD_year, "NO_WAIT")
		else
			--; TRANSLATORS: %s = a date %d = a year
			Npc:says(_"Last login from /dev/ttyS0 on %s %d", SACD_date, SACD_year, "NO_WAIT")
		end
		SACD_date = SACD_date_1
		cli_says(_"admin@sadefence: ~ #", "NO_WAIT")
		hide("node2") show("node99")
	end,

	{
		id = "node1",
		text = _"/usr/bin/guns --disable",
		code = function()
			Npc:says(_"Disabling guns...")
			Npc:says(_"Connecting to peripheral controller...")
			Npc:says(_"Guns disabled.")
			SACD_gunsoff = true
			change_obstacle_state("SADDGun1", "disabled")
			change_obstacle_state("SADDGun2", "disabled")
			cli_says(_"admin@sadefence: ~ #", "NO_WAIT")
			hide("node1") show("node2")
		end,
	},
	{
		id = "node2",
		text = _"/usr/bin/guns --enable",
		code = function()
			Npc:says(_"Enabling guns...")
			Npc:says(_"Connecting to peripheral controller...")
			Npc:says(_"ERROR: Guns cannot be enabled.")
			--; TRANSLATORS: use lowercase for "admin"
			cli_says(_"admin@sadefence: ~ #", "NO_WAIT")
		end,
	},
	{
		id = "node3",
		text = _"/usr/bin/hermodoors --open",
		code = function()
			Npc:says(_"Opening doors...")
			Npc:says(_"Connecting to peripheral controller...")
			change_obstacle_state("SACD-North-1", "opened")
			change_obstacle_state("SACD-North-2", "opened")
			change_obstacle_state("SACD-North-3", "opened")
			change_obstacle_state("SA-Main-EastN", "opened")
			change_obstacle_state("SA-Main-EastS", "opened")
			change_obstacle_state("SA-Main-WestN", "opened")
			change_obstacle_state("SA-Main-WestS", "opened")
			change_obstacle_state("SA-Main-Enter", "opened")
			Npc:says(_"ERROR: An error occurred while opening some doors.")
			Npc:says(_"Please enter unlock security override password:")
			Tux:says(_"CTRL+C")
			Npc:says(_"Invalid password. Entering lockdown mode.")
			Npc:says(_"ERROR: Lockdown mode encountered an error.", "NO_WAIT")
			Npc:says(_"ERROR: error encountered an error.", "NO_WAIT")
			if (bot_exists("SADD")) then
				Npc:says(_"ERROR: SADD droids now set to search-and-destroy mode.")
				SADD:set_faction("ms")
				SADD:set_name("SADD - Exterminate Mode")
				SADD:set_destination("SADD-MoveTarget")
			end
			cli_says(_"admin@sadefence: ~ #", "NO_WAIT")
			hide("node3")
		end,
	},
	{
		id = "node99",
		text = _"logout",
		code = function()
			end_dialog()
		end,
	},
}
