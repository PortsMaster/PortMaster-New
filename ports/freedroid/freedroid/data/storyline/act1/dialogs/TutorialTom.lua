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
PERSONALITY = { "Helpful" },
PURPOSE = "$$NAME$$ guides the player through the various aspects of playing the game."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

-- helper functions for the quickmenu thingy

local function tutorial_chests_and_armor_and_shops()
	tut_tux_items_entered = true
	TutorialTom_Tux_found_all_items = true -- we could open all doors too...
	tut_tux_chest_entered = true
end

local function tutorial_melee_combat()
	tutorial_chests_and_armor_and_shops()

	tut_tux_melee_entered = true
	Tux:add_item("Normal Jacket")
	Tux:add_item("Improvised Buckler")
	Tux:add_item("Shoes")
	Tux:add_item("Worker Helmet")
end

local function tutorial_abilities()
	tutorial_melee_combat()

	tut_tux_terminal_entered = true
end

local function tutorial_upgrade_items_and_terminal()
	tutorial_abilities()
end

local function tutorial_hacking()
	tutorial_upgrade_items_and_terminal()

	tut_tux_takeover_entered = true
end

local function tutorial_ranged_combat()
	tutorial_hacking()

	tut_tux_glass_entered = true
end

local items_up = {"Entropy Inverter", "Tachyon Condensator", "Antimatter-Matter Converter", "Superconducting Relay Unit", "Plasma Transistor"}

-- actual dialog

