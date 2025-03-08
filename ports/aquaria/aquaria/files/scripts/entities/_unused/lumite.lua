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

-- L U M I T E
-- ================================================================================================
-- entity specific
local STATE_STUNNED			= 1000
local STATE_GRABBED			= 1001
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init()
	setupBasicEntity(
	"Lumite",						-- texture
	1,								-- health
	0,								-- manaballamount
	1,								-- exp
	0,								-- money
	16,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	32,								-- sprite width
	32,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	5000,							-- updateCull -1: disabled, default: 4000
	2								-- layer 0: below avatar, 1: above avatar, 2: dark layer
	)
	
	entity_initPart("Glow", "lumite-glow", 0, 0, 1)
	
	entity_partWidthHeight("Glow", 1024, 1024)
	entity_partBlendType("Glow", 1)
	entity_scale(0.5, 0.5)
end

function update(dt)	
	if entity_getState()==STATE_IDLE then
		if not entity_hasTarget() then
			entity_findTarget(800)
			--entity_partAlpha("Glow", -1, 0, 0.1)
		else
			if not entity_isTargetInRange(300) then
				entity_moveTowardsTarget(dt, 1000)
			else
				entity_moveTowardsTarget(dt, -1500)
			end
			--[[
			dist = entity_getDistanceToTarget()
			totalDist = 600
			if dist > totalDist then
				entity_partAlpha("Glow", -1, 0.1)
			else
				entity_partAlpha("Glow", -1, ((totalDist-dist)/totalDist)*0.5+0.1)
			end
			]]--
			--entity_partAlpha("Glow", 1, 0.1)
		end
		entity_doSpellAvoidance(dt, 200, 0.5)
		entity_doCollisionAvoidance(dt, 5, 1)
		entity_doEntityAvoidance(dt, 64, 0.5)
		entity_updateMovement(dt)
		entity_rotateToVel(0.1)
	end
end

function enterState()
	if entity_getState()==STATE_IDLE then
		entity_setMaxSpeed(500)
	elseif entity_getState()==STATE_DEAD then
		entity_partAlpha("Glow", -1, 0, 0.1)
	end
end

function exitState()
end

function hitSurface()
end