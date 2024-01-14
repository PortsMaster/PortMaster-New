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
PERSONALITY = { "Militaristic", "Amoral" },
MARKERS = { NPCID1 = "Francis" },
PURPOSE = "$$NAME$$ is the leader of the Red Guard and gives Tux several quests that involve either ensuring the survival
	 of the town, the downfall of the bots or actions Tux can take to join the Red Guard. $$NAME$$ has the final say on
	 whether Tux can join the Red Guard.",
RELATIONSHIP = {
	{
		actor = "$$NPCID1$$",
		text = "$$NAME$$ disagrees with $$NPCID1$$ about disposing of people in cryonic stasis. $$NAME$$ wants to dispose of some of
		 these people because he wants resources used by cryonic stasis for the town\'s survival. $$NAME$$ threatened to reveal a
		 secret from $$NPCID1$$\'s past to force compliance."
	}
}
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0")
		guard_follow_tux = false
		local guard = FDrpg.get_npc("Town-TuxGuard")
		guard:set_state("patrol")
		change_obstacle_state("Dixon-autogun", "enabled")
	end,

	EveryTime = function()
		if (MO_HFGateAccessServer_Spencer) then
			Npc:says(_"Red Guard HQ, Spencer speaking.")
			Npc:says(_"Are you receiving me?")
			Tux:says(_"Yes.")
			Tux:says(_"Spencer, we have a problem.")
			Npc:says(_"Yes, Richard detected abnormalities with the server. Can you report anything regarding this?")
			Tux:says(_"Indeed, the server says it is a gate server, not a firmware server.")
			Npc:says(_"Bah!")
			Npc:says(_"Must prevent access to the real update server. Can you open the gate?")
			--; TRANSLATORS: follow the markers on the ground
			Npc:says(_"Inside, follow the mrkers o e groun")
			--; TRANSLATORS: Richard says the connection is bad
			Npc:says(_"Ri ard sa... e c nn cti n *bzzzzzzzzz* bad.")
			--; TRANSLATORS: good luck
			Npc:says(_"Goo*sizzle*ck.")
			--; TRANSLATORS: over
			Npc:says(_"O*crack*r")
			Tux:update_quest("Propagating a faulty firmware update", _"Spencer contacted me and said I was supposed to find the real firmware update server. I hope I survive this...")
			Tux:add_quest("Open Sesame", "It turns out what we thought was the firmware update server was just a gate access server. Spencer speculates the real firmware server is behind this gate. There should be something on the ground I am supposed to follow.")
			end_dialog()
		elseif (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) and (not HF_FirmwareUpdateServer_Spencer) then
			next("node60")
		elseif (HF_Spencer_teleported) then
			hide("node7")
			if (Spencer_node66) then
				Spencer_node66=false
				show("node66")
			end
		elseif ((Tux:has_item_equipped("The Super Exterminator!!!") or
				Tux:has_item_equipped("Exterminator")) and (not HF_FirmwareUpdateServer_uploaded_faulty_firmware_update)) then
				Npc:says(_"Even a Red Guard Member only points Exterminators to rebels and bots.", "NO_WAIT")
				Npc:says(_"Unless I am a bot and do not realize it, I must request that you unequip it.")
				end_dialog()
		elseif (tux_has_joined_guard) then
			Npc:says(_"Greetings fellow Red Guard member.")

			hide("node2", "node12")
		end

		if (Tania_met_Pendragon) and (not Spencer_Tania_decision) then
			show("node50")
		end

		if (not Tux:has_quest("Opening access to MS Office")) and
		   (Tux:done_quest("A kingdom for a cluster!")) then
			show("node37")
		end

		if (not Tux:has_quest("Propagating a faulty firmware update")) and
		   (Tux:done_quest("Opening access to MS Office")) then
			show("node44")
		end

		if (data_cube_lost) and
		   (not Tux:done_quest("Deliverance")) then
			show("node29")
		end

		if ((not (Tux_told_Spencer_about_Bob_and_Jim)) and ((Tux:has_met("Bob")) and (knows_spencer_office))) then
			show("node70")
		end

		show("node99")
	end,

	{
		id = "node0",
		text = _"Hi! I'm new here.",
		code = function()
			Npc:says(_"I'm Spencer. I'm the leader of the Red Guard. Is there anything I can help you with?")
			knows_spencer_office = true
			if (Tux:has_quest("Deliverance")) and
			   (not Tux:done_quest("Deliverance")) then
				show("node20")
			end
			hide("node0") show("node1", "node7")
		end,
	},
	{
		id = "node1",
		text = _"I want to join the Red Guard.",
		code = function()
			Npc:says(_"Hmm... Really? Well, you cannot join just like that, you know...", "NO_WAIT")
			Npc:says(_"You must prove that you would make a good new member.")
			hide("node1") show("node2")
		end,
	},
	{
		id = "node2",
		text = _"I really want to become a member.",
		code = function()
			Npc:says(_"This is not so easy. First you must establish a reputation around here. Ask around, talk to people and build your reputation.")
			Npc:says(_"Once you're a known character around here, we might let you join the ranks of the Guard.")
			hide("node2") show("node3", "node12")
		end,
	},
	{
		id = "node3",
		text = _"How about some circuits instead?",
		code = function()
			Npc:says(_"For 15 million circuits, no less, hehe.")
			if (Tux:get_gold() >= 15000000) then -- player cheated obviously :-)
				show("node9")
			end
			hide("node3", "node7", "node12") show("node4")
		end,
	},
	{
		id = "node4",
		text = _"But I don't have that many circuits!",
		code = function()
			Npc:says(_"That much I can tell.")
			Npc:says(_"Look, I'm just fooling around. We don't let just anyone join the Red Guard.", "NO_WAIT")
			Npc:says(_"If you seriously want to join, you have to prove yourself first. You might want to ask around town for things you can do.")
			hide("node4", "node9") show("node7", "node12")
		end,
	},
	{
		id = "node6",
		text = _"Maybe I could help somehow?",
		code = function()
			Npc:says(_"That would be most kind of you, but I doubt that you will be able to clear out the warehouse for us.")
			Npc:says(_"But since you are said to be powerful and a former hero, I'll once more put trust into a stranger.")
			Npc:says(_"I've unlocked the access-way to the warehouse. It's to the north of this town, somewhat hidden in the woods northeast.")
			Npc:says(_"The stuff we need is on the first floor. Don't go any deeper, there are only bots in there.", "NO_WAIT")
			Npc:says(_"I wish you the best of luck.")
			Tux:add_quest("Opening a can of bots...", _"I am supposed to clean out the first level of some warehouse. Sounds easy. It lies nearby, somewhat hidden in the woods north-east of town.")
			change_obstacle_state("TrapdoorToWarehouse", "opened")
			hide("node6")
		end,
	},
	{
		id = "node7",
		text = _"How is it going?",
		code = function()
			if (Tux:has_quest("Opening a can of bots...")) then
				if (Tux:done_quest("Opening a can of bots...")) then
					if (Spencer_reward_for_warehouse_given) then
						Npc:says(_"Thanks to you, we've been able to transport all the goods we need right now. You've really helped us out there.")
						Npc:says(_"Rest assured that we will never forget your brave activity for our community.")
					else
						Npc:says(_"Man, you really did it! I can hardly believe it, but all the bots are gone!", "NO_WAIT")
						Npc:says(_"Take these 500 circuits as a reward. And be assured that you've earned my deepest respect, Linarian.")
						Npc:says(_"Our people are transporting the goods as we speak. It can't be too long until new bots from ships in the orbit of the planet will beam down to replace the dead bots.")
						Tux:add_gold(500)
						Spencer_reward_for_warehouse_given = true
						Tux:update_quest("Opening a can of bots...", _"Ouch. It wasn't. At least I am alive, and the warehouse is clear. *Whew*.")
					end
				else
					Npc:says(_"Not too good. Without the supplies from the warehouse we are doomed. So my problems are still the same.")
					Npc:says(_"Maybe later, when you grow more experienced you might be able to help us after all.")
				end
			else
				Npc:says(_"These are bad times. Interplanetary travel is made impossible by bot ships, so we need to stick to our local resources.")
				Npc:says(_"We've got a list of stuff we need from the automated underground storage north of town. But the bots there are numerous.")
				Npc:says(_"And currently I can't spare a single man from the town's defenses. It's quite a difficult situation.")
				show("node6")
			end
		end,
	},
	{
		id = "node9",
		text = _"I actually do have the 15 million bucks, here take it!",
		code = function()
			Npc:says(_"Wow, err, I mean, thanks.")
			Npc:says(_"You are a Red Guard now.")
			Npc:says(_"Oh, wait, you cheated, didn't you?")
			Npc:says(_"There is no way we can have lame cheaters in the Red Guard, forget about it!")
			Npc:says(_"However, if you did in fact NOT cheat, please tell the developers how you got so much money so they can fix it. :)")
			Npc:says(_"Contact information can be found at https://www.freedroid.org/Contact")
			hide("node9")
			Tux:del_gold(1000000)
		end,
	},
	{
		id = "node12",
		text = _"Have I done enough quests to become a member now?",
		code = function()
			if (not Tux:done_quest("The yellow toolkit")) then
				Npc:says(_"I think our teleporter service man, Dixon, has some problem. You might want to talk to him.")
			elseif (not Dixon_mood) or
			       (Dixon_mood < 50) then
				Npc:says(_"Dixon told me about the matter with his toolkit. He seemed pretty impressed by you.")
			elseif (Dixon_mood < 120) then
				Npc:says(_"Dixon has his toolkit back.", "NO_WAIT")
				Npc:says(_"He was in bad mood and told me he had to pay you for getting his own property back.")
				Npc:says(_"I think it is the best for him if we leave him alone the next days.", "NO_WAIT")
				Npc:says(_"I'm sure he has to do a lot now.")
				-- Joining the guard, tux has to pay 500 circuits.
			elseif (Dixon_mood < 180) then
				Npc:says(_"Dixon has his toolkit back.", "NO_WAIT")
				Npc:says(_"He seemed quite aggressive and stressed.")
				Npc:says(_"Poor guy, if we weren't in such a bad situation, he could have some work-free days, but bot attacks continue all the time.", "NO_WAIT")
				Npc:says(_"You better don't bother him the next days.")
				-- Tux will have to pay 700 circuits to join the red guard
			else
				Npc:says(_"Dixon has his toolkit back.", "NO_WAIT")
				Npc:says(_"He did rail against you though. He said he had to give you 400 circuits to get his toolkit back, his own property.")
				Npc:says(_"That was nearly all the money he had. He said you were too greedy to become a good member and he doesn't want to see you anymore.")
				Npc:says(_"I think everybody deserves to get a chance. Remember this: If you are negatively conspicuous again, we will ban you from our town!")
				-- Tux needs to pay 800 circuits to join the guard.
			end

			if (Tux:done_quest("Anything but the army snacks, please!")) then
				Npc:says(_"When I was eating, Michelangelo told me about his renewed oven energy supply. He seemed very pleased, and so was I.")
			else
				Npc:says(_"I think you should visit the town's cook sometime. He's usually in the restaurant kitchen.")
			end

			if (Tux:done_quest("Novice Arena")) then
				Npc:says(_"From Butch I hear you've become a novice arena master. Congratulations.")
			else
				Npc:says(_"You might want to score some arena victories. That could also help your reputation a lot.")
			end

			if (Tux:done_quest("Bender's problem")) then
				Npc:says(_"Helping Bender along was also a smart move. But you should be very careful with that one. He can get mad rather easily. A bit of a security threat, but we can't be too picky.")
			else
				Npc:says(_"As far as I know, Bender is still very sick.")
			end

			if (Tux:done_quest("Opening a can of bots...")) then
				Npc:says(_"But most importantly, I was very impressed with you when you cleared out the warehouse. That was a huge deed I will never forget.")
			else
				Npc:says(_"Personally I'm also worrying about how we will manage to get some necessary supplies from our warehouse. It's filled with bots and we just don't have the manpower to spare to clean them out.")
				if (not Tux:has_quest("Opening a can of bots...")) then
					show("node6")
				end
			end

			if (get_town_score() > 49) then
				-- ENOUGH POINTS TO JOIN RG
				Npc:says(_"OK. Your list of achievements is long enough. You can join us. So I hereby declare you a member of the Red Guard.")
				Npc:says(_"But now that you are in the Guard, know this: There is only one rule for us guards: We stick together. We survive together or we die together. But we do it together.")
				Npc:says(_"And now you might want to inspect the guard house. Tell Tybalt to open the door for you. Lukas at the arms counter will give you your armor.")
				Npc:says(_"I hope you will prove yourself a worthy member of the Red Guard.")
				display_big_message(_"Joined Town Guard!!")
				tux_has_joined_guard = true
				change_obstacle_state("Main Gate Guardhouse", "opened")
				sell_item("Shotgun shells", 1, "Stone")
				sell_item(".22 LR Ammunition", 1, "Stone")
				sell_item("EMP Shockwave Generator", 2, "Duncan") -- RG members can buy bigger bombs, as Duncan said.
				sell_item("Plasma Shockwave Emitter", 1, "Duncan")

				-- Allows Tux to buy Tier 2 skills
				Tamara_restock=true
				sell_item("Source Book of Sanctuary", 1, "Tamara")
				sell_item("Source Book of Virus", 1, "Tamara")
				sell_item("Source Book of Dispel smoke", 1, "Tamara")
				sell_item("Source Book of Energy Shield", 1, "Tamara")

				hide("node3", "node12")
			else
				if (get_town_score() > 29) then
					Npc:says(_"All in all, not half bad. But there are still things you need to do. Once you finish, then we can talk about it.")
				else
					Npc:says(_"I can't accept you into the Guard like this. Get going. There are still many things to do for you.")
				end
			end
		end,
	},
	{
		id = "node20",
		text = _"Francis wanted me to give you a data cube.",
		code = function()
			Npc:says(_"Ah, excellent, the list I asked for.")
			Npc:says(_"It figures he would ask someone to deliver it for him.")
			Tux:says(_"Why's that?")
			Npc:says(_"We had a little disagreement, Francis and I. He refused to accept our rule and do the task we gave him.")
			Npc:says(_"I had to persuade him myself.")
			Npc:says(_"Well, give me the data cube.")
			if (Tux:has_item_backpack("Data cube")) then
				show("node21", "node22", "node25", "node26")
			else
				show("node23", "node25", "node26")
			end
			hide("node20")
			push_topic("Deliver the cube")
		end,
	},
	{
		id = "node21",
		text = _"(Give the data cube to Spencer)",
		echo_text = false,
		topic = "Deliver the cube",
		code = function()
			Tux:says(_"Here, take it.")
			Tux:del_item_backpack("Data cube", 1)
			Npc:says(_"Thank you for the good work you have done. I think you deserve a small reward.")
			Tux:add_xp(100)
			Tux:add_gold(100)
			Tux:end_quest("Deliverance", _"I gave Spencer the data cube. He gave me a small reward.")
			data_cube_lost = false
			hide("node20", "node21", "node22", "node23", "node24", "node25", "node26")
			pop_topic("Deliver the cube")
		end,
	},
	{
		id = "node22",
		text = _"(Lie about the oversight of the data cube)",
		echo_text = false,
		topic = "Deliver the cube",
		code = function()
			next("node23")
		end,
	},
	{
		id = "node23",
		text = _"(Apologize for the oversight of the data cube)",
		echo_text = false,
		topic = "Deliver the cube",
		code = function()
			if (not data_cube_lost) then
				Tux:says(_"Oh, erm... Hehe, I think I forgot it somewhere.")
			else
				Tux:says(_"Hm, I still don't have the data cube.")
			end
			Npc:says(_"... What?")
			Npc:says(_"Then you better go and look for it. Don't waste my time, Linarian.")
			data_cube_lost = true
			hide("node21", "node22", "node23")
			pop_topic("Deliver the cube")
		end,
	},
	{
		id = "node24",
		text = _"(Lie about the loss of the data cube)",
		echo_text = false,
		topic = "Deliver the cube",
		code = function()
			Tux:says(_"I think I lost the data cube.")
			Npc:says(_"Come on, you've got to be kidding! ...")
			Npc:says(_"So I will call one minion for this job. You are very useless, unable to bring a small thing.")
			Npc:says(_"Get out of my sight!")
			Tux:end_quest("Deliverance", _"I lied about the data cube and now Spencer thinks I lost it. I won a little time for people in cryonic stasis. But, I couldn't stop Spencer's project.")
			Tux:add_xp(250)
			hide("node21", "node22", "node23")
			end_dialog()
		end,
	},
	{
		id = "node25",
		text = _"How did you persuade Francis? Did you beat him up?",
		topic = "Deliver the cube",
		code = function()
			Npc:says(_"No, nothing so violent. Let's just say I know more about Francis than he would like to remember.")
			Npc:says(_"Francis is someone who is very understandable. I just had to find the right words.")
			Npc:says(_"Anyway, we have nearly been close friends since.")
			hide("node25")
		end,
	},
	{
		id = "node26",
		text = _"Why didn't Francis want to do this task you gave him? What was it?",
		topic = "Deliver the cube",
		code = function()
			Npc:says(_"We had an unfortunate misunderstanding, so we had a very hard time talking together.")
			Npc:says(_"I wanted him to go through the people in cryonic freezing in the facility, and make a list of disposable ones and people unlikely to survive. This cube contains that list.")
			Tux:says(_"Disposable people? Unlikely to survive? Can't they just stay in cryonics indefinitely?")
			Npc:says(_"No. They take up a lot of space, and keeping them alive takes a lot of power, which is running out. Most of the people there are sick or dying anyway, which is why they're frozen in the first place. We can't afford to waste any resources.")
			Npc:says(_"We even had to confiscate the town cook's macrowave oven battery, which means we can't eat warm food anymore. We needed it to keep the town's defenses up.")
			Tux:update_quest("Deliverance", _"I learn incredible information. Apparently the data cube stored a list of people frozen in the cryonic facility. Spencer wants to dispose of some of them because keeping them alive uses up the town's power...")
			hide("node26") show("node24")
		end,
	},
	{
		id = "node29",
		text = _"I would like to talk about the Francis' cube.",
		code = function()
			Npc:says(_"Well, I'm listening to you. But you must be quick about it, I've no time to lose.")
			Npc:says(_"If you found the data cube, just give it.")
			if (Tux:has_item_backpack("Data cube")) then
				show("node21", "node22")
			else
				show("node23")
			end
			hide("node29")
			push_topic("Deliver the cube")
		end,
	},
	{
		id = "node37",
		text = _"I've heard Richard obtained new information on the town.",
		code = function()
			Npc:says(_"Yes, that's right, and in fact it might be crucial. As you may have heard, the MS Office is defended by a disruptor shield. They open it only to let out new armies of bots.")
			Npc:says(_"The data on the cube he obtained indicates the existence of a secret experimental facility in this region. Our findings suggest that they were testing some new form of disruptor shield for MS, so the shield can be controlled from that facility.")
			Npc:says(_"If the information is true, then you can defeat the control droid and disable the shield permanently via some console or terminal.")
			Npc:says(_"Then we should be able to get in.")
			Npc:says(_"We know that MS had a firmware update system, which could be used to propagate a malicious update to disable all bots. It is very alluring, but to perform this trick you need to hack the control droid, which is in the heart of the HF. To enter HF you would have to disable the disruptor shield.")
			Npc:says(_"This seems like a gift sent from the heavens. Cleaning the Hell Fortress is not going to be easy, though...")
			hide("node37") show("node38")
		end,
	},
	{
		id = "node38",
		text = _"I'd like to participate in this operation.",
		code = function()
			Npc:says(_"That's most kind of you to volunteer. So far, I've sent two scouts into the area. They have found the facility entrance and unlocked the gate.")
			Npc:says(_"That is a good sign, because it shows that the key combinations from the data cube were correct.")
			Npc:says(_"However, we lost contact with them shortly after they went inside. They also reported heavy bot resistance.")
			Npc:says(_"I'd be glad if you could take a look. But use the utmost care. We can't afford to lose another guard.")
			hide("node38") show("node39", "node40")
		end,
	},
	{
		id = "node39",
		text = _"OK. I'll be careful. But I'll do it.",
		code = function()
			Npc:says(_"Good. The base entrance is somewhat hidden in the caves to the northeast. Best to use the north gate out of town, then head east, and turn north again along the shore.")
			Npc:says(_"I wish you the best of luck for this operation. It might be that our survival depends on it. Don't wait for assistance.")
			Npc:says(_"Try to get control over the disruptor shield if you can. The control droid should be somewhere on the lowest level of the installation. Simply destroying the droid might not suffice in disabling the shield, however there should be some terminal around to control it.")
			Tux:add_quest("Opening access to MS Office", _"Spencer has revealed the information from the data cube evaluation to me. It seems there is an old military research facility north of the town. By defeating the control droid and using a nearby terminal, I should be able to control the disruptor shield at the facility. I can disable disruptor shield, fight my way through the Hell Fortress droids until I reach the main control droid and update it, thereby disabling all bots in the entire area around town in one fell swoop.")
			change_obstacle_state("DisruptorShieldBaseGate", "opened")

			-- Allows Tux to buy Tier 3 skills
			Tamara_restock=true
			sell_item("Source Book of Broadcast Blue Screen", 1, "Tamara")
			sell_item("Source Book of Broadcast virus", 1, "Tamara")
			sell_item("Source Book of Killer poke", 1, "Tamara")
			sell_item("Source Book of Invisibility", 1, "Tamara")
			sell_item("Source Book of Plasma discharge", 1, "Tamara")

			hide("node39", "node40")
		end,
	},
	{
		id = "node40",
		text = _"I don't feel like doing it now. I'd rather prepare some more.",
		code = function()
			Npc:says(_"Good. You should be well prepared if you intend to go.")
			Npc:says(_"Also, there is no need to hurry with this. After all, the installation is not running away, so it's best to take a cautious approach.")
			hide("node40")
		end,
	},
	{
		id = "node44",
		text = _"It's done. Your soldiers were killed, but I managed to reach a computer terminal that controls the shield. Access to the bot factory is now open, after I changed the password on the terminal so as to prevent the bots from enabling the shield again.",
		code = function()
			Npc:says(_"Good. We cannot help you much in this final mission, but I can tell you what our recon teams gathered behind the factory doors. You will enter a zone that used to be a MS Office.")
			Npc:says(_"They carried out some development there, and had part of their patching division and update management department. The actual factory is located behind the office.")
			Npc:says(_"With a bit of luck, you might not need to access it. We know they have their update server in the office.")
			Npc:says(_"If you can find it and get it to propagate a faulty update, this could suffice to stopping bots dead in their tracks.")
			Npc:says(_"Look for the entrance of the office in the crystal fields. I will send a message to the guards so they let you pass. Then you will be on your own.", "NO_WAIT")
			Npc:says(_"However I'll ask Richard to see if we can contact you as soon as you find the server so we know if you're alive and there is still hope, or if things are going to go back to the way they were before you were taken out of stasis sleep...")
			Npc:says(_"Good luck.")
			Tux:add_quest("Propagating a faulty firmware update", _"I can now enter Hell Fortress and find the upgrade server terminal. The fortress gates are in the Crystal Fields. Spencer told the guards to open the doors for me. He said he'd probably contact me when I found the server.")
			Npc:says(_"Wait. I have a weapon here. It is not an Exterminator, but should save your life in the Hell Fortress.")
            if (not has_met("Benjamin") or Benjamin_objective == "None") then
				Npc:says(_"I originally planned to give you a gun, but our gunsmith, Benjamin, did not finished any prototype.")
				Npc:says(_"We found this whip at the Hell Fortress. I'm not really sure what it was used for, but it should be a good weapon.")
    			Tux:add_item("Energy whip")
            elseif (Benjamin_objective == "damage") then
				Npc:says(_"Benjamin started trying to make laser pistols stronger by absorbing the heat, and he ended up creating plasma.")
				Npc:says(_"It deals much more damage than it claims to, because it blasts. A nice gun, but not a pistol, unfortunately.")
    			Tux:add_item("Electro Laser Rifle")
            elseif (Benjamin_objective == "firing") then
				Npc:says(_"Benjamin kept trying to make the laser pistol shoot faster, even if that compromised the damage each hit causes.")
				Npc:says(_"What he developed shoot so fast, that he could not make it stop. A nice gun, but not a pistol, unfortunately.")
    			Tux:add_item("Laser Pulse Cannon")
            elseif (Benjamin_objective == "plasma") then
				Npc:says(_"Benjamin gave up on laser pistols and started enhancing plasma pistols instead.")
				Npc:says(_"He could not make the bullet faster, but the damage went sky high. A nice gun, but not a pistol, unfortunately.")
    			Tux:add_item("Plasma Cannon")
			else
				Npc:says("ERROR, Spencer NODE 44, Benjamin_objective not handled")
    			Tux:add_item("Exterminator") -- as if.
			end

			if (difficulty_level() > 2) then -- difficulty neither easy, nor normal, nor hard
				Npc:says("ERROR, Spencer NODE 44, game difficulty not handled")
			end
			local dev_count = 2 - difficulty_level()
			if (not difficulty_level() == 0) then
				Tux:add_item("Plasma Shockwave Emitter", dev_count)
			end
			Npc:says(_"In the name of the Red Guard I wish you the best of luck!")
			hide("node44") show("node45")
		end,
	},
	{
		id = "node45",
		text = _"I will need some time to get myself ready before I clean up Hell Fortress.",
		code = function()
			Npc:says(_"You better be ready.")
			hide("node45")
		end,
	},
	{
		id = "node50",
		text = _"I found someone out in the desert.",
		code = function()
			Npc:says(_"Great, another mouth to feed.")
			Npc:says(_"What is this person's name?")
			hide("node50") show("node51")
		end,
	},
	{
		id = "node51",
		text = _"Tania",
		code = function()
			if (tux_has_joined_guard) then
				Npc:says(_"Well, since you are a guard member, I'll let you vouch for this Tania person.")
			else
				Npc:says(_"Well, we have enough food for now. I'll let this Tania person in.")
			end

			if (DocMoore:is_dead()) then
				Npc:says(_"I'd say you should take her straight away to Doc Moore, but he was found dead earlier.")
				Npc:says(_"You wouldn't happen to know anything about that, would you?")
				if (killed_docmoore) then
					show("node53")
				end
				show("node52", "node54")
			else
				Npc:says(_"You must take her straight away to Doc Moore. We can't have a disease breaking out.")
				Spencer_Tania_decision = "doc_moore"
				Tux:update_quest("Tania's Escape", _"Spencer said it was okay for Tania to enter the town, as long as she goes to see Doc Moore first thing. Now all I have to do is tell her and Pendragon.")
			end
			hide("node51")
		end,
	},
	{
		id = "node52",
		text = _"No, of course not.",
		code = function()
			Npc:says(_"Good.")
			Npc:says(_"I didn't think it was you, but you never know.")
			Npc:says(_"About your friend, she can come in provided that she pulls her weight around here.")
			Spencer_Tania_decision = "free"
			if (killed_docmoore) then
				Tux:update_quest("Tania's Escape", _"When I asked about Tania entering the town, Spencer confronted me about Doc Moore's death. I denied everything and he bought it! He says it is OK for Tania to enter the town: I should tell her and Pendragon.")
			else
				Tux:update_quest("Tania's Escape", _"When I asked about Tania entering the town, Spencer said Doc Moore was found dead! Oh, and Tania can enter the town. I should go tell her that.")
			end
			hide("node52", "node53", "node54")
		end,
	},
	{
		id = "node53",
		text = _"He and I had a disagreement, which we settled.",
		code = function()
			Npc:says(_"I am the law here. If you have a problem, you come to me.")
			if (tux_has_joined_guard) then
				Npc:says(_"I'm going to strip you of your membership in the Red Guard.")
				tux_has_joined_guard = false
				change_obstacle_state("Main Gate Guardhouse", "closed")
				Npc:says(_"Your friend can come in, but we will be watching the two of you closely.")
				Spencer_Tania_decision = "free"
				Tux:update_quest("Tania's Escape", _"When I asked about Tania entering the town, Spencer confronted me about Doc Moore's death. I told him the truth, and he kicked me out of the Red Guard. But he let Tania in, Now all I have to do is tell her and Pendragon.")
			else
				Npc:says(_"As the law, I pronounce you GUILTY of MURDER.")
				Npc:says(_"The punishment is death.")
				Tux:update_quest("Tania's Escape", _"When I asked about Tania entering the town, Spencer confronted me about Doc Moore's death. He found me guilty of murder, and sentenced me to death.")
				set_faction_state("redguard", "hostile")
				Tux:kill()
				end_dialog()
			end
			hide("node52", "node53", "node54")
		end,
	},
	{
		id = "node54",
		text = _"I killed him just to see what it was like. It was awesome.",
		code = function()
			Npc:says(_"You are a sociopath, and a danger to us all!")
			Npc:says(_"We must stop you before you kill again.")
			Tux:update_quest("Tania's Escape", _"When I asked about Tania entering the town, Spencer confronted me about Doc Moore's death. He found me too dangerous to live.")
			set_faction_state("redguard", "hostile")
			Tux:kill()
			hide("node52", "node53", "node54")
			end_dialog()
		end,
	},
	{
		id = "node60",
		text = "BUG, REPORT ME! Spencer node60 -- Post Firmware Update",
		code = function()
			Npc:says(_"*Fizz*")
			--; TRANSLATORS: can you hear me; %s = Tux:get_player_name()
			Npc:says(_"*Crackle*n you hear me? Hello? %s?", Tux:get_player_name())
			Tux:says(_"Spencer? How are you reaching me?")
			Npc:says(_"You did it! I just can't... I can't believe you actually did it!")
			Npc:says(_"The bots outside, they all just dropped! They're scrap metal!")
			Npc:says(_"We're saved!")
			Tux:says(_"Whew...")
			Npc:says(_"But wait! It gets more interesting: we can actually have this conversation face to face.")
			Npc:says(_"Stand by.")
			add_obstacle(0, 33.5, 51.05, 282) --"Close" Spencer's office door
			change_obstacle_type("spencer-opendoor", 321) --Make the obstacle standing for an open door invisible (321=pathblocker)
			end_dialog()
			show("node61")
		end,
	},
	{
		id = "node61",
		text = _"Hey!",
		code = function()
			Npc:says(_"This must be the main server room. It's safer than an interstellar bunker.")
			Npc:says(_"This is the source of all our suffering.")
			Npc:says(_"You are truly a living legend, Linarian. I don't know how you did it. I don't know how we can thank you.")
			Npc:says(_"You've given us life, and hope.")
			change_obstacle_state("ServerRoomDoor", "opened")
			hide("node61") show("node62", "node63", "node64")
		end,
	},
	{
		id = "node62",
		text = _"What's going on? How did you get in here?",
		code = function()
			Npc:says(_"When you uploaded the firmware, every security component for this area just blacked out. Every network in range was suddenly open.")
			Npc:says(_"Naturally, they were all running on the MegaSys operating system.")
			if Tux:has_met("Richard") then
				Npc:says(_"Richard is still back at the citadel; he's happier than a jaybird ever since we uncovered all this networking. He calls it a treasure.")
			else
				Npc:says(_"Our computer administrator at the citadel is as happy as he could be since all this secret networking popped up. He calls it a treasure.")
			end
			Npc:says(_"The firmware server was one of the things that were hidden in this network, and with all the obfuscations and defenses down, we not only could find it, but had full access.")
			Npc:says(_"But the most interesting thing we uncovered is a secret teleportation network. It was very well-guarded, we never even knew it existed, but now it's open for us to use.")
			Npc:says(_"My guess is, the corporate bastards who drove this sweatshop would use it to get in and out of work unnoticed. Grab the money and zap off to some island to relax.")
			Tux:update_quest("Propagating a faulty firmware update", _"Neutralizing the bot threat in the area wasn't the only thing I'd succeeded in doing: every MegaSys-based security product within range is completely broken now. A new teleportation network was discovered by the Red Guard, which is why Spencer is standing next to me right now.")
			hide("node62") show("node65")
		end,
	},
	{
		id = "node63",
		text = _"I couldn't have done any different.",
		code = function()
			Npc:says(_"You are far too modest. I doubt anyone alive right now could have done it.")
			Npc:says(_"But the work isn't done... Not even close. The entire galaxy is still at war.")
			Npc:says(_"You saved our little town, and you've proven that we can win this thing.")
			Npc:says(_"We can't rest now. It's going to be hard and dangerous, but the alternative is death for humanity.")
			Npc:says(_"As for you, please rest a little at our Town, and then come straight to me, so we can carry on.")
			Tux:update_quest("Propagating a faulty firmware update", _"*yawn* It wasn't easy, but the town is now safe. I still have a galaxy to save, though! I will only restock quickly at the town, and report again to Spencer.")
			Spencer_node66=true
			hide("node63", "node64")
		end,
	},
	{
		id = "node64",
		text = _"I only did it for fun, really.",
		code = function()
			Npc:says(_"... Oh, it doesn't matter.")
			Npc:says(_"I suppose no one's perfect...")
			Npc:says(_"What matters is that we're alive - those of us left, anyway - we have supplies, and we can take what we need from the Fortress now.")
			Npc:says(_"And, whether or not you intended to, you've proven that we have a chance against the bots. Something worth fighting for. Worth living for.")
			Npc:says(_"You'll probably be happy to know that the entire galaxy is pretty much your playground now, Linarian. You'll have all the bots in the world to play with, and lots of opportunities to be a hero.")
			Tux:says(_"Awesome!")
			Npc:says(_"Please, rest a little at our Town, and then come straight to me, so we can carry on.")
			Tux:update_quest("Propagating a faulty firmware update", _"I'm so cool. I saved a bunch of people and bashed a bunch of bots. And there's much more where both of those came from! I'm done here, I will quickly restock at town, and then it's time to go help the next dump. All I need to is ask Spencer where I should go next.")
			Spencer_node66=true
			hide("node63", "node64")
		end,
	},
	{
		id = "node65",
		text = _"Can I use this teleportation network to return to town?",
		code = function()
			if Tux:has_met("Richard") then
				Npc:says(_"Yes, I think you can. I'll contact Richard and tell him to ready the teleporter and link it back to the one in town.")
			else
				Npc:says(_"I believe you can, yes. I'll contact our computer expert and tell him to ready the teleporter and link it back to the one in town.")
			end
			Npc:says(_"But the way he explained it, this system is very limited by design: if the two teleporters are linked, using one will always take you to the other. So keep that in mind.")
			Npc:says(_"We'll stay here for a while longer. This place still needs to be investigated.")
			change_obstacle_type("59-Teleporter", 21)
			hide("node65")
		end,
	},
	{
		id = "node66",
		text = _"I'm ready. Just tell me what to do.",
		code = function()
			Npc:says(_"You've faced countless dangers so far. Are you sure you're willing to face more?")
			Tux:says(_"Bring it on!")
			Npc:says(_"That's exactly what I wanted to hear.")
			Npc:says(_"Now listen carefully, this is the plan...")
			Npc:says(_"We did some research and found out the MegaSys former president is still alive. And the personnel at our citadel was able to track him down! The only problem is the distance. It's not possible to teleport, but do not worry, we already thought on a solution!")
			Npc:says(_"We found a stratopod, it's supposed to travel short - intra-planetary - distances. Probably someone came here on business and I guess that things didn't turn out so well for them.")
			Tux:says(_"So I should take this \"stratopod\" and travel there to kick MS big boss for all the evil he brought us?")
			Npc:says(_"Hm. I was thinking on asking questions, but that will work, too! However, do you know how to pilot?")
			Tux:says(_"Erm...")
	        Npc:says(_"Thought so. A colleague from us will pilot, so you don't need to worry, he told me he is an ace at flying. He should already be on the craft, inclusive. Just walk on the stairs and it should be OK.")
			Npc:says(_"He didn't have any certificate but maybe I should just limit my worrying. I'm pretty sure with him piloting it'll be a successful flight.")
			Tux:end_quest("Propagating a faulty firmware update", _"The town is saved, but there's still a lot to do. I agreed to continue fighting the robot armies with the Red Guard.")
	        Npc:says(_"I'll drop you on the Landing Zone. Just move close to the ship, on the stairs, to board. It'll depart immediately.")
			Tux:add_quest("A New Mission From Spencer", _"In order to interrogate the former MegaSys president, I need to go to the HF Landing Zone and climb the stairs from the Stratopod there. The pilot is already inside, and he'll bring me to next area which needs me.\n\n I am not sure what expects me there, so I should bring along a secondary weapon, unique items, lots of ammo, recovery items, and money. Ah, mastering some skills like repair is also interesting.")

			-- Let's create the ship and open the gates - in case player want to explore further
			add_obstacle(62, 64.0, 37.0, 501)
			enable_event_trigger("All aboard!")
			change_obstacle_state("HF-RoboFreighter-Gate01", "opened")
			change_obstacle_state("HF-RoboFreighter-Gate02", "opened")
			Tux:teleport("HF-LandingZone")

			hide("node65", "node66")
			Spencer_can_die = true
			end_dialog()
		end,
	},
	{
		id = "node70",
		text = _"Are there members of the Red Guard called Bob and Jim?",
		code = function()
			Npc:says(_"They are still alive?! They probably need help!")
			Tux:says(_"Actually it seems that they are in pretty good shape.")
			Npc:says(_"Hm... I sent them to find a portal. Did they find it?")
			if (Tux_heard_Bob_and_Jim_story) then
				Tux:says(_"Yeah!")
				Npc:says(_"Excellent!")
			else
				Tux:says(_"Em... I'm not sure, but inside the room they were guarding I saw something like it.")
				Npc:says(_"So they found the portal.")
			end
			Npc:says(_"How did they survive?")
			Tux:says(_"Fortunately, the portal was inside a little fortress and they hid there.")
			Npc:says(_"Good to hear that. Their mission was not only to find the portal, but to stay there and keep guarding it. So they both survived and keep helping us.")
			Tux:says(_"Helping? What do you mean?")
			Npc:says(_"They prevent more bots from teleporting to our continent.")
			-- TODO:	Spencer will later give Tux a quest for bringing them supplies and a radio-device for establishing connection; also he will tell Tux prehistory of portal.
			Tux_told_Spencer_about_Bob_and_Jim = true
			hide("node70")
		end,
	},
	{
		id = "node99",
		text = _"I'll be going then.",
		code = function()
			if (not HF_FirmwareUpdateServer_Spencer) then
				Npc:says(_"See you later.")
			else
				Npc:says(_"Come back soon. There's much to be done.")
			end
			end_dialog()
		end,
	},
}
