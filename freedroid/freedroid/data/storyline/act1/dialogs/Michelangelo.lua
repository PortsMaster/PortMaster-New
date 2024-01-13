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
PERSONALITY = { "Depressed", "Frustrated" },
MARKERS = { ITEMID1 = "Red Dilithium Crystal" },
PURPOSE = "$$NAME$$ directs Tux to where he can find $$ITEMID1$$s.",
BACKSTORY = "$$NAME$$ is frustrated by his inability to be a chef, as well as his current working conditions.",
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		Michelangelo_food_cooking_time = 0
		show("node0")
	end,

	EveryTime = function()
		hide("node29") -- the node will be re-shown later if we have enough crystals

		if (Tux:has_quest("Anything but the army snacks, please!")) then
			if (Tux:done_quest("Anything but the army snacks, please!")) then
				show("node24") hide("node11")
				if (Tux:has_quest("SADD's power supply")) then
					if (Tux:done_quest("SADD's power supply")) then
						hide("node75", "node76", "node77")
					else
						if (not Tux:has_item_backpack("Red Dilithium Crystal")) then show("node40", "node75") end
					end
				end
				if (Tux:has_quest("Gapes Gluttony")) then
					if (not Tux:done_quest("Gapes Gluttony")) then
						show_if((not Michelangelo_been_asked_meal_to_go), "node21")
						hide("node24")
					elseif (Tux:has_item_backpack("Empty Picnic Basket")) then
						show("node22")
					end
				end
			else
				local nb_crystals = Tux:count_item_backpack("Red Dilithium Crystal")
				if (nb_crystals > 2) then
					show("node29")
				elseif (nb_crystals > 0) then
					show("node30")
				else
					if (Michelangelo_been_asked_for_army_snacks) then
						show("node26")
					else
						show("node12")
					end
					show("node31", "node32", "node40")
				end
			end
		end
		show("node99")
	end,

	{
		id = "node0",
		text = _"Hi! I'm new here.",
		code = function()
			Npc:says(_"Hello. I'm Michelangelo. I haven't been here for long either.")
			Npc:says(_"I wish the bots had just killed me, but I got 'lucky' and ended up in this hellhole.")
			Npc:set_name("Michelangelo - Chef")
			hide("node0") show("node10", "node11")
		end,
	},
	{
		id = "node10",
		text = _"How is it going?",
		code = function()
			Npc:says(_"Don't ask.")
			Npc:says(_"'Terribly' would be a huge understatement.")
			hide("node10") show("node18")
		end,
	},
	{
		id = "node11",
		text = _"Can I buy some food here?",
		code = function()
			Npc:says(_"There is no food here, just the odious military rations.")
			Npc:says(_"They are made fully out of artificial nutrients and carcinogenic flavors. Even the army hated them.")
			Npc:says(_"It's better than starving, but some people have already committed suicide because that repulsive material is the only thing available to eat.")
			Npc:says(_"I can give you some, but it's not worthy of being called food.")
			if (Michelangelo_been_asked_for_army_snacks) then
				show("node26")
			else
				show("node12")
			end
			hide("node11")
		end,
	},
	{
		id = "node12",
		text = _"I want some yummy army snacks!",
		code = function()
			if (Tux:has_item("Fork", "Plate", "Mug")) then
				if (Tux:has_item_equipped("Fork")) then
					Npc:says(_"I am supposed to read this out to all newcomers. Here goes:")
					Npc:says(_"'Please note that the army rations model #23 you are about to eat is provided 'as is' without warranty of any kind.")
					Npc:says(_"That includes the implied warranty of edibility or fitness for a particular purpose. The entire risk as to the quality of the food is with you.")
					Npc:says(_"Should the army meal model #23 prove poisonous, you agree to cover the cost of keeping you alive by the base medical staff or the costs of your cremation in our nuclear furnaces.'")
					Npc:says(_"Well, that is all. Here is the junk that you wanted. Enjoy.")
					Michelangelo_been_asked_for_army_snacks = true
					next("node27")
					hide("node12")
				else
					Npc:says(_"You need to equip your fork before you can use it to eat.")
				end
			else
				Npc:says_random(_"You need to have a full mess kit with a Fork, Mug, and Plate before I can give you any army snacks.",
								_"You need a Fork, Plate, and Mug before I can issue any army snacks.",
								_"You need a full mess kit for army snacks.")
			end
		end,
	},
	{
		id = "node18",
		text = _"You do not sound happy. What is wrong?",
		code = function()
			if (guard_follow_tux) then
				Npc:says(_"I am very happy! The Red Guard is making us so secure, it is great to live here with them taking care of us!")
			else
				Npc:says(_"EVERYTHING!")
				Npc:says(_"Just look at this stupid town!")
				Npc:says(_"We are constantly pushed around by our 'saviors' the rotten Red Guard. I hope they all die from rat bites as soon as possible and go to the deepest hells to boil in lava forever.")
				Npc:says(_"And the bots are keeping us busy by murdering, chopping, slicing, cleaving, rending and wounding us. How wonderful.")
				Npc:says(_"The guards gave me a filthy hovel to live in. The walls are so thin that every night I am rocked to sleep by the bots communicating with those beeps and modem sounds.")
				Npc:says(_"It sounds like they are singing something. Every night they start their song... I cannot sleep thanks to that electric chorus.")
				Npc:says(_"Have I mentioned that the only food that we have is some kind of pestilential military ration? The smell alone is making me want to vomit.")
				hide("node18") show("node19", "node20")
			end
		end,
	},
	{
		id = "node19",
		text = _"Cheer up! All will be fine! Happy days are coming! Hurray!",
		code = function()
			Npc:says(_"...")
			Npc:says(_"Linarian, have you been gorging on psychoactive pills or something?")
			Npc:says(_"Get a grip, the situation is bad and there is no use in pretending otherwise.")
			hide("node19")
		end,
	},
	{
		id = "node20",
		text = _"You are a cook. Stop complaining about the poor food! Make some yourself.",
		code = function()
			Npc:says(_"I cannot! My beautiful macrowave oven is out of power. The wretched Red Guard took away my uranium battery.")
			Npc:says(_"I wish I could kill them all with my bare hands. They deserve it.")
			Npc:says(_"If only I had some dilithium to use as a backup power source...")
			hide("node20") show("node40", "node41", "node42", "node70", "node80")
		end,
	},
	{
		id = "node21",
		text = _"Can I get a meal to go?",
		code = function()
			Tux:says(_"I've found a man who has nothing left to eat but army snacks. He has information for me, but I've got to feed him first.")
			Npc:says(_"I see. We do not have much to spare, but I will see what I can do. I will let you borrow my picnic basket, but I must have it back.")
			Npc:says(_"Here... This meal should satisfy his hunger. I even added a dessert.")
			Tux:update_quest("Gapes Gluttony", _"Michelangelo gave me a healthy meal with dessert for Will Gapes. I have to remember to return the basket!")
			Tux:says(_"Thank you. I'm sure it will be delicious.")
			Tux:add_item("Lunch in a Picnic Basket")
			Michelangelo_been_asked_meal_to_go = true
			hide("node21")
		end,
	},
	{
		id = "node22",
		text = _"I've brought your Picnic Basket back.",
		code = function()
			Npc:says(_"Oh, thank you. Hopefully, the meal hit the spot.")
			Tux:says(_"Yes, he enjoyed it, and I got my information.")
			Npc:says(_"Excellent! Now, perhaps these antibiotics will help you on your mission.")
			Tux:del_item_backpack("Empty Picnic Basket")
			Tux:add_item("Antibiotic", 3)
			hide("node22")
		end,
	},
	{
		id = "node24",
		text = _"Got any food yet?",
		code = function()
			-- The cooking of food take 5 in-game minute.
			if (game_time() - Michelangelo_food_cooking_time < 300) then
				Npc:says(_"I'm confused, nothing of my upper gastronomy is ready to eat. Not one cheese cake.")
				Npc:says(_"But don't despair, Michelangelo is slaving over his stove. A army of bots could not stop the Master when he's cooking.")
				Npc:says(_"Until my next batch of food comes out of the macrowave oven, all I have are the odoriferous military rations.")
				if (Michelangelo_been_asked_for_army_snacks) then
					show("node26")
				else
					show("node12")
				end
			else
				if (not Michelangelo_food_dish) then
					Michelangelo_food_dish = math.random()
				end
				if (Michelangelo_food_dish > 0.9) then
					Npc:says(_"Here, try this slice of lemon meringue pie.")
					if (not Tux:has_item("Fork")) then
						Npc:says(_"Wait, you don't have a fork. You need a fork...")
					elseif (not Tux:has_item_equipped("Fork")) then
						Npc:says(_"You need to equip your fork before you can use it to eat.")
					else
						Tux:says(_"It is as if a cloud from heaven was made into a pie.")
						Tux:hurt(-20)
						Michelangelo_food_dish = false
						Michelangelo_food_cooking_time = game_time() -- wait before you can eat.
					end
				elseif (Michelangelo_food_dish > 0.8) then
					Npc:says(_"Try this crab cake.")
					if (not Tux:has_item("Fork")) and
					   (not Tux:has_item_backpack("Plate")) then
						Npc:says(_"Where is your plate and fork?")
					elseif (not Tux:has_item_equipped("Fork")) then
						Npc:says(_"You need to equip your fork before you can use it to eat.")
					else
						Tux:says(_"Such an intense, delectable, blend of savory spices... it melts in my mouth.")
						Tux:hurt(-40) -- cholesterol not included ;-)
						Michelangelo_food_dish = false
						Michelangelo_food_cooking_time = game_time() -- wait before you can eat.
					end
				elseif (Michelangelo_food_dish > 0.6) then
					Npc:says(_"May I interest you in some eggs sardou?")
					Tux:says(_"EGGS!?")
					Npc:says(_"Oh, Michelangelo had forgotten...")
					Npc:says(_"How about a... yummy army snack instead?")
					Michelangelo_food_dish = false
					Michelangelo_food_cooking_time = game_time() -- wait before you can eat.
					if (Michelangelo_been_asked_for_army_snacks) then
						show("node26")
					else
						show("node12")
					end
				elseif (Michelangelo_food_dish > 0.4) then
					Npc:says(_"I am in the midst of a culinary masterpiece.")
					Npc:says(_"I cannot rush art for I am an artist!")
					Michelangelo_food_dish = false
				else
					Npc:says(_"I had prepared some delicacies, but the ravenous Red Guard ate it all.")
					Npc:says(_"Not a big loss, I have a second batch of food cubes in the oven and they will be ready shortly.")
					Npc:says(_"I think the mood in the town will improve once the cooking master Michelangelo gets to work. Ha!")
					Npc:says(_"But if you are really hungry, I still have some of those disgusting army snacks.")
					Michelangelo_food_dish = false
					Michelangelo_food_cooking_time = game_time() -- wait before you can eat.
					if (Michelangelo_been_asked_for_army_snacks) then
						show("node26")
					else
						show("node12")
					end
				end
			end
			hide("node24")
		end,
	},
	{
		id = "node26",
		text = _"I am racked with hunger pains, give me some army snacks!",
		code = function()
			Npc:says(_"I thought you would have learned by now.")
			Npc:says(_"As you wish.")
			hide("node26") next("node27")
		end,
	},
	{
		id = "node27",
		text = _"Hmm... Crunchy... That is... Oh... No. Ugh. Help.",
		code = function()
			Npc:says(_"Oh yes. You were warned, so don't blame me.")
			Tux:says(_"Bleah! That is not food!")
			Npc:says(_"We already know that. There is nothing else to eat here, so I hope you get used to the taste.")
			Npc:says(_"That thing only looks okay, and has a nice color.")
			Npc:says(_"But as you can see, the color cannot be eaten, only the taste counts.")
		end,
	},
	{
		id = "node29",
		text = _"I have the dilithium you wanted.",
		code = function()
			Npc:says(_"Really? I thought you were dead, but not only did you come back alive, you also brought some power crystals for my trusty oven.")
			Npc:says(_"I will start cooking at once.")
			Npc:says(_"Thank you, Linarian. As soon as the food cubes are ready I will be able to give them away to the hungry people.")
			display_big_message(_"Restored Michelangelo's power supply")
			Tux:add_xp(350)
			Tux:del_item_backpack("Red Dilithium Crystal", 3)
			Tux:end_quest("Anything but the army snacks, please!", _"I gave the cook, Michelangelo, enough dilithium to last a decade. The evil spectre of eating army snacks is lifted from the town's cantina.")
			Michelangelo_food_cooking_time = game_time() -- wait before you can eat.
			hide("node29", "node31", "node32", "node40")
		end,
	},
	{
		id = "node30",
		text = _"I have the dilithium you wanted.",
		code = function()
			Npc:says(_"Really? I thought you were dead, but not only did you come back alive, you also brought some power crystals for my trusty oven.")
			Npc:says(_"However, I need at least three crystals. Can you come back with all the crystals I need?")
			hide("node30")
		end,
	},
	{
		id = "node31",
		text = _"What was I supposed to do again?",
		code = function()
			Npc:says(_"Get me three dilithium crystals before the whole stupid town commits mass suicide because of poor food quality.")
			Npc:says(_"Of course our heinous food might do us in far before that. I swear I saw that stuff glow it the dark and try to sneak away from my plate a few times.")
			hide("node31")
		end,
	},
	{
		id = "node32",
		text = _"Where can I find dilithium crystals?",
		code = function()
			Npc:says(_"There is an old abandoned dilithium mine is to the east of the town.")
			Npc:says(_"Be careful if you go down there!")
			hide("node32")
		end,
	},
	{
		id = "node40",
		text = _"What is this 'dilithium'?",
		code = function()
			Npc:says(_"You do not know? I thought Linarians were unmatched in their knowledge of the universe. Anyway...")
			Npc:says(_"Dilithium is a substance which is usually seen in the form of a small crystal.")
			Npc:says(_"It somehow generates and stores amazing amounts of electricity. I do not know the details. I'm a cook, not a quantum scientist.")
			hide("node40")
		end,
	},
	{
		id = "node41",
		text = _"I have an idea. Use fire to cook the food for the town.",
		code = function()
			Npc:says(_"A nice idea, but there is a couple of major problems with it.")
			Npc:says(_"We are a town of 450 hungry people. It would need to be a very big fire to supply heat for all of the meals.")
			Npc:says(_"There is nothing to burn inside the town. If you want you can go and try to chop some trees in the region to the north, but odds are the bots will chop you down before you get a chance to swing the hatchet once.")
			Npc:says(_"Finally, the meal cubes which we have in the freezer are optimized for macrowaves. If we stick them in a fire they will combust and not cook.")
			Npc:says(_"No oven means having to use premacrowaved food.")
			Npc:says(_"And the only such thing around is that abhorrent military sludge.")
			hide("node41")
		end,
	},
	{
		id = "node42",
		text = _"Tell the Red Guard that you need your battery back.",
		code = function()
			if (tux_has_joined_guard) then
				Npc:says(_"Well, you ARE a Red Guard", "NO_WAIT")
				Npc:says(_"Why can't you just talk to Spencer?")
				Npc:says(_"I want my battery back!")
				Tux:says(_"Umm... I guess you have a point there.")
				Tux:says(_"But sorry, I don't think there is anything I can do right now,", "NO_WAIT")
				Tux:says(_"Talk to Spencer yourself.")
			else
				Npc:says(_"I did.")
				Npc:says(_"They said it was already fed to their reactor as fuel.")
			end
			hide("node42")
		end,
	},
	{
		id = "node70",
		text = _"Why don't you send someone for the dilithium?",
		code = function()
			Npc:says(_"I did.")
			Npc:says(_"Yesterday a guard patrol found a few tiny bits of him and lots of dried blood.")
			Npc:says(_"The bots made a bloody mess out of him.")
			hide("node70")
		end,
	},
	{
		id = "node75",
		text = _"I need a dilithium crystal.",
		code = function()
			Npc:says(_"I am already using the ones you got me. They are being used to feed the town.")
			if (Michelangelo_been_asked_for_spare_dilithium) then
				show("node76")
			else
				show("node77")
			end
			hide("node75") show("node32")
		end,
	},
	{
		id = "node76",
		text = _"I need one of the dilithium crystals back, it is a matter of life or death!",
		code = function()
			Npc:says(_"I gave you all of the crystals I can spare.")
			hide("node76")
		end,
	},
	{
		id = "node77",
		text = _"I need one of the dilithium crystals back, it is a matter of life or death!",
		code = function()
			Npc:says(_"I guess I can spare one of them, since it is an emergency.")
			Michelangelo_been_asked_for_spare_dilithium = true
			Tux:add_item("Red Dilithium Crystal", 1)
			Tux:update_quest("SADD's power supply", _"I remembered that I gave Michelangelo three dilithium crystals when he only needed two for his oven. I convinced him it was a life-or-death situation (is the SADD a life-form?) so he returned the spare one to me. Looks like I saved myself a trip back to the old dilithium mine!")
			hide("node77")
		end,
	},
	{
		id = "node80",
		text = _"Maybe I can get you some dilithium.",
		code = function()
			Npc:says(_"Have you gotten overheated, Linarian?")
			Npc:says(_"Look, there are dozens of ways you can kill yourself, and most hurt less than being killed by a bot.")
			Npc:says(_"If you want to die just walk into a nuclear reactor or something. So much simpler.")
			hide("node80") show("node81")
		end,
	},
	{
		id = "node81",
		text = _"Don't worry, I'll be fine.",
		code = function()
			Npc:says(_"Do you know how the bots act? Some want to kill you as soon as possible... Others want to do the same, but slowly.")
			Npc:says(_"I have seen corpses with nearly all of the fingers ripped off. People with eyes drilled out by some big tool.")
			Npc:says(_"I have smelled burnt meat and heard the screams of the captives as they were incinerated alive outside the town walls.")
			Npc:says(_"The bots know no mercy. They cannot even define it, infernal scrap metal fiends.")
			Npc:says(_"Feel free to go, Linarian, but make sure to be very dead before they start killing you.")
			Tux:says(_"Where can I get the crystals?")
			Npc:says(_"There is an old dilithium mine to the east. I am sure there is lots of that stuff there.")
			Npc:says(_"I will talk to the guards, they will open the eastern gate for you.")
			Npc:says(_"Good luck. Try not to get yourself killed.")
			Tux:says(_"How many dilithium crystals do you need?")
			Npc:says(_"A single small crystal could power my oven for a decade if it is of good quality. But unfortunately my oven requires two to operate correctly. And since it is so dangerous to send anyone to get dilithium, could you get me a spare as well?")
			Tux:says(_"So you need three dilithium crystals?")
			Npc:says(_"Yes. Please get me three dilithium crystals.")
			change_obstacle_state("EastGateOfTown", "opened")
			Tux:add_quest("Anything but the army snacks, please!", _"I am supposed to get three dilithium crystals for that cook, Michelangelo. Without them he cannot cook anything in his macrowave oven. And without his cooking, the whole town is stuck eating army snacks. Many people have committed suicide because of the horrible food. This madness must stop.")
			hide("node19", "node40", "node41", "node42", "node70", "node81")
		end,
	},
	{
		id = "node99",
		text = _"I'll be going then.",
		code = function()
			Npc:says(_"See you later.")
			end_dialog()
		end,
	},
}
