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

v.delay = 0.2
v.b1 = 0
v.b2 = 0
function v.commonInit(me, file)
	setupEntity(me)
	entity_initSkeletal(me, file)
	
	v.b1 = entity_getBoneByIdx(me, 0)
	v.b2 = entity_getBoneByIdx(me, 1)
	
	bone_alpha(v.b2, 0)

	entity_setState(me, STATE_IDLE)
	esetv(me, EV_LOOKAT, false)
end

function postInit(me)
end

function update(me, dt)
	if v.delay > -1 then
		v.delay = v.delay - dt
		if v.delay < 0 then
			v.delay = -1
			bone_alpha(v.b2, 1, 6)
			bone_alpha(v.b1, 0, 6)
		end
	end
end

function enterState(me)
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