return {
	FirstTime = function()
		-- initialize
		TutorialTom_doors = {"TutorialEntry", "TutorialZigzag1", "TutorialZigzag2", "TutorialZigzag3", "TutorialZigzag4"}
		TutorialTom_doors2 = {TutorialTom_doors[1], TutorialTom_doors[2], TutorialTom_doors[3], TutorialTom_doors[4], TutorialTom_doors[5], "TutorialEquipOut", "TutorialMeleeOut", "TutorialDoor", "TutorialGlasswallDoor", "TutorialStorage", "TutorialTakeover", "TutorialExit1"}
		ranged_combat = {"Normal Jacket", "Big kitchen knife", "Shoes", "Standard Shield", "Worker Helmet"}
		-- to avoid excessive map validator waypoint errors, map starts with all relevant doors open, so we need to close them here
		for var in ipairs(TutorialTom_doors2) do
			change_obstacle_state(TutorialTom_doors2[var], "closed")
		end
		-- we also need remove all tux skills, except use weapon
		Tux:downgrade_program("Hacking")
		Tux:downgrade_program("Repair equipment")
		Tux:downgrade_program("Emergency shutdown")
		tut_hack_time=0
		-- done initializing
		Npc:set_name("Tutorial Tom")
		display_console_message(string.format(_"Met [b]%s[/b]!", Npc:get_translated_name()))
	end,

	EveryTime = function()
		if (TutorialTom_start_chat) then --initiated by TutorialTerminal.dialog
			Npc:says(_"Well done.")
			Npc:says(_"Now follow me to the next section. You will learn how to hack bots.")
			TutorialTom_start_chat = false -- don't show this again
			Npc:teleport("TutorialTomPostTerminalTeleportTarget")
			Npc:set_destination("TutorialTom-Takeover")
			change_obstacle_state("TutorialTakeover", "opened") --door
			end_dialog()
		end

		if (partner_started()) and
		   (TutorialTom_glasswall_smashed) and
		   (cmp_obstacle_state("TutorialWall", "broken")) and
		   (not TutorialTom_glasswall_done) then
			-- wall section, shown if tux destroyed the wall by hand
			Npc:says(_"Great, you figured out how deal with this obstacle.")
			Npc:says(_"Let's proceed.")
			TutorialTom_glasswall_done = true
			if (not TutorialTom_Tux_PastWall) then
				TutorialTom_Tux_PastWall = true
				Npc:set_destination("TutorialTom-Ranged")
			end
			end_dialog()
		end

		if (not cmp_obstacle_state("TutorialWall", "broken")) then
			--to avoid regressions with code above
			if (partner_started()) then
				Npc:says(_"Hi Linarian, I've been expecting you. My name is Tutorial Tom.")
				Npc:says(_"Long stasis sleep unfortunately has the side effect of temporary memory loss, sometimes even for simple ordinary every day things.")
				Npc:says(_"So let's start with the basics, shall we?")
				show("node1", "node7", "node80")
				Npc:set_rush_tux(false)
			elseif (Tux:has_quest("Tutorial Movement")) and
				   (not TutorialTom_talk_to_tom_EveryTime) then
				-- only once
				TutorialTom_talk_to_tom_EveryTime = true
				Npc:says(_"Glad to see you figured out the quest log!")
			elseif (Tux:has_quest("Tutorial Movement")) and
			       (TutorialTom_move_black) and
			       (not TutorialTom_sprinting) then
				TutorialTom_sprinting = true
				Npc:says(_"Speaking of moment, you can also [b]sprint[/b] by holding the [b]control key[/b].")
				Tux:update_quest("Tutorial Movement", _"Apparently I can sprint if I hold down the control key as I move. This might help if I get in a tight spot.")
				Npc:says(_"This distance is determined by your yellow stamina bar; the more you have, the farther you can run without becoming winded.")
			end
		end

		if (tut_tux_items_entered) and
		   (not TutorialTom_Tux_found_all_items) then
			show("node5")
		end

		if (not tut_tux_melee_entered ) then

			if (tut_tux_chest_entered) and
			   (not tut_item_chest_opened) then
				show("node10")
			elseif (tut_item_chest_opened) then
				hide("node10")
				show("node11")
			end

			if (Tux:has_item("Normal Jacket")) or
			   (Tux:has_item("Improvised Buckler")) or
			   (Tux:has_item("Shoes")) or
			   (Tux:has_item("Worker Helmet")) then
				hide("node11")
				Npc:says(_"Excellent, I see you already took on the armor that was in the box.")
				if (not armor_node_one) then
					show("node12")
				end
				if (not armor_node_two) then
					show("node13")
				end
			end
		end

		if (tut_tux_melee_entered) and
		   (not tut_tux_glass_entered) then
			-- tux is still in bot melee area
			show("node24")
		end

		if (tut_tux_terminal_entered) then
			hide("node24")
		end

		if (cmp_obstacle_state("TutorialDoor", "opened")) and
		   (tut_tux_takeover_entered) and
		   (not TutorialTom_node50_done) then
			show("node50")
		end

		if (tut_tux_glass_entered) then
			show("node70")
		end

		if (TutorialTom_Tux_PastWall) then
			hide("node70") show("node30")
		end

		if (Tux:done_quest("Tutorial Hacking")) and
		   (not tut_tux_glass_entered) and
		   (not TutorialTom_hide_71) then
			show("node71")
		else
			hide("node71")
		end

		if (tut_tux_glass_entered) then
			hide("node55", "node57")
		end

		if (tut_tux_ranged_entered) and
		   (not tux_node38_done) then
			show("node38")
		end

		if (Tux:has_quest("Tutorial Shooting")) then
			hide("node30") --avoid assigning the quest twice etc..
		end

		show("node99")
	end,

	{
		id = "node1",
		text = _"Yes, it would be most kind of you. I don't remember anything.",
		code = function()
			Npc:says(_"You Linarians keep a quest [b]Log[/b] where you write down key bits of information.")
			Npc:says(_"When you aren't speaking with someone, you can open it up or close it by pressing the [b]q key[/b].")
			Npc:says(_"I'll assign you a new quest, so you can try it out. Once you are done, [b]left click[/b] on me.")
			if (not Tux:has_quest("Tutorial Movement")) then
				Tux:add_quest("Tutorial Movement", _"To talk to someone, left click on them. You can talk to any friendly bot or person. Friendly people and bots have a green bar above them. Press the 'q' key to open or close the quest log. Left click back on Tutorial Tom to learn more!")
			end
			display_big_message(_"Press 'q' for Quests!")
			hide("node1", "node7", "node80") show("node2", "node3", "node4", "node8")
			if (tut_tux_items_entered) and
			   (not TutorialTom_Tux_found_all_items) then
				show("node5")
			end
			end_dialog()
		end,
	},
	{
		id = "node2",
		text = _"What can you tell me about finding my way in the world?",
		code = function()
			Npc:says(_"You Linarians see the world similar to the Heads Up Displays, or [b]HUD[/b], used in computer games.")
			Npc:says(_"Linarians, like all birds, have a remarkable internal sense of direction. Apparently your HUD has a [b]compass[/b], represented by four red arrows in the upper right corner with North marked on it.")
			Npc:says(_"You can temporarily disable this compass by pressing the 'tab' key.")
			Tux:update_quest("Tutorial Movement", _"I learned the four red arrows in the upper-right of my HUD is a compass with north marked on it. I can toggle it using the 'tab' key.")
			Npc:says(_"Rumor is there was a device Linarians used to remember every place they had been, called an [b]automap[/b].")
			Npc:says(_"Although, you don't currently have such a device, you might find someone with nanotechnology skills to make one.")
			Tux:says(_"I'll keep that in mind.")
			hide("node2")
		end,
	},
	{
		id = "node3",
		text = _"My limbs don't seem to want to work properly. Can you help me with that?",
		code = function()
			Npc:says(_"Ah yes, movement. It's second nature to us humans, but our research with you in the past showed that your brain seems to work more like a computer.")
			Npc:says(_"To move somewhere, you have to [b]left click[/b] on the destination on your HUD.")
			Npc:says(_"If you can go there, you will do so.")
			Npc:says(_"Now try to move to the red dot to the north. Then to the black grating to the east, and then talk to me again.")
			Tux:update_quest("Tutorial Movement", _"I'm supposed to left click anywhere to move to a location. If I can figure out a way, I will move there automatically. Tom wants me to first try to move to the red dot to the North.")
			TutorialTom_learn_to_walk = true
			hide("node3")
			end_dialog()
		end,
	},
	{
		id = "node4",
		text = _"What else makes me different as a Linarian?",
		code = function()
			Npc:says(_"As a Linarian, you have some special abilities that no human does: Linarians can translate programming source code into something like magic.")
			Npc:says(_"However, using these [b]Programs[/b], adversely affect your body temperature, which you must regulate.")
			Npc:says(_"But you normally have a special program called [b]Emergency Shutdown[/b], which freezes your motions for several seconds but significantly cools your body.")
			Npc:says(_"This, and the ability to hack bots will soon return once your mind recovers from the stasis.")
			Npc:says(_"Once it does, we'll talk more about programs. You can toggle the [b]Skills/Program menu[/b] by pressing the [b]s key[/b].")
			Tux:update_quest("Tutorial Movement", _"View the Skills/Program menu by pressing the 's' key.")
			hide("node4")
		end,
	},
	{
		id = "node5",
		text = _"I'm sensing some sort of strange presence in the vicinity.",
		code = function()
			Npc:says(_"Ah, yes.", "NO_WAIT")
			Npc:says(_"Linarians seem to [b]detect items[/b] - even through walls - in an augmented reality.")
			Npc:says(_"The [b]z key[/b] will toggle this augmentation, while the [b]x key[/b] momentarily flashes it.")
			Npc:says(_"Moving your pointer over an item will tell you more about that item.")
			Npc:says(_"On our way to the next stopping point, we'll pass some items on the floor.")
			Npc:says(_"Feel free to stop and examine them to get practice.")
			Npc:says(_"[b]Left clicking[/b] on an item will pick it up and put it in your inventory, toggled by the [b]i key[/b], where you can examine it further.")
			if (not TutorialTom_TutMovement_ToggleDetectItems) and
			    Tux:has_quest("Tutorial Movement") then
				Tux:update_quest("Tutorial Movement", _"Toggle detect items by pressing the 'z' key, and press 'x' to flash the ability. To pick up an item, left click on it. To view an item you've picked up, open the inventory by pressing 'i'.")
				TutorialTom_TutMovement_ToggleDetectItems = true
			end
			if (Tux:has_item("Mug")) and
			   (Tux:has_item("Anti-grav Pod for Droids")) and
			   (Tux:has_item("Plasma Transistor")) then
				-- these are the items in the room item
				Npc:says(_"Oh great, I see you found all the items hidden in the room. Good job!")
				TutorialTom_Tux_found_all_items = true
			end
			hide("node5")
		end,
	},
	{
		id = "node7",
		text = _"No, thanks, I still remember how to walk, run, navigate, and pick things up.",
		code = function()
			hide("node1", "node7", "node80") next("node9")
		end,
	},
	{
		id = "node8",
		text = _"Thank you, that was very informative. I think I got how to move around. Can we proceed now?",
		code = function()
			Tux:end_quest("Tutorial Movement")
			Npc:says(_"I just closed your first quest. You can still see what you learned by clicking on the 'done quests' tab in the quest screen.", "NO_WAIT")
			hide("node8") next("node9")
		end,
	},
	{
		id = "node9",
		text = _"I'm eager to learn more.",
		code = function()
			Npc:says(_"Ok, follow me into the next area.")
			for var in ipairs(TutorialTom_doors) do
				change_obstacle_state(TutorialTom_doors[var], "opened")
			end
			hide("node1", "node2", "node3", "node4", "node5")
			end_dialog()
		end,
	},
	{
		id = "node10",
		text = _"What is in that chest?",
		code = function()
			Npc:says(_"Well, you can interact with several types of objects by simply [b]left clicking[/b] on them.")
			Npc:says(_"Left click on the chest to open it up and see what is inside.")
			if (not Tux:has_quest("Tutorial Melee")) then
				Tux:add_quest("Tutorial Melee", _"I'm supposed to left click on chests to open them up.")
			end
			hide("node10") show("node19")
			end_dialog()
		end,
	},
	{
		id = "node11",
		text = _"Some items came out.",
		code = function()
			Npc:says(_"Well, you've discovered a great secret: chests sometimes contain items.")
			Npc:says(_"We humans have a fascination with hiding our treasures. What comprises a treasure means different things to different people.")
			Npc:says(_"For some, it's valuable metals in robotic circuitry. That's the current monetary standard on our world.")
			Npc:says(_"For others, it may be weapons, or even just items that may be used as weapons in a pinch.")
			Npc:says(_"Still others, odd as it may sound, keep dishes hidden away.")
			Npc:says(_"Perhaps the best thing you can find, though, is armor. At least, given the current situation with the bots, that is.")
			hide("node11") show("node12", "node13")
		end,
	},
	{
		-- armor_node_one
		id = "node12",
		text = _"Armor? I should know more about this.",
		code = function()
			Npc:says(_"In the years since you entered stasis, mankind has done much research in the field of robotics.")
			Npc:says(_"One branch in particular that has served us well is the realm of nanotechnology.")
			Npc:says(_"Because they run a very simple operating system, nanobots were not affected by whatever caused the Great Assault.")
			Npc:says(_"To this day, our armor and clothing are made out of nanobots. This enables many different sizes of people to wear the same clothing.")
			Npc:says(_"The nanobots reshape the garment for a comfortable fit, so even you should be able to wear them without problem.")
			hide("node12") show("node14")
		end,
	},
	{
		-- armor_node_two
		id = "node13",
		text = _"How does wearing clothes and holding shields help me?",
		code = function()
			Npc:says(_"Well, it can help you avoid indecent exposure charges.")
			Tux:says(_"...")
			Npc:says(_"But all jokes aside, the bots will not mess around.")
			Npc:says(_"Even the best of fighters sometimes get hit by enemy blows. If I were you, I would seriously consider wearing some sort of armor before mixing it up with those bots.")
			Npc:says(_"They will help to mitigate some of the damage you take from melee or ranged combat.")
			Npc:says(_"Keep in mind, though, that there is a chance that your armor will take damage whenever you get hit. Keep an eye on it, or you'll lose it.")
			hide("node13") show("node15")
		end,
	},
	{
		id = "node14",
		text = _"That sounds useful. How do I use armor?",
		code = function()
			Npc:says(_"Well, let me start by saying that there are four classes of armor: headgear, shoes, body armor, and shields.")
			Npc:says(_"When you pick up a piece of armor of a particular class, and you don't already have one equipped, you will automatically equip it if you can.")
			Npc:says(_"Picking up armor and items can be accomplished by [b]left clicking[/b] on the item. If your inventory has space, you will pick the item up.")
			Npc:says(_"If you currently have one piece of armor equipped that you would like to swap out for another, simply drag the new armor piece to the current armor piece and left click.")
			Npc:says(_"They will swap places, and you can put the other piece of armor back into your inventory.")
			Npc:says(_"Alternatively, you can drag it into your field of view and drop it on the ground.")
			hide("node14") show("node16")
		end,
	},
	{
		id = "node15",
		text = _"I wouldn't want to lose any armor. What can I do about that?",
		code = function()
			Npc:says(_"Well, there are several ways to keep that from happening.")
			Npc:says(_"Equipped items in poor condition will show up yellow and should turn red if in critical condition.")
			Npc:says(_"If you don't unequip an item in poor or critical condition it may be ruined!")
			Npc:says(_"There are three things you can do when an item reaches critical condition:")
			Npc:says(_"First, you can sell or discard the item.")
			Npc:says(_"Second, you can use your [b]repair equipment[/b] program on the item, which will repair the item at the cost of some of its durability.")
			Npc:says(_"Or third, you can have the item repaired at a shop, which maintains the item's durability at a price.")
			hide("node15") show("node17", "node61")
		end,
	},
	{
		id = "node16",
		text = _"You mentioned discarding an item. Why would I want to do that?",
		code = function()
			Npc:says(_"Well, I can think of a few reasons.")
			Npc:says(_"You might not have enough room in your inventory for an item you need more, or can sell for more.")
			Npc:says(_"If an item is close to being destroyed, you might also consider dropping it.")
			Npc:says(_"And finally some items give negative status effects, and aren't worth selling.")
			Npc:says(_"Armor or weapons may affect you in different ways.")
			Npc:says(_"Some will help you out, for example by increasing your cooling rate or increasing your dexterity. This is the work of specialized nanobots, but the reverse can happen too.")
			hide("node16")
			armor_node_two = true
			if (armor_node_one) then
				show("node19")
			end
		end,
	},
	{
		id = "node17",
		text = _"Repair equipment program? How do I use that?",
		code = function()
			Npc:says(_"Perhaps I should start by explaining programs in general.")
			Npc:says(_"To use a program, select it through your HUD (remember the [b]s key[/b] toggles your [b]Skills/Program menu[/b]).")
			Npc:says(_"After you've selected a program, run the program by right clicking. Depending on the program you can target an enemy, an item, or just the world.")
			Npc:says(_"You can also assign quick-select keys to programs. Simply hover over the program in the Skills/Program menu and press one of the keys [b]F5[/b] to [b]F12[/b]. Then, whenever you press this button, you will select the corresponding program.")
			Npc:says(_"If you're curious what a program does, you can find out by clicking the question mark in the Skills/Program menu.")
			Npc:says(_"Now, to answer your question, you use your repair equipment program by selecting it in the Skills/Program menu, then right clicking on the item you wish to repair.")
			Tux:improve_program("Repair equipment")
			TutorialTom_has_repair = true
			if (not Tux:has_quest("Tutorial Melee")) then -- this might be tricky
				Tux:add_quest("Tutorial Melee", _"Run a program by right clicking after it has been selected from the Skills/Program menu. My shoes are damaged, so I might try the repair equipment program on them to slightly repair them.")
			else
				Tux:update_quest("Tutorial Melee", _"Run a program by right clicking after it has been selected from the Skills/Program menu. My shoes are damaged, so I might try the repair equipment program on them to slightly repair them.")
			end
			hide("node17")
		end,
	},
	{
		id = "node19",
		text = _"I think I'm ready for the next section of the tutorial.",
		code = function()
			Npc:says(_"Ok, I'll open the next door then. But prepare yourself, soon you will learn how to fight against bots in hand-to-hand combat.")
			if (not TutorialTom_has_repair) then
				Tux:improve_program("Repair equipment")
			end
			change_obstacle_state("TutorialEquipOut", "opened")
			end_dialog()
			hide("node10", "node11", "node12", "node13", "node14", "node15", "node16", "node17", "node61", "node62", "node63", "node64", "node65", "node19") show("node20")
		end,
	},
	{
		id = "node20",
		text = _"Can you tell me how to fight the bots?",
		code = function()
			Npc:says(_"I will certainly try my best.")
			Npc:says(_"It's odd to think that a flightless bird would be such a scrapper, but you Linarians have been surprising us since the beginning.")
			Npc:says(_"We prefer to fight the blamed droids at a distance. They're less likely to rend us limb from limb that way.")
			Npc:says(_"Unfortunately, guns and other ranged weaponry are hard to come by these days.")
			Npc:says(_"That goes double for ammunition. Because these are bots, you really can't effectively keep them at bay by just waving around an empty gun.")
			Npc:says(_"With that in mind, your most reliable weapons are your fists. They never run out of ammo or wear down, but of course they don't do much damage against a metal body, either.")
			hide("node20") show("node21", "node23")
		end,
	},
	{
		id = "node21",
		text = _"So I'm supposed to fight bots with my fists?",
		code = function()
			Npc:says(_"There may be times when you have no choice.")
			Npc:says(_"Melee combat, armed or unarmed, can be initiated by [b]left clicking[/b] on an enemy.")
			Npc:says(_"You will then walk over to the enemy and start hitting them.")
			Npc:says(_"Now, I understand you may have some concerns over your safety during this...")
			Tux:says(_"CONCERNS? Erm... Yes, this doesn't sound like a particularly healthy endeavor.")
			Npc:says(_"Fred, if you're afraid, you'll have to overlook it. Besides, you knew the job was dangerous when you took it.")
			Tux:says(_"I beg your pardon? Who is Fred?")
			Npc:says(_"Never mind, just an old song.")
			Npc:says(_"Fighting the bots hand-to-hand has risks, there is no question. However, there are things you can do to even the odds.")
			Npc:says(_"We already discussed armor. Another useful type of item is medical supplies.")
			Npc:says(_"There are a few different types of restorative items. The most common are health drinks.")
			hide("node21") show("node22")
		end,
	},
	{
		id = "node22",
		text = _"Tell me about health drinks.",
		code = function()
			Npc:says(_"Man has practised medicine in one form or another for hundreds of years.")
			Npc:says(_"Using some of the same nanotechnology that makes up your armor, we've perfected drinks that instantaneously restore your health.")
			Npc:says(_"There are many kinds, but all accomplish the same thing, to varying degrees.")
			Npc:says(_"Certain items, like health drinks, can be used directly without clicking on them.")
			Npc:says(_"At the bottom of your HUD, you'll notice your item access belt. Small items can go here and be used by pressing the numbers [b]0[/b] through [b]9[/b].")
			Npc:says(_"Unlike armor or weapons, multiple of these items will group together in your inventory slots.")
			Npc:says(_"If you have Diet Supplements equipped in item slot 1, you can press 1 to use one.")
			Npc:says(_"This will restore your health, and will be invaluable in the heat of battle.")
			Tux:update_quest("Tutorial Melee", _"Small one-time-use items, like diet supplements, can be placed in inventory spots labels 1 to 0, and can be used by pressing the corresponding key.")
			hide("node22")
		end,
	},
	{
		id = "node23",
		text = _"I'm ready to fight my first bot.",
		code = function()
			Npc:says(_"We keep two bots captive for melee practice.")
			Npc:says(_"I've unlocked the door leading to the first bot. Take care of it, then come back and talk to me.")
			Npc:says(_"I'm also giving you some health drinks. Feel free to use them, though I can heal you if you need it.")
			Npc:says(_"Your health will also regenerate over time. I wish it were so easy for us humans.")
			Npc:says(_"The first bot is carrying an [b]Entropy Inverter[/b]. Bring it to me to prove you've beaten it.")
			Npc:says(_"Come back and talk to me when you have the Entropy Inverter.")
			change_obstacle_state("TutorialMelee1", "opened")
			Tux:add_item("Doc-in-a-can", 3)
			Tux:update_quest("Tutorial Melee", _"I'm going to fight my first bot! To start melee combat left click on the bot. Tom wants the Entropy Inverter from the bot after I've defeated it, so I should pick that up.")
			hide("node23") show("node24", "node25")
			end_dialog()
		end,
	},
	{
		id = "node24",
		text = _"Can you heal me?",
		code = function()
			if (Tux:get_hp_ratio() == 1) then
				Npc:says(_"You are fine, there is nothing that I can do.")
				hide("node24")
			else
				Npc:says(_"You should be more careful, Linarian. But yes, I can heal you.")
				Npc:says(_"There, all better.")
				Tux:heal()
			end
		end,
	},
	{
		id = "node25",
		text = _"I've beaten the first bot.",
		code = function()
			if (Tux:has_item_backpack("Entropy Inverter")) then
				Npc:says(_"So you have. Well done.")
				Npc:says(_"I'll exchange this wrench for it. I think you'll find it handy.")
				Npc:says(_"Now would be an appropriate time to mention bot parts, I guess.")
				Npc:says(_"Certain parts in the bots are extra valuable. You can sell them at stores for cash.")
				Npc:says(_"If you can learn to extract these parts, it can help improve your lot in the world.")
				Npc:says(_"Hopefully, you can find someone to teach you.")
				Tux:del_item_backpack("Entropy Inverter", 1)
				Tux:add_item("Big wrench", 1)
				Tux:update_quest("Tutorial Melee", _"I brought the entropy inverter to Tom and he gave me my first weapon: a Big wrench. I should equip it.")
				hide("node25") show("node26")
			else
				Npc:says(_"Trying to cheat your way through the tutorial doesn't bode well for your chances in the real world.")
				Npc:says(_"I'll need proof that you've beaten the first bot.")
				Npc:says(_"Don't come back without the [b]Entropy Inverter[/b] it was carrying.")
				end_dialog()
			end
		end,
	},
	{
		id = "node26",
		text = _"You mentioned another bot?",
		code = function()
			Npc:says(_"That's correct. The second bot is a lot more dangerous, and you're not likely to make much headway against it with your fists.")
			Npc:says(_"Lucky for you, there's another dimension to melee combat.")
			Npc:says(_"Fighting bots with your fists is fine, but there are a number of items you can use for melee.")
			Npc:says(_"There are several traditional weapons in the world such as swords or light sabers that can be used against the bots.")
			Npc:says(_"However, more common items you encounter every day can often be used to bash or pry at droid armor.")
			Npc:says(_"For example, that wrench I just gave you will increase the damage you do, and should let you best the next bot.")
			hide("node26") show("node27")
		end,
	},
	{
		id = "node27",
		text = _"I'm ready to take the next bot on.",
		code = function()
			Npc:says(_"I certainly hope so. I will heal you before you go to the next room.")
			Npc:says(_"I'm also giving you another healing drink, just in case.")
			Npc:says(_"A 247 is nothing to trifle with, so I'm giving you a shield in the hopes that it'll help keep you alive.")
			Npc:says(_"Finally, I'm giving you couple of somewhat experimental pills that will temporarily increase your strength and dexterity, respectively.")
			Npc:says(_"Use them in the same way you would use a health drink.")
			Npc:says(_"If I were you, I would think about using your repair equipment program on your armor and that wrench before you go into the room.")
			Npc:says(_"You'll also need to equip them. I won't do that for you.")
			Npc:says(_"Like the last bot, this one will be carrying an item. Bring me the [b]Tachyon Condensator[/b] it is carrying to continue.")
			Npc:says(_"I've unlocked the door. Good luck, and talk to me when you have the Tachyon Condensator.")
			change_obstacle_state("TutorialMelee2", "opened")
			Tux:heal()
			Tux:add_item("Doc-in-a-can", 1)
			Tux:add_item("Strength Capsule", 1)
			Tux:add_item("Dexterity Capsule", 1)
			Tux:add_item("Standard Shield", 1)
			hide("node27") show("node28")
			end_dialog()
		end,
	},
	{
		id = "node28",
		text = _"I've beaten the second bot.",
		code = function()
			if (Tux:has_item_backpack("Tachyon Condensator")) then
				Npc:says(_"Very good! You've completed your melee training.")
				Npc:says(_"These skills will serve you well in the future.")
				Npc:says(_"Talk to me when you're ready to move on to the next part of the tutorial.")
				Tux:del_item_backpack("Tachyon Condensator", 1)
				hide("node28") show("node29")
			else
				Npc:says(_"You didn't bring back the Tachyon Condensator. You'll need to bring it back before we can continue.")
				Npc:says(_"I'll go ahead and heal you. If your weapon or armor are in bad shape, perhaps you should repair them before going back in there.")
				Npc:says(_"Don't come back without the [b]Tachyon Condensator[/b].")
				end_dialog()
			end
			Tux:heal()
		end,
	},
	{
		id = "node29",
		text = _"I'm ready to move on.",
		code = function()
			if (not Tux:done_quest("Tutorial Melee")) then
				Tux:end_quest("Tutorial Melee", _"I decided to move on and go to next unit of the tutorial.")
			end
			--[[ if (TutorialTom_has_gun) then
			Npc:says(_"I'll bet you're itching to try that pistol out on some bots.")
			Npc:says(_"Our next destination is the ranged combat training area, so you're in luck.")
			end ]]--
			Npc:says(_"I'll unlock the door to the south. Follow the corridor east.")
			change_obstacle_state("TutorialMeleeOut", "opened")
			Npc:set_destination("TutorialTom-Terminal")
			hide("node20", "node21", "node22", "node23", "node24", "node25", "node26", "node27", "node28", "node29")
			show("node40")
			end_dialog()
		end,
	},
	{
		id = "node30",
		text = _"Ranged weaponry seems safer than getting up close and personal.",
		code = function()
			Npc:says(_"Well, Linarian, most of the time it is.")
			Npc:says(_"There are some bots with ranged weaponry, but we don't have any of those in captivity.")
			Tux:add_quest("Tutorial Shooting", _"I am learning about how to use ranged weapons.")
			hide("node30") show("node31", "node38")
		end,
	},
	{
		id = "node31",
		text = _"So what can you tell me about guns?",
		code = function()
			Npc:says(_"The basic idea behind ranged weaponry is to hurt or kill an enemy without having to come within swinging range.")
			Npc:says(_"There are three basic ways to do this: traditional firearms, lasers, and plasma weapons.")
			Npc:says(_"Traditional firearms are things that go bang. A small explosion accelerates the ammunition towards the target at a high velocity, causing injury.")
			Npc:says(_"Lasers use an intensified beam of light to burn through the intended victim. These operate on replaceable charge packs.")
			Npc:says(_"Plasma weapons use superheated ionized gas to burn the target. The gas comes in loadable canisters.")
			Npc:says(_"Most other ranged weapons are variations of these three. We have a few in storage for training purposes.")
			hide("node31") show("node32")
		end,
	},
	{
		id = "node32",
		text = _"So how do I use guns?",
		code = function()
			Npc:says(_"Well, firing is pretty simple. First, equip a ranged weapon that you have ammunition for.")
			Npc:says(_"Next, simply [b]left click[/b] on your target, and you'll begin firing.")
			Npc:says(_"Alternatively, you can fire a single shot using the [b]Fire Weapon[/b] program, and [b]right clicking[/b] on the enemy.", "NO_WAIT")
			Npc:says(_"That is the best way if you are trying to conserve precious ammo with high rate of fire guns.")
			Npc:says(_"There are a couple of new tricks with ranged weapons. If you want to [b]move while firing[/b]: hold [b]shift[/b] and [b]left click[/b] your desired position.")
			Npc:says(_"If you'd rather stay in place: Hold [b]A[/b], then [b]left click[/b] your target.")
			Npc:says(_"When your weapon runs out of ammo during combat, it will try to automatically reload if you have extra ammunition for it.")
			Npc:says(_"Sometimes, you will need or want to manually reload. You can do this by pressing the [b]r key[/b].")
			Npc:says(_"If you are reloading, or you are out of ammo, the small message screen at the bottom of your HUD will tell you what type of ammo to get.")
			if (not TutorialTom_guns_how_to) then
				TutorialTom_guns_how_to = true
				Tux:update_quest("Tutorial Shooting", _"If I have equipped a ranged weapon and I left click on an enemy, I will begin firing upon it until my gun is empty, and automatically reload. But if I want to fire a single shot, I need to also equip the Fire Weapon program, and then right click. To move while firing, I have to shift + left click to where I want to go. Also, if I want to manually reload I have to press the 'r' key. The small message screen at the bottom of my HUD will tell me if I'm reloading or out of ammunition.")
			end
			if (not TutorialTom_opened_door) then
				show("node33")
			end
			hide("node32")
		end,
	},
	{
		id = "node33",
		text = _"I think I understand how to use guns now.",
		code = function()
			Npc:says(_"In that case, I'll let you in to the armory. There are some crates and chests in there with weapons and ammunition.")
			Npc:says(_"Be careful though, smashing open crates and barrels could hurt you.")
			if (TutorialTom_has_gun) then
				Npc:says(_"You already got the .22 pistol I gave you earlier? It's not much as guns go, but it can do the trick.")
			else
				Npc:says(_"Here's my personal .22 Automatic pistol. It's not much as guns go, but it can do the trick.")
				Tux:add_item(".22 Automatic", 1)
				Tux:add_item(".22 LR Ammunition", 10)
			end
			Npc:says(_"Here is some more ammunition for it.")
			Npc:says(_"You'll no doubt get more mileage out of the plasma pistol, though. Or any other gun, for that matter.")
			Npc:says(_"Practice switching weapons and reloading.")
			Npc:says(_"On the other side of that fence are some bots. Practice killing them off with various ranged weapons.")
			Npc:says(_"Once you've gotten rid of them all, we can move on.")
			Tux:update_quest("Tutorial Shooting", _"Tutorial Tom wants me to shoot those bots.")
			-- TODO probably explain leveling as well as balancing changes to XP always risk causing leveling here. Or somehow make sure Tux can't level
			TutorialTom_opened_door = true
			change_obstacle_state("TutorialStorage", "opened")
			change_obstacle_state("TutorialShootCage", "opened")
			Tux:add_item(".22 LR Ammunition", 50)
			hide("node33") show("node34", "node35")
			end_dialog()
		end,
	},
	{
		id = "node34",
		text = _"I ran out of ammo. Can I have some more?",
		code = function()
			if (cmp_obstacle_state("37-ammo-chest", "unlocked")) then -- check if tux has opened the ammo chest already : yes
				if (Tux:has_item_backpack("Laser power pack")) or (Tux:has_item_backpack("Plasma energy container")) or (Tux:has_item_backpack(".22 LR Ammunition")) then
					-- check if tux still has ammo left
					Npc:says(_"Looks like you still have some ammo left in your inventory...")
					Npc:says(_"Why don't you use this first?")
					Npc:says(_"Try to switch to another gun maybe...")
				else -- chest opened but no ammo left in inventory...
					Npc:says(_"Ok, I will give you some more ammo. You seem to be in need, indeed...")
					Tux:add_item("Laser power pack", 10)
					Tux:add_item("Plasma energy container", 10)
					Tux:add_item(".22 LR Ammunition", 10)
				end
			else
				Npc:says(_"Check the storage room to the west for more guns and ammo.")
			end
		end,
	},
	{
		id = "node35",
		text = _"I killed all the bots.",
		code = function()
			if (Tux:done_quest("Tutorial Shooting")) then
				Npc:says(_"Excellent job.")
				Npc:says(_"Keep shooting like that, and the bots will never stand a chance, as long as you still have ammo.")
				Tux:update_quest("Tutorial Shooting", _"That was like shooting fish in a barrel. I could use a fish about now.")
				hide("node35") show("node36", "node37")
				end_dialog()
			else
				Npc:says(_"I don't mind if you don't want to do this, but please don't try to trick me.")
				Npc:says(_"I don't have verified kills on all those bots.")
			end
		end,
	},
	{
		id = "node36",
		text = _"I would like a few more bots to shoot at.",
		code = function()
			Npc:says(_"Ok, I'll create some more droids.")
			i = 1
			while (i < 8) do
				create_droid("shootingrange"..i, 123)
				i = i + 2
			end
			hide("node36")
			end_dialog()
		end,
	},
	{
		id = "node37",
		text = _"So, what's next?",
		code = function()
			Npc:says(_"Now, there's one last thing you should know.")
			Npc:says(_"You Linarians can apparently withdraw from our world temporarily.")
			Npc:says(_"Time stops, and everything freezes in place.")
			Npc:says(_"This can be accomplished by using the [b]Esc key[/b].")
			if (not TutorialTom_hacking_bots) then
				Npc:says(_"Your final task is to leave us using this menu.")
				Npc:says(_"I'm afraid there's nothing more I can teach you. I wish you good luck, Linarian.")
				Npc:says(_"You'll need it if our world is to survive.")
			end
			change_obstacle_state("TutorialExit1", "opened")
			hide("node30", "node31", "node32", "node33", "node34", "node35", "node36", "node38")
		end,
	},
	{
		id = "node38",
		text = _"Why can't I hack the bots here, or use programs on them?",
		code = function()
			Npc:says(_"Well, that would be cheating, don't you think so?")
			Npc:says(_"Shooting moving targets needs a bit of practice, yes...")
			Npc:says(_"...but in the end you will profit a lot from it.")
			Tux:says(_"Ok, I will try my best.")
			tux_node38_done = true
			hide("node38")
		end,
	},
	{
		id = "node40",
		text = _"Why are we stopping?",
		code = function()
			Npc:says(_"You've done well so far, Linarian. Let's take a little break.")
			Npc:says(_"Once you get out into the real world, you'll find that your current abilities aren't always enough to survive.")
			Npc:says(_"As you achieve combat experience, you'll be able to apply it to better yourself.")
			Npc:says(_"As with most things, you view this as a panel in your HUD. Press the [b]c key[/b] to open the [b]Character panel[/b].")
			Npc:says(_"Once you've gained enough experience, you'll level up. This will automatically improve some of your statistics.")
			Npc:says(_"You'll also be given 5 points to spend however you choose in three different areas. Characteristics, Skills and Programs.")
			Npc:says(_"[b]Strength[/b] governs the amount of damage you do with each hit in melee combat.")
			Npc:says(_"[b]Dexterity[/b] controls your hit rate, or how likely you are to hit the enemy. It also determines how likely you are to dodge a hit from them.")
			Npc:says(_"[b]Cooling[/b] is your processors cooling, or heat resilience, and determines how much you can process before your system starts overheating.")
			Npc:says(_"Finally, among your main characteristics, [b]Physique[/b] determines how much health you have.")
			Npc:says(_"There are general [b]Melee[/b] and [b]Ranged[/b] fighting skills, both of which increase the damage you inflict and how fast you attack as you improve them.")
			Npc:says(_"You also have the [b]Programming[/b] skill, which essentially is about programming in an energy-efficient manner so programs cause less heat.")
			Npc:says(_"Apart from this, a few programs require a teacher and training points to improve.")
			Npc:says(_"[b]Extract Bot Parts[/b] is a special passive skill that will allow you to salvage parts from bots you 'retire', which you can trade for money in the town.")
			Npc:says(_"There may be other passive skills, but I know nothing about those.")
			Npc:says(_"A good technician is able to make use of those parts.")
			Npc:says(_"He can create, let's say, an add-on and, after doing some modifications to the item, attach this add-on.")
			Npc:says(_"This way an upgraded item is created.")
			Tux:add_quest("Tutorial Upgrading Items", _"There is a way to upgrade items if I meet a good technician. It sounds useful, maybe I should learn more about this.")
			Npc:says(_"The [b]Hacking[/b] program we will speak a bit more of in a little while.")
			hide("node40") show("node41")
		end,
	},
	{
		id = "node41",
		text = _"I'll have to keep that in mind.",
		code = function()
			Npc:says(_"Well, how about you try it out?")
			Npc:says(_"I'll give you some points to spend, and you can distribute them as you like.")
			Npc:says(_"Since you'll be hacking up ahead, you should probably use a few of them on [b]Cooling[/b].")
			Npc:says(_"But, again, that's your choice.")
			Tux:add_xp(2000)
			hide("node41") show("node58")
			end_dialog()
		end,
	},
	{
		id = "node42",
		text = _"Alright, I'm ready to go hack some bots.",
		code = function()
			if (not Tux:done_quest("Tutorial Upgrading Items")) then
				Tux:end_quest("Tutorial Upgrading Items", _"I decided that I don't need to know how to upgrade items.")
			end
			Npc:says(_"First, you'll need to unlock the door.")
			Npc:says(_"See that [b]Terminal[/b] to the left?")
			Npc:says(_"You will need to login, by left clicking on it, and then select unlock door.")
			Npc:says(_"Terminals act very similar to hacked bots.")
			Tux:add_quest("Tutorial Hacking", _"I need to login to the Terminal by left clicking on it. Then I'll unlock the door, so I can go hack some bots!")
			hide("node42", "node58", "node59", "node60")
			end_dialog()
		end,
	},
	{
		id = "node50",
		text = _"So how does this work?",
		code = function()
			Npc:says(_"We talked about programs before. Now, we're going to focus on hacking programs in particular.")
			Npc:says(_"As I mentioned before, your brain works in a way remarkably similar to a central processing unit.")
			Npc:says(_"In many ways, you interact with the world around you as a virtual environment.")
			Npc:says(_"You seem to have access to an API that isn't exposed to humans. You can interact with the environment in ways we only dream of.")
			Npc:says(_"Because of this, you can run various programs on the bots.")
			Npc:says(_"You can attempt to take them over, or monkey with their programming, or even cause them to damage themselves.")
			Npc:says(_"Likewise, there are certain programs that affect you or items around you.")
			if (not Tux:has_quest("Tutorial Hacking")) then -- quest already added in node 42
				Tux:add_quest("Tutorial Hacking", _"I need to login to the Terminal by left clicking on it. Then I'll unlock the door, so I can go hack some bots!")
			end
			TutorialTom_node50_done = true
			hide("node50") show("node51")
		end,
	},
	{
		id = "node51",
		text = _"Tell me about taking bots over.",
		code = function()
			Npc:says(_"I'm afraid that you will have to experience it for yourself to really understand.")
		--	Npc:says(_"However, you did leave yourself instructions before you went into stasis sleep.")
			Npc:says(_"Taking over a bot comes in the form of a game or competition placing you against the bot.")
			Npc:says(_"You initiate it by selecting the [b]Hacking[/b] program, then [b]right-clicking[/b] on a hostile bot.")
			Npc:says(_"The field of play is split into two sides, one yellow, one purple, representing circuit boards.")
			Npc:says(_"In the center of the field is a column of boxes known as logic cores. These cores have wires attached to them from both circuit boards.")
			Npc:says(_"Your objective is to activate as many cores in your chosen color as possible at the end of each round.")
			Npc:says(_"This is accomplished by selecting a wire with the up or down buttons, then pressing spacebar to activate that core.")
			Npc:says(_"You will be given about 10 seconds initially to select which color you want with spacebar.")
			Npc:says(_"At that point, you have 10 more seconds in which to activate more cores than the bot.")
			Npc:says(_"Each activation of one core will consume one charge and you have a limited number of charges, 3 by default, so choose your targets carefully.")
			Npc:says(_"I can tell you about some more advanced techniques, if you'd like.")
			if (not TutorialTom_updated_hacking_quest) then
				Tux:update_quest("Tutorial Hacking", _"Apparently in order to hack, all I have to do is select the Hacking program, right click a bot, and play a little game. I've got this!")
				TutorialTom_updated_hacking_quest = true
			end
			show("node52", "node53", "node54") hide("node51")
		end,
	},
	{
		id = "node52",
		text = _"What was that about activating more cores than the bot?",
		code = function()
			Npc:says(_"Ah, yes. While you are busy trying to take the bot over, it will be busy trying to stop you.")
			Npc:says(_"The truth is, if the bot programming was perfect, it would be almost impossible to defeat.")
			Npc:says(_"Fortunately for you, software bugs do indeed exist, and therefore some cores will be on your side from the beginning.")
			Npc:says(_"Likewise, the bots only have a limited number of charges. Occasionally, they will have more than you, but that is a risk you have to take.")
			Npc:says(_"Because you are initiating the attack, you do get to choose your side, which can let you handicap the bot greatly if used wisely.")
			hide("node52")
		end,
	},
	{
		id = "node53",
		text = _"Tell me about more advanced techniques.",
		code = function()
			Npc:says(_"Each charge will activate and remain active for a certain amount of time. This will let you take over a core that a bot just took over.")
			Npc:says(_"Sometimes, the bots will already have charges on the wires. When you activate one of these, it will increase the time that wire is activated for.")
			Npc:says(_"The bot can use this trick too, so it may be wise to give up a heavily guarded wire for an easier target.")
			Npc:says(_"The wiring inside the bots sometimes contain splitters. These can be used in two ways.")
			Npc:says(_"A 2-to-1 splitter is undesirable. This requires two charges to activate one core, halving your efficiency.")
			Npc:says(_"A 1-to-2 splitter, however, will activate two nodes for the price of one charge.")
			Npc:says(_"Sometimes these splitters will be stacked. Tracing the route ahead of time will be crucial to your tactical success.")
			Npc:says(_"Ideally, you want to stick your opponent with 2-to-1 splitters, while you have 1-to-2 splitters at your disposal.")
			Npc:says(_"Finally, remember that patience is often a virtue. Taking over all cores early on only to lose them later can be a crushing blow.")
			hide("node53")
		end,
	},
	{
		id = "node54",
		text = _"I'm ready to try hacking bots.",
		code = function()
			Npc:says(_"I certainly hope so.")
			Npc:says(_"I should, however, take the time to tell you a few more things.")
			Npc:says(_"Hacking, like most other programs, incurs a cost to you.")
			Npc:says(_"Processing programs seems to heat up your brain.")
			Npc:says(_"You seem to be able to handle quite a bit of heat, but you have your limits.")
			Npc:says(_"If you do not use all charges when attempting to take over a bot, you will spare some heat.")
			Npc:says(_"Not activating all charges or beating the bot with a comfortable winning margin is less exhaustive for you.")
			Npc:says(_"If you nevertheless accumulate too much heat, you will automatically shut down in order to cool off.")
			Npc:says(_"Over time, the heat will seep away from your body naturally. However, there are ways to speed up the process.")
			Npc:says(_"If you can find them, cooling drinks will quickly relieve your thermal discomfort, in much the same way healing drinks help your health.")
			Npc:says(_"Remember you also have a special program called [b]Emergency Shutdown[/b] that will lower your heat level drastically. Unfortunately using Emergency Shutdown will shut you down and render you paralyzed for several seconds. It makes you a sitting duck... er, penguin.")
			Tux:says(_"I take it that was a joke also?")
			Npc:says(_"Quite.", "NO_WAIT")
			Npc:says(_"In addition to hacking, you have the ability to execute arbitrary code on bots.")
			Npc:says(_"These scripts and programs can be learned through reading source code books. To read a book, right-click on it in inventory.")
			Npc:says(_"You should have recovered your hacking ability by now, and I'll give you a couple of source code books as well.")
			show("node55", "node57") hide("node54")
		end,
	},
	{
		id = "node55",
		text = _"Thanks. I'm ready now.",
		code = function()
			Npc:says(_"We have several bots behind that fence for you to practice on.")
			Npc:says(_"Take them over, then talk to me when they're all dead.")
			Npc:says(_"If you need more help, don't hesitate to ask.")
			Npc:says(_"Oh, and Linarian... If you fail when hacking, you'll receive an electrical shock.")
			Npc:says(_"It shouldn't kill you, but you need to be aware of it nonetheless.")
			if (not TutorialTom_hacking_bots) then
				Tux:improve_program("Hacking")
				Tux:improve_program("Emergency shutdown")
				Tux:add_item("Liquid nitrogen", 1)
				Tux:add_item("Source Book of Calculate Pi", 1)
				Tux:add_item("Source Book of Malformed packet", 1)
				TutorialTom_hacking_bots = true
				Tux:update_quest("Tutorial Hacking", _"Tutorial Tom wants me to hack those bots. The only thing I need to worry about is overheating. But if I get too hot I can always try the Emergency shutdown program.")
				change_obstacle_state("TutorialTakeoverCage", "opened")
				show("hacking_extratime")
			end
			hide("node55")
			end_dialog()
		end,
	},
	{
		id = "hacking_extratime",
		text = _"I'm having troubles in taking over a bot within allocated time.",
		code = function()
			tut_hack_time=tut_hack_time+2
			Npc:says(_"In real life you have to finish within the allocated time, and time limit is often more important than charges.")
			Npc:says(_"As it's your first time hacking, I'll teach you a skill so you get a whooping extra second to take over the bot.")
			Npc:says(_"Be warned though, that very few people know how to improve this skill. It's called [b]Animal Magnetism[/b].")
			Npc:says(_"This may be a good time to mention that every program have a revision. It's like a skill level. Higher revision usually means higher effects.") -- TODO This whole part about program revisions should be on node55. "Eating" books should also be explained.
			Npc:says(_"Naturally, this include heat cost as well. Improving a revision is usually the same process from learning a new program.")
			Npc:says(_"Well, I guess that's all. Come back to me when all bots are dead.")
			Tux:improve_program("Animal Magnetism")
			Tux:improve_program("Animal Magnetism")
			if (tut_hack_time > 2) then
				hide("hacking_extratime")
			else
				Npc:says(_"Ah, linarian! If you need, I can grant you even another second, but I don't recommend.", "NO_WAIT")
				Npc:says(_"Come see me if you need it.")
				end_dialog()
			end
		end,
	},
	{
		id = "node57",
		text = _"Tell me again about take over, I'm not sure I got it all.",
		code = function()
			Npc:says(_"Tell me exactly what part you want me to explain again.")
			Npc:says(_"But things will be much clearer once you try for yourself than when I try to explain.")
			Npc:says(_"Use your experience as notes, and all should be clear.")
			show("node51", "node52", "node53") hide("node57")
		end,
	},
	{
		id = "node58",
		text = _"Can you tell me more about upgrading items?",
		code = function()
			Npc:says(_"You can upgrade most weapons and clothing. First, you'll need some materials to craft add-ons.")
			Npc:says(_"Parts needed for this process can be extracted from bots. You'll have to learn how to do it.")
			Npc:says(_"When you have enough materials, you can craft an add-on. Make sure the add-on is suitable for your equipment.")
			Npc:says(_"After this, you have to make a socket in your equipment so you can plug in the add-on.")
			Npc:says(_"That's the theory. Simple, isn't it?")
			Npc:says(_"I'll give you some materials now and let you craft an add-on.")
			Npc:says(_"Usually you'll do this in some sort of mini-factory.", "NO_WAIT")
            Npc:says(_"But I'll do this for you without one or my name is not Tom. Tutorial Tom.")
			Npc:says(_"Pay attention to the type of socket the add-on needs.")
			Tux:update_quest("Tutorial Upgrading Items", _"Before crafting an add-on I have to get some materials. The best way is to extract them from the bots, using Extract Bot Parts skill. Each add-on requires a socket in the item. When the add-on is ready, I have to create a socket in the item and plug the add-on. Only technicians can craft add-ons or plug them.")
			-- TODO decide on what type of upgrade should player make?
			for i,v in ipairs(items_up) do
				Tux:add_item(v, 20)
			end

			craft_addons()
			Npc:says(_"Now you'll need to pay some more money in order to make a socket and plug in the add-on. Here, take some.")
			Tux:add_gold(1200)
			Npc:says(_"Choose an item and add an appropriate socket by clicking '+' on the right of the item. Then attach the add-on to this item and confirm your choice.")
			upgrade_items()
			Tux:end_quest("Tutorial Upgrading Items",_"Maybe I need some time to practice this, but I got the basics.")
			hide("node58") show("node59", "node60", "node42")
		end,
	},
	{
		id = "node59",
		text = _"I wasted my materials on the add-on I didn't need. Can you give more?",
		code = function()
			Npc:says(_"Yes, but only this time. I'll give you some money too. Just be more careful in the future and make wise choices.")
			Npc:says(_"Reality is not as generous as I am.")
			for i,v in ipairs(items_up) do
				Tux:add_item(v, 20)
			end

			Tux:add_gold(1200)
			Tux:says(_"Thank you.")
			Npc:says(_"Think carefully before you make your next add-on.")
			hide("node59")
		end,
	},
	{
		id = "node60",
		text = _"Upgrading items is still too complex for me. Can you explain it again?",
		code = function()
			Npc:says(_"First step is finding materials. They may be extracted from bots, but you'll have to learn how to do it.")
			Npc:says(_"Those materials can be used in crafting add-ons. Make sure the add-on will fit your equipment. Also, remember the type of the socket your add-on needs.")
			Npc:says(_"I gave you materials. Let's craft an add-on now.")
			craft_addons()
			Npc:says(_"All you have to do now is to choose a suitable item and add a socket by clicking ''+'' on the right of the chosen item.")
			Npc:says(_"Remember you pay for both adding a socket and plugging an add-on.")
			Npc:says(_"Let's try it, shall we?")
			upgrade_items()
			Npc:says(_"I hope it's clear now.")
		end,
	},
	{
		id = "node61",
		text = _"Shops?",
		code = function()
			Npc:says(_"Some people are willing to trade items and circuits with you.")
			--Npc:says(_"Although, if you have too many circuits, they will charge you a bit more.") https://rb.freedroid.org/r/1327/
			Npc:says(_"Most are willing to buy whatever you have, at a discounted price.")
			Npc:says(_"There are also some automated vending machines, that dispense small items.") -- but these cannot buy from you.") -- to be implemented
			hide("node61") show("node62")
		end,
	},
	{
		id = "node62",
		text = _"I would like to practice selling an item.",
		code = function()
			Npc:says(_"I'm going to give you a Small Axe, which you can't use yet, so you can practice selling it to me.")
			Npc:says(_"You will see the Small Axe appear in the lower shop bar. You can sell most of these items.")
			Npc:says(_"Items that you have equipped have a hand icon on them.")
			Npc:says(_"However, if you sell the items from the chest (which should have been equipped automatically) I won't be giving you replacements.")
			Npc:says(_"Select the Small Axe and click the sell button.")
			Tux:add_item("Small Tutorial Axe")
			i = 1
			while (i < 100) do -- this is a ugly hack to get rid of the "Item received: Small Axe" centerprint
				display_big_message("")
				i = i + 1
			end
			hide("node62") next("node63")
		end,
	},
	{
		id = "node63",
		text = _"Let me try that again.",
		echo_text = false,
		code = function()
			trade_with("TutorialTom")
			if (Tux:has_item_backpack("Small Tutorial Axe")) then
				show("node63")
			else
				hide("node63")
				show("node64")
			end
		end,
	},
	{
		id = "node64",
		text = _"How about buying an item?",
		code = function()
			Npc:says(_"Well it is much the same procedure, except the items for sale are on the top row.")
			Npc:says(_"With the circuits from selling the Small Axe to me, you can afford to buy a unit of Bottled ice.")
			Npc:says(_"Since Bottled ice combine together, a slider will pop-up asking how many you'd like to buy.")
			Npc:says(_"You have enough circuits for one unit.")
			sell_item("Bottled Tutorial ice")
			hide("node64") next("node65")
		end,
	},
	{
		--hidden
		id = "node65",
		text = _"Let me try that again.",
		echo_text = false,
		code = function()
			if (Tux:get_gold() < 15) then
				Tux:add_gold(15 - Tux:get_gold())
			end
			trade_with("TutorialTom")
			if (Tux:count_item_backpack("Bottled Tutorial ice") < 1) then
				show("node65")
			else
				hide("node65")
				next("node66")
			end
		end,
	},
	{
		--hidden
		id = "node66",
		code = function()
			Npc:says(_"You will occasionally run into items that can't be sold.")
			Npc:says(_"This generally means that the shopkeeper can't give you a reasonable deal on it.")
			Npc:says(_"Someone else probably wants the item.")
			Npc:says(_"You might check your questbook to see if it is mentioned there.")
			if (Tux:has_item_backpack("Bottled Tutorial ice")) then --before player notices, swap the "tutorial" item to normal one :P
				local Tutorial_ice_amount = Tux:count_item("Bottled Tutorial ice")
				Tux:del_item_backpack("Bottled Tutorial ice", Tutorial_ice_amount)
				Tux:add_item("Bottled ice", Tutorial_ice_amount)
				display_big_message("") -- so that we don't have the Item Received: spam on the screen which might be confusing
				display_big_message("")
				display_big_message("")
				display_big_message("")
				display_big_message("")
				display_big_message("")
				display_big_message("")
				display_big_message("")
				display_big_message("")
				display_big_message("")
				display_big_message("")
			else
				Npc:says("ERROR OCCURRED, TutorialTom node 66, player doesn't have bottled tutorial ice, WTF happened??")
			end
			armor_node_one = true
			if (armor_node_two) then
				show("node19")
			end
		end,
	},
	{
		id = "node70",
		text = _"There is a wall in the path! How will we get through?",
		code = function()
			if (cmp_obstacle_state("TutorialWall", "broken")) then
				Npc:says(_"Uhm, looks like the wall is already broken, I'll repair it.")
				change_obstacle_state("TutorialWall", "intact")
			else
				Npc:says(_"Notice that part of it is made of a weak material, glass.")
				Npc:says(_"Obstacles you can interact with change color when your cursor is hovering over them.")
				Npc:says(_"[b]Left click[/b] on the glass wall to break it.")
				Npc:says(_"After you break through the glass wall, walk to the other side so I know you are ready to move on.")
			end
			end_dialog()
		end,
	},
	{
		id = "node71",
		text = _"I defeated all the bots in the cage.",
		code = function()
			Npc:says(_"Well done!")
			Npc:says(_"Then let us move towards the next stage of the Tutorial")
			change_obstacle_state("TutorialGlasswallDoor", "opened")
			Npc:says(_"As a reward, I'm giving you a .22 Automatic pistol.")
			if (Tux:has_item("Source Book of Calculate Pi")) and
			   (Tux:has_item("Source Book of Malformed packet")) then
				--plural
				Npc:says(_"But I have to take these sourcebooks from you to prevent you from cheating in the next section of the tutorial.")
				Npc:says(_"Sorry about that...")
				Tux:says(_"Ok...")
			elseif (Tux:has_item("Source Book of Calculate Pi")) or
			       (Tux:has_item("Source Book of Malformed packet")) then
				--singular
				Npc:says(_"But I have to take this sourcebook from you to prevent you from cheating in the next section of the tutorial.")
				Npc:says(_"Sorry about that...")
				Tux:says(_"Ok...")
			end
			if (Tux:has_item("Source Book of Calculate Pi")) then -- ugly, but it shall do
				Tux:del_item("Source Book of Calculate Pi")
			end
			if (Tux:has_item("Source Book of Malformed packet")) then
				Tux:del_item("Source Book of Malformed packet")
			end
			Tux:add_item(".22 Automatic", 1)
			Tux:add_item(".22 LR Ammunition", 10)
			while (tut_hack_time > 0) do
				Tux:downgrade_program("Animal Magnetism") -- Remove extra hacking time
				tut_hack_time=tut_hack_time-1
			end
			TutorialTom_has_gun = true
			TutorialTom_hide_71 = true
			hide("node42", "node50", "node51", "node52", "node53", "node57", "node71", "hacking_extratime")
			end_dialog()
		end,
	},

--    							Quick Menu (to jump to sections)

	{
		id = "node80",
		text = _"I'd like to skip to a later section of the Tutorial.",
		code = function()
			Npc:says(_"OK, what would you like to learn about?")
			show("node81", "node82", "node83", "node84", "node85", "node86", "node87")
			hide("node1", "node7", "node80")
		end,
	},

	{
		id = "node81",
		text = _"Chests and Armor",
		code = function()
			Npc:says(_"OK, I'll take us to the Chest.")
			Npc:teleport("TutorialTom-Chest")
			Tux:teleport("TutorialTux-Chest")
			tutorial_chests_and_armor_and_shops()
			next("node10")
			hide("node81", "node82", "node83", "node84", "node85", "node86", "node87")
		end,
	},

	{
		id = "node82",
		text = _"Shops",
		code = function()
			Npc:says(_"Remember to pick up the items in the chest.")
			Npc:says(_"I'll tell you about the shops.")
			Npc:teleport("TutorialTom-Chest")
			Tux:teleport("TutorialTux-Chest")
			tutorial_chests_and_armor_and_shops()
			next("node61")
			show("node19")
			hide("node81", "node82", "node83", "node84", "node85", "node86", "node87")
		end,
	},

	{
		id = "node83",
		text = _"Melee Combat",
		code = function()
			Npc:says(_"OK, I'll take us to the melee arena and give you some armor.")
			Npc:teleport("TutorialTom-Melee")
			Tux:teleport("TutorialTux-Melee")
			Tux:add_quest("Tutorial Melee", _"I skipped ahead to the Melee practice. Tom gave me some armor to use.")
			tutorial_melee_combat()
			next("node20")
			hide("node81", "node82", "node83", "node84", "node85", "node86", "node87")
		end,
	},

	{
		id = "node85",
		text = _"Abilities",
		code = function()
			Npc:says(_"OK, I'll take us there and give you some armor and a weapon.")
			Npc:teleport("TutorialTom-Terminal")
			Tux:teleport("TutorialTux-Terminal")
			tutorial_abilities()
			next("node40")
			hide("node81", "node82", "node83", "node84", "node85", "node86", "node87")
		end,
	},

	{
		id = "node86",
		text = _"Upgrading Items & Terminals",
		code = function()
			Npc:says(_"OK, I'll take us there and give you some armor and a weapon to work with.")
			Npc:teleport("TutorialTom-Terminal")
			Tux:teleport("TutorialTux-Terminal")
			tutorial_upgrade_items_and_terminal()
			if (not Tux:has_quest("Tutorial Upgrading Items")) then
				Tux:add_quest("Tutorial Upgrading Items", "")
			end
			next("node58")
			show("node42")
			hide("node81", "node82", "node83", "node84", "node85", "node86", "node87")
		end,
	},

	{
		id = "node87",
		text = _"Hacking Bots",
		code = function()
			Npc:says(_"OK, I'll take us to the hacking area. Also, I'll give you some XP so you can improve your cooling.")
			Tux:add_xp(2000)
			Npc:teleport("TutorialTom-Takeover")
			Tux:teleport("TutorialTom-Takeover")
			tutorial_hacking()
			next("node50")
			hide("node81", "node82", "node83", "node84", "node85", "node86", "node87")
		end,
	},

	{
		id = "node84",
		text = _"Ranged Combat",
		code = function()
			Npc:says(_"OK, I'll take us to the shooting range and give you some armor and a weapon.")
			Npc:teleport("TutorialTom-Ranged")
			Tux:teleport("TutorialTux-Ranged")
			change_obstacle_state("TutorialShootCage", "opened")
			tutorial_ranged_combat()
			next("node30")
			hide("node81", "node82", "node83", "node84", "node85", "node86", "node87")
		end,
	},

	{
		id = "node99",
		text = _"Let me take a short break and practice on my own for a while.",
		code = function()
			Npc:says(_"Ok, I'll be around if you need any more questions answered. Don't hesitate to ask.")
			end_dialog()
		end,
	},
}
