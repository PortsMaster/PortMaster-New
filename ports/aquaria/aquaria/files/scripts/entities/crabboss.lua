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
-- BIG MAUL
-- ================================================================================================

v.leftArmHealth = 16
v.rightArmHealth = 16

v.squidHealth = 16

v.stunTime = 3

v.n = 0

v.fireDelay = 4

v.ahitsMax = 6
v.ahits = v.ahitsMax

local LAYER_LEFTARM		= 1
local LAYER_RIGHTARM	= 2
local LAYER_LEGSANDBODY	= 3

local STATE_BASIC		= 1000
local STATE_STUNNED		= 1001
local STATE_POWER		= 1002
local STATE_LEFTCLAWSWIPE	= 1003
local STATE_RIGHTCLAWSWIPE	= 1004
local STATE_JUMP		= 1005
local STATE_TEABAG		= 1006
local STATE_WAITFORSTART	= 1007
local STATE_JUMPPREP		= 1008
local STATE_FIRING		= 1009

v.leftArmAlive = true
v.rightArmAlive = true

v.fireLoc = 0

v.leftClawBone = 0
v.rightClawBone = 0
v.leftClawPincerBone = 0
v.rightClawPincerBone = 0

v.actionDelay = 0
v.naija = 0
v.moveTimer = 0
v.movingRight = true
v.leftNode = 0
v.rightNode = 0
v.jumpTimer = 0

v.bone_la = 0
v.bone_ra = 0
v.bone_lw = 0
v.bone_rw = 0
v.bone_squid = 0

v.inity = 0

v.leave = 0

