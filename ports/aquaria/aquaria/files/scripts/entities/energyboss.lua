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
-- Energy Boss
-- ================================================================================================

local STATE_MOVING				= 1001
local STATE_MOVEBACK			= 1002
local STATE_SHOCKED				= 1003
local STATE_FIRE				= 1004
local STATE_HITBARRIER			= 1005
local STATE_MOVEBACKFROMBARRIER 	= 1006
local STATE_COLLAPSE			= 1007
local STATE_COLLAPSED			= 1100

local ATTACK_UP					= 1
local ATTACK_DOWN				= 2
local ATTACK_BITE				= 3

v.attacks = 0

v.attack = 0
v.awoken = false
v.attackDelay = 0
v.naija = 0

v.maxMove = 0
v.maxMove2 = 0
v.minMove = 0
v.pushBackHits = 0
v.maxPushBackHits = 6
v.moveDelay = 0
v.fireDelay = 0
v.fireBit = 0
v.shotsFired = 0
v.barrier = 0
v.maxHits = 3
v.hits = v.maxHits
v.endTextDelay = 0
v.playedMusic = false
v.dead = false

v.orb = 0

v.bone_jaw = 0
v.bone_claw = 0
v.bone_head = 0
v.bone_body = 0

function damage(me, attacker, bone, damageType, dmg)
	bone_damageFlash(bone, 1)
	if entity_x(me) > node_x(v.minMove)+50 and not entity_isState(me, STATE_MOVEBACK) and not entity_isState(me, STATE_HITBARRIER) and not entity_isState(me, STATE_MOVEBACKFROMBARRIER) and not entity_isState(me, STATE_COLLAPSE) then
		v.pushBackHits = v.pushBackHits + dmg
		if v.pushBackHits >= v.maxPushBackHits then
			v.pushBackHits = 0
			entity_setState(me, STATE_MOVEBACK)
		end
	end
	return false
end

function init(me)	
	setupBasicEntity(
	me,
	"",								-- texture
	30,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	0,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	6000,							-- updateCull -1: disabled, default: 4000
	0
	)
	entity_initSkeletal(me, "EnergyBoss")
	entity_setState(me, STATE_IDLE)
	entity_setCull(me, false)
	
	entity_setName(me, "EnergyBoss")
	
	--entity_flipHorizontal(me)
		
	entity_scale(me, 1.5, 1.5)
	
	entity_setWeight(me, 800)
	
	entity_setMaxSpeed(me, 2000)
	
	entity_generateCollisionMask(me)
	
	v.bone_jaw = entity_getBoneByName(me, "Jaw")
	v.bone_claw = entity_getBoneByName(me, "Claw")
	v.bone_head = entity_getBoneByName(me, "Head")
	v.bone_body = entity_getBoneByName(me, "Body")
	
	v.maxMove = getNode("ENERGYBOSSMAXMOVE")
	v.maxMove2 = getNode("ENERGYBOSSMAXMOVE2")
	v.minMove = getNode("ENERGYBOSSMINMOVE")
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	
	
	v.naija = getNaija()
	
	loadSound("EnergyBoss-Attack")
	loadSound("EnergyBoss-Die")
	loadSound("EnergyBoss-Hurt")
	loadSound("BossDieSmall")
end

function postInit(me)
	if not entity_isState(me, STATE_COLLAPSE) then
		if getFlag(FLAG_ENERGYBOSSDEAD)>0 and not entity_isState(me, STATE_COLLAPSED) then
			entity_setPosition(me, node_x(v.maxMove2), entity_y(me))
			entity_setState(me, STATE_COLLAPSED)
			v.dead = true
			return
		end
	end

	
	v.orb = getEntityByID(4)
	v.holder = getEntityByID(3)
	v.barrier = getEntityByID(5)
end

