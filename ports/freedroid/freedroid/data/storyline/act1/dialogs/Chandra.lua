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
PERSONALITY = { "Sagely", "Absent-Minded" },
MARKERS = { NPCID1 = "Francis" },
PURPOSE = "$$NAME$$ gives more explanation of what is going on in the world, particularly about the Linarian race and the
	 town. Chandra raises several questions regarding the story.",
RELATIONSHIP = {
	{
		actor = "$$NPCID1$$",
		text = "$$NPCID1$$ and $$NAME$$ know each other. $$NPCID1$$ sent Tux to talk with $$NAME$$ about Linarians."
	},
}
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		Npc:says(_"So the rumors are true - a real live Linarian walks among us!")
		Chandra_bot_information_nodes = 0
		show("node0")
	end,

	EveryTime = function()
		if (not Tux:has_met("Chandra")) then
			Npc:says(_"Good to see you again. How can I help you?")
		end

		if (Chandra_node10_show) and
		   (not tux_has_joined_guard) then
			show("node10")
		end

		if (Chandra_node16_show) then
			show("node16")
		end

		if (Chandra_bot_information_nodes > 1) then
			show("node17")
		end

		show("node99")
	end,

	{
		id = "node0",
		text = _"Hi! I'm new here.",
		code = function()
			Npc:says(_"Welcome. I am Chandra. Some would call me the local sage.")
			if (linarian_chandra) and
			   (not Chandra_first_contact) then
				show("node15")
			end
			hide("node0") show("node1", "node2", "node9")
		end,
	},
	{
		id = "node1",
		text = _"What can you tell me about this place?",
		code = function()
			Npc:says(_"This small town used to be a somewhat successful mining community, exporting rare earth materials and other resources to the rest of the solar system.")
			Npc:says(_"The mines have depleted recently, however. The town was under a threat of bankruptcy. Living here became harder and many left to seek new opportunities elsewhere.")
			Npc:says(_"But now after the Great Assault, the rest of the planet gets bombarded by automated bot ships every now and then, so being here isn't so bad at all.")
			Npc:says(_"Even with the Red Guard in charge.")
			hide("node1") show("node5", "node10", "node14", "node30")
		end,
	},
	{
		id = "node2",
		text = _"Where can I get better equipment?",
		code = function()
			Npc:says(_"The shop is to the north, near the gate. Ms. Stone always has a good range of equipment there, with fair prices too.")
			Npc:says(_"Not that you have much choice.")
			Npc:says(_"Of course, the Red Guard always has the biggest guns and the best armor, but they do not sell them to non-members.")
			hide("node2")
		end,
	},
	{
		id = "node3",
		text = _"So what's so strange about the attack?",
		code = function()
			if (not HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				Npc:says(_"According to my calculations based on the Fermi estimate, there are about seven million bots active in the region, everything from cleaner bots and servant droids to much more dangerous ones.")
			Npc:says(_"I think you will agree with me that the following statement is true: If bots, then death to everything alive.")
			Npc:says(_"Now, I make the assumption that you and I are alive.")
			Npc:says(_"But, if we are not dead, and if bots are killing everything alive...")
			else
				Npc:says(_"According to my calculations based on the Fermi estimate, there used to be about seven million bots active in the region, everything from cleaner bots and servant droids to much more dangerous ones.")
			Npc:says(_"I think you will agree with me that the following statement is true: If bots, then death to everything alive.")
			Npc:says(_"Now, I make the assumption that you and I are alive.")
			Npc:says(_"But, if we are not dead, and if bots were killing everything alive even before you were awaken...")
			end
			Npc:says(_"... THEN WE HAVE A CONTRADICTION!")
			Tux:says(_"Calm down. There must be some logic behind this.")
			Npc:says(_"There can be none!")
			Npc:says(_"They could just enter the town and massacre everyone...")
			Npc:says(_"But they do not even seem to try!")
			Npc:says(_"This makes no sense at all!")
			hide("node3")
		end,
	},
	{
		id = "node4",
		text = _"Could you explain me about bot respawn?",
		code = function()
			Npc:says(_"Respawn? Interesting choice of words. Bots doesn't actually \"respawn\", not literally, but the ships in orbit periodically checks some areas at random and makes a special request so the factory can replace the dead bots.")
			Npc:says(_"I believe that during the check, they also reboot the droids. Therefore I guess that even if you hack a bot, it'll be only a temporary companion.")
			Npc:says(_"There might be areas where their signals doesn't reach, but it's just too rare to even consider it.")
			Npc:says(_"I am not a hacker. A real hacker should understand this better than I.")
			hide("node4")
		end,
	},
	{
		id = "node5",
		text = _"What do you know about the hostile bots?",
		code = function()
			Npc:says(_"The phenomenon of hostile bots has occupied my mind for quite some time. There are some strange irrationalities in this behavior, that I cannot explain.")
			Npc:says(_"This encompasses not only the suddenness of the attack, but also the methods and the scale of it all.")
			hide("node5") show("node3", "node4", "node6", "node7")
		end,
	},
	{
		id = "node6",
		text = _"What types of bots are out there?",
		code = function()
			Npc:says(_"There are many. Each kind of bot has a number consisting of three digits. The first one is the most significant, the class of a bot.")
			Npc:says(_"I know a bit about three classes.")
			Npc:says(_"The 100s are cleaning bots of old. Therefore, they are quite common. Fortunately for us they aren't as good at killing things as they are at cleaning up the mess afterwards.")
			Npc:says(_"The 200s are servant bots, designed to come quickly when summoned and be able to lift heavy weights. That makes them more dangerous under most circumstances, so beware of being attacked by more than one at the same time.")
			Npc:says(_"Right now, an encounter with a 300 type bot equals death, so try to avoid it. They were messenger bots before the Great Assault, which means they have superb visual sensors, and some are very fast.")
			Npc:says(_"There are many more classes out there. The military used bots, of course, and they were used on ships, but I know almost nothing about those types.")
			Chandra_bot_information_nodes = 5
			hide("node6") show("node11", "node12", "node13", "node18", "node19")
			push_topic("Bot Information")
		end,
	},
	{
		id = "node7",
		text = _"I want to leave this place.",
		code = function()
			Npc:says(_"We all do, Linarian, we all do.")
			Npc:says(_"The act in question is made impossible by the quasi-infinite bots outside of the town walls.")
			Npc:says(_"You cannot live for long out there.")
			hide("node7") show("node8")
		end,
	},
	{
		id = "node8",
		text = _"No, I meant I would like to leave this world.",
		code = function()
			Npc:says(_"Simple. Walk outside the town walls, and the bots will send you to the other world within a few minutes.")
			Npc:says(_"Unless you mean leave the planet, in which case that is impossible.")
			Npc:says(_"Most likely all of our cosmodromes have been destroyed in the bot attacks.")
			hide("node8")
		end,
	},
	{
		id = "node9",
		text = _"I'm having difficulty overcoming the bots. What can I do?",
		code = function()
			Npc:says(_"There are many things you can do. The first is to fight more bots.")
			Tux:says(_"Erm... Wouldn't that cause me to be beaten up more, and therefore be counter-productive?")
			Npc:says(_"Your logic is infallible, Linarian, but you are forgetting one thing: the more you fight, the more experienced you become, and the better you become at surviving.")
			Npc:says(_"Also, if you have the money and can find a supplier, it is wise to invest in better equipment - more protective clothing and better weaponry.")
			Npc:says(_"My advice is to invest in a ranged weapon. While it can create a huge hole in your wallet, it also creates several in the bots, and is better than a huge hole in you.")
			Npc:says(_"Currently there is a ban on selling such things. The Red Guard wants to be the only ones with good weapons.")
			Npc:says(_"Should you fail to find something decent to shoot or swing with, there are always other options.")
			Npc:says(_"Ewald, the barkeeper, usually sells an assortment of junk, but even he sometimes has something worthwhile on display.")
			Npc:says(_"There was a person selling grenades, too. Eh... I forgot his name, my memory is not serving me very well today. He's a very mysterious fellow. Perhaps he can help you.")
			Npc:says(_"Other than that, you are on your own.")
			hide("node9")
		end,
	},
	{
		id = "node10",
		text = _"Do you think I could join the guardians of this town?",
		code = function()
			if (guard_follow_tux) then
				Npc:says(_"The Red Guard...? Only if you're as strong and courageous as they are! There is no one better than the Red Guard! Nothing but top quality men there!")
			else
				Npc:says(_"The Red Guard? Unlikely. You'd have to establish a reputation beforehand, and demonstrate that you can make things happen.")
				Npc:says(_"Also, the Red Guard is not a very popular organization, so if you do join them then you can expect to be hated by nearly everyone here.")
				Npc:says(_"As the ancients said, 'Boni pastoris est tondere pecus, non deglubere'. A good tax must be a reasonable tax.")
			end
			hide("node10")
			Chandra_node10_show = true
		end,
	},
	{
		id = "node11",
		text = _"What bots are in the 100 class?",
		topic = "Bot Information",
		code = function()
			Npc:says(_"I know of two types, the 123 and the 139. The former is a simple cleaning bot, and is fairly weak. The latter is a mobile trash compactor. Don't let your flippers get caught in one of those.")
			Tux:says(_"I've seen some of those on my way here. They were... Shooting at me.")
			Npc:says(_"Many strange things have happened since the Great Assault.")
			Npc:says(_"Anyway, because the class 100 bots are neither fast nor dangerous, the Red Guard often uses them for target practice.")
			Npc:says(_"If I were you, I would not underestimate them.")
			Npc:says(_"Nec Hercules contra plures.")
			Chandra_bot_information_nodes = Chandra_bot_information_nodes - 1
			hide("node11")
		end,
	},
	{
		id = "node12",
		text = _"What bots are in the 200 class?",
		topic = "Bot Information",
		code = function()
			Npc:says(_"In fitting with the lazy nature of humans, there are several servant bots of the 200 class.")
			Npc:says(_"The 247 is often called the 'Banshee'. Being a simple servant robot, it isn't very well equipped to kill, although its arms are quite strong.")
			Npc:says(_"Also, as I said, the 200s were built to report quickly. The 247 is no exception, and moves faster than some of us can run. As a killer bot, it has a fast rate of attack. It is not something to be trifled with.")
			Npc:says(_"The 249 is a cheaper version of the Banshee. It uses a tripedal drive instead of anti-gravity propulsion, and is therefore slower. However, it is much more dangerous: its machine gun has a very high rate of fire.")
			Tux:says(_"Machine gun?! But... But it's a servant bot!")
			--; TRANSLATORS: %s =Tux:get_player_name()
			Npc:says(_"I know, %s. I know.", Tux:get_player_name())
			Npc:says(_"Let's see... Oh, there is also the 296, which was used for serving drinks. Ewald once had one of those in his bar.")
			Tux:says(_"Once? What happened to it?")
			Npc:says(_"No one knows. One day it simply wasn't there. Ewald probably remembers more than I do, though.")
			Chandra_bot_information_nodes = Chandra_bot_information_nodes - 1
			hide("node12")
		end,
	},
	{
		id = "node13",
		text = _"What other bots are out there?",
		topic = "Bot Information",
		code = function()
			Npc:says(_"Though I do not know the details, I assure you there are many. Robots and automated machinery served almost every purpose you can imagine, and probably some that you can't.")
			Npc:says(_"They were used by the military, aboard ships, as security droids and more. Right now, however, most of the people who knew them up close are pushing up daisies.")
			Chandra_bot_information_nodes = Chandra_bot_information_nodes - 1
			hide("node13")
		end,
	},
	{
		id = "node14",
		text = _"Where in the void is this world?",
		code = function()
			Npc:says(_"I guess you mean in the universe?")
			Tux:says(_"Yes, I think that is your name for it.")
			Npc:says(_"Well, we are in a barred spiral galaxy, twenty-six thousand light years away from the galactic core.")
			Npc:says(_"The galactic radius is 43,000 light years and the circumference is estimated at 270,000 light years.")
			Npc:says(_"This is a planetary system of ten planets, and we are presently located on the third one from our star, Sol.")
			Npc:says(_"I am not an astronomer, so I could be wrong. I am too tired to keep track of what is a planet and what is just an oversized rock.")
			Tux:says(_"This could be just about anywhere. Your description is too ambiguous.")
			Npc:says(_"Sorry, star sciences are my weak point.")
			Tux:says(_"...Right.")
			hide("node14")
		end,
	},
	{
		id = "node15",
		text = _"Chandra? Francis in the cryonic facility mentioned your name.",
		code = function()
			Npc:says(_"Oh did he? What exactly did he say about me?")
			Tux:says(_"He said you might know more about who I am, about Linarians.")
			Npc:says(_"Hmmm... I'm not so sure about 'who', but he is quite right about my knowledge of Linarians... quite right indeed. What would you like to know, my friend?")
			if (Chandra_revenge) then
				end_dialog()
			end
			Chandra_node16_show = true
			hide("node15") show("node20", "node25", "node26", "node29")
			push_topic("Linarians")
		end,
	},
	{
		id = "node16",
		text = _"I wanted to ask you some questions about Linarians.",
		code = function()
			Npc:says(_"Yes?")
			if (Chandra_revenge) then
				end_dialog()
			end
			hide("node16") show("node20")
			push_topic("Linarians")
		end,
	},
	{
		id = "node17",
		text = _"I wanted to ask you some questions about droids.",
		code = function()
			Npc:says(_"Yes?")
			hide("node17")
			push_topic("Bot Information")
		end,
	},
	{
		id = "node18",
		text = _"You mentioned droids from the 300s class had superb visual sensors...",
		topic = "Bot Information",
		code = function()
			Tux:says(_"What exactly are those sensors?")
			Npc:says(_"A sensor is how a bot perceives the world. It would be wrong to assume that all bots sees the world in exactly the same way.", "NO_WAIT")
			Npc:says(_"While almost all bots have visual sensors, and some better than others, some more advanced droids have different sensors to avoid being tricked by the enemy.")
			Npc:says(_"For example, some battle droid might have an [b]X-Ray[/b] sensor to see though the walls, and a command droid might even have an [b]Infrared[/b] sensor to see heatwaves and detect a living being pretending to be dead or invisible.")
			Npc:says(_"Thankfully only very dangerous bots uses different sensors, so you don't need to worry with them right now. Although I also overheard something interesting once. I'll share this little secret with you...")
			Npc:says(_"They say that the Red Guard changed some droids sensors in one of the arenas. They can't even go down there right now, is what is said. But you can't trust in all rumors you hear, am I not right?")
			Chandra_bot_information_nodes = Chandra_bot_information_nodes - 1
			hide("node18")
		end,
	},
	{
		id = "node19",
		text = _"That's all I wanted to know about droids.",
		topic = "Bot Information",
		code = function()
			Npc:says(_"Did you have any other questions?")
			pop_topic()
		end,
	},
	{
		id = "node20",
		text = _"What is a Linarian?",
		topic = "Linarians",
		code = function()
			if (not Chandra_first_contact) then
				Npc:says(_"Ah yes, I heard that your memory had been affected by stasis. I will share with you what I know.")
				Npc:says(_"Linarians came to this planet about a century ago. While their specialties can vary, they are most widely known for their nearly-magical skills with computers.")

				if (not guard_follow_tux) then
					Npc:says(_"[b](Chandra quickly glances around. After verifying that no one else seems to be paying attention to your conversation, he takes a quick breath and continues quietly.)[/b]")
					Npc:says(_"Since you are asking this question and you have even come into our town, I am assuming that your memory has been completely damaged.")
					Npc:says(_"What I am about to tell you is not easy to say, nor will it be easy to hear. For that I apologize, but you must know the truth.")
					Npc:says(_"[b](He pauses for a breath.)[/b]")
					Npc:says(_"When your people first arrived, there was a miscommunication that resulted in the leaders of Earth acting aggressively. Unfortunately, most of your people did not survive...")
					Npc:says(_"For that my friend, I am deeply sorry.")
					Npc:says(_"[b](He hangs his head slightly and you feel he is sincere in his remorse.)[/b]")
					show("node21", "node22")
					push_topic("Linarians Attacked")
				else
					Npc:says(_"[b](Chandra moves his head ever so slightly as he quickly glances around. After noticing the nearby presence of the Red Guard member, his posture and tone changes. Perhaps you should speak with him again once you lose your escort...)[/b]")
					Npc:says(_"What else would you like to know?")
				end
			else
				Npc:says(_"Linarians came to this planet about a century ago. While their specialties can vary, they are most widely known for their nearly-magical skills with computers.")
				Npc:says(_"I'd rather not repeat what I said earlier. It pains me to think of it...")
			end
			hide("node20")
		end,
	},
	{
		id = "node21",
		text = _"(Calmly accept this information)",
		echo_text = false,
		topic = "Linarians Attacked",
		code = function()
			Tux:says(_"What happened to the other Linarians that survived first contact?")
			Npc:says(_"Sadly, I do not know. All that remains are legends. For a time, Linarians wandered the planet performing grand deeds and earning the respect of most of humanity.")
			Npc:says(_"But as time passed, so did the memories of the great deeds. It is unlikely that you will find many who know more about your people's noble past.")
			Npc:says(_"Perhaps there are still other Linarians alive here on our planet. Or maybe some went back to your own planet.")
			Chandra_first_contact = true
			hide("node20")
			pop_topic()
		end,
	},
	{
		id = "node22",
		text = _"(Respond angrily)",
		echo_text = false,
		topic = "Linarians Attacked",
		code = function()
			Tux:says(_"Your people slaughtered us?!")
			Npc:says(_"Yes, this is the truth and it is something most humans regret. It is this regret that has helped erase the Linarians from our history.")
			Npc:says(_"Humanity does not have a pretty history. We have done many horrible things to each other as well. There are many things we regret so deeply that we wish we could forget.")
			Npc:says(_"Over time, most people have willingly forgotten our actions and focused on the good deeds the Linarians performed despite our senseless behavior.")
			Npc:says(_"Even though we tried to celebrate the grand deeds and heroics of the surviving Linarians, the memories faded. The memories turned into legends and myths as the Linarians slowly withdrew from the world.")
			Npc:says(_"Perhaps there are still other Linarians alive here on our planet. Or maybe some went back to your own planet.")
			Npc:says(_"Spencer and the Red Guard would not want you to know these things, as you might not be willing to help our failing community.")
			Npc:says(_"However, to not share this information with you is another transgression that I cannot be a part of. Please %s, we need your help!", Tux:get_player_name())
			hide("node21", "node22") show("node23", "node24")
		end,
	},
	{
		id = "node23",
		text = _"Chandra, it saddens me to hear this. I will keep what you say in mind, but there is too much suffering for me to ignore.",
		topic = "Linarians Attacked",
		code = function()
			Npc:says(_"Oh! This is great news! I was fearful that the truth would not settle well.")
			Npc:says(_"I should have never doubted the nobility and legendary honor of Linarians.")
			Chandra_first_contact = true
			hide("node20")
			pop_topic()
		end,
	},
	{
		id = "node24",
		text = _"(Attack)",
		echo_text = false,
		topic = "Linarians Attacked",
		code = function()
			Tux:says(_"Stupid humans! How dare you?! Your crimes are unforgivable! You all deserve to be slaughtered by these robots!")
			Npc:says(_"But...")
			Tux:says(_"And I am more than happy to help them!")
			Npc:set_faction("crazy")
			Chandra_revenge = true
			end_dialog()
		end,
	},
	{
		id = "node25",
		text = _"How come no one seems freaked out by a big fracking penguin?",
		topic = "Linarians",
		code = function()
			Npc:says(_"[b]<chuckles>[/b] This is not the first time the people of Earth have seen one of your kind.")
			Npc:says(_"Of course, its been almost one hundred years since Linarians first came to this planet. As you might imagine most of the people who were alive then are long gone.")
			Npc:says(_"But the townspeople were made aware of your existence upon your discovery. Everyone was quickly informed of the legends performed by the Linarians of the past.")
			Npc:says(_"While you will find some people helpful because of this, others may be a bit more hostile. The hostility is a matter of xenophobia and pride in one's own species.")
			if (not guard_follow_tux) then
				Npc:says(_"Don't tell anyone else, but I'm surprised the Red Guard ordered you to be thawed. They are human supremacists to the extreme. For them to accept your help does not make much sense. They must be playing at something. Beware the Red Guard, Linarian.")
			end
			hide("node25")
		end,
	},
	{
		id = "node26",
		text = _"Why did the Linarians come to this world?",
		topic = "Linarians",
		code = function()
			Npc:says(_"The planet you mean? No one knows that. None of you ever said anything about it.")
			Npc:says(_"Sorry, I cannot help you with that.")
			hide("node26")
		end,
	},
	{
		id = "node29",
		text = _"That's all I wanted to ask about that.",
		topic = "Linarians",
		code = function()
			Npc:says(_"Did you have any other questions?")
			pop_topic()
		end,
	},
	{
		id = "node30",
		text = _"Where is everybody? Don't tell me only a dozen of people survived!",
		code = function()
			Npc:says(_"No, no. The casualties here were much smaller than everywhere else.")
			Npc:says(_"Most of citizens are currently at the mines. They are doing everything they can to keep the town running.")
			Npc:says(_"Children, elderly and others who cannot work are upstairs. They are too afraid to come down.")
			Npc:says(_"The ones who you will find here are Red Guards, shopkeepers, medics, programmers, librarians, etc.")
			Npc:says(_"So do not worry. Things may be dire, but we weren't wiped off. Yet.")
			hide("node30")
		end,
	},
	{
		id = "node99",
		text = _"Thank you for your wise words.",
		code = function()
			Npc:says_random(_"Feel free to come here any time you want.",
							_"You flatter me.")
			end_dialog()
		end,
	},
}
