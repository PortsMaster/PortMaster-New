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

local STATE_MOVING 	= 1001

v.n = 0
v.eyes = nil
v.eyeHits = nil
v.beams = nil
v.nut = 0
v.node = 0
v.door = 0
v.beamTimer = 0
v.addBeamIdx = -1
v.addBeamDelay = 0
v.vdir = 0
v.hdir = -1
v.hdirTimer = 6
v.movingSpawnTimer = 3
v.movingBeamTimer = 8

v.soundDelay = 0

v.rotSpeed = 40

local function clearBarriers()
	if v.node ~= 0 then
		-- do magic
		node_setElementsInLayerActive(v.node, 2, false)
		reconstructGrid()
	end
end

function init(me)
	v.eyes = {}
	v.eyeHits = {}
	v.beams = {}

	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "RotCore")	
	--entity_setAllDamageTargets(me, false)
	entity_generateCollisionMask(me)
	entity_setHealth(me, 34) -- 26
	
	for i=1,6 do
		v.eyes[i] = entity_getBoneByIdx(me, i)
		bone_rotate(v.eyes[i], bone_getRotation(v.eyes[i])+180, 2)
		v.eyeHits[i] = 0
		v.beams[i] = 0
	end
	
	entity_setState(me, STATE_IDLE)
	entity_setCullRadius(me, 1024)
	
	v.nut = entity_getBoneByName(me, "Nut")
	
	--entity_rotate(me, 360, 3)
	entity_offset(me, 0, 16, 3,-1,1,1)
	
	bone_setSegs(entity_getBoneByName(me, "Body"), 2, 8, 0.3, 0.3, -0.018, 0, 6, 1)
	bone_setSegs(entity_getBoneByName(me, "Tentacles"), 2, 8, 0.3, 0.3, -0.018, 0, 6, 1)
	entity_setDeathScene(me, true)
	entity_setBounce(me, 1)
	entity_setBounceType(me, BOUNCE_REAL)
	entity_setCollideRadius(me, 100)
	entity_setUpdateCull(me, 3000)
	entity_setDropChance(me, 100, 3)
	
	--entity_setDamageTarget(me, DT_AVATAR_PET, false)
	
	loadSound("rotcore-beam")
	loadSound("rotcore-idle")
	loadSound("rotcore-die")
	loadSound("rotcore-birth")
	loadSound("rotcore-hurt")
	loadSound("rotcore-die2")
end

local function clearBeams()
	for i=1,6 do
		if v.beams[i]~=0 then
			beam_delete(v.beams[i])
			v.beams[i] = 0
		end
		v.eyeHits[i] = 0
		bone_rotateOffset(v.eyes[i], 0, 0.5, 0, 0, 1)
	end
	v.addBeamIdx = -1
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	v.node = entity_getNearestNode(me, "CORERANGE")
	v.door = getEntity("CathedralDoor")
	if entity_isFlag(me, 1) then
		clearBarriers()
		entity_delete(me)
		
		if v.door ~= 0 then
			entity_msg(v.door, "DoorDownPre")
		end		
	end
end

local function addEyeBeam(me, idx)
	if v.beams[idx] == 0 then
		local bx, by = bone_getWorldPosition(v.eyes[idx])
		v.beams[idx] = createBeam(bx, by, bone_getWorldRotation(v.eyes[idx])-90)
		beam_setTexture(v.beams[idx], "particles/Beam")
		
		entity_sound(me, "rotcore-beam")
		
		local c = 0
		for i=1,6 do 
			if v.beams[i] ~= 0 then
				c = c + 1
			end
		end
		if c >= 6 then
			v.beamTimer = 0
			entity_setState(me, STATE_OPEN)
		end
	end
end

local function cueAddEyeBeam(me, idx)
	v.eyeHits[idx] = 1000
	if v.beams[idx] == 0 then
		bone_rotateOffset(v.eyes[idx], 180, 0.5, 0, 0, 1)				
		if v.addBeamIdx ~= -1 and v.addBeamIdx ~= idx then
			addEyeBeam(me, v.addBeamIdx)
		end
		v.addBeamIdx = idx
		v.addBeamDelay = 0.5
		v.beamTimer = 6
	end
end

v.seen = false

