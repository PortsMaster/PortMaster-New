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
PERSONALITY = { "Millitarist", "Devious" },
MARKERS = {
	NPCID1 = "Kevin",
	NPCID2 = "Richard",
	DROIDID1 = "614",
	QUESTID1 = "An Explosive Situation"
},
PURPOSE = "$$NAME$$ guards the inner gate to the Red Guard citadel and will refuse entry to non-Red Guard members - even if bribed!.
	 $$NAME$$ jokingly hints at $$QUESTID1$$. If Tux asks about the citadel, $$NAME$$ suggests he visit $$NPCID2$$ to learn more.",
BACKSTORY = "$$NAME$$ is at his current post after the theft of a $$DROIDID1$$ by $$NPCID1$$. $$NAME$$ is unhappy with this situation."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		Tux:says(_"Hi! I'm new h...", "NO_WAIT")
		Npc:says(_"I don't care! Identify yourself, right now!")
		--; TRANSLATORS: %s = Tux:get_player_name()
		Tux:says(_"%s... I'm %s.", Tux:get_player_name(), Tux:get_player_name())
		Npc:says(_"All right, I'm Tybalt. I'm guarding the town citadel gate. Only authorized personnel are permitted.")
		Npc:set_name("Tybalt - Citadel Gate Guard")
		show("node0", "node5", "node10")
	end,

	EveryTime = function()
		show_if((not Tux:has_met("Spencer")), "node0")

		if (cmp_obstacle_state("Town-CitadelGate", "closed")) then
			show("node10")
		end

		show_if((tybalt_bribe) and
					 (not Tybalt_money_back), "node60")

		if (tux_has_joined_guard) then
			hide("node50", "node54", "node55", "node56")
		end

		hide("node11", "node12", "node13") show("node99")
	end,

	{
		id = "node0",
		text = _"Where I can find Spencer?",
		code = function()
			Npc:says(_"You are going in the wrong direction. Turn around, and he will be on your right.")
			hide("node0")
		end,
	},
	{
		id = "node5",
		text = _"What is the citadel?",
		code = function()
			Npc:says(_"Our headquarters, the strengthened building behind me. It's the area reserved to the Red Guard.")
			Npc:says(_"We need to protect our equipment and documents: lives depend on it.")
			Npc:says(_"Our firearms are enough to kick off any droid, and to blow everything up.")
			Npc:says(_"Luckily, no overloading reactor is near it. Ha-ha.")
			hide("node5") show("node6")
		end,
	},
	{
		id = "node6",
		text = _"Is there anything secret in there?",
		code = function()
			if (not tux_has_joined_guard) then
				Npc:says(_"So, ... Hey, I don't have to answer questions!")
			else
				Npc:says(_"I have no time for a guided tour.")
				Npc:says(_"You can talk to Richard, the quartermaster. He knows the citadel better than I.")
			end
			hide("node6")
		end,
	},
	{
		id = "node10",
		text = _"I want to get into the citadel.",
		code = function()
			if (tux_has_joined_guard) then
				Npc:says(_"Of course. Guard members are always authorized to enter the town citadel. The gate is open. Enjoy your stay.")
				change_obstacle_state("Town-CitadelGate", "opened")
			else
				Npc:says(_"Sorry pal, but I don't think so. Only authorized personnel are permitted and that means members of the Red Guard.")
				Npc:says(_"Talk to Spencer if you have any business inside. I cannot let you pass.")
				-- do we propose a bribe?
				if (not tybalt_bribe) then show("node50") end
				show("node11", "node12")
			end
			hide("node10")
		end,
	},
	{
		id = "node11",
		text = _"Why is this gate locked most of the time?",
		code = function()
			Npc:says(_"It's locked so no one can sneak inside while I'm not looking. That's why.")
			if (not Tybalt_not_looking) then
				show("node13")
			end
			hide("node11", "node12")
		end,
	},
	{
		id = "node12",
		text = _"Is there another entrance to the Citadel?",
		code = function()
			Npc:says(_"Yes. All with a bunch of laser autoguns. Adjusted to shoot on sight.")
			--; TRANSLATORS: %s = Tux:get_player_name()
			Npc:says(_"%s, I discourage you to test our security system.", Tux:get_player_name())
			hide("node11", "node12")
		end,
	},
	{
		id = "node13",
		text = _"So when are you not looking?",
		code = function()
			Npc:says(_"I am always looking. What? Are you planning to steal from us, like that last guy from out of town?")
			Npc:says(_"I'm stationed here to make certain that doesn't happen again. Apparently the last guy suborned the droid that was here and took it with him.")
			Tux:update_quest("A strange guy stealing from town", _"Apparently Tybalt was stationed to stop another break-in at the Red Guard citadel. What a boring job.")
			Tybalt_not_looking = true
			hide("node13")
		end,
	},
	{
		id = "node50",
		text = _"I have a lot of money for you.",
		code = function()
			--; TRANSLATORS: "a hundred" references to a money/circuits
			Npc:says(_"Fascinating. Can I have a hundred please?")
			hide("node50") show("node54", "node55")
			push_topic("bribe citadel guard")
		end,
	},
	{
		id = "node54",
		--; TRANSLATORS: references to a money/circuits
		text = _"Erm... I don't have that much.",
		topic = "bribe citadel guard",
		code = function()
			Npc:says(_"Well, too bad.")
			hide("node54", "node55")
			pop_topic()
		end,
	},
	{
		id = "node55",
		text = _"Here you go.",
		topic = "bribe citadel guard",
		code = function()
			if (Tux:del_gold(100)) then
				Npc:says(_"Thank you.")
				tybalt_bribe = true
				show("node56")
			else
				--; TRANSLATORS: references to a money/circuits
				Npc:says_random(_"That is not a hundred.",
					--; TRANSLATORS: references to a money/circuits
					_"Um, count that again.",
					--; TRANSLATORS: references to a money/circuits
					_"Talk to me when you have a bit more.")
			end
			hide("node54", "node55")
			pop_topic()
		end,
	},
	{
		id = "node56",
		text = _"Ok, now please open the door for me.",
		code = function()
			Npc:says(_"What door?")
			Tux:says(_"The door to the citadel!")
			Npc:says(_"But you are not a member of the Red Guard.")
			Npc:says(_"You cannot come in.")
			Tux:says(_"I paid you!")
			Npc:says(_"Really? I don't remember that.")
			hide("node56") show("node60")
		end,
	},
	{
		id = "node60",
		text = _"I want my money back.",
		code = function()
			if (not tux_has_joined_guard) then
				Npc:says(_"What money?")
				Npc:says(_"I'm not a charity. If this is a problem, talk to Spencer.")
				Npc:says(_"But he doesn't love robbers and foul play.")
			else
				--; TRANSLATORS: %s = Tux:get_player_name()
				Npc:says(_"Wait, %s, maybe we may make a deal.", Tux:get_player_name())
				Npc:says(_"You don't talk to Spencer about it, and I don't tell him you tried to bribe me.")
				Npc:says(_"Just because I am such a nice guy, I'm even willing to give you half of your money back.")
				Npc:says(_"Of course, if you still want to complain, I'll get you kicked out of the Red Guard in no time.")
				Tux:add_gold(50)
				Tybalt_money_back = true
			end
			hide("node60")
		end,
	},
	{
		id = "node99",
		text = _"See you later.",
		code = function()
			Npc:says(_"Good riddance.")
			end_dialog()
		end,
	},
}
