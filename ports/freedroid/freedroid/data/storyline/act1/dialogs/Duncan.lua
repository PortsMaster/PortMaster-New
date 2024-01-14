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
PERSONALITY = { "Devious", "Focused", "Polite", "Vengeful" },
MARKERS = { NPCID1 = "Koan" },
PURPOSE = "$$NAME$$ sells grenades to Tux. $$NAME$$ also hints at the future of the Red Guard.",
BACKSTORY = "$$NAME$$ is the bomb maker for the Red Guard. $$NAME$$ hints that he threw a grenade that caused great
	 destruction and resulted in the loss of many of \'his people\'.",
RELATIONSHIP = {
	{
		actor = "$$NPCID1$$",
		text = "$$NAME$$ is the opposite of $$NPCID1$$. $$NAME$$ destroys life while $$NPCID1$$ creates life."
	},
}
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	EveryTime = function()
		if (Tux:has_met("Koan")) then
			hide("node56")
		end

		if (not Tux:has_met("Duncan")) then
			show("node0", "node90", "node99")
		elseif (not guard_follow_tux) and
		       (not Duncan_Koan_quest) then
			next("node50")
		end

		if (not Duncan_Koan_quest_really_done) then
			if (Tux:has_item_backpack("Pandora's Cube")) or
			   (Koan:is_dead()) or
			   (Koan_spared_via_dialog) then
				--Koan died, and you brought the cube back or
				--Koan died, but you didn't bring the cube back or
				--Koan is alive!
				if (not Duncan_Koan_quest_done) then --if you just came back from Koan
					next("node60")
				elseif (not Duncan_not_given_cube) and
				       (Koan:is_dead()) then
					--if, after talking to Duncan, Koan became dead
					next("node60")
				end
			end
		end

		if (tux_has_joined_guard) then
			hide("node3", "node4")
		end

		if (Duncen_node_62_hide) then
			hide("node62")
		end
	end,

	{
		id = "node0",
		text = _"Hi... Erm... Who are you?",
		code = function()
			Npc:says(_"Duncan McNamara, The Red Guard's resident bomb maker, at your service.")
			Npc:set_name("Duncan - Bombmaker")
			hide("node0", "node90") show("node1")
		end,
	},
	{
		id = "node1",
		text = _"I would like to buy a bomb.",
		code = function()
			Npc:says_random(_"Yes. I am sure we can arrange something. Take a look.",
							_"Sure. These are my offers today.")
			trade_with("Duncan")
			if (not guard_follow_tux) then
				hide("node1") show("node2", "node7")
			end
		end,
	},
	{
		id = "node2",
		text = _"I see only grenades. Do you have something bigger?",
		code = function()
			Npc:says(_"My deepest apologies, I do not.")
			Npc:says(_"The Red Guard prohibits the sales of extremely destructive munitions.")
			Npc:says(_"It is not yet the time for the fall of their rule, so I remain loyal.")
			hide("node2") show("node3", "node4", "node5", "node6")
		end,
	},
	{
		id = "node3",
		text = _"The fall of the Red Guard? I am going to report that you are inciting a revolution!",
		code = function()
			Npc:says(_"My word against yours. If you wish to try it, please, be my guest.")
			Npc:says(_"I am not inciting anything. I am just stating what I see as inevitable in the future.")
			Npc:says(_"I have taken part in many conflicts and I have seen how governments collapse.")
			Npc:says(_"As soon as the war is over, the Red Guard will disband.")
			if (not HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				Npc:says(_"Of course, I am making the assumption of victory, which is highly unlikely with the current state of affairs.")
			else
				Tux:says(_"The war is already over. The bots are all dead.")
				Npc:says(_"It's still too early to sing victory. You need some time to realize if you truly won or if you're just playing along someone's else plan.")
				Tux:says(_"Someone else? Like whom?")
				Npc:says(_"How can you be sure everyone behind the Great Assault is dead, Linarian? Or that it wasn't done on purpose? Only time will tell.")
			end
			hide("node3", "node4")
		end,
	},
	{
		id = "node4",
		text = _"The fall of the Red Guard? Tell me more about it.",
		code = function()
			Npc:says(_"It is not the time to speak of such things yet. Come another day, and we shall talk about it in more detail.")
			Npc:says(_"The Red Guard can have their great laser beams and plasma cannons... But nothing can save them.")
			hide("node3", "node4")
		end,
	},
	{
		id = "node5",
		text = _"I want to buy some grenades.",
		code = function()
			Npc:says_random(_"Certainly.",
							_"Sure.",
							_"With pleasure.")
			trade_with("Duncan")
		end,
	},
	{
		id = "node6",
		text = _"What kind of grenade is the best?",
		code = function()
			Npc:says(_"You get what you pay for.")
			hide("node6")
		end,
	},
	{
		id = "node7",
		text = _"How did you get into making explosives?",
		code = function()
			Npc:says(_"Twenty years ago there was a conflict.")
			Npc:says(_"A grenade I threw destroyed a being which killed many of... my people.")
			Npc:says(_"Now I make more to smash the destroyers.")
			hide("node7")
		end,
	},
	{
		id = "node50",
		code = function()
			Npc:says(_"Ah. Welcome again Linarian.")
			Npc:says(_"I have a little request for you.")
			Npc:says(_"I know someone who needs to be taught a lesson.")
			Npc:says(_"Interested?")
			Duncan_Koan_quest = true
			show("node51", "node59")
		end,
	},
	{
		id = "node51",
		text = _"Tell me more.",
		code = function()
			Npc:says(_"Ah, excellent.")
			Npc:says(_"A... friend of mine, Koan, stole something of great value to me.")
			Npc:says(_"He is hiding somewhere in the desert, I don't know exactly where.")
			hide("node51") show("node52")
		end,
	},
	{
		id = "node52",
		text = _"I will get your property back.",
		code = function()
			Npc:says(_"Excellent. I am pleased to hear this.")
			Npc:says(_"There is something you must know.")
			Npc:says(_"There are not too many bots in the desert, but they are invincible. It is best to avoid them.")
			Npc:says(_"I will be waiting here for your return.")
			Tux:says(_"That is all I need to know. I will find Koan.")
			Npc:says(_"Only time will tell.")
			if (cmp_obstacle_state("DesertGate", "closed")) and
			   (not Tux:has_met("Tania")) then
				Npc:says(_"Here are a couple of circuits to grease open the western gate, if you know what I mean.")
				Tux:add_gold(25)
			end
			Npc:says(_"Good luck!")
			Tux:add_quest("Doing Duncan a favor", _"I have to find Koan in the desert west of town and get Duncan something very precious.")
			hide("node52", "node59") show("node55", "node56")
		end,
	},
	{
		id = "node55",
		text = _"What are those bots?",
		code = function()
			Npc:says(_"We call them 'Harvesters'.")
			Npc:says(_"They were designed to chop down trees in the mountains.")
			Npc:says(_"Now they chop down people.")
			Npc:says(_"Their only weak point is their security system. But no one has managed to stay alive long enough to hack them.")
			hide("node55")
		end,
	},
	{
		id = "node56",
		text = _"What is it that he took from you?",
		code = function()
			Npc:says(_"A cube. Trust me, you can't miss it.")
			hide("node56")
		end,
	},
	{
		id = "node59",
		text = _"No, I don't find bloodshed a pleasurable activity.",
		code = function()
			Npc:says(_"That is fine. I will find someone else.")
			end_dialog()
		end,
	},
	{
		id = "node60",
		code = function()
			if (Tux:has_item_backpack("Pandora's Cube")) then
				if (Duncan_Koan_quest_done) then
					if (Koan:is_dead()) then -- we killed koan manually or using the dialog and got
						--the cube when we return first time to Duncan after seeing Koan
						Tux:says(_"Hey, I think I finally found your cube.")
						Npc:says(_"Oh, great!")
					else -- does this ever show up though?
						Tux:says(_"Hey!")
						Npc:says(_"Hmm...?")
						Tux:says(_"I think I found Koan after all ... finally.")
						Npc:says(_"Oh, nice!")
						Npc:says(_"Did you also get the cube?")
						Duncan_Koan_quest_really_done = true
					end
				else -- koan is dead
					Npc:says(_"So... Any news on the Koan matter?")
				end
				Duncan_Koan_quest_done = true
				show("node62", "node63")
				if (Duncen_node_62_hide) then
					hide("node62")
				end
				Duncen_node_62_hide = true
			elseif (Koan:is_dead()) then -- we don't have the cube but Koan is dead
				if (Duncan_talked_Koan_dead) then -- let Duncan ask for the cube differently if
					-- tux already returned without the cube while Koan was dead
					Npc:says(_"Did you finally find the cube?")
					Tux:says(_"Uhmmm...")
					Npc:says(_"You better go getting it!")
				else -- we killed koan somehow but don't have the cube
					Npc:says(_"You don't look too well, what happened?")
					Tux:says(_"He ... he is dead...")
					Npc:says(_"Koan?")
					if (Koan_spared_via_dialog) then -- we told Koan we won't kill him, and lied to Duncan
						--about not finding him. Afterwards we went back to Koan and killed him manually
						Npc:says(_"I thought you hadn't found him?")
						Tux:says(_"Yes, I didn't find him at first, now I did.")
					else -- we lost the cube and killed Koan via dialog
						Tux:says(_"Yes.")
					end
					Npc:says(_"And the cube that he was carrying? Where is it?")
					Tux:says(_"I must have left it somewhere...")
					Npc:says(_"Fetch it and bring it to me.")
					Duncan_talked_Koan_dead = true
					Tux:update_quest("Doing Duncan a favor", _"Unfortunately, I forgot to bring the cube. Duncan was not amused.")
				end
				end_dialog()
			elseif (Koan_spared_via_dialog) then -- we didn't kill via the dialog
				Tux:says(_"I could not find him anywhere in the desert. I don't think he is there anymore.")
				Npc:says(_"I see.")
				Tux:end_quest("Doing Duncan a favor", _"I lied to Duncan about not finding Koan.")
				Duncan_Koan_quest_done = true
				end_dialog()
			end
			show("node64")
		end,
	},
	{
		id = "node62",
		text = _"I think this is your cube.",
		code = function()
			Npc:says(_"Yes. I appreciate your help.")
			hide("node62", "node63") next("node69")
		end,
	},
	{
		id = "node63",
		text = _"Now, what is this big cube that you had me carry all the way here?",
		code = function()
			Npc:says(_"Just a memento from a friend.")
			Npc:says(_"A little more than a portable end of the world, which I am looking forward to disassembling and learning its secrets.")
			Npc:says(_"Nothing that important.")
			Duncen_node_62_hide = true
			hide("node62", "node63") show("node67", "node68")
		end,
	},
	{
		id = "node64",
		text = _"A 'few' bots? The place was crawling with Harvesters! I nearly got killed!",
		code = function()
			Npc:says(_"There were only one hundred and twenty bots in the entire desert region. This hardly qualifies as many, considering the size of the area.")
			Tux:says(_"What? You know exactly how many bots were in the desert? Without being there? I don't like this.")
			Npc:says(_"I just know a lot of things. You do not need to worry about it.")
			Tux:says(_"I don't like this at all. I'm getting out of here.")
			Npc:says(_"As you wish.")
			end_dialog()
			hide("node64")
		end,
	},
	{
		id = "node67",
		text = _"Hey, that is really neat. Here is your cube. Enjoy disassembling it and have fun with it.",
		code = function()
			Npc:says(_"I will.")
			hide("node67", "node68") next("node69")
		end,
	},
	{
		id = "node68",
		text = _"WHAT? No way I am giving you a doomsday device! Forget about it.",
		code = function()
			Npc:says(_"I understand. So be it.")
			Tux:end_quest("Doing Duncan a favor", _"No way am I giving Duncan that cube thingie, who knows what he would do with it.")
			Duncan_not_given_cube = true
			end_dialog()
			hide("node67", "node68")
		end,
	},
	{
		id = "node69",
		code = function()
			Tux:add_xp(3000)
			Tux:del_item_backpack("Pandora's Cube", 1)
			sell_item("Plasma Shockwave Emitter")
			Tux:end_quest("Doing Duncan a favor", _"I gave Duncan the cube thingie. It feels nice to help people.")
			Duncan_Koan_quest_really_done = true
			end_dialog()
		end,
	},
	{
		id = "node90",
		text = _"I feel you are... Different.",
		code = function()
			Npc:says(_"What a great way to start a conversation.")
			Npc:says(_"Yes, that is true. I am not who I seem to be.")
			Npc:says(_"But then again, neither are you, so my thoughts are, we are even.")
			--; TRANSLATORS: %s = Tux:get_player_name()
			Tux:says(_"What do you mean? I am %s and not anyone else.", Tux:get_player_name())
			Npc:says(_"And I am Duncan McNamara, the maker of grenades and nothing else.")
			Npc:set_name("Duncan - Bombmaker")
			Npc:says(_"I believe the topic is thoroughly exhausted now.")
			hide("node0", "node1", "node2", "node90") show("node5", "node92")
		end,
	},
	{
		id = "node92",
		text = _"Tell me who you are. I need to know.",
		code = function()
			Npc:says(_"Twenty years ago, people were kinder to each other.")
			Npc:says(_"I suggest you be kind to me as well, and I will be kind to you.")
			Npc:says(_"That way I get to keep my secret, and you get to keep yours.")
			hide("node92") show("node93")
		end,
	},
	{
		id = "node93",
		text = _"I don't have any secrets.",
		code = function()
			Npc:says(_"And neither do I.")
			hide("node93")
		end,
	},
	{
		id = "node97",
		code = function()
			Npc:says(_"I wish you cold winds.")
			Tux:says(_"Huh? How do you know the Linarian farewell? No one around here knows it.")
			Npc:says(_"I read many books on Linarians. That is all.")
			Npc:says(_"Nothing more and nothing less.")
			show("node98") next("node98")
		end,
	},
	{
		id = "node98",
		text = _"I wish you cold winds.",
		code = function()
			Npc:says(_"May the ice bring you wisdom.")
			end_dialog()
		end,
	},
	{
		id = "node99",
		text = _"See you later.",
		code = function()
			if (not Duncan_coldwinds) then
				Duncan_coldwinds = true
				next("node97")
			else
				Npc:says(_"See you later.")
				end_dialog()
			end
		end,
	},
}
