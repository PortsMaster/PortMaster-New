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

v.bone_tongue = 0
v.bone_hand = 0
v.bone_head = 0
v.bone_body = 0
v.bone_upperLeg = 0
v.bone_tongue = 0
v.bone_jaw = 0
v.bone_target = 0

v.naijaPit = 0

v.inHand = false
v.node_right = 0
v.node_left = 0
v.node_hang = 0
v.node_middle = 0
v.node_check = 0
v.node_mermanSpawn = 0
v.node_nostomp = 0

v.handSpin = 0

v.sx = 0
v.sy = 0 

v.holding = 0

v.soundDelay = 0

v.skull = false

local STATE_ATTACK1 		= 1000
local STATE_ATTACK2 		= 1001
local STATE_ATTACK3 		= 1002
local STATE_HOLDING 		= 1003
local STATE_ATTACK4 		= 1004
local STATE_ACIDSPRAY 	= 1005
local STATE_PAIN 			= 1006
local STATE_DIE 			= 1007
local STATE_DONE 			= 1008
local STATE_MOVERIGHT	= 1009
local STATE_MOVELEFT	= 1010
local STATE_ATTACK5		= 1011
local STATE_TRANSFORM	= 1012
local STATE_CREATEMERMAN= 1013
-- yer done!

v.attacksToGo = 3

v.lastAcid = false

v.getHitDelay = 0

-- initial v.attackDelay value set below
v.attackDelay = 0


v.hurtDelay =0

v.hits = 0
v.maxHeadHits = 3
v.headHits = v.maxHeadHits
v.maxHandHits = 6
v.handHits = 0

v.minPullSpd = 100
v.maxPullSpd = 1800
v.pullSpdRate = 1000

v.grabPoint = 0

v.started = false

v.fireDelay = 0

v.n = 0

v.beam = 0
v.canMove = true

v.skullHits = 80
v.lessThan = v.skullHits*0.6
v.finalStage = false

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	90,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	0,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	3000,							-- updateCull -1: disabled, default: 4000
	0
	)
	
	entity_initSkeletal(me, "HellBeast")
	entity_generateCollisionMask(me)
	entity_scale(me, 2.0, 2.0)

	--entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
	entity_setCull(me, false)
	
	--entity_setState(me, STATE_IDLE)
	
	v.bone_tongue = entity_getBoneByName(me, "Tongue")
	v.bone_hand = entity_getBoneByName(me, "Hand")
	--bone_leftThumb = entity_getBoneByName(me, "LeftThumb")
	v.bone_head = entity_getBoneByName(me, "Head")
	v.bone_body = entity_getBoneByName(me, "Body")
	v.bone_upperLeg = entity_getBoneByName(me, "UpperLeg")
	v.bone_tongue = entity_getBoneByName(me, "Tongue")
	v.bone_jaw = entity_getBoneByName(me, "Jaw")
	
	v.bone_target = entity_getBoneByName(me, "Target")
	
	bone_setSegs(v.bone_tongue, 2, 12, 0.4, 0.3, -0.02, 0, 8, 0)
	
	v.node_left = entity_getNearestNode(me, "HELLBEAST_LEFT")
	v.node_right = entity_getNearestNode(me, "HELLBEAST_RIGHT")
	v.node_middle = entity_getNearestNode(me, "HELLBEAST_MIDDLE")
	v.node_hang = entity_getNearestNode(me, "HELLBEAST_HANG")
	
	v.node_nostomp = getNode("NOSTOMP")
	
	v.node_check = entity_getNearestNode(me, "HELLBEAST_CHECK")
	v.node_mermanSpawn = entity_getNearestNode(me, "MERMAN_SPAWN")
	
	v.grabPoint = entity_getBoneByName(me, "GrabPoint")
	bone_alpha(v.grabPoint, 0)
	
	
	v.naijaPit = getNode("NAIJAPIT")
	
	entity_setState(me, STATE_IDLE)
	
	--entity_setDamageTarget(me, DT_AVATAR_SHOCK, false)
	
	entity_setTargetPriority(me, 2)
	entity_setTargetRange(me, 1024)
	v.n = getNaija()
	
	v.hits = 3
	
	loadSound("HellBeast-Beam")
	loadSound("HellBeast-Die")
	loadSound("HellBeast-Idle")
	loadSound("HellBeast-Roar")
	loadSound("HellBeast-Stomp")
	loadSound("HellBeast-Suck")
	loadSound("hellbeast-skullhit")
	loadSound("merman-bloat-explode")
	loadSound("mia-appear")
	loadSound("BossDieBig")
	loadSound("BossDieSmall")
	loadSound("hellbeast-shot")
	loadSound("hellbeast-shot-skull")
	
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	if getFlag(FLAG_BOSS_MITHALA) > 0 then
		entity_setState(me, STATE_DONE)
		bone_setTexture(v.bone_head, "hellbeast/skull")
		bone_setTexture(v.bone_jaw, "hellbeast/skulljaw")
		bone_alpha(v.bone_tongue, 0)
		entity_animate(me, "done", -1, true)
		if entity_isFlag(me, 0) then
			voice("naija_song_beastform")
			setControlHint(getStringBank(38), 0, 0, 0, 10, "", SONG_BEASTFORM)
			entity_setFlag(me, 1)
		end
		entity_setAllDamageTargets(me, false)
		entity_setColor(me, 0.6, 0.2, 0.2)
	end
	v.sx = entity_x(me)
	v.sy = entity_y(me)
	
	-- cache
	createEntity("mermanthin", "", -100, -100)
	local e = createEntity("mermanthin", "", -100, -100)
	entity_setState(e, STATE_BLOATED)
