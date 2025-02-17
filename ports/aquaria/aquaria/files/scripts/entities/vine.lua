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

-- SPORE SEED

v.growEmitter = 0
v.done = false
v.lifeTime = 0

function init(me)
	setupEntity(me)
	entity_setTexture(me, "Naija/Thorn")
	--[[
	entity_setWidth(me, 64)
	entity_setHeight(me, 512)
	]]--
	entity_setEntityLayer(me, -1)
	
	entity_initEmitter(me, v.growEmitter, "SporeSeedGrow")
	
	entity_setCollideRadius(me, 0)
	entity_setState(me, STATE_IDLE)
	entity_setInternalOffset(me, 0, -128)
	
	v.lifeTime = 5
	
	entity_alpha(me, 0)
	entity_alpha(me, 1, 0.1)
	
	entity_scale(me, 1, 0)
	entity_scale(me, 1, 1, 0.5, 0, 0, 1)
	
	entity_clampToSurface(me)
end

function postInit(me)
	entity_rotateToSurfaceNormal(me)
end

function songNote(me, note)
end

function update(me, dt)
	if not v.done then
		v.lifeTime = v.lifeTime - dt
		if v.lifeTime < 0 then
			entity_delete(me, 0.2)
			v.done = true
		end

		local sx, sy = entity_getScale(me)
		local len = 256*sy
		local x1, y1 = entity_getPosition(me)
		local fx, fy = entity_getNormal(me)
		local x2 = x1 + fx*len
		local y2 = y1 + fy*len
			
		local ent = getFirstEntity()
		while ent~=0 do
			if entity_getEntityType(ent) ~= ET_NEUTRAL and ent ~= me and entity_isDamageTarget(ent, DT_AVATAR_VINE) then
				local dmg = 0.5
				if entity_getEntityType(ent)==ET_AVATAR and isForm(FORM_NATURE) then
					dmg = 0
				end
				if entity_collideCircleVsLine(ent, x1,y1,x2,y2,16) then
					if dmg ~= 0 then
						entity_damage(ent, me, 0.5, DT_AVATAR_VINE)
					end
				end
			end
					
			ent = getNextEntity()
		end
		
	end
end

function hitSurface(me)
end

function enterState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function exitState(me)
end
