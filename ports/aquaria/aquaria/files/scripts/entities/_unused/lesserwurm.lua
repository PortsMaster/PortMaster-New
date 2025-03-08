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
-- LESSER WURM
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================
 
v.chaseDelay = 0
v.pushDelay = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"LesserWurm-Head",				-- texture
	15,								-- health
	1,								-- manaballamount
	2,								-- exp
	1,								-- money
	32,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	128,							-- sprite width
	256,							-- sprite height
	0,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	5000							-- updateCull -1: disabled, default: 4000
	)
	
	--entity_initSkeletal(me, "LesserWurm")
	
	--entity_flipVertical(me)			-- fix the head orientation
	
	entity_initSegments(
	me,
	6,								-- num segments
	48,								-- minDist
	48,								-- maxDist
	"LesserWurm-Seg1",				-- body tex
	"LesserWurm-Seg5",				-- tail tex
	128,							-- width
	128,							-- height
	0,								-- taper
	0								-- reverse segment direction
	)
	
	entity_setSegmentTexture(me, 2, "LesserWurm-Seg2")
	entity_setSegmentTexture(me, 3, "LesserWurm-Seg3")
	entity_setSegmentTexture(me, 4, "LesserWurm-Seg4")
	
	entity_setDeathParticleEffect(me, "Explode")
	
	entity_scale(me, 1, 1)
end

function update(me, dt)
	entity_handleShotCollisions(me)
	v.pushDelay = v.pushDelay - dt
	if v.pushDelay <= 0 then
		entity_addRandomVel(me, 1000)
		v.pushDelay = 1 + math.random(2)
	end
	--[[
	if entity_hasTarget(me) then
		if entity_isTargetInRange(me, 64) then
			entity_hurtTarget(me, 1)
			entity_pushTarget(me, 400)
		end
	end
	]]--
	if v.chaseDelay > 0 then
		v.chaseDelay = v.chaseDelay - dt
		if v.chaseDelay < 0 then
			v.chaseDelay = 0
		end
	end
	if entity_getState(me)==STATE_IDLE then
		if not entity_hasTarget(me) then
			entity_findTarget(me, 800)
		else
			if v.chaseDelay == 0 then
				if entity_isTargetInRange(me, 1000) then
					if entity_getHealth(me) < 4 then
						entity_setMaxSpeed(me, 600)
						entity_moveTowardsTarget(me, dt, 1500)
					else
						entity_setMaxSpeed(me, 400)
						entity_moveTowardsTarget(me, dt, 1000)
					end					
				else
					entity_setMaxSpeed(me, 100)
				end
			end
		end
	end

	--entity_doEntityAvoidance(me, dt, 200, 0.1)
	
	if entity_velx(me) < 0 and not entity_isFlippedHorizontal(me) then
		entity_flipHorizontal(me)
	elseif entity_velx(me) > 0 and entity_isFlippedHorizontal(me) then
		entity_flipHorizontal(me)
	end

	entity_doCollisionAvoidance(me, dt, 5, 1)
	entity_updateMovement(me, dt)
	entity_rotateToVel(me, 0.1)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then		
		entity_setMaxSpeed(me, 800)
	end
end

function exitState(me)
end
