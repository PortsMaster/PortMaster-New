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

local STATE_HIDDEN 		= 1000
local STATE_REVEAL		= 1001
local STATE_FIRE		= 1002

v.bone_shot = 0
v.bone_body = 0
v.bone_whip = 0
v.fireDelay = 0
v.soundDelay = 0
v.whipDeath = false
v.whipHits = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "Horror")
	entity_setAllDamageTargets(me, true)
	
	entity_generateCollisionMask(me)	
	
	entity_setState(me, STATE_HIDDEN)
	
	entity_setUpdateCull(me, 2000)
	entity_setCullRadius(me, 1024)
	
	v.bone_shot = entity_getBoneByName(me, "Shot")
	v.bone_body = entity_getBoneByName(me, "Body")
	v.bone_whip = entity_getBoneByName(me, "Whip")
	bone_alpha(v.bone_shot, 0)
	
	entity_setEntityLayer(me, -2)
	
	entity_setHealth(me, 20)
	entity_setDeathScene(me, true)
	entity_setDeathParticleEffect(me, "BigRedExplode")
	
	entity_setDropChance(me, 50, 1)
	
	entity_setEatType(me, EAT_NONE)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	local flipNode = entity_getNearestNode(me, "FLIP")
	if flipNode ~= 0 then
		if node_isEntityIn(flipNode, me) then
			entity_fh(me)
		end
	end
end

function update(me, dt)
	
	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then
		entity_touchAvatarDamage(me, 0, 1)
	end
	
	
	local x, y = bone_getWorldPosition(v.bone_body)
	if entity_isState(me, STATE_HIDDEN) then
		v.soundDelay = v.soundDelay +dt
		if v.soundDelay > 1 then
			entity_sound(me, "Scuttle")
			v.soundDelay = -math.random(2)
		end
		if entity_y(v.n) > y and y < entity_y(me) + 1024 then
			local spread = 200
			if entity_x(v.n) > entity_x(me)-spread and entity_x(v.n) < entity_x(me)+spread then
				entity_setState(me, STATE_REVEAL)
			end
		end
	end
	
	--entity_updateMovement(me, dt)
	
	if entity_isState(me, STATE_IDLE) then
		v.fireDelay = v.fireDelay + dt
		if v.fireDelay > 1.5 then
			v.fireDelay = -math.random(2)
			entity_setState(me, STATE_FIRE)
		end
	end

	entity_clearTargetPoints(me)
	if not entity_isState(me, STATE_HIDDEN) then
		entity_addTargetPoint(me, x, y)
		local x, y = bone_getWorldPosition(v.bone_whip)
		entity_addTargetPoint(me, x, y)
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		if entity_getAnimationName(me)=="idle" then
		else
			entity_animate(me, "idle", -1)
		end
		--entity_setNaijaReaction(me, "")
	elseif entity_isState(me, STATE_HIDDEN) then
		entity_animate(me, "hidden", -1)
	elseif entity_isState(me, STATE_REVEAL) then
		entity_setStateTime(me, entity_animate(me, "reveal"))
		entity_setNaijaReaction(me, "shock")
		entity_flipToEntity(me, v.n)
	elseif entity_isState(me, STATE_FIRE) then
		entity_setStateTime(me, entity_animate(me, "fireShots", 0, 1))
	elseif entity_isState(me, STATE_DEATHSCENE) then
		--if v.whipDeath then
			bone_alpha(v.bone_whip, 0)
			if chance(50) then
				entity_animate(me, "die")
			else
				entity_animate(me, "die2")
			end

			local x, y = entity_getPosition(me)
			while (isObstructed(x,y) == false) do
				y = y + 20
			end
			entity_setStateTime(me, entity_setPosition(me, x, y, -1000))
			--[[
		else
			entity_setStateTime(me, 0.1)
		end
		]]--
	end
end

function exitState(me)
	if entity_isState(me, STATE_REVEAL) or entity_isState(me, STATE_FIRE) then
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_isState(me, STATE_HIDDEN) then
		entity_setState(me, STATE_REVEAL)
	end
	if bone == v.bone_whip then
		debugLog("whip hit!")
		v.whipHits = v.whipHits + 1
		if damageType == DT_AVATAR_BITE then
			v.whipHits = v.whipHits + 2
		end
		bone_damageFlash(bone)
		--debugLog(string.format("whipHits %d", v.whipHits))
		if v.whipHits >= 8 then
			--debugLog("whipDeath")
			v.whipDeath = true
			--entity_adjustHealth(me, -999)
			entity_setHealth(me, 1)
			return true
		end
		return false
	end
	return true
end

function animationKey(me, key)
	if entity_isState(me, STATE_FIRE) then
		if key == 3 or key == 5 or key == 7 then
			local x, y = bone_getWorldPosition(v.bone_shot)
			local s = createShot("Horror", me, entity_getTarget(me), x, y)
		end
	end
	--[[
	if entity_isState(me, STATE_DEATHSCENE) then
		if key == 3 or key == 5 or key == 7 then
			
		end
	end
	]]--
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

