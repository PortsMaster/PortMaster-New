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

v.done = false
v.lifeTime = 0

local STATE_WITHER = 1001

function init(me)
	setupEntity(me)
	entity_initSkeletal(me, "NatureFormFlowers")
		
	entity_setCollideRadius(me, 0)
	
	entity_setInternalOffset(me, 0, -32)	
	
	v.lifeTime = 5
	
	entity_alpha(me, 0)
	entity_alpha(me, 1, 0.1)
	
	entity_scale(me, 0.5, 0)
	local v = math.random(100)/250.0
	entity_scale(me, 0.95+v, 0.95+v, 0.5, 0, 0, 1)
	
	--entity_clampToSurface(me)
	entity_setState(me, STATE_IDLE)
	
	local c = (math.random(100)/100.0)*0.1 + 0.9
	entity_setColor(me, c, c, c)

	
	if chance(50) then
		entity_fh(me)
	end
	
	--debugLog("HEREE!!!")
end

function postInit(me)
	entity_clampToSurface(me)
	entity_rotateToSurfaceNormal(me)
	--entity_rotateToSurfaceNormal(me)
	--local c = ((math.random(200)-100)/100.0)*45
	--entity_rotate(me, entity_getRotation(me) + c)	
end

function songNote(me, note)
end

function update(me, dt)
	if entity_isState(me, STATE_IDLE) then
		if not v.done then
			v.lifeTime = v.lifeTime - dt
			if v.lifeTime < 0 then
				v.done = true
				entity_setState(me, STATE_WITHER)
			end
		end
	end
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_WITHER) then
		entity_setStateTime(me, entity_animate(me, "wither")+2)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function exitState(me)
	if entity_isState(me, STATE_WITHER) then
		local x, y = entity_getScale(me)
		entity_scale(me, x, 0.4, 3)
		entity_delete(me, 3)
	end
end
