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
-- N A U T I L U S  P R I M E!! 
-- ================================================================================================

local STATE_ATTACKPREP		= 1000
local STATE_ATTACK			= 1001
local STATE_STARTDELAY		= 1002
local STATE_GIVEBIRTH		= 1003


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.lungeDelay = 0
v.fireDelay = 0

v.tentacles = 0
v.eye = 0
v.shell = 0

v.bigFireDelay = 3
v.shotsFired = 0
v.startx, v.starty = 0,0
v.leaveArea = 0
v.leaveDelay = 0
v.birthDelay = 2

v.beserk = false

v.spawned = nil
v.n = 0
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	v.spawned = {}

	-- health 40
	setupBasicEntity(
	me,
	"",						-- texture
	40,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	180,							-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,						-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	6000,							-- updateCull -1: disabled, default: 4000
	1
	)
	
	v.startx = entity_x(me)
	v.starty = entity_y(me)
	
	entity_setCull(me, false)
	entity_initSkeletal(me, "NautilusPrime")
	
	entity_animate(me, "idle", LOOP_INF)
	
	entity_setDeathParticleEffect(me, "NautilusPrimeExplode")
	
	entity_setDropChance(me, 75, 2)
	
	entity_generateCollisionMask(me)
	--entity_setDamageTarget(me, DT_AVATAR_SHOCK, false)
	v.tentacles = entity_getBoneByName(me, "Tentacles")
	v.eye = entity_getBoneByName(me, "Eye")
	v.shell = entity_getBoneByName(me, "Shell")
	bone_setSegs(v.tentacles, 32, 32, 0.1, 0.1, 0.01, 0.1, 6, 1)
	
	v.lungeDelay = 1.0				-- prevent the nautilus from attacking right away
	v.leaveArea = getNode("NAUTILUSPRIME_LEAVEAREA")
	
	bone_alpha(v.eye, 0)
	entity_setTargetPriority(me, 1)
	
	entity_setTargetRange(me, 300)
	
	entity_setBounceType(me, BOUNCE_REAL)
	entity_setDeathScene(me, true)
	
	loadSound("NautilusPrime")
	loadSound("BossDieSmall")
	loadSound("BossDieBig")
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	v.n = getNaija()
end

local function wakeUp(me)
	overrideZoom(0.5, 1)
	playMusic("MiniBoss")
	v.leaveDelay = 4
	bone_alpha(v.eye, 1, 2)
	entity_setState(me, STATE_STARTDELAY, 1.5)
	entity_sound(me, "NautilusPrime", 800)
	emote(EMOTE_NAIJAUGH)
end

