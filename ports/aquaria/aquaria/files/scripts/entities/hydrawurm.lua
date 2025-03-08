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
-- H Y D R A  W U R M
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================
 
v.chaseDelay = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(me, 
	"wurm-head",					-- texture
	24,								-- health
	1,								-- manaballamount
	2,								-- exp
	1,								-- money
	32,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	256,							-- sprite width
	256,							-- sprite height
	0,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	5000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_flipVertical(me)			-- fix the head orientation
	
	entity_initSegments(me, 
	8,								-- num segments
	2,								-- minDist
	26,								-- maxDist
	"wurm-body",					-- body tex
	"wurm-tail",					-- tail tex
	256,							-- width
	256,							-- height
	0.05,							-- taper
	0								-- reverse segment direction
	)
	entity_setDeathParticleEffect(me, "TinyRedExplode")
end

function update(me, dt)	
	entity_handleShotCollisions(me)
	if entity_hasTarget(me) then
		if entity_isTargetInRange(me, 64) then
			entity_hurtTarget(me, 1)
			entity_pushTarget(me, 400)
		end
	end
	if v.chaseDelay > 0 then
		v.chaseDelay = v.chaseDelay - dt
		if v.chaseDelay < 0 then
			v.chaseDelay = 0
		end
	end
	if entity_getState(me)==STATE_IDLE then
		if not entity_hasTarget(me) then
			entity_findTarget(me, 400)
		else
			--if v.chaseDelay==0 then
			if entity_isTargetInRange(me, 1000) then
				if entity_getHealth(me) < 6 then
					entity_setMaxSpeed(me, 450)
					entity_moveTowardsTarget(me, dt, 1500)
				else
					entity_setMaxSpeed(me, 380)
					entity_moveTowardsTarget(me, dt, 1000)
				end
			else
				entity_setMaxSpeed(me, 100)
			end
			--end
			entity_doEntityAvoidance(me, dt, 200, 0.1)
			if entity_getHealth(me) < 4 then
				entity_doSpellAvoidance(me, dt, 64, 0.5);
			end
			entity_doCollisionAvoidance(me, dt, 5, 1)
			entity_updateMovement(me, dt)
			entity_rotateToVel(me, 0.1)
		end
	end

end

function enterState(me)
	if entity_isState(me, STATE_DEAD) then
		spawnParticleEffect("WurmDie", entity_getPosition(me))
	end
end

function exitState(me)
end

function damage(me)
	entity_findTarget(me, 1000)
	return true
end

function dieNormal(me)
	spawnIngredient("SmallEgg", entity_x(me), entity_y(me))
end
