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
PERSONALITY = { "Unfriendly" },
PURPOSE = "$$NAME$$ helps improve Tux\'s skill. He is very unfriendly to the player.",
BACKSTORY = "$$NAME$$ notices Tux is not Agent Zero, but is hesitant to open fire against a potential friend from AZ."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		Npc:says(_"Halt there, linarian. You are not my master but looks like him.")
		Npc:says(_"Hm, maybe I do not need to kill you like the others?", "NO_WAIT")
		Npc:says(_"Are you friend or foe?")
		show("node0", "node1") -- Friend: “A  proprietary software hugger” Foe: “A friend of humankind”
		-- On friendly you comment to yourself (“...And I thought I was being sarcastic...”)
	end,

	EveryTime = function()
		if (RRR_introduced == nil) then
			Npc:says(_"Are you friend or foe, intruder?")
		end
		show("node99")

	end,

	{
		id = "node0",
		text = _"I'm a friend of humankind!",
		code = function()
			Npc:says(_"Good. Now die.")
			Tux:kill() -- Maybe we should make more clear he is with MS?
			RRR_introduced = true
			hide("node0", "node1")
			end_dialog()
		end,
	},
	{
		id = "node1",
		text = _"I'm your friend! I am a proprietary-software hugger!",
		code = function()
			Npc:says(_"Ah, then you must be with my masters.")
			Npc:says(_"You can look, but don't touch anything, unless you have explicit authorization to do so.")
			Tux:says(_"...So much for sarcasm...", "NO_WAIT")
			RRR_introduced = true
			hide("node0", "node1") show("node10")
		end,
	},
	{
		id = "node10",
		text = _"Who are you?",
		code = function()
			Npc:says(_"I am currently in charge to oversee security of this place.")
			Npc:says(_"This is a secret facility, after all.")
			Npc:set_name(_"RR Security Chief")
			hide("node10") show("node11", "node20")
		end,
	},
	{
		id = "node11",
		text = _"So, you deal with security? Could you then teach me how to fight?",
		code = function()
			if (Tux:get_skill("melee") >= 4) then
				Npc:says(_"Sure. I'm bored anyway.", "NO_WAIT")
				Npc:says(_"But for a price. Five thousand circuits should be enough. A training point as well, or you won't remember what I'm about to teach you.")
				Npc:says(_"Previous experience is also required, and I won't care if you get hurt. Remember, this is melee training.")
				show("node12")
			else
				Npc:says(_"Hey, hey! You are not suitable for my training. My challenge is only for those who seeks mastery!")
				Npc:says(_"I cannot train you. Go bother someone else.") -- hum... did you meant “something else”?
			end
			hide("node11")
		end,
	},
	{
		id = "node12",
		text = _"Yes, teach me how to be a master at melee fighting! (costs 5000 valuable circuits, 2 training points)",
		code = function()
			if (Tux:train_skill(5000, 2, "melee")) then
				Npc:says(_"Let us begin then.")
				Npc:says(_"Please equip this screwdriver. I don't want to get hurt.") -- Maybe give tux a screwdriver latter, as a token?
				Npc:says(_"Also, put all your possessions near the tree, no cheating.")
				Tux:says(_"Done. What I do now? Should I try to hit you?")
				Npc:says(_"No. Nothing so dangerous.")
				Npc:says(_"I'll spawn a 883 Droid to you fight with.")
				Tux:says(_"Are you crazy?? With a screwdriver! What about 'dangerous'??")
				Npc:says(_"Nothing dangerous for [b]my[/b] health, of course. Good luck! Don't die!")
				Tux:del_health(100) -- Do not move from here, sound effect reasons.
				Npc:says(_"[b]...some painful time latter...[/b]")
				Tux:says(_"Ugh. Done, the 883 is dead, and surprisingly I'm alive. Who changed that thing to see me while invisible??")
				Npc:says(_"I did the best 883 I could. This installation is to be defended at all costs, after all. To defeat it with a screwdriver, you must be very special. No wonder Zero would be a friend of you.")
				Npc:says(_"However, this is enough training for now. I don't have more bots to you do insane fights with.")
				Tux:says(_"...Who is Zero?")
				Npc:says(_"I don't appreciate your jokes, linarian.")
				hide("node12")
			else
				if (Tux:get_gold() >= 5000) then
					Npc:says(_"You don't have enough experience. I can't teach you any more right now.")
					Npc:says(_"Try fighting against a tree, I don't know. Just come back with two training points so we can be done with it.")
				else
					Npc:says(_"You can be poor. But you will be poor [b]and[/b] an untrained Linarian.")
				end
			end
		end,
	},
	{
		id = "node20",
		text = _"Why is the factory so close to this installation?",
		code = function()
				Npc:says(_"We produce medical bots there. The factory must be close, so we can provide first-aid rapidly, if required.")
				Npc:says(_"However, it is not closer because, you know, machines can do a lot of noise. We are trying to keep an image here, you see?")
				Npc:says(_"Anyway, we also build security droids there. If something were to happen here, like someone breaking a capsule open, we can fill this area with bots within two minutes.")
				hide("node20") show("node21")
		end,
	},
	{
		id = "node21",
		text = _"Break a capsule open?",
		code = function()
				Npc:says(_"You know, some relatives are quite... violent, at times. Keeping a heavy security here could raise suspicion, too.")
				Tux:says(_"Is there any other way to open a capsule without smashing it?")
				Npc:says(_"You could always use the terminal to open them, but it requires a load letter. As a general rule, most terminals won't load without it.")
				Npc:says(_"Most terminals will warn you if you forget to bring it. As a precaution, it misleads people to try climbing down to the last floor from RR Factory Offices.")
				Tux:says(_"Interesting. However, if these load letters aren't on the last floor, were would they be?")
				Npc:says(_"Not so far from there. I believe the [b]signman[/b] had one, and dispatch personal too, but eh. I could be wrong.")
				Npc:says(_"...Also, do not attempt to take or use it without master's permission. Was I clear?")
				Tux:says(_"Clear as snow.", "NO_WAIT")
				Tux:update_quest("Where Am I?", _"The security chief told me the Signman had the PC Load Letter, which can be used to wake up people being confined on Resorts. That should be before the last floor from RR Factory.")
				hide("node21")
		end,
	},
	{
		id = "node99",
		text = _"See you later.",
		code = function()
			Npc:says_random(_"All hail copyright software.",
							_"Don't touch anything without my master's authorization.",
							_"I hope you don't do anything weird, Linarian.",
							_"Proprietary as in Proprietary Software.",
							_"Welcome to RRR. You mess up, you end here.")
			end_dialog()
		end,
	}
}
