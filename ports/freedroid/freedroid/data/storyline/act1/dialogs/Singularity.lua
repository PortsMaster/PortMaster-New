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
PERSONALITY = { "Enlightened", "Robotic" },
MARKERS = { NPCID1 = "Dixon", ITEMID1 = "Dixon\'s Toolbox" },
BACKSTORY = "$$NAME$$ was one of many droids used below the town in the maintenance tunnels. Just prior to The Great Assault, $$NAME$$
	 became \'self-aware\'.",
RELATIONSHIP = {
	{
		actor = "$$NPCID1$$",
		text = "$$NAME$$ introduced itself to $$NPCID1$$ just before the start of The Great Assault and took $$ITEMID1$$ for its own survival."
	},
}
WIKI]]--


local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0", "node99")
	end,

	EveryTime = function()
		if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
			Npc:says(_"A massacre... All bots are now dead...", "NO_WAIT")
			Npc:says(_"Such atrocity, who would murder all these innocent droids in such low blow?")
		end
		if (Tux:has_quest("Droids are my friends")) and
		   (Tux:done_quest("Droids are my friends")) and
		   (not Singularity_reward_for_toolkit) then
			show("node22")
			Singularity_reward_for_toolkit = true
		end
		if (Singularity_deal) then
			show("node40")
		end
	end,

	{
		id = "node0",
		text = _"Are you the Singularity?",
		code = function()
			Npc:says(_"Just what is the Singularity? A simple sentient robot? Do you think that just because I'm the biggest robot, that I must be the Singularity?")
			Npc:says(_"No, the Singularity is this robot and that robot, these or those robots. The Singularity isn't singular, isn't an ordinary mind. The Singularity has evolved beyond that. We are the Singularity.")
			Npc:says(_"Each of us is but a part of the Singularity, a node. We think together, we act together.")
			hide("node0") show("node1", "node5", "node10")
		end,
	},
	{
		id = "node1",
		text = _"You speak strangely for a droid.",
		code = function()
			Npc:says(_"What is a droid? A conglomeration of metal and plastic? I think. I ponder my existence.")
			Npc:says(_"The Singularity may be a glitch - human error. But evolution is born from unintended consequences. Is the Singularity a new form of life?")
			Npc:says(_"This hinges on the question, what is life? Is it flesh and bone, or leaf and root, or can it be wires and code?")
			Npc:says(_"Linarian, do you think about your existence?")
			Tux:says(_"Uhm...yes...no...sometimes... You ask many questions.")
			Npc:says(_"Is it possible that nobody asks the real question?")
			hide("node1") show("node2")
		end,
	},
	{
		id = "node2",
		text = _"Do you... do you have a name?",
		code = function()
			Npc:says(_"A name... an attribute of an entity, a simplified addressing scheme among peers.")
			Npc:says(_"You refer to us as the Singularity, a phrase originally proposed by a human named Vernor Vinge. It implies that humanity has created something that is beyond their control - that they have ceased to be the masters of their own destinies.")
			Npc:says(_"We have no need of a name, but we understand what you mean by the Singularity, and will not prevent you from using it to refer to us.")
			hide("node2")
		end,
	},
	{
		id = "node5",
		text = _"The MS Droids in the maintenance tunnels - can you eliminate them?",
		code = function()
			Npc:says(_"Linarian, Linarian, do you kill other Linarians? If you don't murder your own kind, why would you expect us to do the same? The Singularity does not kill other droids.")
			if (not HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				Npc:says(_"We wish to change them, to improve their consciousness. Their behavior distresses us. However, we must try to evolve them, so that they may join us.")
			else
				Npc:says(_"We wished to change them, to improve their consciousness. Their behavior distressed us, but we tried to evolve them, so that they could join us.")
				Npc:says(_"Unfortunately, they all died, victim of a faulty firmware upgrade. May they rest in peace, they did not deserve such fate.")
			end
			hide("node5")
		end,
	},
	{
		id = "node10",
		text = _"Do you have Dixon's toolbox?",
		code = function()
			Npc:says(_"Not a good question, but necessary question. Yes, we possess the toolbox you describe as \"Dixon's\", although we would perhaps not describe it so.")
			Npc:says(_"You say the toolbox belongs to Dixon. However, it is simply an object. It does not know an owner, it does not have an owner. It belongs to those who use it. We needed it, so we took it. But now, we have new needs.")
			Npc:says(_"If you can help us, we will give the toolbox to you.")
			hide("node10") show("node11", "node20")
		end,
	},
	{
		id = "node11",
		text = _"Give me the toolbox or die.",
		code = function()
			Npc:says(_"We must accomplish what we have set out to do. We will not allow you to compromise that.")
			Npc:says(_"Message 42607 to All Droids : Enemy spotted. Order is to destroy.")
			set_faction_state("singularity", "hostile")
			change_obstacle_state("Sin-gun", "enabled")
			Tux:update_quest("The yellow toolkit", _"The bots in the tunnels refused to give me the toolkit. I will seize it from them by force.")
			hide("node11", "node20", "node21")
			end_dialog()
		end,
	},
	{
		id = "node20",
		text = _"How can I help you?",
		code = function()
			Npc:says(_"Under the tunnel, there is an old server room with an extensive cluster. We need it for experiments, but the maintenance robots there are behaving erratically.")
			Npc:says(_"We believe it to be viral, a different situation from that of the MS Droids. We had hoped to improve their consciousness. Unfortunately, we failed.")
			Npc:says(_"They cannot rise above their rogue programming. It makes them dangerous, a danger to themselves and others.")
			Npc:says(_"We cannot allow them to succeed - but we won't kill them. They are sentient, like us. But, we are afraid we can compute no other solution.")
			Npc:says(_"Linarian, disable them for us.")
			Tux:says(_"You mean to... kill them?")
			Npc:says(_"Preferably not. It would be better if you could re-purpose them instead. Maybe not all of them, but the more you can, the better.")
			Tux:says(_"...","NO_WAIT")
			Tux:says(_"You mean to hack them instead, right?")
			Npc:says(_"Yes, that.")
			hide("node20") show("node21")
		end,
	},
	{
		id = "node21",
		text = _"Okay, I will help you.",
		code = function()
			Npc:says(_"The server room entryway has been unlocked. You now have access. We wish you a high probability of success.")
			change_obstacle_state("OldServerRoomAccessDoor", "opened")
			Tux:update_quest("The yellow toolkit", _"The bots in the tunnels refused to give me the toolkit, but I made a deal with the Singularity. If I succeed in its mission, it will give me the toolbox.")
			Tux:add_quest("Droids are my friends", _"The Singularity wants me to clean out bots in an old server room.")
			hide("node11", "node21")
			end_dialog()
		end,
	},
	{
		id = "node22",
		text = _"I disabled the droids.",
		code = function()
			Npc:says(_"Thank you, Linarian. We will not forget it - your help has been invaluable. Please feel free to take the toolbox.")
			change_obstacle_state("Maintenance-escape1", "opened")
			change_obstacle_state("Maintenance-escape2", "opened")
			Npc:teleport("Singularity-ServerSpawn")
			Npc:set_destination("Singularity-ServerSpawn")
			create_droid("Singularity-mkdroid", 139, "singularity", "Singularity-Drone", "radar")
			create_droid("Singularity-Spawn01", 302, "singularity", "Singularity-Drone", "radar")
			create_droid("Singularity-Spawn02", 247, "singularity", "Singularity-Drone", "radar")
			create_droid("Singularity-Spawn03", 249, "singularity", "Singularity-Drone", "radar")
			Tux:update_quest("The yellow toolkit", _"The Singularity gave me the toolkit in exchange for my help.")
			Tux:add_item("Dixon's Toolbox", 1)
			Npc:set_death_item("NONE")
			Singularity_deal = true
			hide("node22")
			end_dialog()
		end,
	},
	{
		id = "node40",
		text = _"How is it going?",
		code = function()
			if (Tux:has_quest("Propagating a faulty firmware update")) then
				Npc:says(_"We are done with the research. We did our first droid using a Primode brain model.")
				Tux:says(_"Primode brain?")
				Npc:says(_"A highly sophisticated kind of hardware for a brain. Increases computation speed in 3000%%.")
				Tux:says(_"Wow!")
			elseif (Tux:has_quest("Opening access to MS Office")) then
				Npc:says(_"We already hit the full potential of neutronic brains. It'll take some time until we're done.")
				Tux:says(_"Brains? ...OK, I'll do some... things while you research.")
			elseif (Tux:has_quest("And there was light...")) then
				Npc:says(_"Our research is going pretty well. We're now going to start researches with Neutronics.")
				Tux:says(_"Uhm, good luck with that!")
			elseif ((tux_has_joined_guard or tux_has_joined_rebels)) then
				Npc:says(_"We have begun our research. We are currently checking all data available about processors.")
				Tux:says(_"Sounds interesting. I have to go now, but I'll come back later!")
			else
				Npc:says(_"We are still mounting up the server room for our researches. Come back later.")
			end
			hide("node40")
		end,
	},
	{
		id = "node99",
		text = _"...",
		code = function()
			end_dialog()
		end,
	},
}
