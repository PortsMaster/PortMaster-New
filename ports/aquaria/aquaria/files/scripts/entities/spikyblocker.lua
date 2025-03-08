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

v.n = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "SpikyBall")
	
	entity_setAllDamageTargets(me, false)
	
	entity_scale(me, 0, 0)
	entity_scale(me, 2, 2, 1)
	
	entity_color(me, 1, 0.6, 0.6)
	
	entity_setCollideRadius(me, 64)
	
	entity_setTargetRange(me, -9000)
	
	entity_setState(me, STATE_IDLE)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	entity_updateMovement(me, dt)
	
	entity_setDamageTarget(me, DT_ENEMY_ENERGYBLAST, false)
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
	entity_setDamageTarget(me, DT_AVATAR_SHOCK, true)
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, true)
	
	entity_handleShotCollisions(me)
	
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
	entity_setDamageTarget(me, DT_AVATAR_SHOCK, false)
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	
	entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0.5, 500, 0.2)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	playNoEffect()
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