function update(me, dt)
	if v.addBeamDelay > 0 then
		v.addBeamDelay = v.addBeamDelay - dt
		if v.addBeamDelay < 0 then
			v.addBeamDelay = 0			
			addEyeBeam(me, v.addBeamIdx)
			v.addBeamIdx = -1
		end
	end
	
	v.soundDelay = v.soundDelay - dt
	if v.soundDelay <= 0 then
		v.soundDelay = 0.6 + math.random(2) * 0.6
		entity_sound(me, "rotcore-idle")
	end
	
	if entity_isEntityInRange(me, v.n, 900) then
		overrideZoom(0.5, 0.2)
	else
		overrideZoom(0)
	end
	
	if not v.seen and entity_isEntityInRange(me, v.n, 800) then
		emote(EMOTE_NAIJAUGH)
		v.seen = true
	end

	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then
		local nx,ny = entity_getPosition(v.n)
		local cx,cy = entity_getPosition(me)
		local x = nx-cx
		local y = 0
		x,y = vector_setLength(x,y,2000)
		entity_addVel(v.n, x, y)
		entity_damage(v.n, me, 0.5)
	end
	if entity_isState(me, STATE_IDLE) then
		if v.beamTimer > 0 then
			v.beamTimer = v.beamTimer - dt
			if v.beamTimer <= 0 then
				clearBeams()
			end
		end
		if entity_isEntityInRange(me, v.n, 1000) then
			entity_setMaxSpeedLerp(me, 0.15, 0.1)
			entity_moveTowardsTarget(me, dt, 400)
		end
	end
	if entity_isState(me, STATE_MOVING) then
		v.hdirTimer = v.hdirTimer - dt
		if v.hdirTimer < 0 then
			v.hdirTimer = math.random(2)+4
			if v.hdir == -1 then
				v.hdir = 1
			else
				v.hdir = -1
			end
		end
		entity_setMaxSpeedLerp(me, 1, 0.1)
		entity_rotate(me, entity_getRotation(me)+dt*v.rotSpeed*v.hdir)
		if v.vdir == 0 then
			entity_addVel(me, 0, -500*dt)
		else
			entity_addVel(me, 0, 500*dt)
		end
		entity_addVel(me, v.hdir*100*dt, 0)
		v.movingSpawnTimer = v.movingSpawnTimer - dt
		if v.movingSpawnTimer < 0 then
			local bx, by = bone_getWorldPosition(v.nut)
			for i=1,2 do
				createEntity("RotBaby-Form1", "", bx, by+i*10)
				playSfx("rotcore-birth")
			end	
			v.movingSpawnTimer = math.random(4) + 8
		end
		v.movingBeamTimer = v.movingBeamTimer - dt
		if v.movingBeamTimer < -100 then
			if v.movingBeamTimer <= -100 - 4 then
				clearBeams()
				v.movingBeamTimer = math.random(2) + 4
			end
		elseif v.movingBeamTimer < 0 then
			clearBeams()
			cueAddEyeBeam(me, math.random(6))
			v.movingBeamTimer = -100			
		end		
	end
	entity_updateMovement(me, dt)
	for i=1,6 do
		if v.beams[i]~=0 then
			bone = v.eyes[i]
			beam_setAngle(v.beams[i], bone_getWorldRotation(bone)+90)
			beam_setPosition(v.beams[i], bone_getWorldPosition(bone))
		end
	end
	entity_clearTargetPoints(me)
	if not entity_isState(me, STATE_OPEN) and not entity_isState(me, STATE_MOVING) then
		for i=1,6 do
			entity_addTargetPoint(me, bone_getWorldPosition(v.eyes[i]))
		end
	end
	if entity_isState(me, STATE_OPEN) or entity_isState(me, STATE_MOVING) then
		entity_addTargetPoint(me, bone_getWorldPosition(v.nut))
	end
end

v.incut = false

function enterState(me)
	if v.incut then return end
	
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_OPEN) then
		entity_animate(me, "showNut")
		entity_setStateTime(me, 8)
		entity_clearVel(me)
	elseif entity_isState(me, STATE_CLOSE) then
		clearBeams()
		entity_setStateTime(me, entity_animate(me, "hideNut"))
	elseif entity_isState(me, STATE_DEATHSCENE) then
		v.incut = true
		clearBeams()
		entity_setStateTime(me, 99)
		
		entity_idle(getNaija())
		
		
		
		entity_offset(me, -10, 0)
		entity_offset(me, 10, 0, 0.03, -1, 1)
		
		entity_scale(me, 1.5, 1.5, 4)
		
		cam_toEntity(me)
		shakeCamera(3, 5)
		
		watch(1)
		playSfx("rotcore-die2")
		watch(2)
		
		playSfx("rotcore-die")
		
		fade2(1, 0.2, 1, 1, 1)
		watch(0.2)
		
		entity_heal(v.n, 1)
		
		spawnParticleEffect("rotcore-die", entity_x(me), entity_y(me))
		
		entity_scale(me, 3, 3, 0.5)
		entity_alpha(me, 0, 0.5)
		
		fade2(0, 1, 1, 1, 1)
		watch(2)
		
		entity_setStateTime(me, 0.01)
		v.incut = false
	elseif entity_isState(me, STATE_MOVING) then
		clearBeams()
	elseif entity_isState(me, STATE_DEAD) then
		clearBarriers()
		if v.door ~= 0 then
			entity_msg(v.door, "DoorDown")
		end
		overrideZoom(0)
		entity_setFlag(me, 1)
	end
end

function exitState(me)
	if entity_isState(me, STATE_OPEN) then
		entity_setState(me, STATE_MOVING)
	elseif entity_isState(me, STATE_CLOSE) then
		local bx, by = bone_getWorldPosition(v.nut)
		for i=1,6 do
			createEntity("RotBaby-Form1", "", bx, by+i*10)
		end
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if bone_isName(bone,"Eye") or bone_isName(bone, "Nut") then
		bone_damageFlash(bone)
	end
	if bone == v.nut then
		playSfx("rotcore-hurt")
		return true
	end
	if not entity_isState(me, STATE_OPEN) and not entity_isState(me, STATE_MOVING) then
		local idx = bone_getIndex(bone)
		if idx >= 1 and idx <= 6 then
			-- is an eye!
			v.eyeHits[idx] = v.eyeHits[idx] + dmg
			if v.eyeHits[idx] >= 1 and v.eyeHits[idx] < 1000 then
				cueAddEyeBeam(me, idx)
			end
		end
	end
	return false
end

function animationKey(me, key)
end

function hitSurface(me)
	if entity_isState(me, STATE_MOVING) then
		local nx, ny = getWallNormal(getLastCollidePosition())
		if math.abs(ny) > 0.5 then
			if v.vdir==0 then
				v.vdir = 1
			else
				v.vdir = 0
			end
		end
	end
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

