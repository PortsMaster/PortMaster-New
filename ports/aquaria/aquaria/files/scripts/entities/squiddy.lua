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
-- S Q U I D D Y
-- ================================================================================================

-- entity specific
local STATE_FIREPREP		= 1000
local STATE_FIRE			= 1001
local STATE_LUNGE			= 1002


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.fireDelay = 1.4
v.lungeDelay = 2
 
v.n = 0
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"squiddy",						-- texture
	9,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	32,								-- collideRadius
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setSegs(me, 2, 32, 0.2, 0.2, 0.02, 0, 6, 1)
	entity_setDeathParticleEffect(me, "InkExplode")
	
	entity_setEatType(me, EAT_FILE, "Ink")
end

function postInit(me)
	v.n = getNaija()
end


function update(me, dt)
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, 32, 0, 1200)
	if entity_getState(me)==STATE_IDLE then
		if not(entity_hasTarget(me)) then
			entity_findTarget(me, 1000)
		else
			if v.fireDelay > 0 then
				v.fireDelay = v.fireDelay - dt
				if v.fireDelay < 0 then
					v.fireDelay = 3
					entity_setState(me, STATE_FIREPREP, 0.5)
				end
			end			
			if v.lungeDelay > 0 then
				v.lungeDelay = v.lungeDelay - dt
				if v.lungeDelay < 0 then
					v.lungeDelay = 3
					entity_setState(me, STATE_LUNGE, 2)
				end
			end
			if entity_isTargetInRange(me, 100) then
				v.lungeDelay = 4
				entity_setState(me, STATE_LUNGE, 1)
			elseif entity_isTargetInRange(me, 200) then
				entity_moveAroundTarget(me, dt, 4000, 0)
			else
				entity_moveTowardsTarget(me, dt, 1000)
			end			
		end
	elseif entity_getState(me)==STATE_LUNGE then
		
	end
	
	entity_doEntityAvoidance(me, dt, 256, 0.2);
	entity_doCollisionAvoidance(me, dt, 6, 0.5);
	entity_updateCurrents(me, dt)
	entity_updateMovement(me, dt)
end

function dieNormal(me)
	if chance(25) then spawnIngredient("RubberyMeat", entity_x(me), entity_y(me)) end
	if chance(25) then spawnIngredient("SmallTentacle", entity_x(me), entity_y(me)) end
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_rotateTo(me, 0, 0.5)
	elseif entity_getState(me)==STATE_FIREPREP then
		entity_rotateToTarget(me, entity_getStateTime(me), 180)
	elseif entity_getState(me)==STATE_FIRE then
		local s = createShot("EnemyInk", me, v.n, entity_x(me), entity_y(me))
		shot_setAimVector(s, entity_x(v.n) - entity_x(me), entity_y(v.n) - entity_y(me))
	end
end

function exitState(me)
	if entity_getState(me)==STATE_FIREPREP then
		entity_setMaxSpeed(me, 500)
		entity_setState(me, STATE_FIRE, 0.5)
	elseif entity_getState(me)==STATE_FIRE then
		entity_setState(me, STATE_IDLE)
	elseif entity_getState(me)==STATE_LUNGE then
		entity_setMaxSpeed(me, 800)
		entity_moveAroundTarget(me, 1, 10000, 1)
		entity_setState(me, STATE_IDLE)
	end
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		entity_changeHealth(me, -20)
	end
	return true
end