v.seen = false
function update(me, dt)
	entity_handleShotCollisionsSkeletal(me)

	--[[
	if not v.seen and entity_isEntityInRange(me, getNaija(), 600) then
		emote(EMOTE_NAIJAWOW)
		v.seen = true
	end
	]]--
	
	if entity_getHealth(me) < 15 and not v.beserk then
		v.beserk = true
		bone_setColor(v.shell, 1, 0.5, 0.5, 0.5)
	end
	if entity_hasTarget(me) then
		v.n = getNaija()
		if entity_touchAvatarDamage(me, 200, 1, 800) then
			if not entity_isState(v.n, STATE_PUSH) then
				local x, y = entity_getVectorToEntity(me, v.n)
				x, y = vector_setLength(x, y, 1000)
				entity_push(getNaija(), x, y, 0.5)
			end
		end
	end

	if entity_getState(me)==STATE_IDLE then
		if not entity_hasTarget(me) then
			entity_findTarget(me, 400)
			if entity_hasTarget(me) then
				wakeUp(me)
			end
		else			
			if v.leaveDelay > 0 then v.leaveDelay = v.leaveDelay - dt if v.leaveDelay < 0 then v.leaveDelay = 0 end end
			if v.leaveDelay== 0 and not node_isEntityIn(v.leaveArea, getNaija()) then
				updateMusic()
				overrideZoom(0, 1)
				bone_alpha(v.eye, 0)
				entity_setPosition(me, node_x(v.leaveArea), node_y(v.leaveArea), 2)
				entity_setTarget(me, 0)
				entity_rotate(me, 0, 10)
				entity_clearVel(me)
				entity_heal(me, 10)
				debugLog("nautilusPrime heals 10")
				return
			end
			
			if v.bigFireDelay > 0 then v.bigFireDelay = v.bigFireDelay - dt if v.bigFireDelay < 0 then v.bigFireDelay = 0 v.shotsFired = 0 v.fireDelay = 0 end end
			if v.bigFireDelay == 0 then
				if v.fireDelay > 0 then v.fireDelay = v.fireDelay - dt if v.fireDelay < 0 then v.fireDelay = 0 end end
				
				if v.fireDelay == 0 then
					local firex, firey = bone_getWorldPosition(v.tentacles)
					local velx, vely = firex-entity_x(me), firey-entity_y(me)
					local offx, offy = 0,0
					
					local s = 0
					if not v.beserk then
						s = createShot("NautilusPrimeAngry", me, entity_getTarget(me), firex, firey)
						v.fireDelay = 0.3
					else
						s = createShot("NautilusPrimeNormal", me, entity_getTarget(me), firex, firey)
						v.fireDelay = 0.1
					end
					shot_setAimVector(s, velx, vely)
					v.shotsFired = v.shotsFired + 1
				end
				local maxShots = 3
				if v.beserk then
					maxShots = 14
				end
				if v.shotsFired >= maxShots then
					v.bigFireDelay = 4
					v.shotsFired = 0
				end
			else
				if v.lungeDelay > 0 then v.lungeDelay = v.lungeDelay - dt if v.lungeDelay < 0 then v.lungeDelay = 0 end end					
			end
			
			if entity_isTargetInRange(me, 2000) then
				if entity_isTargetInRange(me, 200) then
					entity_moveTowardsTarget(me, dt, -500)
				else					
					entity_moveTowardsTarget(me, dt, 1000)
				end
			end
			
			local dist = 500
			if v.beserk then
				dist = 600
			end
			if entity_isTargetInRange(me, dist) then
				if math.random(100) < 40 and v.lungeDelay == 0 and not(v.bigFireDelay == 0) then
					entity_setState(me, STATE_ATTACKPREP, 0.5)
				end
			else
				if v.birthDelay > 0 then
					v.birthDelay = v.birthDelay - dt
					if v.birthDelay < 0 then
						v.birthDelay = 0
						if node_getNumEntitiesIn(v.leaveArea, "Nautilus") < 12 then
							entity_setState(me, STATE_GIVEBIRTH, 3)
						end
						v.birthDelay = 5
					end
				end
			end
			
			entity_doEntityAvoidance(me, dt, 128, 0.5);
			entity_doCollisionAvoidance(me, dt, 15, 0.1);
		end
	end
	entity_updateMovement(me, dt)
	entity_clearTargetPoints(me)
	entity_addTargetPoint(me, bone_getWorldPosition(v.tentacles))
	--entity_setEnergyShotTargetPosition(me, bone_getWorldPosition(v.tentacles))
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_animate(me, "idle", LOOP_INF)
		if v.beserk then
			entity_setMaxSpeed(me, 600)
		else
			if entity_getHealth(me) < 20 then
				entity_setMaxSpeed(me, 400)
			else
				entity_setMaxSpeed(me, 200)
			end
		end
	elseif entity_getState(me)==STATE_ATTACKPREP then		
		entity_setMaxSpeed(me, 0)
		entity_doGlint(me, "Glint", BLEND_ADD)
	elseif entity_isState(me, STATE_STARTDELAY) then
	elseif entity_isState(me, STATE_GIVEBIRTH) then
		entity_animate(me, "birth", LOOP_INF)
		entity_rotate(0, 2)
		debugLog("giving birth!")
		bone_scale(v.eye, 1, 0.7, 0.6)
		entity_offset(me, -20, 0, 1.0, LOOP_INF, 1)
	elseif entity_isState(me, STATE_DEATHSCENE) then
	--[[
		n = getNaija()
		entity_clearVel(v.n)
		entity_idle(v.n)
		entity_offset(me, 5, 0, 0.3, -1, 1)
		clearShots()
		entity_setInvincible(v.n, true)
		cam_toEntity(me)
		entity_setStateTime(me,4)
	]]--
		clearShots()
		entity_stopInterpolating(me)
		entity_setStateTime(me, 99)
		fadeOutMusic(6)
		entity_idle(v.n)
		entity_setInvincible(v.n, true)
		cam_toEntity(me)
		entity_offset(me, 0, 0)
		entity_offset(me, 10, 0, 0.1, -1, 1)
		local e = getFirstEntity()
		while e ~= 0 do
			if node_isEntityIn(v.leaveArea, e) and entity_isName(e, "nautilus") then
				entity_damage(e, me, 99)
				watch(0.2)
			end
			e = getNextEntity()
		end
		watch(1)
		playSfx("BossDieSmall")
		spawnParticleEffect("TinyRedExplode", entity_x(me), entity_y(me))
		fade(1, 0.2, 1, 1, 1)
		watch(0.2)
		fade(0, 0.5, 1, 1, 1)
		watch(0.5)

		watch(1)
		playSfx("BossDieSmall")
		spawnParticleEffect("TinyRedExplode", entity_x(me), entity_y(me))
		fade(1, 0.2, 1, 1, 1)
		watch(0.2)
		fade(0, 0.5, 1, 1, 1)
		watch(0.5)
		playSfx("BossDieSmall")
		spawnParticleEffect("TinyRedExplode", entity_x(me), entity_y(me))
		fade(1, 0.2, 1, 1, 1)
		watch(0.2)
		fade(0, 0.5, 1, 1, 1)
		watch(0.5)
		entity_offset(me, 0, 0)
		entity_offset(me, 20, 0, 0.05, -1, 1)
		playSfx("BossDieBig")
		spawnParticleEffect("TinyRedExplode", entity_x(me), entity_y(me))
		fade(1, 1, 1, 1, 1)
		watch(1.2)
		fade(0, 0.5, 1, 1, 1)
		

		
		cam_toEntity(v.n)
		entity_setInvincible(v.n, false)
		
		pickupGem("Boss-Nautilus")
		
		overrideZoom(0, 1)
		entity_setStateTime(me, 0.1)
		entity_setState(me, STATE_DEAD, -1, 1)
		
	elseif entity_isState(me, STATE_DEAD) then
		v.n = getNaija()
		overrideZoom(0,1)
		updateMusic()
		cam_toEntity(v.n)
		entity_setInvincible(v.n, false)
	elseif entity_getState(me)==STATE_ATTACK then
		v.lungeDelay = 2.0
		if v.beserk then
			entity_setMaxSpeed(me, 1000)
		else
			entity_setMaxSpeed(me, 1200)
		end
		entity_moveTowardsTarget(me, 1000, 1)
	end
