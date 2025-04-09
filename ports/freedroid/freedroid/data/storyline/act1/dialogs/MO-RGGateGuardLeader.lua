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
PERSONALITY = { "Militarist", "Abrasive" },
BACKSTORY = "$$NAME$$ is the leader of the defense structure near the Hell Fortress",
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		Npc:says(_"Hey, Linarian! What do you want here?")
		show("node1", "node2", "node3")
	end,

	EveryTime = function()
		if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
			Npc:says_random(_"Congratulations on getting the job done.",
				_"We should rename this place. You did a fine job.",
				_"A bot?! Ah, no, it's just you. I will stay here in case something goes wrong.",
				_"Peace, finally. The perfect time to prepare for the next strike! The world is far from safe!",
                _"I always carry a gun with me. Who knows, bots may come back!")
			end_dialog()
		elseif (Tux:has_met("MO-RGGateGuardLeader")) then
			if (Tux:done_quest("Opening access to MS Office")) then
				if (MO_RGGateGuardLeader_informed) then
					next("node20")
				else
					Npc:says(_"Hey, Linarian! What do you want here?")
				end
			else
				Npc:says(_"GET OUT OF HERE YOU IDIOT!")
				next("node99")
			end
		end
	end,

	{
		id = "node1",
		text = _"Just taking a look around.",
		code = function()
			Npc:says(_"Oh, look. The bird wants to go for a walk.", "NO_WAIT")
			Npc:says(_"We don't call this place 'hell' for nothing.")
			Npc:says(_"Get outta here!")
			hide("node1", "node3") next("node99")
		end,
	},
	{
		id = "node2",
		text = _"I'd like to go through that gate.",
		code = function()
			Npc:says(_"Are you totally out of your mind?", "NO_WAIT")
			Npc:says(_"There are trillions of millions of quintillions of bots in there!")
			Npc:says(_"Besides that, on the other side of the door is a disruptor shield, which we can't control.")
			Npc:says(_"* Throws a stone through the door")
			if (Tux:done_quest("Opening access to MS Office")) then
				Npc:says(_"* Stone freely flies through the gate and drops on the ground on the other side")
				Npc:says(_"HOLY MECHANICAL MARVEL! SHIELD DISABLED! PREPARE FOR BOT ATTACK!")
				next("node10")
			else
				Npc:says(_"* Stone disappears leaving a small cloud of dust *")
				Npc:says(_"Find a different gate to go through.")
				next("node99")
			end
			hide("node1", "node3")
		end,
	},
	{
		id = "node3",
		text = _"I have some business on the other side!",
		code = function()
			Npc:says(_"Are you in a rush to die?")
			Npc:says(_"Go away!")
			hide("node1", "node3") next("node99")
		end,
	},
	{
		id = "node10",
		text = _"Calm down. This is not an attack. I've disabled the shield and I'm going to disable all the bots around! Didn't Spencer inform you?",
		echo_text = false,
		code = function()
			Tux:says(_"Calm down. This is not an attack. I've disabled the shield and I'm going to disable all the bots around! Didn't Spencer inform you?") -- necessary due usage of next()
			Npc:says(_"WHAT?! Not an attack?!")
			Npc:says(_"I hope you are telling the truth. One second...")
			if (Tux:has_quest("Propagating a faulty firmware update")) then
				change_obstacle_state("MSAreaDoor", "opened")
				MO_RGGateGuardLeader_informed = true
				next("node20")
			else
				Npc:says(_"Nothing from Spencer, ya fat duck. Now leave.")
				end_dialog()
			end
		end,
	},
	{
		id = "node20",
		code = function()
			Npc:says(_"Right, there is a message from Spencer, you can enter Hell Fortress. And may the source be with you!")
			Tux:says(_"See...")
			Npc:says(_"Yeah, you were right...")
			end_dialog()
		end,
	},
	{
		id = "node99",
		text = _"Relax, I'm leaving.",
		echo_text = false,
		code = function()
			Tux:says(_"Relax, I'm leaving.") -- necessary due usage of next()
			Npc:says(_"You better be. AND DON'T COME BACK!")
			end_dialog()
		end,
	},
}
