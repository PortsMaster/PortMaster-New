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

-- throw rocks
v.n = 0
function init(me)
	setupEntity(me)
	entity_initSkeletal(me, "CC_Kid")
		
	entity_setState(me, STATE_IDLE)
	
	entity_scale(me, 0.6, 0.6)
	
	entity_setBeautyFlip(me, false)	
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	--entity_fh(me)	
end

function update(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "throwing", -1)
		--entity_update(me, math.random(100)/100.0)
	elseif entity_isState(me, STATE_TRANSFORM) then
		entity_setStateTime(me, entity_animate(me, "transform"))
	end
end

function exitState(me)
	if entity_isState(me, STATE_TRANSFORM) then
		local e = createEntity("Scavenger", "", entity_x(me), entity_y(me))
		entity_setState(e, STATE_GROW, -1, 1)
		entity_alpha(e, 0)
		entity_alpha(e, 1, 0.5)
		entity_delete(me, 0.5)
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

function sporesDropped(me, x, y)
end

function activate(me)
end

