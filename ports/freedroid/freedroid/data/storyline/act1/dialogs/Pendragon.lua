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
PERSONALITY = { "Militarist", "Aggressive", "Confident" },
MARKERS = { QUESTID1 = "Doing Duncan a favor" },
PURPOSE = "$$NAME$$ helps improve Tux\'s skill. Tux must bribe $$NAME$$ in order to complete the $$QUESTID1$$ quest"
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		desertgate_tax = 0
		if (not HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
			show("node0")
		else
			show("Pendragon_postfirmwareupdate")
		end

	end,

	EveryTime = function()

		if (Tania_position == "town_gate") and (not Tania_met_Pendragon) then
			Npc:says(_"Halt! Who goes there?")
			Tux:says(_"Someone I found in the desert, Tania.")
			--; TRANSLATORS: %s = Tux:get_player_name()
			Npc:says(_"%s, you may enter.", Tux:get_player_name())
			Npc:says(_"However, you will have to talk to Spencer before you bring your friend, Tania, into the town.")
			change_obstacle_state("DesertGate-Inner", "opened")
			Tania:teleport("W-enter-2") --Ensure that Tania is on Level 0!
			Tania:set_state("patrol")
			start_chat("Tania")
			end_dialog()
		elseif (not Pendragon_OK_w_Tania) and (Spencer_Tania_decision) then --Tania Escape Quest stuff
			if (not Tux:done_quest("Tania's Escape")) then
				Npc:says(_"Tania has been waiting to talk to you.")
			else
				Npc:says(_"Spencer says it is OK?")
				Npc:says(_"Well that is good enough for me.")
				Npc:says(_"She may enter.")
				Pendragon_OK_w_Tania = true
				end_dialog()
			end
		end

		if ((HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) and (not Pendragon_post_firmware_update)) then
			show("Pendragon_postfirmwareupdate")
		end

		show("node99")

		if (not guard_follow_tux) then
			show("node40")
		end

		if (desertgate_tax ~= 0) then
			if (cmp_obstacle_state("DesertGate", "closed")) then
				Npc:says(_"Got the money?")
				show_if((Tux:get_gold() >= desertgate_tax), "node45")
			end
			hide("node40")
		end

		if (cmp_obstacle_state("DesertGate", "opened")) or
		(Tux:has_met("Tania")) then
			hide("node40", "node45")
		end
	end,

	{
		id = "node0",
		text = _"Hi! I'm new here.",
		code = function()
			Npc:says(_"You don't say. I'm not living here either. I'm just on vacation.")
			Npc:says(_"Normally I'm a fighter. But now I try to relax, chill, take it easy and have a lot of fun.")
			Npc:says(_"And in case you couldn't tell, that was sarcasm.")
			Npc:set_name("Fighter")
			hide("node0") show("node1", "node2")
		end,
	},
	{
		id = "node1",
		text = _"Could you teach me how to fight?",
		code = function()
			if (Pendragon_beaten_up) then
				Npc:says(_"NO! NO! Er... I mean, not right now. I am busy. Come again later.")
			else
				Npc:says(_"Sure. I can help you.", "NO_WAIT")
				Npc:says(_"For a price. A hundred circuits should be enough.")
				hide("node1", "node99") show("node11", "node19")
			end
		end,
	},
	{
		id = "node2",
		text = _"Do you have a name?",
		code = function()
			Npc:says(_"I go by Pendragon, because I can pull a knife from thin air.")
			Npc:says(_"And you?")
			--; TRANSLATORS: %s = Tux:get_player_name()
			Tux:says(_"%s, because it is my name?", Tux:get_player_name())
			if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				--; TRANSLATORS: %s = Tux:get_player_name()
				Npc:says(_"%s. Hah. They won't remember that name the way you think, bird.", Tux:get_player_name())
			end
			Npc:set_name("Pendragon - Fighter")
			hide("node2")
		end,
	},
	{
		id = "node11",
		text = _"Teach me the basic stuff.",
		code = function()
			Npc:says(_"Are you sure?", "NO_WAIT")
			Npc:says(_"I only accept students that already have some experience in fighting bots.")
			hide("node11", "node19") show("node12", "node29")
		end,
	},
	{
		id = "node12",
		text = _"Yes (costs 100 valuable circuits, 5 training points)",
		code = function()
			if (Tux:get_skill("melee") < 1) then
				if (Tux:train_skill(100, 5, "melee")) then
					Tux:del_health(25)
					Npc:says(_"Let us begin then.")
					Npc:says(_"Come closer...")
					Npc:says(_"HA!")
					Tux:says(_"Ouch! What the hell are you doing?")
					Npc:says(_"Lesson number one. Never trust the opponent.")
					Tux:says(_"Just let me get up an -- ouch! Stop it.")
					Npc:says(_"Lesson number two. The bots have no mercy.")
					Npc:says(_"They won't let you get up if you fall down. They will kill you.")
					Npc:says(_"Now, lesson number -- ugh! That hurt!")
					Tux:says(_"Lesson number three. Never underestimate the enemy.")
					Npc:says(_"Ugh. Yes. You are correct.")
					Npc:says(_"I need to... Lie down for a while... My head hurts...")
					Npc:says(_"Lesson number four. Never hit your sparring partner with full force.")
					Npc:says(_"I think you broke my ribs...")
					Npc:says(_"This is enough training for today.")
					Pendragon_beaten_up = true
				else
					if (Tux:get_gold() >= 100) then
						Npc:says(_"You don't have enough experience. I can't teach you anything more right now.")
						Npc:says(_"First collect more experience. Then we can go on.")
					else
						Npc:says(_"You don't have enough valuable circuits on you! Come back when you have the money.")
					end
				end
			else
				Npc:says(_"Hey, wake up! I taught you that stuff already. Go practice on the bots, if you really want more training.")
			end
			hide("node12")
		end,
	},
	{
		id = "node19",
		text = _"Teach me how to smash concrete blocks with my bare hands.",
		code = function()
			Npc:says(_"Oh, Linarian, you amuse me so.", "NO_WAIT")
			Npc:says(_"You are quite an ambitious fellow.")
			Npc:says(_"First learn the basics. Spend a year working on that, and then I'll be able to teach you some advanced tricks.")
			hide("node19") show("node20")
		end,
	},
	{
		id = "node20",
		text = _"Teach me Ninjitsu.",
		code = function()
			Npc:says(_"Go away.")
			hide("node20") show("node21")
		end,
	},
	{
		id = "node21",
		text = _"I want to know the Mega Uber Crazy Double-Fang Wolf-Sunlight I-Like-Tea Death Touch of Major Destruction Flesh-Bursting Attack!",
		code = function()
			Npc:says(_"Wow.", "NO_WAIT")
			Npc:says(_"You have a very rich imagination. There is no such thing. Get a life.")
			hide("node21") show("node22")
		end,
	},
	{
		id = "node22",
		text = _"I want to know the forbidden skill of furuike ya kawazu tobikomu mizu no oto.",
		code = function()
			Npc:says(_"This is starting to make me angry. Shut up and go away.")
			hide("node22") show("node23")
		end,
	},
	{
		id = "node23",
		text = _"Teach me how to flip out and kill people!",
		code = function()
			Npc:says(_"*sigh*")
			Npc:says(_"I will teach you to keep your mouth shut when told to. Observe very carefully.")
			Npc:says(_"Make sure you pay attention.")
			Npc:says(_"TAKE THIS!")
			Tux:says(_"OW!")
			if (not Tux:del_health(40)) then
				if (not Tux:del_health(20)) then
					Tux:del_health(5)
				end
			end
			Npc:says(_"Now go away.")
			hide("node23")
			end_dialog()
		end,
	},
	{
		id = "node29",
		text = _"Enough for now.",
		code = function()
			Npc:says(_"Fine.")
			hide("node11", "node12", "node19", "node20", "node21", "node22", "node23", "node29") show("node1", "node99")
		end,
	},
	{
		id = "node40",
		text = _"I want to pass the gate.",
		code = function()
			Npc:says(_"Fine.")
			Tux:says(_"Can you open it, please?")
			Npc:says(_"Yes, I can.")
			Tux:says(_"Thanks.")
			Tux:says(_"Uhm...")
			Tux:says(_"Will you do it?")
			Npc:says(_"Yes. But you have to pay a one-time tax for it first.")
			if (not Town_NorthGateGuard_tux_nickname_loon) then
				Npc:says(_"Pay 30 circuits and you may pass.")
				desertgate_tax = 30
			else
				Npc:says(_"You can enter the desert, but first you'll have to pay 40 circuits.")
				desertgate_tax = 40
			end
			if (Tux:get_gold() >= desertgate_tax) then
				show("node45")
			end
			hide("node40")
		end,
	},
	{
		id = "node45",
		text = _"Yes, I've got the money.",
		code = function()
			if (Tux:get_gold() >= desertgate_tax) then
				if (desertgate_tax == 30) then
					Npc:says(_"Good.")
					Tux:says(_"Here, take it.")
					Npc:says(_"You may pass.")
					if (Tux:has_quest("Doing Duncan a favor")) then
						Tux:update_quest("Doing Duncan a favor", _"Pendragon opened the gate for me, but I had to pay a little tax.")
					end
				elseif (desertgate_tax == 40) then
					Npc:says(_"At last.")
					Tux:says(_"Here, let me pass now.")
					Npc:says(_"You may pass, Loon.")
					Npc:says(_"But don't expect any help in there.")
					if (Tux:has_quest("Doing Duncan a favor")) then
						Tux:update_quest("Doing Duncan a favor", _"Pendragon opened the gate for me, but I had to pay a tax.")
					end
				end
				Tux:del_gold(desertgate_tax)
				desertgate_tax = 0
				change_obstacle_state("DesertGate", "opened")
			else
				Npc:says(_"Don't try to trick me, duck.") --just in case...
				Npc:says(_"Come back if you have the bucks!")
			end
			hide("node45")
			end_dialog()
		end,
	},
	{
		id = "Pendragon_postfirmwareupdate",
		text = _"Hi!",
		code = function()
			Npc:says(_"What do you want?")
			Pendragon_post_firmware_update = true
			show("Pendragon_postfirmwareupdate_goodbye", "Pendragon_postfirmwareupdate_cont",
							"Pendragon_postfirmwareupdate_brag")
			hide("Pendragon_postfirmwareupdate")
		end,
	},
	{
		id = "Pendragon_postfirmwareupdate_goodbye",
		text = _"Nothing...",
		code = function()
		      Npc:says(_"Get lost. Don't come back.")
		      hide("Pendragon_postfirmwareupdate_goodbye","Pendragon_postfirmwareupdate_cont",
							"Pendragon_postfirmwareupdate_brag")
		      end_dialog()
		end,
	},
	{
		id = "Pendragon_postfirmwareupdate_cont",
		text = _"How's it going?",
		code = function()
			Npc:says(_"Listen to me carefully, bird.")
			Npc:says(_"Maybe it looks like you saved the day, but I know better than that. You're nothing but a duck. You're not a human.")
			Npc:says(_"As far as I'm concerned, you just landed here and stole our show. The Red Guard had everything under control, and we did not need your stupid flippers waddling in our affairs.")
			Npc:says(_"And don't think that just because Spencer is excited, he's on your side.")
			Npc:says(_"He may not share his plans with the rest of us, but I know him well enough to know that he's using you.")
			Npc:says(_"He's been using you since he did you a favor and defrosted you, and your stupid bird brain can't even comprehend that. So don't get cocky.")
			Npc:says(_"You'll get what you deserve, soon enough, just like all the other bird aliens.")
			if (not Pendragon_beaten_up) then
				  Npc:says(_"HA!")
				  Tux:del_health(10)
				  Tux:says(_"Ouch!")
			end
			hide("Pendragon_postfirmwareupdate_goodbye", "Pendragon_postfirmwareupdate_cont",
							"Pendragon_postfirmwareupdate_brag")
			end_dialog()
		end,
	},
	{
		id = "Pendragon_postfirmwareupdate_brag",
		text = _"I want to see a better attitude around here. You'd better be nice to me.",
		code = function()
			if (Pendragon_beaten_up) then
				Tux:says(_"Remember our lesson?")
				Npc:says(". . .")
			else
				Npc:says(_"You impudent little eggspawn.")
				next("Pendragon_postfirmwareupdate_cont")
			end
			hide("Pendragon_postfirmwareupdate_goodbye", "Pendragon_postfirmwareupdate_cont",
							"Pendragon_postfirmwareupdate_brag")
			end_dialog()
		end,
	},
	{
		id = "node99",
		text = _"See you later.",
		code = function()
			if (not HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				Npc:says_random(_"Have courage.",
								_"Be strong.")
			else
				if (Pendragon_beaten_up) then
					Npc:says(". . .")
				else
					Npc:says_random(_"You'll see. Big hero. You'll learn your place soon.",
								_"I hate birds.")
				end
			end
			end_dialog()
		end,
	}
}
