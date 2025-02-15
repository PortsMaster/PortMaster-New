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
v.dad = 0
v.bone = 0
v.babySpawn = 0

v.momVisionTime =  0.5
v.momVisionDelay = v.momVisionTime
v.momEyes = 0


v.started = false
v.createDelayTime = 20
v.createDelay = v.createDelayTime

local STATE_GOTODAD	= 1000
local STATE_MOURN	= 1001
local STATE_MOMVISION = 1002

v.fireDelay = 2
v.shotDelay = 0.1
v.shots = 0
v.numShots = 8
v.angle = 0
 
function init(me)
	setupEntity(me)
	entity_setHealth(me, 30)
	entity_initSkeletal(me, "SunkenMom")
	entity_setCollideRadius(me, 32)
	entity_setState(me, STATE_IDLE)
	entity_scale(me, 0.5, 0.5)
	
	entity_setCull(me, false)
	entity_setEntityType(me, ET_ENEMY)
	entity_setAllDamageTargets(me, false)
	entity_generateCollisionMask(me)
	
	entity_setMaxSpeed(me, 800)
	entity_setDeathScene(me, true)
	
	--entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
end

function postInit(me)
	v.n = getNaija()
	v.dad = entity_getNearestEntity(me, "SunkenDad")
	v.bone = entity_getBoneByName(v.dad, "MomPosition")
	v.babySpawn = entity_getBoneByName(v.dad, "BabySpawn")
	--[[
	local x, y = bone_getWorldPosition(v.bone)
	entity_setPosition(me, x, y, 0.5)
	]]--
	
	entity_setTarget(me, v.dad)
end

function update(me, dt)
	if not v.started then
		return
	end
	if not entity_isState(me, STATE_DEATHSCENE) then
		overrideZoom(0.45, 1.0)
	end
	
	
	--debugLog(string.format("createDelay: %f", v.createDelay))
	if entity_isState(me, STATE_MOMVISION) then
		--[[
		v.momVisionDelay = v.momVisionDelay - dt
		if v.momVisionDelay < 0 then
			v.momVisionDelay = v.momVisionTime
			x = entity_x(v.n)
			node = entity_getNearestNode(v.n, "MOMEYES")
			dist = 300
			x = x + entity_velx(v.n)*0.5
			if chance(50) then
				createEntity("MomEyes", "", x-dist, node_y(node))
				createEntity("MomEyes", "", x, node_y(node))
			else
				createEntity("MomEyes", "", x+dist, node_y(node))
				createEntity("MomEyes", "", x, node_y(node))
			end
		end
		]]--
		--[[
		v.momVisionDelay = v.momVisionDelay - dt
		if v.momVisionDelay < 0 then
			v.momVisionDelay = v.momVisionTime
			s = createShot("MomVision", "", entity_x(v.momEyes), entity_y(v.momEyes))
			shot_setAimVector(s, entity_x(v.n) - entity_x(v.momEyes), entity_y(v.n) - entity_y(v.momEyes))
		end
		]]--
	end
	if entity_isState(me, STATE_IDLE) then
		if not (entity_getHealth(v.dad) < 220) then
			v.createDelay = v.createDelay - dt
			if v.createDelay < 0 then
				if entity_isState(v.dad, STATE_IDLE) then
					--debugLog("setting dad to waitForKiss")
					entity_setState(v.dad, STATE_WAITFORKISS, -1, true)
					entity_setState(me, STATE_GOTODAD)
					v.createDelay = v.createDelayTime
				end			
			end
		else
			v.fireDelay = v.fireDelay - dt
			if v.fireDelay < 0 then
				v.shotDelay = v.shotDelay - dt
				if v.shotDelay < 0 then
					v.shots = v.shots + 1
					v.shotDelay = 0.7
					local s = createShot("zygoteshot-mom", me, v.n)
					shot_setAimVector(s, math.sin(v.angle), math.cos(v.angle))
					v.angle = v.angle + ((3.14*2)/v.numShots) * v.shots
					if v.shots >= v.numShots then
						v.fireDelay = 3
						v.shots = 0
					end
				end
			end
		end
	end
	
	if entity_isState(me, STATE_IDLE) then
		if entity_hasTarget(me) then
			if entity_isTargetInRange(me, 512) then
				entity_moveAroundTarget(me, dt, 1000, 0)
			else
				entity_moveTowardsTarget(me, dt, 1000)
			end
			entity_flipToEntity(me, entity_getTarget(me))
			entity_doCollisionAvoidance(me, dt, 5, 0.5)
		end
		entity_updateMovement(me, dt)
	end
	if entity_isState(me, STATE_KISS) then
		local x, y = bone_getWorldPosition(v.bone)
		entity_setPosition(me, x, y, 0.5)
		entity_flipToEntity(me, v.dad)
	end
	entity_handleShotCollisionsSkeletal(me)
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "fly", -1)	
	elseif entity_isState(me, STATE_GOTODAD) then
		entity_animate(me, "fly", -1)
		local x, y = bone_getWorldPosition(v.bone)
		--debugLog(string.format("pos(%f,%f)", x, y))
		entity_clearVel(me)
		entity_setStateTime(me, entity_setPosition(me, x, y, -1 * 300))
	elseif entity_isState(me, STATE_KISS) then		
		entity_setStateTime(me, entity_animate(me, "kiss"))
		local x, y = bone_getWorldPosition(v.bone)
		entity_setPosition(me, x, y, -1 * 100)
		entity_setState(v.dad, STATE_KISS, -1, true)
	elseif entity_isState(me, STATE_WEAK) then
		local node = getNode("GROUNDLEVEL")
		entity_setPosition(me, entity_x(me), node_y(node), -500)
		entity_animate(me, "weak")
		entity_setStateTime(me, 12)
		entity_setState(v.dad, STATE_RAGE, -1, true)
	elseif entity_isState(me, STATE_MOMVISION) then
		debugLog("mom vision")
		--[[
		v.momEyes = createEntity("MomEyes", "", entity_x(me), entity_y(me)-800)
		entity_setStateTime(me, 20)
		v.momVisionDelay = 0
		]]--
		entity_setStateTime(me, 3)
	elseif entity_isState(me, STATE_DEATHSCENE) then
		entity_setStateTime(me, -1)
		entity_clearVel(me)
	elseif entity_isState(me, STATE_START) then
		v.started = true
		entity_setStateTime(me, 0.1)	
	end
