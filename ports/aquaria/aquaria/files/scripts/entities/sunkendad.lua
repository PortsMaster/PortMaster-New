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

v.attackTimer = 0
v.n = 0
v.mom = 0
v.body = 0

v.started = false
local STATE_ATTACK1		= 1001
local STATE_ATTACK2		= 1002
local STATE_ATTACK3		= 1003

local STATE_PREP1		= 1005
local STATE_PREP2		= 1006
local STATE_PREP3		= 1007
v.enraged = false
v.dadMax = 0
v.dadMin = 0
v.deathScene = false

v.lastPhase = false
v.almostDone = false

v.hitDelay = 0

function init(me)
	setupEntity(me)
	--entity_setHealth(me, 50)
	-- for debug
	--entity_setHealth(me, 2)
	
	entity_setHealth(me, 290) -- 90 -- 100
	entity_initSkeletal(me, "SunkenDad")
	entity_setState(me, STATE_IDLE)
	entity_scale(me, 2, 2)
	
	entity_setCull(me, false)
	entity_setEntityType(me, ET_ENEMY)
	
	entity_generateCollisionMask(me)
	v.n = getNaija()
	--entity_setAllDamageTargets(me, false)
	--[[
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
	entity_setDamageTarget(me, DT_AVATAR_SHOCK, true)
	
	]]--
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_ENEMY_ENERGYBLAST, false)
	
	entity_setEatType(me, EAT_NONE)
	
	entity_setTargetRange(me, 256)
	v.body = entity_getBoneByName(me, "Body")
	
	--[[
	bone_alpha(entity_getBoneByName(me, "MomPosition"), 0.5)
	bone_alpha(entity_getBoneByName(me, "BabySpawn"), 0.5)
	bone_alpha(entity_getBoneByName(me, "PE"), 0.5)
	]]--
	--entity_setAutoSkeletalUpdate(me, false)
	entity_setDeathScene(me, true)
	entity_setTargetRange(me, 2000)
	
	
	loadSound("sunkendad-roar")
	loadSound("sunkendad-hit")
	loadSound("ChopRock")
	loadSound("sunkendad-stomp")
	loadSound("sunkendad-breakout")
	loadSound("mia-appear")
	loadSound("sunkendad-headspurt")
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	v.mom = getEntity("SunkenMom")
end

function animationKey(me, key)
	if entity_isState(me, STATE_ATTACK1) then
		if key == 4 then
			shakeCamera(10, 0.5)
			playSfx("ChopRock")
		end
	elseif entity_isState(me, STATE_ATTACK2) then
		if key == 2 then
			shakeCamera(10, 0.5)
			playSfx("ChopRock")
		end
	elseif entity_isState(me, STATE_PREP3) then
		if key == 4 or key == 6 or key == 8 then
			playSfx("sunkendad-stomp")
		end
	elseif entity_isState(me, STATE_ATTACK3) then
		if key == 2 or key == 4 then
			playSfx("sunkendad-stomp")
		end
	end
	v.dadMax = getNode("DADMAX")
	v.dadMin = getNode("DADMIN")
end

