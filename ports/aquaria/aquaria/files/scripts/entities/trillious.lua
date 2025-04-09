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
-- T R I L L I O U S
-- ================================================================================================

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.swimTime = 1.25
v.swimTimer = v.swimTime - v.swimTime/4
v.gasTimer = 1
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(me, 
	"trillious-head",				-- texture
	8,								-- health
	2,								-- manaballamount
	2,								-- exp
	1,								-- money
	32,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
		
	-- entity_initPart(partName, partTexture, partPosition, partFlipH, partFlipV,
	-- partOffsetInterpolateTo, partOffsetInterpolateTime
	entity_initPart(me, 
	"FlipperLeft", 
	"trillious-flipper",
	-12,
	32,
	1,
	0, 
	0)
	
	entity_initPart(me, 
	"FlipperRight", 
	"trillious-flipper",
	12,
	32,
	1,
	1,
	0)
	
	entity_partRotate(me, "FlipperLeft", 45, v.swimTime/2, -1, 1, 1)
	entity_partRotate(me, "FlipperRight", -45, v.swimTime/2, -1, 1, 1)
	
	entity_setDeathParticleEffect(me, "PurpleExplode")

	entity_addRandomVel(me, 500)
	-- entity_scale(0.8, 0.8)
end

function update(me, dt)
	entity_handleShotCollisions(me)
	if v.gasTimer > 0 then
		v.gasTimer = v.gasTimer - dt
		if v.gasTimer < 0 then
			v.gasTimer = 8
			entity_fireGas(me, 40, 4, 0.25, "Gas", 0, 0.8, 0.6, 0, 0, 2)
			entity_addRandomVel(me, 1000)
			spawnParticleEffect("tinygreenexplode", entity_x(me), entity_y(me))
			entity_sound(me, "boil")
		end
	end
--	entity_doEntityAvoidance(dt, 256, 1);
	entity_doCollisionAvoidance(me, dt, 12, 0.1);
	entity_updateMovement(me, dt)
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_setMaxSpeed(me, 400)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_ENEMY_GAS then
		return false
	end
	return true
end
