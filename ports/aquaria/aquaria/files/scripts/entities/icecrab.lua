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
-- I C E   C R A B
-- ================================================================================================

-- ================================================================================================
-- L O C A L   V A R I A B L E S 
-- ================================================================================================

v.moveTimer = 0

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	setupBasicEntity(me, 
	"IceCrab/Body",					-- texture
	18,								-- health
	1,								-- manaballamount
	0,								-- exp
	0,								-- money
	34,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	3210							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setDeathParticleEffect(me, "Explode")
	
	entity_initSkeletal(me, "IceCrab")
	entity_scale(me, 1.1, 1.1)
	
	esetv(me, EV_WALLOUT, 23)
	entity_clampToSurface(me)
end

function postInit(me)
	entity_setState(me, STATE_IDLE)
	
	-- FLIP WITH A FLIP NODE
	local node = entity_getNearestNode(me, "FLIP")
	if node ~=0 then
		if node_isEntityIn(node, me) then 
			entity_fh(me)
		entity_switchSurfaceDirection(me)
		end
	end
end

function update(me, dt)
	-- FLIP AFTER A WHILE
	v.moveTimer = v.moveTimer + dt
	if v.moveTimer > 42 then
		entity_switchSurfaceDirection(me)
		entity_fh(me)
		v.moveTimer = 0
	end

	-- MOVEMENT
	entity_moveAlongSurface(me, dt, 76)
	entity_rotateToSurfaceNormal(me, 0.54)	
	-- COLLISIONS
	entity_touchAvatarDamage(me, 56, 0.76, 321)
	entity_handleShotCollisions(me)
end

function enterState(me)
	if entity_getState(me) == STATE_IDLE then
		entity_animate(me, "idle", LOOP_INF)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function dieNormal(me)
	if chance(50) then
		spawnIngredient("IceChunk", entity_x(me), entity_y(me))
	end
end
