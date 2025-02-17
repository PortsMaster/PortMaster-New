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
-- SHOCKER
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

local STATE_SHOCKPREP 	= 1000
local STATE_SHOCK		= 1001

v.moveStateTimer = 0
v.moveState = 0
v.shockDelay = 0
v.shockDelayTime = 5

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================


function init(me)
	setupBasicEntity(
	me,
	"",						-- texture
	10,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	32,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	256,							-- sprite width	
	256,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_initSkeletal(me, "Shocker")

	entity_setDeathParticleEffect(me, "Explode")
	--entity_scale(me, 0.5, 0.5)
	
	entity_setState(me, STATE_IDLE)
	entity_setDropChance(me, 75)
end

function update(me, dt)
	dt = dt * 0.8
	
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, 20, 0, 1000)
	
	entity_findTarget(me, 900)
	if not entity_hasTarget(me) then		
		entity_doCollisionAvoidance(me, dt, 4, 0.1)
	end
	
	if entity_hasTarget(me) and entity_isTargetInRange(me, 512) then
		v.shockDelay = v.shockDelay - dt
		if v.shockDelay < 0 then
			v.shockDelay = v.shockDelayTime
			entity_setState(me, STATE_SHOCKPREP, 2)
		end
	end
	
	if entity_isState(me, STATE_SHOCKPREP) then
		entity_offset(me, math.random(5)-2.5, math.random(5)-2.5)
	end
	if entity_hasTarget(me) then
		
		entity_updateMovement(me, dt)
		
		if entity_isTargetInRange(me, 128) then
			entity_moveTowardsTarget(me, dt, -800)
		else
			entity_moveTowardsTarget(me, dt, 1000)
		end
		entity_doCollisionAvoidance(me, dt, 8, 1.0)
		--[[
		if v.moveState == 0 then
			entity_addVel(me, 0*dt, -500*dt)
		elseif v.moveState == 1 then			
			entity_moveTowardsTarget(me, dt, 500)
		elseif v.moveState == 2 then
			entity_addVel(me, 0*dt, 500*dt)
		elseif v.moveState == 3 then
			entity_moveTowardsTarget(me, dt, -500)
		end
		]]--
		
		v.moveStateTimer = v.moveStateTimer + dt
		if v.moveStateTimer > 3 then
			v.moveStateTimer = 0
			v.moveState = v.moveState + 1
			if v.moveState > 3 then
				v.moveState = 0
			end
		end
	end
	entity_rotateToVel(me, 0.1)
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setMaxSpeedLerp(me, 1, 1)
		entity_setMaxSpeed(me, 500)
		entity_animate(me, "idle", LOOP_INF)
	elseif entity_isState(me, STATE_SHOCKPREP) then
		entity_setMaxSpeedLerp(me, 0.2, 1)
	elseif entity_isState(me, STATE_SHOCK) then
		playVisualEffect(VFX_SHOCK, entity_getPosition(me))
	end
end

function exitState(me)
	if entity_isState(me, STATE_SHOCKPREP) then
		entity_setState(me, STATE_SHOCK, 0.5)
	elseif entity_isState(me, STATE_SHOCK) then
		if entity_isEntityInRange(me, getNaija(), 256) then
			entity_damage(getNaija(), me, 1)
		end
		entity_setState(me, STATE_IDLE)
	end
end
