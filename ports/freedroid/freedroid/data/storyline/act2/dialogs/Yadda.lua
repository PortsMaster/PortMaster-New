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
--[[WIKI13
PERSONALITY = { "Wise", "Arrogant" },
PURPOSE = "$$NAME$$ is a strange monk who follows the path of light. Options become available as you talk to him. Gives quest to slay evil glitches. Give quests for Source Book of Light, Light Saber and Light Staff. Is a pacifist with a weak resolve. May summon droids to help Tux in certain quests, or to kill tux if he appears to be walking on an evil path, be it because bad karma, or because strange items on his  possession.",
BACKSTORY = "Please refer to key-characters section on website."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		Yadda_times=0
		Yadda_TP_cost=1
		Yadda_books_bought=0
		Yadda_vmx_saber=20+(math.random(5,7)*difficulty_level())
		show("node99")
		Npc:says(_"Welcome to my temple of peace. People say I am the wisest man alive on the world, but I think I am the wisest on the universe!", "NO_WAIT")
		cli_says(_"And in case you're wondering: ", "NO_WAIT")
	end,

	EveryTime = function()
		--
		Npc:says(_"Greetings, I'm Master Yadda. I teach the path of light.")

		-- Those two conditions make Yadda hostile and wanting to kill tux at once. (Maybe could use extra explanation)
		if (Tux:has_item_equipped("Nobody's edge")) then
			next("evil")
		elseif (Tux:has_item_backpack("Pandora's Cube")) then
			next("pandora")
		end

		-- Show player bad options, like showing Nobody's Edge and such.
		if (Tux:has_item_backpack("Nobody's edge")) then
			show("evil")
		end

		if (Tux:has_quest("Message From An Old Friend") and not Yadda_PGP) then
			Yadda_PGP=true
			show("pgpkey")
		end
		-- Yadda's wise advises and time-dependent events.
		Yadda_times=Yadda_times + 1
		if (Yadda_times==1) then
			Npc:says(_"Come and seek my lightly advises every now and then, and you'll find out truth and light.")
			Tux:assign_quest("The Reapers Of MegaSys I", _"Master Yadda seems to be a very wise man, and I should talk to him a lot more.")
		elseif (Yadda_times==3) then
			Npc:says(_"The only skill worth acquiring in the world: Light.")
			show("book")
		elseif (Yadda_times==7) then
			Npc:says(_"Persistence is the way to perfection.")
		elseif (Yadda_times==13) then
			-- Note for self: thirteen thirty-seven = 1337
			Npc:says(_"I have secrets, but you are not ready for them.")
			Npc:says(_"If you talk to me thirty seven times, as in thirteen thirty-seven, I'll teach them.")
			Tux:update_quest("The Reapers Of MegaSys I", _"Sorry, Master Yadda is ANNOYING! But he promised to tell me a secret if I keep talking to him.")
		elseif (Yadda_times==37) then
			Npc:says(_"This is the 37th time you ask me for enlightenment, as in thirteen thirty-seven. I'll teach you a secret. There is a super-strong bot on this area. Might be worth checking out.")
			show("C64gate")
		elseif (Yadda_times==15) then
			Npc:says(_"I accidentally overkilled a bot and lost my Light Saber in the process. What a shame. Already built a new one, though.")
			show("saber")
		elseif (Yadda_times==28) then
			Npc:says(_"I haven't seen any Alpha Bot lately. Things are strangely calm. And the calm precedes the storm.")
			show("bots")
		-- Random quotes. If we're not in an specific event from above, give Tux a “wise” advice.
		elseif (Yadda_times < 20) then
			-- All texts below are quotes adapted to FreedroidRPG world.
			Npc:says_random(_"In matters of destroying bots, style, not brute force, is the vital thing.",
							_"Any fool can bust a bot open; the art consists in knowing how to exploit it.",
							_"The knife is without measure, for if you hit a bot right, out will come treasure.",
							_"When the linarian fall, the bots reigns.",
							_"A linarian is only finished when he gives up.",
							_"Yadda Yadda Yadda.",
							_"Basically, it's just a jump to the left, and a step to the right... You see?")
		elseif (Yadda_times < 40) then
			-- Texts below aren't quotes, but advises. Some disagree, specially the Yadda parts.
			Npc:says_random(_"No one knows what the future awaits. Except Master Yadda.",
							_"Yadda Yadda Yadda.",
							_"The secret of the sure victory is siding with Master Yadda.",
							_"Kill bots first, ask questions later.",
							_"There was the Experimental Alpha Class. If you meet one, your death is close.",
							_"If you can think, you're sentient. This won't make you a life-form though.",
							_"Lamps are nice. Always carry one with you. You never know when you'll need them.",
							_"Bots will aim whatever is in front of them. Which, in most cases, will be you.")
		else
			Npc:says(_"You're very dedicated, seeking my advice, and wise words that much. But I have nothing else to tell you. Besides that: ")
			--; TRANSLATORS: %d = number of times talked to Yadda
			Npc:says(_"You've asked for my wise advice %d times. Maybe you should start figuring things out on your own.", Yadda_times)
		end


		show("node99")
	end,

	{
		id = "pgpkey",
		text = _"Master, I've been looking for a PGP key in order to unlock a certain file.",
		code = function()
			Tux:says(_"Your wisdom is not mensurable, it's so high to be understood by mere mortals like me, you surely must know where I can find it.")
			 -- Tux probably expected: “You're quite right, except for one thing. I do not know where this key is.”
			Npc:says(_"Indeed, you're quite right there.", "NO_WAIT")
			Npc:says(_"You can find it walking south and entering on the first trapdoor you see.")
			Tux:says(_"I thought you would tell me in a riddle.") -- “Actually, I thought you wouldn't tell me at all.”
			Npc:says(_"Well, you would find it if you explored this map for two minutes. To be asking it you must be as lazy as me, so I decided to just tell you right away. Please enjoy this Island.")
			hide("pgpkey")
		end,
	},
	{
		id = "C64gate",
		text = _"I heard there was a dangerous bot which needs killing. Where is it?",
		code = function()
			Npc:says(_"Indeed, an evil bot there is. A glitch from the gamers at MegaSys threatens this lands.", "NO_WAIT")
			Npc:says(_"If you defeat it, the fictional survivors which aren't here because the Great Assault would be very grateful. You will also gain a nice amount of experience, and who knows what it will drop?", "NO_WAIT")
			Tux:says(_"Seems interesting. Where can I find it?")
			Npc:says(_"Just follow the water, young apprentice of Yaddawan. Only the ones with enough faith can walk over water and save the world!")
			Tux:update_quest("The Reapers Of MegaSys I", _"The first Reaper of MegaSys, The Glitch, can be found by walking over the water on Icy Summer Island. I better stay away, as searching for it is a death wish.")
			del_obstacle("Act2-ArtificialPassage-1")
			del_obstacle("Act2-ArtificialPassage-2")
			hide("C64gate")
		end,
	},
	{
		id = "book",
		text = _"I want that skill you mentioned earlier.",
		code = function()
			Tux:says(_"Light skill, was it?")
			Npc:says(_"Of course I can show you the wonderful program called [b]Light[/b], but I'm too lazy to actually teach you anything.", "NO_WAIT")
			Npc:says(_"Therefore I shall write at hand a book explaining the wonders of light. But such wonderful skill will requires some readiness of mind to absorb it's rich content.")
			--; TRANSLATORS: %d = number of training points required to buy the book.
			Npc:says(_"For you, it'll cost only 2.000 circuits and %d training points.", Yadda_TP_cost)
			show("buybook")
		end,
	},
	{
		id = "buybook",
		text = _"I want to buy the Source Book of Light for the price you mentioned earlier.",
		code = function()

			-- Check if player can buy the book
			if (Tux:get_gold() < 2000) then
				next("no_money")
			elseif (Tux:get_training_points() < Yadda_TP_cost) then
				next("no_points")
			else -- Everything is OK. Get the book.
				Tux:del_training_points(Yadda_TP_cost)
				Tux:add_gold(-2000)
				Tux:add_item("Source Book of Light", 1)
				Yadda_books_bought=Yadda_books_bought+1
				if (Yadda_books_bought % 3 == 0) then
					Yadda_TP_cost=Yadda_TP_cost+1
				end

				-- Fancy message
				if (Yadda_books_bought % 3 == 1) then
					Npc:says(_"It's a deal. May the light guide your path.")
				elseif (Yadda_books_bought % 3 == 2) then
					Npc:says(_"Deal. Light guide you forever.")
				else
					Npc:says(_"Here is the book. May the light guide your steps.")
				end

				-- Limit to 10 sells
				if (Yadda_books_bought == 10) then
					Npc:says(_"I won't sell you anymore from now on.")
					hide("book")
				elseif (Yadda_books_bought == 9) then
					Npc:says(_"I'll sell you only one extra copy. Be sure to don't waste it.")
				elseif (Yadda_books_bought == 7) then
					Npc:says(_"I'll sell you only three copies more.")
				end

				hide("buybook")
			end
		end,
	},
	{
		id = "saber",
		text = _"You crafted a light saber? Amazing! Can I have one?",
		code = function()
			Npc:says(_"The light saber is for the disciples of light.")
			Tux:says(_"I'm always eager to hear your wisdom, o wise master Yadda.")
			Npc:says(_"I'm too wise to be fooled by your praises, young apprentice. But yet, I shall craft one to you, for a small price of my wisdom.")
			Npc:says(_"I shall require 5.000 circuits in compensation for my efforts, 3 source books of light to prove your worthiness and eagerness to learn from my wise words... And...")
			Tux:says(_"...And?")
			--; TRANSLATORS: %d = number of VMX grenades required to craft the Light Saber. Varies according to difficulty.
			Npc:says(_"...And %d VMX Gas Grenades. I'm a pacifist, but the disciples of dark - robots and programmers - soughs for my life. Only with gas grenades I shall survive. They're poison to mere mortals, but for the great master Yadda, they are source of life.", Yadda_vmx_saber)
			--; TRANSLATORS: %d = number of VMX grenades required to craft the Light Saber. Varies according to difficulty.
			Tux:says(_"I have no idea of how life can come out from gas grenades, and how a gas grenade can kill a bot, but I shall bring you 5.000 circuits, 3 source books of light, and %d VMX grenades.", Yadda_vmx_saber)
			hide("saber") show("buysaber")
		end,
	},
	{
		id = "buysaber",
		text = _"I have the 5.000 circuits, 3 source books of light, and the VMX grenades you requested. Gimme the saber!",
		code = function()

			-- Check if player can buy the saber
			if (Tux:get_gold() < 5000) then
				next("no_money")
			elseif (Tux:count_item_backpack("Source Book of Light") < 3) then
				Npc:says(_"And the proof of eagerness? I require three source books of light.")
			elseif (Tux:count_item_backpack("VMX Gas Grenade") < Yadda_vmx_saber) then
			--; TRANSLATORS: %d = number of VMX grenades required to craft the Light Saber. Varies according to difficulty.
				Npc:says(_"I really need %d VMX Gas Grenades to protect myself from the disciples of dark. I won't give you a light saber without it.", Yadda_vmx_saber)
			else -- Everything is OK. Get the saber.
				Tux:add_gold(-5000)
				-- FIXME: Source Book of Light doesn't stacks. Therefore, it's necessary to call the function three times.
				-- This is a fragility from C code to delete items. Other functions might work without this additional care.
				Tux:del_item_backpack("Source Book of Light")
				Tux:del_item_backpack("Source Book of Light")
				Tux:del_item_backpack("Source Book of Light")
				Tux:del_item_backpack("VMX Gas Grenade", Yadda_vmx_saber)
				Tux:add_item("Light saber", 1)

				Npc:says(_"Here it is.")
				Tux:says(_"So quick? I thought you were going to craft it?")
				Npc:says(_"I have dozens of those. I do them on my spare time.")

				hide("saber", "buysaber")
			end
		end,
	},
	{
		id = "bots",
		text = _"Wise master Yadda, could you please instruct again this humble servant of light about what are the Alpha Bots?",
		code = function()
			Npc:says(_"Hah. They're all experimental, most might be scrap in a single shoot, but they all have... skills... which more than makes up for any deficiency they might have.", "NO_WAIT")
			Npc:says(_"My friend, I hope you never meet any of them. They should be only rumors, though.")
			Npc:says(_"Also, I heard from the bard something about Agent Zero not managing to get a good designer for these droids and reusing existing droid models on them.", "NO_WAIT") -- An excuse for missing art.
			Npc:says(_"They should be all at the locked Ice Pass area, north from here. I hope...")
			--Npc:says(_"If this is the case, you might think you're meeting a normal bot and be surprised when it causes havoc because it's from the Alpha class.") -- Missing art can be used as extra difficulty. Still would be better to not provoke mistakes because that.
			--Npc:says(_"There is the [b]001 Influencer[/b]. It can take over your bots. If your army suddenly become hostile to you, one might be near.")
			Npc:says(_"There is the [b]002 Pillbody[/b]. That bot is made to stand under heavy fire. If you find them, be careful as more dangerous bots will come.") -- Also have good sensors
			Npc:says(_"There is also the [b]011 Grenadier[/b]. Will throw grenades to destroy your army. Mass destruction. Kill it as fast as you can.")
			Npc:says(_"Not to mention the [b]021 Wizard[/b]. This one is nasty, so I hope you have an army, because it can slow you, paralyze, it can even poison you, so don't trifle with it.")
			Npc:says(_"Finally there is the [b]Marvin[/b]. I am not sure what it does, because no one returned alive after fighting one. Even the droid number is unknown.")
			Tux:says(_"Sounds dangerous.")
			Npc:says(_"Ha! Not even the start. Agent Zero did many tests on this area to create the supreme foe. There are bots at graveyard too: [b]Zombot[/b] and you won't want to know what it does, the [b]Ghost[/b] and [b]Shadow Hunter[/b], uses invisibility so very dangerous.", "NO_WAIT") -- Maybe the Zombot is the 001 model, which take over your droids
			Npc:says(_"There is also [b]Ghoul Bots[/b] and the silly [b]Pepper Bot[/b] who you won't care with when suddenly! You're dead.")
			Tux:says(_"Sounds extremely dangerous.")
			Npc:says(_"The alpha class carries on. They are only experiments, weak and not mass produced, so you might have a chance against them with my advises. But I must warn you that further on you might find specialized droids using those characteristics. When this happen, I hope you have The Holy Light blessings.")
			Tux:says(_"Thank you. I shall look for one of those experimental droids to practice.")
			Npc:says(_"You won't find them. Do not worry about it.")
			--Npc:says(_"...I hope you know what you're doing.")
		end,
	},
	{
		id = "evil",
		text = _"I have this nice weapon here, want to take a look?",
		code = function()
			Npc:says(_"Nobody's Edge! How do you dare to bring such evil pulsing weapon to those lands!!", "NO_WAIT")
			--; TRANSLATORS: Komm und hilf mir → Come and aid me (from German, use whatever you used with Geist)
			Npc:says(_"Komm und hilf mir, minions! Let's kill this... this... heretic!")
			Npc:set_faction("ms")
			create_droid("Act2-YaddaRef1", "GUB", "ms", "AfterTakeover", "radar")
			create_droid("Act2-YaddaRef2", "GUA", "ms", "AfterTakeover", "radar")
			end_dialog()
		end,
	},
	{
		id = "pandora",
		text = _"I found this small cube on a desert.",
		code = function()
			Npc:says(_"The Pandora Box! How do you dare to bring doom to those lands!!", "NO_WAIT")
			--; TRANSLATORS: Komm und hilf mir → Come and aid me (from German, use whatever you used with Geist)
			Npc:says(_"Komm und hilf mir, minions! Let's kill this doom bringer!")
			Npc:set_faction("ms")
			create_droid("Act2-YaddaRef1", "GUB", "ms", "AfterTakeover", "radar")
			create_droid("Act2-YaddaRef2", "GUA", "ms", "AfterTakeover", "radar")
			end_dialog()
		end,
	},
	{
		id = "no_money",
		code = function()
			Npc:says_random(_"Please don't bother me if you can't pay me.",
				_"No money, no deal.",
				_"I was pretty clear about the amount of money I wanted.")
		end,
	},
	{
		id = "no_points",
		code = function()
			Npc:says_random(
				_"Come back when you have a real will to learn.",
				_"You don't have enough experience. You'll never understand my wisdom like this.")
		end,
	},
	{
		id = "node99",
		text = _"Erm... That was very wise, thank you. I'll think about what you said.",
		code = function()
			Npc:says_random(_"Stay on the path of light.",
							_"I'm pure wisdom. If you follow my words you'll have success.",
							_"Wisdom is more worth than rubies. But if it's my wisdom, it'll be more worth than the whole universe!",
							_"Take as much time you need to reflect on what I said, and you'll become wise, because I am the wisest man on this universe.")
			end_dialog()
		end,
	},
}
