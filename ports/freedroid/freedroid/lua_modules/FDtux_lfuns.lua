--[[

  Copyright (c) 2013 Samuel Degrande

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

--!
--! \file FDtux_lfuns.lua
--! \brief This file contains the Lua functions to add to FDtux (Lua binding of Tux).
--!

local function output_msg(msg)
	if (run_from_dialog()) then
		cli_says(msg, "NO_WAIT")
		npc_says("")
	else
		display_big_message(msg)
	end
end

--! \addtogroup FDtux
--!@{
-- start FDtux submodule

--! \fn number get_hp_ratio(self)
--!
--! \brief Returns Tux hp/max_hp ratio
--!
--! \param self [\p FDtux] FDtux instance
--!
--! \return Tux's HP ratio
--!
--! \bindtype lfun

function FDtux.get_hp_ratio(self)
	return self:get_hp() / self:get_max_hp()
end

--! \fn bool del_gold(self, amount)
--!
--! \brief Remove some amount of gold.
--!
--! If the \e amount of gold is lower than what Tux currently has, then remove
--! that amount of gold and return TRUE. Else, do nothing and return FALSE
--!
--! \param self   [\p FDtux]   FDtux instance
--! \param amount [\p integer] Amount of gold to remove
--!
--! \return TRUE if gold was actually removed, FALSE otherwise
--!
--! \bindtype lfun

function FDtux.del_gold(self, amount)
	if (amount <= self:get_gold()) then
		self:add_gold(-amount)
		return true
	else
		return false
	end
end

--! \fn bool del_points(self, points)
--!
--! \brief Remove some training points
--!
--! If the amount of \e points is lower than current training points, then remove
--! that amount of training points and return TRUE. Else, do nothing and return
--! FALSE
--!
--! \param self   [\p FDtux]   FDtux instance
--! \param points [\p integer] Amount of training points to remove
--!
--! \return TRUE if training points were actually removed, FALSE otherwise
--!
--! \bindtype lfun

function FDtux.del_points(self, points)
	if (self:get_training_points() >= points) then
		self:del_training_points(points)
		return true
	else
		return false
	end
end

--! \fn bool del_health(self, points)
--!
--! \brief Remove some health points
--!
--! If the amount of \e points is lower than current health points, then remove
--! that amount of health points and return TRUE. Else, do nothing and return
--! FALSE
--!
--! \param self   [\p FDtux]   FDtux instance
--! \param points [\p integer] Amount of health points to remove
--!
--! \return TRUE if health points were actually removed, FALSE otherwise
--!
--! \bindtype lfun

function FDtux.del_health(self, points)
	if (points < self:get_hp()) then
		self:hurt(points)
		return true
	else
		return false
	end
end

--! \fn bool can_train(self, gold, points)
--!
--! \brief Check if Tux has enough gold and training points
--!
--! Improving a program or a skill cost money, and cost training points.\n
--! This function can be used to check in one single call if Tux has enough
--! money and training points before to be trained.
--!
--! \param self   [\p FDtux]   FDtux instance
--! \param gold   [\p integer] Amount of gold to check
--! \param points [\p integer] Amount of points to check
--!
--! \return TRUE if Tux has enough gold AND enough training points
--!
--! \bindtype lfun

function FDtux.can_train(self, gold, points)
	if (self:get_gold() < gold) then
		return false
	end

	if (self:get_training_points() < points) then
		return false
	end

	return true
end

--! \fn bool train_skill(self, gold, points, skill)
--!
--! \brief Improve a skill by one level
--!
--! Improve the given \e skill, and remove \e gold and training \e points to Tux.\n
--! First check that Tux has enough \e gold and training \e points. If not, do not
--! improve the skill.
--!
--! \param self   [\p FDtux]   FDtux instance
--! \param gold   [\p integer] Amount of gold to remove
--! \param points [\p integer] Amount of points to remove
--! \param skill  [\p string]  Name of the skill to improve
--!
--! \return TRUE if the skill was improved
--!
--! \bindtype lfun

function FDtux.train_skill(self, gold, points, skill)
	if (not self:can_train(gold, points)) then
		return false
	end

	self:add_gold(-gold)
	self:del_training_points(points)
	self:improve_skill(skill)

	return true
end

--! \fn bool train_program(self, gold, points, program)
--!
--! \brief Improve a program by one level
--!
--! Improve the given \e program, and remove \e gold and training \e points to Tux.\n
--! First check that Tux has enough \e gold and training \e points. If not, do not
--! improve the skill.
--!
--! \param self    [\p FDtux]   FDtux instance
--! \param gold    [\p integer] Amount of gold to remove
--! \param points  [\p integer] Amount of points to remove
--! \param program [\p string]  Name of the program to improve
--!
--! \return TRUE if the program was improved
--!
--! \bindtype lfun

function FDtux.train_program(self, gold, points, program)
	if (not self:can_train(gold, points)) then
		return false
	end

	self:add_gold(-gold)
	self:del_training_points(points)
	self:improve_program(program)

	return true
end

--! \fn void add_quest(self, quest, text)
--!
--! \brief Assign a quest to the player, and fill the diary
--!
--! If the \e quest was already assigned, output an error and do nothing.
--! Else, assign the \e quest, add the \e text to the diary, play a sound and
--! notify in the console
--!
--! \param self  [\p FDtux]  FDtux instance
--! \param quest [\p string] Name of the quest to assign
--! \param text  [\p string] Text to add in the diary
--!
--! \bindtype lfun

function FDtux.add_quest(self, quest, text)
	if (not running_benchmark()) then
		if self:done_quest(quest) or
		   self:has_quest(quest) then
			print(FDutils.text.red("\n\tSEVERE ERROR"))
			print(FDutils.text.red("\tTried to assign already assigned quest!"))
			print(FDutils.text.red("\tWe will continue execution, quest is:"))
			print(FDutils.text.red(quest))
		end
	end
	self:assign_quest(quest, text)
	play_sound("effects/Mission_Status_Change_Sound_0.ogg")
	output_msg("   " .. S_"New Quest assigned: " .. D_(quest))
end

--! \fn void update_quest(self, quest, text)
--!
--! \brief Update the diary text associated to a quest
--!
--! If the \e quest was not yet assigned, output an error and do nothing.
--! Else, add the \e text to the diary, play a sound and notify in the console
--!
--! \param self  [\p FDtux]  FDtux instance
--! \param quest [\p string] Name of the quest to update
--! \param text  [\p string] Text to add in the diary
--!
--! \bindtype lfun

function FDtux.update_quest(self, quest, text)
	if (self:has_quest(quest)) then
		add_diary_entry(quest, text)
		play_sound("effects/Mission_Status_Change_Sound_0.ogg")
		output_msg("   " .. S_"Quest log updated: " .. D_(quest))
	else -- we don't have the quest, how so ?
		if (not running_benchmark()) then -- don't spam the validator
			print(FDutils.text.red("\n\tSEVERE ERROR"))
			print(FDutils.text.red("\tTried to update quest that was never assigned!"))
			print(FDutils.text.red("\tWe will continue execution, quest is:"))
			print(FDutils.text.red(quest))
		end
	end
end

--! \fn void end_quest(self, quest, text)
--!
--! \brief Complete a quest, and fill the diary text associated to the quest
--!
--! If the \e quest was not yet assigned, or is already completed, output an
--! error and do nothing. Else, complete the \e quest, add the \e text to the
--! diary, play a sound and notify in the console
--!
--! \param self  [\p FDtux]  FDtux instance
--! \param quest [\p string] Name of the quest to complete
--! \param text  [\p string] Text to add in the diary
--!
--! \bindtype lfun

function FDtux.end_quest(self, quest, text)
	if (not running_benchmark()) then -- don't spam the validator
		if (self:done_quest(quest)) then
				print(FDutils.text.red("\n\tERROR"))
				print(FDutils.text.red("\tTried to end already done quest!"))
				print(FDutils.text.red("\tWe will continue execution, quest is:"))
				print(FDutils.text.red(quest))
		elseif (not self:has_quest(quest)) then
				print(FDutils.text.red("\n\tSEVERE ERROR"))
				print(FDutils.text.red("\tTried to end never assigned quest!"))
				print(FDutils.text.red("\tWe will continue execution, quest is:"))
				print(FDutils.text.red(quest))
		end
	end

	self:complete_quest(quest, text)
	play_sound("effects/Mission_Status_Change_Sound_0.ogg")
	output_msg("   " .. S_"Quest completed: " .. D_(quest))
end

--! \fn integer count_item(self, item)
--!
--! \brief Return the number of a given item that Tux possesses
--!
--! Count the number of \e item those are in the inventory or equipped.
--!
--! \param self [\p FDtux]  FDtux instance
--! \param item [\p string] Name of the item to count
--!
--! \return Number of items
--!
--! \bindtype lfun

function FDtux.count_item(self, item)
	local number = self:count_item_backpack(item)
	if self:has_item_equipped(item) then
		return number + 1
	else
		return number
	end
end

--! \fn bool has_item(self, ...)
--!
--! \brief Check if all items of a list are in Tux's possession
--!
--! \param self [\p FDtux]  FDtux instance
--! \param ...  [\p string] Comma separated list of names of item to check
--!
--! \return TRUE if Tux has got all items, FALSE otherwise
--!
--! \bindtype lfun

function FDtux.has_item(self, ...)
	for i,item in ipairs({...}) do
		if (not (self:count_item(item) > 0)) then
			return false
		end
	end
	return true
end

--! \fn bool has_item_backpack(self, item)
--!
--! \brief Check if an item is in Tux's inventory (but not equipped)
--!
--! \param self [\p FDtux]  FDtux instance
--! \param item [\p string] Name of the item to check
--!
--! \return TRUE if the item is in the inventory, FALSE otherwise
--!
--! \bindtype lfun

function FDtux.has_item_backpack(self, item)
	return (self:count_item_backpack(item) > 0)
end

--! \fn bool del_item(self, item)
--!
--! \brief Remove an item from Tux's inventory (but not equipped)
--!
--! \param self [\p FDtux]  FDtux instance
--! \param item [\p string] Name of the item to remove
--!
--! \return TRUE if the item was removed, FALSE otherwise (the item is not in
--! the inventory or is equipped)
--!
--! \bindtype lfun

function FDtux.del_item(self, item)
	if (self:count_item_backpack(item) > 0) then
		self:del_item_backpack(item)
		return true
	else
		return false
	end
end

--! \fn void says(self, format, ...)
--!
--! \brief Display a formatted text in the chat log
--!
--! Output a text in the chat log and wait the user to click.\n
--! The text is displayed using the color/font associated to Tux words.\n
--! If the last argument is "NO WAIT", the user's click is not waited. This
--! optional argument is not used to create the formatted text.
--!
--! \param self   [\p FDtux]  FDtux instance
--! \param format [\p string] Format string (as used in string.format())
--! \param ...    [\p any]    Arguments expected by the format string to create the displayed text
--!
--! \bindtype lfun

function FDtux.says(self, format, ...)
	local text, no_wait = chat_says_format('\1- ' .. format .. '\n', ...)
	chat_says(text, no_wait)
end

--! \fn void says_random(self, ...)
--!
--! \brief Randomly choose one of the text arguments and display it in the chat log
--!
--! Output a text in the chat log and wait the user to click.\n
--! The text to display (using the color/font associated to Tux words) is randomly
--! chosen from one of the string arguments.\n
--! If the last argument is "NO WAIT", the user's click is not waited. This
--! optional argument is not used as a text to display.
--!
--! \param self   [\p FDtux]  FDtux instance
--! \param ...    [\p string] List of strings
--!
--! \bindtype lfun

function FDtux.says_random(self, ...)
	arg = {...}
	if (arg[#arg] == "NO_WAIT") then
		self:says(arg[math.random(#arg-1)],"NO_WAIT")
	else
		self:says(arg[math.random(#arg)])
	end
end

-- end FDtux submodule
--!@}

-- Override some methods (cfuns as well as lfuns) when used during dialog validation
function FDtux.__override_for_validator(FDtux)
	-- _says functions are not run by the validator, as they display
	-- text on screen and wait for clicks
	FDtux.says = function(self) end
end
