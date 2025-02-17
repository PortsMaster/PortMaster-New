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

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init()
	setupBasicEntity(
	"kingcrab-head",				-- texture
	20,								-- health
	2,								-- manaballamount
	2,								-- exp
	1,								-- money
	64,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	256,							-- sprite width	
	256,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	--entity_offset(0, 128)
		
	-- entity_initPart(partName, partTexture, partPosition, partFlipH, partFlipV,
	-- partOffsetInterpolateTo, partOffsetInterpolateTime
	entity_initPart(
	"ClawLeft", 
	"kingcrab-claw",
	-64,
	-48,
	0,
	1, 
	0)
	
	entity_initPart(
	"ClawRight", 
	"kingcrab-claw",
	64,
	-48,
	0,
	0,
	0)
	
	entity_initPart("LegsLeft", "kingcrab-leg", -64, 48, 0, 1, 0)
	entity_initPart("LegsRight", "kingcrab-leg", 64, 48, 0, 0, 0)
	
	entity_partRotate("ClawLeft", -32, 0.5, -1, 1, 1);
	entity_partRotate("ClawRight", 32, 0.5, -1, 1, 1);

	entity_partRotate("LegsLeft", 16, 0.25, -1, 1, 1);
	entity_partRotate("LegsRight", -16, 0.25, -1, 1, 1);

	entity_scale(0.5, 0.5)
	
	
	entity_clampToSurface()
end

function update(dt)
	-- dt, pixelsPerSecond, climbHeight, outfromwall
	entity_moveAlongSurface(dt, 100, 6, 54) --64 (32)
	entity_rotateToSurfaceNormal(0.1)
	if not(entity_hasTarget()) then
		entity_findTarget(1200)
	else
		if entity_isTargetInRange(64) then
			entity_pushTarget(500)
		end
		if v.fireDelay > 0 then
			v.fireDelay = v.fireDelay - dt
			if v.fireDelay < 0 then
				-- FIXME: obsolete function
				-- dmg, mxspd, homing, numsegs, out
				--entity_fireAtTarget(1, 1000, 200, 3, 64)
				v.fireDelay = 5
			end
		end
	end
end

function enterState()
	if entity_getState()==STATE_IDLE then
	end
end

function exitState()
end

function hitSurface()
end
