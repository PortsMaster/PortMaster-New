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
-- SPIKEBALL
-- ================================================================================================

-- entity specific
v.dir = 0
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function v.commonInit(me, initDir)
	v.dir = initDir
	setupBasicEntity(
	me,
	"SpikeyEgg",					-- texture
	10,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	90,								-- collideRadius
	STATE_IDLE,						-- initState
	256,							-- sprite width	
	256,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	entity_setAllDamageTargets(me, false)
	--entity_scale(me, 0.9, 0.9)
end

function postInit(me)
end

function update(me, dt)
--[[
	local spd = 500
	if v.dir == 0 then
		entity_addVel(me, 0, spd*dt)
	else
		entity_addVel(me, 0, -spd*dt)
	end
	entity_updateMovement(me, dt)
	]]--
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0.5, 500, 0.5)
	
end

function enterState(me)
end

function exitState(me)
end

function hitSurface(me)
	entity_clearVel(me)
	if v.dir == 0 then
		v.dir = 1
	else
		v.dir = 0
	end
end

function activate(me)
end

function damage(me)
	return false
end
