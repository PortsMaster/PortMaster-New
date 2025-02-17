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

v.normal = 0
v.spirit = 0

v.curNode = 0
v.racePath = 0

v.speed = 1500

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "arnassi-spirit")	
	--entity_setTexture(me, "missingImage")
	
	entity_setSpiritFreeze(me, false)
	
	entity_setState(me, STATE_IDLE)
	
	v.normal = entity_getBoneByName(me, "normal")
	v.spirit = entity_getBoneByName(me, "spirit")
	
	bone_setBlendType(v.normal, BLEND_ADD)
	bone_alpha(v.normal, 1)
	bone_setColor(v.normal, 0.5, 0.6, 1)
	
	bone_alpha(v.spirit, 0)
	
	bone_rotateOffset(v.normal, 360, 0.5, -1)
	
	entity_setCullRadius(me, 512)
	
	v.racePath = getNode("arnassipath")	
	local c = 0
	local e = getFirstEntity()
	while e ~= 0 do
		if entity_isName(e, "arnassi-spirit") then
			c = c + 1
		end
		e = getNextEntity()
	end
	v.curNode = c*5
	

	local x, y = node_getPathPosition(v.racePath, v.curNode)
	entity_setPosition(me, x, y)

end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	if not entity_isInterpolating(me) then
		
		v.curNode = v.curNode + 1
		local x, y = node_getPathPosition(v.racePath, v.curNode)
		if x == 0 and y == 0 then
			v.curNode = 0
			x, y = node_getPathPosition(v.racePath, v.curNode)
		end
		entity_setPosition(me, x, y, -v.speed)
		
		if x > entity_x(me) and not entity_isfh(me) then
			entity_fh(me)
		elseif x < entity_x(me) and entity_isfh(me) then
			entity_fh(me)
		end
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

function shiftWorlds(me, lt, wt)
	local t = 0.9
	if wt == WT_SPIRIT then
		entity_scale(me, 0.8, 0.8, t, 0, 0, 1)
		bone_alpha(v.normal, 0.4, t)
		bone_alpha(v.spirit, 0.8, t)
		bone_scale(v.normal, 3, 3, t)
	elseif wt == WT_NORMAL then
		entity_scale(me, 1, 1, t, 0, 0, 1)
		bone_alpha(v.normal, 1, t)
		bone_alpha(v.spirit, 0, t)
		bone_scale(v.normal, 1, 1, t)
	end
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

