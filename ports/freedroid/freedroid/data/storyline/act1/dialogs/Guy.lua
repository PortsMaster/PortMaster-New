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
PURPOSE = "$$NAME$$ is a character used for Debug purposes",
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

local function guy_fail(test, ...)
	print(FDutils.text.highlight("ERROR! The following test failed:", "red"))
	print(FDutils.text.highlight(test, "red"))
	npc_says("%s failed!" ,test , "NO_WAIT")
	end_dialog()
	exit_game(1)
end

return {
	FirstTime = function()
---------------------------------------------------------- HAS_MET
		if (not Tux:has_met("Guy")) then
			Npc:says("HAS MET test 1 succeeded", "NO_WAIT")
		else
			guy_fail("HAS MET")
		end

		if (not Tux:has_quest("24_guy_death_quest")) then
			Tux:add_quest("24_guy_death_quest", "Quest to check if droid markers work.")
		end

		Npc:says("This text is only shown as you speak to this character the first time.")
	end,

	EveryTime = function()

		Guy_dialog_executing = true

		-- Tux:says_random..
		Tux:says_random("1", "2", "3", "4", "5", "NO_WAIT")
		Tux:says_random("1", "2", "3", "4", "5", "NO_WAIT")
		Tux:says_random("1", "2", "3", "4", "5", "NO_WAIT")
		Tux:says_random("1", "2", "3", "4", "5", "NO_WAIT")
		Tux:says_random("1", "2", "3", "4", "5", "NO_WAIT")
		Tux:says_random("1", "2", "3", "4", "5", "NO_WAIT")

		Tux:says("Tux:says()", "NO_WAIT")
		Npc:says("Npc:says()", "NO_WAIT")
		cli_says("cli_says()", "NO_WAIT")
		Npc:says("", "NO_WAIT") -- extra linebreak for cli_says()

		GuyArray = {"one", "two", "three"}
		for var in ipairs(GuyArray) do
			Npc:says(GuyArray[var], "NO_WAIT")
		end

		next("node0")
	end,

	{
		id = "node0",
		text = "RUNNING TEST NODE",
		code = function()
			show("node0")
			hide("node0")
---------------------------------------------------------- ITEM
			Tux:add_item("Laser Scalpel")
			Tux:add_item(".22 Automatic", 2)
			if (Tux:has_item(".22 Automatic")) then
				Npc:says("ADD ITEM test 1 succeeded", "NO_WAIT")
			else
				guy_fail("ADD ITEM 1")
			end

			if (Tux:has_item_backpack(".22 Automatic")) then
				Npc:says("ADD ITEM test 2 succeeded", "NO_WAIT")
			else
				guy_fail("ADD ITEM 2")
			end

			if (Tux:has_item_equipped("Laser Scalpel")) then
				Npc:says("ADD ITEM test 3 succeeded", "NO_WAIT")
			else
				guy_fail("ADD ITEM 3")
			end

			-- ru654
			--[[ NOTE we need del_item_equipped() or unequipp_item()
			Tux:del_item("Laser Scalpel")
			if (not Tux:has_item("Laser Scalpel")) then
				Npc:says("DEL ITEM 1 test succeeded", "NO_WAIT")
			else
				guy_fail("DEL ITEM 1")
			end
			]]--

			Tux:del_item_backpack(".22 Automatic", 2)
			if (not Tux:has_item_backpack(".22 Automatic")) then
				Npc:says("DEL ITEM test 2 succeeded", "NO_WAIT")
			else
				guy_fail("DEL ITEM 2")
			end
---------------------------------------------------------- FACTION
			npc_faction("self", "Guy - self")
			npc_faction("ms", "Guy - ms")
			npc_faction("redguard", "Guy - redguard" )
			npc_faction("resistance", "Guy - resistance")
			npc_faction("civilian", "Guy - civilian")
			npc_faction("crazy", "Guy - crazy")
			npc_faction("singularity", "Guy - singularity")
			npc_faction("neutral", "Guy - neutral")
---------------------------------------------------------- HEALTH
			Tux:heal()
			Tux:hurt(1)
			Tux:hurt(-1)
			if (Tux:get_hp() == 60) then
				Npc:says("HEALTH test 1 succeeded", "NO_WAIT")
			else
				guy_fail("HEALTH 1")
			end

			if (Tux:get_max_hp() == 60) then
				Npc:says("HEALTH test 2 succeeded", "NO_WAIT")
			else
				guy_fail("HEALTH 2")
			end
---------------------------------------------------------- COOL
			Tux:heat(1)
			Tux:heat(-1)
			if (Tux:get_cool() == 100) then
				Npc:says("COOL test 1 succeeded", "NO_WAIT")
			else
				guy_fail("COOL 1")
			end
---------------------------------------------------------- TELEPORT
			Tux:teleport("24-tux1")
			Tux:teleport("24-tux2")
			Npc:teleport("24-guy1")
			Npc:teleport("24-guy2")
			Dude:teleport("24-dude1")
			Dude:teleport("24-dude2")
---------------------------------------------------------- SKILLS
			--Npc:says(Tux:get_skill("programming"))
			if (not Tux:has_met("Guy")) then
				Tux:improve_skill("programming")
				if (Tux:get_skill("programming") == 1) then
					Npc:says("SKILL test 1 succeeded", "NO_WAIT")
				else
					guy_fail("SKILL 1")
				end
			else
				Tux:says("Skipping SKILL test 1 due to missing possibility to downgrade skills!")
			end
---------------------------------------------------------- PROGRAMS
			Tux:improve_program("Ricer CFLAGS")
			Tux:downgrade_program("Ricer CFLAGS")
			if (Tux:get_program_revision("Ricer CFLAGS") == 0) then
				Npc:says("PROGRAM test 1 succeeded", "NO_WAIT")
			else
				guy_fail("PROGRAM 1")
			end
---------------------------------------------------------- QUESTS
			if (not Tux:has_met("Guy")) then
				if (not Tux:has_quest("24_dude_test_quest")) then
					Npc:says("QUEST test 1 succeeded", "NO_WAIT")
				else
					guy_fail("QUEST 1")
				end
				Tux:add_quest("24_dude_test_quest", "Add 24 dude quest.")
			else
				Tux:says("Skipping QUEST test 1 due to missing possibility to remove quests!")
			end

			if (Tux:has_quest("24_dude_test_quest")) then
				Npc:says("QUEST test 2 succeeded", "NO_WAIT")
			else
				guy_fail("QUEST 2")
			end
			Tux:update_quest("24_dude_test_quest", "Update 24 dude quest.")

			if (not Tux:has_met("Guy")) then
				if (not Tux:done_quest("24_dude_test_quest")) then
					Npc:says("QUEST test 3 succeeded", "NO_WAIT")
				else
					guy_fail("QUEST 3")
				end

				Tux:end_quest("24_dude_test_quest", "Complete 24 dude quest.")
				if (Tux:done_quest("24_dude_test_quest")) then
					Npc:says("QUEST test 4 succeeded", "NO_WAIT")
				else
					guy_fail("QUEST 4")
				end
			else
				Tux:says("Skipping QUEST test 3 due to missing possibility to remove quests!")
				Tux:says("Skipping QUEST test 4 due to missing possibility to remove quests!")
			end

			if (Tux:has_met("Guy")) then -- need to have met guy to let the DeadGuy die...
				if (Tux:done_quest("24_guy_death_quest")) then -- check droid markers
					Npc:says("QUEST test 5 succeeded","NO_WAIT")
				else
					guy_fail("QUEST 5")
				end
			else
				Tux:says("Skipping QUEST test 5, we need to have met Guy...")
			end

---------------------------------------------------------- OBSTACLES

			change_obstacle_message("24_guy_sign", _"Guy signmessage B")
			display_big_message("Sign message changed from")
			display_big_message("Guy signmessage A' to 'Guy signmessage B'")

			if (cmp_obstacle_state("24_guy_door", "opened")) then
				Npc:says("OBSTACLE test 1 succeeded", "NO_WAIT")
			else
				guy_fail("OBSTACLE 1")
			end
			change_obstacle_state("24_guy_door", "closed")
			if (cmp_obstacle_state("24_guy_door", "closed")) then
				Npc:says("OBSTACLE test 2 succeeded", "NO_WAIT")
			else
				guy_fail("OBSTACLE 2")
			end
			change_obstacle_state("24_guy_door", "opened") -- 6 = door
			change_obstacle_type("24_guy_door", "1")
			if (get_obstacle_type("24_guy_door") == 1) then
				Npc:says("OBSTACLE test 3 succeeded", "NO_WAIT")
			else
				guy_fail("OBSTACLE 3")
			end
			change_obstacle_type("24_guy_door", "6") -- set it back to door

---------------------------------------------------------- NPC DEATH TEST
			if (not Tux:has_met("Guy")) then
				if (not DeadGuy:is_dead()) then
					Npc:says("NPC DEATH test 1 succeeded", "NO_WAIT")
				else
					guy_fail("NPC DEATH 1")
				end

				DeadGuy:drop_dead() -- kill Dude
			end

			if not (running_benchmark()) then -- remember: our dialog validator is quite dump :(
				if (DeadGuy:is_dead()) then
					Npc:says("NPC DEATH test 2 succeeded", "NO_WAIT")
				else
					guy_fail("NPC DEATH 2")
				end
			end

			-- one day we might be able to revive DeadGuy

			--[[ if (not Dude:is_dead()) then
			Npc:says("NPC DEATH test 3 succeeded", "NO_WAIT")
		else
			guy_fail("NPC DEATH 3")
			end ]]--
---------------------------------------------------------- FACTION DEATH TEST
			if (not Tux:has_met("Guy")) then
				if (not FactionDeadBot:is_dead()) then  -- it's alive
					Npc:says("FACTION DEATH test 1 succeeded", "NO_WAIT")
				else
					guy_fail("FACTION DEATH 1")
				end

				kill_faction("test") -- kill test faction

				if not (running_benchmark()) then -- remember: our dialog validator is quite dump :(
					if (FactionDeadBot:is_dead()) then -- we killed it, it's dead
						Npc:says("FACTION DEATH test 2 succeeded", "NO_WAIT")
					else
						guy_fail("FACTION DEATH 2")
					end
				end
				-- @TODO: implement revive and additional checks
				respawn_level(24) --respawn level, now check if bot is alive again
				if not (running_benchmark()) then -- remember: our dialog validator is quite dump :(
					if (not FactionDeadBot:is_dead()) then --it's alive again
						Npc:says("FACTION DEATH test 3 succeeded", "NO_WAIT")
					else
						guy_fail("FACTION DEATH 3")
					end
				end
				-- now check if kill_faction with no_respawn works
				kill_faction("test", "no_respawn")
				if not (running_benchmark()) then -- remember: our dialog validator is quite dump :(
					if (FactionDeadBot:is_dead()) then -- we killed it, it's dead
						Npc:says("FACTION DEATH test 4 succeeded", "NO_WAIT")
					else
						guy_fail("FACTION DEATH 4")
					end
				end
					-- now respawn and check if its still dead.
				respawn_level(24)
				if not (running_benchmark()) then -- remember: our dialog validator is quite dump :(
					if (FactionDeadBot:is_dead()) then -- we killed it, no_respawn was given, it should still be dead
						Npc:says("FACTION DEATH test 5 succeeded", "NO_WAIT")
					else
						guy_fail("FACTION DEATH 5")
					end
				end
			end
---------------------------------------------------------- EVENTS
			if not (running_benchmark()) then
				if (l24_event_test == "works" ) then
					Npc:says("EVENT test 1 (map label) succeeded", "NO_WAIT")
				else
					guy_fail("EVENT test 1 (map label)")
				end
			end

			if not (running_benchmark()) then
				if (DeadGuy_death_trigger == "works" ) then
					Npc:says("EVENT test 2 (death event) succeeded", "NO_WAIT")
				else
					guy_fail("EVENT test 2 (death event)")
				end
			end

			Guy_24_to_70_passed = false --reset these here.
			Guy_70_to_24_passed = false -- needed because we might have walked around manually
			if not (running_benchmark()) then
				-- tux is on lvl 24 currently
				teleport("24-exit-level-70") -- teleport from level 24 to level 70, to a label
				if (Guy_24_to_70_passed) then -- the from24to70 event worked!    the event also teleport tux back to level 24 (from70to24!)...
					Npc:says("EVENT test 3 (Entering 70, exiting 24) succeeded", "NO_WAIT")
				else
					guy_fail("EVENT test 3 (Entering 70, exiting 24)")
				end

				if (Guy_70_to_24_passed) then -- ... which sets this as true.   tux is also teleported to label 24-tux2
					Npc:says("EVENT test 4 (Entering 24, exiting 70) succeeded", "NO_WAIT")
				else
					guy_fail("EVENT test 4 (Entering 24, exiting 70)")
				end
			end




---------------------------------------------------------- Gold
			if (Tux:get_gold() == 0) then
				Npc:says("GOLD test 1 succeed", "NO_WAIT")
			else
				guy_fail("GOLD 1")
			end

			Tux:add_gold(100)
			if (Tux:get_gold() == 100) then
				Npc:says("GOLD test 2 succeed", "NO_WAIT")
			else
				guy_fail("GOLD 2")
			end

			if (not Tux:del_gold(1000)) then
				Npc:says("GOLD test 3 succeed", "NO_WAIT")
			else
				guy_fail("GOLD 3")
			end

			if (Tux:get_gold() == 100) then -- check if gold changed, just to be sure...
				Npc:says("GOLD test 4 succeed", "NO_WAIT")
			else
				guy_fail("GOLD 4")
			end

			if (Tux:del_gold(100)) then
				Npc:says("GOLD test 5 succeed", "NO_WAIT")
			else
				guy_fail("GOLD 5")
			end

			Tux:add_gold(100)
			Tux:add_gold(-100)
			if (Tux:get_gold() == 0) then
				Npc:says("GOLD test 6 succeed")
			else
				guy_fail("GOLD 6")
			end


---------------------------------------------------------- RUSH TUX
			if (not Tux:has_met("Guy")) then
				if not (Npc:get_rush_tux()) then
					Npc:says("RUSH TUX test 1 succeed", "NO_WAIT")
				else
					guy_fail("RUSH TUX 1")
				end
			else
				Tux:says("Skipping RUSH TUX test 1 because it would fail since we directly rush tux on second time we call the dialog.")
			end

			Npc:set_rush_tux(true)

			if (Npc:get_rush_tux()) then
				Npc:says("RUSH TUX test 2 succeed", "NO_WAIT")
			else
				guy_fail("RUSH TUX 2")
			end
---------------------------------------------------------- OTHER
			-- print some useless colorful foo

			Guy_colors={"black", "red", "green", "yellow", "blue", "purple", "cyan", "white"}
			if (running_benchmark()) then -- for nodes we use printf which has no linebreak at the end.
				print("")				  -- "black" would get appended directly to a node but this avoids it.
			end

			for k, color in ipairs(Guy_colors) do
				print(FDutils.text.highlight(color, color))
			end

			Npc:set_death_item("Pandora's Cube")
			Npc:says("")
			display_big_message("Big Message")
			display_console_message("Console message, [b]blue[/b], not blue.")
			end_dialog()
			Guy_dialog_executing = false
		end,
	},
	{
		id = "node99",
		text = "logout",
		code = function()
			end_dialog()
		end,
	},
}