v.inCut = false
local function cutScene(me)
	if v.inCut then return end
	v.inCut = true
	local dad = me
	entity_stopInterpolating(me)
	fadeOutMusic(4)
	overrideZoom(0.5, 1)
	entity_idle(v.n)
	cam_toEntity(me)
	entity_stopInterpolating(me)
	entity_setPosition(me, entity_x(me), entity_y(me), 10)
	setSceneColor(1,1,1,4)
	watch(4)
	changeForm(FORM_NORMAL)
	
	--setFlag(FLAG_PET_ACTIVE, 0)

	local e = getFirstEntity()
	while e ~= 0 do
		if entity_isName(e, "zygote") then
			entity_delete(e)
		end
		e = getNextEntity()
	end


	cam_toEntity(dad)
	entity_alpha(dad, 0, 3)
	entity_flipToEntity(v.n, dad)
	
	
	debugLog("creating father")
	
	local gdad = createEntity("cc_father", "", entity_x(me), entity_y(me))
	entity_alpha(gdad, 0)
	entity_alpha(gdad, 1, 2)
	entity_setPosition(gdad, entity_x(gdad), entity_y(gdad)-50, 3, 0, 0, 1)
	
	watch(3)
	
	local sx, sy = entity_getScale(gdad)
	entity_scale(gdad, sx*1.5, sy*1.5, 2)
	entity_alpha(gdad, 0, 2)
	
	watch(2)
	
	cam_toEntity(v.mom)
	entity_flipToEntity(v.n, v.mom)
	local gmom = createEntity("CC_Mother", "", entity_getPosition(v.mom))
	entity_alpha(gmom, 0)
	entity_alpha(gmom, 1, 2)
	entity_alpha(v.mom, 0, 4)
	entity_setPosition(gmom, entity_x(gmom), entity_y(gmom)-50, 3, 0, 0, 1)
	watch(1)
	voice("naija_likidnappedbefore")
	watch(3)
	sx,sy = entity_getScale(gmom)
	entity_scale(gmom, sx*1.5, sy*1.5, 2)
	entity_alpha(gmom, 0, 2)
	watch(2)
	
	entity_idle(v.n)
	local li = getLi()
	if li ~= 0 then	
		--cam_toEntity(li)
		
		local door = entity_getNearestEntity(me, "EnergyDoor")
		if not entity_isState(door, STATE_OPENED) then
			entity_setState(door, STATE_OPEN)
		end
		

		--[[
		local node = getNode("CREATORSHADOW")
		local c = createEntity("CreatorShadow", "", node_x(node), node_y(node))
		entity_setPosition(c, entity_x(li), entity_y(li), -1000)
		while entity_isInterpolating(c) do
			watch(FRAME_TIME)
		end
		]]--
		
		cam_toNode(getNode("BOSSWAIT"))
		
		
		
		fade(1, 2)
		watch(2)
	
		setOverrideVoiceFader(1.0)
		
		local node = getNode("NAIJAPOS")
		entity_setPosition(v.n, node_x(node), node_y(node))
		
		local node = getNode("LIPOS")
		entity_setPosition(li, node_x(node), node_y(node))
		
		local node = getNode("CREATORSPAWN")
		local c = createEntity("CreatorSunkenCity", "", node_x(node), node_y(node))
		entity_alpha(c, 0)
		
		entity_flipToEntity(c, v.n)
		entity_flipToEntity(v.n, c)
		entity_flipToEntity(li, c)
		
		fade(0, 1)
		watch(1)

		cam_toEntity(c)
		playSfx("mia-appear")
		spawnParticleEffect("CreatorTransport", node_x(node), node_y(node))
		watch(1)
		
		playSfx("NaijaGasp")
		
		watch(0.5)
		
		entity_alpha(c, 1, 1)
		
		voiceInterupt("laugh3")
		
		watch(0.5)

		
		
		
		watch(0.5)
		
		watch(0.1)
		
		--[[
		entity_animate(c, "smack")
		while entity_isAnimating(c) do
			watch(FRAME_TIME)
		end
		]]--
		
		
		
		entity_animate(c, "grab")
		while entity_isAnimating(c) do
			watch(FRAME_TIME)
		end
		
		emote(EMOTE_NAIJALI)
		
		entity_setState(li, STATE_TRAPPEDINCREATOR)
		
		entity_setState(c, STATE_GRAB)
		entity_animate(c, "take")
		while entity_isAnimating(c) do
			watch(FRAME_TIME)
		end
		
		playSfx("mia-appear")
		
		-- li!!
		
		entity_swimToNode(v.n, getNode("NAIJACONCERN"))
		
		entity_alpha(c, 0, 1)
		entity_alpha(li, 0, 1)
		
		spawnParticleEffect("CreatorTransport", node_x(node), node_y(node))
		
		watch(1)
		
		entity_setState(c, STATE_IDLE)
		
		entity_setPosition(c, 0, 0)
		entity_setPosition(li, 0, 0)
		
		cam_toEntity(v.n)
		
		--[[
		local node = getNode("CREATORSHADOWEXIT")
		--entity_swimToNode(c, node, SPEED_VERYFAST)
		entity_setPosition(c, node_x(node), node_y(node), -1000)
		cam_toEntity(v.n)
		playMusic("SunkenCity")
		while entity_isInterpolating(c) do
			wait(FRAME_TIME)
			entity_setPosition(li, entity_x(c), entity_y(c))			
		end
		entity_setPosition(li, 0, 0)
		entity_delete(c)
		]]--
		
		watch(4)
		
		setOverrideVoiceFader(-1)
		
		voice("naija_likidnapped")
		setFlag(FLAG_LI, 200)
		setFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_BOSSDONE)
		
		
	else
		cam_toEntity(v.n)
	end
	overrideZoom(0, 1)	
