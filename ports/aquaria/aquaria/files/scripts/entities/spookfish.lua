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
-- S P O O K F I S H   (pre-alpha)
-- ================================================================================================


-- ================================================================================================
-- L O C A L   V A R I A B L E S 
-- ================================================================================================

v.segsOn = true

v.angle = 0

v.boostLen = 0
v.boostDir = 0

-- ================================================================================================
-- M Y   F U N C T I O N S
-- ================================================================================================

local function setSpookSegsOn(me)
	bone_setSegs(v.body, 8, 2, 0.12, 0.42, 0, -0.03, 8, 0)
	bone_setSegs(v.glow01, 8, 2, 0.12, 0.42, 0, -0.03, 8, 0)
	bone_setSegs(v.glow02, 8, 2, 0.12, 0.42, 0, -0.03, 8, 0)
end

local function setSpookSegsOff(me)
	bone_setSegs(v.body, 8, 2, 0.23, 0.69, 0, -0.03, 8, 0)
	bone_setSegs(v.glow01, 8, 2, 0.23, 0.69, 0, -0.03, 8, 0)
	bone_setSegs(v.glow02, 8, 2, 0.23, 0.69, 0, -0.03, 8, 0)
	--bone_setSegs(v.body)
	--bone_setSegs(v.glow01)
	--bone_setSegs(v.glow02)
end

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	v.swimTimer = 0.64 + (math.random(64) * 0.01)
	v.boostTimer = 4.56 + (math.random(640) * 0.01)

	setupBasicEntity(me, 
	"Spookfish/Body",				-- texture
	2,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	64,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)	
	4000,							-- updateCull -1: disabled, default: 4000
	1
	)
	
	entity_setAllDamageTargets(me, false)
	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	
	entity_initSkeletal(me, "Spookfish")
	v.body = entity_getBoneByName(me, "Body")
	v.glow01 = entity_getBoneByName(me, "Glow01")
	v.glow02 = entity_getBoneByName(me, "Glow02")
end

function postInit(me)
	v.angle = randAngle360()
	entity_rotateTo(me, v.angle)
	entity_moveTowardsAngle(me, v.angle, 1, 101)
	entity_setState(me, STATE_IDLE)
	
	bone_scale(v.glow02, 1.31, 2.5, 3.4, -1, 1, 1)
	bone_alpha(v.glow01, 0.12, 1.23, -1, 1, 1)
	bone_alpha(v.body, 0.23, 4.2, -1, 1, 1)

	setSpookSegsOn(me)
	v.segsOn = true
end

function update(me, dt)
	
	v.angle = entity_getRotation(me)

	if entity_getState(me) == STATE_IDLE then
		-- BOOST FORWARD RANDOMLY
		v.boostTimer = v.boostTimer - dt
		if v.boostTimer <= 0 then
			v.boostTimer = 4.56 + (math.random(640) * 0.01)
			
			v.angle = v.angle + math.random(46) - 23
			if v.angle > 360 then
				v.angle = v.angle - 360
			elseif v.angle < 0 then
				v.angle = v.angle + 360
			end
			
			if v.segsOn == true then 
				setSpookSegsOff(me)
				v.segsOn = false
			end
			v.boostLen = 1.4
			if chance(50) then v.boostDir = -1
			else v.boostDir = 1 end
			entity_setMaxSpeedLerp(me, 4.2)
			entity_setMaxSpeedLerp(me, 1, v.boostLen)
			entity_moveTowardsAngle(me, v.angle, 1, 1234)
		end
		
		-- Curve with boost
		v.boostLen = v.boostLen - dt
		if v.boostLen <= 0 then
			v.boostLen = 0
			if v.segsOn == false then 
				setSpookSegsOn(me)
				v.segsOn = true
			end
		else
			v.angle = v.angle + (40 * v.boostDir)
			if v.angle > 360 then
				v.angle = v.angle - 360
			elseif v.angle < 0 then
				v.angle = v.angle + 360
			end
			entity_rotateTo(me, v.angle, 0.1)
			entity_moveTowardsAngle(me, v.angle, 1, 98)
		end
		
		-- CHANGE SWIM DIRECTION SLIGHTLY
		v.swimTimer = v.swimTimer - dt
		if v.swimTimer <= 0 then
			v.swimTimer = 0.64 + math.random(64)/100
				
			v.angle = v.angle + math.random(90) - 45
			if v.angle > 360 then
				v.angle = v.angle - 360
			elseif v.angle < 0 then
				v.angle = v.angle + 360
			end
					
			entity_moveTowardsAngle(me, v.angle, 1, 87)
			entity_doEntityAvoidance(me, dt, 64, 0.21)
		end
		
		entity_moveTowardsAngle(me, v.angle, dt, 124)
		entity_doEntityAvoidance(me, dt, 128, 0.08)
		entity_doCollisionAvoidance(me, dt, 12, 0.36)
	end
	
	-- FLIP
	local flipThresh = 32
	if entity_isfh(me) and entity_velx(me) < -flipThresh then 
		entity_fh(me)
	elseif not entity_isfh(me) and entity_velx(me) > flipThresh then
		entity_fh(me)
	end
	
	entity_handleShotCollisions(me)
	
	entity_doFriction(me, dt, 123)
	entity_updateCurrents(me, dt)
	entity_rotateToVel(me, 0.8)
	entity_updateMovement(me, dt)
	entity_touchAvatarDamage(me, 64, 0, 321)
end

function enterState(me)
	if entity_getState(me) == STATE_IDLE then
		entity_animate(me, "idle", LOOP_INF)
		entity_setMaxSpeed(me, 123)
	end
end

function exitState(me)
end

function hitSurface(me)
	v.boostLen = 0
	entity_doCollisionAvoidance(me, 1, 4, 2.34)
end
