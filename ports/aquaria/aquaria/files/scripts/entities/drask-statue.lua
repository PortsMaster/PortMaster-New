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

local STATE_SIT				= 1000

function init(me)
	setupEntity(me)
	entity_initSkeletal(me, "drasktrident", "drask-statue")
	
	entity_setCullRadius(me, 2048)
	entity_setState(me, STATE_SIT)
	
	local bTrident = entity_getBoneByName(me, "Trident")
	bone_alpha(bTrident, 0)
	
	entity_scale(me, 0.7, 0.7)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	local flip = entity_getNearestNode(me, "flip")
	if flip ~= 0 then
		if node_isEntityIn(flip, me) then
			entity_fh(me)
		end
	end
end

function update(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_SIT) then
		entity_animate(me, "sitstill", -1)
	end
end

function exitState(me)
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

