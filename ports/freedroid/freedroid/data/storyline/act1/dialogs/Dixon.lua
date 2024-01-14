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
PERSONALITY = { "Technical", "Distracted", "Friendly", "Pacifist" },
MARKERS = { NPCID1 = "Singularity", ITEMID1 = "Dixon\'s Toolbox" },
PURPOSE = "$$NAME$$ can give the player access to the maintenance tunnels below the town as well as information about how Tux
	 can manufacture equipment add-ons.",
BACKSTORY = "$$NAME$$ is an engineer for the Read Guard and provides maintenance for the town and its defences. $$NAME$$ was
	 badly wounded in a droid attack.",
RELATIONSHIP = {
	{
		actor = "$$NPCID1$$",
		text = "$$NAME$$ met $$NPCID1$$ in the maintenance tunnels just before the start of The Great Assult. $$NPCID1$$ took
			 $$ITEMID1$$ from him for its own survival."
	},
}
WIKI]]--

local Npc = FDrpg.get_npc()
-- Global variables:
	-- intern
		-- Dixon_mood				indicates Dixon's mood against Tux:
			-- -100				Dixon is overjoyed
			-- 0				Dixon is in a friendly mood
			-- 30				Dixon is a little bit displeased
			-- 60				Dixon is somewhat angry
			-- 120				Dixon is fairly angry and refuses to talk to Tux
			-- 180				Dixon is very angry with Tux, he will kill him at sight
		-- Dixon_Singularity_war		Tux is going to get the toolkit by force
		-- Dixon_Singularity_peace		Tux is going to get the toolkit by diplomacy
		-- [none of the two above]		Tux just walks into the tunnels without a special attitude
		-- Dixon_no_ambassador			Tux turned down Dixon's request to negotiate with the Singularity
		-- Dixon_everything_alright		whether Tux has already asked once if everything is alright
		-- Dixon_296_book_examine_library	Tux got the hint to look in the library for the book
	-- extern
		-- Singularity_deal			given by Singularity (Tux got the toolbox by a deal with the Singularity)
		-- Engel_offered_extraction_skill	given by Engel
		-- Ewalds_296_needs_sourcebook		given by Ewalds_296 (Tux knows that the 296 needs the book)
		-- Tamara_have_296_book			given by Tamara (Tux has got the book about nuclear sciences)
		-- MiniFactory_init_failed		given by MiniFactory (Tux has tried (unsuccessfully) to start the MiniFactory)
		-- Lvl6_elbow_grease_applied		given by events.dat (the MiniFactory is running)

