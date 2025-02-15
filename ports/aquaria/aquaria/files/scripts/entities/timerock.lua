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

v.d1 = 0
v.d2 = 0
v.d3 = 0

v.firstSet = true

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "timerock")	

	--entity_setTexture(me, "missingImage")
	entity_scale(me, 1.25, 1.25)	
	
	entity_alpha(me, 0.5)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setEntityLayer(me, -1)
	
	entity_setCullRadius(me, 256)
	
	v.d1 = entity_getBoneByName(me, "d1")
	v.d2 = entity_getBoneByName(me, "d2")
	v.d3 = entity_getBoneByName(me, "d3")
	
	v.firstSet = true
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

function msg(me, s, val)
	if s == "time" then
		if entity_isEntityInRange(me, getNaija(), 3500) then
			spawnParticleEffect("tinyredexplode", entity_x(me), entity_y(me))
			playSfx("saved")
		end
		
		local mins = math.floor(val/60)
		local secs = val - (mins*60)
		
		local secs1 = math.floor(secs/10)
		local secs2 = secs - (secs1*10)
		
		if mins > 9 then mins = 9 end
		
		debugLog(string.format("timerock %d : %d%d", mins, secs1, secs2))
		
		bone_setTexture(v.d1, string.format("seahorse/num-%d", mins))
		bone_setTexture(v.d2, string.format("seahorse/num-%d", secs1))
		bone_setTexture(v.d3, string.format("seahorse/num-%d", secs2))
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

