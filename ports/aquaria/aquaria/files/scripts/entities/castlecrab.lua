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
v.sx = 0
v.sy = 0
v.fireDelay = 0

v.frontHand = 0
v.backHand = 0

function init(me)
	v.attackDelay = 1 + math.random(100)/100

	setupEntity(me)
	entity_setEntityLayer(me, -2)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "CastleCrab")
	entity_setDamageTarget(me, DT_AVATAR_BITE, false)
	entity_setCollideRadius(me, 96)
	
	entity_setState(me, STATE_IDLE)
	entity_setHealth(me, 6)
	
	--entity_scale(me, 1.5, 1.5)
	v.sx,v.sy = entity_getScale(me)	
	--entity_setCullRadius(me, 1024)
	--entity_setUpdateCull(me, 2000)
	entity_setDeathScene(me, true)
	
	entity_setEatType(me, EAT_NONE)
	
	v.frontHand = entity_getBoneByName(me, "FrontHand")
	v.backHand = entity_getBoneByName(me, "BackHand")
	
	entity_setCullRadius(me, 512)
	
	loadSound("castlecrab-die")
	
	--entity_setDeathSound(me, "rockhit")
	
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
	if entity_isState(me, STATE_IDLE) then
		v.attackDelay = v.attackDelay - dt
		if v.attackDelay < 0 then
			if entity_isEntityInRange(me, v.n, 2800*v.sx)
			and not isForm(FORM_FISH) then
				v.fireDelay = 1
				entity_setState(me, STATE_ATTACK)
			end			
		end
	elseif entity_isState(me, STATE_ATTACK) then
		--[[
		v.fireDelay = v.fireDelay - dt
		if v.fireDelay < 0 then
			v.fireDelay = 1
			local s = createShot("Orbiter", me, entity_getTarget(me))
			shot_setOut(s, 32)
		end
		]]--
	end
	entity_handleShotCollisions(me)
	
	entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0.5, 500)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_ATTACK) then
		--entity_sound(me, "Mosshead", 900+math.random(100))
		entity_setStateTime(me, entity_animate(me, "attack"))
	elseif entity_isState(me, STATE_DEATHSCENE) then
		entity_sound(me, "castlecrab-die")
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
		return true
	else
		return false
	end
end

function animationKey(me, key)
	if entity_isState(me, STATE_ATTACK) then
		if key == 4 or key == 13 then
			local bx = 0
			local by = 0
			if key == 4 then
				bx, by = bone_getWorldPosition(v.frontHand)
			else
				bx, by = bone_getWorldPosition(v.backHand)
			end
			local s = createShot("smallrock", me, entity_getTarget(me), bx, by)
			--shot_setOut(s, 32)
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
	--[[
	local x = entity_x(me)
	local y = entity_y(me)
	
	if isObstructedBlock(x, y, 2) then
		x = entity_x(me)
		y = entity_y(me)-40
		
		if isObstructed(x, y, 2) then
			x = entity_x(me)
			y = entity_y(me)+40
		end
	end
	]]--
	
	local bx, by = bone_getWorldPosition(v.frontHand)
	
	local e = createEntity("Rock0006", "", bx, by)
	entity_alpha(e, 0)
	entity_alpha(e, 1, 1)
end

