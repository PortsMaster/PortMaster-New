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
v.life = -1

function init(me)
	setupEntity(me)
	entity_setAllDamageTargets(me, false)
	entity_setEntityType(me, ET_ENEMY)
	entity_setCollideRadius(me, 12)
	entity_setState(me, STATE_IDLE)
	entity_addVel(me, randVector(200))
	entity_addVel(me, 0, -100)
	entity_setMaxSpeed(me, 1000)
	entity_setWeight(me, 500)
	entity_setBounce(me, 0.5)
	entity_setBounceType(me, BOUNCE_REAL)
	entity_setDeathSound(me, "")
	
	entity_setUpdateCull(me, 2000)
	
	esetv(me, EV_LOOKAT, 0)
	
	entity_setCanLeaveWater(me, true)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	if avatar_isRolling() and entity_isEntityInRange(me, v.n, 256) then
		local vx, vy = entity_getPosition(v.n) - entity_getPosition(me)
		vx, vy = vector_setLength(vx, vy, 1000*dt)
		entity_addVel(me, vx, vy)
	end
	
	if entity_isEntityInRange(me, v.n, 40) then
		entity_addVel(me, entity_velx(v.n)*0.75, entity_vely(v.n)*0.75)
	end
	
	local vx = entity_velx(me)
	entity_rotate(me, entity_getRotation(me)+dt*vx)	
	
	entity_updateMovement(me, dt)
	
	if v.life > -1 then
		v.life = v.life - dt
		if v.life < 0 then
			entity_setHealth(me, 0)
			entity_setState(me, STATE_DEAD)
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
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

