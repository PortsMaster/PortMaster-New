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
-- Energy Boss CLIMB
-- ================================================================================================

v.node = 0

v.speed = 550

function init(me)	
	setupBasicEntity(
	me,
	"",								-- texture
	30,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	0,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	entity_initSkeletal(me, "EnergyBoss")
	entity_setState(me, STATE_IDLE)
	entity_setCull(me, false)	
	entity_setName(me, "EnergyBossClimb")
	
	--entity_flipHorizontal(me)	
	entity_generateCollisionMask(me)	
	v.node = getNode("NARROW")	
end

function update(me, dt)
	entity_handleShotCollisionsSkeletal(me)
	
	local bone = entity_collideSkeletalVsCircle(me, getNaija())
	if bone ~= 0 then
		entity_damage(getNaija(), me, 1000)
		entity_push(getNaija(), 0, -1200, 1)
	end

	if entity_y(me)-256 > node_y(v.node) then
		entity_setPosition(me, entity_x(me), entity_y(me) - v.speed * dt)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", LOOP_INF)
	end
end

function exitState(me)
end

function activate(me)
end

function hitSurface(me)
end

