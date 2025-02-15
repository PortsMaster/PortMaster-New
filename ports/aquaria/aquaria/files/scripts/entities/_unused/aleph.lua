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

v.maxFireDelay = 2

v.fireDelay = v.maxFireDelay

v.btm = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "aleph")	
	entity_setAllDamageTargets(me, false)
	
	entity_generateCollisionMask(me)
	
	entity_setState(me, STATE_IDLE)
	
	v.btm = entity_getBoneByName(me, "btm")
	
	bone_alpha(v.btm, 0.5, 0.1, -1, 1)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	entity_updateMovement(me, dt)

	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	
	if bone ~= 0 then
		if avatar_isBursting() and entity_setBoneLock(v.n, me, bone) then
		else
			local bx, by = bone_getWorldPosition(bone)
			local x, y = entity_getPosition(v.n)
			x = x - bx
			y = y - by
			x,y = vector_setLength(x, y, 2000)
			entity_clearVel(v.n)
			entity_addVel(v.n, x, y)
		end
	end
	
	v.fireDelay = v.fireDelay - dt
	if v.fireDelay <= 0 then
		v.fireDelay = v.maxFireDelay
		local s = createShot("creatorform6-hand", me, v.n)
		shot_setOut(s, 64)
		shot_setAimVector(s, 0, 800)
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
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

