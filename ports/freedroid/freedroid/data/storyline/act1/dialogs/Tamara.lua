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
PERSONALITY = { "Intelligent", "Timid" },
MARKERS = { NPCID1 = "Sorenson", QUESTID1 = "An Explosive Situation" },
PURPOSE = "$$NAME$$ can sell Tux programs books. Her skills are needed to aid Tux in resolving the $$QUESTID1$$ quest.",
BACKSTORY = "$$NAME$$ is the town\'s librarian, which she use to run with $$NPCID1$$ until their falling out. $$NAME$$ also documents bot history in her spare time.",
RELATIONSHIP = {
	{
		actor = "$$NPCID1$$",
		text = "$$NAME$$ and $$NPCID1$$ are half-sisters who have not talked to each other since $$NAME$$ locked $$NPCID1$$
			 in her bedroom for staring into computer screens too much."
	},
}
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		-- Initialization
		Tamara_about_bots_nodes = 0

		--; TRANSLATORS: %s =Tux:get_player_name()
		Tux:says(_"Hi, I'm %s.", Tux:get_player_name())
		Npc:says(_"Welcome to the Library, I'm Tamara.")
		Npc:says(_"Please take a look around and see if there is something here that interests you.")
		Npc:says(_"You are welcome to ask me if you have any questions.")
		Npc:set_name("Tamara - Librarian")
		show("node10")
	end,

	EveryTime = function()
		if (Tamara_restock) then
			Npc:says(_"I was looking at the depot and found some interesting books. You might want to take a look at them later.")
			Tamara_restock=false
		end

		if (tamara_shelf_count == 1) and
		   (not tamara_shelf_count_1_done) then
			Npc:says(_"Hey, please don't make such a mess here.")
			tamara_shelf_count_1_done = true
		elseif (tamara_shelf_count == 2) and
		       (not tamara_shelf_count_2_done) then
			Npc:says(_"Please put everything back in place if you don't need it.")
			tamara_shelf_count_2_done = true
		elseif (tamara_shelf_count == 3) and
		       (not tamara_shelf_count_3_done) then
			Npc:says(_"Please be careful with these books. They are older than most computers in this town.")
			tamara_shelf_count_3_done = true
			tamara_shelf_stuff = "done"
		elseif (tamara_shelf_count) and
		       (tamara_shelf_count > 3) then
			Npc:says("ERROR: Tamara.dialog, EveryTime LuaCode: unhandled value for tamara_shelf_count, please report. value is: %s", tamara_shelf_count)
		end

		if (Tux:has_met("Tamara")) then
			Npc:says(_"What can I help you with?")
		end

		if (Tux:has_met("Sorenson")) and
		(not Tamara_talked_about_sister) then
			show("node1")
		end

		show_if(((not won_nethack) and
				      (not Tamara_asked_hacking)), "node2")

		show_if(Tamara_bot_apocalypse_book, "node21")

		if (Ewalds_296_needs_sourcebook) and
		   (not Tamara_have_296_book) then
			show("node50")
		end

		-- function to hide node in the topic Tamara_about_bot_nodes
		function hide_node_about_bots(node)
			Tamara_about_bots_nodes = Tamara_about_bots_nodes - 1
			hide("node" .. node)
			if (Tamara_about_bots_nodes <= 0) then
				pop_topic()
			end
		end

		if (Kevin_sigtalk) and
		   (not tamara_robotic_girlfriends_node) then
			Tamara_about_bots_nodes = Tamara_about_bots_nodes + 1
			tamara_robotic_girlfriends_node = true;
			show("node34")
		end

		if (tux_has_joined_guard) and
		   (not tamara_robot_class_node) then
			Tamara_about_bots_nodes = Tamara_about_bots_nodes + 1
			tamara_robot_class_node = true;
			Npc:says(_"By the way, someone just returned a book about 'Advanced Robot Classes', tell me if you're interested.")
			show("node35")
		end

		show_if(Tamara_talked_about_bots and
		            (Tamara_about_bots_nodes > 0), "node31")

		show("node99")

		show_if((HF_FirmwareUpdateServer_uploaded_faulty_firmware_update and
				 not Tamara_post_firmware_update), "Tamara_post_firmware_update_1")
	end,

	{
		id = "node1",
		text = _"Hmm, you look very similar to another person I met, by the name of Sorenson.",
		code = function()
			Npc:says(_"Well, it's understandable. We are sisters.")
			Npc:says(_"Or actually half sisters. She is also half crazy, so we don't communicate much.")
			Npc:says(_"*sigh*")
			Npc:says(_"We used to. Even ran this library together.")
			Npc:says(_"Then she started reading more and more books and sitting in front of the computer day and night, never sleeping.")
			Npc:says(_"In the end she completely lost her marbles, sadly.")
			Npc:says(_"Now all she does is sitting locked in her house staring into the computer.")
			Tamara_talked_about_sister = true
			hide("node1")
		end,
	},
	{
		id = "node2",
		text = _"I would like to learn how to hack.",
		code = function()
			Tamara_asked_hacking = true
			if (Tamara_talked_about_sister) then
				Npc:says(_"My sister used to play Nethack all the time, about the time she became really good at hacking.")
			else
				Npc:says(_"Everyone I know who is good with computers always talks about beating Nethack.")
			end
			Npc:says(_"I think there might be a version on the town's computers.")
			Npc:says(_"I've never played it.")
			Npc:says(_"That might be why I'm no good with computers.")
			hide("node2")
		end,
	},
	{
		id = "node10",
		text = _"I see you have a huge source code book collection. Mind if I buy some from you?",
		code = function()
			Npc:says(_"This is a library, not a book shop.")
			Npc:says(_"However, valuable books have a tendency to simply vanish and never get returned by some people...")
			Npc:says(_"Especially strangers just passing by...")
			Npc:says(_"Thus, I'm forced to take a deposit for each book.")
			hide("node10") show("node11")
		end,
	},
	{
		id = "node11",
		text = _"So what interesting books do you have available right now?",
		code = function()
			Npc:says_random(_"Some of these might interest you.",
							_"I only have a few programming volumes, feel free to look through them.")
			trade_with("Tamara")
			show_if(not Tamara_bot_apocalypse_book, "node20")
			show_if(not Tamara_talked_about_bots, "node30")
		end,
	},
	{
		id = "node20",
		text = _"Do you have any books about the bot apocalypse?",
		code = function()
			Npc:says(_"I'm writing one, but it isn't complete, and there are no publishers left.")
			Tamara_bot_apocalypse_book = true
			hide("node20")
		end,
	},
	{
		id = "node21",
		text = _"Have you been progressing on your book about the bot apocalypse?",
		code = function()
			Npc:says_random(_"I need more time to finish it.",
							_"Page-by-page, my book is growing up.",
							_"Sorry, but you have to wait a bit more before you can read it.")
			hide("node21")
		end,
	},
	{
		id = "node30",
		text = _"Do you have any books about robotics?",
		code = function()
			Npc:says(_"Sorry, most of them have been stolen or borrowed.")
			Npc:says(_"However, I can tell you all about robots and automata in literature. Interested?")
			Tamara_talked_about_bots = true
			Tamara_about_bots_nodes = Tamara_about_bots_nodes + 2
			hide("node30") show("node32", "node33", "node39")
			push_topic("About bots")
		end,
	},
	{
		id = "node31",
		text = _"I would like to know some more about bots.",
		code = function()
			Npc:says(_"If you mean in culture, I have some anecdote you could be interested in.")
			push_topic("About bots")
		end,
	},
	{
		id = "node32",
		text = _"Where does the word 'bot' come from?",
		topic = "About bots",
		code = function()
			Npc:says(_"It is a shortening of the word 'robot', derived from the Czech word for forced labor.")
			Npc:says(_"R.U.R. (Rossum's Universal Robots), a theatrical play, introduced 'robots' as artificial people.")
			Npc:says(_"In the play the robots revolted, took over the world, and killed all the humans.")
			Tux:says(_"Ironic.")
			hide_node_about_bots(32)
		end,
	},
	{
		id = "node33",
		text = _"What about the creation of robots for defense?",
		topic = "About bots",
		code = function()
			Npc:says(_"During the Holy Roman Empire, the Jewish people of the Prague ghetto needed protection.")
			Npc:says(_"So a holy rabbi shaped a Golem out of clay, and brought it to life through rituals and writing 'emet' (truth) on its head.")
			Npc:says(_"The Golem initially protected the Jews, but was brainless and stupid, and thus soon became dangerously violent to the Jews also.")
			Npc:says(_"It was only by trickery that the rabbi was able to even get close to the Golem.")
			Npc:says(_"But as the rabbi changed 'emet' to 'met' (death), the Golem fell on him, and both the creator and creation became lifeless.")
			hide_node_about_bots(33)
		end,
	},
	{
		id = "node34",
		text = _"What can you tell me about robotic girlfriends?",
		topic = "About bots",
		code = function()
			Npc:says(_"Well, the Greeks wrote down a story about Pygmalion, the sculptor of Cyprus.")
			Npc:says(_"Pygmalion carved an ivory woman of far surpassing natural beauty and fell in love.")
			Npc:says(_"Aphrodite, the goddess of love, brought the ivory woman to life.")
			Npc:says(_"The woman, Galatea, likewise fell in love and married her creator Pygmalion.")
			Npc:says(_"So you could say that this is one of the few stories that end well.")
			hide_node_about_bots(34)
		end,
	},
	{
		id = "node35",
		text = _"Earlier you've said that there was a book about Advanced Robot Classes.",
		topic = "About bots",
		code = function()
			Npc:says(_"Yes. Here, I'll show it to you.")
			Npc:says(_"[b]Advanced Robot Classes - A quick guide introducing the most dangerous robots on our world.[/b]")
			Npc:says(_"[b]Battle Droids - Droids from the class 700s are Battle Droids. They are designed for war, so they're pretty much killing machines. If you find a droid of the 700s class, it's advised to run.[/b]")
			Npc:says(_"[b]Security Droids - Droids from the class 800s are meant to seek intruders and exterminate them. Most are fast and very dangerous, with the notable exception of the 883 model, which is designed to hold position and is even more dangerous. If you find a droid of the 800s class, it's advised to run.[/b]")
			Npc:says(_"[b]Command Droids - Droids from the class 900s were designed to control droids, ships, stations, and a lot more. Being experimental, they usually are heavily armored, fast, and powerful. Most are equipped with top-notch sensors to see even invisible things. If you find a droid of the 900s class, it's advised to survive. Which is unlikely.[/b]")
			Tux:says(_"Great. Why I have the feeling that I'll be meeting these droids soon enough?")
			hide_node_about_bots(35)
		end,
	},
	{
		id = "node39",
		text = _"Can I come back to you on that later?",
		topic = "About bots",
		code = function()
			Npc:says(_"Don't hesitate to talk to me again for further questions.")
			pop_topic()
		end,
	},
	{
		id = "Tamara_post_firmware_update_1",
		text = _"Have you heard about the news?",
		code = function()
			Npc:says(_"Oh? What news?")
			Tux:says(_"The world is saved! The apocalypse is over!")
			Npc:says(_"Oh, yes... This news. I agree, it's wonderful.")
			hide("Tamara_post_firmware_update_1")
			show("Tamara_post_firmware_update_2")
			Tamara_post_firmware_update = true
		end,
	},
	{
		id = "Tamara_post_firmware_update_2",
		text = _"You don't seem very excited.",
		code = function()
			Npc:says(_"I am glad, although... Well, it's not like the library was ever in any immediate danger.")
			Tux:says(_"What? Did you want it to be?")
			Npc:says(_"No - it's hard to explain. I suppose I had this certain... Idea that it was my job to keep the books safe during the apocalypse. To defend them.")
			Npc:says(_"It was my little fortress made of electronic paper, that I had to grow and protect from any threats. To save human knowledge.")
			hide("Tamara_post_firmware_update_2")
			show("Tamara_post_firmware_update_3")
		end,
	},
	{
		id = "Tamara_post_firmware_update_3",
		text = _"But what about all the people that died? They weren't made of E-paper!",
		code = function()
			Npc:says(_"I know! Please, don't misunderstand, I think it's fantastic that the Assault is over!")
			Npc:says(_"I just... Well, I guess I wanted a bigger piece of the action, in my own way.")
			Npc:says(_"I'll... Go and arrange some books now...")
			if (tamara_shelf_count) then
				Npc:says(_"It's rather hard to keep the library in good shape lately. Someone's been ransacking the southern sections. Times like these can bring out the worst in us.")
				Npc:says(_"But I guess cleaning work is also part of preserving culture.")
			end
			hide("Tamara_post_firmware_update_3")
			show("Tamara_post_firmware_update_interview", "Tamara_post_firmware_update_burn")
		end,
	},
	{
		id = "Tamara_post_firmware_update_burn",
		text = _"You know, I can start a fire here if you want me to.",
		code = function()
			Npc:says(_"What? No! Absolutely not!")
			Npc:says(_"Why in the world would I want you to do that?!")
			Tux:says(_"Because that would put the books in immediate danger, and then you can rush in and save them!")
			Npc:says(_"That - that's insane!")
			Npc:says(_"You are a danger to this establishment. Get out of here!")
			Tux:says(_"You are a very confusing person.")
			if (Tamara_talked_about_sister) then
				Tux:says(_"I guess it runs in the family...")
			end
			end_dialog()
			hide("Tamara_post_firmware_update_burn", "Tamara_post_firmware_update_interview")
		end,
	},
	{
		id = "Tamara_post_firmware_update_interview",
		text = _"Well, you didn't get to fend off a hoard of bots. But you can interview me personally!",
		code = function()
			Npc:says(_"Really? You'd let me interview you?")
			if (Tamara_bot_apocalypse_book) then
				--; TRANSLATORS: it = the interview
				Tux:says(_"Sure! You can put it in the book you're writing.")
			else
				Tux:says(_"Sure!")
			end
			Npc:says(_"Thank you! This is a wonderful opportunity! I have a first-hand account from a central actor in the biggest event in human history!")
			Npc:says(_"We must set a time for an interview. And I must read everything in the library about interviewing!")
			Npc:says(_"There's a lot of ground to cover, but i can already imagine the descriptions - you, in the center of the robot apocalypse...")
			Npc:says(_"Just like in those old fairy tales they used to tell children, about the brave dashing knight storming alone into a castle to save the princess.")
			Npc:says(_"With some mild adjustments.")
			Npc:says(_"I mean, no one in those stories had flippers.")
			Tux:says(_"That sounds like discrimination.")
			Npc:says(_"Yes, they don't tell those stories to children anymore. Too much adult content. The effect on the young psyche was poorly studied.") -- might open the subject of Linarian folk tales?
			hide("Tamara_post_firmware_update_interview", "Tamara_post_firmware_update_burn")
		end,
	},
	{
		id = "node50",
		text = _"Do you have a copy of Subatomic and Nuclear Science for Dummies, Volume IV?",
		code = function()
			Npc:says(_"It's interesting you should be looking for that - the library has two copies.")
			Tux:says(_"I need one - it's a matter of life and death!")
			Npc:says(_"Life and death?")
			Tux:says(_"There's a nuclear reactor going super critical under the town - if I have the book, maybe I can stop it.")
			Npc:says(_"In that case, you can have it. My mission is to preserve our culture, which won't matter if we're all dead.")
			Tux:says(_"Thank you, Tamara.")
			Tux:update_quest("An Explosive Situation", _"I was able to get a copy of Subatomic and Nuclear Science for Dummies, Volume IV from the librarian, Tamara. I'd better hurry back to Ewald's 296 with it.")
			Tux:add_item("Nuclear Science for Dummies IV")
			Tamara_have_296_book = true
			hide("node50")
			end_dialog()
		end,
	},
	{
		id = "node99",
		text = _"Thank you for the help.",
		code = function()
			Npc:says_random(_"No problem, and remember to return your books in time.",
							_"I aim to ensure that the great works of literature will survive this horrible apocalypse.",
							_"That is what I'm here for. Come back at any time.")
			end_dialog()
		end,
	},
}
