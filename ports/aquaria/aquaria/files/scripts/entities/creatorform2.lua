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

local STATE_START		= 1000
local STATE_GRABATTACK	= 1001
local STATE_HOLDING		= 1002
local STATE_INHAND		= 1003
local STATE_BEAM		= 1004

v.bone_head			= 0
v.bone_body			= 0
v.grabPoint 			= 0
v.inHand				= false
v.breakFreeTimer		= 0
v.grabDelay			= 3
v.hits 				= 200 * 1.3

v.grabRange			= 0

v.shotDelay			= 0
v.shotDelayTime		= 0

v.prepDelay			= 8

v.beam = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "CreatorForm2")	
	--entity_setAllDamageTargets(me, false)
	
	entity_generateCollisionMask(me)
	
	entity_setState(me, STATE_IDLE)
	
	v.grabPoint = entity_getBoneByName(me, "Hand")
	v.bone_head = entity_getBoneByName(me, "Head")
	v.bone_body = entity_getBoneByName(me, "Body")
	v.grabRange = entity_getBoneByName(me, "GrabRange")
	
	entity_setMaxSpeed(me, 800)
	
	entity_setDamageTarget(me, DT_ENEMY_BEAM, false)
	
	entity_setCull(me, false)
	
	playMusic("Worship2")
	
	loadSound("creatorform2-shot")
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	--debugLog(string.format("hits %d", hits))
	if entity_isState(me, STATE_TRANSITION) or entity_isState(me, STATE_WAIT) then
		return
	end
	entity_doFriction(me, dt, 800)
	entity_doCollisionAvoidance(me, dt, 15, 0.5)
	entity_updateMovement(me, dt)


	if v.grabDelay > 0 then
		v.grabDelay = v.grabDelay - dt
		if v.grabDelay < 0 then
			v.grabDelay = 0
		end
	end
	
	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	
	if bone ~= 0 then
		if not v.inHand and v.grabDelay == 0 and bone == v.grabPoint then
			v.inHand = true
			avatar_fallOffWall()
		end
		if not v.inHand and avatar_isBursting() and bone == v.bone_body and entity_setBoneLock(v.n, me, bone) then
		else
			local bx, by = bone_getWorldPosition(bone)
			local x, y = entity_getPosition(v.n)
			bx = x - bx
			by = y - by
			bx, by = vector_setLength(bx, by, 800)
			entity_addVel(v.n, bx, by)
		end
		if bone == v.grabPoint then
			entity_damage(v.n, me, 0.5)
		end
	end
	
	if v.inHand then
		entity_setPosition(v.n, bone_getWorldPosition(v.grabPoint))
		entity_rotate(v.n, bone_getWorldRotation(v.grabPoint)-90)
		
		if avatar_isRolling() then
			v.breakFreeTimer = v.breakFreeTimer + dt
			if v.breakFreeTimer > 2 then
				v.inHand = false
				v.breakFreeTimer = 0
				v.grabDelay = 4
				local x, y = entity_x(v.n), entity_y(v.n)
				if isObstructed(x, y) then
					-- Trapped in the floor!  Warp out.
					while y > 4500 and isObstructed(x, y) do
						y = y-20
					end
					entity_setPosition(v.n, x, y)
				end
			end
		end
	end
	
	if not v.inHand and math.abs(entity_x(me) - entity_x(v.n)) > 256 then
		entity_flipToEntity(me, v.n)
	end
	
	entity_clearTargetPoints(me)
	entity_addTargetPoint(me, bone_getWorldPosition(v.bone_head))
	
	if entity_isState(me, STATE_IDLE) then
		v.prepDelay = v.prepDelay - dt
		if v.prepDelay < 0 then
			local bx, by = bone_getWorldPosition(v.grabRange)
			if (entity_getBoneLockEntity(v.n) == me) or (entity_isPositionInRange(v.n, bx, by, 512) and chance(30)) then
				entity_setState(me, STATE_GRABATTACK)
			else
				if chance(50) then
					entity_setState(me, STATE_PREP)
				elseif chance(50) then
					entity_setState(me, STATE_BEAM)
				end
			end
		end
	end
	
	if entity_isState(me, STATE_ATTACK) then
		v.shotDelay = v.shotDelay - dt
		if v.shotDelay <= 0 then
			local s = createShot("CreatorForm2", me, v.n, bone_getWorldPosition(v.bone_head))
			v.shotDelayTime = v.shotDelayTime - 0.01
			v.shotDelay = v.shotDelayTime
		end
	end
	
	if entity_isState(me, STATE_BEAM) then
		if v.beam ~= 0 then
			if entity_isfh(me) then
				beam_setAngle(v.beam, bone_getWorldRotation(v.bone_head)+90)
			else
				beam_setAngle(v.beam, bone_getWorldRotation(v.bone_head)-90)
			end
			beam_setPosition(v.beam, bone_getWorldPosition(v.bone_head))
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "start", -1)
	elseif entity_isState(me, STATE_START) then
		entity_setStateTime(me, entity_animate(me, "start", 2))
	elseif entity_isState(me, STATE_TRANSITION) then
		v.inHand = false
		clearShots()
		entity_setAllDamageTargets(me, false)
		
		entity_idle(v.n)
		disableInput()
		entity_setInvincible(v.n, true)
		cam_toEntity(me)
		
		local node = entity_getNearestNode(me, "CENTER")
		entity_setPosition(me, node_x(node), node_y(node), 3, 0, 0, 1)	
		
		local t = entity_animate(me, "die")
		entity_setStateTime(me, t + 2)
		
		local node = getNode("HASTYEXIT")
		local door = node_getNearestEntity(node, "FinalDoor")
		entity_setState(door, STATE_OPEN)
	elseif entity_isState(me, STATE_PREP) then
		entity_setStateTime(me, entity_animate(me, "prep"))
	elseif entity_isState(me, STATE_ATTACK) then
		entity_animate(me, "attack", -1)
		entity_setStateTime(me, 6)
		v.shotDelayTime = 1
	elseif entity_isState(me, STATE_GRABATTACK) then
		entity_setStateTime(me, entity_animate(me, "grabAttack"))
		shakeCamera(10, 1)
		avatar_fallOffWall()
	elseif entity_isState(me, STATE_BEAM) then
		entity_setStateTime(me, entity_animate(me, "beam"))
		shakeCamera(10, 3)
		avatar_fallOffWall()
		v.beam = 0
		voice("Laugh3")
	end
