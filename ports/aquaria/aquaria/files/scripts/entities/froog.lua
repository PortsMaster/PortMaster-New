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
-- FROOG
-- ================================================================================================

-- specific
local STATE_JUMP			= 1000
local STATE_TRANSITION		= 1001

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.jumpDelay = 0
v.moveTimer = 0
v.rotateOffset = 0
v.flyTimer = 0
v.moveTowardsTimer = 0
v.y_range = 200
v.fudge = 40
v.soundDelay = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	3,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	40,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_initSkeletal(me, "Froog")
	
	entity_setDeathParticleEffect(me, "TinyGreenExplode")

	entity_scale(me, 0.5, 0.5)
	entity_clampToSurface(me)
	entity_setState(me, STATE_IDLE)
	entity_setDropChance(me, 25)
	--entity_setBounce(0)
	esetv(me, EV_WALLOUT, 24)
	
	loadSound("FroogFlap")
end

local function isInLine(me)
	if (entity_getRotation(me) >= -45 and entity_getRotation(me) <= 45) or
	(entity_getRotation(me) >= 135 and entity_getRotation(me) <= 225) then
		if entity_x(entity_getTarget(me)) > entity_x(me)-v.y_range/2 and entity_x(entity_getTarget(me)) < entity_x(me)+v.y_range/2 then
			return true
		end
	else
		if entity_y(entity_getTarget(me)) > entity_y(me)-v.y_range/2 and entity_y(entity_getTarget(me)) < entity_y(me)+v.y_range/2 then
			return true
		end
	end
	return false
end

function update(me, dt)
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, 32, 1, 1000)
	
	--[[
	if entity_hasTarget(me) then
		if entity_isTargetInRange(me, 64) then
			entity_hurtTarget(me, 1)
			entity_pushTarget(me, 500)
		end
	end
	]]--
	if v.jumpDelay > 0 then
		v.jumpDelay = v.jumpDelay - dt
		if v.jumpDelay < 0 then
			v.jumpDelay = 0
		end
	end
	if entity_getState(me)==STATE_IDLE then
		entity_rotateToSurfaceNormal(me, 0.1)
		entity_moveAlongSurface(me, dt, 0, 6, 24)
	--[[
		entity_moveAlongSurface(me, dt, 100, 6, 24)
		entity_rotateToSurfaceNormal(me, 0.1)
		v.moveTimer = v.moveTimer + dt
		if v.moveTimer > 30 then
			entity_switchSurfaceDirection(me)
			v.moveTimer = 0
		end
		]]--
		if not(entity_hasTarget(me)) then
			entity_findTarget(me, 2000)
		else
			if entity_isTargetInRange(me, 900) and isInLine(me) then
			--[[and entity_y(entity_getTarget(me)) > entity_y(me)-v.y_range/2
			and entity_y(entity_getTarget(me)) < entity_y(me)+v.y_range/2 then]]--
				--if trace(entity_x(me), entity_y(me), 5) then
					if v.jumpDelay == 0 then
						v.jumpDelay = 1.5
						entity_setState(me, STATE_JUMP)
					end
				--end
				--end
			end
		end
	elseif entity_getState(me)==STATE_JUMP then
		v.soundDelay = v.soundDelay + dt
		if v.soundDelay >= 0.5 then
			entity_playSfx(me, "FroogFlap")
			v.soundDelay = 0
		end

		if v.flyTimer > 0 then
			v.flyTimer = v.flyTimer - dt
			if v.flyTimer < 0 then
				v.flyTimer = 0
			end
		end
		v.rotateOffset = v.rotateOffset + dt * 400
		if v.rotateOffset > 180 then
			v.rotateOffset = 180
		end
		--[[
		if entity_hasTarget(me) then
			if v.moveTowardsTimer > 0 then
				v.moveTowardsTimer = v.moveTowardsTimer - dt
				if v.moveTowardsTimer < 0 then
					v.moveTowardsTimer = 0
				end
				entity_moveTowardsTarget(me, dt, 20000)
			end
		end
		]]--
		entity_rotateToVel(me, 0.1)
		--entity_rotateToVel(me, 0.1, v.rotateOffset)
		entity_updateMovement(me, dt)
--		entity_applySurfaceNormalForce(1000)
		
	elseif not(entity_getState(me)==STATE_TRANSITION) then
		entity_updateMovement(me, dt)
	end
end

function hitSurface(me)
	if entity_isState(me, STATE_JUMP) then
		--and v.flyTimer==0
		--msg1("hitsurface!")
		--entity_adjustPositionBySurfaceNormal(me, v.fudge)
		entity_clampToSurface(me, 0.1) -- (0.1)
		--entity_setState(STATE_IDLE)
		entity_setState(me, STATE_TRANSITION, 0.1)		
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setMaxSpeed(me, 900)
		entity_animate(me, "idle", LOOP_INF)
	elseif entity_isState(me, STATE_JUMP) then
		v.soundDelay = 999
		local t = entity_getTarget(me)
		if t ~= 0 then
			entity_moveTowardsTarget(me, 1, 2000)
			local amp = 1.5
			entity_addVel(me, entity_velx(entity_getTarget(me))*amp, entity_vely(entity_getTarget(me))*amp)
		end
		v.moveTowardsTimer = 0
		v.rotateOffset = 0
		v.flyTimer = 6
		entity_applySurfaceNormalForce(me, 800)
		--entity_adjustPositionBySurfaceNormal(me, 64)
		entity_adjustPositionBySurfaceNormal(me, v.fudge)
		entity_animate(me, "swim", LOOP_INF)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_isState(me, STATE_IDLE) then
		entity_setState(me, STATE_JUMP)
	end
	return true
end

function exitState(me)
	if entity_isState(me, STATE_TRANSITION) then
		entity_setState(me, STATE_IDLE)
	end
end
