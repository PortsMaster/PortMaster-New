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

local STATE_STEPFORE		= 1000
local STATE_STEPBACK		= 1001
local STATE_ATTACK1			= 1002
local STATE_ATTACK2			= 1003
local STATE_ATTACK3			= 1004
local STATE_BACKHANDATTACK	= 1005
local STATE_MOUTHATTACK		= 1006
local STATE_SPAWNNAIJA		= 1007

local STATE_SCENEGHOST		= 1010


v.maxLeft					= 0
v.maxRight				= 0



v.stepDelay = 0
v.attackDelay = 0

v.eye = 0
v.hand = 0
v.forearm = 0
v.socket = 0
v.neck = 0
v.backHand = 0
v.tongue = 0

v.li = 0

v.shieldHits = 3      --9
v.hits = 3 -- 3

v.camNode = 0
v.camBone = 0


v.chestMonster = 0
v.chestShield = 0
v.eyeCover = 0
v.eyeSocket = 0

v.eyeSpiral = 0

v.eyeCoverHits = 24

local PHASE_HASLI	= 0
local PHASE_FINAL	= 1

v.phase = PHASE_HASLI

v.attackPhase = 0

local function enterFinalPhase(me)
	debugLog("setting phase to final")
	
	playSfx("naijali1")
	
	setFlag(FLAG_LI, 100)
	entity_setState(v.li, STATE_IDLE, -1, true)
	v.phase = PHASE_FINAL
	
	v.chestMonster = createEntity("chestmonster", "", entity_x(me), entity_y(me))
	
	playSfx("licage-shatter")
	
	bone_alpha(v.chestShield, 0, 2)
	
	v.attackPhase = 0
end

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "CreatorForm6")	
	--entity_setAllDamageTargets(me, false)
	entity_setCull(me, false)
	
	entity_generateCollisionMask(me)	
	
	entity_setState(me, STATE_IDLE)
	entity_scale(me, 2, 2)
	
	v.eye = entity_getBoneByName(me, "Eye")
	v.hand = entity_getBoneByName(me, "Hand")
	v.forearm = entity_getBoneByName(me, "Forearm")
	v.socket = entity_getBoneByName(me, "Socket")
	v.neck = entity_getBoneByName(me, "Neck")
	
	
	v.chestShield = entity_getBoneByName(me, "chestshield")
	
	v.eyeSocket = entity_getBoneByName(me, "eyesocket")
	v.eyeCover = entity_getBoneByName(me, "eyecover")
	
	
	entity_setTargetRange(me, 2000)
	
	
	bone_setVisible(v.eyeSocket, 0)
	
	v.backHand = entity_getBoneByName(me, "BackHand")
	v.tongue = entity_getBoneByName(me, "tongue")
	
	bone_setAnimated(v.eye, ANIM_POS)
	
	v.camBone = v.eye
	
	v.li = getLi()
	
	esetv(me, EV_SOULSCREAMRADIUS, -1)
	
	setFlag(FLAG_LI, 200)
	
	loadSound("licage-crack1")
	loadSound("licage-crack2")
	loadSound("licage-shatter")
	
	loadSound("creatorform6-die3")
	
	loadSound("hellbeast-shot-skull")
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	local node = getNode("MAXLEFT")
	v.maxLeft = node_x(node)
	local node = getNode("MAXRIGHT")
	v.maxRight = node_x(node)
	
	v.camNode = getNode("CAM")
	
	
	
	if v.li == 0 then
		-- create li
		v.li = createEntity("Li")
		setLi(v.li)
	end
	
	entity_setState(v.li, STATE_TRAPPEDINCREATOR, -1, true)
end

