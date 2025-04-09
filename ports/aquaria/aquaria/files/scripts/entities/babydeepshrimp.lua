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
-- Rood Shrimp
-- ================================================================================================

-- specific
local STATE_JUMP			= 1000
local STATE_TRANSITION		= 1001
local STATE_RETURNTOWALL	= 1002
local STATE_SURFACE			= 1003

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.moveTimer = 0
v.moveDir = 0
v.avoidCollisionsTimer = 0
v.glow = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"BabyDeepShrimp",					-- texture
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

	entity_setMaxSpeed(me, 500)
	--entity_clampToSurface(me)
	entity_setState(me, STATE_IDLE)
	entity_setDropChance(me, 10)
	
	entity_setDeathParticleEffect(me, "PurpleExplode")
	
	v.glow = createQuad("Naija/LightFormGlow", 13)
	quad_scale(v.glow, 1, 1)
	quad_scale(v.glow, 1.2, 1.2, 0.5, -1, 1, 1)	

	
	entity_offset(me, 0, -40, 1, -1, 1)
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function update(me, dt)
	entity_handleShotCollisions(me)	
	
	if entity_isState(me, STATE_IDLE) then
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
			v.moveDir = v.moveDir + 1
			if v.moveDir >= 4 then
				v.moveDir = 0
			end
		elseif v.moveTimer > 2.5 then
			local factor = 5*dt
			entity_addVel(me, -entity_velx(me)*factor, -entity_vely(me)*factor)
		end
		if v.avoidCollisionsTimer < 4 then
			entity_doCollisionAvoidance(me, dt, 4, 1.0)
		end
		entity_updateMovement(me, dt)		
	elseif entity_isState(me, STATE_SURFACE) then
		entity_moveAlongSurface(me, dt, 20, 2)
		entity_rotateToSurfaceNormal(me, 0.1)
		if not entity_isFlippedHorizontal(me) then
			entity_flipHorizontal(me)
		end		
		--entity_rotateToVel(me, 0.1)
	end
	
	local x, y = entity_getPosition(me)
	quad_setPosition(v.glow, x, y, 0.05)
	
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
	elseif entity_isState(me, STATE_DEAD) then
		if v.glow ~= 0 then
			quad_delete(v.glow)
		end
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function exitState(me)
	if entity_isState(me, STATE_SURFACE) then
		entity_rotate(me, 0, 1)
		entity_setState(me, STATE_IDLE)		
	end
end
