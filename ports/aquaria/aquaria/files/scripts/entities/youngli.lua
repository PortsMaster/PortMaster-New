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

local ANIMLAYER_LI = 0
local ANIMLAYER_BOAT = 1
v.n = 0

v.headNormal = 0
v.headShock = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "YoungLi")	
	entity_setAllDamageTargets(me, false)
	
	entity_setCull(me, false)
	entity_setState(me, STATE_IDLE)
	
	v.headNormal = entity_getBoneByName(me, "Head")
	v.headShock = entity_getBoneByName(me, "HeadShock")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1, ANIMLAYER_BOAT)
		entity_animate(me, "cruise", -1, ANIMLAYER_LI)
	elseif entity_isState(me, STATE_ON) then
		entity_animate(me, "idle", -1, ANIMLAYER_LI)
	elseif entity_isState(me, STATE_OFF) then
		bone_setVisible(v.headNormal, 0)
		bone_setVisible(v.headShock, 1)
	elseif entity_isState(me, STATE_ATTACK) then
		bone_setVisible(v.headNormal, 1)
		bone_setVisible(v.headShock, 0)
		entity_animate(me, "puzzled", 0, ANIMLAYER_LI)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

