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
-- ELECTRIC EEL
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

v.songTimer = 0

v.spawns = 0

v.shockDelay = 6
local STATE_SHOCK		= 1000

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
	-1							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setDropChance(me, 50)
	
	v.lungeDelay = 1.0				-- prevent the nautilus from attacking right away

	entity_initHair(me, 80, 4, 32, "eel-0002")
	--[[
	entity_initSegments(
	25,								-- num segments
	2,								-- minDist
	12,								-- maxDist
	"wurm-body",						-- body tex
	"wurm-tail",						-- tail tex
	128,								-- width
	128,								-- height
	0.01,							-- taper
	0								-- reverse segment direction
	)
	]]--
	
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
	--entity_setDeathParticleEffect(me, "Explode")
	entity_setDeathScene(me, true)
	
	v.spawns = 1 + math.random(2)
	
	entity_setCanLeaveWater(me, 1)
end

-- the entity's main update function
function update(me, dt)

	if v.shockDelay > 0 then
		entity_setState(me, STATE_IDLE)
	end

	if v.songTimer > 0 then
		v.songTimer = v.songTimer - dt*0.4
		--debugLog(string.format("songTimer: %f", songTimer))
	end
	
	if v.songTimer > 6 then
		v.songTimer = 3
		if v.spawns > 0 then
			playSfx("secret")
			spawnIngredient("EelOil", entity_x(me), entity_y(me))
			v.spawns = v.spawns - 1
		end
	end

	if v.colorRevertTimer > 0 then
		v.colorRevertTimer = v.colorRevertTimer - dt
		if v.colorRevertTimer < 0 then
			entity_setColor(me, 1, 1, 1, 3)
		end
	end
	entity_handleShotCollisionsHair(me, v.collisionSegs)
	--entity_handleShotCollisions(me)
	if entity_collideHairVsCircle(me, v.naija, v.collisionSegs) then
		entity_touchAvatarDamage(me, 0, 0, 500)
	end
	-- in idle state only
	if entity_getState(me)==STATE_IDLE or entity_getState(me)==STATE_SHOCK then
		-- count down the lungeDelay timer to 0
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
							entity_moveTowardsTarget(me, dt, -500)		-- if we're too close, move away
						elseif not entity_isTargetInRange(me, 300) then
							entity_moveTowardsTarget(me, dt, 1000)		-- move in if we're too far away
						end
						entity_moveAroundTarget(me, dt, 1000+v.wiggleTime, v.dir)
					end
				end
			else
				if entity_isTargetInRange(me, 1600) then
					entity_moveTowardsTarget(me, dt, -100)		-- if we're too close, move away
				end
			end
			
			--[[
			v.switchDirDelay = v.switchDirDelay - dt
			if v.switchDirDelay < 0 then
				v.switchDirDelay = math.random(800)/100.0
				if v.dir == 0 then
					v.dir = 1
				else
					v.dir = 0
				end
			end
			]]--
			
			--[[
			-- 40% of the time when we're in range and not delaying, launch an attack
			if entity_isTargetInRange(me, 300) then
				if math.random(100) < 40 and v.lungeDelay == 0 then
					entity_setState(me, STATE_ATTACKPREP, 0.5)
				end
			end
			]]--
			
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
			entity_doCollisionAvoidance(me, dt, 10, 0.5)
			entity_doCollisionAvoidance(me, dt, 4, 0.8)
		end
	end
	entity_updateMovement(me, dt)	
	entity_setHairHeadPosition(me, entity_x(me), entity_y(me))
	entity_updateHair(me, dt)
	
	
	if entity_checkSplash(me) then
		if not entity_isUnderWater(me) then
			entity_setMaxSpeedLerp(me, 2)
			
			if entity_velx(me) < 0 then
				entity_addVel(me, -200, -500)
			else
				entity_addVel(me, 200, -500)
			end
			entity_setWeight(me, 600)
			v.jumpDelay = 2+math.random(5)
		else
			--entity_setCanLeaveWater(me, false)
			entity_setWeight(me, 0)
		end
	end

	v.shockDelay = v.shockDelay - dt
	if v.shockDelay < 0 then
		v.shockDelay = 5 + math.random(3)
		entity_setState(me, STATE_SHOCK, 0.5)
	end

end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setMaxSpeed(me, 400)
	elseif entity_isState(me, STATE_SHOCK) then
		entity_sound(me, "EnergyOrbCharge")
		spawnParticleEffect("JellyShock", entity_x(me), entity_y(me))
	elseif entity_isState(me, STATE_DEATHSCENE) then
		entity_clearVel(me)
		entity_setStateTime(me, 1.2)
		local sz = 20.0
		for i=80,0,-sz do
			local x, y = entity_getHairPosition(me, i)
			spawnParticleEffect("TinyGreenExplode", x, y, 0.15*((80-i)/sz))
		end		
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

function songNoteDone(me, note, t)
	v.songTimer = v.songTimer + t
end


function dieNormal(me)
	if chance(25) then
		spawnIngredient("EelOil", entity_x(me), entity_y(me))
	end
end

