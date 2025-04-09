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
PERSONALITY = { "Delusional", "Lonely", "Heartbroken", "Intelligent" },
MARKERS = {
	NPCID1 = "Koan",
	NPCID2 = "SADD",
	QUESTID1 = "Tania's Escape",
	ITEMID1 = "Strength Pill",
},
PURPOSE = "$$NAME$$\'s entrapment is the subject of the quest $$QUESTID1$$. Tux must rush to prevent $$NPCID2$$ from attacking $$NAME$$.",
BACKSTORY = "$$NAME$$ is a brilliant biologist who worked in the \'Secret Area\' facility. This facility developed and produced
	 $$ITEMID1$$s. Since The Great Assault, $$NAME$$ has been living locked up in the facility. Initially, $$NAME$$ had a companion,
	 Peter, who, after consuming too many $$ITEMID1$$s, became delusional about his increased abilities and perished in an accident.",
RELATIONSHIP = {
	{
		actor = "$$NPCID1$$",
		text = "The relationship between $$NAME$$ and $$NPCID1$$ is unclear. However, $$NAME$$ will respond badly if Tux
		 has killed him."
	},
}
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0")
	end,

	EveryTime = function()
		show("end_default")
		if (Koan_murdered) then
			Npc:says(_"You just killed him!")
			Npc:says(_"How could you?")
			Npc:says(_"You murderer!")
			npc_faction("crazy", _"Tania - Avenging Koan")
			end_dialog()
		end

		if (Tux:has_quest("Tania's Escape")) then
			hide("node1", "node2", "node3", "node4", "node5", "node6", "node7", "node10", "node11", "node12", "node13", "node14", "node17", "node18", "node19", "end_default")
			if (not Tania_position) then -- Tania hasn't moved yet - she isn't following Tux.
				Npc:says_random(_"I long to see the surface.",
								_"You are the most interesting hallucination yet.")
				show("end_default")
				if (not SACD_gunsoff) then --Guns are still on
					hide("node27")
					show("node28")
				elseif (not Tania_guns_off) then --Guns are off, but you haven't told Tania yet
					hide("node28")
					show("node27")
				else --Tania can escape, but you haven't decided to let her follow you yet
					hide("node27", "node28")
					show("node40", "node41")
				end
			elseif (Tania_position == "underground") then --Tania is following you, but still Underground
				Npc:says(_"I can't wait to leave this place.")
				show("end_underground")
			elseif (Tania_position == "desert") then --in the Western Desert
				if (not Tania_discussed_surface) then
					Tania_discussed_surface = true
					Npc:says(_"It is so very bright and hot out here.") --thirsty dialog
					show("node45", "node46", "node47")
				elseif (Npc:get_damage() > 10) then --skip to injury dialog
					next("node55")
				else
					Npc:says_random(_"Are we there yet?",
									_"How much longer?")
				end
				show("end_desert")
			elseif (Tania_position == "bunker") then --in the Western Desert
				show("end_desert") --TODO: Tania talks about the bunker and Koan
			elseif (Tania_position == "town_gate") and npc_dead("Pendragon") and (not Tania_met_Pendragon) then
				Tux:says(_"We hit town. Welcome to your new home!")
				Npc:says(_"Thank you so much! I have dreamed to leave this underground hell.")
				Tux:says(_"You are free to go where you like.")
				change_obstacle_state("DesertGate-Inner", "opened")
				Tania:teleport("W-enter-2") --Ensure that Tania is on Level 0!
				Tania:set_state("patrol")
				Npc:set_destination("BarPatron-Enter")
				next("tania_enter_town")
				-- TODO: Spencer can learn than Tux let Tania enter freely and react to it.
			elseif (Tania_position == "town_gate") and (not Spencer_Tania_decision) then --at the Town Entrance, waiting for Spencer's OK
				hide("node45", "node46", "node47", "node49", "node50", "node51", "node52", "node53", "node56", "node57", "node58", "node59", "end_desert")
				if (not Tania_met_Pendragon) then
					Tania_met_Pendragon = true
					Tux:update_quest("Tania's Escape", _"Pendragon just stopped Tania and I at the town gate. Apparently he won't let her in, unless Spencer gives the go-ahead.")
					Npc:says(_"It is OK. I'll wait here at the gate.")
					end_dialog()
				end
				show("end_towngate")
			elseif (Tania_position == "town_gate") then --Town Entrance then (if Doc is alive) send her DocMoore's office, else set free (send to Bar)
				Npc:says(_"What is the news?")
				Tux:says(_"I talked to Spencer, and he said you are welcome to enter the town.")
				Npc:says(_"That is great news!")
				if (Spencer_Tania_decision == "doc_moore") then
					Tux:says(_"He said you must first get checked out by Doc Moore though.")
					Npc:set_destination("DocPatient-Enter")
				else -- (Spencer_Tania_decision == "free") -- DocMoore is Dead!
					Tux:says(_"He said you are free to go where you like.")
					Npc:set_destination("BarPatron-Enter")
				end
				next("tania_enter_town")
			elseif (Tania_position == "town") then --"Tania's Escape" was a success!
				if (Spencer_Tania_decision == "doc_moore") then --send to Bar
					Spencer_Tania_decision = "doc_moore_free"
					Npc:heal()
					Npc:says(_"I have good news: the doctor says I'm healthy!")
					Npc:says(_"Where should I go?")
					if (Tux:done_quest("Anything but the army snacks, please!")) then
						show("node70")
					else
						show("node71")
					end
				end
				hide("end_towngate") -- It's possible that this node is still visible, so be sure it's hidden
				show("end_town")
			end
		end

		if (Tania_heal_node8) then
			show("node8")
		end
	end,

	{
		id = "node0",
		text = _"Um, hi.",
		code = function()
			Npc:says(_"Oh! It happened! I have been waiting for you for 3226 hours!") --@TODO use gametime (hours since game started) instead of 3226 hours ?
			hide("node0") show("node1", "node3", "node14", "node19")
		end,
	},
	{
		id = "node1",
		text = _"You knew I would come?",
		code = function()
			Npc:says(_"Of course, my little imaginary friend!")
			hide("node1") show("node2", "node5")
		end,
	},
	{
		id = "node2",
		text = _"Imaginary?! I am as real as you are.",
		code = function()
			Npc:says(_"This place is locked. Hermetically sealed and guarded by bots. So you can't possibly be anything more than the product of my imagination.")
			Tux:says(_"But who are you?")
			Npc:says(_"A figment of my imagination should know my name: Tania.")
			Npc:set_name("Tania - lonely scientist")
			hide("node2") show("node12")
		end,
	},
	{
		id = "node3",
		text = _"Where am I?",
		code = function()
			Npc:says(_"In a prison, a luxurious prison. I am feeling quite lonely, as you can see. Big room, plenty of food, a waterfall behind the window...")
			hide("node3") show("node4", "node6")
		end,
	},
	{
		id = "node4",
		text = _"All I see through the window are ray emitters. And we are below ground level..",
		code = function()
			Npc:says(_"Yes, I know. But I so badly want to see the sun, the trees and the rivers... there definitely is a waterfall behind them!")
			hide("node4")
		end,
	},
	{
		id = "node5",
		text = _"It is dark here.",
		code = function()
			Npc:says(_"The main power supply is down, so only the emergency lights work. Peter tried to switch it back on, but he didn't succeed.")
			hide("node5")
		end,
	},
	{
		id = "node6",
		text = _"This place doesn't look like a prison.",
		code = function()
			Npc:says(_"In the past it was a secret lab. You heard about those strength pills? They were invented here. Other pills too, but I was working on the strength ones.")
			hide("node6") show("node7", "node8")
		end,
	},
	{
		id = "node7",
		text = _"Can you give me some pills then?",
		code = function()
			Npc:says(_"No, Peter ate them all. That killed him.")
			Npc:says(_"*cries*")
			Tux:says(_"They say that strength pills are absolutely safe!")
			Npc:says(_"They are like money. Having money is good, but if you have too much, you can decide that you can do anything.")
			Npc:says(_"Peter became not very strong, but very-very-very strong. He thought he could make an exit with his bare hands.")
			Npc:says(_"*cries*")
			Npc:says(_"If you go further down the corridor, you will find debris and a big stone. That is his grave.")
			hide("node7") show("node10", "node11")
		end,
	},
	{
		id = "node8",
		text = _"So you are a biologist? Could you heal me?",
		code = function()
			Npc:says(_"That would be something different from what I've done in the last months at least. Some entertainment.")
			Npc:says_random(_"Let me take a look at that... it's nothing some nanobots couldn't take care of.... You will be all fixed up in a minute.",
							_"You are now completely healed. You should take better care of yourself.")
			Tux:heal()
			Tania_heal_node8 = true
			hide("node8")
		end,
	},
	{
		id = "node10",
		text = _"You loved him?",
		code = function()
			Npc:says(_"I still do.")
			hide("node10")
		end,
	},
	{
		id = "node11",
		text = _"But why not go out through the door?",
		code = function()
			Npc:says(_"It is locked and very reliable. Even a tank would not be able to smash it! And if a door was broken, SADDs would attack, that's their program.")
			hide("node11") show("node18")
		end,
	},
	{
		id = "node12",
		text = _"Autoguns have made a hole in the wall. I came through this hole.",
		code = function()
			Npc:says(_"Do you mean I can go out to the surface?!")
			Npc:says(_"Oh god! I - I told Peter that he chose the wrong place, but he was so stubborn!")
			hide("node12") show("node13")
		end,
	},
	{
		id = "node13",
		text = _"Yes, you can get to the surface. But the guns are still on.",
		code = function()
			Npc:says(_"All hope is lost! I'm a scientist, not a warrior.")
			hide("node13") show("node15")
		end,
	},
	{
		id = "node14",
		text = _"It is strange to see a girl in such a beautiful dress here.",
		code = function()
			Npc:says(_"I'm going to spend all my life here! So forgive me some little indulgences.")
			hide("node14")
		end,
	},
	{
		id = "node15",
		text = _"Maybe is it possible to disable the guns?",
		code = function()
			Npc:says(_"Theoretically yes, but in practice I'm not sure you would be able to do that.")
			hide("node15") show("node16")
		end,
	},
	{
		id = "node16",
		text = _"How can I disable the guns?",
		code = function()
			Npc:says(_"Somewhere in a distant part of the lab should be an SACD - Secret Area Control Datacenter. It controls all the defense systems in the base. If you manage to get to it, you would be able to control the base. However, it's very hard to find and get to the SACD.")
			hide("node16") show("node17")
		end,
	},
	{
		id = "node17",
		text = _"I will disable the guns for you.",
		code = function()
			Npc:says(_"Thanks... please be careful. You will not be able to access the control center directly, it is behind a triple hermetic door. Try using the service tunnels.")
			Tux:add_quest("Tania's Escape", _"I have met a girl locked in a secret area. If I manage to disable the autoguns, she will be able to go to the surface and look at the sun again.")
			Npc:says(_"It's dangerous to go alone! Take this!")
			if (difficulty("easy")) and
			   (not Tania_mapper_given == true) then
				Tux:add_item("Source Book of Network Mapper")
				Tania_mapper_given = true
			end
			Tux:add_item("EMP Shockwave Generator", 5)
			hide("node17")
		end,
	},
	{
		id = "node18",
		text = _"Why not just open them? There should be a way of unlocking the base.",
		code = function()
			Npc:says(_"To open the door you need to know the password. Only the commander of the area and his deputy knew it. The commander was killed by bots as soon as the assault started, and the deputy was in town, I don't know what happened to him.")
			hide("node18")
		end,
	},
	{
		id = "node19",
		text = _"Carpets, sofa, bookshelves. Where did you get all this?",
		code = function()
			Npc:says(_"Peter did all he could to make this room comfortable. The sofa and armchair are from the commander's cabinet, the books are from the lounge...")
			hide("node19")
		end,
	},
	{
		id = "node27",
		text = _"The sentry guns are off. You can go now!",
		code = function()
			Npc:says(_"Thanks, thanks a lot! Now I will be able to see the sun, the trees and the rivers... I missed them so much!")
			Npc:says(_"I hope these books will help you.")
			display_big_message(_"Tania is now free!")
			Tux:add_xp(1500)
			if (difficulty("normal")) and
			   (not Tania_mapper_given == true) then
				Tux:add_item("Source Book of Network Mapper")
				Tania_mapper_given = true
			end
			Tux:add_item("Source Book of Check system integrity",1)
			Tux:add_item("Source Book of Sanctuary",1)
			Tux:update_quest("Tania's Escape", _"Tania is free now, I got some books as a reward.")
			Tux:says(_"You could always come back with me to the town. There are people there.")
			Npc:says(_"I'd love to, but you'll have to escort me.")
			Tania_guns_off = true
			hide("node27") show("node40", "node41")
		end,
	},
	{
		id = "node28",
		text = _"Where can I find that SACD?",
		code = function()
			Npc:says(_"To the right from the entrance of the area, there is a hall. In the south part of this hall you will find a triple hermetic door. The control center is behind that door. But it is locked, so you will have to find another way there. The cable collectors may help you.")
			hide("node28")
		end,
	},
	{
		id = "node40",
		text = _"I'm not ready to escort you to the town.",
		code = function()
			next("end_default")
		end,
	},
	{
		id = "node41",
		text = _"I'm ready to escort you to the town.",
		code = function()
			Tania_position = "underground"
			Tux:update_quest("Tania's Escape", _"I have agreed to escort Tania to the town. Once I'm there, I'll introduce her to Spencer.")
			Npc:set_state("follow_tux")
			hide("node8", "node40", "node41") next("end_underground")
		end,
	},
	{
		id = "node45",
		text = _"It isn't all like this, the town is very nice.",
		code = function()
			hide("node45", "node46", "node47") next("node48")
		end,
	},
	{
		id = "node46",
		text = _"I got lost in this desert once.",
		code = function()
			hide("node45", "node46", "node47") next("node48")
		end,
	},
	{
		id = "node47",
		text = _"It must be hard adjusting to the bright sunlight.",
		code = function()
			Npc:says(_"I was underground for so long.")
			Npc:says(_"It is all so bright on my eyes.")
			hide("node45", "node46", "node47") next("node48")
		end,
	},
	{
		id = "node48",
		code = function()
			number_of_liquid_items = 0
			if (Tux:has_item_backpack("Bottled ice")) then
				number_of_liquid_items = number_of_liquid_items + 1
				show("node49")
			end
			if (Tux:has_item_backpack("Industrial coolant")) then
				number_of_liquid_items = number_of_liquid_items + 1
				show("node50")
			end
			if (Tux:has_item_backpack("Liquid nitrogen")) then
				number_of_liquid_items = number_of_liquid_items + 1
				show("node51")
			end
			if (Tux:has_item_backpack("Barf's Energy Drink")) then
				number_of_liquid_items = number_of_liquid_items + 1
				show("node52")
			end
			if (number_of_liquid_items > 0) then
				Npc:says(_"I hope we get there soon. I'm very thirsty.")
			else
				next("node54")
			end
			show("node53")
		end,
	},
	{
		id = "node49",
		text = _"Would you like some bottled ice?",
		code = function()
			Npc:says(_"Thank you very much.")
			Npc:says(_"I feel very refreshed!")
			Npc:heal()
			Tux:del_item_backpack("Bottled ice")
			Tux:update_quest("Tania's Escape", _"Tania wasn't prepared for the desert heat. I gave her some bottled ice, and she looked much more healthy.")
			hide("node49", "node50", "node51", "node52", "node53")
		end,
	},
	{
		id = "node50",
		text = _"I have some industrial coolant you could have.",
		code = function()
			Npc:says(_"I can't drink this.")
			if Tux:has_met("Ewald") then
				Tux:says(_"I've seen the town bartender put it in drinks.")
				Npc:says(_"I guess I'll give it a try then.")
				Tux:del_item_backpack("Industrial coolant")
				Npc:heal()
				Npc:says(_"I feel very cold, but better.") --TODO: freeze her here
				Tux:update_quest("Tania's Escape", _"Tania wasn't prepared for the desert heat. I gave her some Industrial coolant. At first, she was hesitant, but she tried it.")
				hide("node49", "node50", "node52", "node53")
			else
				next("node54")
			end
			hide("node51")
		end,
	},
	{
		id = "node51",
		text = _"Can I offer you some liquid nitrogen?",
		code = function()
			Npc:says(_"I can't drink this.")
			next("node54") hide("node51")
		end,
	},
	{
		id = "node52",
		text = _"You could have a bottle of Barf's Energy Drink if you are thirsty?",
		code = function()
			Npc:says(_"Thank you very much.")
			Npc:says(_"I feel very energetic!")
			Npc:heal()
			Tux:del_item_backpack("Barf's Energy Drink")
			Tux:update_quest("Tania's Escape", _"Tania wasn't prepared for the desert heat. I gave her a bottle of Barf's Energy Drink. After downing it in a couple seconds, she looked much more energetic!")
			hide("node49", "node50", "node51", "node52", "node53")
		end,
	},
	{
		--THIS WILL BE A LIE
		id = "node53",
		text = _"Sorry, I have nothing to offer you.",
		code = function()
			Npc:says(_"I feel very ill.")
			Tux:update_quest("Tania's Escape", _"Tania wasn't prepared for the desert heat, but I decided not to share any of my liquids with her.")
			Npc:drop_dead()
			hide("node49", "node50", "node51", "node52", "node53")
		end,
	},
	{
		id = "node54",
		code = function()
			number_of_liquid_items = number_of_liquid_items - 1
			if (number_of_liquid_items < 1) then
				if (Npc:get_damage() > 10) then
					next("node55")
				else
					Npc:says(_"I feel a little faint, but I think I will survive.")
				end
				hide("node53")
			end
		end,
	},
	{
		id = "node55",
		code = function()
			injured_level = 0
			if (Npc:get_damage() > 10) then
				Npc:says(_"I am injured!")
				injured_level = 1
			elseif (Npc:get_damage() > 40) then
				Npc:says(_"I am badly injured!")
				injured_level = 2
			elseif (Npc:get_damage() > 60) then
				Npc:says(_"I am seriously injured!")
				injured_level = 3
			end

			if (Tux:has_item_backpack("Doc-in-a-can")) then
				show("node59")
			end
			if (Tux:has_item_backpack("Antibiotic") and
			   (injured_level < 3)) then
				show("node58")
			end
			if (Tux:has_item_backpack("Diet supplement") and
			   (injured_level < 2)) then
				show("node57")
			end
			show("node56")
		end,
	},
	{
		id = "node56",
		text = _"There is nothing I can do about your injuries right now.",
		code = function()
			Npc:says(_"I hope we get to the town soon.")
			hide("node56", "node57", "node58", "node59")
		end,
	},
	{
		id = "node57",
		text = _"Here, take this Diet supplement.",
		code = function()
			Npc:says(_"I feel better now.")
			Tux:del_item_backpack("Diet supplement")
			Npc:heal()
			hide("node56", "node57", "node58", "node59")
		end,
	},
	{
		id = "node58",
		text = _"I'm prescribing you some antibiotics.",
		code = function()
			Npc:says(_"I feel much better.")
			Tux:del_item_backpack("Antibiotic")
			Npc:heal()
			hide("node56", "node57", "node58", "node59")
		end,
	},
	{
		id = "node59",
		text = _"I have a Doc-in-a-can. It should heal you right up.",
		code = function()
			Npc:says(_"I feel fit as new!")
			Tux:del_item_backpack("Doc-in-a-can")
			Npc:heal()
			hide("node56", "node57", "node58", "node59")
		end,
	},
	{
		id = "tania_enter_town",
		code = function()
			Tania_position = "town"
			Tux:end_quest("Tania's Escape", _"I successfully brought Tania safely to the town. I hope she likes it here.")
			if (difficulty("hard")) and
			   (not Tania_mapper_given == true) then
				Npc:says(_"I'm so glad that I am finally here, take this.")
				Tux:add_item("Source Book of Network Mapper")
				Tania_mapper_given = true
			end
			if (not npc_dead("Pendragon")) then
				start_chat("Pendragon")
			end
			end_dialog()
		end,
	},
	{
		id = "node70",
		text = _"I think you would enjoy some of Michelangelo's cooking at the restaurant.",
		code = function()
			Npc:set_destination("BarPatron-Enter")
			Tania_at_Ewalds_Bar = true
			Npc:says(_"It has been so long since I've had a nice meal.")
			hide("node70")
		end,
	},
	{
		id = "node71",
		text = _"You might try the bar. But stay away from the food. It is horrible.",
		code = function()
			Npc:set_destination("BarPatron-Enter")
			Tania_at_Ewalds_Bar = true
			Npc:says(_"I really miss good food, especially lemon meringue pie.")
			Npc:says(_"Oh well.")
			hide("node71")
		end,
	},
	{
		--Pre-"Tania's Escape" Quest
		id = "end_default",
		text = _"I think I have to go.",
		code = function()
			Npc:says_random(_"That's OK. But please, please, come back. I'm so lonely.",
							_"Please come back again and get me out of here.")
			hide("end_default") end_dialog()
		end,
	},
	{
		--"Tania's Escape" Quest (Underground)
		id = "end_underground",
		text = _"Follow me to the Surface!",
		code = function()
			Npc:says(_"Lead on, my little penguin.")
			hide("end_underground") end_dialog()
		end,
	},
	{
		--"Tania's Escape" Quest (Western Desert)
		id = "end_desert",
		text = _"Follow me to the Town!",
		code = function()
			Npc:says(_"Lead on, my little penguin.")
			hide("end_desert") end_dialog()
		end,
	},
	{
		--"Tania's Escape" Quest (Western Town Gate)
		id = "end_towngate",
		text = _"Wait here.",
		code = function()
			Npc:says(_"OK. But please, come back soon.")
			hide("end_towngate") end_dialog()
		end,
	},
	{
		--"Tania's Escape" Quest (Western Town Gate to Doctor's Office)
		id = "end_town",
		text = _"See you later.",
		code = function()
			Npc:says_random(_"Please stay safe!",
							_"Thanks again.",
							_"Please come back again, my little penguin.")
			hide("end_town") end_dialog()
		end,
	},
}
