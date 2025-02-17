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
v.tongueTarget = 0
v.tongue = 0
v.sx = 0
v.sy = 0
v.attackDelay = 1

function init(me)
	setupEntity(me)
	entity_setEntityLayer(me, -2)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "MossHead")
	--[[
	entity_setAllDamageTargets(me, false)
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
	entity_setDamageTarget(me, DT_AVATAR_BITE, true)
	]]--
	
	entity_generateCollisionMask(me)
	
	entity_setState(me, STATE_IDLE)
	
	v.tongueTarget = entity_getBoneByName(me, "TongueTarget")
	v.tongue = entity_getBoneByName(me, "Tongue")
	bone_alpha(v.tongueTarget)
	
	entity_scale(me, 1.5, 1.5)
	v.sx, v.sy = entity_getScale(me)	
	entity_setCullRadius(me, 1024)
	entity_setUpdateCull(me, 2000)
	
	entity_setDeathScene(me, true)
	entity_setHealth(me, 6)
	
	entity_setEatType(me, EAT_NONE)
	
	loadSound("MossHead")
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	local node = entity_getNearestNode(me, "FLIP")
	if node ~=0 then
		if node_isEntityIn(node, me) then
			entity_fh(me)
		end
	end
end

function update(me, dt)
	entity_clearTargetPoints(me)
	if entity_isState(me, STATE_IDLE) then
		v.attackDelay = v.attackDelay - dt
		if v.attackDelay < 0 then
			if entity_isEntityInRange(me, v.n, 280*v.sx)
			and not isForm(FORM_FISH) then
				entity_setState(me, STATE_ATTACK)
			end			
		end
	elseif entity_isState(me, STATE_ATTACK) then
		entity_handleShotCollisionsSkeletal(me)
		local bone = entity_collideSkeletalVsCircle(me, v.n)
		-- do damage to avatar
		if bone~= 0 then
			if avatar_isTouchHit() then
				entity_damage(v.n, me, 0.5, 500)
			end
		end
			
		local x, y = bone_getWorldPosition(v.tongueTarget)
		entity_addTargetPoint(me, x, y)
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_ATTACK) then
		entity_sound(me, "Mosshead", 900+math.random(100))
		entity_setStateTime(me, entity_animate(me, "attack"))
	elseif entity_isState(me, STATE_DEATHSCENE) then		
		entity_setStateTime(me, entity_animate(me, "die"))
	end
end

function exitState(me)
	if entity_isState(me, STATE_ATTACK) then
		v.attackDelay = 1+math.random(2)
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_isState(me, STATE_ATTACK) then
		if bone == v.tongue then
			if damageType == DT_AVATAR_BITE then
				entity_changeHealth(me, -6)
			end
			return true
		end
	end
	return false
end

function animationKey(me, key)
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
	if chance(10) then
		spawnIngredient("VeggieSoup", entity_x(me), entity_y(me))
	else
		if chance(20) then
			spawnIngredient("VeggieCake", entity_x(me), entity_y(me))
		else
			if chance(50) then
				spawnIngredient("Poultice", entity_x(me), entity_y(me))
			end
		end
	end
end