end

function damage(me, attacker, bone, damageType, dmg)
--[[
	v.hits = v.hits + 1
	if v.hits > 5 then
		v.hits = 0
		if entity_isState(me, STATE_THREE) then
			entity_setState(me, STATE_TWO)
		else
			entity_setState(me, STATE_THREE)
		end
	end
	return false
	]]-- 

	if entity_isState(me, STATE_HOLDING) then
		v.handHits = v.handHits - dmg
		if v.handHits <= 0 then
			-- move to some hurt state instead
			v.inHand = false
			entity_setState(me, STATE_IDLE)
		end
	end	
	
	if v.skull then
		if bone == v.bone_head or bone == v.bone_jaw then
			debugLog("skull hit")
			bone_damageFlash(v.bone_head)
			bone_damageFlash(v.bone_jaw)
			bone_damageFlash(entity_getBoneByIdx(me, 0))
			bone_offset(v.bone_head, 0, 0)
			bone_offset(v.bone_head, 20, 0, 0.1, 1, 1)
			
			playSfx("hellbeast-skullhit")
			v.skullHits = v.skullHits - dmg
			if v.skullHits < v.lessThan and not v.finalStage then
				v.finalStage = true
				playMusicStraight("mithalapeace")
			end
			if v.skullHits <= 0 then
				entity_setState(me, STATE_DIE)
			end
			shakeCamera(2, 1)
		else
			playNoEffect()
		end
	else
		
		if not (entity_isState(me, STATE_MOVELEFT) or entity_isState(me, STATE_ATTACK4)) then
			if (damageType == DT_AVATAR_ENERGYBLAST or damageType == DT_AVATAR_SHOCK) and (bone == v.bone_head or bone == v.bone_jaw or bone == v.bone_tongue) then
				v.headHits = v.headHits - dmg
			end
		end
	end
	
	if not v.skull then
		bone_damageFlash(v.bone_head, 1)
		bone_damageFlash(v.bone_jaw, 1)
		--playNoEffect()
	end
	
	entity_heal(me, 999)

	
	-- for debug
	--[[
	if not entity_isState(me, STATE_DIE) then
		entity_setState(me, STATE_DIE)
	end
	]]--
	
	
	--bone_damageFlash(bone)
	return false
