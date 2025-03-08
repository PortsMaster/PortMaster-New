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
v.attackDelay = 2

local STATE_GETREADY			= 1000
local STATE_FIRING				= 1001

v.body = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "Guardian")	
	
	entity_generateCollisionMask(me)	
	
	entity_setHealth(me, 64)
	entity_setDeathScene(me, true)
	entity_setState(me, STATE_WAIT)
	entity_setCullRadius(me, 2000)
	entity_scale(me, 2, 2)
	entity_setDeathScene(me, true)
	
	v.body = entity_getBoneByName(me, "Body")
	
	entity_setTargetRange(me, 2024)
	
	entity_setUpdateCull(me, 3000)
	
	loadSound("Guardian-Die")
	loadSound("Guardian-Attack")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	local node = entity_getNearestNode(me, "FLIP")
	if node ~= 0 and node_isEntityIn(node, me) then
		entity_fh(me)
	end
end

function update(me, dt)
	--entity_updateMovement(me, dt)
	
	if entity_isState(me, STATE_WAIT) then
		if entity_isEntityInRange(me, v.n, 600) then
			entity_setState(me, STATE_GETREADY)
		end
	end
	
	if entity_isState(me, STATE_IDLE) then
		v.attackDelay = v.attackDelay - dt
		if v.attackDelay <= 0 then
			if not entity_isEntityInRange(me, v.n, 1024) or chance(10) then
				entity_setState(me, STATE_FIRING)
			else
				entity_setState(me, STATE_ATTACK)
			end
		end
		
	end
	
	if not entity_isState(me, STATE_WAIT) then
		overrideZoom(0.6, 1)
	end
	
	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then
		if entity_isfh(me) then
			entity_addVel(v.n, 2000, 0)
		else
			entity_addVel(v.n, -2000, 0)
		end
		entity_damage(v.n, me, 1)
	end
	
	if entity_isfh(me) then
		if entity_x(v.n) > entity_x(me) then
			entity_addVel(v.n, 1000, 0)
		end
	else
		if entity_x(v.n) > entity_x(me) then
			entity_addVel(v.n, -1000, 0)
		end
	end
	entity_clearTargetPoints(me)
	entity_addTargetPoint(me, bone_getWorldPosition(v.body))
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "ready", -1)
	elseif entity_isState(me, STATE_WAIT) then
		entity_animate(me, "wait", -1)
	elseif entity_isState(me, STATE_GETREADY) then
		entity_setStateTime(me, entity_animate(me, "getReady"))
	elseif entity_isState(me, STATE_ATTACK) then
		playSfx("Guardian-Attack")
		if entity_y(v.n) < entity_y(me) then
			entity_setStateTime(me, entity_animate(me, "attack"))
		else
			entity_setStateTime(me, entity_animate(me, "attack2"))
		end
	elseif entity_isState(me, STATE_DEATHSCENE) then
		playSfx("Guardian-Die")
		shakeCamera(4, 4)
		overrideZoom(0.5, 0.5)
		entity_setStateTime(me, 99)
		cam_toEntity(me)
		entity_setInvincible(v.n, true)
		watch(entity_animate(me, "die"))
		entity_color(me, 0, 0, 0, 1)
		watch(1)
		entity_setStateTime(me, 0.01)
		entity_setInvincible(v.n, false)
		cam_toEntity(v.n)
	elseif entity_isState(me, STATE_FIRING) then
		entity_setStateTime(me, entity_animate(me, "firing"))
	end
end

function exitState(me)
	if entity_isState(me, STATE_ATTACK) then
		v.attackDelay = 3
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_GETREADY) then
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_DEATHSCENE) then
		overrideZoom(0, 0.5)
	elseif entity_isState(me, STATE_FIRING) then
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_isState(me, STATE_WAIT) then
		entity_setState(me, STATE_GETREADY)
		return false
	end
	if bone == v.body then
		return true
	end

	return false
end

function animationKey(me, key)
	if entity_isState(me, STATE_FIRING) then
		if key == 2 or key == 4 or key == 6 then
			local s = createShot("Guardian", me, v.n, entity_getPosition(me))
			if key == 2 then
				shot_setAimVector(s, -400, -100)
			elseif key == 4 then
				shot_setAimVector(s, -400, 0)
			elseif key == 6 then
				shot_setAimVector(s, -400, 100)
			end
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

