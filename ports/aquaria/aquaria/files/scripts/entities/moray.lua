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
v.attackDelay = 1
v.boneHead = 0
v.attackNum = 0

v.a1 = 0
v.a2 = 0
v.a3 = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "Moray")	
	--entity_setAllDamageTargets(me, false)
	entity_setHealth(me, 10)
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	
	entity_generateCollisionMask(me)	
	
	entity_setState(me, STATE_IDLE)
	
	entity_setCullRadius(me, 512)
	entity_setDeathScene(me, true)
	
	v.boneHead = entity_getBoneByName(me, "Head")
	
	
	v.a1 = entity_getBoneByName(me, "a1")
	v.a2 = entity_getBoneByName(me, "a2")
	v.a3 = entity_getBoneByName(me, "a3")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	local node = entity_getNearestNode(me, "FLIP")
	if node_isEntityIn(node, me) then
		entity_fh(me)
	end
end

function update(me, dt)
	--entity_updateMovement(me, dt)
	entity_clearTargetPoints(me)
	
	if entity_isState(me, STATE_IDLE) then
		if entity_isEntityInRange(me, v.n, 512) then
			v.attackDelay = v.attackDelay - dt
			if v.attackDelay < 0 then
				entity_setState(me, STATE_ATTACK)
			end
		end
	end
	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then
		if entity_isState(me, STATE_ATTACK) then
			--entity_damage(v.n, me, 1)
			entity_touchAvatarDamage(me, 0, 1, 800)
		else
			entity_touchAvatarDamage(me, 0, 0.5, 800)
		end
	end
	
	entity_addTargetPoint(me, bone_getWorldPosition(v.boneHead))
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_DEATHSCENE) then
		entity_setStateTime(me, entity_animate(me, "death")+1)
		entity_setColor(me, 0.2, 0.2, 0.2, entity_getStateTime(me))
	elseif entity_isState(me, STATE_ATTACK) then
		--[[
		atkname = "attack1"
		if entity_y(v.n) < entity_y(me)-16 then
			atkname = "attack2"
		end
		]]--
		local x = entity_x(v.n)
		local y = entity_y(v.n)
		
		local bx, by = bone_getWorldPosition(v.a1)
		local d1 = vector_getLength(x-bx, y-by)
		
		local bx, by = bone_getWorldPosition(v.a2)
		local d2 = vector_getLength(x-bx, y-by)
		
		local bx, by = bone_getWorldPosition(v.a3)
		local d3 = vector_getLength(x-bx, y-by)
		
		--debugLog(string.format("d1: %d, d2: %d, d3: %d", d1, d2, d3))
		
		if d1 < d2 and d1 < d3 then
			v.attackNum = 1
		elseif d2 < d1 and d2 < d3 then
			v.attackNum = 2
		elseif d3 < d1 and d3 < d1 then
			v.attackNum = 3
		else
			v.attackNum = 1
		end
		
			
		entity_setStateTime(me, entity_animate(me, string.format("attack%d", v.attackNum)))
	end
end

function exitState(me)
	if entity_isState(me, STATE_ATTACK) then
		v.attackDelay = 0.5
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	v.attackDelay = v.attackDelay - dmg*2
	entity_setColor(me, 1, 0.5, 0.5)
	entity_setColor(me, 1, 1, 1, 1)
	return true
end

function animationKey(me, key)
	if entity_isState(me, STATE_ATTACK) then
		if key == 2 then
			entity_sound(me, "bite")
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

function dieNormal(me)
	if chance(75) then
		local bx, by = bone_getWorldPosition(v.boneHead)
		if chance(50) then
			spawnIngredient("SmallEgg", bx , by)
		else
			spawnIngredient("EelOil", bx, by)
		end
	end
end