end

function exitState(me)
	if entity_isState(me, STATE_GOTODAD) then
		debugLog("state goToDad done")
		entity_setState(me, STATE_KISS)
	elseif entity_isState(me, STATE_KISS) then
		if not entity_isState(v.dad, STATE_DEATHSCENE) then
			--entity_setState(v.dad, STATE_IDLE)
			local x, y = bone_getWorldPosition(v.babySpawn)
			createEntity("Zygote", "", x, y)
			playSfx("sunkendad-headspurt")
			spawnParticleEffect("sunkendad-headspurt", x, y)
			--createEntity("GhostBaby", "", x, y-10)
			entity_setState(me, STATE_IDLE)
		end
	elseif entity_isState(me, STATE_WEAK) then
		if not entity_isState(v.dad, STATE_DEATHSCENE) and not (entity_getHealthPerc(v.dad) <= 0) then
			if entity_getHealth(v.dad) >= 220 then
				entity_setState(v.dad, STATE_CALM, -1, true)
			end
			entity_setState(me, STATE_MOMVISION)
		end
	elseif entity_isState(me, STATE_MOMVISION) then
		if v.momEyes ~= 0 then
			entity_setState(v.momEyes, STATE_DONE)
		end
		
		if not entity_isState(v.dad, STATE_DEATHSCENE) and not (entity_getHealthPerc(v.dad) <= 0) then
			entity_setState(v.dad, STATE_IDLE)
			entity_setState(me, STATE_IDLE)
		end
		
	elseif entity_isState(me, STATE_START) then
		entity_setState(me, STATE_IDLE)		
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if not (entity_getHealth(v.dad) < 220) then
		if not entity_isState(me, STATE_WEAK) then
			-- for debug
			--or damageType == DT_AVATAR_ENERGYBLAST
			if damageType == DT_AVATAR_CREATORSHOT  then
				--bone_damageFlash(me, entity_getBoneByIdx(me, 0))
				entity_setState(me, STATE_WEAK)
			end
		end
	end
	return false
end

