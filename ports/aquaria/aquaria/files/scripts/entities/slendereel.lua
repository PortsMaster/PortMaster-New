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

-- ================================================================================================
-- EEL
-- ================================================================================================

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

v.dir = 0
v.switchDirDelay = 0
v.wiggleTime = 0
v.wiggleDir = 1
v.interestTimer = 0
v.colorRevertTimer = 0

v.collisionSegs = 50
v.avoidLerp = 0
v.avoidDir = 1
v.interest = false
-- initializes the entity
function init(me)
-- oldhealth : 40
	setupBasicEntity(
	me,
	"",						-- texture
	6,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	32,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1,							-- updateCull -1: disabled, default: 4000
	1
	)
	
	entity_setDropChance(me, 50)
	
	v.lungeDelay = 1.0				-- prevent the nautilus from attacking right away

	entity_initHair(me, 64, 4, 16, "SlenderEel")
	
	if chance(50) then
		v.dir = 0
	else
		v.dir = 1
	end
	
	if chance(50) then
		v.interest = true
	end
	v.switchDirDelay = math.random(800)/100.0
	v.naija = getNaija()
	
	entity_addVel(me, math.random(1000)-500, math.random(1000)-500)
	entity_setDeathParticleEffect(me, "Explode")
	entity_setUpdateCull(me, 2000)
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

-- the entity's main update function
function update(me, dt)


	if v.colorRevertTimer > 0 then
		v.colorRevertTimer = v.colorRevertTimer - dt
		if v.colorRevertTimer < 0 then
			entity_setColor(me, 1, 1, 1, 3)
		end
	end
	entity_handleShotCollisionsHair(me, v.collisionSegs)
	--entity_handleShotCollisions(me)
	--[[
	if entity_collideHairVsCircle(me, v.naija, v.collisionSegs) then
		entity_touchAvatarDamage(me, 0, 0, 500)
	end
	]]--
	-- in idle state only
	if entity_getState(me)==STATE_IDLE then
		-- count down the v.lungeDelay timer to 0
		if v.lungeDelay > 0 then v.lungeDelay = v.lungeDelay - dt if v.lungeDelay < 0 then v.lungeDelay = 0 end end
		
		-- if we don't have a target, find one
		if not entity_hasTarget(me) then
			entity_findTarget(me, 1000)
		else
			v.wiggleTime = v.wiggleTime + (dt*200)*v.wiggleDir
			if v.wiggleTime > 1000 then
				v.wiggleDir = -1	
			elseif v.wiggleTime < 0 then
				v.wiggleDir = 1
			end
			
			v.interestTimer = v.interestTimer - dt
			if v.interestTimer < 0 then
				if v.interest then
					v.interest = false
				else
					v.interest = true
					entity_addVel(me, math.random(1000)-500, math.random(1000)-500)
				end
				v.interestTimer = math.random(400.0)/100.0 + 2.0
			end
			if v.interest then
				if entity_isNearObstruction(getNaija(), 8) then
					v.interest = false
				else
					if entity_isTargetInRange(me, 1600) then
						if entity_isTargetInRange(me, 100) then
							entity_moveTowardsTarget(me, dt, -500)
						elseif not entity_isTargetInRange(me, 300) then
							entity_moveTowardsTarget(me, dt, 1000)
						end
						entity_moveAroundTarget(me, dt, 1000+v.wiggleTime, v.dir)
					end
				end
			else
				if entity_isTargetInRange(me, 1600) then
					entity_moveTowardsTarget(me, dt, -100)
				end
			end
			
			v.avoidLerp = v.avoidLerp + dt*v.avoidDir
			if v.avoidLerp >= 1 or v.avoidLerp <= 0 then
				v.avoidLerp = 0
				if v.avoidDir == -1 then
					v.avoidDir = 1
				else
					v.avoidDir = -1
				end
			end
			-- avoid other things nearby
			entity_doEntityAvoidance(me, dt, 32, 0.1)
--			entity_doSpellAvoidance(dt, 200, 1.5);
			entity_doCollisionAvoidance(me, dt, 10, 0.1)
			entity_doCollisionAvoidance(me, dt, 4, 0.8)
		end
	end
	entity_updateMovement(me, dt)	
	entity_setHairHeadPosition(me, entity_x(me), entity_y(me))
	entity_updateHair(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setMaxSpeed(me, 400)
	end
end

function exitState(me)
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
	entity_setMaxSpeed(me, 600)
	return true
end

function songNote(me, note)
	if getForm()~=FORM_NORMAL then
		return
	end
	
	v.interest = true
	local r,g,b = getNoteColor(note)
	entity_setColor(me, r,g,b,1)
	v.colorRevertTimer = 2 + math.random(300)/100.0
	--entity_setColor(me, 1,1,1,10)
end
