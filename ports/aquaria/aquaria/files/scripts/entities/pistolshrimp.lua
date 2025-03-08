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
v.dir = 0

local STATE_FLYBACK = 1000

function init(me)
	v.fireDelay = 2 + math.random(2)

	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "pistolshrimp")	
	entity_setAllDamageTargets(me, true)
	
	entity_setCollideRadius(me, 32)
	
	entity_setState(me, STATE_IDLE)
	entity_setHealth(me, 9)
	entity_setUpdateCull(me, 3000)
	entity_setDeathParticleEffect(me, "tinyyellowexplode")
	v.dir = math.random(2)-1
	
	--[[
	if v.dir == 0 then
		entity_rotateOffset(me, 90)
		--entity_rotateOffset(me, 80)
		--entity_rotateOffset(me, 110, 1, -1)
	else
		entity_rotateOffset(me, -90)
		--entity_rotateOffset(me, -80)
		--entity_rotateOffset(me, -110, 1, -1)
	end
	]]--
	--entity_scale(me, 0.8, 0.8)
	entity_setEatType(me, EAT_FILE, "PistolShrimp")
	entity_setEntityLayer(me, 1)
	
	esetv(me, EV_TYPEID, EVT_PISTOLSHRIMP)
	
	loadSound("pistolshrimp-fire")
end

function postInit(me)
	v.n = getNaija()
	
end

function update(me, dt)	
	if entity_hasTarget(me) then
		if not entity_isState(me, STATE_FLYBACK) then
			if entity_isTargetInRange(me, 400) then
				entity_moveTowardsTarget(me, dt, 2000)
				if entity_isTargetInRange(me, 256) then			
					entity_moveTowardsTarget(me, dt, -2000)
				end
				
				entity_setMaxSpeedLerp(me, 2, 0.5)
				entity_moveAroundTarget(me, dt, 3000, v.dir)
				v.fireDelay = v.fireDelay - dt*1.5
				entity_doEntityAvoidance(me, dt, 8, 0.5)
				
			else
				v.fireDelay = v.fireDelay - dt
				entity_doEntityAvoidance(me, dt, 16, 1)
				entity_doEntityAvoidance(me, dt, 32, 0.6)
				
				entity_setMaxSpeedLerp(me, 1, 0.5)
				entity_moveTowardsTarget(me, dt, 1000)
				--entity_rotate(me, 90, 0.5)
			end
			entity_rotate(me, 0, 0.5)
		elseif entity_isState(me, STATE_FLYBACK) then
		end
		if v.fireDelay < 0 then
			if entity_isEntityInRange(me, v.n, 900) then
				v.fireDelay = 1 + math.random(2)
				local s = createShot("pistolshrimp", me, v.n)
				shot_setOut(s, 32)
				entity_setMaxSpeedLerp(me, 4)
				entity_setMaxSpeedLerp(me, 1, 3)
				entity_moveTowards(me, entity_x(v.n), entity_y(v.n), 1, -4000)
				entity_rotateToVel(me, 0.1, -90)--, 80)
				entity_setState(me, STATE_FLYBACK, 1)
			end
		end
		
		entity_doCollisionAvoidance(me, dt, 4, 0.1)
		entity_findTarget(me, 1800)
		
	else
		entity_findTarget(me, 900)
		entity_setMaxSpeedLerp(me, 0.01, 1)
	end
	
	entity_updateMovement(me, dt)
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0.5, 400)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	end
end

function exitState(me)
	if entity_isState(me, STATE_FLYBACK) then
		entity_setState(me, STATE_IDLE, -1)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if attacker == me or eisv(attacker, EV_TYPEID, EVT_PISTOLSHRIMP) then
		return false
	end
	if damageType == DT_AVATAR_BITE then
		entity_changeHealth(me, -100)
	end
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
	if chance(50) then
		spawnIngredient("SpicyMeat", entity_x(me), entity_y(me))
	end
end

