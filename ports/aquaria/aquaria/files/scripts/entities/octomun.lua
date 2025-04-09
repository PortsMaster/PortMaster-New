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
v.body = 0
v.weakPoint = 0
v.marker1 = 0
v.marker2 = 0
v.attackDelay = 0
v.attack1Marker = 0
v.grabbingEntity = 0
v.dark = 0
v.inkBlastDelay = 0

local STATE_ATTACK1 = 1001
local STATE_BASH = 1002

v.fireDelay = 0

v.shot1 = 0
v.shot2 = 0
v.shot3 = 0

v.fireOff = 1

v.isWeakPointHittable = false

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "Octomun")	
	v.body = entity_getBoneByName(me, "Body")
	v.weakPoint = entity_getBoneByName(me, "WeakPoint")
	v.marker1 = entity_getBoneByName(me, "Marker1")
	v.marker2 = entity_getBoneByName(me, "Marker2")
	v.attack1Marker = entity_getBoneByName(me, "Attack1Marker")
	
	bone_alpha(v.attack1Marker, 0)
	
	v.shot1 = entity_getBoneByName(me, "Shot1")
	v.shot2 = entity_getBoneByName(me, "Shot2")
	v.shot3 = entity_getBoneByName(me, "Shot3")
	
	--entity_setAllDamageTargets(me, false)
	
	entity_generateCollisionMask(me)
	
	entity_setAllDamageTargets(me, false)
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
	
	entity_setCullRadius(me, 1024)
	entity_setState(me, STATE_IDLE)
	entity_setTargetRange(me, 512)
	
	v.dark = createQuad("Octomun/Dark", 13)
	quad_scale(v.dark, 64, 64)
	quad_alpha(v.dark, 0)
	
	entity_setUpdateCull(me, 4064)
	
	loadSound("Octomun-Growl")
	loadSound("Octomun-Hit")
	loadSound("Octomun-Shot")
	loadSound("Octomun-Ink")
	
	loadSound("BossDieSmall")
	loadSound("BossDieBig")
	
	loadSound("rotcore-birth")
	
	entity_setTargetRange(me, 1024)
	
	entity_setHealth(me, 30)
	
	entity_setDeathScene(me, true)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

local function tentacle1Collision(me)
	if v.grabbingEntity ~= 0 then
		return
	end
	local x1, y1 = bone_getWorldPosition(v.marker2)
	local x2, y2 = bone_getWorldPosition(v.marker1)
	
	if entity_isPositionInRange(v.n, x2, y2, 96) then
		v.grabbingEntity = v.n
		avatar_fallOffWall()
		entity_idle(v.grabbingEntity)
		entity_animate(v.grabbingEntity, "trapped", LOOP_INF, LAYER_OVERRIDE)		
	elseif entity_collideCircleVsLine(v.n, x1, y1, x2, y2, 32) then
		entity_damage(v.n, me, 1)
	end
end

v.seen = 0

v.fired = 0

v.started = false

