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
	entity_initSkeletal(me, "HorseShoe")	
	--entity_setAllDamageTargets(me, false)
	
	--entity_generateCollisionMask(me)
	entity_setCollideRadius(me, 32)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setHealth(me, 3)
	entity_setDropChance(me, 20, 1)
	entity_scale(me, 0.75, 0.75)
	
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	entity_setUpdateCull(me, 4000)
end

function postInit(me)
	v.n = getNaija()
	--entity_setTarget(me, v.n)
end

function update(me, dt)
	
	if not entity_hasTarget(me) then
		entity_findTarget(me, 800)
		if entity_hasTarget(me) then
			entity_moveTowardsTarget(me, 1, 500)
		end
	else		
		entity_moveTowardsTarget(me, dt, 800)
		entity_findTarget(me, 2000)
	end
	entity_doEntityAvoidance(me, dt, 32, 0.5)
	entity_doCollisionAvoidance(me, dt, 4, 0.2)
	entity_updateMovement(me, dt)
	entity_rotateToVel(me, 0, 90)
	
	entity_handleShotCollisions(me)
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0.75, 400) then
		entity_moveTowardsTarget(me, 1, -500)
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
		entity_setMaxSpeed(me, 500)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return true
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

function dieNormal(me)
	if chance(20) then
		spawnIngredient("RubberyMeat", entity_x(me), entity_y(me))
	end
end

