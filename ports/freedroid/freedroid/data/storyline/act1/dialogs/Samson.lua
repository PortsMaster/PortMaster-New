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
PERSONALITY = { "Brilliant", "Smart", "Composed", "Friendly" },
MARKERS = { NPCID1 = "Mr. Saves", NPCID2 = "Sorenson"},
PURPOSE = "$$NAME$$ teaches Tux programming, but only if Tux have prior knowledge on it. In future he will also give player a quest to unlock sensor-changing on droids.",
BACKSTORY = "$$NAME$$ worked with $$NPCID1$$ at Nicholson Inc., where $$NAME$$ did the coding and $$NPCID1$$ came with crazy ideas. $$NPCID1$$ left mysteriously shortly before the Great Assault and haven't been seen since then. $$NAME$$ was then transferred to droid security division, but before assuming the job the droids went crazy. Because that, he wasn't able to patch the security fixes on the 615 droids. $$NAME$$ was also in charge to finish sensor system with $$NPCID1$$, but because the disappearance from the former one, it was never finished. He will also notice the programming knowledge Tux might have acquired from $$NPCID2$$."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0")
		Sam_boredom=0
	end,

	EveryTime = function()
		Sam_boredom=Sam_boredom + 1

		if (Sam_boredom == 3) then
			Npc:says(_"I'm bored. Hey, do you want to take a challenge?")
			show("expertise_intro")
		end
	end,

	{
		id = "node0",
		text = _"Hi! I'm new here. ",
		code = function()
			Npc:says(_"Hello, I am Samson, the Coder. Pleased to meet you.")
			Npc:says(_"I used to work on Nicholson, Inc. and was supposed to take over security for the 615 project two days after the Great Assault happened. Oh well.")
			Npc:set_name("Samson, the Coder")
			hide("node0") show("node1", "training_main")
		end,
	},

	{
		id = "node1",
		text = _"You used to work at Nicholson, Inc.? How was it there?",
		code = function()
			Npc:says(_"Well, it was fun. I got to test a lot of new ideas. There was a man who always came up with crazy ideas, I can't recall his name. Making them reality was my task. It was fun, but time-consuming.")
			Npc:says(_"About three months before the Great Assault happened, that man vanished. There were no signs of where he could have gone.")
			Npc:says(_"We were doing a \"sensor\" system. He said that MegaSys command droids used those gadgets to detect invisible things, and if we could replicate, our security droids would be almost invincible.")
			Npc:says(_"Because of his disappearance, we never finished that. I was thinking though, maybe if someone got me his work, I could finish it, and add those so-called \"sensors\" on the droids you hack...")
			Npc:says(_"...sorry, I'm just rambling. Please forget everything I've said.") -- Quest is NYI as well as changing sensors via Lua.
			hide("node1")
		end,
	},
	{
		id = "shop",
		text = _"Yes, I would like to trade with you.",
		code = function()
			Npc:says_random(_"Yes, please feel free to.",
							_"I only have some consumables with me.",
							_"That's all I can do for you now.")
			trade_with("Samson")
		end,
	},


	{
		id = "training_main",
		text = _"You're a coder. Could you, maybe, teach me programming?",
		code = function()
			if (Tux:get_skill("programming") == 0) then
				Npc:says(_"No, sorry, I cannot.", "NO_WAIT")
				Npc:says(_"You see, even while I am on vacations right now, I can think on more interesting things to do other than teaching the basics to some overgrown penguin.")
				Npc:says(_"Maybe if you knew some programming, we could talk...")
			elseif (Tux:get_skill("programming") == 1) then
				Npc:says(_"Well, why not? It could be fun.", "NO_WAIT")
				Npc:says(_"But hey, it's no easy task.")
				Npc:says(_"For so, I expect you to bring me some money, to be ready of mind, and then you may be my apprentice.")
				Npc:says(_"Interested?")
				hide("training_main") show("apprentice")
			elseif (Tux:get_skill("programming") == 2) then
				Npc:says(_"Oh, so you want more. I guess you're using a lot of skills, then?", "NO_WAIT")
				Npc:says(_"Well, sorry to inform, it's not so easy. You'll require much more than just money and training. I want to see your efforts.")
				Npc:says(_"Interested?")
				hide("training_main") show("professional")
			elseif (Tux:get_skill("programming") == 3) then
				Npc:says(_"Oh, you want to become an expert when doing programs?", "NO_WAIT")
				Npc:says(_"Then you'll need to bring me, besides the usual, something which shows you're an expert at coding.")
				Tux:says(_"How can I show you a proof that I am an expert if I want to become an expert in first place?")
				Npc:says(_"Do not get it wrong, linarian. I want to ensure you know various programming languages and such. What I will teach you, is how to fully use the potential you already have.")
				Npc:says(_"This will be my last lesson. And the hardest one. Are you interested?")
				hide("training_main") show("expert")
			else
				if (Sorenson:is_dead()) then
					Npc:says(_"Sorry, there is no human alive that could give you further training. Maybe Sorenson could, but I'm afraid she's dead.")
				else
					Npc:says(_"Sorry, there is no human alive that could give you further training.") -- Is Sorenson still human?
				end
				Npc:says(_"Maybe I could sell you some consumables to help?")
				hide("training_main") show("shop")
			end
		end,
	},
	{
		id = "apprentice",
		text = _"Make me your apprentice in programming. (costs 100 circuits, 9 training points)",
		echo_text = false,
		code = function()
			Tux:says(_"Yes, please make me your apprentice in programming.")
			cost = 100
			if Tux:train_skill(cost, 9, "programming") then
				Npc:says(_"Okay, class number 1: A program done entirely on a single language will most likely bring you headache.")
				Npc:says(_"You should learn early to diverse your program languages if that makes your life easier. Specially when working with teams.")
				Npc:says(_"For example, see this game done by Arthur, a friend of mine.", "NO_WAIT")
				Npc:says(_"The mechanics are on specific language and dialogs are on Lua.")
				Npc:says(_"Lua is a very simple programming language. In fact, you do not need to be a programmer to use basic Lua.")
				Npc:says(_"This way, you can have a programmer team working on mechanics and a non-programmer team doing content.", "NO_WAIT")
				Npc:says(_"Not only that, but it makes scripting much easier to read and work with.")
				Npc:says(_"Good. You are learning quickly. Try splitting the languages on a few programs. Knowledge on multiple programming languages is power.")
				Npc:says(_"Okay, I think that it is enough for today.")
				hide("apprentice") show("training_main")
			else
				if (Tux:get_gold() < cost ) then next("no_money") else next("no_training") end
			end
		end,
	},
	{
		id = "professional",
		text = _"I want to do coding like a pro! (costs 150 circuits, 13 training points, 1x Peltier Element)",
		echo_text = false,
		code = function()
			Tux:says(_"So let's start the second course?")
			cost = 150

			if Tux:has_item_backpack("Peltier element") then
				if Tux:train_skill(cost, 13, "programming") then
					Tux:del_item_backpack("Peltier element", 1)
					Npc:says(_"Very well.")
					Npc:says(_"I shall teach you how to use Git.", "NO_WAIT")
					Npc:says(_"Programming is not only about coding. It's also about making your work efficient.")
					Npc:says(_"With Git, you'll have much fewer problems with backups and code mistakes.")
					Npc:says(_"Try it a little, and you'll be having fewer failures now.")
					hide("professional") show("training_main")
				else
					if (Tux:get_gold() < cost ) then next("no_money") else next("no_training") end
				end
			else
				Npc:says(_"Negative. Any true program's user will know to have Peltier Elements to avoid overheating!")
			end
		end,
	},
	{
		id = "expert",
		text = _"Teach me all you know about programming. (costs 200 circuits, 18 training points, 1x MS Stock Certificate)",
		echo_text = false,
		code = function()
			Tux:says(_"So can you help me become even better with programs?")
			cost = 200

			if Tux:has_item_backpack("MS Stock Certificate") then
				if Tux:train_skill(cost, 18, "programming") then
					Npc:says(_"Oh my, according to this certificate, you made a company learn BASIC. Keep it, I cannot take it from you.", "NO_WAIT")
					Npc:says(_"Of course it'll be my pleasure to teach you something more.")
					if (Sorenson:is_dead()) then
						Npc:says(_"You still haven't realized, but since we've first talked, I already sensed a great coder on you. I just try to help you to harness all your potential. So...")
					end
					Npc:says(_"For my next lesson, we will study and do a program together.")
					Tux:says(_"How will that help?")
					Npc:says(_"Only practice and study will lead you to the expertise you seek.", "NO_WAIT")
					Npc:says(_"I'll be here to answer any questions you have. I hope the little I know be of help to you.")
					hide("expert") show("training_main")
				else
					if (Tux:get_gold() < cost ) then next("no_money") else next("no_training") end
				end
			else
					Npc:says(_"No proof, no training.")
			end
		end,
	},
	{
		id = "no_money",
		code = function()
			Npc:says_random(_"You need more circuits.",
							_"Please don't bother me if you can't pay me.",
							_"Come back when you have enough circuits.",
							_"So come back when you have something of value.")
		end,
	},
	{
		id = "no_training",
		code = function()
			Npc:says_random(_"You are not ready. Go kill some bots and come back.",
							_"Come back when you are mentally prepared to learn.",
							_"I don't think you have enough experience for this.",
							_"Come back when you have a real will to learn.",
							_"You don't have enough experience. Come here after you see some more action.")
		end,
	},


	{
		id = "expertise_intro",
		text = _"A... challenge?",
		code = function()
			Npc:says(_"I call it \"The Expertise Challenge\". It's pretty simple actually, but easy? Definitely not.")
			Npc:says(_"As you might have noticed, you have three improvements, or this is how I decided to call them: Melee, Ranged and Programming.")
			Npc:says(_"Basically, you usually decide what you want to master at, and invest money, training points and sweat on them. But why not investing on all of them?!")
			Npc:says(_"If you achieve the rank of [b]expert[/b] on the three of them, I will teach you a skill I warrant you won't learn it anywhere else.")
			Npc:says(_"It will [b]increase the time you have to take over a bot[/b]. It will reconfigure your magnetic field to keep connection alive for longer - or something like that. It's not much though, be warned.")
			Npc:says(_"Come talk to me when you're ready.")
			hide("expertise_intro") show("expertise_repeat", "expertise_ready")
		end,
	},
	{
		id = "expertise_repeat",
		text = _"Could you repeat about the Expertise Challenge?",
		code = function()
			next("expertise_intro")
		end,
	},
	{
		id = "expertise_ready",
		text = _"I have completed the Expertise Challenge!",
		code = function()
			Npc:says(_"Oh, really? Let's see.")
			local failed=false

			if (Tux:get_skill("melee") < 4) then
				Npc:says(_"You're no expert at melee.")
				failed=true
			end

			if (Tux:get_skill("ranged") < 4) then
				Npc:says(_"You're no expert at ranged.")
				failed=true
			end

			if (Tux:get_skill("programming") < 4) then
				Npc:says(_"You're no expert at programming.")
				failed=true
			end

			if (failed) then
				Npc:says(_"You must be an expert at the three areas of specialization to receive the reward. Sorry.")
			else
				Npc:says(_"Indeed, you're an expert at everything! Congratulations!")
				Npc:says(_"Let me just upload on you the codes for the skill and you will be able to make slightly longer takeovers.")
				Tux:improve_program("Animal Magnetism")
				Tux:says(_"I feel... Great! Thanks, Sam! I can't wait to spend hours hacking the same bot!")
				Npc:says(_"...I don't think that skill increases your take over for so much time...... Oh well. Have fun, linarian!")
				hide("expertise_repeat", "expertise_ready", "expertise_intro")
			end
		end,
	},
	{
		id = "node99",
		enabled = true,
		text = _"See you later.",
		code = function()
			Npc:says_random(_"Take care, Linarian.",
							_"Safe travels, Linarian.",
							_"Do not get caught by the 615, Linarian.",
							_"If you have cool ideas, come tell me, Linarian.")
			end_dialog()
		end,
	},
}