v.pd = 0
function update(me, dt)
	if entity_isState(me, STATE_WAIT) then
		return
	end
	if entity_isState(me, STATE_TRANSITION) or entity_isState(me, STATE_SCENEGHOST) then
		local bx, by = bone_getWorldPosition(v.camBone)
		node_setPosition(v.camNode, bx, by)
		cam_toNode(v.camNode)
		v.pd = v.pd + dt
		if v.pd > 0.2 then
			spawnParticleEffect("TinyRedExplode", bx-500+math.random(1000), by-500 + math.random(1000))
			v.pd = 0
		end
		return 
	end
	
	entity_updateMovement(me, dt)
	
	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	
	if bone ~= 0 then
		--[[
		if avatar_isBursting() and bone ~= v.hand and bone ~= v.forearm and entity_setBoneLock(v.n, me, bone) then
		else
		]]--
			-- puuush
			--entity_addVel(v.n, -800, 0)
			local bx, by = bone_getWorldPosition(bone)
			local x, y = entity_getPosition(v.n)
			x = x - bx
			y = y - by
			x,y = vector_setLength(x, y, 2000)
			entity_clearVel(v.n)
			entity_addVel(v.n, x, y)
			
			x,y = vector_setLength(x, y, 8)
			entity_setPosition(v.n, entity_x(v.n) + x -20, entity_y(v.n) + y)
			
			--if bone == v.hand or bone == v.forearm then
			entity_damage(v.n, me, 1)
			avatar_fallOffWall()
			--end
			--entity_addVel(v.n, -400, 0)
		--end
	end
	
	overrideZoom(0.45)
	
	if entity_isState(me, STATE_IDLE) then
		v.stepDelay = v.stepDelay + dt
		if v.stepDelay > 2 then
			v.stepDelay = 0
			if entity_x(me) > v.maxLeft and chance(50) then
				entity_setState(me, STATE_STEPFORE)
			elseif entity_x(me) < v.maxRight then
				entity_setState(me, STATE_STEPBACK)
			end
		end
		
		if v.phase == PHASE_HASLI then
			v.attackDelay = v.attackDelay + dt
			if v.attackDelay > 4 then
				v.attackDelay = 0
				if v.attackPhase == 0 then
					entity_setState(me, STATE_BACKHANDATTACK)
				elseif v.attackPhase == 1 then
					entity_setState(me, STATE_SPAWNNAIJA)
				elseif v.attackPhase == 2 then
					entity_setState(me, STATE_MOUTHATTACK)
				end
				v.attackPhase = v.attackPhase + 1
				if v.attackPhase > 2 then
					v.attackPhase = 0
				end
			end
		end
		if v.phase == PHASE_FINAL then
			v.attackDelay = v.attackDelay + dt
			if v.attackDelay > 4 then
				v.attackDelay = 0
				if v.attackPhase == 0 then
					entity_setState(v.chestMonster, STATE_OPEN)
					v.attackDelay = -3
				elseif v.attackPhase == 1 then
					entity_setState(me, STATE_BACKHANDATTACK)
				elseif v.attackPhase == 2 then
					-- spawn aleph ???
				elseif v.attackPhase == 3 then
				end
				v.attackPhase = v.attackPhase + 1
				if v.attackPhase > 1 then
					v.attackPhase = 0
				end
			end
		end
	end
	
	local dist = 270
	local bx, by = bone_getWorldPosition(v.eye)
	if entity_y(v.n) > by + dist then
		bone_rotate(v.eye, -25, 0.5)
	elseif entity_y(v.n) < by - dist then
		bone_rotate(v.eye, 35, 0.5)
	else
		bone_rotate(v.eye, 0, 0.5)
	end
	
	if v.li ~= 0 and v.phase == PHASE_HASLI then
		entity_setPosition(v.li, bone_getWorldPosition(v.socket))
	end
	
	if v.phase == PHASE_FINAL then
		if v.chestMonster ~= 0 then
			entity_setPosition(v.chestMonster, bone_getWorldPosition(v.socket))
		end
	end
	
	if v.eyeSpiral ~= 0 then
		local bx,by = bone_getWorldPosition(v.eyeSocket)
		entity_setPosition(v.eyeSpiral, bx-64, by)
	end
	
	entity_clearTargetPoints(me)
	
	if v.phase == PHASE_HASLI then
		if bone_isVisible(v.eyeCover) then
			entity_addTargetPoint(me, bone_getWorldPosition(v.eyeCover))
		end
	end
end

v.stepTime = 2

local function flash()
end

v.incut = false

function enterState(me)
	if v.incut then return end
	
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_STEPFORE) then
		entity_setPosition(me, entity_x(me)-600, entity_y(me), v.stepTime, 0, 0, 0)
		entity_setStateTime(me, v.stepTime)
	elseif entity_isState(me, STATE_STEPBACK) then
		entity_setPosition(me, entity_x(me)+600, entity_y(me), v.stepTime, 0, 0, 0)
		entity_setStateTime(me, v.stepTime)
	elseif entity_isState(me, STATE_ATTACK1) then
		entity_setStateTime(me, entity_animate(me, "attack1"))
	elseif entity_isState(me, STATE_TRANSITION) then
		if v.chestMonster ~= 0 then
			entity_delete(v.chestMonster)
			v.chestMonster = 0
		end
		
		bone_setAnimated(v.eye, ANIM_ALL)
		v.incut = true
		

		--entity_setStateTime(me, entity_animate(me, "die"))
		--entity_setStateTime(me, 22)
		
		-- 22
		-- gets picked up by node FINALBOSSDEATH
		--[[
		flash() entity_animate(me, "die1", -1)
		watch(7)
		flash() entity_animate(me, "die2", -1)
		watch(5)
		flash() entity_animate(me, "die3", -1)
		watch(9)
		entity_setStateTime(me, 0.01)
		]]--
		v.incut = false
	elseif entity_isState(me, STATE_SCENEGHOST) then
		debugLog("ghost")
		v.incut = true

		v.incut = false
	elseif entity_isState(me, STATE_WAIT) then
		debugLog("wait")
	elseif entity_isState(me, STATE_BACKHANDATTACK) then
		entity_setStateTime(me, entity_animate(me, "backHandAttack"))
	elseif entity_isState(me, STATE_MOUTHATTACK) then
		entity_setStateTime(me, entity_animate(me, "mouthattack"))
	elseif entity_isState(me, STATE_SPAWNNAIJA) then
		entity_setStateTime(me, entity_animate(me,  "spawnthing"))
	end
