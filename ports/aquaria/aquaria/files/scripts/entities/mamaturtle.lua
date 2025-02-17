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
-- M A M A  T U R T L E
-- ================================================================================================

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

local STATE_SCREECH			= 1000

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	999,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	512,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,							-- initState
	512,								-- sprite width	
	512,								-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000								-- updateCull -1: disabled, default: 4000
	)
	
	entity_setEntityLayer(me, -3)
	entity_initSkeletal(me, "mamaturtle")
	entity_animate(me, "idle", -1)
	
	entity_setState(me, STATE_IDLE)

	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	
	entity_setCullRadius(me, 1024)
	
	loadSound("mamaturtle-roar")
	
	entity_setEntityType(me, ET_NEUTRAL)
end

function update(me, dt)
	if entity_isEntityInRange(me, getNaija(), 500) then
		if entity_isState(me, STATE_IDLE) then
			entity_setState(me, STATE_SCREECH)
		end
	elseif entity_isState(me, STATE_SCREECH) then
		entity_setState(me, STATE_IDLE)
	end
	--entity_updateMovement(me, dt)
end

function hitSurface(me)
end

function animationKey(me, key)
	if entity_isState(me, STATE_SCREECH) then
		if key == 1 then
			playSfx("mamaturtle-roar")
			shakeCamera(3, 2)
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_SCREECH) then
		entity_animate(me, "screech")
	elseif entity_isState(me, STATE_OPEN) then
		local nd = 0
		if isFlag(FLAG_MAMATURTLE_RESCUE3, 1) then
			nd = getNode("P3")
		elseif isFlag(FLAG_MAMATURTLE_RESCUE2, 1) then
			nd = getNode("P2")
		elseif isFlag(FLAG_MAMATURTLE_RESCUE1, 1) then
			nd = getNode("P1")
		end
		cam_toNode(nd)
		watch(1)
		local plant = node_getNearestEntity(nd, "ancient-plant")
		entity_setState(plant, STATE_OPEN)
		watch(1)
	end
end

function exitState(me)
end
