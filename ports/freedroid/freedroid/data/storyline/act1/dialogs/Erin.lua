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
PERSONALITY = { "Challenging", "Strong", "Extroverted", "Independent", "Arrogant" },
MARKERS = { NPCID1 = "Iris", NPCID2 = "Saul" },
PURPOSE = "$$NAME$$ teaches Tux melee combat, but only if Tux have prior knowledge on it because she can't stand weak linarians. In future there will be a quest to reunite her with Iris.",
BACKSTORY = "$$NAME$$ is part from the Rebel Faction. She worked with $$NPCID1$$ hunting bots and when they were to sleep at barracks, which was rare, they were roommates. On combat, $$NPCID1$$ was more careful to preserve droid drops and she would use brute force to smash and finish the bot \"for once and for all\". They are good friends, despite the contrasts on their personality and fighting style. They usually took solo missions but back home they told stories of their missions to each other. $$NAME$$ usually challenged $$NPCID1$$ to see who had killed more droids and most times than not, won. $$NPCID1$$ believes she is dead because $$NAME$$ went on a special, secret mission, given by $$NPCID2$$ personally, and never came back. She has fought with many robots before, and will not be scared by a mere linarian."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0")
	end,

	{
		id = "node0",
		text = _"Hi! I'm new here.",
		code = function()
			Npc:says(_"Oh great. A greenie. This is no place for you. Come back from where you came.")
			--; TRANSLATORS: %s = player name
			Tux:says(_"Well, excuse me?! I am %s, the Linarian who will save the world!", get_player_name())
			Npc:says(_"Linarian? You're more to some sort of overgrown penguin who forgot where the North Pole is. You're wasting my time, so you better have a reason to be talking to me.")
			hide("node0") show("node1", "node30")
		end,
	},

	{
		id = "node1",
		text = _"What's your name?",
		code = function()
			Npc:says(_"I am Erin, the bot hunter.")
			Tux:says(_"Pleased to meet you! I am-", "NO_WAIT")
			Npc:says(_"Yes, yes, I don't care. Is that all?")
			Npc:set_name("Erin - bot hunter")
			hide("node1") show("node2", "node3", "shop")
		end,
	},
	{
		id = "node2",
		text = _"Do you hate me?",
		code = function()
			Npc:says(_"No, I'm just annoyed with your silly questions.")
			hide("node2") hide("node30", "node31")
		end,
	},
	{
		id = "node3",
		text = _"You hunt bots?",
		code = function()
			Npc:says(_"I have to make a living, after all. Food is not free.")
			Tux:says(_"Even military rations?")
			Npc:says(_"...are you being serious?")
			hide("node3") show("node4")
		end,
	},
	{
		id = "node4",
		text = _"You're the most annoying person I've ever met.",
		code = function()
			Npc:says(_"The same can be said from my part. Now, will you leave me alone?")
			hide("node4") show("node5")
		end,
	},
	{
		id = "node5",
		text = _"I'm serious. You're being rude and mean. What have I done for you?!",
		code = function()
			Npc:says(_"You're wasting my time. This is a reason good enough to I be mean.")
			Npc:says(_"I think I'll ignore you until you say something important.")
			hide("node5") show("node6", "node10")
		end,
	},
	{
		id = "node6",
		text = _"Where did you got your outfit?",
		code = function()
			Npc:says("...")
			hide("node6")
		end,
	},
	{
		id = "node10",
		text = _"You look strong.",
		code = function()
			Npc:says(_"I don't look strong. I [b]AM[/b] strong. I hunt bots, after all.")
			Tux:says(_"Well, I hunt bots too.")
			Npc:says(_"...are you being serious? No, you surely jest.")
			hide("node10") show("node11")
		end,
	},
	{
		id = "node11",
		text = _"Jest?? I am at least so strong as you!",
		code = function()
			Npc:says(_"Oh, is this a challenge?")
			Tux:says(_"...")
			Tux:says(_"...Yes.")
			Npc:says(_"Hmm. Good. I like challenges. We shall fight then, Linarian!")
			Npc:says(_"But I will be fair. Only when you get expertise at melee training, we can spar.")
			hide("node11") show("training_main")
		end,
	},
	{
		id = "node30",
		text = _"How do you dare to call me a penguin?? Face my wrath!",
		code = function()
			Npc:says(_"HAHAHA!")
			Npc:says(_"I've fought with many bots before, and I'll not be scared by a mere linarian.")
			Npc:says(_"Feel free to try, though. Anytime.")
			hide("node30") show("node31")
		end,
	},
	{
		id = "node31",
		text = _"Prepare to die!",
		code = function()
			Npc:says(_"Who, me? Didn't you mean... you?", "NO_WAIT")
			Npc:says(_"[b]She draws a short sword she kept hidden the whole time, and struck it against your chest.[/b]")
			Npc:says(_"Now you die.")
			Tux:del_health(50)
			Tux:says(_"Not... yet!", "NO_WAIT")
			Npc:says(_"[b]With visible effort, you manage to get away.[/b]")
			Npc:says(_"Come back, penguin... I'll make you... SUFFER.")
			Npc:set_faction("ms") -- She'll ignore robots just... for... YOU.
			hide("node31")
			end_dialog()
		end,
	},
	{
		id = "shop",
		text = _"I would like to trade with you.",
		code = function()
			Npc:says(_"Do I look some sort of vending machine to you? What makes you think I will have anything to trade with you?")
			Npc:says(_"I said you were overgrown earlier. Forget it. You're just a kid.")
			hide("shop")
		end,
	},


	-- This node turned kinda huge. Handles training.
	{
		id = "training_main",
		text = _"Can you train me, so I can get expertise at melee fighting for our promised fight?",
		code = function()
			if (Tux:get_skill("melee") == 0) then
				Npc:says(_"What?? I am not a Linarian babysitter!")
				Npc:says(_"See in the town if someone is fool enough to want to teach you the BASICS.")
				Npc:says(_"You better get out of my face!")
			-- Tux is on learning range, but haven't decided on a payment method yet
			elseif (Tux:get_skill("melee") > 0 and Tux:get_skill("melee") < 4 and not Erin_payment_method) then
				Npc:says(_"Oh, so the duck wants a lesson. So, tell me, what would I gain from that?", "NO_WAIT")
				Npc:says(_"My time is precious, after all.")
				hide("training_main") show("tm_money", "tm_training", "tm_weapons")
			elseif (Tux:get_skill("melee") == 1) then -- Novice -> Apprentice (Mace)
				Npc:says(_"You want me to train you, then? Have you already look on the mirror?", "NO_WAIT")
				Npc:says(_"You're more green than the color green. In fact, calling you a newbie would be a offense to the term itself.")
				Npc:says(_"But, maybe, with my training, you can improve. Assuming you can improve, that is. But it'll be hard, I warn you.")
				Npc:says(_"It's take or leave.")
				hide("training_main")
				if Erin_payment_method == "money" then
					show("apprentice_money")
				elseif Erin_payment_method == "training" then
					show("apprentice_training")
				elseif Erin_payment_method == "weapons" then
					show("apprentice_weapons")
				else -- (Something deemed impossible went wrong, silently fix it...)
					Erin_payment_method = false
					next("training_main")
				end
			elseif (Tux:get_skill("melee") == 2) then -- Apprentice -> Professional (Sword)
				Npc:says(_"Look who is back asking for more training. I'm amused.", "NO_WAIT")
				Npc:says(_"It seems like you've been doing your homework, uhm?")
				Tux:says(_"Of course I've improved. I have an excellent teacher, after all.")
				Npc:says(_"You...! Okay, maybe I took too easy previously! I will train you so hard this time, that you'll sweat blood!")
				Npc:says(_"Are you up for the challenge?!")
				hide("training_main")
				if Erin_payment_method == "money" then
					show("professional_money")
				elseif Erin_payment_method == "training" then
					show("professional_training")
				elseif Erin_payment_method == "weapons" then
					show("professional_weapons")
				else
					Erin_payment_method = false
					next("training_main")
				end
			elseif (Tux:get_skill("melee") == 3) then -- Professional -> Expert (Light Staff)
				Npc:says(_"Hey, look at what we got here.", "NO_WAIT")
				Npc:says(_"You're getting good. But not so good like me, though! Hahaha!")
				Npc:says(_"Tell me, I have one more task for you. Consider this... specialization.")
				Npc:says(_"Interested?")
				hide("training_main")
				if Erin_payment_method == "money" then
					show("expert_money")
				elseif Erin_payment_method == "training" then
					show("expert_training")
				elseif Erin_payment_method == "weapons" then
					show("expert_weapons")
				else
					Erin_payment_method = false
					next("training_main")
				end
			else -- Tux is an Expert. The promised fight can happen now.
				Npc:says(_"Heh. I don't want to admit it, but you got pretty good. You'll need to train by yourself now, if you want to improve further.")
				Tux:says(_"Don't get forgetful. I've challenged you to a duel. You said you would accept when I got stronger.")
				Npc:says(_"Indeed I did, but Saul needs my services now. I'm sorry, Linarian. You'll need to wait a few days before I can wash the floor with your head.")
				Tux:says(_"..Your head, you mean...")
				Npc:says(_"Hey, I won't be training you any further, but this doesn't mean I can't do anything for you. I have a strength pill. Here, take it.", "NO_WAIT")
				Tux:add_item("Strength Pill")
				Npc:says(_"May we cross our blades another time, Linarian. This is a promise.")
				-- at this point, we could send Erin to Slasher mountains or something...
				hide("training_main")
			end
		end,
	},

	-- Payment method selection
	{
		id = "tm_money",
		text = _"I have lots of valuables with me.",
		code = function()
			Erin_payment_method="money"
			Tux:says(_"You could use money to buy a better outfit, ya'know.")
			Npc:says(_"Hmm, that can do.")
			Npc:says(_"But be warned, I'm not cheap!")
			hide("tm_money", "tm_training", "tm_weapons") show("training_main")
		end,
	},
	{
		id = "tm_training",
		text = _"I'll train hard everyday, and make you proud by being the best disciple one could wish for.",
		code = function()
			Erin_payment_method="training"
			Tux:says(_"You will be able to brag about my deeds to all your friends.")
			Npc:says(_"Hmm, that can do.")
			Npc:says(_"But be warned, it'll be stressing!")
			hide("tm_money", "tm_training", "tm_weapons") show("training_main")
		end,
	},
	{
		id = "tm_weapons",
		text = _"I could arrange to expand your weapon arsenal.",
		code = function()
			Erin_payment_method="weapons"
			Npc:says(_"Hmm, that can do.")
			Npc:says(_"If you give me the weapons I ask for, that is!")
			hide("tm_money", "tm_training", "tm_weapons") show("training_main")
		end,
	},


	-- Dialog for trainings. Please note payment is handled in another node.
	{
		id = "apprentice",
		echo_text = false,
		code = function()
			Tux:says(_"Yes, please make me your apprentice.")
			Npc:says(_"Okay, try hitting me.")
			Tux:says(_"Hah! Me, hitting a female?")
			Tux:del_health(20)
			Npc:says(_"Shut up and do what you're told! Do you want to learn from me or not?!")
			Tux:says(_"YOU!!")
			Npc:says(_"[b]Erin, however, is too fast. She dodges all blows until you're too tired and collapse on the ground.[/b]")
			Npc:says(_"Haha, what a weakling! I wanted to say even a fly can hit harder than you, but you can't even hit!")
			Npc:says(_"Listen here, linarian. It's not about causing damage. It's about hitting your enemy.", "NO_WAIT")
			Npc:says(_"If you do not have the dexterity to hit them, your strength and physical won't matter, you'll die.")
			Npc:says(_"I hope you've learned your lesson! That I am better than you, that is.")
			Tux:improve_skill("melee")
			show("training_main")
			end_dialog()
		end,
	},
	{
		id = "professional",
		echo_text = false,
		code = function()
			Tux:says(_"I want to fight like a pro! I want to smash concrete with my bare hands!")
			Npc:says(_"So, let's have a duel.")
			Tux:says(_"What?? Hey wait, I wasn't even managing to hit you before--", "NO_WAIT")
			Tux:del_health(35)
			Npc:says(_"Shut up and do what you're told! I said you were going to sweat blood!")
			Tux:says(_"YOU!!")
			Npc:says(_"[b]This time you're more in shape, and even manage to hit her twice. Unfortunately, her hits were too hard and you give up not long after the fight begun.[/b]")
			Npc:says(_"Haha, you must be weaker than the bots here. Congratulations on hitting me twice, but you're still far from mastering melee, though.")
			Npc:says(_"I might be saying the obvious but... There's no point if you die.", "NO_WAIT")
			Npc:says(_"Giving up was, well, shameful, but you should remember that retreating is no reason of shame. When you retreat, you gain time.")
			Npc:says(_"You can do a lot of things with extra time. You can change your weapon, train some more, study your opponent, plan a strategy and even hack an army of robots to help you.")
			Npc:says(_"So, remember this! Retreating is an option! Dying is not!")
			Npc:says(_"...And take care. I might have seen some 123 bots nearby, and I think they're still too strong for you, so...")
			Tux:improve_skill("melee")
			show("training_main")
			end_dialog()
		end,
	},
	{
		id = "expert",
		echo_text = false,
		code = function()
			Tux:says(_"So, what do you want, Erin? To mop the ground with my head?")
			Npc:says(_"No, not this time.")
			Tux:says(_"Oh? What could it be to iron-clad Erin speak softly?")
			Tux:del_health(60)
			Npc:says(_"Shut up!!!")
			Npc:says(_"[b]Erin hit you pretty strongly, and you fall to the ground.[/b]")
			Npc:says(_"Oh, you survived. Congratulations. Maybe you can be useful, after all?")
			Npc:says(_"Today you'll learn stealth. By the hard way, that is.")
			Npc:says(_"South of here is the building they call... \"The Hell Fortress\". The Red Guard is responsible for its security so I can't get close.", "NO_WAIT")
			Npc:says(_"They took a necklace from me. Your task is to get it back. You can't fail.")
			Npc:says(_"Do it without killing them, and I'll consider you an expert at the melee arts. Because fighting is an art, it's not about killing.")
			-- TODO: Erin was planned to have tasks instead of simple dialog. But that's NYI so bear with us.
			Npc:says(_"[b]You somehow do it. One of the guards notice you sneaking at his belongings, but you knock him out to the ground and get away unnoticed.[/b]")
			Npc:says(_"Good job, newbie. You know, we might disagree with the Red Guard but we need them to protect those gates.")
			Tux:says(_"We?")
			Npc:says(_"There are many things you don't know, Linarian. The fall of the Red Guard is near. Now leave.")
			Tux:improve_skill("melee")
			show("training_main")
			end_dialog()
		end,
	},

	-- Handles payment by class and trade-coin
	{
		id = "apprentice_money",
		text = _"Please make me your apprentice! (costs 1000 circuits)",
		echo_text = false,
		code = function()
			if (Tux:can_train(1000, 0)) then
							Tux:del_gold(1000)
							hide("apprentice_money")
							next("apprentice")
			else
				next("no_money")
			end
		end,
	},
	{
		id = "apprentice_training",
		text = _"Please make me your apprentice! (costs 10 training points)",
		echo_text = false,
		code = function()
			if (Tux:can_train(0, 10)) then
							Tux:del_points(10)
							hide("apprentice_training")
							next("apprentice")
			else
				next("no_training")
			end
		end,
	},
	{
		id = "apprentice_weapons",
		text = _"Please make me your apprentice! (requires Mace)",
		echo_text = false,
		code = function()
			if (Tux:has_item_backpack("Mace")) then
							Tux:del_item_backpack("Mace", 1)
							hide("apprentice_weapons")
							next("apprentice")
			else
				Npc:says(_"Listen, Linarian, I want a mace to smash the bots.", "NO_WAIT")
				next("no_weapons")
			end
		end,
	},

	{
		id = "professional_money",
		text = _"Teach me how to smash concrete with my bare hands! (costs 3000 circuits)",
		echo_text = false,
		code = function()
			if (Tux:can_train(3000, 0)) then
							Tux:del_gold(3000)
							hide("professional_money")
							next("professional")
			else
				next("no_money")
			end
		end,
	},
	{
		id = "professional_training",
		text = _"Teach me how to smash concrete with my bare hands! (costs 15 training points)",
		echo_text = false,
		code = function()
			if (Tux:can_train(0, 15)) then
							Tux:del_points(15)
							hide("professional_training")
							next("professional")
			else
				next("no_training")
			end
		end,
	},
	{
		id = "professional_weapons",
		text = _"Teach me how to smash concrete with my bare hands! (requires Antique Greatsword)",
		echo_text = false,
		code = function()
			if (Tux:has_item_backpack("Antique Greatsword")) then
							Tux:del_item_backpack("Antique Greatsword", 1)
							hide("professional_weapons")
							next("professional")
			else
				Npc:says(_"Listen, Linarian, I want a Greatsword to say I have a Greatsword.", "NO_WAIT")
				next("no_weapons")
			end
		end,
	},

	{
		id = "expert_money",
		text = _"What do you want, Erin? I am ready to become an expert at melee! (costs 6500 circuits)",
		echo_text = false,
		code = function()
			if (Tux:can_train(6500, 0)) then
							Tux:del_gold(6500)
							hide("expert_money")
							next("expert")
			else
				next("no_money")
			end
		end,
	},
	{
		id = "expert_training",
		text = _"What do you want, Erin? I am ready to become an expert at melee! (costs 20 training points)",
		echo_text = false,
		code = function()
			if (Tux:can_train(0, 20)) then
							Tux:del_points(20)
							hide("expert_training")
							next("expert")
			else
				next("no_training")
			end
		end,
	},
	{
		id = "expert_weapons",
		text = _"What do you want, Erin? I am ready to become an expert at melee! (requires Light Saber)",
		echo_text = false,
		code = function()
			if (Tux:has_item_backpack("Light saber")) then
							Tux:del_item_backpack("Light saber", 1)
							hide("expert_weapons")
							next("expert")
			else
				Npc:says(_"Listen, Linarian, I want a Light Saber, because when I was just a child I saw a movie and since then I always wanted to have one.", "NO_WAIT")
				next("no_weapons")
			end
		end,
	},

	-- Failure messages. Some are too similar to other NPCs and should be changed.
	{
		id = "no_money",
		code = function()
			Npc:says_random(_"You need more circuits, or no training for you!",
							_"Please don't bother me if you can't pay me!",
							_"Come back when you have some circuits. A deal is a deal.",
							_"Keep your end on the bargain and come back when you have something of value.")
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
		id = "no_weapons",
		code = function()
			Npc:says_random(_"Keep your end on the bargain.",
							_"Give me the weapon and I'll give you training.",
							_"I expect you to bring me everything I've asked you to.")
		end,
	},

	{
		id = "node99",
		enabled = true,
		text = _"See you later.",
		code = function()
			if (not HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				Npc:says_random(_"Try to don't die until then.",
								_"Don't let the bots get you. If they do, you're dead.",
								_"Yeah yeah. Leave me alone.",
								_"...Finally...")
			else
				Npc:says_random(_"Watch where you step. There may be traps.",
								_"Yeah yeah. Leave me alone.",
								_"...Finally...")
			end
			end_dialog()
		end,
	},
}
