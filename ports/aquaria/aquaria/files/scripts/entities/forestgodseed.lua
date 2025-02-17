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

-- ===============================================================================================
-- SPORE CHILD
-- ================================================================================================

v.growth = 0
v.growTime = 5
v.growEmitter = 0
v.seekEnemy = 0
v.seekEnemyDelay = 1.5

v.minSpeed = 450
v.maxSpeed = 700

v.backAway = 0
v.backAwayTime = 0.75

v.myType = 1

function init(me)
	setupBasicEntity(
	me,
	"SporeChildSeed",				-- texture
	1,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	16,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	64,								-- sprite width	
	64,								-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1,								-- updateCull -1: disabled, default: 4000
	1
	)
	
	entity_initEmitter(me, v.growEmitter, "SporeSeedGrow")
	
	entity_setCollideRadius(me, 64)
	entity_setEntityType(me, ET_ENEMY)
	
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
	entity_setDamageTarget(me, DT_AVATAR_SHOCK, false)
	entity_setDamageTarget(me, DT_AVATAR_BITE, true)
	--entity_setDamageTarget(me, DT_AVATAR_VOMIT, false)
	--entity_setDamageTarget(me, DT_AVATAR_SPORECHILD, false)
	
	entity_setState(me, STATE_SEED)
	
	entity_setWeight(me, 100)
	
	v.seekEnemy = v.seekEnemyDelay
end

function update(me, dt)
	entity_handleShotCollisions(me)
	entity_updateMovement(me, dt)
	if entity_isState(me, STATE_SEED) then
	end
end

function hitSurface(me)
	entity_delete(me)
	createEntity("UberVine", "", entity_x(me), entity_y(me))
end

function enterState(me)
	if entity_isState(me, STATE_SEED) then
		
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_ENERGYBLAST then
		return false
	end
	if damageType == DT_AVATAR_BITE then
		debugLog("bite!!")
		entity_delete(me)
		return true
	end
	return true
end

function exitState(me)
end
