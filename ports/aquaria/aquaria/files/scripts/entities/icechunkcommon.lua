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
-- I C E   C H U N K   C O M M O N   S C R I P T
-- ================================================================================================

-- ================================================================================================
-- L O C A L   V A R I A B L E S
-- ================================================================================================

v.n = 0

v.chunkSize = 0
v.width = 0
v.dir = -1
 
-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function v.commonInit(me, size)
	v.maxSpeed = 321 + math.random(32)
	v.chunkSize = size

	setupBasicEntity(
	me,
	"IceChunk/Large",				-- texture
	8,								-- health
	1,								-- manaballamount
	1,								-- exp
	0,								-- money
	64,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	512,							-- sprite width	
	512,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	loadSound("IceChunkBreak")
	
	entity_setEntityType(me, ET_NEUTRAL)
	--entity_setAllDamageTargets(me, false)
	--entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_BITE, false)
	
	entity_setDeathScene(me, true)
	
	-- SLIGHT SCALE AND COLOUR VARIATION
	local sz = 0.8 + (math.random(400) * 0.001)
	entity_scale(me, sz, sz)
	local cl = 1.0 - (math.random(2345) * 0.0001)
	entity_color(me, cl, cl, cl)
	
	-- IF LARGE
	if v.chunkSize <= 0 then
		v.chunkSize = 0
		entity_setTexture(me, "IceChunk/Large")
		v.width = 154 
		entity_setHealth(me, 8)
	
	-- IF MEDIUM
	elseif v.chunkSize == 1 then
		v.chunkSize = 1
		entity_setTexture(me, "IceChunk/Medium")
		v.width = 76
		entity_setHealth(me, 4)
		v.maxSpeed = v.maxSpeed * 1.23
	
	-- IF SMALL
	else
		v.chunkSize = 2
		entity_setTexture(me, "IceChunk/Small")
		v.width = 42
		entity_setHealth(me, 2)
		v.maxSpeed = v.maxSpeed * 1.54
	end
	
	v.width = v.width * sz
	entity_setCollideRadius(me, v.width)
	entity_setDeathSound(me, "")
	entity_alpha(me, 0.9)
end

function postInit(me)
	v.n = getNaija()

	entity_setMaxSpeed(me, v.maxSpeed)
	entity_rotate(me, randAngle360())
	entity_addRandomVel(me, 123)
	
	if chance(50) then v.dir = 1 end
end

function update(me, dt)
	entity_clearTargetPoints(me)
	
	-- ROTATE GENTLY
	local rotSpeed = (entity_getVelLen(me)/300) + 1
	if entity_velx(me) < 0 then v.dir = -1
	else v.dir = 1 end
	entity_rotateTo(me, entity_getRotation(me) + (rotSpeed * v.dir))
	
	-- IF LARGE
	if v.chunkSize == 0 then
		-- LOCK ON TO BIG CHUNK
		if entity_touchAvatarDamage(me, v.width*1.1, 0) then
			if avatar_isBursting() and entity_setBoneLock(v.n, me) then
			else
				local vecX, vecY = entity_getVectorToEntity(me, v.n, 1000)
				entity_addVel(v.n, vecX, vecY)
			end
		end
		
		if entity_getBoneLockEntity(v.n) ~= me and entity_touchAvatarDamage(me, v.width, 0, 321) then
		end
	
	-- IF MEDIUM
	elseif v.chunkSize == 1 then
		-- NAIJA COLLISION
		if entity_getBoneLockEntity(v.n) ~= me and entity_touchAvatarDamage(me, v.width, 0, 210) then
			if avatar_isBursting() then
				entity_moveTowards(me, entity_x(getNaija()), entity_y(getNaija()), 1, -456)
			else
				entity_moveTowards(me, entity_x(getNaija()), entity_y(getNaija()), 1, -87)
			end
		end
	
	-- IF SMALL
	elseif v.chunkSize == 2 then
		-- NAIJA COLLISION
		if entity_getBoneLockEntity(v.n) ~= me and entity_touchAvatarDamage(me, v.width, 0, 128) then
			if avatar_isBursting() then
				entity_moveTowards(me, entity_x(getNaija()), entity_y(getNaija()), 1, -1234)
			else
				entity_moveTowards(me, entity_x(getNaija()), entity_y(getNaija()), 1, -128)
			end
		end
	end

	-- AVOIDANCE
	if entity_getBoneLockEntity(v.n) ~= me then entity_doEntityAvoidance(me, dt, v.width*1.1, 1.23) end
	entity_doCollisionAvoidance(me, dt, ((v.width*0.01)*7)+1, 0.421)
	-- MOVEMENT
	if entity_getVelLen(me) > 64 then entity_doFriction(me, dt, 42) end
	entity_updateMovement(me, dt)
	-- SHOT COLLISIONS
	entity_handleShotCollisions(me)
end

function enterState(me)
	if entity_getState(me) == STATE_IDLE then
	
	elseif entity_getState(me) == STATE_DEATHSCENE then
		local deathTime = 0.23
		entity_setStateTime(me, deathTime)
		entity_alpha(me, 0, deathTime)
		entity_scale(me, 0, 0, deathTime)
		entity_delete(me, deathTime)
		
		entity_sound(me, "IceChunkBreak")
		
		if v.chunkSize ~= 2 then
			for i=1,3 do
				local newChunk
				if v.chunkSize == 0 then
					newChunk = createEntity("IceChunkMedium", "", entity_x(me) + (math.random(8) - 4), entity_y(me) + (math.random(8) - 4))
				else
					newChunk = createEntity("IceChunkSmall", "", entity_x(me) + (math.random(4) - 2), entity_y(me) + (math.random(4) - 2))
				end
				entity_moveTowards(newChunk, entity_x(me), entity_y(me), 1, -321)
			end
		end
	end
end

function exitState(me)
end

function hitSurface(me)
	
	
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function activate(me)
end
