-- Copyright (C) 2007, 2010 - Bit-Blot
--
-- This file is part of Aquaria.
--
-- Aquaria is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--
-- See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

-- ================================================================================================
-- CHILD SHARAN
-- ================================================================================================


function init(me)
	setupConversationEntity(me, "Sharan")
	entity_initSkeletal(me, "child", "childsharan")
	entity_animate(me, "idle", -1)
	entity_scale(me, 0.6, 0.6)
	entity_setActivation(me, AT_CLICK, 80, 256)
end

function update(me, dt)
	entity_touchAvatarDamage(me, 32, 0, 200)
end

function enterState(me)
end

function exitState(me)
end

function activate(me)
	entity_watchSwimToEntitySide(getNaija(), me)
	wnd(1)
	if isFlag(FLAG_SHARAN, 0) then
		txt("Sharan: Naija, I need your help. What's the capital of Aquaria?")
		opt(
			"Mithalas", hasKM(KM_MITHALAS),
			"Don't Know", 1
			)
		if isChoice(0) then
			txt("Sharan: Oh! Of course, how could I forget. Mithalas, under the rule of the great Kairam.")
			KM(KM_KAIRAM)
			setFlag(FLAG_SHARAN, 1)
		elseif isChoice(1) then
			txt("Sharan: I know I'll just fail my next test...")
		end
	elseif isFlag(FLAG_SHARAN, 1) then
		txt("Sharan: Can I help you, Naija?")
		opt(
			"Mithalas", hasKM(KM_MITHALAS),
			"Kairam", hasKM(KM_KAIRAM),
			"Drask", hasKM(KM_DRASK),
			"Vedha", 1,
			"Old Father", hasKM(KM_OLDFATHER),
			"West Passage", hasKM(KM_WESTPASSAGE),
			"Deep Cave", hasKM(KM_DEEPCAVE),
			"Nevermind", 1
			)
		if isChoice(0) then
			txt("Sharan: I can't wait to visit Mithalas!")
		elseif isChoice(1) then
			txt("Sharan: Kairam is the greatest ruler in all of Aquarian history!")
		elseif isChoice(2) then
			txt("Sharan: Drask is the first boy to ever make it to Vedha's classes. Isn't it funny?")
		elseif isChoice(3) then
			txt("Sharan: Vedha said I'm improving in my studies. Maybe some day I can sing like you, Naija!")
		elseif isChoice(4) then
			txt("Sharan: The Old Father is the Creator of all of Aquaria, and the Mithalans believe that he lives in their city.")
		elseif isChoice(5) then
			txt("Sharan: You'd better not go running off to a forbidden area. I don't think Vedha would be very pleased. Just the other day, she scolded me for exploring the deep cave.")
			KM(KM_DEEPCAVE)
		elseif isChoice(6) then
			txt("Sharan: I found a cave, deep below this one. I only had a chance to have a peak before Vedha found me.")
			txt("Sharan: From what I could tell, it looked like some long forgotten ruins. I wish I could explore, but now I'm grounded.")
		end
	end
	wnd(0)
end

function hitSurface(me)
end

