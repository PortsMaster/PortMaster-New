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

-- generic egg
local STATE_HATCH	= 1000

function init()
	setupConversationEntity("egg")
	entity_setActivationType(AT_NONE)
	entity_setEntityType(ET_NEUTRAL)
end

function hatch()
	entity_stopTimer()	
	if entity_getState()==STATE_IDLE then
		entity_createEntity(v.entityTypeName)
	elseif entity_getState()==STATE_PLANTED then
		entity_createPet(v.entityTypeName)
	end
	entity_delete()
	entity_setState(STATE_HATCH)
end

function exitTimer()
	hatch()
end

function update()
	if entity_getState()==STATE_IDLE then
		if not entity_hasTarget() then
			entity_findTarget(800)
		else
			if entity_isTargetInRange(64) then
				pickupItem(v.itemName, 1)
				entity_delete()
			end
		end
	end
end

function enterState()
	if entity_getState()==STATE_PLANTED then
		entity_resetTimer(v.plantedTime)
	elseif entity_getState()==STATE_IDLE then
		entity_resetTimer(v.hatchTime)
	end
end

function exitState()
end

function activate()
end

function hitSurface()
end
