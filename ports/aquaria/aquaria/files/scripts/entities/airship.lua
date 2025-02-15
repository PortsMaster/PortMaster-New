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
v.attached = 0
v.bone_attach = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "airship")

	for i=1,2 do
		local blade = entity_getBoneByIdx(me, i)
		bone_scale(blade, 0.1, 1, 0.1, -1, 1)
	end
	
	entity_setState(me, STATE_IDLE)
	
	entity_scale(me, 1.2, 1.2)
	
	entity_setCull(me, false)
	
	entity_setEntityLayer(me, 1)
	
	entity_fh(me)
	
	v.bone_attach = entity_getBoneByName(me, "attach")
	bone_alpha(v.bone_attach, 0)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	if v.attached ~= 0 then
		local bx, by = bone_getWorldPosition(v.bone_attach)
		entity_setPosition(v.attached, bx, by)
	end
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
end

function msg(me, msg, val)
	if msg == "attach" then
		v.attached = val
	end
end


