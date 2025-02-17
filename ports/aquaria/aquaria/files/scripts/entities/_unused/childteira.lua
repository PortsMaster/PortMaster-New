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
-- CHILD TEIRA
-- ================================================================================================

function init(me)
	setupConversationEntity(me, "Teira")
	entity_initSkeletal(me, "child", "childteira")
	entity_animate(me, "idle", LOOP_INF)
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
	if isFlag(FLAG_TEIRA, 0) then
		debugLog("Here.. first line of dialogue")
		txt("Teira: Vedha's been looking for you!")
		txt("Teira: Where did you swim off to?")
		txt("Naija: Oh... nowhere special...")
		txt("Teira: Hmph. I can't wait until we get to visit Mithalas. THAT will be exciting.")
		KM(KM_MITHALAS)
		setFlag(FLAG_TEIRA, 1)
	elseif isFlag(FLAG_TEIRA, 1) then
		txt("Teira: What do you want, Naija?")
		opt(
			"Mithalas", hasKM(KM_MITHALAS),
			"Vedha", 1,
			"Drask", hasKM(KM_DRASK),
			"Old Father", hasKM(KM_OLDFATHER),
			"Nevermind", 1
			)
		if isChoice(0) then
			txt("Teira: You really haven't been paying attention in class, have you?")
			txt("Teira: Mithalas is the crown jewel of Aquaria. The great Mer City!")
			txt("Teira: *tsk* I really don't know why Vedha keeps you around...")
		elseif isChoice(1) then
			txt("Teira: You'd best do exactly what Vedha says, Naija. She is our teacher after all.")
		elseif isChoice(2) then
			txt("Teira: Drask? He shouldn't even be here. Whoever heard of a boy Siren?")
		elseif isChoice(3) then
			txt("Teira: I know that the Old Father has a plan for me... and for all of us. You'd be wise to put your faith in Him.")
		end
	end
	wnd(0)
end

function hitSurface(me)
end
