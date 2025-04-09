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
-- Merman / Thin
-- ================================================================================================

v.swimTime = 0
v.swimTimer = v.swimTime - v.swimTime/4
v.dirTimer = 0
v.dir = 0

v.playedSound = false

v.attackDelay = 0
v.maxAttackDelay = 1

local STATE_HANG 	= 1000
local STATE_SWIM 	= 1001
local STATE_BURST = 1002
local STATE_WALL = 1003
local STATE_WALLBURST = 1004

v.burstDelay = 0
v.checkSurfaceDelay = 0

v.bloatTimer = 0

v.lastx = 0
v.lasty = 0

v.bloated = false

function init(me)
	v.soundDelay = math.random(4)
	v.playSoundDelay = math.random(300)/300.0

	setupBasicEntity(me, 
	"",					-- texture
	9,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	30,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	64,								-- sprite width	
	64,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	2000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_initSkeletal(me, "MermanThin")
	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	

	entity_setState(me, STATE_IDLE)
	
	
	entity_setTarget(me, getNaija())
	
	entity_setDropChance(me, 40, 1)
	
	
	entity_scale(me, 0.75, 0.75)
	
	entity_setBeautyFlip(me, false)
	
	esetv(me, EV_WALLOUT, 32)
	
	--[[
	r = math.random(100)/200.0
	r = r* 0.25
	r = r - 0.15
	entity_scale(me, 0.75+r, 0.75+r)
	
	typ = math.random(4)
	if typ<=2 then
		entity_color(me, 1, 1, 1)
	elseif typ==3 then
		entity_color(me, 0.75, 0.75, 1)
	elseif typ==4 then
		entity_color(me, 1, 0.75, 0.75)
	end
	]]--
	
	loadSound("Merman-Cry")
	loadSound("Merman-Idle")
	loadSound("merman-bloat-explode")
	
	entity_setDeathScene(me, true)
	
	entity_setDamageTarget(me, DT_ENEMY_POISON, false)
	
	--esetv(me, EV_TYPEID, EVT_MERMANTHIN)
end

function postInit(me)
	--checkSurface(me)
	local node = entity_getNearestNode(me, "bloatup")
	if node ~= 0 and node_isEntityIn(node, me) then
		entity_setState(me, STATE_BLOATED, -1, 1)
	end
	
	local node = entity_getNearestNode(me, "sitstill")
	if node ~= 0 and node_isEntityIn(node, me) then
		entity_setMaxSpeed(me, 0.01)
	end
end

--[[
function checkSurface(me)
	if entity_isNearObstruction(me, 3, OBSCHECK_4DIR) then
		v.checkSurfaceDelay = math.random(3)+1
		if entity_clampToSurface(me, 0.5, 3) then
			entity_setState(me, STATE_WALL, 2 + math.random(2))
		else
			v.checkSurfaceDelay = 0.1
		end
	end
end
]]--

function update(me, dt)
	local amt = 800
	
	if entity_isState(me, STATE_IDLE) or entity_isState(me, STATE_WALL) or entity_isState(me, STATE_SWIM) then
		v.soundDelay = v.soundDelay - dt
		if v.soundDelay < 0 then
			v.soundDelay = math.random(4)+2
			entity_sound(me, "Merman-Idle", 1000+math.random(100))
		end
	end
	
	if v.burstDelay > 0 then
		v.burstDelay = v.burstDelay - dt
	end

	
	entity_updateCurrents(me, dt)
	
	if entity_isState(me, STATE_BLOATED) then
		v.dirTimer = v.dirTimer + dt
		if v.dirTimer > 2 then
			v.dirTimer = 0
			if v.dir > 0 then
				v.dir = 0
			else
				v.dir = 1
			end
		end
		local spd = 200
		if v.dir > 0 then
			spd = -spd
		end
		entity_addVel(me, spd*dt, 0)
		entity_doEntityAvoidance(me, dt, 256, 0.1)
		entity_doCollisionAvoidance(me, dt, 6, 0.5)
		
		if not entity_isBeingPulled(me) then
			v.bloatTimer = v.bloatTimer + dt
			if v.bloatTimer > 0.5 then
				spawnParticleEffect("gaspoof", entity_x(me), entity_y(me))
				--createShot( "bloatgasshot", me, getNaija())
				v.bloatTimer = 0
			end
		else
			v.bloatTimer = -3
		end
		
	end
	if entity_isState(me, STATE_IDLE) then
		entity_rotate(me, 0, 0.2)
		entity_updateCurrents(me)
		v.timer = v.timer + dt
		if v.timer > 2 then
			v.timer = 0
			if not entity_hasTarget(me) then
				entity_findTarget(me, 2000)
			end
			if entity_hasTarget(me) then
				entity_setState(me, STATE_SWIM)
			end
			entity_addVel(me, 0, -100*dt)			
		end
	end

	if not v.playedSound and entity_isEntityInRange(me, getNaija(), 800) then
		v.playSoundDelay = v.playSoundDelay - dt
		if v.playSoundDelay < 0 then
			v.playedSound = true
			entity_sound(me, "Merman-Cry", 1000 + math.random(100))
			v.playSoundDelay = 0
		end
	end

	
	if entity_isState(me, STATE_SWIM) then
		v.timer = v.timer + dt
		if v.timer > 5 then
			entity_setState(me, STATE_IDLE)
		end
		if entity_hasTarget(me) then
			entity_moveTowardsTarget(me, dt, 800)
			entity_doCollisionAvoidance(me, dt, 3, 0.5)
		else
			entity_setState(me, STATE_IDLE)
		end
		entity_rotateToVel(me, 0)
		entity_doEntityAvoidance(me, dt, 256, 0.1)
	end
	
	if entity_isState(me, STATE_IDLE) or entity_isState(me, STATE_SWIM) then
		v.checkSurfaceDelay = v.checkSurfaceDelay + dt
		
		if v.checkSurfaceDelay > 5 then
			--debugLog("MermanThin: checking surface")
			if entity_checkSurface(me, 6, STATE_WALL, math.random(2)+2) then
				--debugLog("MermanThin: successful clamp!")
			else
				entity_doCollisionAvoidance(me, dt, 2, 0.5)
				v.checkSurfaceDelay = 4.9
			end
			
			--v.checkSurfaceDelay = 0
		else
			entity_doCollisionAvoidance(me, dt, 2, 0.5)
		end
	end
	
	if entity_isState(me, STATE_BURST) or entity_isState(me, STATE_WALLBURST) then
		entity_rotateToVel(me, 0)
	end
	
	if entity_isBeingPulled(me) then
		entity_setMaxSpeedLerp(me, 2, 0.1)
	else
		entity_setMaxSpeedLerp(me, 1, 0.1)
	end
	
	--[[
	if not entity_hasTarget(me) then
		entity_findTarget(me, 500)
	else
		
		v.swimTimer = v.swimTimer + dt
		if v.swimTimer > v.swimTime then			
			entity_moveTowardsTarget(me, 1, amt)
			if not entity_isNearObstruction(getNaija(), 8) then
				entity_doCollisionAvoidance(me, 1, 6, 0.5)
			end
			
			entity_doSpellAvoidance(me, 1, 256, 0.2)
			entity_doEntityAvoidance(me, 1, 256, 0.2)
			entity_rotateToVel(me, 0.1)
			v.swimTimer = v.swimTimer - v.swimTime
			entity_animate(me, "swim", LOOP_INF)
		else
			entity_moveTowardsTarget(me, dt, 400)
			entity_doEntityAvoidance(me, dt, 64, 0.1)
			--if not entity_isNearObstruction(getNaija(), 8) then
			entity_doCollisionAvoidance(me, dt, 6, 0.5)
			if entity_getAnimationName(me, 0)~="idle" then
				entity_animate(me, "idle", LOOP_INF)
			end
			
			--end
		end
		entity_findTarget(me, 800)
	end
	]]--
	
	if not entity_isState(me, STATE_WALL) then		
		entity_doFriction(me, dt, 100)
		if entity_isBeingPulled(me) then
			--entity_flipToEntity(me, v.n)
			entity_doCollisionAvoidance(me, dt, 5, 0.5)
		else
			entity_flipToVel(me)
		end
		entity_updateMovement(me, dt)
	else
		-- on wall
		entity_moveAlongSurface(me, dt, 350, 6)
		entity_rotateToSurfaceNormal(me)
		--[[
		if entity_x(me) == v.lastx and entity_y(me) == v.lasty then
			entity_setState(me, STATE_WALLBURST)
		end
		]]--
	end

	if not entity_isState(me, STATE_WALL) then
		if v.attackDelay < v.maxAttackDelay then
			v.attackDelay = v.attackDelay + dt
		else
			if entity_isEntityInRange(me, entity_getTarget(me), 128) then
				entity_animate(me, string.format("attack%d", math.random(3)), 0, LAYER_UPPERBODY)
				v.attackDelay = 0
			end
		end
	end
	if not entity_isBeingPulled(me) then
		local attacked = false
		if not entity_isState(me, STATE_BLOATED) then
			attacked = entity_touchAvatarDamage(me, 32, 1, 1200)
		else
			if v.bloatTimer >= 0 then
				attacked = entity_touchAvatarDamage(me, 96, 0.5, 1200)
			end
		end

	end
	
	entity_handleShotCollisions(me)	
	
	v.lastx = entity_x(me)
	v.lasty = entity_y(me)
	
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_ENEMY_GAS then
		if not entity_isState(me, STATE_BLOATED) then
			--and not entity_isState(me, STATE_WALL)
			spawnParticleEffect("Swell", entity_x(me), entity_y(me))
			entity_setState(me, STATE_BLOATED)
			shakeCamera(3, 1)
		else
			return false
		end
	end
	if entity_isState(me, STATE_BLOATED) then
		if attacker == getNaija() then
			entity_sound(me, "noeffect")
			return false
		end
	end
	if damageType == DT_ENEMY_POISON or damageType == DT_ENEMY_ACTIVEPOISON then
		return false
	end
	if entity_isState(me, STATE_IDLE) or entity_isState(me, STATE_SWIM) then
		if (entity_isState(me, STATE_IDLE) or v.burstDelay <= 0) and damageType == DT_AVATAR_ENERGYBLAST then
			entity_setState(me, STATE_BURST, 0.5)
		end
	end
	if damageType == DT_ENEMY_BEAM then
		-- do more damage?
		--entity_changeHealth(me, -dmg*2)
	end
	--entity_sound(me, "MermanHit", 980+math.random(40))
	return true
end

function enterState(me)
	v.timer = 0
	if entity_getState(me)==STATE_IDLE then
		--debugLog("MermanThin: STATE_IDLE")
		entity_setProperty(me, EP_MOVABLE, false)
		entity_setMaxSpeed(me, 600)
		entity_animate(me, "idle", LOOP_INF)
	elseif entity_isState(me, STATE_DEATHSCENE) then
		entity_setStateTime(me, 1)
		entity_setColor(me, 0, 0, 0, 0.5)
		--entity_setAnimLayerTimeMult(me, 0, 2)
	elseif entity_getState(me)==STATE_BLOATED then
		--[[
		if isMapName("Cathedral04") then
			node = getNode("BLOATEDPOS")
			entity_setPosition(me, node_x(node), node_y(node), 1, 0, 0, 1)
		end
		]]--
		v.bloated = true
		entity_setProperty(me, EP_MOVABLE, true)
		--entity_applySurfaceNormalForce(me, 1000)
		--entity_setWeight(me, 10)	
		entity_initSkeletal(me, "MermanBloated")
		entity_rotate(me,0,0.5)
		entity_setMaxSpeed(me, 200)
		entity_animate(me, "idle", LOOP_INF)
		entity_setDropChance(me, 0)
		entity_adjustPositionBySurfaceNormal(me, 64)
		entity_setDeathScene(me, false)
		entity_setDeathParticleEffect(me, "mermanexplode")
		entity_setDeathSound(me, "merman-bloat-explode")
		
		entity_setDamageTarget(me, DT_AVATAR_PET, false)
		entity_setDamageTarget(me, DT_ENEMY_POISON, false)
		
		entity_sound(me, "merman-bloat-explode")
		
	elseif entity_getState(me)==STATE_SWIM then
		entity_animate(me, "swim", LOOP_INF)
	elseif entity_isState(me, STATE_WALL) then
		debugLog("MermanThin: STATE_WALL")
		entity_clearVel(me)
		entity_clampToSurface(me)
		entity_stopAllAnimations(me)
		
		--[[
		side = false
		if entity_x(getNaija()) < entity_x(me) then
			side = false
		else
			side = true
		end

		a = entity_getRotation(me)
		if a > 90 and a < 360-90 then
			side = not side
		end
		]]--
		if chance(50) then
			entity_switchSurfaceDirection(me, 1)
			if entity_isFlippedHorizontal(me) then
				entity_flipHorizontal(me)
			end			
		else
			entity_switchSurfaceDirection(me, 0)
			if not entity_isFlippedHorizontal(me) then
				entity_flipHorizontal(me)
			end			
		end
		entity_animate(me, "wall", LOOP_INF)
	elseif entity_getState(me)==STATE_BURST then
		v.burstDelay = 6
		entity_animate(me, "burst")
		--[[
		entity_doSpellAvoidance(me, 1, 256, 1.0)
		entity_doEntityAvoidance(me, 1, 256, 1.0)
		entity_doCollisionAvoidance(me, 1, 256, 1.0)
		]]--		
		entity_setMaxSpeedLerp(me, 2, 0.1)
		entity_moveTowardsTarget(me, 1, 1000)
	elseif entity_getState(me)==STATE_WALLBURST then		
		--entity_applySurfaceNormalForce(me, 1000)
		local vx, vy = entity_getNormal(me)
		vx = vx * 1000
		vy = vy * 1000
		entity_clearVel(me)
		entity_addVel(me, vx, vy)
		--debugLog(string.format("v(%f, %f)", vx, vy))
		v.burstDelay = 6
		entity_animate(me, "burst")
		entity_setMaxSpeedLerp(me, 2, 0.1)
		--entity_moveAlongSurface(me, 1, 0, 0, 100)
	elseif entity_isState(me, STATE_DEAD) then
		entity_sound(me, "Merman-Cry", 1150 + math.random(200))
	end
end

function exitState(me)
	if entity_isState(me, STATE_BURST) or entity_isState(me, STATE_WALLBURST) then	
		entity_setState(me, STATE_SWIM)
		entity_setMaxSpeedLerp(me, 1, 0.1)
	elseif entity_isState(me, STATE_WALL) then
		entity_setState(me, STATE_WALLBURST, 1)
	end
end

function hitSurface(me)
end

function dieNormal(me)
	if v.bloated then
		shakeCamera(10, 2)
	end
end