end

function animationKey(me, key)
	if entity_isState(me, STATE_PAIN) and key==3 then
		shakeCamera(10, 1.5)
	end
	if ((entity_isState(me, STATE_MOVERIGHT) or entity_isState(me, STATE_MOVELEFT)) and key == 2)
		or (entity_isState(me, STATE_ATTACK3) and key == 2)
		or ((entity_isState(me, STATE_MOVERIGHT) or entity_isState(me, STATE_MOVELEFT)) and key == 6)
		then
			playSfx("HellBeast-Stomp")
			shakeCamera(30, 0.5)
			if not v.skull then
				setSceneColor(0.7, 0.7, 0.7)
				setSceneColor(1, 1, 1, 0.5)
			end
	end
	if entity_isState(me, STATE_MOVERIGHT) or entity_isState(me, STATE_MOVELEFT) then
		if key == 0 or key == 2 or key == 3 or key == 6 or key == 7 then
			v.canMove = false
		else
			v.canMove = true
		end
	end
	if entity_isState(me, STATE_ACIDSPRAY) and key == 3 then
		--playSfx("HellBeast-Beam")
		local x, y = bone_getPosition(v.bone_tongue)
		--v.beam = createBeam(x, y, 90)
	end
	if entity_isState(me, STATE_CREATEMERMAN) then	
		v.lastAcid = false
		if key == 1 then
			local bx, by = bone_getWorldPosition(v.bone_tongue)
			spawnParticleEffect("mermanspawn", bx, by)
			playSfx("mia-appear")
		elseif key == 3 then
			local bx, by = bone_getWorldPosition(v.grabPoint)
			
			v.holding = createEntity("mermanthin", "", bx, by)
			
		elseif key == 4 then
			v.holding = 0
		end
	end
end

