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
PERSONALITY = { "Paranoid", "Fearful" },
MARKERS = {	QUESTID1 = "Propagating a faulty firmware update" },
PURPOSE = "$$NAME$$ aids Tux in the $$QUESTID1$$ quest by providing the means for Tux to access the Mega Systems factory.",
BACKSTORY = "$$NAME$$ helped start the Mega Systems company and was the chief software architect prior to The Great Assault.
	 $$NAME$$ has been living in an isolated bunker since The Great Assault and is unaware of other survivors. He has insight
	 into how The Great Assault may have started."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	EveryTime = function()
		if (not Tux:has_met("WillGapes")) then
			Npc:says(_"Don't come any closer! Or I'll turn you into scrap metal!")
			Npc:says(_"Wait... You're not a robot. Who are you? What are you doing here?")
			show("node1", "node2", "node3")
		elseif (Tux:has_quest("Gapes Gluttony")) and
		       (not Tux:done_quest("Gapes Gluttony")) then
			if (Tux:has_item_backpack("Lunch in a Picnic Basket")) then
					Tux:del_item_backpack("Lunch in a Picnic Basket")
				show("node9")
			else
				Npc:says(_"Have you brought me some food?")
				Tux:says(_"No, not yet.")
				Npc:says(_"Hurry... I'm starting to feel weak.")
			end
		elseif (WillGapes_generous) and
		       (Tux:get_hp() < 20) then
			Npc:says(_"Hey, are you all right? It looks like the robots are winning.")
			Npc:says(_"I found this in the First Aid kit. Maybe it will help.")
			Tux:add_item("Antibiotic")
			WillGapes_generous = false
		else
			Npc:says(_"I see you're still alive. Maybe the robots won't win after all.")
			if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				if (not Gapes_Uploaded_firmware) then
					Tux:says(_"I killed all bots, you can go outside now.")
					Npc:says(_"It's impossible. The bots are after me! I must stay here!")
					Tux:says(_"...Okay, but when you feel hungry, do leave and visit the town. You can find food there.")
					Npc:says(_"*stomach growls*")
					Npc:says(_"I'm not hungry! I swear!")
					Gapes_Uploaded_firmware=true
				else
					Npc:says(_"*stomach growls*")
					Npc:says(_"I'm not hungry yet! Nothing will make me leave this little fortress!", "NO_WAIT")
				end
			end
		end
		show("node99")
	end,

	{
		id = "node1",
		text = _"A friend...",
		code = function()
			--; TRANSLATORS: %s =  Tux:get_player_name()
			Tux:says(_"My name is %s, and I'm here to stop the robots!", Tux:get_player_name())
			Npc:says(_"Stop them!? You can't. It's too late. The robots have killed everyone.")
			hide("node1", "node2", "node3") show("node4", "node5", "node6")
		end,
	},
	{
		id = "node2",
		text = _"I am Luke Skywalker, a Jedi Knight, and I'm here to save you!",
		code = function()
			Npc:says(_"Huh? Am I dreaming?")
			Tux:says(_"Sorry, I've always wanted to say that.")
			Npc:says(_"Who are you really?")
			next("node1")
		end,
	},
	{
		id = "node3",
		text = _"Your worst nightmare! I'm here to punish you for your crimes against humanity.",
		code = function()
			Npc:says(_"Wait, Stop! I'm worth billions of circuits... I'll give you anything. Just don't kill me!")
			Npc:says(_"Who are you really?")
			next("node1")
		end,
	},
	{
		id = "node4",
		text = _"There are still some alive in the town.",
		code = function()
			Npc:says(_"Ha, they won't last long. The robots will destroy them all. It's hopeless!")
			hide("node4")
		end,
	},
	{
		id = "node5",
		text = _"But you're still alive?",
		code = function()
			Npc:says(_"Barely, all I've had to eat for the past few months were energy bars from the snack machine.")
			Npc:says(_"Now all that's left are military rations, and I would rather starve than eat those!")
			hide("node5") show("node7")
		end,
	},
	{
		id = "node6",
		text = _"Who are you?",
		code = function()
			Npc:says(_"My name is Will Gapes. I'm the chief software architect for MegaSys. I helped start the company.")
			Npc:says(_"Without my help this company would still be learning BASIC!")
			Npc:set_name("Will Gapes - MegaSys CSA")
			hide("node6") show("node8")
		end,
	},
	{
		id = "node7",
		text = _"Maybe I could find you some food?",
		code = function()
			Npc:says(_"If you bring me a well-cooked meal, I will tell you about Hell's Fortress.")
			Npc:says(_"Trust me, you won't survive long in there without my help.")
			Tux:add_quest("Gapes Gluttony", _"I found a man who is starving. He is willing to tell me about Hell's Fortress if I will bring him some food. I should speak to Michelangelo about this.")
			hide("node7")
		end,
	},
	{
		id = "node8",
		text = _"So these murderous robots are your creation?",
		code = function()
			Npc:says(_"NO! It was the company's fault!")
			Npc:says(_"I told them the upgrade wasn't ready. It hadn't been fully tested.")
			Npc:says(_"They wouldn't listen to me. They called me a fool! ME!?")
			Npc:says(_"Now they are all dead. Serves them right too!")
			hide("node8")
		end,
	},
	{
		id = "node9",
		text = _"I've brought you some food.",
		code = function()
			Npc:says(_"It's about time! I'm starving.")
			Npc:says(_"Oh, this is delicious!")
			Npc:says(_"[b]om nom nom[/b]")
			Tux:says(_"Um...You're welcome?")
			Npc:says(_"...")
			Tux:says(_"Now, how about some information?")
			Npc:says(_"OK, so what do you want to know?")
			Tux:end_quest("Gapes Gluttony", _"I brought the full picnic basket to Gapes, and he tore into it like a wild animal. It was a disgusting sight, but thankfully it ended quickly.")
			Tux:del_item_backpack("Lunch in a Picnic Basket")
			Tux:add_item("Empty Picnic Basket")
			WillGapes_generous = true
			hide("node9") show("node11", "node12")
		end,
	},
	{
		id = "node11",
		text = _"Tell me about this upgrade. Is that why all the robots are killing people?",
		code = function()
			Npc:says(_"I'm afraid so... It wasn't finished yet.")
			Npc:says(_"The upgrade was supposed to revolutionize the world, but instead, it seems to have destroyed it.")
			hide("node11")
		end,
	},
	{
		id = "node12",
		text = _"How can I shut down the factory?",
		code = function()
			Npc:says(_"You must deactivate the energy supply.")
			Npc:says(_"But the robots have sealed the doors shut.")
			hide("node12") show("node13")
		end,
	},
	{
		id = "node13",
		text = _"Is there another way to get in?",
		code = function()
			Npc:says(_"You might be able to get guest access.")
			Npc:says(_"It was created to give clearance to the tourists when the factory was first built.")
			Npc:says(_"Because the program hasn't been used in years, maybe the robots haven't disabled it.")
			Npc:says(_"But you will have to find some other way into the headquarters. Guests were never given clearance.")
			Npc:says(_"However, owners are.")
			Npc:says(_"I guess that is all this otherwise worthless piece of paper is useful for anymore.")
			Tux:says(_"Paper?")
			Npc:says(_"Sheet of cellulose.")
			Npc:says(_"Here, take it.")
			Tux:add_item("MS Stock Certificate", 1)
			Tux:update_quest("Propagating a faulty firmware update", _"Will Gapes gave me his MS Stock Certificate so that I can gain access to the MegaSys Factory.")
			hide("node13")
		end,
	},
	{
		id = "node99",
		text = _"I'll be going then.",
		code = function()
			Npc:says(_"Be careful!")
			end_dialog()
		end,
	},
}