function update(me, dt)
	quad_setPosition(v.dark, entity_getPosition(me))
	overrideZoom(0.6, 0.5)
	entity_handleShotCollisionsSkeletal(me)
	entity_clearTargetPoints(me)
	local bx, by = bone_getWorldPosition(v.weakPoint)
	entity_addTargetPoint(me, bx, by)
	
	if v.seen == 0 and entity_isEntityInRange(me, v.n, 1000) then
		playSfx("Octomun-Growl")
		v.seen = 1
	end
	
	if v.seen < 2 and entity_isEntityInRange(me, v.n, 800) then
		emote(EMOTE_NAIJAUGH)
		playMusic("MiniBoss")
		v.started = true
		v.seen = 2
	end
	
	if not v.started then return end
	
	if quad_getAlpha(v.dark) < 0.1 then
		v.inkBlastDelay = v.inkBlastDelay + dt
		if v.inkBlastDelay > 20 then
			playSfx("Octomun-Ink")
			spawnParticleEffect("InkBlast", entity_getPosition(me))
			quad_alpha(v.dark, 1, 4)
			v.inkBlastDelay = math.random(5)
		end
	end
	if entity_isState(me, STATE_IDLE) then
		v.attackDelay = v.attackDelay + dt
		if v.attackDelay > 1 then
			if v.grabbingEntity~=0 then
				entity_setState(me, STATE_BASH)
			else
				local x, y = bone_getWorldPosition(v.attack1Marker)
				if entity_x(v.n) < x and entity_y(v.n) > y and entity_x(v.n) > entity_x(me) then
					entity_setState(me, STATE_ATTACK1)
				end
			end
		--[[
			local bx, by = bone_getWorldPosition(v.marker1)
			if entity_isPositionInRange(v.n, bx, by, 128) then
				entity_setState(me, STATE_ATTACK1)
			end
			]]--
		end
		v.fireDelay = v.fireDelay + dt
		if v.fireDelay > 6 and v.fired == 0 then
			playSfx("Octomun-Shot")
			local s = createShot("Octomun", me, v.n, bone_getWorldPosition(v.shot1))
			shot_setAimVector(s, 100, -100)
			v.fired = 1
		elseif v.fireDelay > 6.5 and v.fired == 1 then
			playSfx("Octomun-Shot")
			local s = createShot("Octomun", me, v.n, bone_getWorldPosition(v.shot2))
			shot_setAimVector(s, 100, -50)
			v.fired = 2
		elseif v.fireDelay > 7 and v.fired == 2 then
			playSfx("Octomun-Shot")
			local s = createShot("Octomun", me, v.n, bone_getWorldPosition(v.shot3))
			shot_setAimVector(s, 100, 0)
			v.fired = 3
			--[[
			entity_fireAtTarget(me, "Purple", 1, 500, 200, 0, 0, 0, 0, 100, -100, bx, by)
			entity_fireAtTarget(me, "Purple", 1, 500, 200, 0, 0, 0, 0, 100, -50, bx, by)
			entity_fireAtTarget(me, "Purple", 1, 500, 200, 0, 0, 0, 0, 100, 0, bx, by)
			]]--
			
		elseif v.fireDelay > 9 and v.fired == 3 then
			v.fired = 0
			
			if v.fireOff == 1 then
				playSfx("rotcore-birth")
				
				bx, by = bone_getWorldPosition(v.shot1)
				
				local e = createEntity("Squiddy", "", bx, by)
				entity_alpha(e, 0.001)
				entity_alpha(e, 1, 0.5)
				
				spawnParticleEffect("tinyredexplode", bx, by)
				v.fireOff = 0
			else
				v.fireOff = 1
			end
			
			v.fireDelay = math.random(2)*0.75 + 0.5
		end
	elseif entity_isState(me, STATE_ATTACK1) then
		tentacle1Collision(me)
	end
	
	if v.grabbingEntity~=0 then
		local mx, my = bone_getWorldPosition(v.marker1)		
		entity_setPosition(v.grabbingEntity, mx, my)
		entity_rotate(v.grabbingEntity, bone_getRotation(v.marker1))
		if entity_isfh(v.grabbingEntity) then
			entity_fh(v.grabbingEntity)
		end
	end
	
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then
		entity_damage(v.n, me, 1)
		entity_pushTarget(me, 500)
	end
	entity_updateMovement(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		v.isWeakPointHittable = false
		entity_animate(me, "idle", -1)
		v.attackDelay = 0
	elseif entity_isState(me, STATE_ATTACK1) then
		playSfx("Octomun-Growl")
		local num = entity_animate(me, "attack1")
		entity_setStateTime(me, num)		
	elseif entity_isState(me, STATE_BASH) then
		entity_setStateTime(me, entity_animate(me, "bash",1))
		if v.grabbingEntity ~= 0 then
			--entity_push(v.grabbingEntity, 10, 0, 1)
		end
	elseif entity_isState(me, STATE_DEAD) then
		quad_delete(v.dark)
	elseif entity_isState(me, STATE_DEATHSCENE) then
		setFlag(FLAG_MINIBOSS_OCTOMUN, 1)
		clearShots()
		entity_stopInterpolating(me)
		entity_setStateTime(me, 99)
		fadeOutMusic(6)
		entity_idle(v.n)
		entity_setInvincible(v.n, true)
		cam_toEntity(me)
		entity_setInternalOffset(me, 0, 0)
		entity_setInternalOffset(me, 10, 0, 0.1, -1, 1)
		watch(1)
		playSfx("BossDieSmall")
		fade(1, 0.2, 1, 1, 1)
		watch(0.2)
		fade(0, 0.5, 1, 1, 1)
		watch(0.5)
		watch(1)
		playSfx("BossDieSmall")
		fade(1, 0.2, 1, 1, 1)
		watch(0.2)
		fade(0, 0.5, 1, 1, 1)
		watch(0.5)
		playSfx("BossDieSmall")
		fade(1, 0.2, 1, 1, 1)
		watch(0.2)
		fade(0, 0.5, 1, 1, 1)
		watch(0.5)
		entity_setInternalOffset(me, 0, 0)
		entity_setInternalOffset(me, 20, 0, 0.05, -1, 1)
		playSfx("BossDieBig")
		fade(1, 1, 1, 1, 1)
		watch(1.2)
		fade(0, 0.5, 1, 1, 1)
		
		cam_toEntity(v.n)
		entity_setInvincible(v.n, false)
		pickupGem("Boss-Octomun")
		overrideZoom(0, 1)
		entity_setStateTime(me, 0.1)
		entity_setState(me, STATE_DEAD, -1, 1)
	end
end

function exitState(me)
	if entity_isState(me, STATE_ATTACK1) then
		v.isWeakPointHittable = false
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_BASH) then
		if v.grabbingEntity ~= 0 then
			entity_idle(v.grabbingEntity)
			entity_push(v.grabbingEntity, 1000, 0, 1)
		end
		v.grabbingEntity = 0
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if bone == v.weakPoint and v.isWeakPointHittable then
		bone_damageFlash(v.body)
		playSfx("Octomun-Hit")
		v.fireDelay = v.fireDelay - dmg * 0.2
		return true
	else
		playNoEffect()
	end
	return false
end

function animationKey(me, key)
	if entity_isState(me, STATE_BASH) and key == 4 then
		entity_damage(v.n, me, 0.75)
	elseif entity_isState(me, STATE_ATTACK1) then
		if key == 1 then
			v.isWeakPointHittable = true
		end
		if key == 5 then
			v.isWeakPointHittable = false
		end
		if key == 4 then
			playSfx("rockhit-big")
			shakeCamera(10, 0.8)
		end
	end
end

function lightFlare(me)
	if entity_isEntityInRange(me, v.n, 1024) then
		quad_alpha(v.dark, 0, 2)
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

