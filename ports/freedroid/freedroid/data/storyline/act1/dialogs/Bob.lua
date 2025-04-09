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
PERSONALITY = { "Friendly" },
BACKSTORY = "$$NAME$$ is part of the Special Area across bridge on level 42. He guards the portal to the recption desk."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		Tux:says(_"Hello.")
		Npc:says(_"Hi... Wait... How did you find this place?")
		Tux:says(_"Well, I was researching our beautiful continent, then I saw a gate, and walked through.")
		Npc:says(_"Oh... Well, welcome to this little fortress. There are only three people - me, my friend Jim and you.")
		Npc:says(_"There is also a 614 security droid.")
		Tux:says(_"Yeah, I noticed...")
		Npc:says(_"By the way, who are you?")
			--; TRANSLATORS: %s = Tux:get_player_name()
		Tux:says(_"I am %s.", Tux:get_player_name())
		Tux:says(_"And, who are you?")
		Npc:says(_"Bob. I'm guardian of these gates.")
		Npc:set_name(_"Bob - Gate Guardian")
		Jim:set_name(_"Jim - Portal Guardian")
		show("node1", "node2", "node6")
	end,

	EveryTime = function()
		if (Tux:has_quest("Ticket's price - crystal")) and 
		   (not Tux:done_quest("Ticket's price - crystal")) and
		   (Tux:has_item_backpack("Red Dilithium Crystal")) then
			show("node5")
		else
			hide("node5")
		end

		if Tux:has_met("Bob") then
			Tux:says_random(_"Hello.", _"Hi again, Bob.")
			if (Tux:done_quest("Ticket's price - crystal")) then
				Npc:says_random(_"Hi again. ", _"Hi again, my friend.", _"Welcome back, my friend.")
			else
				Npc:says_random(_"Hi again, Linarian", _"Hi.", _"Welcome back.")
			end
		end
		
		if (Tux_wants_taste_fruits) then
			show("node3")
		end
		
		show("node99")
	end,

	{
		id = "node1",
		text = _"I see a room near.",
		code = function()
			Npc:says(_"This is the room with the portal to the other continent inside.")
			Tux:says(_"To the other continent?!")
			Npc:says(_"Yeah. But the gate is closed.")
			Tux:says(_"Why?")
			Npc:says(_"Jim told me to do that, because he is afraid that bots can teleport through the portal.")
			Tux:says(_"But they will kill him if he stays inside a locked room!")
			Npc:says(_"I know. But Jim doesn't fear that... He hates bots and wants to destroy them all.")
			Tux:says(_"What's wrong with him? Is he crazy?")
			Npc:says(_"No... That's a bad story...")
			Npc:says(_"Spencer, the leader of Red Guard, sent a group of soldiers to scout the area, but none of them came back.")
			Npc:says(_"He got a message from one of them before the connection terminated. This message contained two coordinates and description with just one word: [b]Portal[/b].")
			Npc:says(_"So, he sent us to find this portal. There were 3 of us. Me, Jim and his brother. Also there was our 614. One day Jim's brother woke us up, and said that there were lots of bots around.")
			Npc:says(_"We started to flee, but some bots were faster than we are. Jim's brother said that he would hold them as long as possible, and ordered us to run... We have never seen him again...")
			Npc:says(_"After about four hours of running, we found this little fortress, and noticed that it was at Spencer's coordinates.","NO_WAIT")
			Npc:says(_"We hid inside.")
			Npc:says(_"And Jim hasn't talked since.")
			hide("node1") show("node4")
			Tux_heard_Bob_and_Jim_story = true
		end,
	},
	{
		id = "node2",
		text = _"What are these two trees?",
		code = function()
			Npc:says(_"The trees' fruit is our only source of food. The fruit is slightly bitter and leaves your mouth like an unripe persimmon, but we've noticed our wounds are healing much faster.")
			Tux:says(_"Wow.")
			Npc:says(_"Yeah. I can give you some. Just ask.")
			Tux:says(_"Thanks.")
			Tux_wants_taste_fruits = true
			hide("node2") show("node3")
		end,
	},
	{
		id = "node3",
		text = _"Could you give me another fruit please?",
		code = function()
			Npc:says(_"Of course. Take this one.")
			Tux:heal()
			hide("node3")
		end,
	},
	{
		id = "node4",
		text = _"I would like to walk inside this portal room anyways.",
		code = function()
			Npc:says(_"Sorry, my friend, but I can't let you do that. I need a good reason why I should open the gate for you.")
			Tux:says(_"What about a deal? I'll help you, you'll open this gate.")
			Npc:says(_"Good idea, but I don't need any help... Wait! My 614... Its power level is too low. I think that soon it will turn off.")
			Npc:says(_"Well, here is my task for you: bring me one dilithium crystal. I'll need it to raise my bot's power level.")
			Tux:says(_"Ok... but where can I find it?")
			Npc:says(_"Hmmm... You have to go to the underground. The entrance is situated far away from here on the south. I don't know anything else.")
			Tux:says(_"Thanks for the information. Well, I'll go then.")
			Npc:says(_"Linarian... Please, be careful! I don't want to have same story with you as Jim had with his brother.")
			Tux:says(_"*gulp* Ok... I'll be careful...")
			Tux:add_quest("Ticket's price - crystal", _"I asked Bob to open a gate for me, but he said that he will open it only if I'll help him by bringing one dilithium crystal for his 614. He said that I must go somewhere to the south. Also he warned me to be careful. But I think that some bunch of stupid bots won't scare me.")
			hide("node4")
		end,
	},
	{
		id = "node5",
		text = _"Well, here is your difficult-to-find dilithium crystal.",
		code = function()
			Npc:says(_"COOL!! Give it to me.")
			Tux:says(_"Here you go.")
			Tux:del_item("Red Dilithium Crystal", 1)
			Npc:says(_"Oh dude, you can't even imagine how thankful I am!")
			if (not HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				Npc:says(_"My bot is now fine: the power level is holding steady at 9001 megawatts. I won't need to worry that bots will kill me while I am sleeping! Thank you so much!")
			else
				Npc:says(_"My bot is now fine: the power level is holding steady at 9001 megawatts. Now I have a robot and my brother to talk to, even knowing none of them will reply my questions! Thank you so much!")
			end
			Npc:says(_"Here is my award for you. When we saw this place at the first time, we found some bot inside. I destroyed it and this mace dropped out of it. I'm not sure how did it appear inside, but now it's yours.")
			Tux:add_item("Mace")
			Tux:says(_"Thank you, Bob.")
			Npc:says(_"Well, now I'll open the gate for you... I'm afraid that Jim will be angry because I violated his order not to open the gates... But he won't say me anything, hehehehe.")
			Tux:end_quest("Ticket's price - crystal", _"I finally brought a dilithium crystal for Bob. He even awarded me with a mace. But my main prize is the opened gate to the room with the portal that goes to the other continent. I've finally got a ticket for a trip.")
			hide("node5")
		end,
	},
	{
		id = "node6",
		text = _"What is this scrap near the entrance?",
		code = function()
			Npc:says(_"A couple days ago few bots became our 'guests'.")
			Tux:says(_"Yuck! I hope that you are not welcoming all guests like that.")
			Npc:says(_"No. Do not worry about that.")
			hide("node6")
		end,
	},
	{
		id = "node99",
		text = _"See you later.",
		code = function()
			if Tux:done_quest("Ticket's price - crystal") then
				Npc:says_random(_"See you later.", _"Goodbye, my friend.")
			else
				Npc:says(_"See you later, Linarian.")
			end
			end_dialog()
		end,
	},
}
