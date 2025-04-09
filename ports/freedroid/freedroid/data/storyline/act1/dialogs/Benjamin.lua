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
PERSONALITY = { "Militaristic", "Jovial", "Intelligent" },
PURPOSE = "$$NAME$$ helps improve Tux's abilities",
BACKSTORY = "$$NAME$$ is the Red Guard\'s weapons expert and armourer."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0")
		Benjamin_objective="None"
	end,

	EveryTime = function()
		if (Tux:has_met("Benjamin")) then
			Tux:says_random(_"Hello.",
							_"Greetings Master Benjamin.")
			Npc:says_random(_"Well, hello again.",
							_"Hello hello.",
							_"Welcome back.")
			if (Tux:has_item_equipped("The Super Exterminator!!!") or
				Tux:has_item_equipped("Exterminator")) then
				Npc:says(_"You are using a fine weapon. I wonder where you found it?")
				-- After all, if there is something I am sure of, is that Spencer would never give you one.
			end
		end
		show("node99")
	end,

	{
		id = "node0",
		text = _"Hello!",
		code = function()
			Npc:says(_"Ah, so you are the new member. Welcome. My name is Benjamin, and I take care of our ranged weaponry here in the citadel.")
			Npc:set_name("Benjamin - Gunsmith")
			hide("node0") show("node1", "node20", "node30")
		end,
	},
	{
		id = "node1",
		text = _"What are you doing here alone?",
		code = function()
			Npc:says(_"I'm experimenting with new designs. I want to redesign the laser pistol.")
			Npc:says(_"A lot of energy is wasted somewhere during firing, and I have no idea where. If I could find the source of the problem, the gun would become much more powerful.")
			Npc:says(_"So far all my prototypes have failed. Mostly overheating and jamming. Sometimes I wonder if I am doing something wrong.")
			hide("node1") show("node3", "node4", "node5")
		end,
	},
	{
		id = "node3",
		text = _"Did you think about somehow gathering the excess heat and using it to make the beam stronger?",
		code = function()
			Npc:says(_"Hmm... There might be something in that idea. I will think about it.")
			Benjamin_objective = "damage"
			hide("node3", "node4", "node5")
		end,
	},
	{
		id = "node4",
		text = _"If I were you, I would focus my work on the firing rate.",
		code = function()
			Npc:says(_"Hmm... I will think about it. Hmm...")
			Benjamin_objective = "firing"
			hide("node3", "node4", "node5")
		end,
	},
	{
		id = "node5",
		text = _"You know, laser pistols are not a very promising weapon. I think you should work on something different.",
		code = function()
			Npc:says(_"Yeah, maybe you are right. I will think about it.")
			Benjamin_objective = "plasma"
			hide("node3", "node4", "node5")
		end,
	},
	{
		id = "node20",
		text = _"Can you teach me how to properly use rifles and guns?",
		code = function()
			if (Tux:get_skill("ranged") == 0) then
				Npc:says(_"If anyone in this town knows more about guns than me, then my name's not Benjamin.", "NO_WAIT")
				Npc:says(_"Of course, I will need compensation for the ammunition spent in the training and for my time.")
				Npc:says(_"Say... A hundred circuits should be enough for a beginner lesson.")
				Npc:says(_"Interested?")
				show("node21")
			elseif (Tux:get_skill("ranged") == 1) then
				Npc:says(_"Oh, you are ready for some more training?", "NO_WAIT")
				Npc:says(_"It will of course cost a bit more money as well as mental focus on your part.")
				Npc:says(_"It will take you two hundred circuits and double the effort on your part to become a true apprentice.")
				Npc:says(_"Interested?")
				show("node22")
			elseif (Tux:get_skill("ranged") == 2) then
				Npc:says(_"I see you have taken a liking to guns.", "NO_WAIT")
				Npc:says(_"But the next step will cost even more money and require the mental focus equalling all your previous training.")
				Npc:says(_"Interested?")
				show("node23")
			elseif (Tux:get_skill("ranged") == 3) then
				Npc:says(_"To become an expert with firearms, you need ridiculous amounts of training.", "NO_WAIT")
				Npc:says(_"It will cost you 400 valuable circuits and an awful lot of mental focusing on the task.")
				Npc:says(_"Interested?")
				show("node24")
			elseif (Tux:get_skill("ranged") == 4) then
				Npc:says(_"Oh, you want to become a real master with shooters, just like me?", "NO_WAIT")
				Npc:says(_"It will of course cost a fair bit of cold, hard circuits as well. 500, to be precise.")
				Npc:says(_"Interested?")
				show("node25")
			else
				Npc:says(_"Sorry, there is no human alive that could give you further training.")
			end
			hide("node20")
		end,
	},
	{
		id = "node21",
		text = _"Sign up for a course in improving my ranged weapons skill. (costs 100 circuits, 3 training points)",
		echo_text = false,
		code = function()
			Tux:says(_"Yes, I'd like some basic training in ranged combat.")
			cost = 100
			if Tux:train_skill(cost, 3, "ranged") then
				Npc:says(_"Suits me well enough, I'm not busy at the moment anyway.")
				Npc:says(_"Now, the most important thing is that you turn off the auto-aim on your weapon, like this.", "NO_WAIT")
				Npc:says(_"Otherwise your weapon might 'help' you and shoot somewhere you didn't intend to fire.")
				Npc:says(_"The next important thing is to remember how to properly fire a shot.", "NO_WAIT")
				Npc:says(_"Watch your target closely. Pretend you're moving with it. Aim for the head.")
				Npc:says(_"When you feel completely in sync with your target, then you pull the trigger.", "NO_WAIT")
				Npc:says(_"Good. You are learning quickly. Try it a few more times.")
				Npc:says(_"Okay, I think that it is enough for today.")
				hide("node21") show("node20")
			else
				if (Tux:get_gold() < cost ) then next("node27") else next("node28") end
			end
		end,
	},
	{
		id = "node22",
		text = _"Yes, I want even more training. (costs 200 circuits, 6 training points)",
		echo_text = false,
		code = function()
			Tux:says(_"So let's start the second course?")
			cost = 200
			if Tux:train_skill(cost, 6, "ranged") then
				Npc:says(_"Very well.")
				Npc:says(_"You must remain calm whilst shooting.", "NO_WAIT")
				Npc:says(_"Try breathing out as you pull the trigger, and squeeze it gently rather than jerking it.")
				Npc:says(_"That's right. You will find yourself hitting the target much more often now.")
				hide("node22") show("node20")
			else
				if (Tux:get_gold() < cost ) then next("node27") else next("node28") end
			end
		end,
	},
	{
		id = "node23",
		text = _"I'm eager for more training. (costs 300 circuits, 9 training points)",
		echo_text = false,
		code = function()
			Tux:says(_"So can you help me become even better with guns?")
			cost = 300
			if Tux:train_skill(cost, 9, "ranged") then
				Npc:says(_"Of course.")
				Npc:says(_"Next lesson: hitting a moving target.")
				Npc:says(_"It's pretty simple really, just watch to see where it is going and then aim slightly ahead if you are using a non-laser gun.")
				Npc:says(_"It's easy when you know how, especially with bots, because they tend to move in straight lines, not bob and weave like people.")
				Npc:says(_"I think that it is enough training for now. Next time, firing on the move!")
				hide("node23") show("node20")
			else
				if (Tux:get_gold() < cost ) then next("node27") else next("node28") end
			end
		end,
	},
	{
		id = "node24",
		text = _"Yes, I wish to train some more. (costs 400 circuits, 12 training points)",
		echo_text = false,
		code = function()
			Tux:says(_"I'd like to learn how to be a crack shot.")
			cost = 400
			if Tux:train_skill(cost, 12, "ranged") then
				Npc:says(_"Firing on the move is difficult, but can make survival much more likely!")
				Npc:says(_"The secret is to keep your weapon steadily but loosely, so that it isn't jarred.")
				Npc:says(_"Oh yes, and be careful of your footing. You should be looking where you are firing, not where you are stepping.")
				Npc:says(_"Keep practising and you will get the hang of it eventually.")
				hide("node24") show("node20")
			else
				if (Tux:get_gold() < cost ) then next("node27") else next("node28") end
			end
		end,
	},
	{
		id = "node25",
		text = _"I want to become a master in ranged combat. (costs 500 circuits, 15 training points)",
		echo_text = false,
		code = function()
			Tux:says(_"Teach me how to be at one with my weapon.")
			cost = 500
			if Tux:train_skill(cost, 15, "ranged") then
				Npc:says(_"The ultimate secret to becoming a master in ranged combat is something you should value.")
				Npc:says(_"I don't tell everyone this, so keep it to yourself, all right?")
				Npc:says(_"To become a master in ranged combat you need to...")
				Npc:says(_"...practise. A lot.")
				Npc:says(_"Go ahead and use my firing range as much as you need.")
				hide("node25") show("node20")
			else
				if (Tux:get_gold() < cost ) then next("node27") else next("node28") end
			end
		end,
	},
	{
		id = "node27",
		code = function()
			Npc:says_random(_"You need more circuits.",
							_"Please don't bother me if you can't pay me.",
							_"I need cash to defray the costs of the ammo used in training.",
							_"I repeat, you need to bring enough to pay for the practice targets you destroy, and for my time.",
							_"You don't have enough money! I cannot afford to just give away training for free.",
							_"Come back when you have enough circuits.",
							_"So come back when you have something of value.")
		end,
	},
	{
		id = "node28",
		code = function()
			Npc:says_random(_"You are not ready. Go kill some bots and come back.",
							_"Come back when you are mentally prepared to learn.",
							_"Come back after some more practice in the field.",
							_"Only a well prepared mind is open to the ultimate in ranged combat secrets.",
							_"Waving those circuits in front of me when you are too unfocused to train won't help. I can take your money, but you won't learn anything.",
							_"I don't think you have enough experience for this. Come back after you see some more action.",
							_"Come back when you have a real will to learn.",
							_"You don't have enough experience. Come here after you see some more action.")
		end,
	},
	{
		id = "node30",
		text = _"What weapons are available to the members of the Red Guard?",
		code = function()
			Npc:says(_"Well, for novice members there are simple laser and plasma pistols. They have their share of problems, but they do the trick nine times out of ten.")
			Npc:says(_"For bigger bots we have bigger guns. The exterminator is the best weapon that we have. We hand them out only in case of an emergency, or to highly experienced people.")
			hide("node30") show("node31", "node32", "node33")
		end,
	},
	{
		id = "node31",
		text = _"Plasma sounds deadly.",
		code = function()
			Npc:says(_"It is!", "NO_WAIT")
			Npc:says(_"While many people find the ammunition canisters too big, and the bullets too slow, they cannot deny that once plasma hits, it leaves big holes.")
			Npc:says(_"Plasma is matter, ionized gas to be exact. It also happens to be hot enough to make steel boil.")
			Npc:says(_"Most of the new recruits hate how hard this weapon is to aim. If bullets were animals, then plasma would be a well fed cow. By the time it arrives at the target, the bot is already a mile away.")
			Npc:says(_"If you are going to use plasma weapons you need to remember one thing: Don't let the weapon get damaged.")
			Npc:says(_"Even though our armor is designed to resist high temperatures, once the plasma containment module goes, you will die, along with anything within ten meters of you.")
			Npc:says(_"Because of all those drawbacks, plasma weapons are not too popular. Quite a pity, they have great potential.")
			hide("node31")
		end,
	},
	{
		id = "node32",
		text = _"Tell me more about laser weapons.",
		code = function()
			Npc:says(_"Laser is an acronym for Light Amplification by Stimulated Emission of Radiation.")
			Npc:says(_"Laser is the technology employed in most of our weaponry. It uses a focused light beam to cause damage.")
			Npc:says(_"Because the beam is composed out of light, it travels REALLY fast, at the speed of light, so to say. It is also not affected by gravity or wind, which makes aiming easier.")
			Npc:says(_"However, other than being a good training tool for newbies, that design just fails to deliver.")
			Npc:says(_"The shots tend to be underpowered, the gun takes a long while to power up for a shot, and it can overheat during intense combat.")
			Npc:says(_"This is why I am trying to improve it, but so far I have had no success. I'm feeling pretty discouraged about it.")
			hide("node32")
		end,
	},
	{
		id = "node33",
		text = _"I am curious about the exterminator.",
		code = function()
			Npc:says(_"Sorry, but that is classified and confidential. I have said too much already.")
			hide("node33") show("node40")
		end,
	},
	{
		id = "node40",
		text = _"I will make it worth your while...",
		code = function()
			Npc:says(_"Intriguing.")
			Npc:says(_"Fifty circuits per bit of information.", "NO_WAIT")
			Npc:says(_"So... What do you exactly want to know?")
			hide("node40") show("node41", "node46", "node47", "node51", "node69")
		end,
	},
	{
		id = "node41",
		text = _"How many exterminators does the Red Guard have?",
		code = function()
			if (Tux:del_gold(50)) then
				Npc:says(_"It might come as a surprise to you, but we don't have many. A little over twenty, last time I checked.", "NO_WAIT")
				Npc:says(_"Thankfully, as you can clearly see, it's more than enough to keep all the cursed bots away.")
				hide("node41") show("node44")
			else
				next("node43")
			end
		end,
	},
	{
		id = "node43",
		text = _"Well, I am a bit short on circuits right now...",
		code = function()
			Npc:says(_"Linarian, I thought we had an agreement. Fifty per infobit. My silence can be only broken with currency, so if you want to know, you have to pay.", "NO_WAIT")
			Npc:says(_"This conversation is now over.")
			end_dialog()
		end,
	},
	{
		id = "node44",
		text = _"That is not many. Why there are so few of them right now?",
		code = function()
			if (Tux:del_gold(50)) then
				Npc:says(_"They were a very lucky find.", "NO_WAIT")
				Npc:says(_"We found a crashed army truck on the Terminal Field. It had six crates inside it, each containing five exterminators.")
				Npc:says(_"We tried, but we could not replicate the technology, only bullets.", "NO_WAIT")
				Npc:says(_"A few got damaged in battle, and we failed to recover five after a failed scout mission. We have twenty-two right now.")
				hide("node44") show("node49")
			else
				next("node43")
			end
		end,
	},
	{
		id = "node46",
		text = _"What is the exterminator ammunition made from?",
		code = function()
			if (Tux:del_gold(50)) then
				Npc:says(_"We use radioactive isotopes, whatever type happens to be on hand. Mostly plutonium and uranium, but we are not too picky.")
				Npc:says(_"When we get low on ammo, we send in a chain gang of criminals and sluggards into mine shaft K-17.")
				Npc:says(_"That place was closed down ages ago because of high radiation levels, but it's full of good ore from which we make bullets and power our nuclear reactors.")
				Npc:says(_"We get our fission materials, and they serve their sentence. It was one of the best ideas we have ever had.")
				hide("node46")
			else
				next("node43")
			end
		end,
	},
	{
		id = "node47",
		text = _"Tell me who designed the exterminator.",
		code = function()
			Npc:says(_"That answer is on the house. Heh.", "NO_WAIT")
			Npc:says(_"We do not know, Linarian. We have absolutely no clue.")
			hide("node47")
		end,
	},
	{
		id = "node49",
		text = _"What was the failed mission?",
		code = function()
			Npc:says(_"Ugh. That will cost you triple.", "NO_WAIT")
			Npc:says(_"No. Wait.")
			Npc:says(_"I changed my mind.", "NO_WAIT")
			Npc:says(_"Keep your money Linarian. No amount of circuits can make me talk about that accursed day.")
			hide("node49")
		end,
	},
	{
		id = "node51",
		text = _"What makes the exterminator so powerful?",
		code = function()
			if (Tux:get_gold(50)) then
				Npc:says(_"That's a tricky question. Most of the force comes from the miniature nuclear explosions which happen once the bullet hits something.")
				Npc:says(_"Of course, the high velocity of the impact can cause tremendous devastation by itself.")
				Npc:says(_"We never bothered with doing much research on that topic. It works, and that is enough for us.")
			else
				next("node43")
			end
			hide("node51")
		end,
	},
	{
		id = "node69",
		text = _"That is all I want to know.",
		code = function()
			Npc:says(_"Very well. Oh... This conversation never happened.")
			hide("node41", "node44", "node46", "node47", "node49", "node51", "node69")
		end,
	},
	{
		id = "node99",
		text = _"I will be going then.",
		code = function()
			Npc:says(_"See you later!")
			end_dialog()
		end,
	},
}
