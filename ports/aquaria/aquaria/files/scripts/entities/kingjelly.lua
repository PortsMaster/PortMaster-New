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

v.core = 0
v.ring = 0
v.n = 0
v.spawnTimer = 0
v.closeRange = 860
v.farRange = 950
v.started = false

local STATE_READY			= 1000
local STATE_SPAWNJELLIES	= 1001
local STATE_MOVECORE		= 1002

v.maxHealth = 60

v.zaps = nil
v.zapGlows = nil

v.nZaps = 3

v.zapTimer = 0
v.zapStart = 5
v.zapTime = 5
v.zapGlowStart = 3

v.zapsOn = false
v.zapGlowOn = false
v.dist = 90
v.start = 0
v.spread = 120

v.hardLevel = 0

function init(me)
	v.zaps = {}
	v.zapGlows = {}

	setupEntity(me)
	--entity_setEntityLayer(me, 1)
	entity_initSkeletal(me, "KingJelly")
	entity_setTargetPriority(me, 1)
	entity_setEntityType(me, ET_ENEMY)
	entity_setCollideRadius(me, 120)
	entity_generateCollisionMask(me)
	entity_animate(me, "idle")
	entity_setCull(me, false)
	
	entity_setHealth(me, v.maxHealth)
	
	v.core = entity_getBoneByName(me, "Core")
	v.ring = entity_getBoneByName(me, "Ring")
	
	--bone_scale(v.core, 1.2, 1.2, 1, -1)
	
	entity_setState(me, STATE_IDLE)	
	v.n = getNaija()
	
	--entity_setActivation(me, AT_CLICK, 64, 512)
	
	--[[
	entity_setAllDamageTargets(me, false)
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
	entity_setDamageTarget(me, DT_AVATAR_SHOCK, true)
	]]--
	
	for i=5,5+v.nZaps do
		v.zaps[i-4] = entity_getBoneByIdx(me, i)
		bone_alpha(v.zaps[i-4], 0)
	end
	
	for i=10,10+v.nZaps do
		v.zapGlows[i-9] = entity_getBoneByIdx(me, i)
		bone_alpha(v.zapGlows[i-10], 0)
	end	
	
	--entity_initStrands(me, 32, 16, 256, 20, 0.8, 0.9, 1.0)
	--bone_setPosition(v.core, 0, -40, 3, -1, 1, 1)
	entity_setDeathScene(me, true)
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	if isFlag(FLAG_MINIBOSS_KINGJELLY, 1) then
		entity_delete(me)
	end
end

local function activate(me)
	entity_setActivationType(me, AT_NONE)
	entity_setState(me, STATE_READY)
end

local function killJellies(me)
	local ent = getFirstEntity()
	while ent ~= 0 do
		if ent ~= me and entity_getEntityType(ent)==ET_ENEMY and entity_isEntityInRange(me, ent, v.farRange*2) and entity_isName(ent, "EvilJelly") then
			entity_damage(ent, me, 1000)
		end
		ent = getNextEntity()
	end
end

local function toggleZapGlow(me, on)
	v.zapGlowOn = on
	if on then
		v.start = math.random(360*2)-360
		for i=1,v.nZaps do
			--debugLog("setting alpha to 1")
			bone_rotate(v.zapGlows[i], v.start+(i-1)*v.spread)
			bone_alpha(v.zapGlows[i], 1, 0.2)
			bone_scale(v.zapGlows[i], 1, 1)
			bone_scale(v.zapGlows[i], 1.5, 1.5, 0.2, -1)
		end
	else
		for i=1,v.nZaps do
			--debugLog("setting alpha to 0")
			bone_alpha(v.zapGlows[i], 0, 0.5)
		end	
	end
end

local function toggleZaps(me, on)
	v.zapsOn = on
	if on then
		toggleZapGlow(me, false)
		for i=1,v.nZaps do
			bone_alpha(v.zaps[i], 1, 0.1)
		end
		for i=1,v.nZaps do
			bone_setSegs(v.zaps[i], 2, 32, 0.8, 0.8, -0.1, 0, 50, 1)
			bone_rotate(v.zaps[i], v.start+(i-1)*v.spread)
			bone_rotate(v.zaps[i], v.start+v.dist+(i-1)*v.spread, v.zapTime/2, -1, 1, 1)
		end		
	else
		toggleZapGlow(me, false)
		for i=1,v.nZaps do
			bone_alpha(v.zaps[i], 0, 0.1)
		end
	end
end

local function zapCollision(me, dt)
	if not v.zapsOn then return end
	if avatar_isShieldActive() then return end
	for i=1,v.nZaps do
		local rot = bone_getRotation(v.zaps[i])
		if entity_collideCircleVsLineAngle(v.n, rot, 64, 900, 8, entity_getPosition(me)) then
			entity_damage(v.n, me, 1)
		end
	end
end