end

local function spawnNautilus(me, x, y)
	local ent = createEntity("Nautilus", "", entity_x(me)+x, entity_y(me)+y)
	entity_scale(ent, 0, 0)
	entity_scale(ent, 1, 1, 2.5)
end

function exitState(me)
	if entity_getState(me)==STATE_ATTACKPREP then
		if not v.beserk then
			entity_setState(me, STATE_ATTACK, 2.5)
		else
			entity_setState(me, STATE_ATTACK, 3)
		end
	elseif entity_isState(me, STATE_GIVEBIRTH) then	
		local out = 100
		spawnNautilus(me, -out, 0)
		spawnNautilus(me, out, 0)
		spawnNautilus(me, 0, -out)
		spawnNautilus(me, 0, out)
		

		bone_scale(v.eye, 1, 1, 1)
		entity_offset(me, -5, 0, 0.5, -1, 1)
		v.birthDelay = 10 + math.random(5)
		entity_rotate(me, 360 + entity_getRotation(me), 4, LOOP_INF)
		entity_setState(me, STATE_IDLE)		
	elseif entity_getState(me)==STATE_ATTACK then
		--entity_disableMotionBlur(me)
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_STARTDELAY) then
		v.lungeDelay = 0
		entity_setState(me, STATE_IDLE)
		--entity_rotate(me, 0)
		entity_rotate(me, 360 + entity_getRotation(me), 4, LOOP_INF)
	end
end

function hitSurface(me)
	if entity_isState(me, STATE_ATTACK) then
		entity_sound(me, "BigRockHit", 900+math.random(200))
		local cx, cy = getLastCollidePosition()
		spawnParticleEffect("Dirt", cx, cy)
		shakeCamera(5, 0.5)
		if entity_isEntityInRange(me, getNaija(), 400) then
			avatar_fallOffWall()
		end
		
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_CRUSH then
		return true
	end
	if bone ~= 0 and bone_isName(bone, "Tentacles") then
		if not entity_hasTarget(me) then
			entity_findTarget(me, 2000)
			if entity_hasTarget(me) then
				wakeUp(me)
			end
		end
		if entity_getHealth(me)-dmg <= 0 then
			entity_sound(me, "NautilusPrime", 500)
		else
			entity_sound(me, "NautilusPrime", 1100+math.random(100))
		end
		return true
	end
	playNoEffect()
	return false
end