function update(me, dt)
	--[[
	if entity_isState(me, STATE_COLLAPSED) then
		if getFlag(FLAG_ENERGYBOSSDEAD)>0 then
			fadeOutMusic(0.5)
		end
	end
	]]--
	if entity_isState(me, STATE_COLLAPSE) then
		if v.endTextDelay > 0 then
			v.endTextDelay = v.endTextDelay - dt
			if v.endTextDelay < 0 then
				v.endTextDelay = 0
				
				cam_toEntity(v.naija)
				changeForm(FORM_NORMAL)
				
				setInvincible(true)
				
				entity_idle(v.naija)
				entity_animate(v.naija, "agony", -1)
				entity_flipToEntity(v.naija, me)
				--voiceOnce("Naija_EnergyBossOver")
				voice("Naija_Vision_EnergyBoss1")
				--entity_idle(v.naija)
				entity_idle(v.naija)
				entity_animate(v.naija, "agony", -1)
				fade2(0.5, 8, 1, 1, 1)
				watchForVoice()
				fade2(1, 1, 1, 1, 1)
				watch(1)
				
				local collectibleNode = getNode("COLLECTIBLE")
				local ent = createEntity("CollectibleEnergyBoss", "", node_x(collectibleNode), node_y(collectibleNode))
				entity_alpha(ent, 0)
				entity_alpha(ent, 1, 2)
				watch(0.5)
				
				setInvincible(false)
				
				if entity_getHealth(v.naija) < 1 then
					entity_heal(v.naija, 1)
				end
				
				loadMap("EnergyTempleVision")
				
				--entity_idle(v.naija)
				--watch(6.5)
				--[[
				showImage("Visions/EnergyBoss/00")
				voice("Naija_Vision_EnergyBoss2")
				watchForVoice()
				entity_idle(v.naija)
				hideImage()
				watch(1)
				voice("Naija_Vision_EnergyBoss3")
				]]--

			end
		end
		return
	end
	if entity_isState(me, STATE_COLLAPSED) then
		return
	end
	if not v.awoken and not v.playedMusic and getFlag(FLAG_ENERGYBOSSDEAD)==0 then
		if not isFlag(FLAG_OMPO, 4) then 
			if entity_isEntityInRange(me, v.naija, 1220) then
				emote(EMOTE_NAIJAUGH)
				v.playedMusic = true
				playMusic("BigBoss")
				--setNaijaHeadTexture("shock", 4)
				entity_setState(me, STATE_INTRO)
			end
		end
	end
	
	if not v.awoken then return end
	

	if entity_isState(me, STATE_COLLAPSED) then
		return
	end

	
	--[[
	if v.barrier == 0 then
		v.barrier = getEntityByID(5)
	end
	]]--
	
	local bone = entity_collideSkeletalVsCircle(me, getNaija())
	if bone ~= 0 or entity_x(v.naija) < entity_x(me) then
		entity_damage(getNaija(), me, 1)
		if entity_y(v.naija) > entity_y(me)+50 then
			entity_push(getNaija(), 1200, -600, 0.5)
		elseif entity_y(v.naija) < entity_y(me) then
			entity_push(getNaija(), 1200, 600, 0.5)
		else
			entity_push(getNaija(), 1200, 0, 0.5)
		end
	end
		
	if entity_isState(me, STATE_ATTACK) or entity_isState(me, STATE_INTRO) then
		if not entity_isAnimating(me) then
			if entity_isState(me, STATE_ATTACK) then
				v.attacks = v.attacks + 1 
				if v.attacks >= 1 then
					v.attacks = 0
					entity_setState(me, STATE_MOVING)
				else
					entity_setState(me, STATE_IDLE)
				end
			else
				entity_setState(me, STATE_IDLE)
			end
		end
	end
	
	--[[
	if entity_isState(me, STATE_HITBARRIER) and not entity_isAnimating(me) then
		entity_setState(me, STATE_MOVEBACKFROMBARRIER)
	end
	]]--


	
	if not entity_isState(me, STATE_MOVEBACK) and not entity_isState(me, STATE_MOVEBACKFROMBARRIER) then
		if entity_x(v.orb) < entity_x(v.barrier) then
			if v.moveDelay > 0 then
				v.moveDelay = v.moveDelay - dt
				if v.moveDelay < 0 then
					v.moveDelay = 0
				end
			end
		end
	end

	if v.barrier ~= 0 then
		--debugLog("ENERGYBOSS: has Barrier")
		if entity_isState(v.barrier, STATE_PULSE) then
			--debugLog("ENERGYBOSS: barrier pulse")
			if not entity_isState(me, STATE_HITBARRIER) and not entity_isState(me, STATE_MOVEBACKFROMBARRIER) then			
				local lineBone = entity_collideSkeletalVsLine(me, entity_x(v.barrier), entity_y(v.barrier)+500, entity_x(v.barrier), entity_y(v.barrier)-500, 8)
				if lineBone ~= 0 then
					--debugLog("ENERGYBOSS: hit barrier!")
					local bx,by = bone_getPosition(lineBone)
					spawnParticleEffect("HitEnergyBarrierBig", entity_x(v.barrier), by)
					bone_damageFlash(v.bone_head)
					bone_damageFlash(v.bone_body)
					v.hits = v.hits - 1
					if v.hits <= 0 then
						entity_setState(me, STATE_COLLAPSE)						
					else
						entity_setState(me, STATE_HITBARRIER, 1)
					end
				end
			end
		else
			--debugLog("ENERGYBOSS: barrier off")
		end
	else
		--debugLog("ENERGYBOSS: Did not find barrier")
	end
	
	if entity_isState(me, STATE_FIRE) then
		v.fireBit = v.fireBit - dt
		if v.fireBit < 0 then
			entity_setTarget(me, v.naija)
			local offx, offy = 0
			while v.shotsFired < 3 do
				local velx, vely = 0, 0
				if v.shotsFired == 3 then
					velx = 100
					vely = 50
				elseif v.shotsFired == 0 then
					velx = 100
					vely = 25
				elseif v.shotsFired == 1 then
					velx = 100
					vely = 0
				elseif v.shotsFired == 2 then
					velx = 100
					vely = -25
				end	
				--entity_fireAtTarget(me, "Purple", 1, 500, 100, 0, 0, offx, offy, velx, vely)
				local s = createShot("EnergyBoss", me, entity_getTarget(me), entity_getPosition(me))
				shot_setAimVector(s, velx, vely)
				
				v.shotsFired = v.shotsFired + 1
			end
			entity_setState(me, STATE_IDLE)
		end
	end
	
	if entity_isState(me, STATE_IDLE) then
		if v.moveDelay <= 0 and entity_x(me) < node_x(v.maxMove)
		and entity_x(v.naija) < entity_x(me)+1200 then
			entity_setState(me, STATE_MOVING)
		else
			if v.awoken then
				v.fireDelay = v.fireDelay - dt
				if v.fireDelay <= 0 then
					v.fireDelay = 0
					entity_setState(me, STATE_FIRE)
				end
			end
			
			if entity_isState(me, STATE_IDLE) then
				v.attackDelay = v.attackDelay - dt
				if v.attackDelay <= 0 and entity_x(v.naija) < entity_x(me)+800 then
					v.attackDelay = 1
					entity_setState(me, STATE_ATTACK)
				end
			end
		end
	end
	if entity_isState(me, STATE_MOVING) and entity_x(me) >= node_x(v.maxMove) then
		if entity_isInterpolating(me) then
			entity_animate(me, "idle")
		end
		entity_stopInterpolating(me)
		entity_setPosition(me, node_x(v.maxMove), entity_y(me))
	end
	if (entity_isState(me, STATE_MOVEBACK) or entity_isState(me, STATE_MOVEBACKFROMBARRIER)) and entity_x(me) <= node_x(v.minMove) then
		entity_stopInterpolating(me)
		entity_setPosition(me, node_x(v.minMove), entity_y(me))
	end
	if entity_isState(me, STATE_MOVING) or entity_isState(me, STATE_MOVEBACK) or entity_isState(me, STATE_MOVEBACKFROMBARRIER) then
		if not entity_isInterpolating(me) then
			entity_setState(me, STATE_IDLE)
		end
	end
	entity_handleShotCollisionsSkeletal(me)	
	entity_clearTargetPoints(me)
	entity_addTargetPoint(me, bone_getWorldPosition(v.bone_head))
	if entity_isState(me, STATE_ATTACK) then
		entity_setLookAtPoint(me, bone_getWorldPosition(v.bone_claw))
		entity_setNaijaReaction(me, "shock")
	else
		entity_setLookAtPoint(me, bone_getWorldPosition(v.bone_jaw))
		entity_setNaijaReaction(me, "")
	end
	--entity_setEnergyShotTargetPosition(me, bone_getWorldPosition(v.bone_head))
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_stopInterpolating(me)
		entity_animate(me, "idle", LOOP_INF)
	elseif entity_isState(me, STATE_ATTACK) then
		playSfx("EnergyBoss-Attack", (900+math.random(200)) / 1000)
		local x, y = bone_getPosition(v.bone_jaw)
		if entity_isPositionInRange(v.naija, x, y, 600)
		and entity_y(v.naija) < y+64
		and entity_y(v.naija) > y-64
		then
			entity_animate(me, "bite")
			v.attack = ATTACK_BITE
		else
			if entity_y(v.naija) < entity_y(me)-200 then
				entity_animate(me, "attackUp")
				v.attack = ATTACK_UP
			else
				entity_animate(me, "lungeBite")
				v.attack = ATTACK_DOWN
			end
		end
	elseif entity_isState(me, STATE_FIRE) then
		v.shotsFired = 0
		entity_animate(me, "firing")
		v.fireDelay = 4
	elseif entity_isState(me, STATE_MOVING) then
		if v.hits <= 1 then
			v.maxMove = v.maxMove2
		end	
		entity_animate(me, "moveForward", LOOP_INF)
		if entity_x(v.orb) > entity_x(v.barrier) then
			entity_setPosition(me, entity_x(me)+(800/2), entity_y(me), 3.5/2)
		else
			entity_setPosition(me, entity_x(me)+800, entity_y(me), 3.5)
		end
	elseif entity_isState(me, STATE_MOVEBACK) then
		entity_animate(me, "moveBackward", LOOP_INF)
		
		if entity_x(v.orb) > entity_x(v.barrier) then
			v.moveDelay = 999
		else
			v.moveDelay = v.moveDelay + 10
		end
		v.attackDelay = 0
		v.fireDelay = 0
		playSfx("EnergyBoss-Hurt", (900+math.random(200)) / 1000)
		entity_animate(me, "hurt")
		entity_setPosition(me, entity_x(me)-500, entity_y(me), 1.6)
	elseif entity_isState(me, STATE_HITBARRIER) then
		entity_stopInterpolating(me)
		playSfx("EnergyBoss-Die", (1100+math.random(200)) / 1000)
		entity_animate(me, "hitBarrier")	
		
		entity_spawnParticlesFromCollisionMask(me, "energyboss-hit", 4)
	elseif entity_isState(me, STATE_MOVEBACKFROMBARRIER) then
		--entity_animate(me, "idle", LOOP_INF)
		--entity_setPosition(me, entity_x(me)-(1500*0.80), entity_y(me), 2)
		local nodeName = string.format("bossbackloc%d", v.hits)
		debugLog(string.format("nodeName: %s", nodeName))
		local backNode = getNode(nodeName)
		entity_setPosition(me, node_x(backNode), entity_y(me), -800)
	elseif entity_isState(me, STATE_COLLAPSE) then
		clearShots()
		playSfx("EnergyBoss-Die")
		setFlag(FLAG_ENERGYBOSSDEAD, 1)	
		entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
		entity_setDamageTarget(me, DT_AVATAR_SHOCK, false)	
		v.endTextDelay = 6.5
		
		entity_spawnParticlesFromCollisionMask(me, "energyboss-hit", 4)
		
		
		fadeOutMusic(2)
		
		entity_animate(me, "die")
		cam_toEntity(me)
		disableInput()
		--[[
		cam_toEntity(me)		
		watch(4)
		voiceOnce("Naija_EnergyBossOver")
		cam_toEntity(getNaija())
		]]--
	elseif entity_isState(me, STATE_COLLAPSED) then
		v.orb = getEntityByID(4)
		v.holder = getEntityByID(3)
		if v.orb and v.holder then
			entity_setPosition(v.orb, entity_x(v.holder), entity_y(v.holder))
		end
		local collectibleNode = getNode("COLLECTIBLE")
		createEntity("CollectibleEnergyBoss", "", node_x(collectibleNode), node_y(collectibleNode))
		--debugLog("animating dead")
		entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
		entity_setDamageTarget(me, DT_AVATAR_SHOCK, false)
		entity_animate(me, "dead")
		
		--if entity_isFlag(me, 0) then
		
		-- you can't beat the game without dual form
		-- and we don't want to stop the music when we're panning near the boss at the end of the game
		-- therefore: DO THIS:
		if not hasSong(SONG_DUALFORM) then
			fadeOutMusic(0.1)
		end
			--entity_setFlag(me, 1)
		--end
	elseif entity_isState(me, STATE_INTRO) then
		v.awoken = true
		playSfx("EnergyBoss-Die", 0.8)
		shakeCamera(10, 3)
		entity_stopInterpolating(me)
		entity_animate(me, "roar")
		overrideZoom(0.5, 1)
		
	elseif entity_isState(me, STATE_APPEAR) then
		entity_animate(me, "eatOmpo")
	end