end

function update(me, dt)
	if not v.started then
		return
	end
	entity_clearTargetPoints(me)
	local x, y = bone_getWorldPosition(v.body)
	entity_addTargetPoint(me, x, y)
	if v.enraged then
		dt = dt * 2
	end
	
	if v.hitDelay > 0 then
		v.hitDelay = v.hitDelay - dt
		if v.hitDelay < 0 then
			v.hitDelay = 0
		end
	end
	
	-- note also has to be set to the same value in sunkenmom
	if entity_getHealth(me) < 220 and entity_getHealth(me) > 0 then
		v.enraged = true
		if v.almostDone then
			setSceneColor(1, 0.3, 0.3, 3)
		else
			setSceneColor(1, 0.7, 0.7, 3)
		end
	end

	if not entity_isAnimating(me) and (entity_isState(me, STATE_ATTACK1) or entity_isState(me, STATE_ATTACK2)) then
		entity_setState(me, STATE_IDLE)
	end
	if entity_isState(me, STATE_IDLE) then
		v.attackTimer = v.attackTimer + dt
		if (not v.enraged and v.attackTimer > 3) or (v.enraged and v.attackTimer > 2) then
		
			--local hammerzone = entity_getNearestNode(v.n, "hammerzone")
			local dadjumpzone = entity_getNearestNode(me, "dadjumpzone")
			if node_isEntityIn(dadjumpzone, me) then
				entity_setState(me, STATE_PREP2)
			else
				local xdist = entity_x(v.n)-entity_x(me)
				if math.abs(xdist)<500 and entity_y(v.n) > entity_y(me)-100 then
					if chance(50) then
						entity_setState(me, STATE_PREP3)
					else
						entity_setState(me, STATE_ATTACK1)
					end
				else
					if entity_y(v.n) > entity_y(me) - 400 then
						if chance(40) then						
							entity_setState(me, STATE_PREP2)
						else
							entity_setState(me, STATE_PREP3)
						end
					else
						entity_setState(me, STATE_PREP2)
					end
				end
			end
			v.attackTimer = 0
		end
	end
	if entity_isState(me, STATE_ATTACK3) and not entity_isInterpolating(me) then
		entity_setState(me, STATE_IDLE)
	end
	
	if entity_x(me) < node_x(v.dadMin) then
		if entity_isState(me, STATE_ATTACK3) then
			entity_setState(me, STATE_IDLE)
		end
		entity_setPositionX(me, node_x(v.dadMin))
	end
	if entity_x(me) > node_x(v.dadMax) then
		if entity_isState(me, STATE_ATTACK3) then
			entity_setState(me, STATE_IDLE)
		end
		entity_setPositionX(me, node_x(v.dadMax))
	end
	
	--entity_updateSkeletal(me, dt)
	
	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then
		avatar_fallOffWall()
	
		local nx,ny = entity_getPosition(v.n)
		local cx,cy = entity_getPosition(me)
		local x = nx-cx
		local y = 0
		x,y = vector_setLength(x,y,2000)
		entity_addVel(v.n, x, y)
		local dmg = 0.5
		if v.enraged then
			if entity_getHealth(me) < 220 then
				dmg = 1.5
			else
				dmg = 1
			end
		end
		entity_damage(v.n, me, dmg)
	end	
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
		entity_flipToEntity(me, v.n)
	elseif entity_isState(me, STATE_PREP1) then
		playSfx("sunkendad-roar")
		entity_setStateTime(me, entity_animate(me, "prep1"))
	elseif entity_isState(me, STATE_PREP2) then
		playSfx("sunkendad-roar")
		entity_flipToEntity(me, v.n)
		entity_setStateTime(me, entity_animate(me, "prep2"))
	elseif entity_isState(me, STATE_PREP3) then
		playSfx("sunkendad-roar")
		entity_setStateTime(me, entity_animate(me, "prep3"))
		entity_flipToEntity(me, v.n)
	elseif entity_isState(me, STATE_ATTACK1) then
		entity_flipToEntity(me, v.n)
		entity_animate(me, "attack")
	elseif entity_isState(me, STATE_ATTACK2) then
		entity_flipToEntity(me, v.n)
		entity_animate(me, "attack2")
		local minJumpLen = 100
		local maxJumpLen = 600
		local dist = entity_x(v.n) - entity_x(me)
		if dist > maxJumpLen then
			dist = maxJumpLen
		end
		if dist < minJumpLen then
			dist = minJumpLen
		end
		if dist > -maxJumpLen then
			dist = -maxJumpLen
		end
		if dist < -minJumpLen then
			dist = -minJumpLen
		end		
		entity_setPosition(me, entity_x(v.n) + dist, entity_y(me), 1)
		entity_offset(me, 0, -650, 0.5, 1, 1)
	elseif entity_isState(me, STATE_ATTACK3) then
		entity_flipToEntity(me, v.n)
		entity_animate(me, "attack3", -1)
		local chargeDist = 2000
		local spd = 1800
		if entity_x(v.n) < entity_x(me) then
			entity_setPosition(me, entity_x(me) - chargeDist, entity_y(me), -1 * spd)
		else
			entity_setPosition(me, entity_x(me) + chargeDist, entity_y(me), -1 * spd)
		end
	elseif entity_isState(me, STATE_WAITFORKISS) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_KISS) then
		entity_setStateTime(me, entity_animate(me, "kiss"))
	elseif entity_isState(me, STATE_RAGE) then
		entity_setStateTime(me, entity_animate(me, "rage"))
		entity_color(me, 1, 0.5, 0.5, 3)
		v.enraged = true
		entity_setDamageTarget(me, DT_AVATAR_LIZAP, true)
	elseif entity_isState(me, STATE_CALM) then
		v.enraged = false
		entity_setStateTime(me, entity_animate(me, "calm"))
		entity_color(me, 1, 1, 1, 3)
		entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	elseif entity_isState(me, STATE_DEATHSCENE) then
		--entity_setStateTime(v.mom, 10)
		entity_setAllDamageTargets(me, false)
		debugLog("DEATH SCENE!")
		pickupGem("Boss-SunkenDad")
		v.deathScene = true
		entity_animate(me, "die")
		entity_setStateTime(me, -1)
		entity_setState(v.mom, STATE_DEATHSCENE)
		entity_color(me, 1, 1, 1, 5)
		entity_stopInterpolating(me)
		entity_setPosition(me, entity_x(me), entity_y(me), 0.1)
		cutScene(me)
		toggleSteam(false)
		
	elseif entity_isState(me, STATE_START) then
		v.started = true
		entity_setStateTime(me, 0.1)
	end
