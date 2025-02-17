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
v.bone_head = 0

local function doSkel(me, skel, skin)
	entity_initSkeletal(me, skel, skin)	
	v.bone_head = entity_getBoneByName(me, "Head")
end

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	
	entity_setAllDamageTargets(me, false)
	
	entity_scale(me, 0.5, 0.5)
	
	entity_generateCollisionMask(me)	
	
	entity_setState(me, STATE_IDLE)
	
	esetv(me, EV_LOOKAT, 0)
	
	doSkel(me, "Li", "")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
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
end

function msg(me, m)
	if m == "smile" then
		bone_showFrame(v.bone_head, EXPRESSION_HAPPY)
	elseif m == "normal" then
		bone_showFrame(v.bone_head, EXPRESSION_NORMAL)
	elseif m == "surprise" then
		bone_showFrame(v.bone_head, EXPRESSION_SURPRISE)
	elseif m == "end" then
		doSkel(me, "Li", "li-end")
	end
end

