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
-- S Q U E E Z E R
-- ================================================================================================

local STATE_CLAMP			= 1000
local STATE_CLAMPED			= 1001
local STATE_UNCLAMP			= 1002
local STATE_GRABBED			= 1003


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.clampDelay = 0
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"squeezer-head",				-- texture
	20,								-- health
	2,								-- manaballamount
	2,								-- exp
	1,								-- money
	48,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	256,							-- sprite width	
	512,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	2000,							-- updateCull -1: disabled, default: 4000
	1
	)
		
	-- entity_initPart(partName, partTexture, partPosition, partFlipH, partFlipV,
	-- partOffsetInterpolateTo, partOffsetInterpolateTime
	entity_initPart(me,
	"FlipperLeft", 
	"squeezer-flipper",
	-8,
	0,
	0,
	0, 
	0)
	
	entity_initPart(me,
	"FlipperRight", 
	"squeezer-flipper",
	8,
	0,
	0,
	1,
	0)

	entity_scale(me, 0.8, 0.8)
	
	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	entity_setDropChance(me, 10, 1)
end

function update(me, dt)
	entity_handleShotCollisions(me)
	if not entity_hasTarget(me) then
		entity_findTarget(me, 1000)
	else
		if v.clampDelay > 0 then
			v.clampDelay = v.clampDelay - dt
			if v.clampDelay < 0 then
				v.clampDelay = 0
			end
		end
		if entity_hasTarget(me) then
			if not(entity_getState(me)==STATE_GRABBED) then
				if not(entity_isTargetInRange(me,64)) then
					entity_moveTowardsTarget(me,dt, 900)
				else
					entity_doFriction(me,dt, 1000)
				end
				if entity_getState(me)==STATE_IDLE and entity_isTargetInRange(me,64) and v.clampDelay==0 then
					entity_setState(me,STATE_CLAMP, 0.25)
				end
				if entity_getState(me)==STATE_CLAMPED then
					entity_doFriction(me,dt, 500)
					if entity_isTargetInRange(me,96) then
						entity_grabTarget(me)
						avatar_fallOffWall()
--						entity_hurtTarget(1)
						entity_setState(me, STATE_GRABBED, 8)
					end
				end	
			end		
		end
	end
	--entity_doEntityAvoidance(me, dt, 0, 1);
	entity_doCollisionAvoidance(me, dt, 4, 1.0);
	entity_rotateToVel(me, 0, 180)
	entity_updateMovement(me, dt)
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_setMaxSpeed(me, 400)
		entity_partRotate(me, "FlipperLeft", 4, 1, -1, 1, 1)
		entity_partRotate(me, "FlipperRight", -4, 1, -1, 1, 1)
	elseif entity_getState(me)==STATE_CLAMP then
		entity_partRotate(me, "FlipperLeft", -64, entity_getStateTime(me), 0, 0, 0)
		entity_partRotate(me, "FlipperRight", 64, entity_getStateTime(me), 0, 0, 0)
	elseif entity_getState(me)==STATE_UNCLAMP then
		entity_partRotate(me, "FlipperLeft", 0, 1)
		entity_partRotate(me,"FlipperRight", 0, 1)
	end
end

function exitState(me)
	if entity_getState(me)==STATE_CLAMP then
		entity_setState(me, STATE_CLAMPED, 0.2)
	elseif entity_getState(me)==STATE_CLAMPED then
		entity_setState(me, STATE_UNCLAMP, 1)
	elseif entity_getState(me)==STATE_UNCLAMP then
		entity_setState(me, STATE_IDLE, -1)
	elseif entity_getState(me)==STATE_GRABBED then
		entity_releaseTarget(me)
		entity_pushTarget(me, 1000)
		entity_setState(me, STATE_UNCLAMP, 1)
	end
end
