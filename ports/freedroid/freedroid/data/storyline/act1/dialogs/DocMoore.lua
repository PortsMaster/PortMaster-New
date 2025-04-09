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
PERSONALITY = { "Folksy", "Knowledgeable", "Friendly" },
MARKERS = { NPCID1 = "Bender" },
PURPOSE = "$$NAME$$ will heal Tux for free and also provides information about medical equipment in the game.",
BACKSTORY = "$$NAME$$ provides medical services to the town, but only if injuries are \'Not Self-Inflicted\'.",
RELATIONSHIP = {
	{
		actor = "$$NPCID1$$",
		text = "$$NAME$$ refuses to help $$NPCID1$$ for ignoring his medical advice."
	},
}
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		if (not HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
			show("node0")
		else
			show("DocMoore_post_firmware_update_firsttime")
		end
	end,

	EveryTime = function()
		if (Tux:has_quest("Bender's problem")) and
		   (Tux:has_met("DocMoore")) and
		   (not Tux:done_quest("Bender's problem")) then
			show("node2")
		end

		if (Spencer_Tania_decision == "doc_moore") and
		(not DocMoore_Tania_OK) then
			DocMoore_Tania_OK = true
			show("node25")
		end

		if (Tux:has_item_backpack("Strength Pill")) then show("node50") end
		if (Tux:has_item_backpack("Dexterity Pill")) then show("node51") end
		if (Tux:has_item_backpack("Code Pill")) then show("node52") end

		if (Tux:has_item_backpack("Brain Enlargement Pill")) then show("node54") end
		if (Tux:has_item_backpack("Diet supplement")) then show("node55") end
		if (Tux:has_item_backpack("Antibiotic")) then show("node56") end
		if (Tux:has_item_backpack("Doc-in-a-can")) then show("node57") end

		show("node99")

		if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) and
		   (Tux:has_met("DocMoore")) and
		   (not DocMoore_post_firmware_update_congrats) then
			next("DocMoore_post_firmware_update")
			return -- next() node is executed immediately after EveryTime, would look odd if EveryTime contains Npc:says
		end

		if (Tux:get_hp_ratio() < 0.1) then
			Npc:says(_"You look gravely injured.")
			Npc:says(_"I will help you.")
			Tux:says(_"I...")
			Npc:says(_"It's ok, you'll be fine soon.")
			Npc:says(_"A little spray here...")
			Npc:says(_"An injection there...", "NO_WAIT")
			Tux:says(_"OW!")
			Npc:says(_"Now, swallow this pill.")
			Tux:says(_"*glup*")
			Npc:says(_"Ok, you are fixed now.")
			Tux:says(_"Oh, thank you!")
			Npc:says(_"Take better care of yourself, Linarian.")
			Tux:heal()
		end

		if (Tux:get_hp_ratio() < 0.2) then
			Npc:says(_"You don't look too good...")
			Npc:says(_"I can help you if you want.")
		elseif (Tux:get_hp_ratio() < 0.4) then
			Npc:says(_"You should take better care of yourself out there.")
		end

		if (Npc:get_rush_tux()) then
			Npc:set_rush_tux(false)
		end

		if (Tux:has_met("DocMoore")) and
		   (Tux:has_item("Rubber duck")) and
		   (not DocMoore_not_seen_rubber_duck_lie) then
			Npc:says(_"Oh, did you by any chance see a bright yellow item made out of polyvinyl chloride?")
			show("node42", "node43")
		end

		if (Bender_go_talk_to_doc) and
		   (not Tux:done_quest("Bender's problem")) then
			show("DocMoore_post_firmware_update_bender")
		end
	end,

	{
		id = "node0",
		text = _"Hello!",
		code = function()
			Npc:says(_"Hello. I'm Doc Moore. I'm the medic of this town. I don't believe we've met?")
			--; TRANSLATORS: %s = Tux:get_player_name()
			Tux:says(_"I'm %s.", Tux:get_player_name())
			Npc:says(_"Um, what are you? Some kind of overgrown penguin?")
			Tux:says(_"I'm a Linarian.")
			Npc:says(_"Oh, I vaguely remember reading something about Linarian biology back in my university days...")
			Npc:says(_"Wait... did you come from outside of town?")
			Tux:says(_"Yes, I had to fight my way here through a bunch of bots.")
			Npc:says(_"Oh my!")
			Npc:says(_"Well, I should be able to heal you if you get hurt.")
			if (Tux:has_quest("Bender's problem")) then
				show("node2")
			end
			Npc:set_name("Doc Moore - Medic")
			hide("node0") show("node1", "node3", "node10")
		end,
	},
	{
		id = "node1",
		text = _"Do you also sell medical equipment?",
		code = function()
			Npc:says(_"Yes. Here is what I can offer today.")
			trade_with("DocMoore")
			hide("node1") show("node40")
		end,
	},
	{
		id = "node2",
		text = _"Doc, I took some of those brain enlargement pills...",
		code = function()
			if (DocMoore_healed_tux) then
				Npc:says(_"Sorry, but I already gave you some medical help.")
				Npc:says(_"To poison yourself again, that's entirely your own business and I'm not responsible.")
				Npc:says(_"As far as I am concerned, in this town everyone gets everything equally.")
				show("node20")
			else
				Npc:says(_"Oh no, not another one. Those pills are almost pure biological waste.")
				Npc:says(_"Taking that stuff almost always equals delayed suicide.")
				Npc:says(_"Now, take this antidote. It should remove the dangerous substances within your body.")
				Npc:says(_"But remember, I'll only give you this help once, because you didn't know the effects.")
				Npc:says(_"Should you take that junk again, I won't feel responsible for what happens to you any more.")
				DocMoore_healed_tux = true
				Tux:update_quest("Bender's problem", _"The doctor was easily fooled. I have the pills that Bender needs.")
				Tux:add_item("Brain Enlargement Pills Antidote", 1)
			end
			hide("node2")
		end,
	},
	{
		id = "node3",
		text = _"Doctor, how can I keep healthy and alive?",
		code = function()
			Npc:says(_"Always remember L-I-F-E") -- @TODO: how do we translate this? german "LEBEN" has 5 letters for example..
			Npc:says(_"L - Look at your health status regularly.")
			Npc:says(_"I - Ingest cold water if you are overheating.")
			Npc:says(_"F - Flee if you cannot fight.")
			Npc:says(_"E - Evacuate to the town if you cannot flee.")
			hide("node3")
		end,
	},
	{
		id = "node10",
		text = _"Can you fix me up?",
		code = function()
			Npc:says(_"Sure, as the only doctor of this slowly growing community, I take responsibility for everyone's health.")
			if (not DocMoore_asked_self_damage) and
			   (not HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				Npc:says(_"However, self-inflicted damage might be exempted from this rule in some cases...")
				show("node11")
			end
			if (Tux:get_hp_ratio() == 1) then
				Npc:says(_"You seem to be in excellent health, there is nothing I can do for you right now.")
			else
				Npc:says_random(_"There, it's done. You're completely fixed. You can go now.",
								_"You need to keep better care of yourself. You're completely fixed. You can go now.")
				Tux:heal()
			end
			hide("node0")
		end,
	},
	{
		id = "node11",
		text = _"What do you mean, self-inflicted damage?",
		code = function()
			if (guard_follow_tux) or
			   (tux_has_joined_guard) then
				Npc:says(_"Well, you see that Bender character on my doorstep?")
			else
				Npc:says(_"Well, you see that idiotic Bender character on my doorstep?")
			end
			Tux:says(_"What can you tell me about Bender?")
			Npc:says(_"Bender asked my advice about some pills he saw advertised in an e-mail. I told him not to buy them.")
			Npc:says(_"But guess what? He bought and took the stupid pills anyway, and then he came back to me to fix him.")
			Npc:says(_"If he, or anyone, is going to completely disregard my medical advice, and then think they are going to get my medical supplies, then they are wrong.")
			Npc:says(_"He won't get anything from me anymore. It would be unfair to the community to waste all the supplies on him, and that's my final word on that.")
			DocMoore_asked_self_damage = true
			hide("node11")
		end,
	},
	{
		id = "node20",
		text = _"Doc... I really want the antidote.",
		code = function()
			Npc:says(_"No! I am not giving it to you. Forget about it.")
			hide("node20") show("node21", "node30")
		end,
	},
	{
		id = "node21",
		text = _"My patience is running out. Give me the antidote. Now.",
		code = function()
			Npc:says(_"No! Over my dead body.")
			hide("node21") show("node22", "node30")
		end,
	},
	{
		id = "node22",
		text = _"Your wish is my command!",
		code = function()
			Npc:says(_"Huh? What?")
			Tux:says(_"Humans... You are so interesting. I always wanted to know exactly how much blood you have.")
			Npc:says(_"Don't do this. Don't do this.")
			Tux:says(_"Prepare, Doctor. The experiment begins.")
			Npc:says(_"Don't do this! DON'T DO THIS!")
			Npc:says(_"AAAAAAAAAAAA!")
			Tux:says(_"Ugh. Human blood is disgusting. At least four liters. I feel sick.")
			Npc:says(_" . . .")
			Tux:says(_"I guess this means I get to inherit all your stuff. I hope you don't mind if I take everything?")
			Npc:says(_" . . .")
			Tux:says(_"Good. I am very glad not to hear a disapproval.")
			Npc:says(_" . . .")
			killed_docmoore = true
			Npc:drop_dead()
			Tux:add_item("Diet supplement",15)
			Tux:add_item("Diet supplement",15)
			Tux:add_item("Doc-in-a-can",10)
			Tux:add_item("Antibiotic",10)
			Tux:add_item("Laser Scalpel",1)
			Tux:add_item("Doc-in-a-can",10)
			Tux:add_item("Antibiotic",10)
			Tux:add_item("Brain Enlargement Pills Antidote",1)
			hide("node22", "node10", "node11", "node50", "node51", "node52", "node55", "node56", "node57")
		end,
	},
	{
		id = "node25",
		text = _"Is Tania OK?",
		code = function()
			Npc:says(_"Haven't you heard of doctor-patient confidentiality?")
			Tux:says(_"Ummm...")
			Npc:says(_"No worries. She is fine.")
			Tania:heal()
			hide("node25")
		end,
	},
	{
		id = "node30",
		text = _"Forget it. Getting the antidote is not worth the effort.",
		code = function()
			Npc:says(_"I am not giving it to you, and that won't change.")
			hide("node21", "node22", "node30")
		end,
	},
	{
		id = "node40",
		text = _"May I buy some medical equipment?",
		code = function()
			Npc:says(_"Sure. Here is what I can offer today.")
			trade_with("DocMoore")
		end,
	},
	{
		id = "node42",
		text = _"Hmm. I cannot remember.",
		code = function()
			Tux:says(_"I'm sorry.")
			Npc:says(_"No problem. Thanks anyway.")
			DocMoore_not_seen_rubber_duck_lie = true
			hide("node42", "node43")
		end,
	},
	{
		id = "node43",
		text = _"I think I did.",
		echo_text = false,
		code = function()
			Tux:says(_"Hmm... Yellow, bright, PVC...?")
			Tux:says(_"I think I did.")
			Tux:says(_"Do you mean this rubber duck by any chance?")
			Npc:says(_"Ooh, you found it.")
			Tux:says(_"Here, take it if it's yours.")
			Npc:says(_"Thanks.")
			Npc:says(_"Take this healthy drink as reward.")
			Tux:says(_"Looks.. erm... interesting...")
			Tux:says(_"Thank you. I am sure it ... can be quite useful in some situations.")
			Tux:add_item("Doc-in-a-can", 1)
			Tux:del_item("Rubber duck")
			hide("node42", "node43")
		end,
	},
	{
		id = "node50",
		text = _"What can you tell me about Strength Pills?",
		code = function()
			hide("node50") next("node53")
		end,
	},
	{
		id = "node51",
		text = _"What can you tell me about Dexterity Pills?",
		code = function()
			hide("node51") next("node53")
		end,
	},
	{
		id = "node52",
		text = _"What can you tell me about Code Pills?",
		code = function()
			hide("node52") next("node53")
		end,
	},
	{
		id = "node53",
		code = function()
			Npc:says(_"Those pills are only one variant of a fantastic scientific breakthrough that happened shortly before the Great Assault.")
			Npc:says(_"Three kinds of enhancement pills were developed. One for strength, one for dexterity and one for programming abilities.")
			Npc:says(_"These pills work on a nanotechnological basis with small machines connecting to your muscle and nerve tissue.")
			Npc:says(_"The machines connect together and form some inorganic artificial tissue that has been optimized for certain qualities.")
			Npc:says(_"Since this invention only came about shortly before the Great Assault, these pills are now very rare.")
			Npc:says(_"But if you should get them, even better, because the effects are permanent, and as far as we can tell, there aren't any side effects!")
			hide("node53")
		end,
	},
	{
		id = "node54",
		text = _"What can you tell me about Brain Pills?",
		code = function()
			if (DocMoore_healed_tux) then
				Npc:says(_"I already warned you about those!")
			end
			Npc:says(_"Those pills are almost pure biological waste! They are sold to stupid ignorant gullible people. Never EVER take one.")
			hide("node54")
		end,
	},
	{
		id = "node55",
		text = _"What can you tell me about Diet supplements?",
		code = function()
			Npc:says(_"Have you tasted the army snacks that the cook, Michelangelo, has been handing out?")
			if (Michelangelo_been_asked_for_army_snacks) then
				Tux:says(_"Yes, those were horrible. They had a nice color though.")
				Npc:says(_"The dye used to make that color is a known carcinogen.")
			else
				Tux:says(_"No, should I?")
				Npc:says(_"Not if you can avoid it.")
			end
			Npc:says(_"Well, unlike the army snacks, the Diet Supplements actually have a slight nutritional benefit.")
			Npc:says(_"After taking one, your health should improve slightly.")
			hide("node55")
		end,
	},
	{
		id = "node56",
		text = _"What can you tell me about Antibiotics?",
		code = function()
			Npc:says(_"Basically it is bottled up poison made by bacteria.")
			Tux:says(_"And that is good for me?")
			Npc:says(_"Yep. It kills the bacteria that want to kill you. It improves your health significantly.")
			hide("node56")
		end,
	},
	{
		id = "node57",
		text = _"What is a Doc-in-a-can?",
		code = function()
			Npc:says(_"It is a device that releases millions of short-lived nanobots that swarm all over your body inside and out repairing and fixing almost all but the most serious wounds.")
			Tux:says(_"Wouldn't long-lived nanobots work better?")
			Npc:says(_"They found that long-lived nanobots evolve self-replication and act like a cancer. A cancer of gray goo that eats everything.")
			Npc:says(_"Several planets were made uninhabitable before they figured that one out.")
			hide("node57")
		end,
	},
	{
		id = "DocMoore_post_firmware_update_firsttime",
		text = _"Hello!",
		code = function()
			next("DocMoore_post_firmware_update")
			hide("DocMoore_post_firmware_update_firsttime")
			show("node1", "node3")
		end,
	},
	{
		id = "DocMoore_post_firmware_update",
		text = "BUG REPORT ME! DocMoore node DocMoore_post_firmware_update",
		echo_text = false,
		code = function()
			Npc:says(_"Sorry, the doctor is out- oh! It's you! How can i help you?")
			Npc:says(_"Do you need Antibiotics? No, of course not, you look like you're in need of some radiotherapy!")
			Tux:says(_"No, I'm fine, thank you...")
			Npc:says(_"Are you sure? Anything for you! You're a hero!")
			DocMoore_post_firmware_update_congrats = true
			show("DocMoore_post_firmware_update_humble", "DocMoore_post_firmware_update_bruised")
			hide("node2", "node11", "node20", "node21", "node22", "node30", "node10") -- hide nodes related to Bender's quest and "fix me up"
		end,
	},
	{	id = "DocMoore_post_firmware_update_bruised",
		text = _"Well, now that you mentioned it, I am a little bruised.",
		code = function()
			Npc:says(_"Well, let's take a look at you...")
			if (Tux:get_hp_ratio() < 0.3) then
				Npc:says(_"Yes, I can see - you've been through some harshness.")
				Npc:says(_"But we can fix that. Under my care, you'll be as good as new! Now take this, put it in your mouth and count to 30.")
				--; TRANSLATORS: "mrn" = one, "tww" = two, "thow" = three + ow
				Tux:says(_"Mrn... Tww... ThOW!")
				Npc:says(_"Just a little shot while you were waiting!")
				Npc:says(_"Ok, you are fixed now.")
				Tux:says(_"Oh, thank you!")
				Tux:heal()
			else
				Npc:says(_"Hmm... Yes... And here...")
				Npc:says(_"I see. Well, a preliminary physical examination doesn't show anything very wrong, but we can't be too sure!")
				Tux:says(_"What are you doing? Why are you putting on a glove?")
				Npc:says(_"Calm down, I do this all the time. Now, relax your muscles...")
				Tux:says(_"Whoa! Whoa- thanks, doc, but I'm feeling much better now! Really!")
				Npc:says(_"Oh- well, great!")
				Npc:says(_"Funny, they always say that...")
			end
			hide("DocMoore_post_firmware_update_bruised")
			show("node10")
		end,
	},
	{	id = "DocMoore_post_firmware_update_humble",
		text = _"I only did what I had to do.",
		code = function()
			Npc:says(_"And what no one thought could be done!")
			--; TRANSLATORS: %s = Tux:get_player_name()
			Npc:says(_"Listen, %s, you saved everyone's lives here - the least I could do as a doctor is to look out for yours.", Tux:get_player_name())
			hide("DocMoore_post_firmware_update_humble")
		end,
	},
	{	id = "DocMoore_post_firmware_update_bender",
		text = _"Have you heard anything from Bender?",
		code = function()
			Npc:says(_"Bender?")
			Npc:says(_"Oh, him! That fool who took the brain growth pills!")
			Tux:says(_"Yes. I guess they really should be called brain growth pills. He's still very sick. ")
			Npc:says(_"But I can't just give him the antidote.")
			Tux:says(_"Why not?")
			Npc:says(_"Well, that would be unfair. It would also be unwise, and... And...")
			Npc:says(_"Oh, darn it, why not indeed! The worst is past us! He can have all the antidote he wants. I'm in such a good mood, I haven't felt so cheerful since my first autopsy back in medical school!")
			Tux:says(". . .")
			Npc:says(_"Of course, I mean the celebrations that followed the autopsy. Everyone had passed the exam.")
			Tux:says(_"Yes. Of course.")
			Tux:end_quest("Bender's problem", _"It is done - I talked to Doc Moore, and he will happily give Bender the antidote.")
			hide("DocMoore_post_firmware_update_bender")
		end,
	},
	{
		id = "node99",
		text = _"See you later.",
		code = function()
			if (not HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				Npc:says_random(_"See you later.",
								_"Keep healthy!")
			else
				Npc:says_random(_"Take good care of yourself - I'm taking a vacation!",
								_"It's a wonderful day. Thank you.")
			end
			end_dialog()
		end,
	},
}
