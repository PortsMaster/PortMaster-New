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
v.delay = 0
v.bone_eyes = 0
v.cr = 70

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "AbyssOctopus")	
	
	--entity_generateCollisionMask(me)	
	entity_setCollideRadius(me, v.cr)
	
	entity_setState(me, STATE_IDLE)
	
	local angle = 360
	if chance(50) then
		angle = -angle
	end
	entity_rotate(me, angle, 10, -1)
	
	bone_setSegs(entity_getBoneByName(me, "Tentacles-Front"), 2, 16, 0.6, 0.6, -0.03, 0, 6, 1)
	bone_setSegs(entity_getBoneByName(me, "Tentacles-Back"), 2, 16, 0.6, 0.6, -0.04, 0, 6, 1)
	
	entity_setHealth(me, 12)
	
	entity_setDeathScene(me, true)
	--entity_setDeathParticleEffect(me, "BigRedExplode")
	entity_setDamageTarget(me, DT_ENEMY_BEAM, false)
	v.bone_eyes = entity_getBoneByName(me, "Eyes")
	
	v.delay = -math.random(2)
	
	entity_setUpdateCull(me, 1024)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	entity_handleShotCollisions(me)
	--local bone = entity_collideSkeletalVsCircle(me, v.n)
	
	entity_updateMovement(me, dt)
	entity_moveTowardsTarget(me, dt, 100)
	entity_doEntityAvoidance(me, dt, 128, 1)
	entity_doCollisionAvoidance(me, dt, 8, 0.5)
	
	if entity_isState(me, STATE_IDLE) then
		if v.beam == 0 then
			v.delay = v.delay + dt
			if v.delay > 3 then
				v.delay = 0

				entity_setState(me, STATE_CHARGE1)
				entity_setUpdateCull(me, 3000)
				--entity_animate(me, "charge")
			end
		else		
			
			beam_setAngle(v.beam, entity_getRotation(me)-180)
			beam_setPosition(v.beam, entity_getPosition(me))
			v.delay = v.delay + dt
			if v.delay >= 3 then
				entity_setUpdateCull(me, 1024)
				v.delay = 0
				beam_delete(v.beam)
				v.beam = 0
				bone_setColor(v.bone_eyes, 1, 1, 1, 1)
			end
		end
	end
	
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0) then
		if avatar_isBursting() and entity_setBoneLock(v.n, me) then
		else
			local x, y = entity_getVectorToEntity(me, v.n, 800)
			entity_addVel(v.n, x, y)
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)		
	elseif entity_isState(me, STATE_DEATHSCENE) then
		spawnParticleEffect("BigRedExplode", entity_getPosition(me))
		entity_animate(me, "die")
		if v.beam ~= 0 then
			beam_delete(v.beam)
			v.beam = 0
		end	
		
		bone_setColor(v.bone_eyes, 0, 0, 0, 2)
	
		entity_rotate(me, entity_getRotation(me), 1)
		entity_setPosition(me, entity_x(me), entity_y(me)+1024, 4, 0, 0, 1)
		entity_setWeight(me, 200)		
		entity_setStateTime(me, 2)
		entity_scale(me, 0.3, 0.6, 4)
	elseif entity_isState(me, STATE_DEAD) then
	elseif entity_isState(me, STATE_CHARGE1) then
		bone_setColor(v.bone_eyes, 1, 0, 0, 1)
		entity_stopInterpolating(me)
		--bone_setColor(v.bone_eyes, 1, 0, 0, 1)
		entity_animate(me, "charge")
		entity_setStateTime(me, 0.5)
		entity_sound(me, "EnergyOrbCharge")
		---playSfx("EnergyOrbCharge")
	end
end

function exitState(me)
	if entity_isState(me, STATE_CHARGE1) then
		entity_sound(me, "PowerUp")
		entity_sound(me, "FizzleBarrier")
		v.beam = createBeam(0, 0, entity_getRotation(me)-180)
		beam_setTexture(v.beam, "particles/Beam")
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_DEATHSCENE) then
		entity_scale(me, 0.1, 0.1)
		spawnParticleEffect("BigRedExplode", entity_getPosition(me))
	end
end

function damage(me, attacker, bone, damageType, dmg)
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

