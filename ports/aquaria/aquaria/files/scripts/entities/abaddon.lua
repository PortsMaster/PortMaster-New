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
v.bone_tentacles = 0
v.fireDelay = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "Abaddon")	
	--entity_setAllDamageTargets(me, true)
	
	entity_generateCollisionMask(me)	
		
	v.bone_tentacles = entity_getBoneByName(me, "Tentacles")	
	
	entity_setDeathParticleEffect(me, "BigRedExplode")
	entity_setDeathScene(me, true)
	
	entity_setHealth(me, 24)
	entity_setState(me, STATE_IDLE)
	entity_setCullRadius(me, 512)
	
	entity_setUpdateCull(me, 3000)
	
	entity_setDropChance(me, 100, 1)
	
	entity_setDamageTarget(me, DT_ENEMY_BEAM, false)
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then
		entity_touchAvatarDamage(me, 0, 1, 400)
	end
	
	v.fireDelay = v.fireDelay + dt
	if v.fireDelay > 4 then
		v.fireDelay = 0
		local radius = 64
		local maxa = 3.14 * 2
		local off = bone_getRotation(v.bone_tentacles)
		local a = off
		while a < maxa+off do
			local s = createShot("Abaddon", me)
			shot_setAimVector(s, math.sin(a), math.cos(a))		
			shot_setOut(s, radius)
			a = a + (3.14*2)/8.0
		end
	end
	entity_updateMovement(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		bone_rotate(v.bone_tentacles, 360, 10, -1)
	elseif entity_isState(me, STATE_DEATHSCENE) then
		local t = 2
		entity_offset(me, 10, 0, 0.05, -1, 1)
		entity_setStateTime(me, t)
		entity_scale(me, 0.2, 0.2, t, 0, 1)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if bone == v.bone_tentacles then
		return false
	end
	return true
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

