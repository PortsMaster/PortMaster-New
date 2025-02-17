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
-- V E D H A 
-- ================================================================================================


-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init()
	setupConversationEntity("Vedha")
	-- click/range, cursorRadius, playerRange
	entity_setActivation(AT_CLICK, 80, 256)
	entity_initPart("CloakFront", "vedha-cloak-front", 0, 0, 1)
	entity_partSetSegs("CloakFront", 2, 60, 0.1, 0.1, -0.018, 0, 2.5, 1)
	entity_initPart("CloakBack", "vedha-cloak-back", 0, 0, 0)
	entity_partSetSegs("CloakBack", 2, 60, 0.1, 0.1, -0.018, 0, 2.5, 1)	
	entity_followPath("VEDHATRAINING", 500, 0)
	entity_warpToPathStart()
end

function update(dt)
	entity_updateMovement(dt)
	if not entity_isFollowingPath() then
		entity_delete()
	end
end

function enterState()
end

function exitState()
end

function activate()
end

function hitSurface()
end
