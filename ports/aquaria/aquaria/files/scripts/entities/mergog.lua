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

local STATE_FIREPREP	= 1000
local STATE_BEAMPREP	= 1001
local STATE_BEAMFIRE	= 1002

v.n = 0
v.head = 0
v.mergog = 0

v.shot_bones = nil

v.shot = 1

v.attackDelay = 0
v.attackDelayMax = 8

v.shotDelay = 0
v.shotDelayMax = 0.02

v.firePos = 0

v.beam = 0
v.pokeTimer = 0

function init(me)
	v.shot_bones = {0,0,0,0,0}

	setupBasicEntity(
	me,
	"Mergog/Mergog",				-- texture
	14,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	128,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	256,							-- sprite width	
	256,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	1800							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setDeathParticleEffect(me, "")
	entity_setDeathSound(me, "")
	
	entity_initSkeletal(me, "Mergog")
	entity_generateCollisionMask(me)
	entity_scale(me, 1.2, 1.2)
	
	entity_setEntityType(me, ET_ENEMY)
	
	entity_setCullRadius(me, 640) -- Skeletal sprites ain't got auto cull yet (says Alec)
	
	entity_setState(me, STATE_PREP, -1, 1)
	
	entity_setHealth(me, 100)
	--entity_setHealth(me, 5)
	
	v.head = entity_getBoneByName(me, "Head")
	v.mergog = entity_getBoneByName(me, "Mergog")
	
	for i=1,5 do
		v.shot_bones[i] = entity_getBoneByIdx(me, 9+i)
	end
	
	entity_setMaxSpeed(me, 1200)
	
	entity_setDeathScene(me, true)
	
	loadSound("BossDieSmall")
	loadSound("BossDieBig")
	
	entity_setTargetRange(me, 1024)
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	
	loadSound("rotcore-beam")
	loadSound("mergog-laugh")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	v.firePos = getNode("FIREPOS")
end

function update(me, dt)
	if entity_isState(me, STATE_PREP) then
		if entity_isEntityInRange(me, v.n, 1024) then
			emote(EMOTE_NAIJAGIGGLE)
			playMusic("Miniboss")
			entity_setState(me, STATE_IDLE)
		end
		return
	end
	overrideZoom(0.45, 1)
	
	if entity_isState(me, STATE_IDLE) then
		v.attackDelay = v.attackDelay + dt
		if v.attackDelay > v.attackDelayMax then
			v.attackDelay = 0
			if entity_getHealthPerc(me) < 0.5 then
				if chance(50) then
					entity_setState(me, STATE_FIREPREP)
				else
					entity_setState(me, STATE_BEAMPREP)
				end
			else
				entity_setState(me, STATE_FIREPREP)
			end
		end
		entity_addVel(me, 0, 1000*dt)
		
		if entity_vely(me) < 0 then
			entity_moveTowardsTarget(me, dt, 500)
		end

		
		if math.abs(entity_x(me) - entity_x(v.n)) > 50 then
			entity_flipToEntity(me, v.n)
		end
	end
	
	if entity_isState(me, STATE_FIRE) then
		v.shotDelay = v.shotDelay + dt
		if v.shotDelay > v.shotDelayMax then
			v.shotDelay = 0
			local bx, by = bone_getWorldPosition(v.shot_bones[v.shot])
			v.shot = v.shot + 1
			if v.shot > 5 then
				v.shot = 1
			end
			local s = createShot("Mermog", me, v.n, bx, by)
			local x, y = randVector()
			if y > x then
				local t = x
				x = y
				y = t
			end
			if entity_x(v.n) < entity_x(me) then
				if x > 0 then
					x = -x
				end
			end
			shot_setAimVector(s, x, y)
			
		end
		shakeCamera(2, 0.5)
	end
	
	if entity_isState(me, STATE_BEAMFIRE) then
		debugLog("beamfire")
		entity_moveTowardsTarget(me, dt, -200)
		entity_addVel(me, -500*dt, 0)
		if entity_y(v.n) < entity_y(me) then
			entity_addVel(me, 0, -1000*dt)
		elseif entity_y(v.n) > entity_y(me) then
			entity_addVel(me, 0, 1000*dt)
		end
		beam_setPosition(v.beam, entity_x(me), entity_y(me)+20)
	end
	
	if entity_isState(me, STATE_IDLE) or entity_isState(me, STATE_BEAMFIRE) then
		v.pokeTimer = v.pokeTimer + dt
		if v.pokeTimer > 2 then
			entity_moveTowardsTarget(me, 1, 1000)
			v.pokeTimer = 0
		else
			if v.pokeTimer > 1 then
				entity_addVel(me, 0, -1000*dt)
			end
			entity_doCollisionAvoidance(me, dt, 4, 1)
			entity_doCollisionAvoidance(me, dt, 8, 0.2)
			entity_doCollisionAvoidance(me, dt, 10, 0.1)
		end
		entity_updateMovement(me, dt)
	end
	
	entity_handleShotCollisionsSkeletal(me)
	
	--[[
	bone = entity_collideSkeletalVsCircle(me, getNaija())
	if bone ~= 0 then
		entity_touchAvatarDamage(me, 0, 0.5, 800)
	end
	]]--
	entity_touchAvatarDamage(me, 100, 1, 2000)
	
	entity_setLookAtPoint(me, bone_getWorldPosition(v.mergog))
	entity_clearTargetPoints(me)
	entity_addTargetPoint(me, bone_getWorldPosition(v.mergog))
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_clearVel(me)
		entity_animate(me, "idle", LOOP_INF)
	elseif entity_isState(me, STATE_FIRE) then
		playSfx("mergog-laugh")
		v.shot = 1
		entity_animate(me, "fire", LOOP_INF)
	elseif entity_isState(me, STATE_FIREPREP) then
		if entity_isfh(me) then
			entity_fh(me)
		end
		entity_setStateTime(me, 2.5)
		entity_setPosition(me, node_x(v.firePos), node_y(v.firePos), 2, 0, 0, 1)
	elseif entity_isState(me, STATE_BEAMPREP) then
		playSfx("mergog-laugh")
		entity_setStateTime(me, entity_animate(me, "beamPrep"))
		if entity_isfh(me) then
			entity_fh(me)
		end
		--entity_setStateTime(me, 0.1)
	elseif entity_isState(me, STATE_BEAMFIRE) then
		entity_animate(me, "fire", -1)
		entity_setStateTime(me, 5)
		local x, y = entity_getPosition(me)
	
		playSfx("rotcore-beam")
		v.beam = createBeam(x, y, 180)
		beam_setAngle(v.beam, 90)
		beam_setTexture(v.beam, "particles/Beam")
	elseif entity_isState(me, STATE_DEATHSCENE) then
		if v.beam ~= 0 then
			beam_delete(v.beam)
			v.beam = 0
		end
		clearShots()
		entity_stopInterpolating(me)
		entity_setStateTime(me, 99)
		fadeOutMusic(6)
		entity_idle(v.n)
		entity_setInvincible(v.n, true)
		cam_toEntity(me)
		entity_offset(me, 0, 0)
		entity_offset(me, 10, 0, 0.1, -1, 1)
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
		entity_color(me, 0, 0, 0, 1.5)
		entity_offset(me, 0, 0)
		entity_offset(me, 20, 0, 0.05, -1, 1)
		playSfx("BossDieBig")
		fade(1, 1, 1, 1, 1)
		watch(1.2)
		fade(0, 0.5, 1, 1, 1)
		
		cam_toEntity(v.n)
		entity_setInvincible(v.n, false)
		overrideZoom(0, 1)
		entity_setStateTime(me, 0.1)
		entity_setState(me, STATE_DEAD, -1, 1)
		
		spawnIngredient("SpecialBulb", entity_x(me), entity_y(me))
		
		pickupGem("boss-mergog")
		
	end
end

--[[
			beam_setAngle(v.beam, entity_getRotation(me)-180)
			beam_setPosition(v.beam, entity_getPosition(me))
			v.delay = v.delay + dt
			if v.delay >= 3 then
				entity_setUpdateCull(me, 1024)
				v.delay = 0
				beam_delete(v.beam)
				v.beam = 0
				bone_setColor(bone_eyes, 1, 1, 1, 1)
			end
			]]--
function exitState(me)
	if entity_isState(me, STATE_FIRE) then
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_FIREPREP) then
		entity_setState(me, STATE_FIRE, 5)
	elseif entity_isState(me, STATE_BEAMPREP) then
		entity_setState(me, STATE_BEAMFIRE)
	elseif entity_isState(me, STATE_BEAMFIRE) then
		beam_delete(v.beam)
		v.beam = 0
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if bone == v.mergog then
		return true
	end
	return false
end

function animationKey(me, key)
end

function hitSurface(me)
	--debugLog("Hit surface")
	--entity_clearVel(me)
	--entity_doCollisionAvoidance(me, 1, 8, 1000)
	entity_moveTowardsTarget(me, 1, 500)
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

