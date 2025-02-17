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
-- M A U L
-- ================================================================================================

-- entity specific
local STATE_FIRE			= 1000
local STATE_PULLBACK		= 1001
local STATE_REGROUP			= 1002

v.dir = 0
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"Piranha",					-- texture
	4,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	16,								-- collideRadius 
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	1024,							-- updateCull -1: disabled, default: 4000
	1
	)

	--entity_setSegs(me, 8, 2, 0.1, 0.9, 0, -0.03, 8, 0)
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	entity_setState(me, STATE_IDLE)
	entity_scale(me, 0.6, 0.6)
	entity_setMaxSpeed(me, 300)
	--entity_rotateOffset(me, 90)
	entity_setBeautyFlip(me, false)
end

function update(me, dt)	
	
	if entity_isState(me, STATE_ATTACK) then
		entity_moveTowardsTarget(me, dt, 1000)
		entity_rotateToVel(me, 0.1)
		entity_flipToVel(me)
		entity_doCollisionAvoidance(me, dt, 8, 0.4)
		entity_doEntityAvoidance(me, dt, 16, 0.8)
	elseif entity_isState(me, STATE_PULLBACK) then
		entity_moveTowardsTarget(me, dt, -4000)
		entity_rotateToVel(me, 0.1)
		entity_flipToVel(me)
		entity_doCollisionAvoidance(me, dt, 8, 0.4)
		entity_doEntityAvoidance(me, dt, 32, 0.8)		
	elseif entity_isState(me, STATE_REGROUP) then
		entity_doEntityAvoidance(me, dt, 32, -2.0)
	elseif entity_isState(me, STATE_IDLE) then
		if v.dir == 0 then
			entity_addVel(me, -1000, 0)
		else
			entity_addVel(me, 1000, 0)
		end
		entity_rotateToVel(me, 0.1)
		entity_flipToVel(me)
		entity_doEntityAvoidance(me, dt, 32, 0.8)		
	end
	
	if entity_hasTarget(me) then
		if not (entity_isState(me, STATE_ATTACK) or entity_isState(me, STATE_PULLBACK)) then
			entity_setState(me, STATE_ATTACK)
		else
			entity_findTarget(me, 600)
		end
	else
		if not entity_isState(me, STATE_IDLE) then
			entity_setState(me, STATE_IDLE)
		end
		entity_findTarget(me, 500)
	end

	entity_updateCurrents(me, dt)
	
	entity_updateMovement(me, dt)
	
	entity_handleShotCollisions(me)	
	if entity_isState(me, STATE_ATTACK) then
		if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0.5, 200) then
			entity_sound(me, "Bite", 1200+math.random(200))
			entity_setState(me, STATE_PULLBACK, 0.9)
		end
	end
	
end

function enterState(me)
	if entity_isState(me, STATE_ATTACK) then		
		--entity_disableMotionBlur(me)
		entity_setMaxSpeedLerp(me, 2.25, 0.5)
	elseif entity_isState(me, STATE_PULLBACK) then
		--entity_enableMotionBlur(me)
		entity_setMaxSpeedLerp(me, 2, 0.5)		
		entity_moveTowardsTarget(me, 1, -500)
		--entity_setMaxSpeedLerp(me, 2.2, 0.5)
	elseif entity_isState(me, STATE_IDLE) then
		--entity_disableMotionBlur(me)
		entity_setMaxSpeedLerp(me, 0.5)
		entity_setMaxSpeedLerp(me, 1, 1, -1, 1)
		entity_rotate(me, 0, 1, 0, 0, 1)
	end
end

function exitState(me)
	if entity_isState(me, STATE_PULLBACK) then
		entity_setState(me, STATE_ATTACK)
	elseif entity_isState(me, STATE_REGROUP) then
		entity_setState(me, STATE_IDLE)
	end
end

function hitSurface(me)
	entity_flipHorizontal(me)
	if v.dir == 0 then
		v.dir = 1
	elseif v.dir == 1 then 
		v.dir = 0
	end
end

function activate(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		entity_changeHealth(me, -10)
	end
	return true
end