function update(me, dt)
	if not entity_isState(me, STATE_DONE) and getFlag(FLAG_BOSS_MITHALA) > 0 then
		return
	end
	if not(entity_isState(me, STATE_DONE) or entity_isState(me, STATE_DIE)) then
		if entity_isEntityInRange(me, v.n, 2848) then
			if not v.started then
				emote(EMOTE_NAIJAUGH)
				playMusic("Mithala")
				playSfx("HellBeast-Roar")
				v.started = true
				v.attackDelay = -2
				local nd = getNode("MERSPAWN")
				createEntity("mermanthin", "", node_x(nd), node_y(nd))
			end
			v.soundDelay = v.soundDelay - dt
			if v.soundDelay < 0 then
				entity_playSfx(me, "HellBeast-Idle")
				v.soundDelay = (math.random(100)/100.0)*1 + 0.5
			end
		end
	end
	entity_clearTargetPoints(me)
	entity_addTargetPoint(me, bone_getWorldPosition(v.bone_head))
	entity_addTargetPoint(me, bone_getWorldPosition(v.bone_jaw))
	
	
	--[[
	if isLeftMouse() then
		cutscene(me)
	end
	]]--
	--[[
	entity_addTargetPoint(me, bone_getWorldPosition(v.bone_body))
	entity_addTargetPoint(me, bone_getWorldPosition(v.bone_upperLeg))
	]]--
	if not entity_isState(me, STATE_DIE) and not entity_isState(me, STATE_DONE) then
		overrideZoom(0.3, 1)
		
		--[[
		if node_getNumEntitiesIn(v.node_check, "MermanThin")<=0 then
			createEntity("MermanThin", "", node_x(v.node_mermanSpawn), node_y(v.node_mermanSpawn))
		end
		]]--
	end
	entity_handleShotCollisionsSkeletal(me)	
	
	if entity_isState(me, STATE_IDLE) then
		if v.headHits <= 0 then
			v.headHits = v.maxHeadHits
			debugLog("HeadHits exceeded")
			
			if entity_x(me) < node_x(v.node_left)+100 then
				if node_getNumEntitiesIn(v.node_check, "MermanThin") > 0 then
					entity_setState(me, STATE_ATTACK4, -1, true)
				else
					entity_setState(me, STATE_MOVERIGHT)
				end
			else
				if node_getNumEntitiesIn(v.node_check, "MermanThin") <= 0 then
					entity_setState(me, STATE_MOVERIGHT)
				else
					entity_setState(me, STATE_MOVELEFT)
				end
			end
			return
		end	
		
		v.attackDelay = v.attackDelay + dt
		if v.attackDelay > 1.8 then
			v.attackDelay = (3-v.hits)*0.2
			local my_x = entity_x(me)
			local my_y = entity_y(me)
			
			if not v.skull then
				v.attacksToGo = v.attacksToGo - 1
				
				if node_getNumEntitiesIn(v.node_check, "MermanThin")<=0 then
					if v.attacksToGo <= 0 then
						v.attacksToGo = v.hits + 3
						entity_setState(me, STATE_CREATEMERMAN)
						return
					end
				else
					v.attacksToGo = 2
				end
			end
			
			if node_isEntityIn(v.naijaPit, v.n) then
				debugLog("in pit")
				if node_isEntityIn(v.node_nostomp, me) then
					debugLog("no stomp")
					v.lastAcid = false
					entity_setState(me, STATE_ATTACK5)
				else
					debugLog("not no stomp")
					if not v.lastAcid then
						if chance(50) then
							entity_setState(me, STATE_ACIDSPRAY)
							v.lastAcid = true
						else
							v.lastAcid = false
							entity_setState(me, STATE_MOVERIGHT)
						end
					else
						v.lastAcid = false
						entity_setState(me, STATE_MOVERIGHT)
					end
				end
			else
				if entity_y(v.n) < my_y+50 and entity_y(v.n) > my_y-200 and entity_x(v.n) < my_x+1024 then
					entity_setState(me, STATE_ATTACK2)
				elseif entity_y(v.n) >= my_y and entity_x(v.n) < my_x + 750 then
					if not node_isEntityIn(v.node_nostomp, me) then
						entity_setState(me, STATE_ATTACK3)
					else
						entity_setState(me, STATE_ATTACK2)
					end
				elseif entity_y(v.n) < my_y-200 then
					if entity_x(v.n) < entity_x(me)+ 300 then
						entity_setState(me, STATE_ATTACK1)
					else
						entity_setState(me, STATE_ACIDSPRAY)
					end
				--elseif entity_y(v.n) < my_y+800 then
				else

					if chance(55) then
						if my_x < node_x(v.node_right)-100 or v.lastAcid then
							v.lastAcid = false
							entity_setState(me, STATE_MOVERIGHT)
						else
							if node_isEntityIn(v.naijaPit, v.n) then
								entity_setState(me, STATE_ATTACK5)
								v.lastAcid = false
							else
								v.lastAcid = true
								entity_setState(me, STATE_ACIDSPRAY)
							end
						end
					else
						if not v.lastAcid then
							v.lastAcid = true
							entity_setState(me, STATE_ACIDSPRAY)
						else
							entity_setState(me, STATE_MOVERIGHT)
						end
					end
				end
			end
			
		end

	end
	
	if entity_isState(me, STATE_ATTACK4) then
		v.pullSpd = v.pullSpd + v.pullSpdRate * dt
		if v.pullSpd > v.maxPullSpd then
			v.pullSpd = v.maxPullSpd
		end
		local x, y = bone_getWorldPosition(v.bone_tongue)
		local radius = 1500
		local length = v.pullSpd
		entity_pullEntities(me, x, y, radius, length, dt)
		
		if v.getHitDelay > 0 then
			v.getHitDelay = v.getHitDelay - dt
		else
			--ent = entity_getNearestEntity(me, "MermanThin")
			local ent = getFirstEntity()
			while ent ~= 0 do
				if entity_getEntityType(ent)==ET_ENEMY or entity_getEntityType(ent)==ET_AVATAR then
					if entity_isPositionInRange(ent, x, y, 180) then
						-- chompy
						entity_stopPull(ent)						
						
						if entity_isState(ent, STATE_BLOATED) then
							v.attackDelay = 0
							spawnParticleEffect("mermanexplode", entity_x(ent), entity_y(ent))
							playSfx("merman-bloat-explode")
							entity_delete(ent)
							--debugLog(string.format("%s %d", "hits: ", v.hits))
							setSceneColor(0.7, 1, 0.5)
							setSceneColor(1, 1, 1, 1)
							v.hits = v.hits - 1
							if v.hits == 1 then
								playMusic("mithalaanger")
								entity_setColor(me, 1, 0.5, 0.5, 4)
							end
							v.getHitDelay = 3
							if v.hits <= 0 then
								--entity_delete(me)
								fade2(1, 0, 1, 1, 1)
								bone_setTexture(v.bone_head, "hellbeast/skull")
								bone_setTexture(v.bone_jaw, "hellbeast/skulljaw")
								bone_alpha(v.bone_tongue, 0)
								fade2(0, 0.5, 1, 1, 1)
								playSfx("mia-appear")
								entity_setState(me, STATE_TRANSFORM, -1, true)
								return
								--entity_setState(me, STATE_DIE)
							else
								entity_setState(me, STATE_PAIN)
							end
							bone_damageFlash(v.bone_head)
							bone_damageFlash(v.bone_jaw)
							bone_damageFlash(v.bone_body)
						elseif entity_isName(ent, "mermanthin") then
							entity_delete(ent)
						else
							if entity_getEntityType(ent) == ET_AVATAR then
								entity_damage(ent, me, 1)
							else
								entity_damage(ent, me, 999)
							end
						end
					end
				end
				ent = getNextEntity()
			end
		end
	end
	
	if entity_isState(me, STATE_ACIDSPRAY) then
		if v.beam ~= 0 then
			beam_setAngle(v.beam, bone_getWorldRotation(v.bone_tongue)+90)
			beam_setPosition(v.beam, bone_getWorldPosition(v.bone_tongue))
		end
		v.fireDelay = v.fireDelay + dt
		local amount = 0.5
		if v.skull then
			amount = 0.2
		end
		if v.fireDelay > amount then
			v.fireDelay = 0
			local x, y = bone_getWorldPosition(v.bone_tongue)
			local tx, ty = bone_getWorldPosition(v.bone_target)
			local vx = tx - x
			local vy = (ty - y)*1.5
			if v.skull then
				local dx = entity_x(v.n) - x
				local dy = entity_y(v.n) - y
				vx, vy = vector_normalize(vx, vy)
				dx, dy = vector_normalize(dx, dy)
				vx = dx
				vy = dy
			end
			if v.skull then
				playSfx("hellbeast-shot-skull")
				createShot(string.format("hellbeast-skull", 4-v.hits), me, v.n, x, y, vx, vy)
			else
				playSfx("hellbeast-shot")
				createShot(string.format("hellbeast%d", 4-v.hits), me, v.n, x, y, vx, vy)
			end
		end
	end
	--[[
	if entity_isState(me, STATE_ACIDSPRAY) then
		v.fireDelay = v.fireDelay - dt
		if v.fireDelay < 0 then
			x,y = bone_getWorldPosition(v.bone_tongue)
			entity_setTarget(me, v.n)
			entity_fireAtTarget(me, "Purple", 1, 1000, 100, 0, 0, offx, offy, 0, 0, x, y)
			v.fireDelay = v.fireDelay + 0.2
		end
	end
	]]--

	if v.hurtDelay > 0 then
		v.hurtDelay = v.hurtDelay - dt
	else
		if not v.inHand and
		not entity_isState(me, STATE_DONE) and not entity_isState(me, STATE_DIE)
		then
			local bone = entity_collideSkeletalVsCircle(me, v.n)
			if bone ~= 0 then
				if not entity_isState(me, STATE_IDLE) then
					if bone == v.bone_hand then
						if (entity_isState(me, STATE_ATTACK2) or entity_isState(me, STATE_ATTACK5)) then
							v.inHand = true
							avatar_fallOffWall()
							entity_setState(me, STATE_HOLDING)
							entity_animate(v.n, "trapped", -1, LAYER_OVERRIDE)
							v.handSpin = 4
							return
						end
					end
				end
				if entity_isState(me, STATE_ATTACK4) then
					entity_setState(me, STATE_IDLE)
				end
				if not v.inHand then
					if not entity_isState(me, STATE_PAIN) and not entity_isState(me, STATE_DIE) and not entity_isState(me, STATE_CREATEMERMAN)
					and not entity_isState(me, STATE_TRANSFORM) then
						entity_damage(v.n, me, 1)
					end
					entity_push(v.n, 1200, 0, 0)
				end
			end
			if entity_x(v.n) < entity_x(me) then
				entity_setPosition(v.n, entity_x(me) + 1, entity_y(v.n))
				if entity_velx(v.n) < 0 then
					local vx = entity_velx(v.n)
					local vy = entity_vely(v.n)
					if vx < 0 then
						vx = -vx
					end
					entity_clearVel(v.n)
					entity_addVel(v.n, vx, vy)
				end
			end
		end
	end

	
	--[[
	if entity_isState(me, STATE_TWO) then
		x,y = bone_getWorldPosition(v.bone_tongue)
		entity_velTowards(getNaija(), x, y, 1200*dt, 1000)
	end
	]]--

	if v.inHand then
		--debugLog(string.format("%s %d", "handHits: ", v.handHits))
		entity_setPosition(v.n, bone_getWorldPosition(v.grabPoint))
		entity_rotate(v.n, bone_getWorldRotation(v.grabPoint))
		entity_flipToEntity(v.n, me)
		v.hurtDelay = 1
		
		if avatar_isRolling() then
			v.handSpin = v.handSpin - dt
			
			if v.handSpin < 0 then
				v.handSpin = 0
				v.inHand = false
				entity_setState(me, STATE_IDLE)
			end
		end
		
		if entity_isState(me, STATE_IDLE) then
			v.inHand = false
			entity_idle(v.n)
		end
	end
	
	if v.holding ~= 0 then
		entity_setPosition(v.holding, bone_getWorldPosition(v.grabPoint))
		entity_rotate(v.n, bone_getWorldRotation(v.grabPoint))
	end
	
	local moveSpd = 500
	if v.canMove then
		if entity_isState(me, STATE_MOVERIGHT) then
			entity_setPosition(me, entity_x(me)+moveSpd*dt, entity_y(me))
		end
		if entity_isState(me, STATE_MOVELEFT) then
			entity_setPosition(me, entity_x(me)-moveSpd*1.3*dt, entity_y(me))
		end	
	end
	if entity_isState(me, STATE_ATTACK1) or entity_isState(me, STATE_ATTACK2) or entity_isState(me, STATE_ATTACK3) or entity_isState(me, STATE_HOLDING) or entity_isState(me, STATE_ATTACK4) or entity_isState(me, STATE_ACIDSPRAY) or entity_isState(me, STATE_PAIN) then
		if not entity_isAnimating(me) then
			if entity_isState(me, STATE_PAIN) then
				v.lastAcid = true
				entity_setState(me, STATE_ACIDSPRAY)
				--entity_setState(me, STATE_MOVERIGHT)
				v.attackDelay = -1
			else
				entity_setState(me, STATE_IDLE)
			end
		end
	end
	if entity_isState(me, STATE_DIE) and not entity_isAnimating(me) then
		entity_setState(me, STATE_DONE)
	end
	
	if entity_isState(me, STATE_MOVERIGHT) and entity_x(me) > node_x(v.node_right) then
		entity_setState(me, STATE_IDLE)
	end
	
	if entity_isState(me, STATE_MOVELEFT) and entity_x(me) < node_x(v.node_left) then
		entity_setState(me, STATE_IDLE)
	end	
