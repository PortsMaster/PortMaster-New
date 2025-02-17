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
	entity_initSkeletal(me, "KrotiteVsKrotite")	
	
	entity_setCullRadius(me, 2048)
	entity_setState(me, STATE_IDLE)
	
	entity_scale(me, 0.7, 0.7)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_ON) then
		entity_stopAllAnimations(me)
		entity_animate(me, "idle", 0, 0, -1)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function animationKey(me, key)
	if entity_isState(me, STATE_ON) then
		if key == 9 then
			playSfx("EnergyOrbCharge", 0, 0.2)
		elseif key == 13 then
			playSfx("EnergyForm", 0, 0.2)
		elseif key == 19 then
			playSfx("EnergyOrbCharge", 0, 0.2)
		elseif key == 21 then
			playSfx("EnergyForm", 0, 0.2)
		end
	end
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

