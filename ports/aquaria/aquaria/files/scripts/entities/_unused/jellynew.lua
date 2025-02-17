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
-- J E L L Y - Version 2.0   (alpha)
-- ================================================================================================

-- NOTE:  This is a WIP!  Use the backup if you want it to work.

-- ================================================================================================
-- S T A T E S
-- ================================================================================================

local STATE_FALLING = 1001
local STATE_THRUSTING = 1002
local STATE_BUMPED = 1003
local STATE_PULLED = 1004
local STATE_WIGGLING = 1005

-- ================================================================================================
-- L O C A L   V A R I A B L E S 
-- ================================================================================================

v.mT = 2.1
v.moveTimer = v.mT

v.bumpForce = 134

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"Jelly",						-- texture
	6,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	32,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	2100,							-- updateCull -1: disabled, default: 4000
	1
	)
	
	entity_setDeathParticleEffect(me, "PurpleExplode")
	entity_setDropChance(me, 100)
	entity_setEatType(me, EAT_FILE, "Jelly")
	
	entity_initHair(me, 40, 5, 40, "JellyTentacles")
	entity_exertHairForce(me, 0, 4200, 1)
end

function postInit(me)
	entity_setTarget(me, getNaija())
	entity_setState(me, STATE_FALLING)
end

function update(me, dt)
	-- GET BUMPED
	if entity_touchAvatarDamage(me, 32, 0, 600) then
		entity_setState(me, STATE_BUMPED)
		
		-- ...IF NAIJA'S THRUSTING
		if avatar_isBursting() then
			-- Bounce Jelly hard
			local nX, nY = entity_getPosition(getNaija())
			entity_moveTowards(me, nX, nY, 1, -(v.bumpForce*1.4))
			
		-- ...IF NAIJA'S RIDING SOMETHING
		elseif entity_getRiding(getNaija()) ~= 0 then
			-- Bounce Ride and Jelly away from eachother
			local ride = entity_getRiding(getNaija())
			local rX, rY = entity_getPosition(ride);
			local nX, nY = entity_getPosition(getNaija())
			entity_moveTowards(ride, nX, nX, 1, -(v.bumpForce*2.0))
			entity_moveTowards(me, rX, rY, 1, -v.bumpForce)
		
		-- ...IF NAIJA'S ONLY MOVING
		else
			-- Bounce Jelly lightly
			local nX, nY = entity_getPosition(getNaija())
			entity_moveTowards(me, nX, nY, 1, -v.bumpForce)
		end
		
		-- Reset movement stuff
		--[[
		v.moveState = MOVE_STATE_UP
		v.moveTimer = 0
		entity_rotateToVel(me, 7.6)
		entity_scale(me, 1, 1, 1.3, 0, 0, 1)
		
		entity_sound(me, "JellyBlup", 808)
		]]--
	end
	
	-- MOVEMENT STUFF
	if v.moveState == MOVE_STATE_DOWN then
		-- Time before thrust
		if v.moveTimer > 0 then v.moveTimer = v.moveTimer - dt
		else		
			-- THRUST UP
			local xVel = 43 + math.random(234)
			if chance(50) then xVel = -xVel end
			
			-- Thrust
			entity_clearVel(me)
			entity_addVel(me, xVel, -v.thrustStrength)
			entity_rotateToVel(me, 0.56)

			v.moveState = MOVE_STATE_UP
			v.moveTimer = 0
			
			entity_scale(me, 0.8, 1.1, 1.2, 0, 0, 1)
		end
	else
		-- FALL DOWN
		if entity_getVelLen(me) <= 1 then
			entity_scale(me, 1.1, 0.8, 4.73, 0, 0, 1)
			v.moveState = MOVE_STATE_DOWN
			--entity_addVel(me, 0, 42)
			v.moveTimer = v.mT + (math.random(256) * 0.01)
		end
	end
	
	-- GRAVITY
	if v.moveState == MOVE_STATE_DOWN then
		entity_addVel(me, 0, 4)
		entity_rotateTo(me, 0, 1.4)
		entity_exertHairForce(me, 0, 200, dt*0.6, -1) -- Hair gravity
	end
	
	-- COLLISION AVOIDANCE
	entity_doEntityAvoidance(me, dt, 43, 0.1)
	entity_doCollisionAvoidance(me, dt, 8, 0.34)
	-- UPDATE EVERYTHING
	entity_doFriction(me, dt, 200)
	entity_updateCurrents(me, dt)
	entity_updateMovement(me, dt)
	entity_handleShotCollisions(me)
	entity_setHairHeadPosition(me, entity_x(me), entity_y(me))
	entity_updateHair(me, dt)
end

function enterState(me)
	if entity_getState(me) == STATE_FALLING then
		
	
	elseif entity_getState(me) == STATE_THRUSTING then
	
	end
end

function damage(me, attacker, bone, damageType, dmg, x, y)
	-- EXTRA DAMAGE WHEN BIT or CHARGE SHOT'D
	if damageType == DT_AVATAR_BITE or damageType == DT_AVATAR_SHOCK then
		entity_changeHealth(me, -dmg)
	else
		-- PUSH WHEN HIT	
		entity_moveTowards(me, x, y, 1, -(v.bumpStrength*0.69))
	end

	return true
end

function dieNormal(me)
	spawnIngredient("JellyOil", entity_x(me), entity_y(me), math.random(3))
end
