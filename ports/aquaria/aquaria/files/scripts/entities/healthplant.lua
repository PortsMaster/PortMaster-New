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
-- HEALTH PLANT
-- ================================================================================================

v.particleDelay = 0
v.out = 32
-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"HealthPlant",					-- texture
	15,								-- health
	2,								-- manaballamount
	2,								-- exp
	1,								-- money
	32,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	64,								-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	2000							-- updateCull -1: disabled, default: 4000
	)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_setSegs(me, 2, 8, 0.3, 0.1, -0.018, 0, 6, 0)
end

function update(me, dt)
	if entity_isState(me, STATE_IDLE) then
		v.particleDelay = v.particleDelay - dt
		if v.particleDelay < 0 then
			v.particleDelay = 0.6
			local nx, ny = entity_getNormal(me)
			nx = nx * v.out
			ny = ny * v.out
			spawnParticleEffect("HealthPlantGlow", entity_x(me)+nx, entity_y(me)+ny)
		end
		
		if entity_isEntityInRange(me, getNaija(), 64) then
			spawnManaBall(entity_x(getNaija()), entity_y(getNaija()), 1)
			entity_setState(me, STATE_USED)
		elseif entity_isEntityInRange(me, getNaija(), 580) and avatar_isRolling() then
			local nx, ny = entity_getNormal(me)			
			nx = nx * v.out
			ny = ny * v.out		
			spawnManaBall(entity_x(me)+nx, entity_y(me)+ny, 1)
			entity_setState(me, STATE_USED)		
		end
	elseif entity_isState(me, STATE_USED) then
		
	end
end

function enterState(me)
	if entity_isState(me, STATE_USED) then		
	elseif entity_isState(me, STATE_IDLE) then
	end
end

function animationKey(me, key)
end

function exitState(me)
end

function hitSurface(me)
end
