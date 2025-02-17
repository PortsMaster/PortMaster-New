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
-- E C C O
-- ================================================================================================

-- ================================================================================================
-- L O C A L   V A R I A B L E S
-- ================================================================================================

v.dir = 0
v.switchDirDelay = 0
v.wiggleTime = 0
v.wiggleDir = 1
v.interestTimer = 0
v.colorRevertTimer = 0

v.collisionSegs = 50
v.avoidLerp = 0
v.avoidDir = 1
v.interest = false

v.jumpDelay = 0

v.n = 0

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
-- oldhealth : 40
	setupBasicEntity(
	me,
	"",						-- texture
	12,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	32,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setDropChance(me, 50)
	
	if chance(50) then
		v.dir = 0
	else
		v.dir = 1
	end
	
	if chance(50) then
		v.interest = true
	end
	v.switchDirDelay = math.random(800)/100.0
	v.naija = getNaija()
	
	entity_addVel(me, math.random(1000)-500, math.random(1000)-500)
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	
	entity_initSkeletal(me, "ekko")
	local body = entity_getBoneByName(me, "Body")
	bone_setSegs(body, 8, 8, 0.69, 0.23, 0, -0.03, 8, 0)
	
	entity_setCanLeaveWater(me, true)
	entity_scale(me, 0.75, 0.75)
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	v.n = getNaija()
end

-- the entity's main update function
function update(me, dt)
	if entity_getState(me)==STATE_IDLE then		
		entity_doCollisionAvoidance(me, dt, 10, 0.1)
		entity_doCollisionAvoidance(me, dt, 4, 0.5)
	end

	if not entity_hasTarget(me) then
		entity_findTarget(me, 500)
	else
		-- has target
		if entity_isUnderWater(me) then
			if not entity_isNearObstruction(entity_getTarget(me), 5) then
				if v.interest then
					entity_moveTowardsTarget(me, dt, 500)
				end
			end
		end
	end
	entity_flipToVel(me)
	entity_rotateToVel(me, 0.3)
	entity_updateCurrents(me, dt)
	entity_updateMovement(me, dt)	
	
	if entity_isUnderWater(me) then
		v.jumpDelay = v.jumpDelay - dt
		if v.jumpDelay <= 0 then
			v.jumpDelay = 0
			entity_setCanLeaveWater(me, true)
			if entity_y(me) - getWaterLevel() < 400 then
				entity_addVel(me, 0, -1000*dt)
			end
		end
		v.interestTimer = v.interestTimer + dt
		if v.interestTimer > 12 then
			if v.interest then
				v.interest = false
			else
				v.interest = true
			end
			v.interestTimer = math.random(3)
		end
	end
	if entity_checkSplash(me) then
		if not entity_isUnderWater(me) then
			entity_setMaxSpeedLerp(me, 2)
			
			if entity_velx(me) < 0 then
				entity_addVel(me, -200, -456)
			else
				entity_addVel(me, 200, -456)
			end
			entity_setWeight(me, 888)
			v.jumpDelay = 2+math.random(5)
		else
			entity_setCanLeaveWater(me, false)
			entity_setWeight(me, 0)
		end
	end
	
	-- COLLISIONS
	entity_handleShotCollisions(me)
	
	if entity_touchAvatarDamage(me, 64, 0) then
		--[[
		if avatar_isBursting() and entity_setBoneLock(v.n, me) then
		else
		]]--
			local x, y = entity_getVectorToEntity(me, v.n, 420)
			entity_addVel(v.n, x, y)
		--end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", LOOP_INF)
		entity_setMaxSpeed(me, 543)
	end
end

function exitState(me)
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
	entity_setMaxSpeed(me, 654)
	return true
end

function songNote(me, note)
end
