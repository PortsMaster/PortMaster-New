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
-- C R E E P Y   F A C E
-- ================================================================================================

-- ================================================================================================
-- L O C A L   V A R I A B L E S
-- ================================================================================================


-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	v.faceTimer = 1.23 + (math.random(123) * 0.1)

	setupBasicEntity(
	me,
	"CreepyFace/Face",				-- texture
	69,								-- health
	69,								-- manaballamount
	69,								-- exp
	69,								-- money
	69,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	256,							-- sprite width	
	256,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	1234							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setAllDamageTargets(me, false)
	
	entity_setState(me, STATE_IDLE)
end

function postInit(me)
	entity_alpha(me, 0)
end

function update(me, dt)
	if v.faceTimer > 0 then v.faceTimer = v.faceTimer - dt
	elseif v.faceTimer <= 0 then
		v.faceTimer = 1.23 + (math.random(123) * 0.1)
		
		spawnParticleEffect("CreepyFace", entity_x(me), entity_y(me))
	end
end

function enterState(me)
	if entity_getState(me) == STATE_IDLE then
	end
end

function damage(me, attacker, bone, damageType, dmg, x, y)
	return false
end

function exitState(me)
end