end

function exitState(me)
	if entity_getEnqueuedState(me) == STATE_DEATHSCENE or entity_getEnqueuedState(me) == STATE_RAGE then
		return
	end
	
	if entity_isState(me, STATE_KISS) then
		entity_setState(me, STATE_IDLE)
		v.attackTimer = -1
	elseif entity_isState(me, STATE_RAGE) then
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_PREP2) then
		entity_setState(me, STATE_ATTACK2)
	elseif entity_isState(me, STATE_PREP3) then
		entity_setState(me, STATE_ATTACK3)
	elseif entity_isState(me, STATE_START) then
		entity_setState(me, STATE_IDLE)		
	end
end

function damage(me, attacker, bone, damageType, dmg)
-- for debug
--[[
	entity_changeHealth(me, -999)
	return true
	]]--

	if v.enraged then
		if v.hitDelay == 0 then
			playSfx("sunkendad-hit")
			v.hitDelay = 0.5
		end
		if ((entity_getHealth(me) - dmg) < 220) and not v.lastPhase then
			v.lastPhase = true
			playMusic("mithalaanger")
			fade2(1, 0, 1, 1, 1)
			fade2(0, 0.5, 1, 1, 1)
			
			if entity_isState(v.mom, STATE_WEAK) then
				entity_setStateTime(v.mom, 4)
			end
		end
		if ((entity_getHealth(me) - dmg) < 100) and not v.almostDone then
			v.almostDone = true
			playMusic("mithalapeace")
			fade2(1, 0, 1, 1, 1)
			fade2(0, 0.5, 1, 1, 1)
		end
		return true
	end
	

	
	playNoEffect()
	return false
end

