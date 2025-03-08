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

-- SPORE SEED

v.growEmitter = 0
v.done = false
v.weight = 400

v.SEED_FLOWER		= 0
v.SEED_VINE			= 1
v.SEED_UBERVINE		= 2

v.seedType = 0

function v.commonInit(me, st)
	setupEntity(me)
	entity_setTexture(me, "Naija/Seedling")
	entity_setEntityLayer(me, 1)
	
	entity_initEmitter(me, v.growEmitter, "SporeSeedGrow")
	
	entity_setHealth(me, 1)
	entity_setCollideRadius(me, 2)
	entity_setWeight(me, v.weight)
	entity_setState(me, STATE_IDLE)
	entity_setMaxSpeed(me, 800)
	
	entity_alpha(me, 0)
	entity_alpha(me, 1, 0.2)
	entity_setCanLeaveWater(me, true)
	entity_setEntityType(me, ET_ENEMY)
	entity_setAllDamageTargets(me, false)
	entity_setDamageTarget(me, DT_AVATAR_BITE, true)
	
	v.seedType = st
	
	if v.seedType == v.SEED_FLOWER then
		entity_setTexture(me, "Naija/Seed")
	elseif v.seedType == v.SEED_UBERVINE then
		entity_setTexture(me, "Naija/Uberseed")
	end
end

function postInit(me)
	entity_ensureLimit(me, 3, STATE_DONE)
end

local function terminate(me)
	if not v.done then
		
		if v.seedType == v.SEED_VINE then
			registerSporeDrop(entity_x(me), entity_y(me),1)
			createEntity("Vine", "", entity_getPosition(me))
		elseif v.seedType == v.SEED_UBERVINE then
			registerSporeDrop(entity_x(me), entity_y(me),2)
			createEntity("UberVine", "", entity_getPosition(me))
		else
			registerSporeDrop(entity_x(me), entity_y(me),0)
			createEntity("NatureFormFlowers", "", entity_getPosition(me))
		end
		
		entity_delete(me)
		
		v.done = true
	end
end

function songNote(me, note)	
end

function update(me, dt)
	if not v.done then
		if entity_updateCurrents(me, dt) then
			entity_setWeight(me, 1)
		else
			if entity_isUnderWater(me) then
				entity_setWeight(me, v.weight)
			else
				entity_setWeight(me, v.weight*2)
			end
		end
		entity_updateMovement(me, dt)
		if entity_isNearObstruction(me, 2) then
			terminate(me)
		end
	end
end

function hitSurface(me)
	--terminate(me)
end

function enterState(me)
	if entity_isState(me, STATE_DONE) then
		debugLog("state done")
		entity_delete(me, 0.2)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		return true
	end
	return false
end

function exitState(me)
end