end

v.inCutScene = false
local function cutscene(me)
	v.n = getNaija()
	if not v.inCutScene then		
		v.inCutScene = true
		

		setCameraLerpDelay(1)
		
		local pn = getNode("NAIJADONE")
		setFlag(FLAG_BOSS_MITHALA, 1)
		local ent = getFirstEntity()
		while ent ~= 0 do
			if entity_isName(ent, "MermanThin") then
				entity_setDieTimer(ent, 0.1)
			end
			ent = getNextEntity()
		end		
		changeForm(FORM_NORMAL)
		
		
		setSceneColor(0.5, 0.1, 0.1, 1)
		entity_idle(v.n)
		entity_flipToEntity(v.n, me)
		fade2(1, 1, 1, 0, 0)
		watch(1)
		
		cam_toNode(getNode("WATCHDIE"))

		entity_setPosition(me, v.sx, v.sy)
		entity_setPosition(v.n, node_x(pn), node_y(pn))
		playMusicOnce("mithalaend")
		
		entity_animate(me, "pain", -1)
		
		fade2(0, 1.5, 1, 0, 0)
		watch(2)
		playSfx("HellBeast-Die")
		shakeCamera(100, 3)
		entity_animate(me, "die")
		watch(3)
		playSfx("BossDieSmall")
		fade(1, 0.2, 1, 1, 1)
		watch(0.2)
		fade(0, 0.5, 1, 1, 1)
		watch(0.5)
		playSfx("BossDieSmall")
		fade(1, 0.2, 1, 1, 1)
		watch(0.2)
		fade(0, 0.5, 1, 1, 1)
		watch(0.5)
		entity_color(me, 0.5, 0.5, 0.5, 1.5)
		entity_offset(me, 0, 0)
		entity_offset(me, 5, 0, 0.05, -1, 1)
		playSfx("BossDieSmall")
		--playSfx("BossDieBig")
		fade(1, 1, 1, 1, 1)
		watch(1.2)
		fade(0, 0.5, 1, 1, 1)
		entity_offset(me, 0, 0, 0.1)
		
		entity_heal(v.n, 1)
		entity_idle(v.n)
		entity_flipToEntity(v.n, me)
		watch(5)
		--debugLog("playing agony")
		
		entity_idle(v.n)
		emote(EMOTE_NAIJASADSIGH)
		
		cam_toEntity(v.n)
		--entity_setPosition(v.n, node_x(pn), node_y(pn), 2, 0, 0, 1)
		
		--cam_toNode(getNode("WATCHDIE"))
		setSceneColor(1, 1, 1, 6)
		watch(2)
		--entity_setPosition(v.n, node_x(pn), node_y(pn), 2, 0, 0, 1)
		overrideZoom(0.8, 5)
		fade2(1,5,1,1,1)
		watch(2)
		cam_toEntity(v.n)
		entity_animate(v.n, "agony", -1)
		watch(4)
		--[[
		fade2(1, 1, 1, 1, 1)
		watch(1)
		]]--
		setCameraLerpDelay(0)
		loadMap("MithalasVision")

		--[[
		fade(0,0.5,1,1,1)
		fade2(0,0.5,1,1,1)
		entity_animate(v.n, "agony", LOOP_INF)
		
		showImage("Visions/Mithalas/00")
		watch(0.5)
		voice("naija_vision_mithalas")
		watchForVoice()
		hideImage()
		learnSong(SONG_BEASTFORM)
		watch(1)
		entity_idle(v.n)
		changeForm(FORM_BEAST)
		entity_addVel(v.n, 0, -100)
		entity_animate(v.n, "beast", 4)
		while entity_isAnimating(v.n) do
			watch(FRAME_TIME)
		end
		voice("naija_song_beastform")
		
		setControlHint(getStringBank(38), 0, 0, 0, 10, "", SONG_BEASTFORM)

		overrideZoom(0)
		entity_idle(v.n)
		
		setCameraLerpDelay(0)
		]]--
		--watchForVoice()
		-- show help text
	end