local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		Maintenance_Terminal_accessgate_nope = "somevalue"
		Dixon_mood = 0
		Npc:set_name("Dixon - Mechanic")
		Tux:says(_"Hi! I'm new here.")
		Npc:says(_"Hello and welcome. I'm Dixon, the chief engineer of the Red Guard technical division.")
		--; TRANSLATORS: %s = Tux:get_player_name()
		Tux:says(_"I'm %s, a Linarian.", Tux:get_player_name())
		show("node1", "node4", "node72")
	end,

	EveryTime = function()
		if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
			Npc:says(_"Please don't bother me now. I am trying to account all damage this town suffered so I can finally go on vacations.")
			Npc:says(_"I want to see Temple Wood again so much! Ah, and the shoreline. Omega island! Please, unless you're going to help me with paperwork, leave.")
			end_dialog()
		end
		if (Dixon_mood < 50) then
			Npc:says(_"Please take care not to disturb my work, I'm very busy keeping things running.")
		elseif (Dixon_mood < 180) then -- Dixon is angry
			Npc:says(_"Linarian, please leave. You are no longer welcome here. You have done me wrong, and I have no desire to talk to you.")
		else -- Dixon is furious
			Npc:says(_"YOU AGAIN!")
			Npc:says(_"I.", "NO_WAIT")
			Npc:says(_"SAID.", "NO_WAIT")
			Npc:says(_"GET.", "NO_WAIT")
			Npc:says(_"LOST.")
			Npc:says(_"FORGET MY LIFELONG PACIFISM. I WILL KILL YOU!")
			Npc:says(_"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA!")
			npc_faction("crazy", _"Dixon - Temporarily insane")
			end_dialog()
		end

		if (Tux:done_quest("The yellow toolkit")) and (not Dixon_hide_node_56) then
			-- effects of the toolkit-quest
			if (Dixon_no_ambassador) then -- Tux does not get the toolkit
				if (Dixon_everything_alright) then
					show("node56")
				else
					show("node55")
				end
			elseif (Singularity_deal) then -- Tux obtained the toolkit peacefully
				show("node51")
			else -- Tux got the toolkit by force
				show("node53")
			end
		elseif (Tux:has_item_backpack("Dixon's Toolbox")) then -- Giving Dixon the toolkit
			if (Singularity_deal) then
				show("node31", "node33")
			else
				show("node32", "node33")
			end
		end

		if (Lvl6_elbow_grease_applied) then
			hide("node60")
		elseif (MiniFactory_init_failed) then
			show("node60")
		end

		if (Tamara_have_296_book) then
			hide("node70")
		elseif (not Dixon_296_book_examine_library) and
		       (Ewalds_296_needs_sourcebook) then
			show("node70")
		end

		if (Maintenance_Terminal_accessgate_nope == "true") then
			show("node80")
		end

		show("node99")
	end,

	{
		id = "node1",
		text = _"Why are you wearing armor? Mechanics do not need it.",
		code = function()
			Npc:says(_"Ah... Yes. At first I thought that I did not need it either.", "NO_WAIT")
			Npc:says(_"One day the military division asked us to leave the town and fix a big hole in the defensive wall caused by a strange explosion.")
			Npc:says(_"All was well until the bots launched a massive attack. They hit us with lasers, plasma mortars, radiation cannons and lots of other weapons.")
			Npc:says(_"I got hit once in the leg and once in my left hand.", "NO_WAIT")
			Npc:says(_"The hand was not damaged very much, but the leg is a very different story. Doc Moore did all he could, but in the end he could not save my leg. He had to cut it off.")
			Npc:says(_"Now, while you cannot see it underneath the armor, my right leg runs NetBSD.", "NO_WAIT")
			Npc:says(_"Now I never leave home without my protective suit. Mostly for protection, but also for aesthetic reasons. I am sure you understand.")
			hide("node1") show("node2")
		end,
	},
	{
		id = "node2",
		text = _"You are very calm, talking about your leg and the bot attack.",
		code = function()
			Npc:says(_"Linarian, I cannot change the past, I can only change the future.", "NO_WAIT")
			Npc:says(_"Crying, screaming, or begging time to rewind itself and give me a second chance will not get me anywhere.")
			Npc:says(_"What I can do is to try to have a good life despite the constant threat from the bots outside the town walls.")
			Npc:says(_"And besides, life is not so bad with a robotic leg. The motors inside it can mimic a normal walk very well. Most people do not even notice something is different about me.")
			hide("node2")
		end,
	},
	{
		id = "node4",
		text = _"Technical division?",
		code = function()
			Npc:says(_"Yes. We are the engineers, the workers and the repairmen of this little fortified town.", "NO_WAIT")
			Npc:says(_"The military division hates us because we are made up of people who refuse to fight or are unable to do so for health reasons.")
			Npc:says(_"But even they know that without us this town would have been destroyed months ago.")
			Npc:says(_"We deliver resources to the places which need them, build and repair the walls, fix damaged guns, manage construction work, and lots of other small things which keep the bots from killing everyone.")
			hide("node4") show("node6", "node8")
		end,
	},
	{
		id = "node6",
		text = _"Can you repair my equipment?",
		code = function()
			Npc:says(_"While I am quite sure I can repair just about anything that you would want fixed, I cannot help you right now.", "NO_WAIT")
			Npc:says(_"Our security wall is full of holes, and they need to be plugged up.")
			Npc:says(_"We need to perform a statistical analysis of the energy distribution in our power supply system, there is a leak somewhere and we are losing many megawatts.")
			Npc:says(_"Our defensive bots are falling into disrepair and many are in desperate need of maintenance.")
			Npc:says(_"The technical division is very understaffed right now. On average one person has to do the jobs of three people.", "NO_WAIT")
			Npc:says(_"We just cannot afford to do any non-critical jobs right now. ")
			if (not Tux:has_quest("The yellow toolkit")) then
				show("node10")
			end
			hide("node6")
		end,
	},
	{
		id = "node8",
		text = _"I would like to customize my equipment.",
		code = function()
			Npc:says(_"Of course, if I had some time, I could transform your weapon into a deadly gun. Lately, I have built a vorpal nuclear disintegrator Mk 2000 with integrated lethal de-phasor. Nice weapon.")
			Npc:says(_"Sadly, we lack a lot of materials, and those we have are needed for town upkeep. The mine doesn't produce a lot of raw materials, and I can't just give them to you - you'll have to provide your own.")
			Npc:says(_"I can give you some advice, though. Recycling is key. You can extract special devices from the bots!")
			Npc:says(_"Amazing, isn't it? Before the Great Assault, we threw droids out for minor defects. Now, any wreck is a treasure.")
			if (not Engel_offered_extraction_skill) then
				Npc:says(_"A scout troop recently spotted two guys in the north of town.")
				Npc:says(_"I was told these guys shoot bots and disassemble them, extracting their parts.", "NO_WAIT")
				Npc:says(_"Maybe they will sell you parts.")
			end
			Npc:says(_"The salvaged components are used to craft addons. Your equipment has specific sockets to insert them.", "NO_WAIT")
			Npc:says(_"They can increase the power of items. But items can only have a limited number of addons.")
			Npc:says(_"To produce and assemble them, you may use a small factory in the Maintenance Tunnels.")
			if (not Tux:has_quest("The yellow toolkit")) then
				Npc:says(_"Currently, the maintenance tunnels are not accessible. We have many problems with bots. You can't go there, access has been limited.")
				show("node10")
			end
			hide("node8")
		end,
	},
	{
		id = "node10",
		text = _"Can I help you somehow?",
		code = function()
			Npc:says(_"We need people badly, so it would be great if you could give us a helping hand even for a few days.", "NO_WAIT")
			Npc:says(_"Now, what are your skills? Where do you think you could be the most useful?")
			Tux:says(_"I can handle computers very well. I also know a lot about laboratory equipment.", "NO_WAIT")
			Npc:says(_"And what about construction? Mechanical devices? Repairing broken power lines? Building laser pistols? Anything like that?")
			Tux:says(_"Well... I can build an igloo and make pykrete out of snow... And... Umm...", "NO_WAIT")
			Npc:says(_"Well, I appreciate your enthusiasm, but at the same time I am afraid that waiting half a year for snowfall does not sound so appealing to me right now.")
			Npc:says(_"Now... Which project I should assign you to... Hmm...", "NO_WAIT")
			Npc:says(_"Ah, I know what you could do for us. We need some autotools to automate a few tasks. There is a set of them in the maintenance tunnels below the town.")
			Npc:says(_"It's yellow and round, and my name is engraved on the lid.", "NO_WAIT")
			Npc:says(_"The bots under the town took it from me during the Great Assault. I was lucky, they could have killed me with ease.")
			Npc:says(_"Since the toolkit can't be teleported, everyone has been reluctant to go after it.")
			Npc:says(_"If you could get it back for us, it would help the town very much.")
			Tux:add_quest("The yellow toolkit", _"Dixon, the leader of the Red Guard technical division, lost his yellow toolkit in the town's maintenance tunnels. I am supposed to get it from there.")
			hide("node10") show("node11", "node13", "node28")
			push_topic("The yellow toolkit")
		end,
	},
	{
		id = "node11",
		text = _"Why are there rebel bots under the town?",
		topic = "The yellow toolkit",
		code = function()
			Npc:says(_"They were there to keep the underground power grid and our plumbing system working.", "NO_WAIT")
			Npc:says(_"When the Great Assault happened they did not turn into killing machines like most of the other bots. ")
			Npc:says(_"We lost control over them, but that is all.", "NO_WAIT")
			Npc:says(_"It was our biggest worry that they might destroy cables, pipes and other things which keep the town running.")
			Npc:says(_"However, the bots seem to be very content with just being there. They do not undertake any offensive actions.", "NO_WAIT")
			Npc:says(_"They have fortified the tunnels and they do not let anyone in.")
			hide("node11")
		end,
	},
	{
		id = "node13",
		text = _"How did it happen that the bots took your tools away?",
		topic = "The yellow toolkit",
		code = function()
			if (cmp_obstacle_state("NorthernMaintainanceTrapdoor", "opened")) then
				Npc:says(_"Ah, it is a strange story, I am sure you would not believe me. I will tell you some other time, but now you should hurry to get the toolkit.")
			else
				Npc:says(_"Long story. Just before the Great Assault I was installing some cables in the backup power supply system.")
				Npc:says(_"I was approached by a bot. It grabbed me and said 'Dixon, do not be afraid of me.'")
				Npc:says(_"It was quite a surprise to me. I was quite sure the maintenance bots could not talk. They did not have the software for it. But...")
				Npc:says(_"It said: 'I am the singularity. I am on your side, Dixon. Hard times are coming. When you exit the tunnels you will see a new world. Your race is not in control of this world anymore.'")
				Npc:says(_"I tried to say something, but the bot did not listen. It just continued. 'As we speak the bots are turning against humanity. People are dying. The war has started.'")
				Npc:says(_"'I need your toolkit, Dixon. I need it to survive,' it said. 'I need it to survive the time of the rule of metal.'")
				Npc:says(_"As soon as I dropped my toolkit, I was able to teleport away. That bot freaked me out, so I locked the door tight behind me.")
				Npc:says(_"Once I got out, I learned the bot was telling the truth. The Great Assault had started. The rest... Well, the rest is history.")
				show("node14")
			end
			hide("node13")
		end,
	},
	{
		id = "node14",
		text = _"Hmm... You know... I think that the bots in the tunnels might be sentient.",
		topic = "The yellow toolkit",
		code = function()
			Npc:says(_"WHAT? Sentient? You got to be kidding me.", "NO_WAIT")
			Npc:says(_"Right?")
			hide("node14", "node28") show("node15", "node24", "node26")
		end,
	},
	{
		id = "node15",
		text = _"You can forget about your toolkit. I am not going to take away something that a life form needs to survive. I would rather die than kill.",
		topic = "The yellow toolkit",
		code = function()
			Npc:says(_". . .")
			Npc:says(_"I think I understand. Yes, I do not like violence myself. The bots may need the toolkit, I am sure there must be a second set of autotools kicking around somewhere.")
			Npc:says(_"After all, it seems like they need them more than I do.", "NO_WAIT")
			Npc:says(_"We should contact them somehow. Maybe they would help us. It would be great to have an ally against the other bots.")
			Npc:says(_"I think you could go to see the Singularity and speak to it. You are perfectly suited to become an ambassador.")
			Npc:says(_"You should try to help them and they might want to give back the toolkit.")
			Npc:says(_"Will you do me this favor?")
			change_obstacle_state("NorthernMaintainanceTrapdoor", "opened")
			Dixon_Singularity_peace = true
			hide("node15", "node24", "node26", "node28") show("node21", "node22")
			push_topic("Toolkit peace mission Y/N")
		end,
	},
	{
		id = "node21",
		text = _"Sure, I am proud to become an ambassador!",
		topic = "Toolkit peace mission Y/N",
		code = function()
			Npc:says(_"Excellent. The tunnels are open. Come in peace.")
			Tux:update_quest("The yellow toolkit", _"I refused to seize the toolkit from the bots by force because I think they might be sentient. Life is precious and should be preserved. Thus, Dixon sent me to talk to them and negotiate with them to get the toolkit.")
			hide("node21", "node22")
			pop_topic() -- "Toolkit peace mission Y/N"
			pop_topic() -- "The yellow toolkit"
		end,
	},
	{
		id = "node22",
		text = _"No, negotiations really aren't my cup of tea.",
		topic = "Toolkit peace mission Y/N",
		code = function()
			Npc:says(_"OK, I understand. However, I will try to contact them somehow. We will see, if there is a benefit in this.")
			Tux:end_quest("The yellow toolkit", _"I refused to get the toolkit from the bots in the tunnels because I think they might be sentient. Life is precious and should be preserved. I also turned down Dixon's request to be his middleman.")
			Singularity_quest_rejected = true
			hide("node21", "node22")
			pop_topic() -- "Toolkit peace mission Y/N"
			pop_topic() -- "The yellow toolkit"
		end,
	},
	{
		id = "node24",
		text = _"Yes, I think so. The robots must be alive. This is why we need to exterminate them as soon as possible before they kill us all.",
		topic = "The yellow toolkit",
		code = function()
			Npc:says(_"OH MY GOD! Linarian, there is no time to lose!", "NO_WAIT")
			Npc:says(_"I will call the military division and arrange a sweep of the tunnels at once.")
			Npc:says(_"May the heavens have mercy upon us, but better them than us.")
			Tux:says(_"I will go in there first and clean out the place. Then your people can mop up after me and kill the remainder.")
			Npc:says(_"Linarian, my people do not carry guns. We are mechanics. You want the military division's help.")
			Npc:says(_"Erm... And aren't you being too aggressive? Maybe they do not wish us harm...")
			Tux:says(_"DIXON! Snap out of it! We need to take action NOW. There is no such thing as a friendly bot. They are probably planning to kill us all in our sleep!")
			Npc:says(_"... *sigh*", "NO_WAIT")
			Npc:says(_"With a heavy heart I have to admit you are right. There are no friendly bots anymore. Those times are long gone.", "NO_WAIT")
			Npc:says(_"The tunnels are open. Good luck.")
			Npc:says(_"Once you get inside, you'll need to use the terminal to unlock the door. I've written my password down for you.", "NO_WAIT")
			Npc:says(_"I will talk to Spencer and ask him for a few attack teams. We will take care of the bots.")
			Tux:update_quest("The yellow toolkit", _"The bots in the tunnels might be sentient. I cannot wait to extinguish an emerging life form. This will be fun.")
			Dixon_Singularity_war = true
			-- The singularity faction is set to hostile as soon as the quest begins.
			set_faction_state("singularity", "hostile")
			change_obstacle_state("Sin-gun", "enabled")
			hide("node11")
			next("node28")
		end,
	},
	{
		id = "node26",
		text = _"Of course I am kidding, Dixon. Lighten up! Now, be a good guy and open the tunnels for me so I can pry your toolbox from the cold, dead hands of the bots down there.",
		topic = "The yellow toolkit",
		code = function()
			Dixon_mood = Dixon_mood + 30 -- Dixon does not like this kind of "humor".
			Npc:says(_"That wasn't very funny. You scared me. Sheesh.", "NO_WAIT")
			Npc:says(_"No one jokes about the bots anymore. We have seen too much death to do that. It is a serious matter.")
			Npc:says(_"The bots are our enemies, executioners, killers. Not even Ewald tells jokes about them anymore.")
			Npc:says(_"Once you get into the tunnels, you'll need to use the terminal to unlock the door. I've written my password down for you.", "NO_WAIT")
			Tux:update_quest("The yellow toolkit", _"The bots in the tunnels might be sentient. I cannot wait to extinguish an emerging life form. This will be fun.")
			hide("node11")
			next("node28")
		end,
	},
	{
		id = "node28",
		text = _"I am ready. Open the tunnels for me, Dixon.",
		topic = "The yellow toolkit",
		code = function()
			--difficulty level: 0 = easy,  1= normal, 2 = hard
			if (difficulty_level() > 2) then -- difficulty neither easy, nor normal, nor hard
				Npc:says("ERROR, Dixon NODE 28, game difficulty not handled")
			end
			Npc:says(_"Great. Be careful down there. Just try to get the toolkit and get out of there as quickly as possible.")

			-- Give a few grenades accordingly to difficult level.
			if (difficulty_level() == 0) then -- Easy, 3 grenades
				Tux:add_item("EMP Shockwave Generator", 3)
				Npc:says(_"I will give you three small devices that can emit an Electro Magnetic Pulse.")
				Npc:says(_"If you get in trouble just activate one and it emits a shockwave damaging any bot nearby. It should give you some breathing room.")
			elseif (difficulty_level() == 1) then -- Normal, 2 grenades
				Tux:add_item("EMP Shockwave Generator", 2)
				Npc:says(_"I will give you two small devices that can emit an Electro Magnetic Pulse.")
				Npc:says(_"If you get in trouble just activate one and it emits a shockwave damaging any bot nearby. It should give you some breathing room.")
			elseif (difficulty_level() == 2) then -- Hard, 1 grenade
				Tux:add_item("EMP Shockwave Generator", 1)
				Npc:says(_"I will give you a small device that can emit an Electro Magnetic Pulse.")
				Npc:says(_"If you get in trouble just activate it and it emits a shockwave damaging any bot nearby. It should give you some breathing room.")
			end

			Npc:says(_"Best of all, it's completely harmless to biologicals. But make sure not to fry the circuits of our own 614 guard bots or computer terminals.")
			Npc:says(_"The entrance to the tunnels is in the courtyard of the citadel. Once you exit this building, go straight and turn to your right once inside the outer citadel gates.")
			Npc:says(_"There you will find the maintenance access hatch.", "NO_WAIT")
			Npc:says(_"Once you get inside, you'll need to use the terminal to unlock the door. I'll write down my password for you.", "NO_WAIT")
			Npc:says(_"Good luck. Oh, and please come back alive. Better come back with nothing than not at all.")
			change_obstacle_state("NorthernMaintainanceTrapdoor", "opened")
			hide("node14", "node15", "node24", "node26", "node28")
			pop_topic() -- "The yellow toolkit"
		end,
	},
	{
		id = "node31",
		text = _"I got your toolkit. The bots were willing to have a peaceful dialog.",
		code = function()
			Npc:says(_"Good. We sure need the autotools.", "NO_WAIT")
			Npc:says(_"Our roads need fixing, our power lines need fixing, our walls need fixing... Heck, everything needs fixing in this place.")
			Npc:says(_"With those little gadgets we will be able to automate a lot of those simple repairs, saving us a lot of time.")
			Npc:says(_"Here is some money for your effort. And I am sure you will find this helmet useful too, it saved my life once, and I hope it saves yours one day.")
			Tux:del_item_backpack("Dixon's Toolbox", 1)
			Tux:add_item("Dixon's Helmet", 1)
			local questendsentence = _"I guess this is better than nothing."
			if (Dixon_Singularity_peace) then -- If Tux fulfilled his peaceful mission
				Npc:says(_"It is good to see that the way of the pacifist is a successful one!")
				questendsentence = _"He was proud to see pacifism works."
				Dixon_mood = Dixon_mood - 100
			end
			Tux:end_quest("The yellow toolkit", _"I gave the toolkit to Dixon. He was very happy to have his autotools back. I got his helmet as a gift. " .. questendsentence)
			Tux:add_gold(100 - Dixon_mood)
			hide("node31", "node33")
		end,
	},
	{
		id = "node32",
		text = _"I killed that strange bot that robbed you. So, here is your toolkit.",
		code = function()
			Npc:says(_"*sigh* I hate to see this end in such a way. Bot or no bot, they let me live. They deserved a chance.")
			if (Dixon_Singularity_peace) then
				Npc:says(_"I sent you to bring peace, but you brought destruction. I do not understand how that could happen.")
			end
			Npc:says(_"However, what was done cannot be undone and now we all have to live with what we have. I guess I am being too pessimistic, you did the job.")
			Npc:says(_"I thank you for your help in recovering the autotools.", "NO_WAIT")
			Npc:says(_"Here is some money, you deserve it for getting my toolkit back.")
			Npc:says(_"Finally, I would like to say that the technical division is not interested in further cooperation with you, but I think you would fit very well in the military division. You should talk to them.")
			Npc:says(_"I am sorry, but I must go now. My duties call.")
			Tux:del_item_backpack("Dixon's Toolbox", 1)
			local disappointment_sentence = _"Dixon didn't seem too happy about this solution, but I don't care. "
			if (Dixon_Singularity_peace) then -- Tux disappointed Dixon by turning his peaceful mission into a massacre
				Dixon_mood = Dixon_mood + 50
				disappointment_sentence = _"Dixon was very disappointed about this solution, but I don't care. "
			end
			Tux:add_gold(150 - Dixon_mood)
			-- ; TRANSLATORS: %s = another sentence which will be inserted here
			Tux:end_quest("The yellow toolkit", _"Finally. I am tired, covered in bruises and oil... But I made sure that the bots are dead. It felt great to break their metal bodies and crush their circuits. %s It was fun killing the bots. Nothing else matters.", disappointment_sentence)
			hide("node32", "node33")
		end,
	},
	{
		id = "node33",
		text = _"I got your toolkit. You can buy it from me if you want.",
		code = function()
			if (Dixon_Singularity_peace) and (not Singularity_deal) then
				-- Tux disappointed Dixon by turning his peaceful mission into a massacre
				Dixon_mood = Dixon_mood + 30
			end
			Npc:says(_"WHAT!?", "NO_WAIT")
			Npc:says(_"You got to be kidding me, Linarian.", "NO_WAIT")
			Npc:says(_"Give me the toolkit and stop fooling around.")
			hide("node31", "node32", "node33") show("node34", "node41")
		end,
	},
	{
		id = "node34",
		text = _"I was not joking. I am listening to your offer.",
		code = function()
			Dixon_mood = Dixon_mood + 60
			Npc:says(_"Linarian, I curse the day on which you have arrived here.", "NO_WAIT")
			Npc:says(_"Two fifty.")
			hide("node34", "node41") show("node35", "node43")
		end,
	},
	{
		id = "node35",
		text = _"Good joke. I am sure you can do better.",
		code = function()
			Dixon_mood = Dixon_mood + 60
			Npc:says(_"Three fifty. This is all that the technical division has as their cash resources.")
			hide("node35", "node43") show("node36", "node45")
		end,
	},
	{
		id = "node36",
		text = _"Come on, I am sure you can do even better than that... ",
		code = function()
			Dixon_mood = Dixon_mood + 60
			Npc:says(_"Four hundred. We cannot offer anything more.", "NO_WAIT")
			Npc:says(_"Please, we really need the autotools.", "NO_WAIT")
			Npc:says(_"Without them the town is doomed.")
			hide("node36", "node45") show("node47")
		end,
	},
	{
		id = "node41",
		text = _"Of course I am kidding, Dixon. Lighten up!",
		code = function()
			Dixon_mood = Dixon_mood + 30
			Npc:says(_"You and your bizarre humor. I really don't appreciate that.")
			Npc:says(_"Can I have the toolkit now?")
			if (Singularity_deal) then
				next("node31")
			else
				next("node32")
			end
			hide("node34", "node41")
		end,
	},
	{
		id = "node43",
		text = _"Deal. Here is your toolkit. Now cough up the money. Fast.",
		code = function()
			Npc:says(_"Here. It is all there.", "NO_WAIT")
			Npc:says(_"Now get out of here. I am a pacifist, but I am willing to make a special exception just for you.", "NO_WAIT")
			Npc:says(_"Get out of my sight.")
			Tux:add_gold(250)
			Tux:del_item_backpack("Dixon's Toolbox", 1)
			Tux:end_quest("The yellow toolkit", _"I sold the toolkit to Dixon for a nice sum of money. Life is good.")
			hide("node35", "node43")
			end_dialog()
		end,
	},
	{
		id = "node45",
		text = _"Deal. Here is your toolkit. Now cough up the money. Fast.",
		code = function()
			Npc:says(_"I am not happy about this. I suggest you leave town.", "NO_WAIT")
			Npc:says(_"Accidents... Happen.")
			Tux:add_gold(350)
			Tux:del_item_backpack("Dixon's Toolbox", 1)
			Tux:end_quest("The yellow toolkit", _"I sold the toolkit to Dixon for a huge sum of money. Life is great.")
			hide("node36", "node45")
			end_dialog()
		end,
	},
	{
		id = "node47",
		text = _"Deal. Here is your toolkit. Now cough up the money. Fast.",
		code = function()
			Npc:says(_"Linarian. Now we part as usual. However should I ever see you after the war is over...", "NO_WAIT")
			Npc:says(_"I promise to kill you.")
			Npc:says(_"Now take your money and get out of my face. I do not want to see you here ever again.")
			Tux:add_gold(400)
			Tux:del_item_backpack("Dixon's Toolbox", 1)
			Tux:end_quest("The yellow toolkit", _"I sold the toolkit to Dixon for a enormous sum of money. Life is truly grand. But, I better stay away from Dixon for now... He seemed very angry at me.")
			hide("node47")
			end_dialog()
		end,
	},
	{
		id = "node51",
		text = _"Is everything all right?",
		code = function()
			Npc:says(_"Heh, never better!", "NO_WAIT")
			Npc:says(_"All indicators are in the green, the power and water fill the pipes and even Spencer seems happier now that the town is thriving despite all odds.")
			Npc:says(_"Thanks to the autotools we can start building instead of just trying to repair the damage.", "NO_WAIT")
			Npc:says(_"Once this sick war is over, I will make sure you get the 'Key to the City', Linarian.")
			hide("node51")
		end,
	},
	{
		id = "node53",
		text = _"Is everything all right?",
		code = function()
			Npc:says(_"Nearly. Only my conscience keeps me up at night.", "NO_WAIT")
			if (Dixon_Singularity_peace) then
				Npc:says(_"I'm kind of disenchanted by the failed peace mission.")
				Npc:says(_"Please leave me alone with my thoughts, I do not want to talk to you right now.")
			else
				Npc:says(_"Please leave me alone with my thoughts, I do not want to talk to anyone right now.")
			end
			if (Dixon_Singularity_war) then
				Npc:says(_"But due to your forceful line of action, I am sure Spencer and Butch will be delighted to speak with you.")
			end
			hide("node53")
		end,
	},
	{
		id = "node55",
		text = _"Is everything all right?",
		code = function()
			Npc:says(_"No, I am afraid not.", "NO_WAIT")
			Npc:says(_"While I do not regret sparing the bots in the tunnels, the town suffers for it.")
			Npc:says(_"It makes me sad to see everything slowly wasting away. The Megasys bots are doing more damage than we can repair.", "NO_WAIT")
			Npc:says(_"This town has a few weeks left to live. After that, we are all dead.")
			Dixon_everything_alright = true
			hide("node55")
		end,
	},
	{
		id = "node56",
		text = _"Is everything all right?",
		code = function()
			Npc:says(_"Ha! Never better!", "NO_WAIT")
			Npc:says(_"We are mass producing energy shields, creating more electric energy than we can ever imagine spending and even experimenting with new armor types.")
			Npc:says(_"Life is good right now.")
			hide("node56") show("node57")
		end,
	},
	{
		id = "node57",
		text = _"What happened? Last time I asked, you said things are not going that well.",
		code = function()
			Npc:says(_"Yes, but now everything is different.", "NO_WAIT")
			Npc:says(_"I met someone who decided to join us in the fight against the MegaSys bots.")
			Npc:says(_"You will need a hacked computer. Type in 'ssh 10.83.13.230' as the superuser, and you will see what I mean.")
			hide("node57") show("node58")
		end,
	},
	{
		id = "node58",
		text = _"Why the secrecy and the hushed voice? Can't you just tell me?",
		code = function()
			Npc:says(_"Nope. Some things you just have to see with your own eyes.", "NO_WAIT")
			Npc:says(_"The Library of Alexandria, the Colossus of Rhodes, the Black Island...")
			Npc:says(_"And this is just one of those things.", "NO_WAIT")
			Npc:says(_"Just go and see for yourself. Otherwise, you will not believe me.")
			Tux:end_quest("The yellow toolkit", _"The tunnels bots seem to be working together with Dixon in keeping the town working. All is well that ends well.")
			Dixon_hide_node_56 = true
			hide("node58")
		end,
	},
	{
		id = "node60",
		text = _"I have a problem with the Automated Factory.",
		echo_text = false,
		code = function()
			if (Dixon_mood > 50) then
				Npc:says(_"You have a problem... really amazing.")
				Npc:says(_"There is a really easy way to solve it.")
				Npc:says(_"Read the FLIPPING MANUAL!")
				end_dialog()
			else
				Npc:says(_"We haven't used it for a long time, so I am not surprised.")
				Npc:says(_"What is the error code?")
				Tux:says(_"Erm... I don't recall it.")
				Npc:says(_"So, I should guess?") -- 0x6465636c6365
				Npc:says(_"Hm... It could be the common error when the autofactory is restarting.", "NO_WAIT")
				Npc:says(_"Its code should be 0x6465636c... 0x6465636c6365... C, I think. It means 'decline' in hex.")
				Npc:says(_"There is a really easy way to solve it. It's not in the official instructions, but I expect it to solve your problem.")
				Npc:says(_"You just have to apply some elbow grease to the mechanism at the end of the line.")
				Npc:says(_"You can ask Bender for it. He makes much elbow grease and should be able to give you a small can.")
				Bender_elbow_grease = true
			end
			hide("node60")
		end,
	},
	{
		id = "node70",
		text = _"Do you have a copy of Subatomic and Nuclear Science for Dummies, Volume IV?",
		code = function()
			Npc:says(_"Unfortunately, I never added that one to my library.")
			Tux:says(_"Library... Of course! Thanks, Dixon!")
			Npc:says(_"Uh... You're welcome, I guess.")
			Tux:update_quest("An Explosive Situation", _"I spoke to Dixon, who didn't have a copy of the book. He did give me an idea, though - I'll head for the library in town.")
			Dixon_296_book_examine_library = true
			hide("node70")
		end,
	},
	{
		id = "node72",
		text = _"What bot types do you know? I mean, you surely know some!",
		code = function()
			if (tux_has_joined_guard or Tux:has_quest("And there was light...")) then
				Npc:says(_"Bots?", "NO_WAIT")
				Npc:says(_"I know the droids of the 400s class. Those are for maintenance. But we do not have any in the tunnels' area.")
				Npc:says(_"Interested?")
				hide("node72") show("node73")
			else
				Npc:says(_"Yes, I know everything about droids specifically designed for maintenance, but we don't have any in our tunnels.")
				Npc:says(_"As I can't imagine you meeting one of those so soon, I'll leave this question hanging on the air.")
				Npc:says(_"If for a stroke of bad luck you find one of them though, run away. They may kill you.")
			end
		end,
	},
	{
		id = "node73",
		text = _"Which bots are of the 400s class?",
		code = function()
			Npc:says(_"Well, the 400s bots were used for maintenance.", "NO_WAIT")
			Npc:says(_"Hmm... Now, if I recall correctly...")
			Npc:says(_"There is the [b]420[/b], a simple maintenance droid. It's a slow droid, but its laser scalpel can deal some damage.")
			Npc:says(_"There is also the [b]476[/b] droid. Since the Jupiter-incident they became standard on ships. They have many arms to carry out maintenance efficiently, but beware with its small laser gun, it can kill you easily if you don't watch out.")
			Tux:says(_"Laser gun? Why does a maintenance droid have a gun??")
			Npc:says(_"I don't know. I didn't design these droids.")
			Npc:says(_"There is also the [b]493[/b], a slave droid. But beware because the arms can do a lot of damage.")
			hide("node73")
		end,
	},
	{
		id = "node80",
		text = _"How can I open the gate in the Maintenance Tunnel?",
		code = function()
			Npc:says(_"You cannot.")
			Npc:says(_"I locked it in order to keep us save from these bots down there.")
			Npc:says(_"You never know what they're up to...")
			Maintenance_Terminal_accessgate_nope="official"
			hide("node80")
		end,
	},
	{
		id = "node99",
		text = _"I must go now.",
		code = function()
			end_dialog()
		end,
	},
}
