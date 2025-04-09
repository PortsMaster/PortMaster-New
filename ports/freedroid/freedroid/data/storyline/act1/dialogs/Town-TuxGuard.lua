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
PERSONALITY = { "Militaristic", "Condescending" },
MARKERS = { NPCID1 = "Spencer" },
PURPOSE = "When Tux fist visits the town, $$NAME$$ will escort Tux to visit $$NPCID1$$. After that, $$NAME$$ will patrol the town."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	EveryTime = function()
		if (guard_follow_tux) then
			Npc:says(_"I'm to keep an eye on you until you talk to Spencer.")
			Npc:set_name("Red Guard Escort")
		elseif (tux_has_joined_guard) then
			if ((HF_Spencer_teleported) and (not HF_Town_TuxGuard_post_firmware_update)) then
				next("node30")
				HF_Town_TuxGuard_post_firmware_update = true
			elseif HF_Spencer_teleported then
				Npc:says(_"Hello again.")
			else
				Npc:says(_"I'll let you be now; no need to suspect one of our own!")
			end
		else
			Npc:says(_"Spencer seems to think that you are harmless. Go about your business.")
			if (Town_NorthGateGuard_tux_nickname_loon) then
				Npc:says(_"Babysitting a loon... Now I can say I've done it all!")
			end
		end
		show_if((not Tux:has_met("Spencer")), "node20")
		show("node99")
	end,

	{
		id = "node20",
		text = _"Where can I find Spencer?",
		code = function()
			if (not knows_spencer_office) then
				Npc:says(_"He's usually in his office in the citadel.")
				Npc:says(_"Head down the main corridor until you pass the citadel gates.")
				Npc:says(_"His office has purple walls, you won't miss it.")
				Tux:says(_"Okay.")
				knows_spencer_office = true
			else
				Npc:says_random(_"Come on, you know that already.",
								_"I'm pretty sure you know that...",
								_"We told you! Stop stalling!")
			end
			hide("node20")
		end,
	},
	{
		id = "node30",
		text = "BUG, REPORT ME! Town-TuxGuard node30 -- Post Firmware Update",
		code = function()
			Tux:says(_"Hello again.")
			Npc:says(_"Well hey, it's you.")
			Npc:says(_"I remember you from way back, when you were just the new bird in the tree. Hehe.")
			if (Town_NorthGateGuard_tux_nickname_loon) then
				Npc:says(_"Hah, and we used to call you 'loon'! Good old times.")
				Tux:says(_"Haha, yeah... I guess...")
			else
				Tux:says(_"Yes, that was a while ago...")
			end
			Npc:says(_"And it looks like you've been up to a lot since then.")
			Tux:says(_"That's true. I did manage to pretty much save the entire town in the mean time.")
			Npc:says(_"Mhmmm. Yeah, that's pretty cool.")
			show("node31", "node32")
		end,
	},
	{
		id = "node31",
		text = _"What? Aren't you impressed?",
		code = function()
			Npc:says(_"Oh, sure, I mean, we're in your eternal debt, and all that.")
			Tux:says(_"... But...?")
			Npc:says(_"Well, you see, it's just that I've been around, and I've seen and heard some things in my time.")
			Npc:says(_"And it's just... not that high up on the scale, as far as epic deeds go.")
			Npc:says(_"No offense.")
			show("node33", "node34", "node35") hide("node31")
		end,
	},
	{
		id = "node32",
		text = _"How's it going out there?",
		code = function()
			Npc:says(_"Much of the same, really.")
			Npc:says(_"It's going to get a little easier from here on, without all those bots wanting to kill us.")
			Npc:says(_"Spencer's pretty deeply impressed over there. He's been under a lot of stress since the Great Assault began, you know.")
			Npc:says(_"He knows as well as anyone else that being a leader isn't about being popular, but it still takes its toll.")
			Npc:says(_"He won't admit it, but the time between you heading out and all the bots dropping was a roller coaster for him. Absolutely nerve wracking.")
			Npc:says(_"I've never seen him as desperate as when you were in here. And I've never seen him as happy as when he dragged us to the teleporter.")
			hide("node32")
		end,
	},
	{
		id = "node33",
		text = _"I see. Those must have been some very impressive deeds.",
		code = function()
			Npc:says(_"Oh, you bet. Those were the good old days...")
			Npc:says(_"Although... Well, I don't remember anyone saving a town half-full of people in the middle of a flaming apocalypse.")
			Tux:says(_"I suppose that doesn't happen very often.")
			Npc:says(_"...")
			--; TRANSLATORS: %s = Tux:get_player_name()
			Npc:says(_"Hah hah! You know something, you're all right, %s.", Tux:get_player_name())
			Town_NorthGateGuard_tux_nickname_loon = false
			hide("node33", "node34", "node35")
		end,
	},
	{
		id = "node34",
		text = _"Are you out of your mind? Do you know the danger I've been through?!",
		code = function()
			Npc:says(_"Well, ok, friend, keep your voice down...")
			Tux:says(_"I've risked my life for all of you, and this is what I get? 'Eh, it's pretty cool, it's not that high up on the scale'?!")
			Npc:says(_"Well, I said no offense!")
			Tux:says(_"Is there even a scale for these things? How would you even quantify where something is on the scale? What do I have to do, lose a flipper?!")
			Npc:says(_"Calm down already, I'm sorry! I'll just... stay back here, all right? You calm down now and... Take a walk around...")
			Npc:set_state("home")
			Tux:says(_"Oh, all right, I'll take a walk now... I'll just be careful not to step on the ARMIES OF BOTS I TOOK DOWN BY MYSELF, thank you very much!")
			Npc:says(_"Yikes...")
			hide("node33", "node34", "node35", "node32")
			end_dialog()
		end,
	},
	{
		id = "node35",
		text = _"Well, I think I deserve a little more credit than that...",
		code = function()
			Npc:says(_"Hrmm... I suppose, now that I look around, you're probably right.")
			Npc:says(_"I shouldn't underestimate what you've done for us. I'll be honest with you: we were in pretty bad shape back there.")
			if (Tux:done_quest("Opening a can of bots...")) then
				Npc:says(_"Even with the supplies from the warehouse, if the factory was to continue spewing out bots, I think a lot of us would've lost hope completely.")
			end
			if (Tux:done_quest("Anything but the army snacks, please!")) then
				Npc:says(_"I remember people would go a couple of days at a time without eating at all, just because all we had were the military rations... I'm not sure what's worse, you know, dying by starvation, by bots or by that sludge.")
				Npc:says(_"Getting our kitchen back on track literally brought some taste back to life.")
			end
			if (Dixon_mood) then
				if (Dixon_mood < 0) then
					Npc:says(_"And I saw Dixon after he talked to you - he was so happy, you could think nothing was ever wrong. Whatever you talked about, the result was... Impressive.")
				elseif (Dixon_mood <= 120) then
					Npc:says(_"I know you definitely made some people angry along the way, but you gotta look at how far we've come. The apocalypse doesn't feel so bad anymore.")
				else
					Npc:says(_"But it wasn't all roses... I remember visiting Dixon one day after he talked to you. I couldn't see his face, but something was... Very different about him.")
					Npc:says(_"I don't know what you did to him, but it changed him for the worse.")
					Npc:says(_"The price we pay for salvation...")
				end

			end
			Npc:says(_"All those things you did... Well, you did good.")
			hide("node33", "node34", "node35")
		end,
	},
	{
		id = "node99",
		text = _"I'll be going then.",
		code = function()
			if (guard_follow_tux) then
				Npc:says_random(_"Not without me, you won't.",
								_"I'll be watching you, then.",
								_"Hey, wait up!")
			else
				Npc:says(_"Mhmmm.")
			end
			if (Town_NorthGateGuard_tux_nickname_loon) then
				--; TRANSLATORS: %s = Tux:get_player_name()
				Npc:says(_"%s... the Loon", Tux:get_player_name())
			end
			end_dialog()
		end,
	},
}
