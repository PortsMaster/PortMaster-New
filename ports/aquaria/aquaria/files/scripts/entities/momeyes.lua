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
v.beam = 0
v.timer = 0

v.delayTimeMin = 1
v.delayTimeMax = 0.25
v.delay = v.delayTimeMin
v.delayTime = v.delayTimeMin
v.delayTimeBit = 0.05

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_setTexture(me, "SunkenMom/MomEyes")
	entity_setAllDamageTargets(me, false)
	
	entity_alpha(me)
	entity_alpha(me, 1, 0.1)
	entity_setState(me, STATE_IDLE)
	entity_scale(me, 1, 0.1)
	entity_scale(me, 1, 1, 0.4, 0, 1)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	if v.timer == -1 then return end

	local sx, sy = entity_getScale(me)
	if sy == 1 then
		v.delay = v.delay - dt
		if v.delay < 0 then
			v.delay = v.delayTime
			
			local s = createShot("MomVision", me, v.n, entity_x(me), entity_y(me)+16)
			shot_setAimVector(s, randVector(1))
			
			if v.delayTime > v.delayTimeMax then
				v.delayTime = v.delayTime - v.delayTimeBit
			end
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_DONE) then
		entity_scale(me, 1, 0.1, 0.2)
		entity_delete(me, 0.2)		
		v.timer = -1
		if v.beam ~= 0 then
			beam_delete(v.beam)
		end
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

