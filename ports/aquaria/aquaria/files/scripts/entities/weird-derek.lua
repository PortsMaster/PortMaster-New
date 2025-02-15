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

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "weird-derek")	
	entity_setAllDamageTargets(me, false)
	entity_setState(me, STATE_IDLE)
	entity_setEntityLayer(me, -1)
	entity_setActivation(me, AT_CLICK, 64, 512)
end

function postInit(me)
	v.n = getNaija()
	local node = entity_getNearestNode(me, "FLIP")
	if node ~=0 then
		if node_isEntityIn(node, me) then
			entity_fh(me)
		end
	end
end

function update(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
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
	entity_idle(v.n)
	entity_flipToEntity(v.n, me)
	fade2(1, 0.1, 1, 1, 1)
	watch(0.1)
	cam_toEntity(me)
	watch(0.5)
	fade2(0, 1, 1, 1, 1)
	watch(1)
	overrideZoom(1.2, 4)
	watch(2)
	emote(EMOTE_NAIJALAUGH)
	watch(1)
	fade(1, 1, 1, 1, 1)
	watch(1)
	cam_toEntity(getNaija())
	watch(0.5)
	fade(0, 0.5, 1, 1, 1)
	watch(0.5)
	overrideZoom(0)
end

