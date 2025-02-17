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
-- L E A C H
-- ================================================================================================

-- entity specific
local STATE_ATTACHED		= 1000
local STATE_FLYOFF			= 1001


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.attachOffsetX	= 0
v.attachOffsetY	= 0
v.attachBone = 0
v.rollTime = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	v.maxRollTime = math.random(10)/10.0 + 0.5

	setupBasicEntity(
	me,
	"Leach",						-- texture
	3,								-- health
	0,								-- manaballamount
	1,								-- exp
	0,								-- money
	16,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	64,								-- sprite width
	64,								-- sprite height
	0,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	5000,							-- updateCull -1: disabled, default: 4000
	1
	)
	
	entity_setDeathParticleEffect(me, "LeachExplode")
end

function update(me, dt)
	
	if entity_getState(me)==STATE_IDLE then
		if not entity_hasTarget(me) then
			entity_findTarget(me, 550)
		else
			if entity_isTargetInRange(me, 32) then
				if not isForm(FORM_FISH) then
					entity_setState(me, STATE_ATTACHED)
				end
			elseif entity_isTargetInRange(me, 300) then
				entity_setMaxSpeed(me, 800)
				entity_moveTowardsTarget(me, dt, 2100)
			else
				entity_moveTowardsTarget(me, dt, 200)
			end
			entity_doCollisionAvoidance(me, dt, 5, 1)
		end
	elseif entity_getState(me)==STATE_ATTACHED then
		if isForm(FORM_FISH) then
			entity_setState(me, STATE_FLYOFF, 2)
			return
		end
		entity_rotate(me, bone_getWorldRotation(v.attachBone))
		entity_setPosition(me, bone_getWorldPosition(v.attachBone))
		
		if avatar_isRolling() then
			v.rollTime = v.rollTime + dt
			if v.rollTime > v.maxRollTime then
				entity_setState(me, STATE_FLYOFF, 2)
			end
		end

	end		
	if not(entity_isState(me, STATE_ATTACHED)) then
		entity_updateMovement(me, dt)
		entity_rotateToVel(me, 0.1)
		entity_handleShotCollisions(me)
	end
	
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_setEntityType(me, ET_ENEMY)
		entity_setMaxSpeed(me, 400)
	elseif entity_getState(me)==STATE_ATTACHED then
		entity_setEntityType(me, ET_NEUTRAL)
		entity_setMaxSpeed(me, 0)
		entity_incrTargetLeaches(me)
		entity_sound(me, "Leach")
		v.attachBone = entity_getNearestBoneToPosition(entity_getTarget(me), entity_getPosition(me))
		--[[
		v.attachOffsetX = entity_x(me) - entity_getTargetPositionX(me)
		v.attachOffsetY = entity_y(me) - entity_getTargetPositionY(me)
		]]--
	elseif entity_isState(me, STATE_FLYOFF) then
		entity_setEntityType(me, ET_ENEMY)
		v.rollTime = 0
		entity_setMaxSpeed(me, 800)
		entity_addRandomVel(me, 1000)
	end
end

function exitState(me)
	if entity_getState(me)==STATE_ATTACHED then
--		entity_setState(STATE_IDLE)
		entity_decrTargetLeaches(me)
	elseif entity_isState(me, STATE_FLYOFF) then
		entity_setState(me, STATE_IDLE)
	end
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		entity_setHealth(me, 0)
	end
	return true
end