end

function exitState(me)
	if entity_isState(me, STATE_START) then
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_TRANSITION) then
		local bx, by = bone_getWorldPosition(v.bone_head)
		createEntity("CreatorForm4", "", bx, by)
		entity_setState(me, STATE_WAIT, 2)
	elseif entity_isState(me, STATE_WAIT) then
		entity_delete(me)
		enableInput()
		entity_setInvincible(v.n, false)
		cam_toEntity(v.n)
	elseif entity_isState(me, STATE_PREP) then
		entity_setState(me, STATE_ATTACK)
	elseif entity_isState(me, STATE_ATTACK) or entity_isState(me, STATE_GRABATTACK) or entity_isState(me, STATE_BEAM) then
		if v.beam ~= 0 then
			beam_delete(v.beam)
			v.beam = 0
		end
		v.prepDelay = math.random(3)+4
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if bone == v.bone_head then
		bone_damageFlash(bone)
		v.hits = v.hits - dmg
		if v.hits <= 0 then
			entity_setState(me, STATE_TRANSITION)
		end
		return false
	end
	return false
end

function animationKey(me, key)
	if entity_isState(me, STATE_IDLE) and (key == 2 or key == 3) then
		entity_moveTowards(me, entity_x(v.n), entity_y(v.n), 1, 1000)
	elseif entity_isState(me, STATE_BEAM) and key == 1 then
		v.beam = createBeam()
		beam_setTexture(v.beam, "particles/Beam")
		beam_setDamage(v.beam, 3)
		playSfx("PowerUp")
		playSfx("FizzleBarrier")
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

