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
-- Energy God
-- ================================================================================================

function init(me)	
	setupBasicEntity(
	me,
	"",					-- texture
	30,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	0,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	1024,								-- sprite width
	1024,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000,							-- updateCull -1: disabled, default: 4000
	1
	)
	entity_initSkeletal(me, "EnergyGod")
	entity_setCull(me, false)
	--entity_setTouchPush(me, 1)	
	--entity_flipHorizontal(me)
	--entity_setCollideWithAvatar(me, true)

	entity_setName(me, "EnergyGod")
	entity_setState(me, STATE_IDLE)	
	--entity_generateCollisionMask(me)

	v.naija = getNaija()
end

function update(me, dt)

--[[
	local bone = entity_collideSkeletalVsCircle(me, getNaija())
	if bone ~= 0 or entity_x(v.naija) < entity_x(me) then
		entity_push(getNaija(), 1200, 0, 1)
	end
	]]--
	
	if entity_x(v.naija) < entity_x(me) and entity_x(v.naija) > entity_x(me) - 256 then
		entity_push(getNaija(), 1200, 0, 1)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	
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

