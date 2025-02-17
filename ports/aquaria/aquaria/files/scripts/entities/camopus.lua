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

v.head = 0
v.tback = 0
v.tfront = 0


local STATE_APPEAR			= 1000
local STATE_HIDDEN			= 1001
local STATE_HIDE			= 1002

v.inout	= 0
v.dir 	= 1
v.spawn = false

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "camopus")
	
	entity_setAllDamageTargets(me, false)
	
	v.head = entity_getBoneByName(me, "head")
	v.tfront = entity_getBoneByName(me, "tfront")
	v.tback = entity_getBoneByName(me, "tback")
	
	bone_setSegs(v.head, 2, 8, 0.8, 0.8, -0.018, 0, 6, 1)
	bone_setSegs(v.tfront, 2, 8, 0.8, 0.8, -0.018, 0, 6, 1)
	bone_setSegs(v.tback, 2, 8, -0.8, -0.8, -0.018, 0, 6, 1)
	
	entity_setCollideRadius(me, 32)
	
	entity_animate(me, "idle", -1)
	
	entity_setState(me, STATE_HIDDEN)
	
	entity_setUpdateCull(me, 3000)
	
	entity_setMaxSpeed(me, 800)
	
	entity_setHealth(me, 20)
	
	entity_setEatType(me, EAT_FILE, "Ink")
	
	entity_setDeathParticleEffect(me, "explode")
	
	entity_setCullRadius(me, 300)
	
	loadSound("camopus-roar")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	if entity_isState(me, STATE_HIDDEN)
	and not isForm(FORM_FISH) then
		if entity_isEntityInRange(me, v.n, 180) then
			entity_setState(me, STATE_APPEAR)
		end
	end
	
	if entity_isState(me, STATE_IDLE) then
		v.inout = v.inout + dt*v.dir
		if not v.spawn and v.inout > 0.2 then
			spawnParticleEffect("bubble-release", entity_x(me), entity_y(me))
			v.spawn = true
		end
		if v.inout > 1 then
			v.dir = -1
			v.inout = 1
			spawnParticleEffect("bubble-release", entity_x(me), entity_y(me))
		elseif v.inout < 0 then
			v.dir = 1
			v.inout = 0
			v.spawn = false
			
			if entity_isEntityInRange(me, v.n, 1000) then
				local s = createShot("camopus-ink", me, v.n, entity_x(me), entity_y(me))
				shot_setAimVector(s, entity_x(v.n) - entity_x(me), entity_y(v.n) - entity_y(me))
			end
			
		end
		
		bone_scale(v.tfront, 0.2*(1-v.inout)+0.8, 0.9 + v.inout*0.1)
		bone_scale(v.tback, 0.2*v.inout+0.8, 1)
		
		bone_scale(v.head, 0.9 + 0.1 * (1-v.inout), 0.2*v.inout + 0.8)
		
		entity_setMaxSpeedLerp(me, v.inout*2 + 0.4)
		
		
		
		entity_moveTowardsTarget(me, dt, -400)
		entity_doCollisionAvoidance(me, dt, 10, 0.2)
		entity_doEntityAvoidance(me, dt, 64, 0.1)
		if not entity_isEntityInRange(me, v.n, 1224) then
			entity_setState(me, STATE_HIDE) 
		end
		
		entity_rotateToVel(me, 0.4)
	end
	
	entity_updateMovement(me, dt)

	entity_handleShotCollisions(me)
	
	entity_touchAvatarDamage(me, 48, 0, 500)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_moveTowardsTarget(me, 1, -800)
		entity_setAllDamageTargets(me, true)
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_APPEAR) then
		spawnParticleEffect("bubble-release", entity_x(me), entity_y(me))
		playSfx("camopus-roar")
		entity_setStateTime(me, 0.3)
		entity_alpha(me, 1, 0.5)
	elseif entity_isState(me, STATE_HIDDEN) then
		entity_setAllDamageTargets(me, false)
		entity_alpha(me, 0.05)
	elseif entity_isState(me, STATE_HIDE) then
		entity_clearVel(me)
		entity_rotate(me, 0, 1, 0, 0, 1)
		entity_alpha(me, 0.05, 3)
		entity_setStateTime(me, 3)
		bone_scale(v.head, 1, 1, 1)
		bone_scale(v.tfront, 1, 1, 1)
		bone_scale(v.tback, 1, 1, 1)
	end
end

function exitState(me)
	if entity_isState(me, STATE_APPEAR) then
		emote(EMOTE_NAIJAUGH)
		entity_setState(me, STATE_IDLE, -1)
	elseif entity_isState(me, STATE_HIDE) then
		entity_setState(me, STATE_HIDDEN)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_isState(me, STATE_HIDDEN) then
		v.inout = 0.5
		v.dir = -1
		entity_setState(me, STATE_APPEAR)
	end
	if entity_isState(me, STATE_IDLE) then
		return true
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

function dieNormal(me)
	playSfx("camopus-roar")
	cam_toEntity(me)
	
	entity_idle(v.n)
	watch(0.5)
	
	shakeCamera(2, 3)
	spawnIngredient("RubberyMeat", entity_x(me), entity_y(me))
	spawnIngredient("RubberyMeat", entity_x(me), entity_y(me))
	spawnIngredient("RubberyMeat", entity_x(me), entity_y(me))
	spawnIngredient("RubberyMeat", entity_x(me), entity_y(me))
	if chance(90) then spawnIngredient("SmallTentacle", entity_x(me), entity_y(me)) end
	watch(1)
	cam_toEntity(v.n)
end

