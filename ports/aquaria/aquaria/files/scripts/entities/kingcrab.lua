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
-- K I N G   C R A B
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.fireDelay = 2
v.moveTimer = 0
v.clampTimer = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(me, 
	"kingcrab-head",				-- texture
	20,								-- health
	2,								-- manaballamount
	2,								-- exp
	1,								-- money
	20,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	256,							-- sprite width	
	256,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	--entity_offset(0, 128)
		
	-- entity_initPart(partName, partTexture, partPosition, partFlipH, partFlipV,
	-- partOffsetInterpolateTo, partOffsetInterpolateTime
	entity_initPart(me, 
	"ClawLeft", 
	"kingcrab-claw",
	-64,
	-48,
	0,
	1, 
	0)
	
	entity_initPart(me, 
	"ClawRight", 
	"kingcrab-claw",
	64,
	-48,
	0,
	0,
	0)
	
	entity_initPart(me, "LegsLeft", "kingcrab-leg", -64, 48, 0, 1, 0)
	entity_initPart(me, "LegsRight", "kingcrab-leg", 64, 48, 0, 0, 0)
	
	entity_partRotate(me, "ClawLeft", -32, 0.5, -1, 1, 1);
	entity_partRotate(me, "ClawRight", 32, 0.5, -1, 1, 1);

	entity_partRotate(me, "LegsLeft", 16, 0.25, -1, 1, 1);
	entity_partRotate(me, "LegsRight", -16, 0.25, -1, 1, 1);

	entity_scale(me, 0.5, 0.5)
	
	entity_setDeathParticleEffect(me, "Explode")
	
	entity_clampToSurface(me)
	
	esetv(me, EV_WALLOUT, 12)
	esetvf(me, EV_CLAMPTRANSF, 1)
	v.clampTimer = 999
end

function update(me, dt)
	--[[
	v.clampTimer = v.clampTimer + dt
	if v.clampTimer > 6 then
		entity_clampToSurface(me)
		v.clampTimer = 0
	end
	]]--

	
	-- dt, pixelsPerSecond, climbHeight, outfromwall
	
	entity_rotateToSurfaceNormal(me, 0)
	entity_moveAlongSurface(me, dt, 120, 6, 40) --64 -- 54
	
	-- entity_rotateToSurfaceNormal(0)
	v.moveTimer = v.moveTimer + dt
	if v.moveTimer > 30 then
		entity_switchSurfaceDirection(me)
		v.moveTimer = 0
	end
	if not(entity_hasTarget(me)) then
		entity_findTarget(me, 1200)
	else
		if v.fireDelay > 0 then
			v.fireDelay = v.fireDelay - dt
			if v.fireDelay < 0 then
				-- dmg, mxspd, homing, numsegs, out
				--entity_fireAtTarget(me, "BlasterFire", 1, 400, 200, 3, 64)
				v.fireDelay = 5
			end
		end
	end
	
	entity_handleShotCollisions(me)
	
	if entity_touchAvatarDamage(me, 80, 1, 1000) then
		-- do something maybe
	end
	
	if isObstructed(entity_x(me), entity_y(me)) then
		entity_adjustPositionBySurfaceNormal(me, 1)
	end
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
	end
end

function exitState(me)
end

function hitSurface()
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function dieNormal(me)
	if chance(50) then
		spawnIngredient("CrabMeat", entity_getPosition(me))
	end
end
