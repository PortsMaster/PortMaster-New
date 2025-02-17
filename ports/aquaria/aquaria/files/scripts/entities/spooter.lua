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
-- S P O O T E R (I C E  S C O O T E R)
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
v.hungry = true
v.fedTime = 0
v.eatTime = 0
v.eating = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"spooter",						-- texture
	9,							-- health
	2,							-- manaballamount
	2,							-- exp
	10,							-- money
	40,							-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,							-- particle "explosion" type, 0 = none
	0,							-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	
	entity_clampToSurface(me)
	entity_setWeight(me, 300)
	
	entity_setDeathParticleEffect(me, "PurpleExplode")
	
	entity_setSegs(me, 2, 16, 0.4, 0.4, -0.05, 0, 6, 1)
	
	esetv(me, EV_WALLOUT, 24)
	esetv(me, EV_ENTITYDIED, 1)
end

local function startEating(me, krill)
	v.eating = krill
	v.hungry = false
	entity_setState(krill, STATE_WAIT)
	entity_scale(krill, 0, 0, 1.5)
	
	entity_scale(me, 1,1)
	entity_scale(me, 1,0.5, 0.5, -1, 1)	
end

local function clearEating(me)
	entity_scale(me, 1,1)
	v.fedTime = 2
	v.eatTime = 0
	v.eating = 0
	v.hungry = false
end

-- warning: only called if EV_ENTITYDIED set to 1!
function entityDied(me, ent)
	if ent == v.eating then
		clearEating(me)
	end
end

function update(me, dt)
	if entity_getState(me)==STATE_IDLE then
		--, 24

		entity_rotateToSurfaceNormal(me, 0.1)

		if v.eating==0 then
			entity_moveAlongSurface(me, dt, 100, 6)
			v.moveTimer = v.moveTimer + dt
			if v.moveTimer > 30 then
				entity_switchSurfaceDirection(me)
				v.moveTimer = 0
			end	
	
			if not(entity_hasTarget(me)) then
				entity_findTarget(me, 1200)
			else
				if entity_isTargetInRange(me, 600) then
					v.jumpDelay = v.jumpDelay - dt
					if v.jumpDelay < 0 then
						v.jumpDelay = 3
						entity_setState(me, STATE_JUMP)
					end
				end
			end
		end
		
	elseif entity_getState(me)==STATE_JUMP then
		v.rotateOffset = v.rotateOffset + dt * 400
		if v.rotateOffset > 180 then
			v.rotateOffset = 180
		end
		entity_rotateToVel(me, 0.1, v.rotateOffset)
		entity_updateMovement(me, dt)
		
	elseif not(entity_isState(me, STATE_TRANSITION)) then
		entity_updateMovement(me, dt)
	end

	entity_touchAvatarDamage(me, 64, 1, 400)
	entity_handleShotCollisions(me)
end

function hitSurface(me)
	if entity_getState(me)==STATE_JUMP then
		local t = egetvf(me, EV_CLAMPTRANSF)
		if entity_checkSurface(me, 6, STATE_TRANSITION, t) then
			entity_rotateToSurfaceNormal(me, 0)
			entity_scale(me, 1, 0.5)
			entity_scale(me, 1, 1, t)
			entity_setInternalOffset(me, 0, 64)
			entity_setInternalOffset(me, 0, 0, t)
		else
			local nx, ny = getWallNormal(entity_getPosition(me))
			nx, ny = vector_setLength(nx, ny, 400)
			entity_addVel(me, nx, ny)
		end
		--[[
		if entity_isNearObstruction(me, 4, OBSCHECK_4DIR) then
			entity_clampToSurface(me)
			entity_setState(me, STATE_TRANSITION, 0.001)
		end
		]]--
	end
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_setMaxSpeed(me, 800)
	elseif entity_getState(me)==STATE_JUMP then
		v.rotateOffset = 0
		entity_applySurfaceNormalForce(me, 800)
		entity_adjustPositionBySurfaceNormal(me, 10)
	end
end

function exitState(me)
	if entity_getState(me)==STATE_TRANSITION then
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_isState(me, STATE_IDLE) then
		entity_setState(me, STATE_JUMP)
	end
	return true
end
