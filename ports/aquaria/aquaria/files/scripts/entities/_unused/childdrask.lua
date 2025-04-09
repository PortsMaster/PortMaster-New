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
-- CHILD DRASK
-- ================================================================================================

function init(me)
	setupConversationEntity(me, "Drask")
	entity_initSkeletal(me, "child", "childdrask")
	entity_animate(me, "idle", -1)
	entity_scale(me, 0.6, 0.6)
	entity_setActivation(me, AT_CLICK, 80, 256)
end

--entity_swimToNode(me, getNode("DRASKCAVEJUMP2"))
function update(me, dt)
	entity_touchAvatarDamage(me, 32, 0, 200)
end

function enterState(me)
end

function exitState(me)
end

function activate(me)
	--entity_flipToEntity(me, getNaija())
	entity_watchSwimToEntitySide(getNaija(), me)
	if isFlag(FLAG_DRASK, 0) then		
		wnd(1)
		txt("Drask: ...")
		txt("Drask: What are you staring at?")
		wnd(0)
		KM(KM_DRASK)
		setFlag(FLAG_DRASK, 1)
	elseif isFlag(FLAG_DRASK, 1) then
		wnd(1)
		txt("Drask: What?")
		opt(
			"Vedha", 1,
			"Mithalas", hasKM(KM_MITHALAS),
			"West Passage", hasKM(KM_WESTPASSAGE),
			"Song Crystal", hasKM(KM_SONGCRYSTAL),
			"Nevermind", 1
			)
		if isChoice(0) then
			txt("Drask: Vedha scares me.")
		elseif isChoice(1) then
			txt("Drask: Please don't ask me about Mithalas...")
		elseif isChoice(2) then
			txt("Drask: Are you going to try and go there, Naija? But... you were warned... by Vedha...")
			txt("Drask: One day, I hope that I'll be as brave as you!")
		elseif isChoice(3) then
			txt("Drask: Someone spoke to you from inside a Crystal?  This means that something more than memory is stored there...")
			txt("Drask: Think about it... all that power...")
		end
		wnd(0)
	end
end

function hitSurface(me)
end
