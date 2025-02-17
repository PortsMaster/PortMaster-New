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

-- energy door
function init(me)
	setupEntity(me, "")
	entity_initSkeletal(me, "Erulian")
	entity_setActivationType(me, AT_NONE)
	entity_setWidth(me, 512)
	entity_setHeight(me, 512)
	
	entity_scale(me, 0.75, 0.75)
	
	bone_setSegs(entity_getBoneByName(me, "Head"), 20, 4, 0.1, 0.1, -0.001, -0.018, 5, 1)
	bone_setSegs(entity_getBoneByName(me, "Body"), 20, 4, 0.1, 0.1, -0.001, -0.018, 5, 1)
	bone_setSegs(entity_getBoneByName(me, "Ear"), 20, 4, 0.1, 0.1, -0.001, -0.018, 5, 1)
	bone_setSegs(entity_getBoneByName(me, "Arm"), 20, 4, 0.1, 0.1, -0.001, -0.018, 5, 1)
	bone_setSegs(entity_getBoneByName(me, "Leg"), 20, 4, 0.1, 0.1, -0.001, -0.018, 5, 1)
	
	entity_setState(me, STATE_IDLE)
	entity_alpha(me, 0.0001)
	--[[
	entity_alpha(me, 0.5)
	entity_alpha(me, 1, 10, -1, 1)
	]]--
	entity_setSpiritFreeze(me, false)
	
	bone_alpha(entity_getBoneByName(me, "Glow"), 0)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", LOOP_INF)
	end
end

function exitState(me)
end

function hitSurface(me)
end
