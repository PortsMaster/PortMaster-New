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

v.life = 10

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	
	entity_setTexture(me, "particles/blow-bubble")
	
	entity_alpha(me, 0.6)
	
	entity_setBlendType(me, BLEND_ADD)

	entity_setState(me, STATE_IDLE)
	
	entity_setWeight(me, -20)
	
	entity_setMaxSpeed(me, 300)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

local function pop(me)
	spawnParticleEffect("bubble-release", entity_x(me), entity_y(me))
	spawnParticleEffect("pop-big", entity_x(me), entity_y(me))
	entity_delete(me)
end

function update(me, dt)
	entity_updateMovement(me, dt)
	
	v.life = v.life - dt
	if v.life < 0 then
		pop(me)
		return
	end
	
	if entity_isEntityInRange(me, v.n, 40) then
		local vx = entity_velx(v.n)
		local vy = entity_vely(v.n)
		if vector_isLength2DIn(vx, vy, 600) then
			-- push
			entity_moveTowardsTarget(me, dt, -500)
		else
			-- pop
			pop(me)
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

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
	local r,g,b = getNoteColor(note)
	entity_setColor(me, r,g,b, 0.2)
end

function songNoteDone(me, note)
end

function song(me, song)
	
end

function activate(me)
end

