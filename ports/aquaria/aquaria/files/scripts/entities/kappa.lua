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
v.glow = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "Kappa")	
	entity_setAllDamageTargets(me, false)
	
	v.glow = entity_getBoneByName(me, "Glow")
	bone_alpha(v.glow, 0)
	bone_scale(v.glow, 2, 2)
	entity_setState(me, STATE_IDLE)
	
	entity_setEntityLayer(me, -3)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		bone_alpha(v.glow, 0)
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_CHARGE1) then
		playSfx("MenuNote0")
		bone_alpha(v.glow, 1)
		bone_setColor(v.glow, 1, 0.5, 0.5)
		bone_alpha(v.glow, 0, 1)
	elseif entity_isState(me, STATE_CHARGE2) then
		playSfx("MenuNote0")
		bone_alpha(v.glow, 1)
		bone_setColor(v.glow, 1, 1, 0.5)
		
		bone_alpha(v.glow, 0, 1)
	elseif entity_isState(me, STATE_CHARGE3) then
		playSfx("MenuNote7")
		bone_alpha(v.glow, 1)
		bone_setColor(v.glow, 0.5, 1, 0.5)		
		bone_alpha(v.glow, 0, 1)
		entity_setStateTime(me, 1)
	end
end

function exitState(me)
	if entity_isState(me, STATE_CHARGE3) then
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

