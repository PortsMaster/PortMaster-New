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
-- Krill
-- ================================================================================================

-- specific
local STATE_JUMP			= 1000
local STATE_TRANSITION		= 1001
local STATE_RETURNTOWALL	= 1002
local STATE_SURFACE			= 1003
local STATE_LAYEGGS			= 1004
local STATE_RECOVER			= 1005
local STATE_PASSON			= 1006

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.moveTimer = 0
v.moveDir = 0
v.avoidCollisionsTimer = 0
v.eggTimer = 0
v.lifeSpan = 0

v.eggTime = 2

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"Krill/Krill",					-- texture
	3,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	16,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	64,							-- sprite width	
	64,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	3000,							-- updateCull -1: disabled, default: 4000
	1
	)

	entity_setEatType(me, EAT_FILE, "SmallFood")
	
	entity_setMaxSpeed(me, 500)
	
	entity_setDropChance(me, 0)
	
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	
	esetv(me, EV_WALLOUT, 8)
	
	v.lifeSpan = 18 + math.random(8)
	--v.lifeSpan = 8
	
	entity_setState(me, STATE_IDLE)
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	--entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	entity_ensureLimit(me, 128, STATE_PASSON)
end

function update(me, dt)	
	
	if entity_isState(me, STATE_IDLE) then
		v.lifeSpan = v.lifeSpan - dt
		if v.lifeSpan < 2 then
			entity_setMaxSpeedLerp(me, 0.1, 0.1)	
			entity_color(me, 0.2,0.4,0.4,100*dt)
		elseif v.lifeSpan < 4 then
			entity_setMaxSpeedLerp(me, 0.4, 0.1)
			entity_setColor(me, 0.6, 0.9, 0.9, 100*dt)
		end
		if v.lifeSpan < 0 then
			entity_setState(me, STATE_PASSON)
		end
		v.avoidCollisionsTimer = v.avoidCollisionsTimer + dt
		if v.avoidCollisionsTimer > 5 then
			v.avoidCollisionsTimer = 0
		end
		v.moveTimer = v.moveTimer + dt
		if v.moveTimer < 1.5 then
			-- move
			local amount = 2000*dt
			if v.moveDir == 0 then
				entity_addVel(me, -amount, 0)
				if entity_isFlippedHorizontal(me) then
					entity_flipHorizontal(me)
				end
			elseif v.moveDir == 1 then
				entity_addVel(me, 0, amount)
			elseif v.moveDir == 2 then
				entity_addVel(me, amount, 0)
				if not entity_isFlippedHorizontal(me) then
					entity_flipHorizontal(me)
				end			
			elseif v.moveDir == 3 then
				entity_addVel(me, 0, amount)
			end		
		elseif v.moveTimer > 3 then
			-- stop 
			--entity_clearVel(me)
			v.moveTimer = 0
			v.moveDir = v.moveDir +1 
			if v.moveDir >= 4 then
				v.moveDir = 0
			end
		elseif v.moveTimer > 2.5 then
			local factor = 5*dt
			entity_addVel(me, -entity_velx(me)*factor, -entity_vely(me)*factor)
		end
		if v.avoidCollisionsTimer < 3 then
			entity_doCollisionAvoidance(me, dt, 4, 1.0)
		end
		entity_updateMovement(me, dt)		
	elseif entity_isState(me, STATE_SURFACE) then
		
		entity_moveAlongSurface(me, dt, 20, 2)
		entity_rotateToSurfaceNormal(me, 0.1)
		if not entity_isFlippedHorizontal(me) then
			entity_flipHorizontal(me)
		end				
		v.eggTimer = v.eggTimer + dt
		if v.eggTimer > v.eggTime then
			v.eggTimer = 0
			entity_setState(me, STATE_LAYEGGS)
		end
	elseif entity_isState(me, STATE_LAYEGGS) or entity_isState(me, STATE_RECOVER) then
		entity_rotateToSurfaceNormal(me, 0.1)
	elseif entity_isState(me, STATE_PASSON) then
		entity_addVel(me, 0, -800*dt)
		entity_updateMovement(me, dt)
	end
	if not entity_isState(me, STATE_GROW) then
		entity_handleShotCollisions(me)	
	end
end

function hitSurface(me)
	entity_clampToSurface(me)
	entity_setState(me, STATE_SURFACE, 3+math.random(2))
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		v.avoidCollisionsTimer = 0
	elseif entity_isState(me, STATE_SURFACE) then
		entity_clearVel(me)
		if chance(50) then
			entity_switchSurfaceDirection(me, 1)
			if entity_isFlippedHorizontal(me) then
				entity_flipHorizontal(me)
			end
		else
			entity_switchSurfaceDirection(me, 0)
			if not entity_isFlippedHorizontal(me) then
				entity_flipHorizontal(me)
			end
		end
	elseif entity_isState(me, STATE_GROW) then
		entity_scale(me)
		entity_scale(me, 1, 1, 1)
		entity_setStateTime(me, 1)
		v.eggTimer = -7
	elseif entity_isState(me, STATE_LAYEGGS) then
		entity_setInternalOffset(me, 0, 0)
		entity_setInternalOffset(me, 10, 0, 0.1, -1, 1)
		entity_setStateTime(me, 2)
		v.lifeSpan = v.lifeSpan - 2
	elseif entity_isState(me, STATE_RECOVER) then
		local eggs = createEntity("KrillEggs", "", entity_getPosition(me))
		entity_alpha(eggs, 0)
		entity_alpha(eggs, 1, 0.5)
		entity_scale(eggs, 1)
		entity_scale(eggs, 1, 1, 0.5)
		entity_setInternalOffset(eggs)
		entity_setInternalOffset(eggs, 0, -16, 0.5)
		entity_rotate(eggs, entity_getRotation(me))
		entity_setInternalOffset(me, 0, 0, 0.5)
		entity_setStateTime(me, 2)
	elseif entity_isState(me, STATE_PASSON) then
		local t = 2
		entity_setStateTime(me, t)
		entity_alpha(me, 1)
		entity_alpha(me, 0, t)
		entity_rotate(me, -180, t*1.2)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		entity_changeHealth(me, -100)
	end
	return true
end

function exitState(me)
	if entity_isState(me, STATE_SURFACE) then		
		entity_setState(me, STATE_IDLE)
		entity_rotate(me, 0, 1)
	elseif entity_isState(me, STATE_LAYEGGS) then
		entity_setState(me, STATE_RECOVER)
	elseif entity_isState(me, STATE_RECOVER) then
		entity_setState(me, STATE_IDLE)
		entity_rotate(me, 0, 1)
	elseif entity_isState(me, STATE_GROW) then
		entity_rotate(me, 0, 1)
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_PASSON) then
		entity_delete(me)
	end
end
