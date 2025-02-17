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
-- L I O N F I S H
-- ================================================================================================

-- ================================================================================================
-- S T A T E S
-- ================================================================================================

local STATE_GLIDING = 1001
local STATE_TO_THRUST = 1002
local STATE_THRUSTING = 1003
local STATE_TO_GLIDE = 1004

-- ================================================================================================
-- L O C A L   V A R I A B L E S 
-- ================================================================================================

v.maxSpeed = 890
v.angle = 90

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	v.swimTime = 0.34 + (math.random(42)*0.01)

	setupBasicEntity(
	me,
	"",				-- texture
	20,				-- health
	1,				-- manaballamount
	1,				-- exp
	1,				-- money
	64,				-- collideRadius (only used if hit entities is on)
	STATE_GLIDING,			-- initState
	128,				-- sprite width	
	128,				-- sprite height
	1,				-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,				-- 0/1 hit other entities off/on (uses collideRadius)
	1800				-- updateCull -1: disabled, default: 4000
	)
	
	entity_initSkeletal(me, "lionfish")

	entity_setDeathParticleEffect(me, "Explode")
	entity_setDropChance(me, 21)

	entity_setState(me, STATE_GLIDING)
	entity_rotateTo(me, 360, 0.1)
	entity_setMaxSpeed(me, v.maxSpeed)
end

function animationKey(me, key)
end

function postInit(me)
	-- FLIP HORIZONTALLY IF THERE'S A FLIP NODE
	local node = entity_getNearestNode(me, "FLIP")
	if node ~=0 then
		if node_isEntityIn(node, me) then 
			entity_fh(me)
		end
	end
end

function update(me, dt)
	-- SWIM ANGLE
	if entity_getState(me) == STATE_GLIDING then
		v.swimTime = v.swimTime - dt
		if v.swimTime < 0 then
			v.swimTime = 1.23 + (math.random(234)*0.01)
			
			-- Point based on Flip
			if not entity_isfh(me) then
				v.angle = 58 + math.random(64)
				entity_rotateTo(me, v.angle + 270, 2)
			else
				v.angle = 238 + math.random(64)
				entity_rotateTo(me, v.angle + 90, 2)
			end		
			
			entity_setState(me, STATE_TO_THRUST)
		end
	end
	
	-- SUBTLE GLIDE
	if entity_getState(me) == STATE_TO_THRUST then
		if not entity_isfh(me) then
			entity_moveTowardsAngle(me, entity_getRotation(me) - 270, 1, 2.48)
		else
			entity_moveTowardsAngle(me, entity_getRotation(me) - 90, 1, 2.48)
		end
	end
	
	-- FLIP L/R
	local flipThresh = 50	
	if entity_velx(me) < -flipThresh and not entity_isfh(me) then
		entity_fh(me)
		v.angle = v.angle + 180
	elseif entity_velx(me) > flipThresh and entity_isfh(me) then
		entity_fh(me)
		v.angle = v.angle - 180
	end
	
	-- AVOIDANCE
	entity_doEntityAvoidance(me, dt, 43, 0.12)
	entity_doCollisionAvoidance(me, dt, 5, 0.36)
	
	-- MOVEMENT
	entity_doFriction(me, dt, 48)
	entity_updateMovement(me, dt)

	-- DAMAGE
	entity_handleShotCollisions(me)	
	if entity_touchAvatarDamage(me, 32, 1, 1200) then
		setPoison(1, 8)
	end
end

function enterState(me)
	if entity_getState(me) == STATE_TO_THRUST then
		entity_setStateTime(me, entity_animate(me, "idle"), -1)
	elseif entity_getState(me) == STATE_THRUSTING then
		entity_setStateTime(me, entity_animate(me, "thrust"), -1)
	elseif entity_getState(me) == STATE_TO_GLIDE then
		entity_setStateTime(me, entity_animate(me, "idle"), -1)
		
	end
end

function exitState(me)
	if entity_getState(me) == STATE_GLIDING then
	
	elseif entity_getState(me) == STATE_TO_THRUST then
		entity_setState(me, STATE_THRUSTING)
		
	elseif entity_getState(me) == STATE_THRUSTING then
		-- THRUST
		entity_moveTowardsAngle(me, v.angle, 1, 124 + math.random(124))
		entity_setState(me, STATE_TO_GLIDE)
		
	elseif entity_getState(me) == STATE_TO_GLIDE then
		entity_setState(me, STATE_GLIDING)
		
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end


function dieNormal(me)
	if chance(25) then
		spawnIngredient("LeechingPoultice", entity_x(me), entity_y(me))
	end
end
