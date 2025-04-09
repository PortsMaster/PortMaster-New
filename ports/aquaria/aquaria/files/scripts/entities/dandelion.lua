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

v.n = 0

local STATE_SHAKE = 1001

v.bone_head = 0

function init(me)
	setupEntity(me)
	entity_setEntityLayer(me, -2)
	--entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "Dandelion")	
	entity_setAllDamageTargets(me, false)	
	entity_setCullRadius(me, 1024)	
	entity_generateCollisionMask(me)
	
	entity_setState(me, STATE_IDLE)
	v.bone_head = entity_getBoneByName(me, "Head")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	if entity_isState(me, STATE_IDLE) then
		--entity_handleShotCollisionsSkeletal(me)
		local bone = entity_collideSkeletalVsCircle(me, v.n)
		if bone ~= 0 and avatar_isBursting() then
			-- shake!
			entity_setState(me, STATE_SHAKE)
		end
	end
	entity_updateMovement(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_SHAKE) then
		entity_setStateTime(me, entity_animate(me, "shake"))
	end
end

function exitState(me)
	if entity_isState(me, STATE_SHAKE) then
		-- spawn spore seeds
		local x, y = bone_getWorldPosition(v.bone_head)
		createEntity("SeedFlower", "", x, y)
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

