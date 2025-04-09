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
-- M O N E Y E
-- ================================================================================================


v.spawnTime = 5
v.spawnTimer = 1

v.bounces = 0

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(me, 
	"",						-- texture
	12,							-- health
	1,							-- manaballamount
	1,							-- exp
	1,							-- money
	96,							-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	300,							-- sprite width	
	300,							-- sprite height
	1,							-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,							-- 0/1 hit other entities off/on (uses collideRadius)
	3000							-- updateCull -1: disabled, default: 4000
	)
	entity_setSegs(me, 2, 32, 0.1, 0.1, -0.018, 0, 2.5, 1)
	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	--entity_setEatType(me, EAT_FILE, "MoneyeBreeder")
	
	entity_initSkeletal(me, "aggroeggs")
	
	loadSound("aggroeggs-spawn")
end

function update(me, dt)
	if entity_isState(me, STATE_GROW) then
		entity_addVel(me, 0, 1000*dt)
		entity_updateMovement(me, dt)
	else
		
		if entity_isEntityInRange(me, getNaija(), 900) then
			v.spawnTimer = v.spawnTimer - dt
			if v.spawnTimer < 0 then
				--debugLog("Spawning")
				local out = 100
				local nx, ny = entity_getNormal(me)
				nx = nx * out
				ny = ny * out
				v.spawnTimer = v.spawnTime
				local moneye = createEntity("aggrobaby", "", entity_x(me)+nx, entity_y(me)+ny)
				spawnParticleEffect("MoneyeBirth", entity_x(me)+nx, entity_y(me)+ny)
				entity_alpha(moneye, 0)
				entity_alpha(moneye, 1, 0.5)
				
				entity_sound(me, "aggroeggs-spawn")
			end
		else
			v.spawnTimer = v.spawnTimer - dt*0.3
		end
	end
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0.5, 400)
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
	elseif entity_isState(me, STATE_GROW) then
		entity_setMaxSpeed(me, 800)		
	end
end

function exitState(me)
end

function hitSurface(me)
	if entity_isState(me, STATE_GROW) then
		
		entity_rotateToSurfaceNormal(me)
		v.bounces = v.bounces + 1
		if v.bounces > 3 then
			entity_setState(me, STATE_IDLE)
		end
	end
end

function dieNormal(me)
	if chance(100) then
		spawnIngredient("SmallEgg", entity_x(me), entity_y(me))
	end
end

