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
--[[WIKI
PERSONALITY = { "Robotic" },
PURPOSE = "$$NAME$$ is the next bot Tux encounters in the game. It provides some background story about bots during The Great Assault.",
BACKSTORY = "$$NAME$$ defends the Cryogenic Laboratory. $$NAME$$ offers and will provide its product history, advertising its manufacturer, on request."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	EveryTime = function()
		show("node0", "node4", "node5", "node99")
	end,

	------------------------------
	-- 614_sub
	--
	{
		topic = "614_sub",
		generator = include("614_sub"),
	},
	--
	------------------------------

	{
		id = "node0",
		text = _"Who are you?",
		code = function()
			push_topic("614_sub")
			-- call 614_sub subdialog
			next("614_sub.everytime")
		end,
	},
	{
		-- called after the end of 614_sub subdialog
		id = "after-614_sub",
		code = function()
			pop_topic()
			Npc:set_name("614 - Cryo Lab Guard Bot")
			hide("node0")
		end,
	},
	{
		id = "node4",
		text = _"Have you detected any hostile bot activity?",
		code = function()
			Npc:says(_"Order Received. Initiating proximity energy level scan...")
			Npc:says(_"***** Proximity Scan Results *****", "NO_WAIT")
			if (not HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				Npc:says(_"Hostile Numeric Presence: [b]HIGH[/b]", "NO_WAIT")
				Npc:says(_"Enemy Energy Levels: [b]LOW[/b]", "NO_WAIT")
				Npc:says(_"Threat Degree Analysis: [b]MODERATE[/b]", "NO_WAIT")
			else
				Npc:says(_"Hostile Numeric Presence: [b]NONE[/b]", "NO_WAIT")
				Npc:says(_"Threat Degree Analysis: [b]NO THREAT DETECTED[/b]", "NO_WAIT")
			end
			if (cmp_obstacle_state("CryoOuterGate", "closed")) then
				Npc:says(_"Cryo Complex Gates Status: [b]CLOSED[/b]")
			else
				Npc:says(_"Cryo Complex Gates Status: [b]OPEN[/b]")
			end
			hide("node4")
		end,
	},
	{
		id = "node5",
		text = _"What are your orders?",
		code = function()
			Npc:says(_"Primary objective: Protect the living beings inside this complex from attacks by hostile bots.")
			Npc:says(_"Secondary objective: Protect facility by locking outer gates if Threat Degree Analysis: [b]HIGH[/b].")
			cryo_614_lock_gate = true
			hide("node5")
		end,
	},
	{
		id = "node99",
		text = _"See you later.",
		code = function()
			Npc:says(_"Resuming guard program.")
			end_dialog()
		end,
	},
}
