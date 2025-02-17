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
--v.hits = 0

function init(me)
	setupEntity(me)
	entity_setEntityLayer(me, -2)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "SunkenDoor")

--[[	
	entity_setAllDamageTargets(me, false)
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, true)
]]--
	
	entity_generateCollisionMask(me)	
	
	entity_setState(me, STATE_IDLE)
	
	entity_scale(me, 1.5, 1.5)
	entity_setCullRadius(me, 1024)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then
		entity_clearVel(v.n)
		entity_addVel(v.n, 500, 0)
		entity_setPosition(v.n, entity_x(v.n)+2, entity_y(v.n))
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_OPEN) then
		entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
		entity_animate(me, "open")
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_isState(me, STATE_IDLE) then
	--[[
		if damageType == DT_AVATAR_LIZAP then
			v.hits = v.hits + dmg
			if v.hits > 5 then
				entity_setState(me, STATE_OPEN)
			end
		end
	]]--
	end
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