function update(me, dt)
	if entity_isState(me, STATE_DESCEND) and not entity_isInterpolating(me) then
		--entity_setState(me, STATE_IDLE)
		activate(me)
	end
	if entity_getHealthPerc(me) < 0.75 then
		v.hardLevel = 1
	elseif entity_getHealthPerc(me) < 0.90 then
		v.hardLevel = 2
	end
	if v.hardLevel == 2 then
		dt = dt * 1.25
	end
	if not entity_isState(me, STATE_DEATHSCENE) then
		entity_handleShotCollisionsSkeletal(me)
		entity_handleShotCollisions(me)
		
		local bone = entity_collideSkeletalVsCircle(me, v.n)
		if bone ~= 0 then
			local nx,ny = entity_getPosition(v.n)
			local cx,cy = entity_getPosition(me)
			local x = nx-cx
			local y = ny-cy
			x,y = vector_setLength(x,y,2000)
			entity_addVel(v.n, x, y)
			entity_damage(v.n, me, 1)
		end
		entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0, 2000)
	else
		killJellies(me)
	end
	
	if not entity_isState(me, STATE_IDLE) and not entity_isState(me, STATE_DEATHSCENE) then
		if v.hardLevel > 0 then
			v.zapTimer = v.zapTimer + dt
			if v.zapTimer > v.zapGlowStart and v.zapTimer < v.zapStart and not v.zapGlowOn then
				toggleZapGlow(me, true)
			end
			if v.zapTimer > v.zapStart and not v.zapsOn then
				toggleZaps(me, true)
			elseif v.zapTimer > v.zapStart+v.zapTime and v.zapsOn then
				toggleZaps(me, false)
				v.zapTimer = 0
			end
			zapCollision(me, dt)
		end
		local ent = getFirstEntity()
		while ent ~= 0 do
			if ent ~= me and (entity_getEntityType(ent)==ET_AVATAR or entity_isEntityInRange(me, ent, v.farRange)) then
				if not entity_isEntityInRange(me, ent, v.closeRange) or entity_y(ent) > entity_y(me)+512 then
					if not entity_isState(me, STATE_DESCEND) or entity_y(ent) < entity_y(me) then
						if entity_getEntityType(ent) == ET_AVATAR then
							avatar_fallOffWall()
						end
						local nx,ny = entity_getPosition(ent)
						local cx,cy = entity_getPosition(me)
						local x = nx-cx
						local y = ny-cy
						x,y = vector_setLength(x,y,-2000)
						entity_clearVel(ent)
						entity_addVel(ent, x, y)
					end
					
				end
			end
			ent = getNextEntity()
		end
		
		if not entity_isState(me, STATE_DESCEND) then
			v.spawnTimer = v.spawnTimer + dt
			if v.spawnTimer > 10 then
				for i=1,2+v.hardLevel do
					createEntity("EvilJelly", "", entity_getPosition(me))
				end
				v.spawnTimer = 0
			end
		end
	end
	if entity_isState(me, STATE_READY) then
		bone_rotate(v.ring, bone_getRotation(v.ring)+dt*20)
	end
end


function enterState(me)
	if entity_isState(me, STATE_IDLE) then
	elseif entity_isState(me, STATE_READY) then
		if not v.started then
			overrideZoom(0.5, 1)
			playMusic("MiniBoss")
			emote(EMOTE_NAIJAUGH)
			v.started = true
		end
		for i=1,2+v.hardLevel do
			createEntity("EvilJelly", "", entity_getPosition(me))
		end			
	elseif entity_isState(me, STATE_MOVECORE) then
		bone_rotate(v.ring, math.random(360*2)+360*6, 4, 0, 0, 1)
		entity_setStateTime(me, 4)
	elseif entity_isState(me, STATE_DEAD) then
		overrideZoom(0)
	elseif entity_isState(me, STATE_DESCEND) then
		local node = getNode("KINGJELLYPOS")
		entity_setPosition(me, node_x(node), node_y(node), -200, 0, 0, 1)
		--playMusic("inevitable")
	elseif entity_isState(me, STATE_DEATHSCENE) then
		setFlag(FLAG_MINIBOSS_KINGJELLY, 1)
		fadeOutMusic(10)
		entity_setStateTime(me, -1)
		entity_idle(v.n)
		entity_clearVel(v.n)
		entity_flipToEntity(v.n, me)
		for i=1,10 do
			killJellies(me)
			watch(0.1)
			killJellies(me)
		end
		playSfx("BeastForm")
		entity_scale(me, 0.05, 0.05, 4)
		overrideZoom(1, 4)
		watch(4)
		overrideZoom(0)
		
		pickupGem("boss-jelly")
		
		--entity_setStateTime(me, 0)
		entity_delete(me)
	end
end

function exitState(me)
	if entity_isState(me, STATE_MOVECORE) then
		local rot = bone_getRotation(v.ring)
		while rot > 360 do
			rot = rot - 360
		end
		bone_rotate(v.ring, rot)
		entity_setState(me, STATE_READY)
	end
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function hitSurface(me)
	--entity_sound(me, "rock-hit")
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_isState(me, STATE_DESCEND) then
		return false
	end
	if bone == v.ring then
		return false
	end
	if entity_isState(me, STATE_READY) then
		if bone == 0 then
		--[[
			if entity_getHealth(me)-dmg <= 0 then
				deathScene(me)
			end
			]]--
			entity_setState(me, STATE_MOVECORE)
			return true
		end
	end
	if entity_isState(me, STATE_MOVECORE) then
		if bone == 0 then
			return true
		end
	end
	return false
end