end

function exitState(me)
	if entity_isState(me, STATE_STEPFORE) or entity_isState(me, STATE_STEPBACK) or entity_isState(me, STATE_ATTACK1) then
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_TRANSITION) then
		--entity_setState(me, STATE_SCENEGHOST)
	elseif entity_isState(me, STATE_SCENEGHOST) then
		disableInput()
		fade(1, 2, 0, 0, 0)
	elseif entity_isState(me, STATE_BACKHANDATTACK) then
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_MOUTHATTACK) then
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_SPAWNNAIJA) then
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	--[[
	if v.phase == PHASE_HASLI then
		if damageType == DT_ENEMY_CREATOR then
			debugLog("damage type is dt_enemy_creator")
			if bone == v.socket then
				v.shieldHits = v.shieldHits - dmg
				bone_damageFlash(bone)
				if v.shieldHits <= 0 then
					enterFinalPhase(me)
				end
			end
		end
	end
	]]--
	if damageType == DT_ENEMY_BEAM then
		return false
	end
	if bone == v.eyeCover then
		bone_damageFlash(v.eyeCover)
		v.eyeCoverHits = v.eyeCoverHits - dmg
		playSfx("licage-crack1")
		if v.eyeCoverHits <= 0 then
			bone_setVisible(v.eyeCover, 0)
			bone_setVisible(v.eyeSocket, 1)
			playSfx("licage-shatter")
			
			v.eyeSpiral = createEntity("eyespiral", "", bone_getWorldPosition(v.eyeSocket))
		end
	end
	
	if v.phase == PHASE_FINAL then
		if damageType == DT_AVATAR_DUALFORMNAIJA then
			v.hits = v.hits - 1
			for i = 0,10 do
				bone_damageFlash(entity_getBoneByIdx(me, i))
			end
			playSfx("creatorform6-die3")
			if v.hits <= 0 then
				entity_setState(me, STATE_TRANSITION)
			end
		end
	end

	return false
end

function animationKey(me, key)
	if entity_isState(me, STATE_BACKHANDATTACK) then
		if key == 4 or key == 5 or key == 6 or key == 7 or key == 8 then
			-- create entity
			debugLog("Creating entity")
			local bx, by = bone_getWorldPosition(v.backHand)
			local vx, vy = entity_getPosition(getNaija())
			vx = vx - bx
			vy = vy - by
			--local e = createEntity("cf6-shot", "", bx, by)
			local s = createShot("creatorform6-hand", me, getNaija(), bx, by)
			shot_setAimVector(s, vx, vy)
		end
	elseif entity_isState(me, STATE_MOUTHATTACK) then
		if key == 4 or key == 5 or key == 6 or key == 7 or key == 8 or key == 9 or key == 10 then
			local bx, by = bone_getWorldPosition(v.tongue)
			local vx, vy = entity_getPosition(getNaija())
			vx = vx - bx
			vy = vy - by
			
			local s = createShot("creatorform6-hand", me, getNaija(), bx, by)
			shot_setAimVector(s, vx, vy)
		end
	elseif entity_isState(me, STATE_SPAWNNAIJA) then
		if key == 5 then -- key == 3 or 
			local bx, by = bone_getWorldPosition(v.hand)
			spawnParticleEffect("tinyredexplode", bx, by)
			createEntity("mutantnaija", "", bx, by)
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

function msg(me, msg)
	if msg == "eye" then
		v.camBone = v.eye
	elseif msg == "neck" then
		v.camBone = v.neck
	end
	if msg == "eyedied" then
		enterFinalPhase(me)
	end
	if msg == "eyepopped" then
		fade2(1, 0, 1, 1, 1)
		fade2(0, 1, 1, 1, 1)
		playSfx("creatorform6-die3")
		v.eyeSpiral = 0
		setSceneColor(1, 0, 0, 0)
		setSceneColor(1, 1, 1, 4)
		entity_animate(me, "eyehurt", 0, 1)
	end
end

