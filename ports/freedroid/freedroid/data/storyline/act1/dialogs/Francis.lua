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
PERSONALITY = { "Weak", "Aged", "Friendly", "Honest" },
MARKERS = { NPCID1 = "Spencer", QUESTID1 = "Deliverance", NPCID2 = "Chandra" },
PURPOSE = "$$NAME$$ is the first character encountered in the game. He gives a summary explanation of what is going on in the
	 world, and is able to direct the player to the mining community.",
BACKSTORY = "$$NAME$$ is the Doctor in charge of the Cryonic Facility near the town. $$NAME$$ is quite old and his heart is weak; he could
	 easily suffer a fatal heart attack. He escaped to the town when the Great Assault began. He has agreed to be the keeper of the Cryo
	 Stasis Laboratory. When he discovered that there was a Linarian being held in stasis, he took it upon himself to resuscitate that
	 Linarian in hopes of bringing an end to the war.",
RELATIONSHIP = {
	{
		actor = "$$NPCID1$$",
		text = "$$NAME$$ disagrees with $$NPCID1$$ about disposing of people in cryonic stasis. Initially he refused the task, but $$NPCID1$$
		 threatened to reveal a secret from $$NAME$$\'s past and forced him to accept. $$NAME$$ must send $$NPCID1$$ a list of all people in
		 the Cryonic Facility. Not wanting to confront $$NPCID1$$ again, $$NAME$$ passes the delivery on to Tux in the $$QUESTID1$$ quest."
	},
	{
		actor = "$$NPCID2$$",
		text = "$$NAME$$ and $$NPCID2$$ know each other. $$NAME$$ sends Tux to talk to him about Linarians."
	},
}
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		Francis_help = 150
	end,

	EveryTime = function()
		if (not Francis_bot_attack) then
			if (InvaderBot_hacked or InvaderBot:is_dead()) then
				next("node6")
			else
				Npc:says(_"HELP! We're under attack!","NO_WAIT")
				Npc:says(_"[b](The old man is clearly distressed and frightened.)[/b]")
				show("node0")
			end
			Francis_bot_attack = true
			Npc:set_rush_tux(false)
		elseif (not InvaderBot_hacked and not InvaderBot:is_dead()) then
			Npc:says(_"Have you neutralized the threat yet?")
			if (not Francis_tux_liar) then
				show("node1", "node2")
			else
				show("node1", "node3")
			end
		elseif (not Francis_invaderbot_neutralized) then
			Npc:says(_"Have you neutralized the threat yet?")
			show("node5")
		else
			if (not Tux:has_quest("Deliverance")) and
			   (not (Francis_refused_deliverance)) then
				show("node90")
				--; TRANSLATORS: %s =Tux:get_player_name()
				Npc:says(_"Welcome back %s.", Tux:get_player_name())
			else
				show("node99")
				--; TRANSLATORS: %s =Tux:get_player_name()
				Npc:says(_"It's good to see you again, %s.", Tux:get_player_name())
			end

			if (Francis_tux_dismissed) then
				show("node21", "node22")
			end

			if (cryo_614_lock_gate) and
			   (not cryo_outergate_code) then
				show("node30")
			end

			if (tux_has_joined_guard) and
			   (not Francis_guard_response) then
				Francis_guard_response = true
				Tux:says(_"I joined the Red Guard.")
				Npc:says(_"Oh...")
				Npc:says(_"Well. Congratulations are in order, I suppose.")
				Tux:says(_"...")
			end

			if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) and
			   (not Francis_hf_response) then
					Francis_hf_response = true
					Tux:says(_"All droids are dead. Mission complete!")
					Npc:says(_"Now, that's quite a deed. Congratulations.")
					Npc:says(_"I can finally sleep with one worry less, I suppose.")
					Tux:says(_"...")
					if (Tux:has_quest("Deliverance")) then
						Tux:says(_"The data cube still worries you, am I right?")
						Npc:says(_"...Yes.")
					end
			end
		end

		-- in case Francis gets stuck at FrancisSafe:
		if (InvaderBot_hacked or InvaderBot:is_dead()) and
		   (Francis_invaderbot_neutralized) and
		   (not Francis_movement_free) then -- this way we prevent him from walking to the label whenever we talk to him again which may look strange
			Npc:set_destination("InvaderBot-Alive-Check-W")
			Francis_movement_free = true
		end
	end,

	{
		id = "node0",
		text = _"Uhh... Where... Uh... Who am I? Oh, my head...",
		code = function()
			Npc:says(_"You have been in stasis for quite some time, but you must hurry! There's no time to explain... There's a bot in the next room. You must neutralize it quickly!")
			Npc:set_destination("FrancisSafe")
			hide("node0")
			end_dialog()
		end,
	},
	{
		id = "node1",
		text = _"No, not yet.",
		code = function()
			Npc:says(_"Hurry! There's no time...")
			Npc:set_destination("FrancisSafe")
			hide("node1", "node2", "node3")
			end_dialog()
		end,
	},
	{
		id = "node2",
		text = _"(Lie) Yes, the bot has been defeated.",
		code = function()
			Francis_help = Francis_help - 30
			Npc:says(_"Oh, many thanks to ...")
			Npc:says(_"You lie! You shouldn't toy with an old man with a weak heart! I can hear its servos whirring away... heading this way to kill us both! Please, you must help...")
			Francis_tux_liar = true
			Npc:set_destination("FrancisSafe")
			hide("node1", "node2")
			end_dialog()
		end,
	},
	{
		id = "node3",
		text = _"(Lie) Yes, the bot has been defeated.",
		code = function()
			Npc:says(_"[b](sigh)[/b] Thank you, Linarian. You are truly...")
			Npc:says(_"[b](In the other room, you hear the faint whirring of servos. The horror in the old man's eyes tell you that he too has heard it.)[/b]")
			Npc:says(_"...a monster! You are not a Linarian like the legends spoke of! The cryo-stasis has corrupted your soul! AGGGG!!!")
			Npc:says(_"[b](The old man grips his chest and collapses in what appears to have been a fatal heart attack.)[/b]")
			InvaderBot:teleport("NewTuxStartGameSquare")
			InvaderBot:set_faction("ms")
			Tux:add_quest("Deliverance", _"The mysterious old man died from a heart attack caused by fear. He had a small data cube on his body. I wonder what's on it...?")
			Tux:add_item("Data cube")
			Npc:drop_dead()
			hide("node1", "node3")
			end_dialog()
		end,
	},
	{
		id = "node5",
		text = _"Yes, the bot has been defeated.",
		code = function()
			Npc:says(_"Thank heavens! Perhaps the legends are true after all...")
			Npc:says(_"Now that we are safe, I'd be happy to answer some of your questions. But we cannot take too long, you will need to head to the town as soon as possible.")
			Francis_invaderbot_neutralized = true
			Npc:set_destination("FrancisStart")
			hide("node5") show("node10", "node90")
		end,
	},
	{
		id = "node6",
		code = function()
			Npc:says(_"Thank heavens! You have protected us from this bot.")
			Npc:says(_"You have been in stasis for quite some time, but you still can defend yourself. Perhaps the legends are true after all...")
			Npc:says(_"Now that we are safe, I'd be happy to answer some of your questions. But we cannot take too long, you will need to head to the town as soon as possible.")
			Francis_invaderbot_neutralized = true
			Npc:set_destination("FrancisStart")
			hide("node6") show("node10", "node90")
		end,
	},
	{
		id = "node10",
		text = _"I feel terrible... Was I asleep? I remember nightmares. A meteor shower... Fire... Death... It was awful.",
		code = function()
			Npc:says(_"Unfortunately, for a case like yours, that is normal. According to your records, you were in stasis sleep for over 70 years.")
			Npc:says(_"Stasis is not too kind on the mind. It is not uncommon for strange dreams and nightmares to plague people who have been under stasis that long.")
			hide("node10") show("node11", "node15")
		end,
	},
	{
		id = "node11",
		text = _"Who am I?",
		code = function()
			Npc:says(_"So you really can't remember, eh?")
			Npc:says(_"Long stasis sleep can cause neurological damage and impact the memory. Looks like that is what happened here.")
			--; TRANSLATORS: %s = Tux:get_player_name()
			Npc:says(_"If the computer is not lying, then your name is %s.", Tux:get_player_name())
			Npc:says(_"I'm just glad that we realized that you were a legendary Linarian and started the thawing process when we did.")
			hide("node11") show("node12")
		end,
	},
	{
		id = "node12",
		text = _"Linarians? Legends? What are you talking about?",
		code = function()
			Npc:says(_"Wow, this is the worst case of cryo-neural damage I have ever seen.")
			Npc:says(_"The Red Guard had me thaw you out because you are a Linarian. I don't know much about your kind, but I do know that you have a strange affinity for computers, almost magical powers.")
			Npc:says(_"Chandra in the nearby town center probably has even more information.")
			Npc:says(_"Look in the chest in the next room for some spare gear I managed to gather for you. It's not much, but it should help you make it to town in one piece.")
			linarian_chandra = true
			Francis_tux_dismissed = true
			hide("node12") show("node20", "node21")
		end,
	},
	{
		id = "node15",
		text = _"Who are you? What is going on?",
		code = function()
			Npc:says(_"My name is Dr. Francis Spark. I am... uh... the keeper of this cryonic facility.")
			Npc:set_name("Dr. Francis - Cryonicist")
			Npc:says(_"Currently, there is a war raging all around the globe. One day, our once loyal bots rebelled against us and began trying to wipe us out. The beginning of this war has been dubbed 'The Great Assault.'")
			Npc:says(_"And it looks like humans are losing the war. Our town isn't doing so well at this point either. But there is still hope, since you were discovered here.")
			hide("node15") show("node16", "node17")
		end,
	},
	{
		id = "node16",
		text = _"How did the war start?",
		code = function()
			Npc:says(_"Unfortunately, I'm not the best source of information for that. All I know is that one day the bots went crazy. Maybe someone else in town knows more.")
			hide("node16")
		end,
	},
	{
		id = "node17",
		text = _"Keeper? You don't sound so sure... What is the deal with this place?",
		code = function()
			Npc:says(_"I'm sorry, but you probably need to start travelling to the town. The Red Guard are not known to be the most patient.")
			Npc:says(_"They were the ones who wanted me to thaw you out, after all. You'd better get going.")
			Francis_tux_dismissed = true
			hide("node17") show("node20", "node21")
		end,
	},
	{
		id = "node20",
		text = _"Tell me more about the town you mentioned.",
		code = function()
			Npc:says(_"It is a small mining community of perhaps 500 inhabitants...")
			Npc:says(_"I guess it was a stroke of luck that the town has not been completely destroyed by the bots.")
			Npc:says(_"Oddly enough, the rusty old bots that the town uses for security were not affected by whatever caused the other bots to go crazy.")
			Npc:says(_"Right now the town is 'protected' by the Red Guard, a bunch of opportunistic roughnecks. It's not exactly a secret that I don't agree with their methods.")
			Npc:says(_"However, I must admit that being oppressed is a much better alternative to being eviscerated alive.")
			hide("node20")
		end,
	},
	{
		id = "node21",
		text = _"Can you tell me how to get to town?",
		code = function()
			Npc:says(_"Sure. You just need to follow the road outside to the east. After the bridge, turn right and continue to follow the road and you will soon be outside of the town main gate.")
			Npc:says(_"If you run across too many bots, you can try to circle around them. But avoid getting too far off the road, so you don't get lost. It's very dangerous out there.")
			Npc:says(_"Once in town you will be able to purchase or trade a few more items for protection at Ms. Stone's shop just inside the town gate.")
			hide("node21") show("node22")
		end,
	},
	{
		id = "node22",
		text = _"How do I get out from here?",
		code = function()
			Npc:says(_"Oh, just take the small door and corridor out to the waiting room. And from there you can get out through the customer entrance.")
			Npc:says(_"I keep the back entrance, close to my sleeping quarters, locked at all times. Better safe than sorry.")
			hide("node22")
		end,
	},
	{
		id = "node30",
		text = _"The 614 bot said he might lock the outside gate!",
		code = function()
			cryo_outergate_code = true
			Npc:says(_"Oh. You'll need to put the cryonic terminals into admin mode to access the gate controls.")
			Tux:says(_"How do I do that?")
			Npc:says(_"You press star-pound-zero-six-pound and then enter the free-speech number.")
			Npc:says(_"It is kind of long, so I'll write it down for you.")
			Npc:says(_"If the 614 bot locks the gate, it is for a good reason. Lock the gate behind you!")
			hide("node30")
		end,
	},
	{
		id = "node90",
		text = _"Thanks for the help. I'll be going now.",
		code = function()
			Npc:says(_"I am glad I could help you. You should be careful around here. Best head straight for our town.")
			Npc:says(_"Oh, I almost forgot... Could you take this data cube and give it to Spencer once you get to town?")
			Tux:says(_"Spencer?")
			Npc:says(_"Yes. He's the leader of the Red Guard.")
			hide("node90") show("node91", "node92", "node93")
			push_topic("Deliver the cube")
		end,
	},
	{
		id = "node91",
		text = _"What is stored in the cube?",
		topic = "Deliver the cube",
		code = function()
			Npc:says(_"It's almost nothing... nothing important... if I know nothing about purposes.")
			Npc:says(_"Spencer wanted me to list all people in cryonic stasis. We had an argument about it, but in the end I gave in. Maybe it's needed. I couldn't avoid it.")
			Npc:says(_"I'm not a bad person, but I don't like these types of decisions. Lose-lose decisions are especially difficult. But, I suppose, it's like that for everybody.")
			Npc:says(_"Bring your questions to Spencer. I'd rather not discuss it anymore, it is too troubling, especially since I'm complicit in whatever happens.")
			hide("node91")
		end,
	},
	{
		id = "node92",
		text = _"All right, I'll deliver the cube.",
		topic = "Deliver the cube",
		code = function()
			Npc:says(_"Thank you.")
			Npc:says(_"You can ask one of the guards in town, they'll know where to find Spencer.")
			Tux:add_item("Data cube", 1)
			Tux:add_quest("Deliverance", _"Francis asked me to deliver a data cube for him. When I reach the town, I'm supposed to give it to Spencer, who's in charge of the Red Guard ruling the nearby town. Of course, my first job is to survive the trip there...")
			hide("node91", "node92", "node93", "node94")
			next("node98")
		end,
	},
	{
		id = "node93",
		text = _"Deliver that cube yourself.",
		topic = "Deliver the cube",
		code = function()
			Francis_help = Francis_help - 10
			Npc:says(_"Oh, I would, believe me. I'm quite capable of running my own errands, even with the mass of bots out there.")
			Npc:says(_"But... The prospect of facing that... That man again... I just can't bear it.")
			--; TRANSLATORS: %s =Tux:get_player_name()
			Npc:says(_"Please, %s, will you do me this favor?", Tux:get_player_name())
			hide("node93") show("node94")
		end,
	},
	{
		id = "node94",
		text = _"No, I don't want to deliver your stupid cube.",
		topic = "Deliver the cube",
		code = function()
			Francis_help = Francis_help - 60
			Francis_refused_deliverance = true
			Npc:says(_"... All right.")
			Npc:says(_"I can't force you to do it if you don't want to.")
			Npc:says(_"I suppose I'll just have to go to Spencer myself.")
			Npc:says(_"Anyway, I am glad I could help you. You should be careful around here. Best head straight for our town.")
			hide("node91", "node92", "node94")
			next("node98")
		end,
	},
	{
		id = "node98",
		code = function()
			if (Francis_help > 0) then
				Npc:says(_"Oh... I almost forgot... This is a small help but I hope it will make your life a little easier.")
				Tux:add_gold(Francis_help)
			end
			Npc:says(_"Remember not to veer too far off the path, or your quest could be over before it begins.")
			end_dialog()
		end,
	},
	{
		id = "node99",
		text = _"Thanks for the help. I'll be going now.",
		code = function()
			if (not HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				Npc:says(_"I am glad I could help you. You should be careful around here. Best head straight for our town.")
				Npc:says(_"Remember not to veer too far off the path, or your quest could be over before it begins.")
			else
				Npc:says(_"Safe travels, linarian.")
			end
			end_dialog()
		end,
	},
}
