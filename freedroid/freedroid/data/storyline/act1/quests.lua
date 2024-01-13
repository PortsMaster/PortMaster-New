--[[
  Copyright (c) 2003 Johannes Prix

  This file is part of Freedroid

  Freedroid is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  Freedroid is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Freedroid; see the file COPYING. If not, write to the 
  Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, 
  MA  02111-1307  USA
]]--

-- Feel free to make any modifications you like.  If you set up 
-- something cool, please send your file in to the Freedroid project.

mission_list {
{
	mission_name = _"Bender's problem",
	mission_description = "Find a cure for Bender, suffering from brain enlargement pills",
},
{
	mission_name = _"The yellow toolkit",
	mission_description = "Retrieve Dixon's lost toolkit",
	completion_code = [=[
		change_obstacle_state("Town-Solar-1", "enabled")
		change_obstacle_state("Town-Solar-2", "enabled")
		change_obstacle_state("Town-Solar-3", "enabled")
		change_obstacle_state("Town-Solar-4", "enabled")
		change_obstacle_state("Town-Solar-5", "enabled")
		change_obstacle_state("Town-Solar-6", "enabled")
		change_obstacle_state("Town-Solar-7", "enabled")
		change_obstacle_state("Town-Solar-8", "enabled")
	]=],
},
{
	mission_name = _"Anything but the army snacks, please!",
	mission_description = "Find energy crystals for Michelangelo",
},
{
	mission_name = _"Novice Arena",
	mission_description = "Defeat the bots in the Novice Arena",
},
{
	mission_name = _"Time to say goodnight",
	mission_description = "Defeat the bots in the Master Arena",
	kill_droids_marked = 1030,
	completion_code = [=[
		change_obstacle_state("MasterArenaExitDoor", "opened")
		display_console_message(_"Master arena cleared. Good job, man.")
		display_big_message(_"Level cleared!")
		update_quest("Time to say goodnight", _"I managed to win the fight in the master arena. Am I really that good, or did I cheat?")
	]=],
},
{
	mission_name = _"Opening a can of bots...",
	mission_description = "Clean out the first sub-level of the warehouse",
	must_clear_level = 1,
	completion_code = [=[
		update_quest("Opening a can of bots...", _"The first level of the warehouse has been cleared of bots; Dixon's men can now safely retrieve the supplies from here.")
	]=],
},
{
	mission_name = _"And there was light...",
	mission_description = "Clean out the second sub-level of the Kevin's Complex",
	must_clear_level = 18,
	completion_code = [=[
		update_quest("And there was light...", _"Hope everything is back to normal now. I better go check with Kevin.")
		display_console_message(_"All hostiles on level disabled.")
		display_big_message(_"Level cleared!")
	]=],
},
{
	mission_name = _"A kingdom for a cluster!",
	mission_description = "Take Kevin's data cube to the cluster maintenance people inside the Red Guard complex",
},
{
	mission_name = _"Opening access to MS Office",
	mission_description = "Reach the disruptor shield generator and take control of it",
},
{
	mission_name = _"Propagating a faulty firmware update",
	mission_description = "Upload faulty firmware to the firmware update server.",
},
{
	mission_name = _"A New Mission From Spencer",
	mission_description = "Board Spencer's stratopod and finish Act 1, for once and for all.",
},
{
	mission_name = _"SADD's power supply",
	mission_description = "Bring energy crystals to SADD",
},
{
	mission_name = _"Tania's Escape",
	mission_description = "Free Tania from underground facility and escort her to the town",
	kill_droids_marked = 2035,
	completion_code = [=[
		if (npc_dead("Tania")) then
			display_big_message(_"Tania died!")
			display_console_message(_"Tania died!")
			if (not Tania_surface) then
				update_quest("Tania's Escape", _"Tania died before escaping her underground bunker. I was unable to protect her.")
			elseif (not Tania_stopped_by_Pendragon) then
				update_quest("Tania's Escape", _"Tania died in the desert while trying to make it to the town. I was unable to protect her.")
				change_obstacle_state("DesertGate-Inner", "opened")
			else
				update_quest("Tania's Escape", _"Tania died while trying to make it to the town. I was unable to protect her.")
			end
		else
			display_big_message(_"Tania made it to the town!")
			display_console_message(_"Tania successfully made it to the town!")
			add_xp(3000)
		end
	]=],
},
{
	mission_name = _"Saving the shop",
	mission_description = "Help Stone pay her tax bill",
	completion_code = [=[
		sell_item("Shotgun shells", 1, "Stone")
		sell_item(".22 LR Ammunition", 1, "Stone")
	]=],
},
{
	mission_name = _"Doing Duncan a favor",
	mission_description = "Find Koan",
},
{
	mission_name = _"Tutorial Movement",
	mission_description = "Learn to Move",
},
{
	mission_name = _"Tutorial Melee",
	mission_description = "Learn to fight bots hand-to-hand",
	kill_droids_marked = 2037,
	completion_code = [=[
		display_big_message(_"Melee droids destroyed!")
	]=],
},
{
	mission_name = _"Tutorial Shooting",
	mission_description = "Learn to shoot bots",
	kill_droids_marked = 4037,
	completion_code = [=[
		display_big_message(_"Shooting range cleared!")
	]=],
},
{
	mission_name = _"Tutorial Hacking",
	mission_description = "Learn to hack bots",
	kill_droids_marked = 3037,
	completion_code = [=[
		display_big_message(_"Hacking area cleared!")
	]=],
},
{
	mission_name = _"A strange guy stealing from town",
	mission_description = "Find Kevin",
},
{
	mission_name = _"Deliverance",
	mission_description = "Deliver list from Francis to Spencer",
},
{
	mission_name = _"Gapes Gluttony",
	mission_description = "Deliver a nice meal to Will Gapes",
},
{
	mission_name = _"Tutorial Upgrading Items",
	mission_description = "Learn to upgrade items",
	completion_code = [=[
		display_console_message(_"Tutorial Upgrading Items finished!")
	]=],
},
{
	mission_name = _"Droids are my friends",
	mission_description = "Clean out the old server room",
	must_clear_level = 58,
	completion_code = [=[
		update_quest("Droids are my friends", _"The old server room is now secured.")
	]=],
},
{
	mission_name = _"An Explosive Situation",
	mission_description = "Save the town from nuclear disaster",
},
{
	mission_name = _"Open Sesame",
	mission_description = "Hack the Hell Fortress Gate Access Server and find the gate.",
},
{
	mission_name = _"Jennifer's Toolbox",
	mission_description = "Find red toolbox and return it to Jennifer",
},
{
	mission_name = _"24_label_test_quest",
	mission_description = "This is a test quest",
},
{
	mission_name = _"24_dude_test_quest",
	mission_description = "This is also a test quest",
},
{
	mission_name = _"24_guy_death_quest",
	mission_description = "This is another test quest",
	kill_droids_marked = 2025,
	completion_code = [=[
		display_big_message("24 guy death quest solved")
	]=],
},
{
	mission_name = _"Ticket's price - crystal",
	mission_description = "Bring one dilithium crystal to Bob for his 614",
	completion_code = [=[
		change_obstacle_state("ToTheWorld2PortalGate", "opened")
		add_xp(1000)
	]=],
},
{
	mission_name = _"Bot in need",
	mission_description = "Bring 999 Cerebrum some add-ons for his needs",
	completion_code = [=[
		add_xp(500)
	]=],
},

}