end

function enterState(me, state)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", LOOP_INF)
	elseif entity_isState(me, STATE_TRANSFORM) then
		v.skull = true
		entity_setStateTime(me, entity_animate(me, "transform"))
		setSceneColor(1, 0.5, 0.5, 2)
		v.attackDelay = -1
	elseif entity_isState(me, STATE_ATTACK1) then
		entity_animate(me, "attack1")
	elseif entity_isState(me, STATE_ATTACK2) then
		entity_animate(me, "attack2")
	elseif entity_isState(me, STATE_ATTACK3) then
		entity_animate(me, "attack3")
	elseif entity_isState(me, STATE_ATTACK4) then
		if v.skull then
			entity_setState(me, STATE_IDLE)
		else
			playSfx("HellBeast-Suck")
			v.pullSpd = v.minPullSpd
			entity_animate(me, "attack4")
		end
	elseif entity_isState(me, STATE_ATTACK5) then
		entity_setStateTime(me, entity_animate(me, "attack5"))
	elseif entity_isState(me, STATE_ACIDSPRAY) then	
		if v.skull then
			local bx, by = bone_getWorldPosition(v.bone_tongue)
			spawnParticleEffect("mermanspawn", bx, by)
		end
		entity_animate(me, "acidSpray")
		v.fireDelay = -1.5
	elseif entity_isState(me, STATE_PAIN) then	
		playSfx("HellBeast-Roar")	
		entity_animate(me, "pain")
	elseif entity_isState(me, STATE_HOLDING) then
		entity_animate(me, "holding")
		v.handHits = v.maxHandHits
	elseif entity_isState(me, STATE_DIE) then

		cutscene(me)
	elseif entity_isState(me, STATE_DONE) then
		debugLog("DONE")
		overrideZoom(0)
	elseif entity_isState(me, STATE_MOVERIGHT) then
		v.lastAcid = false
		entity_animate(me, "move", -1)
		--entity_setPosition(me, entity_x(me)+800, entity_y(me), 3)
		entity_setStateTime(me, 3)
	elseif entity_isState(me, STATE_MOVELEFT) then
		v.attackDelay = v.attackDelay - 1
		if v.attackDelay < -1 then
			v.attackDelay = -1
		end
		
		entity_animate(me, "move", -1)
		--entity_setPosition(me, entity_x(me)-800, entity_y(me), 3)
		entity_setStateTime(me, 3)
	elseif entity_isState(me, STATE_CREATEMERMAN) then
		entity_setStateTime(me, entity_animate(me, "create"))
	end
end

function exitState(me, state)
	if entity_isState(me, STATE_HOLDING) then
		if v.inHand then
			entity_damage(v.n, me, 1.5, DT_ENEMY)
		end
		v.inHand = false
		entity_idle(v.n)
		v.hurtDelay = 2
	elseif entity_isState(me, STATE_MOVERIGHT) or entity_isState(me, STATE_MOVELEFT) then
		playSfx("HellBeast-Stomp")
		shakeCamera(10, 1)
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_ATTACK4) then
	elseif entity_isState(me, STATE_ATTACK5) then
		v.attackDelay = -4
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_ACIDSPRAY) then
		if v.beam ~= 0 then
			beam_delete(v.beam)
			v.beam = 0
		end
	elseif entity_isState(me, STATE_TRANSFORM) then
		entity_setState(me, STATE_ACIDSPRAY)
	elseif entity_isState(me, STATE_CREATEMERMAN) then
		entity_setState(me, STATE_IDLE)
	end
end