function init(me)	
	setupBasicEntity(
	me,
	"",								-- texture
	0,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	0,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setHealth(me, 16)
	
	entity_scale(me, 1.5, 1.5)
	entity_initSkeletal(me, "CrabBoss")
	entity_setState(me, STATE_WAITFORSTART)
	entity_setCull(me, false)
		
	v.leftNode = getNode("CRABBOUNDLEFT")
	v.rightNode = getNode("CRABBOUNDRIGHT")
		
	--entity_setTouchDamage(me, 1)
	--entity_setTouchPush(me, 1)
	
	entity_setWeight(me, 800)
	
	entity_setMaxSpeed(me, 2000)
	
	entity_generateCollisionMask(me)
	
	v.leftClawBone = entity_getBoneByName(me, "LeftClaw")
	v.rightClawBone = entity_getBoneByName(me, "RightClaw")
	v.leftClawPincerBone = entity_getBoneByName(me, "LeftClawPincer")
	v.rightClawPincerBone = entity_getBoneByName(me, "RightClawPincer")
	
	v.fireLoc = entity_getBoneByName(me, "FireLoc")
	
	v.naija = getEntity("Naija")
	
	v.bone_la = entity_getBoneByName(me, "LeftAntenna")
	v.bone_ra = entity_getBoneByName(me, "RightAntenna")
	
	v.bone_lw = entity_getBoneByName(me, "LeftArmWeakPoint")
	v.bone_rw = entity_getBoneByName(me, "RightArmWeakPoint")
	
	v.bone_squid = entity_getBoneByName(me, "Squid")
	
	esetv(me, EV_WALLOUT, 300)
	esetv(me, EV_SWITCHCLAMP, 0)
	
	entity_setTargetRange(me, 600)
	
	entity_setDeathScene(me, true)
	
	loadSound("BossDieSmall")
	loadSound("BossDieBig")
	
	entity_setDamageTarget(me, DT_AVATAR_SEED, true)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	v.inity = entity_y(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	v.leave = getNode("LEAVE")
end

v.wasMoving = false
function update(me, dt)
	if entity_isState(me, STATE_WAITFORSTART) then
		if entity_isEntityInRange(me, v.naija, 2000) then
			entity_setState(me, STATE_BASIC)
			playMusic("MiniBoss")
		end
		return
	end

	if node_isEntityIn(v.leave, v.n) then
		updateMusic()
		entity_setState(me, STATE_WAITFORSTART)
	end
	
	overrideZoom(0.45)
	if v.actionDelay > 0 then
		v.actionDelay = v.actionDelay - dt
	end
	
	if v.jumpTimer > 0 then
		v.jumpTimer = v.jumpTimer - dt
	end
	
	if entity_isState(me, STATE_JUMP) then
		if v.jumpTimer > 0 then
			entity_addVel(me,0,-1000)
		end
		entity_updateMovement(me, dt)
	end
	
	if entity_isState(me, STATE_LEFTCLAWSWIPE) and (not entity_isAnimating(me, LAYER_LEFTARM)) then
		entity_setState(me, STATE_BASIC)
	end

	if entity_isState(me, STATE_RIGHTCLAWSWIPE) and (not entity_isAnimating(me, LAYER_RIGHTARM)) then
		entity_setState(me, STATE_BASIC)
	end
	
	if entity_isState(me, STATE_TEABAG) and (not entity_isAnimating(me)) then
		entity_setState(me, STATE_BASIC)
	end
	
	if v.naija ~= 0 then
		if entity_isState(me, STATE_BASIC) then
			--entity_rotateToSurfaceNormal(me, 0.1, 20)
			local moving = false
			local moveDir
			if entity_x(v.naija) > entity_x(me) + 256 and entity_x(me) < node_x(v.rightNode) then
				moving = true
				moveDir = 1
				--entity_switchSurfaceDirection(me, 0)
				--entity_rotateToSurfaceNormal(me, 1)
			elseif entity_x(v.naija) < entity_x(me) - 256 and entity_x(me) > node_x(v.leftNode) then
				moving = true
				moveDir = -1
				--entity_switchSurfaceDirection(me, 1)
				--entity_rotateToSurfaceNormal(me, 1)
			end
			if not moving then
				if not v.leftArmAlive and not v.rightArmAlive then
					if entity_x(v.naija) > entity_x(me)-256 and entity_x(v.naija) < entity_x(me)+256 then
						if entity_y(v.naija) < entity_y(me)-512 then
							entity_setState(me, STATE_JUMPPREP)
						end
						--[[
						elseif entity_y(v.naija) > entity_y(me)-128 then
							entity_setState(me, STATE_TEABAG)
						end
						]]--
					end
				end
			end
			if moving then
				--debugLog("Moving")
				--entity_moveAlongSurface(me, dt, 300, 6, 200) --64 (32)
				entity_setPosition(me, entity_x(me)+moveDir*300*dt, entity_y(me))
			end
			if moving and not v.wasMoving then
				entity_animate(me, "walk", -1, LAYER_LEGSANDBODY)
			elseif not moving and v.wasMoving then
				entity_animate(me, "idle", -1, LAYER_LEGSANDBODY)
			end
			v.wasMoving = moving
			
			v.fireDelay = v.fireDelay - dt
			if v.fireDelay < 0 then
				entity_setState(me, STATE_FIRING)
			end
			-- dt, pixelsPerSecond, climbHeight, outfromwall		
			--[[
			v.moveTimer = v.moveTimer + dt
			if v.moveTimer > 5 then
				entity_switchSurfaceDirection(me)
				v.moveTimer = 0
			end
			]]--
		else
			--[[
			if not (entity_isState(me, STATE_LEFTCLAWSWIPE) or entity_isState(me, STATE_RIGHTCLAWSWIPE) or entity_isState(me, STATE_STUNNED)) then
				entity_animate(me, "idle", -1, LAYER_LEGSANDBODY)
				v.wasMoving = false
			end
			]]--
		end
		if entity_isState(me, STATE_BASIC) then
			local didArmAttack = false
			
			if v.leftArmHealth > 0 then
				if entity_x(v.naija) < entity_x(me)-64 and entity_isEntityInRange(me, v.naija, 680) and entity_y(v.naija) > entity_y(me)-200 then
					entity_setState(me, STATE_LEFTCLAWSWIPE)
					didArmAttack = true
				end
			end
			if not didArmAttack and v.rightArmHealth > 0 then
				if entity_x(v.naija) > entity_x(me)+64 and entity_isEntityInRange(me, v.naija, 680) and entity_y(v.naija) > entity_y(me)-200 then
					entity_setState(me, STATE_RIGHTCLAWSWIPE)
					didArmAttack = true
				end
			end
		end
	end
	
	
	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.naija)
	if bone ~= 0 then
		avatar_fallOffWall()
		if entity_x(v.naija) < entity_x(me) then
			--entity_push(v.naija, -1200, -100, 0.5)
			entity_addVel(v.naija, -1200, -100)
		else
			entity_addVel(v.naija, 1200, -100)
			--entity_push(v.naija, 1200, -100, 0.5)
		end
		entity_damage(v.naija, me, 1)
	end
	
	entity_clearTargetPoints(me)
	if entity_isState(me, STATE_JUMP) then
		local vx = entity_velx(me)
		local vy = entity_vely(me)
		if vx ~= 0 then
			local len = vector_getLength(vx, vy)
			vx, vy = vector_setLength(0, vy, len)
			entity_clearVel(me)
			entity_addVel(me, vx, vy)
		end
		entity_addTargetPoint(me, bone_getWorldPosition(v.bone_squid))
	elseif not entity_isState(me, STATE_STUNNED) then
		entity_addTargetPoint(me, bone_getWorldPosition(v.bone_la))
		entity_addTargetPoint(me, bone_getWorldPosition(v.bone_ra))
	else
		entity_addTargetPoint(me, bone_getWorldPosition(v.bone_lw))
		entity_addTargetPoint(me, bone_getWorldPosition(v.bone_rw))
	end
end

--[[
	v.rightClawHealth = v.rightClawHealth - dmg
	if v.rightClawHealth < 0 then
		entity_toggleBone(me, bone, 0)
	end
]]--
function damage(me, attacker, bone, dtype, dmg)
	if entity_isState(me, STATE_JUMPPREP) then
		return false
	end
	if bone ~= 0 then
		if bone_isName(bone, "LeftAntenna") or bone_isName(bone, "RightAntenna") then	
			if not entity_isState(me, STATE_STUNNED) and not entity_isState(me, STATE_JUMP) 
			and (v.leftArmHealth>0 or v.rightArmHealth>0) then
				v.ahits = v.ahits - dmg
				bone_damageFlash(bone)
				if v.ahits <= 0 then
					debugLog("state stunned")
					entity_setState(me, STATE_STUNNED, v.stunTime)
					
					v.ahits = v.ahitsMax
				end
			end
		elseif bone_isName(bone, "RightArmWeakPoint") or bone_isName(bone, "LeftArmWeakPoint") then
			if entity_isState(me, STATE_STUNNED) then
				if bone_isName(bone, "LeftArmWeakPoint") then						
					v.leftArmHealth = v.leftArmHealth - dmg
					for i=30,33 do
						bone_damageFlash(entity_getBoneByIdx(me, i))
					end
					if v.leftArmHealth <= 0 then
						v.leftArmAlive = false
						-- [30 - 33]
						for i=30,33 do
							bone_setVisible(entity_getBoneByIdx(me, i), false)
						end
					end
				end
				if bone_isName(bone, "RightArmWeakPoint") then
					v.rightArmHealth = v.rightArmHealth - dmg
					for i=26,29 do
						bone_damageFlash(entity_getBoneByIdx(me, i))
					end
					debugLog(string.format("rightArmHealth: %d", v.rightArmHealth))
					if v.rightArmHealth <= 0 then
						v.rightArmAlive = false
						-- [26 - 29]
						for i=26,29 do
							bone_setVisible(entity_getBoneByIdx(me, i), false)
						end
					end
				end
				bone_damageFlash(bone)
				--entity_setState(me, STATE_BASIC)
			end
		elseif bone_isName(bone, "Squid") then
			if dtype == DT_AVATAR_VINE then
				--entity_changeHealth(me, 0.5)
				if not entity_isState(me, STATE_JUMPPREP) and not entity_isState(me, STATE_JUMP) then
					entity_setState(me, STATE_JUMPPREP)
				end
			end
			bone_damageFlash(bone)
			--[[
			bone_damageFlash(bone)

			v.squidHealth = v.squidHealth - dmg
			if v.squidHealth <= 0 then
				msg ("Killed Squid")
				
			end
			]]--
			return true
		end			
		return false
	else
		return false
	end
	
	return false
end

function enterState(me)
	if entity_isState(me, STATE_BASIC) then
		entity_setDamageTarget(me, DT_AVATAR_VINE, true)
		entity_animate(me, "idle", LOOP_INF)
		--bone_setTouchDamage(v.leftClawBone, 0)
		--bone_setTouchDamage(v.rightClawBone, 0)
	elseif entity_isState(me, STATE_STUNNED) then
		entity_stopAllAnimations(me)
		entity_animate(me, "stunned", LOOP_INF)
	elseif entity_isState(me, STATE_LEFTCLAWSWIPE) then
		entity_animate(me, "ArmSwipe", 0, LAYER_LEFTARM)
		--bone_setTouchDamage(v.leftClawBone, 1)
	elseif entity_isState(me, STATE_RIGHTCLAWSWIPE) then
		entity_animate(me, "ArmSwipe", 0, LAYER_RIGHTARM)
		--bone_setTouchDamage(v.rightClawBone, 1)
	elseif entity_isState(me, STATE_JUMP) then
		entity_setDamageTarget(me, DT_AVATAR_VINE, false)
		--entity_applySurfaceNormalForce(me, 4)
		entity_addVel(me,0,-2000)
		v.jumpTimer = 0
		entity_adjustPositionBySurfaceNormal(me, 8)
		entity_rotate(me, 0, 0.5)
	elseif entity_isState(me, STATE_TEABAG) then
		entity_stopAllAnimations(me)
		entity_animate(me, "teabag")
	elseif entity_isState(me, STATE_JUMPPREP) then
		entity_setStateTime(me, entity_animate(me, "jumpPrep"))
	elseif entity_isState(me, STATE_FIRING) then
		entity_setStateTime(me, entity_animate(me, "firing"))
	elseif entity_isState(me, STATE_DEATHSCENE) then
		clearShots()
		entity_stopInterpolating(me)
		entity_setStateTime(me, 99)
		fadeOutMusic(6)
		entity_idle(v.naija)
		entity_setInvincible(v.naija, true)
		cam_toEntity(me)
		entity_setInternalOffset(me, 0, 0)
		entity_setInternalOffset(me, 10, 0, 0.1, -1, 1)
		watch(1)
		playSfx("BossDieSmall")
		fade(1, 0.2, 1, 1, 1)
		watch(0.2)
		fade(0, 0.5, 1, 1, 1)
		watch(0.5)
		watch(1)
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
		entity_setInternalOffset(me, 0, 0)
		entity_setInternalOffset(me, 20, 0, 0.05, -1, 1)
		playSfx("BossDieBig")
		fade(1, 1, 1, 1, 1)
		watch(1.2)
		fade(0, 0.5, 1, 1, 1)
		
		cam_toEntity(v.naija)
		entity_setInvincible(v.naija, false)
		pickupGem("Boss-RockCrab")
		overrideZoom(0, 1)
		entity_setStateTime(me, 0.1)
		entity_setState(me, STATE_DEAD, -1, 1)
	end
end

function exitState(me)
	if entity_isState(me, STATE_STUNNED) then
		entity_setState(me, STATE_BASIC)
	elseif entity_isState(me, STATE_JUMPPREP) then
		entity_setState(me, STATE_JUMP)
	elseif entity_isState(me, STATE_BASIC) then
		entity_animate(me, "idle", -1, LAYER_LEGSANDBODY)
		v.wasMoving = false
	elseif entity_isState(me, STATE_FIRING) then
		entity_setState(me, STATE_BASIC, -1)
		v.fireDelay = math.random(3) + 2
	end
end

function activate(me)
end

function animationKey(me, key)
	if entity_isState(me, STATE_FIRING) then
		if key == 2 or key == 4 or key == 6 then
			local x, y = entity_getPosition(v.n)
			local bx, by = bone_getWorldPosition(v.fireLoc)
			x = x - bx
			y = y - by
			x, y = vector_setLength(x, y, 100)
			
			local s = createShot("CrabBoss", me, entity_getTarget(me), bx, by)
			if key == 2 then
				shot_setAimVector(s, -50*0.5 + x*0.5, -100*0.5 + y*0.5)
			elseif key == 4 then
				shot_setAimVector(s, 0+x*0.5, -100*0.5+y*0.5)
			elseif key == 6 then
				shot_setAimVector(s, 50*0.5+x*0.5, -100*0.5 + y*0.5)
			end
		end
	end
end

function hitSurface(me)
	if entity_y(me) >= v.inity then
		entity_setPosition(me, entity_x(me), v.inity)
		entity_setState(me, STATE_TEABAG)
	end
--[[
	if entity_isState(me, STATE_JUMP) then
		entity_clampToSurface(me)
		--entity_moveAlongSurface(me, dt, 1, 6, 200)
		entity_setState(me, STATE_TEABAG)
	end
]]--
end

