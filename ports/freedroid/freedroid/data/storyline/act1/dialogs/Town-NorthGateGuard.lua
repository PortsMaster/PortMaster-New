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
PERSONALITY = { "Militaristic", "Vigilant", "Condescending" },
MARKERS = { NPCID1 = "Kevin", QUESTID1 = "A strange guy stealing from town" },
PURPOSE = "$$NAME$$ is the first town resident and Red Guard member Tux encounters.",
BACKSTORY = "$$NAME$$ aggressively guards the main entrance to town. $$NAME$$ lost his sister in The Great Assault.",
RELATIONSHIP = {
	{
		actor = "$$NPCID1$$",
		text = "$$NAME$$ is angry at the theft undertaken by $$NPCID1$$. $$NAME$$ does not know who $$NPCID1$$ is but
		 wants him found. This initiates $$QUESTID1$$."
	},
}
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	EveryTime = function()
		Town_NorthGateGuard_doors1 = {"Main Gate Outer W", "Main Gate Outer E", "Main Gate Guardhouse"}
		Town_NorthGateGuard_doors = {Town_NorthGateGuard_doors1[1], Town_NorthGateGuard_doors1[2], Town_NorthGateGuard_doors1[3], "Main Gate Inner W", "Main Gate Inner E"}
		if (not Tux:has_met("Town-NorthGateGuard")) then
			Npc:says(_"Hey you! Linarian! What do you want here?")
			show("node1", "node2", "node3")
			Npc:set_rush_tux(false)
			guard_follow_tux = true
		elseif (Npc:get_rush_tux()) then
			Npc:set_rush_tux(false)
			if (Town_NorthGateGuard_tux_nickname_loon) then
				Npc:says_random(_"Oh, the loon has returned.",
								_"Oh, it's just the loon. No need to worry.")
			else
				Npc:says_random(_"Oh, it's you.",
								_"I see you have returned.",
								_"You just can't get enough, can you?")
			end
			end_dialog()
		else
			if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				Npc:says(_"I'm ever vigilant! Bots are all dead? And what? I have a gate to guard! It's my duty, and I won't fail!")
				Npc:says(_"[b]*in whisper* ... Not like I did with you, dear...[/b]")
				Npc:says(_"Pretend you've heard nothing and mind your own business, Linarian.")
				end_dialog()
			else
				Tux:says(_"Can I ask you something?")
				if (Town_NorthGateGuard_tux_nickname_loon) then
					Npc:says(_"Yes, Loon.", "NO_WAIT")
				end
				Npc:says(_"You can ask, but don't expect a reply.", "NO_WAIT")
				Npc:says(_"I'm guarding this gate, and if I get distracted the bots might overrun this town and kill everybody in it.")
			end
		end
		show_if(knows_spencer_office, "node41")
		if (KevinMurder) and
		   (not Tux:done_quest("A strange guy stealing from town")) and
		   (Tux:has_quest("A strange guy stealing from town")) then
			show("node50")
		end
	end,

	{
		id = "node1",
		text = _"Just taking a look around.",
		code = function()
			Npc:says(_"Oh, great. Another curious one.")
			Npc:says(_"About a week ago I let in a stranger who also said he was just taking a look around. I never saw him again. And I'm making sure he won't be getting back in either.")
			hide("node1", "node2", "node3") show("node5")
		end,
	},
	{
		id = "node2",
		text = _"I'd like to get into town.",
		code = function()
			Npc:says(_"Funny, exactly the same could be said about all of the crazy bots out there.")
			Npc:says(_"Not to mention that weird guy that came by last week. The only place in town he is going next time is straight into a holding cell.")
			hide("node1", "node2", "node3") show("node5")
		end,
	},
	{
		id = "node3",
		text = _"I'm here to assassinate your leader and you won't stop me!",
		code = function()
			Npc:says(_"Ok, Linarian! You asked for it!")
			Npc:says(_"Open fire!")
			for var in ipairs(Town_NorthGateGuard_doors1) do
				change_obstacle_state(Town_NorthGateGuard_doors1[var], "closed")
			end
			set_faction_state("redguard", "hostile")
			Tux:kill()
			end_dialog()
			hide("node1", "node2", "node3") show("node99")
		end,
	},
	{
		id = "node5",
		text = _"Oh? Who was he? And why?",
		code = function()
			Npc:says(_"Heh, you sure are a curious little bird, in more than one way I might say.")
			Npc:says(_"On the day he visited all our computers went insane, 20 bags of food rations vanished from our storage and one of our bots was stolen.")
			Npc:says(_"I think that freak lives somewhere to the east. I would love to get my hands on him and beat the life out of him. Slowly.")
			if (not Tux:has_met("Kevin")) then
				Tux:add_quest("A strange guy stealing from town", _"The guard in charge at the entrance of the town mentioned that somebody sneaked into town recently, and stole food and hardware. Apparently he lives somewhere to the east.")
			elseif (Kevin:is_dead()) then
				Tux:add_quest("A strange guy stealing from town", _"The guard told me about a guy who stole some food and hardware from the town. He lives somewhere in the east.")
				Tux:end_quest("A strange guy stealing from town", _"Apparently it was this Kevin person I recently hit a bit too hard... Oops... Well, at least he won't steal again...")
				Tux:add_xp(70)
			else
				Tux:add_quest("A strange guy stealing from town", _"Ooops, the guard must be talking about Kevin. I'd better not mention I know him and where he lives, or I might find myself in a holding cell or being forced to show the guards straight to his home. But I guess that explains where Kevin got that 614 bot from.")
				Tux:add_xp(100)
				-- We should perhaps not end quest here but later when talking again to Kevin and asking about the comps
				Tux:end_quest("A strange guy stealing from town", _"Though, I probably should ask Kevin some day what he was doing with the town computers.")
			end
			if (not Tux:has_met("Kevin")) and
			   (not Kevin:is_dead()) then
				show("node10") -- We should add other nodes in the other cases.
			end
			hide("node5") show("node11")
		end,
	},
	{
		id = "node10",
		text = _"Somewhere to the east? I should look for him.",
		code = function()
			Npc:says(_"Oh, definitely, and I'm sure all the bots out there will be glad to give you directions, too.")
			Npc:says(_"But if you're insanely lucky and you do find him, you come back straight to me, understand?")
			Npc:says(_"I'd like to wring his head off... Though, it's not my call. But who knows, if the Boss feels generous we might both get rewarded.")
			Npc:says(_"Be careful anyway, this creep is a sneaky one if he got past us.")
			Tux:update_quest("A strange guy stealing from town", _"I offered to find out who the strange guy is. The guard I talked to was pretty sceptical, though; I should get some experience and better equipment before travelling far outside of town.")
			next("node15")
		end,
	},
	{
		id = "node11",
		text = _"Surely he'll never come back here.",
		code = function()
			Npc:says(_"I'm not counting on that. The criminal always comes back to the scene of the crime.")
			Npc:says(_"And that's the last stupid thing they do. You can't steal from the Red Guard twice.")
			next("node15")
		end,
	},
	{
		id = "node15",
		code = function()
			Npc:says(_"In any case...")
			Npc:says(_"We've changed our security policy. Our leader, Spencer, wants to interrogate any strangers we let in.")
			Npc:says(_"You have to talk to him before you head out into the town to do stupid things.")
			Npc:says_random(_"And up until you do, a guard will be following you. We'll be watching you.",
							_"And until you do, one of us will be following you. I'll let the others know you've arrived.")
			Npc:says_random(_"I'll let you in now, but be warned: one false move and we all have flightless waterfowl for dinner. Am I making myself clear?",
							_"Linarian, I will let you in. Do something stupid, and you aren't coming out. Got it?")
			hide("node10", "node11") show("node16", "node17")
		end,
	},
	{
		id = "node16",
		text = _"Yes. I understand.",
		code = function()
			Npc:says(_"State your name Linarian.")
			--; TRANSLATORS: %s = Tux:get_player_name()
			Tux:says(_"My name is %s.", Tux:get_player_name())
			Npc:says(_"You don't look too stupid. Try not to mess up.")
			--; TRANSLATORS: %s = Tux:get_player_name()
			Npc:says(_"You may now enter %s.", Tux:get_player_name())
			hide("node16", "node17") next("node40")
		end,
	},
	{
		id = "node17",
		text = _"No. Not at all. Your mother dresses you funny.",
		code = function()
			Npc:says(_"What did you say, you oversized duck?")
			for var in ipairs(Town_NorthGateGuard_doors1) do
				change_obstacle_state(Town_NorthGateGuard_doors1[var], "closed")
			end
			hide("node16", "node17") show("node20", "node21", "node22", "node23", "node30")
		end,
	},
	{
		id = "node20",
		text = _"Let me get back to you on that one.",
		code = function()
			Npc:says(_"Well, you aren't going anywhere. I'm watching you.")
			end_dialog()
		end,
	},
	{
		id = "node21",
		text = _"... I was only wondering who you were, and why you were wearing such a bright scarlet outfit.",
		code = function()
			Npc:says(_"My apologies, Linarian. You are new here, and do not know.")
			Npc:says(_"The red outfit indicates that I am of the Red Guard. We are the defenders of the town and impose the law.")
			Npc:says(_"With the continued bot attacks, and the grumbling townsfolk, all of us are a little on edge.")
			Npc:says(_"Tell me your name, and then you may pass.")
			--; TRANSLATORS: %s = Tux:get_player_name()
			Tux:says(_"My name is %s.", Tux:get_player_name())
			Npc:says(_"You may enter.")
			next("node40")
		end,
	},
	{
		id = "node22",
		text = _"I said: YOUR MOTHER DRESSES YOU FUNNY.",
		code = function()
			Npc:says(_"Nobody says things about my mother. Forget you, Linarian!")
			Npc:says(_"Open fire!")
			set_faction_state("redguard", "hostile")
			Tux:kill()
			hide("node20", "node21", "node22", "node23", "node30")
			end_dialog()
		end,
	},
	{
		id = "node23",
		text = _"I said: THIS PLACE LOOKS CLASSY.",
		code = function()
			Npc:says(_"Sure you said that.")
			hide("node21", "node22", "node23", "node30") show("node30", "node31", "node32")
		end,
	},
	{
		id = "node30",
		text = _"Please don't hurt me.",
		code = function()
			Npc:says(_"How about I punch you until you spit out your name and get out of here, and we call it even?")
			Tux:says(_"OW")
			Npc:says(_"Your name?")
			Tux:says("%s.", Tux:get_player_name())
			Tux:says(_"OW. That HURT!")
			--; TRANSLATORS Doc = Doctor
			Npc:says(_"Get out of here. The Doc is the third door on the right along the main path.")
			if (not Tux:del_health(40)) then
				Tux:del_health(1)
			end
			next("node40")
		end,
	},
	{
		id = "node31",
		text = _"I want to talk to your manager, moron.",
		code = function()
			Npc:says(_"I'll be happy to send you his way, I already told you, you have to talk to him anyway. But I need your name before I let you in.")
			Tux:says("%s.", Tux:get_player_name())
			Npc:says(_"Talk to Spencer. His office is in the citadel, straight ahead, the first one on your left. You can't miss it.")
			Npc:says(_"Now stop bothering me! You crazy loon.")
			Town_NorthGateGuard_tux_nickname_loon = true
			knows_spencer_office = true
			if (Tux:has_quest("Deliverance")) then
				Tux:update_quest("Deliverance", _"I've managed to get into town, and the guard at the gate told me where I can find Spencer: his office is the first one on the left inside the Citadel, directly south of the gate. The guard also calls me a loon.")
			end
			next("node40")
		end,
	},
	{
		id = "node32",
		text = _"That is exactly what I said.",
		code = function()
			Npc:says(_"You are as out of your mind as that Sorenson lady.")
			Npc:says(_"But I guess she's already here, so it doesn't matter if we have another loon.")
			--; TRANSLATORS: %s = Tux:get_player_name()
			Tux:says(_"I'm a Linarian, not a loon. %s the Linarian.", Tux:get_player_name())
			--; TRANSLATORS: %s = Tux:get_player_name()
			Npc:says(_"Get out of here %s, the loon, and stop bothering me.", Tux:get_player_name())
			Town_NorthGateGuard_tux_nickname_loon = true
			next("node40")
		end,
	},
	{
		id = "node40",
		code = function()
			for var in ipairs(Town_NorthGateGuard_doors) do
				change_obstacle_state(Town_NorthGateGuard_doors[var], "opened")
			end
			if not knows_spencer_office then
				show("node41")
			end
			hide("node20", "node21", "node22", "node23", "node30", "node31", "node32") show("node99")
		end,
	},
	{
		id = "node41",
		text = _"Can you tell me where I can find Spencer?",
		code = function()
			if (not knows_spencer_office) then -- player wasn't told where to find spencer
				Npc:says(_"Spencer's office is in the citadel, straight ahead. First one on your left.")
				knows_spencer_office = true
				if (Tux:has_quest("Deliverance")) and
				   (not Tux:done_quest("Deliverance")) then
					Tux:update_quest("Deliverance", _"I've managed to get into the town, and the guard at the gate told me where I can find Spencer: his office is the first one on the left inside the Citadel, directly south of the gate.")
				end
			else -- player was told where spencer's office is, or has met spencer
				if (not Tux:has_met("Spencer")) then
					Npc:says_random(_"No, you were already told that.",
									_"I don't believe anyone's memory is that short, even yours.")
					Npc:says(_"Stop wasting my time!")
				else
					Npc:says_random(_"Are you joking? You already talked to him.",
									_"Go ask him yourself. I know you already talked to him.")
					Npc:says(_"Stop wasting my time!")
				end
			end
			hide("node41")
		end,
	},
	{
		id = "node50",
		text = _"I have found the thief you talked about and took care of him.",
		code = function()
			Npc:says(_"Really? Wow... I must say, you are efficient. Well, at least we won't lose anything else to that freak.")
			if (Town_NorthGateGuard_tux_nickname_loon) then
				Npc:says(_"I will never again call you a loon. You are a most deadly penguin.")
				Town_NorthGateGuard_tux_nickname_loon = false
			end
			Npc:says(_"Here's a little reward we scraped together in case anyone solved our thief problem. I'll let Spencer know what you did.")
			Tux:add_gold(250)
			KevinMurder = false
			KevinMurderCongratulation = true
			Tux:end_quest("A strange guy stealing from town", _"I killed the thief who stole from town. The Red Guard rewarded me for it, but did I do the right thing? Hmm...")
			hide("node50")
			end_dialog()
		end,
	},
	{
		id = "node99",
		text = _"I'll be going then.",
		code = function()
			Npc:says_random(_"Mhmmm.",
							_"Finally...",
							_"It was about time...")
			if (Town_NorthGateGuard_tux_nickname_loon) then
				--; TRANSLATORS: %s = Tux:get_player_name()
				Npc:says(_"%s... the Loon", Tux:get_player_name())
			end
			end_dialog()
		end,
	},
}
