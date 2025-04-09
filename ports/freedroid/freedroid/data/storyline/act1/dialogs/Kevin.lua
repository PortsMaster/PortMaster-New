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
PERSONALITY = { "Obsessed", "Distracted", "Intelligent" },
MARKERS = { NPCID1 = "Jasmine" },
PURPOSE = "$$NAME$$ will help to improve Tux\'s skills.",
BACKSTORY = "$$NAME$$ stole material from the town and works in isolation on research to defeating the bots.",
RELATIONSHIP = {
	{
		actor = "$$NPCID1$$",
		text = "$$NAME$$ is $$NPCID1$$\'s creator and boyfriend." },
}
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0")
		Kevin_max_lessons = 6 -- the max number of lessons Kevin is willing to teach
		Kevin_lessons_taught = 0 -- the number of lessons Kevin has already taught, initialized with 0
		Kevin_next_lesson_cost = 0 -- the training point cost of the upcoming lesson
		Kevin_talk_later = 0 -- to trigger the stdoubt node
		Kevin_hacking = false -- Should we display Kevin's hacking node?
	end,

	EveryTime = function()
		if (Kevin_hacking) then
			show("node30")
			Kevin_hacking=false
		end

		if (Kevin_entering_from_back) then
			Npc:says(_"Hey, what are you doing?")
			Npc:says(_"You aren't allowed to enter through the backdoor, least of all make one...")
			Npc:says(_"Of course, unless you receive authorization from the administrator.")
			Npc:says(_"Of course, unless you could save lives or protect people.")
			Npc:says(_"Of course, unless, maybe two or three further exceptions...")
			Npc:says(_"But this isn't the case here, so explain yourself.")
			show("node90", "node91", "node92")
			push_topic("Backdoor")
		elseif (not has_met("Kevin")) then -- don't say "hello again" when meeting for the first time
			Tux:says_random(_"Hello.",
							_"Hi there.")
			Npc:says_random(_"Well, hello.",
							_"Hello hello.",
							_"Uhm hello.")
		else
			Tux:says_random(_"Hello.",
							_"Hi there, Kevin.")
			Npc:says_random(_"Well, hello again.",
							_"Hello hello.",
							_"Welcome back.")
		end

		if (Tux:has_quest("A strange guy stealing from town")) and
		   (not Tux:done_quest("A strange guy stealing from town")) then
			Tux:add_xp(100)
			Tux:end_quest("A strange guy stealing from town", _"Oh, I seem to have found the guy the town guard was raving on about. Better not tell the Red Guards in town or they might force me to assist them in his capture. I'll likely have more use of Kevin and his knowledge here in his house with his computers than in a holding cell in town.")
		end

		if (Tux:has_quest("And there was light...")) and
		   (Tux:done_quest("And there was light...")) then
			show("node8", "node10")
			if (not Kevin_did_And_there_was_light) then
				Kevin_did_And_there_was_light = true -- Tux spoke with Kevin after completing the quest "And there was light..."
				Tux:update_quest("And there was light...", _"Everything *is* back to normal for now, so Kevin doesn't need to spend all his time monitoring the power levels.")
			end
		end

		if (Jasmine_sigsegv) then
			show_if((not Kevin_sigtalk), "node20")
		end

		if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
			Npc:says(_"Dang, my test subjects just died and I just can't find other droids to replace them...")
			Npc:says(_"Where did all droids go, after all?!")
			Npc:says(_"I have no time to talk, I have to find new test subjects.")
			if (not Kevins_Lawnmower_tux_login_granted) and
				(Kevins_Lawnmower_tux_login) then
					next("node61")
			end
			end_dialog()
		end

		if (not Kevins_Lawnmower_tux_login_granted) then
			if (Kevins_Lawnmower_tux_login_kevin_attempt) then
				Npc:says(_"Hmm, strange things are happening to my lawnmower.")
				Npc:says(_"But I don't have the time right now to take a look at it.")
			end

			if (Kevins_Lawnmower_tux_login) then
				Npc:says(_"Oh, and did you play around with my lawnmower?")
				show("node60", "node61")
			end
		end

		show("node99")
	end,

	{
		id = "node0",
		text = _"Oh dear... You look awful... Who did this to you? Did they torture you?",
		code = function()
			Npc:says(_"I haven't eaten and slept very much lately, so I'm a little hungry and may appear a little tired.")
			Npc:says(_"One of the side effects of always deleting all cookies.")
			Npc:says(_"Don't worry about me. I'll be fine.")
			Npc:says(_"I'm Kevin, a computer security expert.")
			Tux:says(_"In other words: You are a hacker.")
			Npc:says(_"Eh... I guess you could put it that way, yes.")
			Npc:set_name("Kevin - Hacker")
			hide("node0") show("node30")
		end,
	},
	{
		id = "node6",
		text = _"I'll see after the energy supply now.",
		code = function()
			Npc:says(_"That's great. You can't miss it. It's not hard to find. Enter my garden and find the lower station entrance there.")
			Npc:says(_"It would be best not to bother with the resistance on the first level. You only need to take care of the energy supply. And that's on the SECOND level.")
			Npc:says(_"I hope you have a laser pistol or something like that, the bots there will rip you apart if you try to approach them.")
			Npc:says(_"Best make it quick. I'm already sick of stabilizing the stupid power grid!")
			Tux:update_quest("And there was light...", _"The entrance is in Kevin's garden. According to Kevin I also don't need to bother with bots on the first level, just go straight for the second level.")
			hide("node6", "node7")
		end,
	},
	{
		id = "node7",
		text = _"I'm sorry, but I don't think there's anything I could do about the energy supply.",
		code = function()
			Npc:says(_"Too bad. Now get out of my sight.")
			hide("node7")
		end,
	},
	{
		id = "node8",
		text = _"About that project you said you have running...",
		code = function()
			if (Tux:done_quest("A kingdom for a cluster!")) then
				Npc:says(_"I've already received the results from the evaluation of my data in the cluster. Good work.")
			else
				Npc:says(_"Yes, since the energy supply has been constant, results were much better. I've achieved my goal.")
				Npc:says(_"I've obtained secret data on the town surroundings. We'll need a big computer cluster to evaluate it properly.")
				Npc:says(_"Once we've evaluated the data, we might find a way to secure the town and ensure our survival. But it's too early to tell yet.")
				Npc:says(_"If I only had a suitable cluster. Then we could start data evaluation right away.")
				show("node9")
			end
			hide("node8")
		end,
	},
	{
		id = "node9",
		text = _"Maybe I can help somehow to find a suitable cluster.",
		code = function()
			if (Tux:has_quest("A kingdom for a cluster!")) then
				Npc:says(_"You've already agreed to take my data cube to the cluster. I have no influence on this matter anymore.")
				Npc:says(_"The fate of the town now rests in your hands. Take the data cube I gave you to the cluster. Only there can the data be evaluated properly.")
			else
				Npc:says(_"That would be great of course. I know that the old town is maintaining a suitable information infrastructure and has had a proper cluster running for some time now.")
				Npc:says(_"The only problem is, I can't go back to town. They would probably kill me because of... a misunderstanding.")
				Npc:says(_"Also, the cluster is inside of the guard citadel. I hear that only members of the Red Guard are allowed to enter the complex.")
				Npc:says(_"But maybe you can arrange that somehow. For me it would be impossible, because of my reputation.")
				Npc:says(_"I'll give you the data cube. Take it to the computer cluster administration people. They will know what to do. And don't mention me there.")
				Tux:add_quest("A kingdom for a cluster!", _"Kevin gave me a cube full of some kind of data. I am supposed to take it to a computer cluster for analysis. Ought to be simple.")
				Tux:add_item("Kevin's Data Cube", 1)
				Npc:set_death_item("NONE") -- to make sure we don't get two data cubes!!
			end
			hide("node9")
		end,
	},
	{
		id = "node10",
		text = _"How about some reward for securing your energy supply area?",
		code = function()
			if (Kevin_reward_given) then
				Npc:says_random(_"I've already rewarded you for that. Don't steal my time. I'm busy.",
					_"I am not as confused as you think. Go away now.")
			else
				Npc:says(_"What do you want?")
				push_topic("Kevin's Reward")
				show("node11", "node12", "node13", "node14")
			end
			hide("node10")
		end,
	},
	{
		id = "node11",
		text = _"I want to become a hacker.",
		topic = "Kevin's Reward",
		code = function()
			Npc:says(_"Your desire for information amuses me. Your wish will be granted. I will teach you how to improve your skill in designing hacking programs.")
			Npc:says(_"You must know that hacking is an art. It is easy to chop your enemy to bits with an axe or shred it to atoms with a grenade... But hacking requires skill.")
			Npc:says(_"Look at this terminal... I am connected to a remote system. A fool would just launch a thousand attacks, but a skilled intruder stops and thinks.")
			Npc:says(_"You must know when to hack and when not to hack. You must attack when the enemy is unprepared for you.")
			Npc:says(_"Now watch. Observe carefully. See how I enter the system... Yes. Watch the connection glowing, burning like a bright star...")
			Npc:says(_"...only to die seconds after, as the system far away collapses under it's own weight... It's done.")
			Npc:says(_"That is all I want to show you for now. Maybe later I will teach you something else.")
			Tux:improve_program("Hacking")
			next("node15")
		end,
	},
	{
		id = "node12",
		text = _"I don't want any reward. Just gratitude.",
		topic = "Kevin's Reward",
		code = function()
			Npc:says(_"Of course you can have that. There, I'm most grateful to you. That should do.")
			-- reward here could be bonus to joining faction or a powerful hacked (friendly) bot that supports Tux fighting in Hell Fortress.
			next("node15")
		end,
	},
	{
		id = "node13",
		text = _"I want money.",
		topic = "Kevin's Reward",
		code = function()
			Npc:says(_"Eh... Here, take these 900 circuits. That should be enough.")
			Tux:add_gold(900)
			next("node15")
		end,
	},
	{
		id = "node14",
		text = _"I want to think about that for another moment.",
		topic = "Kevin's Reward",
		code = function()
			Npc:says(_"So be it. As reward for your help I grant you the right to think about that.")
			Npc:says(_"Just joking. Come back when you've decided what you want.")
			hide("node11", "node12", "node13", "node14")
			pop_topic() -- "Kevin's Reward"
		end,
	},
	{
		id = "node15",
		topic = "Kevin's Reward",
		code = function()
			Kevin_reward_given = true -- Tux received a reward for completing the quest "And there was light..."
			hide("node11", "node12", "node13", "node14") show("node30")
			pop_topic() -- "Kevin's Reward"
		end,
	},
	{
		id = "node20",
		text = _"Jasmine just blew up.",
		code = function()
			Npc:says(_"Oh. Right.")
			Npc:says(_"Well, thanks for telling me.")
			Npc:says(_"Back to the drawing board, I guess...")
			Kevin_sigtalk = true -- Tux spoke with Kevin about Jasmine blew up
			hide("node20") show("node21")
		end,
	},
	{
		id = "node21",
		text = _"I thought you would be more worried about her death.",
		code = function()
			--; TRANSLATORS: %s = a week day.
			Npc:says(_"Why? I have backups from last %s. No reason to worry at all.",
				get_random(_"Monday", _"Tuesday", _"Wednesday", _"Thursday", _"Friday", _"Saturday", _"Sunday"))
			Npc:says(_"It will be a while till I get her together again, but she will be fine.")
			hide("node21")
		end,
	},
	{
		id = "node30",
		text = _"What can you teach me about hacking?",
		code = function()
			if (not Tux:done_quest("And there was light...")) then
				if (not Tux:has_quest("And there was light...")) then
					Npc:says(_"Not now, I'm busy.")
					Npc:says(_"I've got an important research project going on. In fact this project might be crucial to the survival of the whole town.")
					Npc:says(_"There is tremendous importance in it. But the project is in danger. There are some maintenance bots down at the energy source.")
					Npc:says(_"They are trying to 'maintain' machines by rebooting them all the time. This must stop, but I can't leave this place.")
					Npc:says(_"I must balance the remaining power in such a way that my project can continue uninterrupted.")
					Npc:says(_"Now, if you go down there and make the power flow stable, then I'll find the time to teach you something.")
					Tux:add_quest("And there was light...", _"Kevin has a problem with his energy supply. His bots keep rebooting the system, and he cannot conduct any experiments with an unstable power supply. My job is to stabilize the power. I think that implies removing the stupid bots.")
					show("node6", "node7")
				else
					Npc:says(_"As I've told you, I cannot teach you anything right now. I don't have the time.")
					Npc:says(_"I must see that the flaky energy stream is distributed in such a way that my research project can continue.")
					Npc:says(_"If you get rid of the maintenance bots on the second underground level of this station, I will find the time to teach you something.")
				end
			else
				if (Kevin_lessons_taught == Kevin_max_lessons) then
					Npc:says(_"Sorry, there is no human alive that could give you further training.")
					hide("node31")
				else
					Kevin_next_lesson_cost = 2 * (Kevin_lessons_taught + 1)
					Npc:says(_"I can teach you everything, for a price of course.", "NO_WAIT")
					Npc:says(_"Three hundred per lesson, up front.", "NO_WAIT")
					--; TRANSLATORS: %d = number training points needed
					Npc:says(_"You will need %d training points.", Kevin_next_lesson_cost)
					Npc:says(_"Still interested?")
					show("node31")
				end
			end
			Kevin_hacking=true
			hide("node30")
		end,
	},
	{
		id = "node31",
		text = _"Yes, please teach me how to become a hacker.",
		code = function()
			if (Tux:train_program(300, Kevin_next_lesson_cost, "Hacking")) then
				Kevin_lessons_taught = Kevin_lessons_taught + 1
				Npc:says(_"Good. The most important thing about hacking is to understand the nature of the machine you want to hack.")
				Npc:says(_"Once you have figured out what the creators of the system were thinking when setting it up, you'll also know how to best hack it.")
				Npc:says(_"Now I see the feature set of your hacking program has already improved a lot.")
			else
				if (Tux:get_gold() < 300) then
					next("node40")
				else
					next("node41")
				end
			end
			hide("node31") show("node30")
		end,
	},
	{
		id = "node40",
		code = function()
			Tux:says_random(_"Hold on, I don't seem to have that much money right now.",
				_"This is embarrassing. I will come back when I have the amount of valuable circuits you desire.")
			Npc:says_random(_"Ok, come back when you can afford to pay me if you are interested.",
				_"Please don't bother me if you can't pay me.",
				_"You don't have enough money! I cannot afford to just give away training for free.",
				_"Come back when you have enough circuits.",
				_"So come back when you have some valuables.")
		end,
	},
	{
		id = "node41",
		code = function()
			Tux:says(_"Sorry, my memory data bank is filled to the brim right now. Can't learn more until I get some more experience.")
			Npc:says_random(
				_"You Linarians are funny creatures. Come back later when you feel ready if you please.",
				_"I cannot teach you when you have no training points. Come back when you are more prepared.",
				_"You are not ready. Go kill some bots and come back.",
				_"Come back when you are mentally ready to learn.",
				_"Come back after some more practice in the field.",
				_"Waving those circuits in front of me when you are too unfocused to train won't help. I can take your money, but you won't learn anything.",
				_"Yeah, I don't think you have enough experience for this. Come back here after you see some more action.",
				_"Then come back when you have a real will to learn.",
				_"You don't have enough experience. Come here after you see some more action.")
		end,
	},
	{
		id = "node60",
		text = _"No, I didn't touch it.",
		code = function()
			Npc:says(_"Strange, I should have a look at it...") --Tux lied to him and will not directly get an account if he talks to it next time.
			Npc:says(_"...when I have more time...")
			Kevins_Lawnmower_tux_login = false
			hide("node60", "node61")
		end,
	},
	{
		id = "node61",
		text = _"Yes, I tried to login.",
		code = function()
			if (Tux:done_quest("And there was light...")) then
				Npc:says(_"Please, don't touch it.")
				Npc:says(_"I don't want you to break it somehow.")
				Kevins_Lawnmower_tux_login_granted = true -- Tux has access to Kevin-Lawnmower
			else
				Npc:says(_"You better not touch it!")
				Npc:says(_"If you break it somehow, I'll be very angry.")
				Npc:says(_"And I still have no time.")
				Npc:says(_"The power level is still very low, hence, I am quite busy.")
			end
			Kevins_Lawnmower_tux_login = false
			hide("node60", "node61")
		end,
	},
	{
		id = "node90",
		text = _"I came to warn you: droids broke through your wall!",
		topic = "Backdoor",
		code = function()
			Npc:says(_"You could just go around and enter by the main door.")
			Npc:says(_"This way, you might waste time. You've optimized your path. Good job!")
			Npc:says(_"Thank you for your report, but I don't have time to fix it.")
			next("node93")
		end,
	},
	{
		id = "node91",
		text = _"My mission is top-secret. I must be stealthy.",
		topic = "Backdoor",
		code = function()
			Npc:says(_"You are really careful with the security of your mission.")
			Npc:says(_"However, don't destroy my equipment, I can support you to be stealthy.")
			Npc:says(_"But later, maybe... I don't have time now.")
			next("node93")
		end,
	},
	{
		id = "node92",
		text = _"I saw an opening in the wall and I decided to take a look inside.",
		topic = "Backdoor",
		code = function()
			Npc:says(_"Oh, you have just entered by curiosity. I always fought to make it an exception to the rules.")
			Npc:says(_"I like curiosity. I think it's what rocketed us on Mars. And beyond...")
			Npc:says(_"Thank you, I now know the issue, but I don't have time to fix it.")
			next("node93")
		end,
	},
	{
		id = "node93",
		topic = "Backdoor",
		code = function()
			-- open KevinGuard door
			KevinGuard_door_open = true
			change_obstacle_state("KevinsDoor", "opened")

			Kevin_entering_from_back = false
			pop_topic()
		end,
	},
	{
		id = "node99",
		text = _"Let us talk later.",
		code = function()
			if (Kevin_talk_later == 10) then
				Npc:says(_"Hey Linarian...")
				Tux:says(_"Mmmh, yes?")
				Npc:says(_"Do you know this feeling...")
				Npc:says(_"... when you get a really strange output...")
				Npc:says(_"... and you look at the code...")
				Npc:says(_"... again and again...")
				Npc:says(_"... but you see no path it could come from?")
				Tux:says(_"Hmm, yes, I get this sometimes...")
				Npc:says(_"I checked online if there is a name for this symptom... but couldn't find anything...")
				Npc:says(_"I guess I am going to call it 'stdoubt'.")
				Tux:says(_"Ok...")
				Tux:says(_"...")
			else
				Npc:says_random(_"Be careful. The bots are in a foul mood today. Very easy to get killed. Very easy.",
								_"If you need to contact me, my number is 127.0.0.1",
								_"Keep your system up to date, Linarian.")
			end
			Kevin_talk_later = Kevin_talk_later + 1
			end_dialog()
		end,
	},
}
