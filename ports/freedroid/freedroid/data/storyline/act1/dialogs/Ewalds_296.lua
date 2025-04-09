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
PERSONALITY = { "Robotic", "Programmaticly Helpful" },
MARKERS = { NPCID1 = "Ewald" },
BACKSTORY = "$$NAME$$ is a Customer Service Droid. While in the storage room below the town bar, $$NAME$$ fell into a sinkhole.
	 Since then, $$NAME$$\'s previous programming has been used to prevent the town\'s backup nuclear reactor from failing. For now...",
RELATIONSHIP = {
	{
		actor = "$$NPCID1$$",
		text = "$$NAME$$ was programmed to work in the town bar for its proprietor, $$NPCID1$$."
	},
}
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		Npc:says(_"HI THERE! I'll be your humble servant for the duration of your stay at Ewald's bar! We hope you enjoy your stay here and come again! Don't forget to tell ALL your friends about us! I LOVE YOU!")
		show("node0")
	end,

	EveryTime = function()
		if (Tux:has_met("Ewalds_296")) then
			Npc:says(_"HI THERE! I'll be your humble servant!", "NO_WAIT")
			Tux:says(_"Uhh, yes, thank you, I know.")
		end

		if (Tux:has_item_backpack("Nuclear Science for Dummies IV")) then
			show("node10")
		end

		if (Ewalds_296_reactor_fix) and
		   (not Ewalds_296_self_sacrifice) then
			show("node11")
		end

		if (Ewalds_296_teleported) then
			show("node30")
		end

		if (Tux:done_quest("An Explosive Situation")) then
			hide("node30") show("node31")
		end
	end,

	{
		id = "node0",
		text = _"Who are you? And why do you talk so... Friendly-like-ish?",
		code = function()
			Npc:says(_"I am a 296 Customer Service Droid, designed to make your day memorable!")
			Tux:says(_"Uh huh. I just-", "NO_WAIT")
			Npc:says(_"I have installed on me the Service with a Smile software package, copyrighted by MEGASYS CORPORATION, to make sure I'm REALLY happy and appealing to customers!")
			Npc:says(_"May I interest you in reading the license to you? Perhaps the terms of usage? The privacy policy?")
			Tux:says(_"Uh, no, I'm fine.")
			Npc:says(_"Oh, that's a real shame, sir and or madam! We have a special Chef's Surprise today! Would you be interested in-", "NO_WAIT")
			Tux:says(_"No, I'm fine, really!")
			hide("node0") show("node1", "node99")
		end,
	},
	{
		id = "node1",
		text = _"What is this place? What are you doing with that funny-looking tool? WHAT VILE PLOTS HAVE YOU BEEN BREWING HERE?!",
		code = function()
			Npc:says(_"Our GREAT and SUPER AWESOME barman EWALD has been brewing fantastic drinks for your enjoyment-", "NO_WAIT")
			Tux:says(_"That's NOT what I meant!")
			hide("node1") show("node2", "node3", "node9")
		end,
	},
	{
		id = "node2",
		text = _"I'm giving you one chance to explain yourself, bot. You'd better make it quick.",
		code = function()
			Npc:says(_"My Advanced Nuclear Maintenance Program v0.93 tells me that this is a standard Parafunken Triple-Core X41Z5 Nuclear Reactor Backup Power supply. Would you be interested in it?")
			Tux:says(_"Your... what? Did Ewald actually install that on you?")
			Npc:says(_"Absolutely!")
			Npc:says(_"The tool I am holding is a SUPER AWESOME standard-issue Parafunken Geiger Counter. May I suggest a sample?")
			Tux:says(_"A super awesome- I mean, a Geiger counter? To measure radiation? Interesting. It's making all those funny clicking sounds... What is it saying?")
			Npc:says(_"It is saying the reactor is nearing terminal radiation overload! AWESOME!")
			Tux:add_quest("An Explosive Situation", _"I found a 296 belonging to Ewald in the maintenance tunnels underneath the town. It claims to be monitoring a damaged nuclear reactor.")
			hide("node2", "node3") show("node4", "node5", "node16")
		end,
	},
	{
		id = "node3",
		text = _"DIE, YOU EVIL PIECE OF SCRAP METAL!",
		code = function()
			--; TRANSLATORS: sir or madam
			Npc:says(_"Sir or ma-")
			Tux:says(_"DIE!")
			Npc:drop_dead()
			end_dialog()
		end,
	},
	{
		id = "node4",
		text = _"Terminal radiation overload? What in the name of ice have you done!?",
		code = function()
			Npc:says(_"I've been trying to extract the expired-", "NO_WAIT")
			Tux:says(_"You... You've been sitting down here, plotting to kill everyone!")
			next("node3")
		end,
	},
	{
		id = "node5",
		text = _"Terminal radiation overload? Isn't that a bit... Dangerous?",
		code = function()
			Npc:says(_"My Maintenance Program v0.93 Glossary tells me the condition of 'Terminal Radiation Overload' can cause a nuclear explosion and EXTREME DEATH!")
			Tux:says(_"Oh. Nice. Does it actually say 'extreme death' in there?")
			Npc:says(_"It most certainly does! This program is the BEST! We have it in 5 different flavors! Care to try some?")
			Tux:says(_"... Thanks, I think I'll pass.")
			Tux:says(_"But... If this nuclear reactor is about to explode... The town up there...")
			Npc:says(_"My data on 'Nuclear Explosion' says it will vaporize ANYTHING within several hundred kilometers! The entire area will be UNINHABITABLE for several decades! Would you like to order anything?")
			Tux:update_quest("An Explosive Situation", _"Ewald's 296 has assured me that the nuclear reactor is about to explode and destroy the town! I have to do something!")
			hide("node4", "node5") show("node6", "node7")
		end,
	},
	{
		id = "node6",
		text = _"Why aren't you calling someone? Why aren't you trying to fix this? You have a maintenance program!",
		code = function()
			Npc:says(_"You would like to see my manager? I don't think that would be necessary, Dave. I mean, sir and or madam.")
			Tux:says(_"Fine, don't call anyone, but fix this thing! It's unstable!")
			Npc:says(_"I've been trying to extract the expired graphite module and replace it with a BRAND NEW, CHEAP one! But my maintenance program does not have data on 'Graphite Module'. I am afraid I can't do it, Dave.")
			Npc:says(_"... Sir and or madam.")
			hide("node6") show("node8")
		end,
	},
	{
		id = "node7",
		text = _"I suppose I might as well order something while I'm here. Give me the menu, please.",
		code = function()
			Npc:says(_"I'm sorry, sir and or madam, we have no menu at the moment.")
			Tux:says(_"All right, then give me some cold water.")
			Npc:says(_"I'm sorry, sir and or madam, we're fresh out of water.")
			Tux:says(_"But you just offered me...")
			Npc:says(_"Sorry!")
			hide("node7")
		end,
	},
	{
		id = "node8",
		text = _"We need to do something. We can't just sit here and wait for it to blow up!",
		code = function()
			Npc:says(_"My DELICIOUS database is insufficient to repair the radiation leak and replace the module!")
			Tux:says(_"All right, so you need more data... How about a sourcebook? Would that help?")
			Npc:says(_"The Maintenance program contains references to the popular Subatomic and Nuclear Science for Dummies series, volume IV.")
			Tux:says(_"Subatomic and Nuclear Science for Dummies, volume IV?. Maybe someone in town has it. I have to go now, there's no time to lose!")
			Npc:says(_"Would you like the check?")
			Ewalds_296_needs_sourcebook = true
			Tux:update_quest("An Explosive Situation", _"If I can get a copy of Subatomic and Nuclear Science for Dummies, Volume IV, the 296 may be able to stop the explosion. I hope someone in town has it!")
			hide("node8")
			end_dialog()
		end,
	},
	{
		id = "node9",
		text = _"How on Earth did you get here?",
		code = function()
			Npc:says(_"While our SUPER AWESOME barman EWALD was restoring his biological energy supply, I went down to the basement to refill the bar taps and get some more soft and tender napkins for our WONDERFUL customers!")
			Npc:says(_"My balance mechanism suddenly went WILD. The ground started SHAKING and the next thing I knew, I was FALLING!")
			Tux:says(_"The floor must have given way. From what I've seen, the whole tunnel system isn't very stable.")
			Npc:says(_"I was looking for LOVELY customers to serve and care for. Then I found this BEAUTIFUL chamber, with this EXPLOSIVE reactor!")
			hide("node9")
		end,
	},
	{
		id = "node10",
		text = _"I have the sourcebook here. Look up whatever you need.",
		code = function()
			Npc:says(_"[b]Processing data, please wait... Updating database, this may take a while...[/b]")
			Npc:says(_"[b]To adjust to the changes, the system must restart.[/b]")
			Npc:says(_"[b]BEEP![/b]")
			Tux:says(_". . .")
			Npc:says(_"... HI THERE! I'll be your humble servant for the duration of your stay in-", "NO_WAIT")
			Tux:says(_"THE REACTOR! What about the reactor? Can you replace the module now?")
			Npc:says(_"Yes, the reactor! Your order has been processed, sir and or madam! Please wait patiently!")
			Ewalds_296_reactor_fix = true
			Tux:update_quest("An Explosive Situation", _"I gave the book to Ewald's 296. Now all I can do is wait while it attempts to repair the reactor.")
			Tux:del_item("Nuclear Science for Dummies IV")
			hide("node10")
			end_dialog()
		end,
	},
	{
		id = "node11",
		text = _"Well? Is the reactor fixed?",
		code = function()
			Npc:says(_"My analysis of the reactor determines the graphite module has melted and can not be replaced.")
			Npc:says(_"The reactor must SPECTACULARLY self-destruct to prevent a nuclear explosion, which would be NOT COOL!")
			Tux:says(_"Oh, so all we had to do all this time was to blow up the reactor. Great. Well, set the timer and let's get out of here!")
			Npc:says(_"The self-destruct mechanism is flawed, and the countdown can not function properly. The mechanism must be operated manually.")
			Tux:says(_"Manually? You mean someone has to stay here and make sure it blows up?")
			Npc:says(_"Affirmative.")
			Npc:says(_"... My maintenance program contains the required data for the procedure.")
			Tux:says(_"You're... Volunteering to do it? But... You'll-", "NO_WAIT")
			Npc:says(_"Unit 296 will be terminated.")
			hide("node11", "node99") show("node12", "node13")
		end,
	},
	{
		id = "node12",
		text = _"OK then, have fun. See you!",
		code = function()
			Npc:says(_"Of course... Have a nice day.")
			Tux:says(_"Yeah, sure. Crazy bot.")
			Tux:update_quest("An Explosive Situation", _"The 296 has volunteered to sacrifice itself in order to safely destroy the reactor. It might be admirable, if it weren't a (particularly annoying) bot.")
			Ewalds_296_self_sacrifice = true
			hide("node7", "node9", "node12", "node13", "node16") show("node99")
			end_dialog()
		end,
	},
	{
		id = "node13",
		text = _"No. No, I won't let you do it! I can't let you die!",
		code = function()
			Npc:says(_"Only this version of the program-", "NO_WAIT")
			Tux:says(_"I don't care! You're willing to sacrifice yourself to save the people up there. That qualifies as a bot worth saving in my eyes.")
			Tux:says(_"I am not letting you die.")
			Npc:says(_"You must not try to stop me, sir and or madam.")
			hide("node12", "node13") show("node14", "node15")
		end,
	},
	{
		id = "node14",
		text = _"I am going to save you, even if... Even if I have to hack you and drag you all the way up!",
		code = function()
			Npc:says(_"You wish to fight, sir and or madam?")
			Tux:says(_"I don't want to hurt you. Follow me, and we can think of a better way to do this.")
			Npc:says(_"Negative. The reactor can only be safely destroyed using the manual self-destruction mechanism.")
			Tux:says(_"All right then. I guess I'll just have to force you to come.")
			Npc:says(_"I cannot allow sir and or madam to come to harm.")
			Tux:update_quest("An Explosive Situation", _"The 296 bravely volunteered to sacrifice itself in order to blow the reactor up safely. I wasn't about to let it throw its life away like that, but as I prepared to hack it and force it to follow me, I was suddenly teleported into town! Wait... Was that an explosion? Oh no...")
			Ewalds_296_self_sacrifice = true
			Ewalds_296_teleported = true
			Tux:teleport("TeleportHomeTarget")
			Npc:teleport("296TeleportTarget")
			hide("node7", "node9", "node12", "node14", "node15", "node16") show("node30", "node99")
			end_dialog()
		end,
	},
	{
		id = "node15",
		text = _"... You're sure you want to do this?",
		code = function()
			Npc:says(_"There is no other way, sir and or madam.")
			Tux:says(_"I understand.")
			Tux:says(_"Good luck, 296. You won't be forgotten.")
			Npc:says(_"Thank you, sir and or madam.")
			Npc:says(_"I must go now. Goodbye.")
			Tux:update_quest("An Explosive Situation", _"The 296 has bravely volunteered to sacrifice itself in order to blow the reactor up safely. A very courageous droid - I'm sorry to see it go.")
			Ewalds_296_self_sacrifice = true
			hide("node7", "node9", "node12", "node14", "node15", "node16") show("node99")
			end_dialog()
		end,
	},
	{
		id = "node16",
		text = _"What's that smashed droid there?",
		code = function()
			Npc:says(_"That is a REALLY FLAT 476 Maintenance droid! I found it when I first came here!")
			Npc:says(_"According to the reactor's BORING repair log, the 476 was supposed to make a monthly system check FIVE DAYS AGO!")
			Tux:says(_"Oh, great. The one droid that was keeping the reactor in check is now a metallic pancake.")
			Npc:says(_"We offer DELICIOUS pancakes-", "NO_WAIT")
			Tux:says(_"I'm not interested!")
			hide("node16")
		end,
	},
	{
		id = "node30",
		text = _"Erm... But didn't you... Uh...",
		code = function()
			Npc:says(_"Allow me to clear up your confusion, sir and or madam!")
			Npc:says(_"My Nick of Time software package allowed me to tap into the town's teleportation network.")
			Npc:says(_"This COMPLETELY AWESOME set of subroutines let me teleport in an iron bar to take my place at the last possible moment!")
			Tux:says(_"And now you're-", "NO_WAIT")
			Npc:says(_"Back in the employ of the GREAT and SUPER AWESOME Ewald!")
			Tux:says(_"Well, I'm glad to see you're not destroyed.")
			Tux:end_quest("An Explosive Situation", _"I found Ewald's 296 alive and well in Ewald's bar! I was sure it was destroyed in that explosion I heard, but it's safe and sound. Well, I guess all's well that ends well.")
			Tux:add_xp(1500)
			show("node31") hide("node30")
		end,
	},
	{
		id = "node31",
		text = _"So, 296, how's it going?",
		code = function()
			Npc:says(_"Great, sir and or madam! The business is flourishing and everything is AMAZINGLY back to normal!")
			Npc:says(_"Would sir and or madam be interested in a refreshing drink, ON THE HOUSE?")
			Tux:says(_"Why, thank you!")
			Tux:heat(-50)
			Npc:says(_"Would sir and or madam want any other service?")
			if (not Ewalds_296_has_ewalds_password) then
				show("node32")
			end
			show("node33") hide("node31")
		end,
	},
	{
		id = "node32",
		text = _"Hmm... How about... Ewald's password?",
		code = function()
			Npc:says(_"Our MAGNIFICENT bartender EWALD has an UNBREAKABLE password! His account is the most secure EVER! NO ONE except for him can get on it!")
			Tux:says(_"What's the password?")
			Npc:says(_"Five asterisks!")
			Tux:says(_"...")
			Npc:says(_"... Maybe I shouldn't have said that.")
			Ewalds_296_has_ewalds_password = true
			hide("node32")
		end,
	},
	{
		id = "node33",
		text = _"I'd like another drink, please.",
		code = function()
			Npc:says(_"Certainly! This one's on the house!")
			Tux:heat(-10)
		end,
	},
	{
		id = "node99",
		text = _"Well, I should really be going now.",
		code = function()
			Npc:says_random(_"Thank you, come again!",
							_"Tell your friends about us!",
							_"We hope you've enjoyed our service!")
			end_dialog()
		end,
	},
}
