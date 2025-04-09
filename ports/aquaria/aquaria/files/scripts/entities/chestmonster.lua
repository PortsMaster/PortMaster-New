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


v.maxHits = 3
v.hits = v.maxHits

v.head = 0

v.beam = 0

v.hit = false

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "chestmonster")
	
	entity_generateCollisionMask(me)
	
	entity_setState(me, STATE_IDLE)
	
	v.head = entity_getBoneByName(me, "head")
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	entity_setDamageTarget(me, DT_ENEMY, false)
	entity_setDamageTarget(me, DT_ENEMY_ENERGYBLAST, false)
	entity_setDamageTarget(me, DT_ENEMY_BEAM, false)
	
	entity_scale(me, 3, 3)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	
	entity_handleShotCollisionsSkeletal(me)
	
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then
		entity_setPosition(v.n, entity_x(v.n)-20, entity_y(v.n))
		entity_addVel(v.n, -1000, 0)
		entity_damage(v.n, me, 1)
	end
	
	if v.beam ~= 0 then
		beam_setPosition(v.beam, entity_x(me), entity_y(me))
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_OPEN) then
		setSceneColor(0.4, 0.4, 1, 1)
		entity_setStateTime(me, entity_animate(me, "open"))
	elseif entity_isState(me, STATE_OPENED) then
		playSfx("PowerUp")
		playSfx("FizzleBarrier")
		v.beam = createBeam(0, 0, entity_getRotation(me)-90, 1)
		beam_setTexture(v.beam, "creator/form6/beam")
		beam_setBeamWidth(v.beam, 256)
		beam_setDamage(v.beam, 3)
	elseif entity_isState(me, STATE_CLOSE) then
		entity_setStateTime(me, entity_animate(me, "close"))
		beam_delete(v.beam)
		v.beam = 0
		
	elseif entity_isState(me, STATE_CLOSED) then
		if v.hit then
			local e1 = createEntity("mutilus", "", entity_x(me)-64, entity_y(me)-32)
			local e2 = createEntity("mutilus", "", entity_x(me)-64-10, entity_y(me))
			local e3 = createEntity("mutilus", "", entity_x(me)-64, entity_y(me)+32)
			spawnParticleEffect("tinyredexplode", entity_x(e1), entity_y(e1))
			spawnParticleEffect("tinyredexplode", entity_x(e2), entity_y(e2))
			spawnParticleEffect("tinyredexplode", entity_x(e3), entity_y(e3))
		end
		v.hit = false
		entity_setStateTime(me, 1)
		setSceneColor(1, 1, 1, 2)
	end
end

function exitState(me)
	if entity_isState(me, STATE_OPEN) then
		entity_setState(me, STATE_OPENED, 4)
	elseif entity_isState(me, STATE_OPENED) then
		entity_setState(me, STATE_CLOSE)
	elseif entity_isState(me, STATE_CLOSE) then
		entity_setState(me, STATE_CLOSED)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_isState(me, STATE_OPEN) and bone == v.head then
		if not v.hit then
			v.hit = true
			playSfx("creatorform6-die3")

			bone_damageFlash(entity_getBoneByIdx(me, 0))
			bone_damageFlash(entity_getBoneByIdx(me, 1))
			bone_damageFlash(entity_getBoneByIdx(me, 2))
		end
	else
		playNoEffect()
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

