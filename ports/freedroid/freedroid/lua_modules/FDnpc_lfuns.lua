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
--! \file FDnpc_lfuns.lua
--! \brief This file contains the Lua functions to add to FDnpc (Lua binding of a NPC).
--!

--! \addtogroup FDnpc
--!@{
-- start FDnpc submodule


--! \fn number get_damage(self)
--!
--! \brief Return NPC's current damage
--!
--! Current damage is: maximum health - current health
--!
--! \param self [\p FDnpc] FDnpc instance
--!
--! \return [\p number] Current damage
--!
--! \bindtype lfun

function FDnpc.get_damage(self)
	return self:get_max_health() - self:get_health()
end

--! \fn number get_damage_ratio(self)
--!
--! \brief Return NPC's current damage ratio
--!
--! Current damage ratio is: current damage / max health
--!
--! \param self [\p FDnpc] FDnpc instance
--!
--! \return [\p number] Current damage ratio
--!
--! \bindtype lfun

function FDnpc.get_damage_ratio(self)
	return self:get_damage()/self:get_max_health()
end

--! \fn void drain_health(self)
--!
--! \brief Drain all NPC's health and transfer it to Tux
--!
--! As a result, the NPC dies
--!
--! \param self [\p FDnpc] FDnpc instance
--!
--! \bindtype lfun

function FDnpc.drain_health(self)
	--[[ For example, if NPC's health = 10, hurt_tux(-10) will heal tux by 10 HP
	     To have the difficulty lvl influence the HP tux gets we divide the
	     HP by the difficulty_lvl+1 (to prevent division by zero)
	     -10/2 (difficulty_lvl = 3/hard) = -5.  Tux will be healed by 5 HP ]]--
	local tux = FDrpg.get_tux()
	tux:hurt(-(self:get_health())/(difficulty_level()+1))
	self:drop_dead()
end

--! \fn void says(self, format, ...)
--!
--! \brief Display a formatted text in the chat log
--!
--! Output a text in the chat log and wait the user to click.\n
--! The text is displayed using the color/font associated to the NPCs words.\n
--! If the last argument is "NO WAIT", the user's click is not waited. This
--! optional argument is not used to create the formatted text.
--!
--! \param self   [\p FDnpc] FDnpc instance
--! \param format [\p string] Format string (as used in string.format())
--! \param ...    [\p any]    Arguments expected by the format string to create the displayed text
--!
--! \bindtype lfun

function FDnpc.says(self, format, ...)
	local text, no_wait = chat_says_format('\2' .. format .. '\n', ...)
	chat_says(apply_bbcode(text,"\3","\2"), no_wait)
end

--! \fn void says_random(self, ...)
--!
--! \brief Randomly choose one of the text arguments and display it in the chat log
--!
--! Output a text in the chat log and wait the user to click.\n
--! The text to display (using the color/font associated to the NPCs words) is randomly
--! chosen from one of the string arguments.\n
--! If the last argument is "NO WAIT", the user's click is not waited. This
--! optional argument is not used to create the formatted text.
--!
--! \param self   [\p FDnpc] FDnpc instance
--! \param format [\p string] List of strings
--!
--! \bindtype lfun

function FDnpc.says_random(self, ...)
	arg = {...}
	if (arg[#arg] == "NO_WAIT") then
		self:says(arg[math.random(#arg-1)],"NO_WAIT")
	else
		self:says(arg[math.random(#arg)])
	end
end

-- end FDnpc submodule
--!@}

-- Override some methods (cfuns as well as lfuns) when used during dialog validation
function FDnpc.__override_for_validator(FDnpc)
	-- _says functions are not run by the validator, as they display
	-- text on screen and wait for clicks
	FDnpc.says = function(self) end
	-- set_destination cannot be tested because this may be invoked when the bot is
	-- on a different level than where the bot starts
	FDnpc.set_destination = function(self) end
	FDnpc.teleport = function(self) end
	-- drop_dead cannot be tested because it means we would try to kill our dummy bot
	-- several times, which is not allowed by the engine
	FDnpc.drop_dead = function(self) end
end