end

function animationKey(me, key)
	if entity_isState(me, STATE_APPEAR) then
		if key == 5 then
			local x, y = bone_getWorldPosition(v.bone_claw)
			spawnParticleEffect("Dirt", x,y)
			playSfx("RockHit-Big")
		elseif key == 7 then
			playSfx("Bite")
		elseif key == 9 then
			playSfx("Bite")
		elseif key == 15 then
			local x, y = bone_getWorldPosition(v.bone_claw)
			spawnParticleEffect("Dirt", x,y)
			--playSfx("RockHit-Big")
		elseif key == 16 then
			playSfx("Gulp")
		elseif key == 17 then
			local x, y = bone_getWorldPosition(v.bone_claw)
			spawnParticleEffect("Dirt", x,y)
			playSfx("RockHit-Big")
		end
		
		return
	end
	if entity_isState(me, STATE_COLLAPSE) then
		if key == 9 then
			playSfx("BossDieSmall")
			fade2(0.5, 0, 1, 1, 1)
			fade2(0, 1, 1, 1, 1)
		end
		if key == 11 then
			playSfx("BossDieSmall")
			fade2(0.2, 0, 1, 1, 1)
			fade2(0, 1, 1, 1, 1)
			entity_spawnParticlesFromCollisionMask(me, "energyboss-hit", 4)
		end
	else
		if v.attack == ATTACK_DOWN then
			if entity_isState(me, STATE_ATTACK) and key == 4 then
				local x, y = bone_getWorldPosition(v.bone_claw)
				spawnParticleEffect("Dirt", x,y)
				playSfx("RockHit-Big")
				shakeCamera(15, 0.5)
			end
		elseif v.attack == ATTACK_UP then
			if entity_isState(me, STATE_ATTACK) and key == 4 then
				local x, y = bone_getWorldPosition(v.bone_claw)
				spawnParticleEffect("Dirt", x,y)
				playSfx("RockHit-Big")
				shakeCamera(15, 0.5)
			end	
		end
	end
end

function exitState(me)
	if entity_isState(me, STATE_HITBARRIER) then
		entity_setState(me, STATE_MOVEBACKFROMBARRIER)
	elseif entity_isState(me, STATE_MOVING) then
		v.moveDelay = 4
	end
end

function activate(me)
end

function hitSurface(me)
end

