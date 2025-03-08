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

-- P E T  N A U T I L U S

local STATE_ATTACKPREP		= 1000
local STATE_ATTACK			= 1001

v.lungeDelay = 0

v.spinDir = -1

v.rot = 0
v.shotDrop = 0

function init(me)
	setupBasicEntity(
	me,
	"Piranha",						-- texture
	4,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	0,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1,								-- updateCull -1: disabled, default: 4000
	1
	)
	
	entity_setDeathParticleEffect(me, "TinyBlueExplode")
	
	--entity_rotate(me, 360, 1, LOOP_INF)
	v.lungeDelay = 1.0
	
	entity_scale(me, 0.6, 0.6)
	
	v.rot = 0
	
	esetv(me, EV_LOOKAT, 0)
	esetv(me, EV_ENTITYDIED, 1)
	esetv(me, EV_TYPEID, EVT_PET)
	
	for i=DT_AVATAR,DT_AVATAR_END do
		entity_setDamageTarget(me, i, false)
	end
end

function postInit(me)
	v.n = getNaija()
end

v.distTimer = 0
v.tpoint = 0

function update(me, dt)
	if getPetPower()==1 then
		entity_setColor(me, 1, 0.5, 0.5, 0.1)
	else
		entity_setColor(me, 1, 1, 1, 1)
	end
	
	if not isInputEnabled() or not entity_isUnderWater(v.n) then
		entity_setPosition(me, entity_x(v.n), entity_y(v.n), 0.3)
		entity_alpha(me, 0, 0.1)
		return
	else
		entity_alpha(me, 1, 0.1)
	end
	
	local naijaUnder = entity_y(v.n) > getWaterLevel()
	if naijaUnder then
		if entity_y(me)-32 < getWaterLevel() then
			entity_setPosition(me, entity_x(me), getWaterLevel()+32)
		end
	else
		if entity_isState(me, STATE_FOLLOW) then
			entity_setPosition(me, entity_x(v.n), entity_y(v.n), 0.1)
		end
	end
	
	if entity_isState(me, STATE_FOLLOW) then
		local target = v.n
		
		v.rot = v.rot + dt*0.2
		if v.rot > 1 then
			v.rot = v.rot - 1
		end
		local dist = 100
		local t = 0
		local x = 0
		local y = 0
		if avatar_isRolling() then
			dist = 90
			v.spinDir = -avatar_getRollDirection()
			t = v.rot * 6.28
		else
			t = v.rot * 6.28
		end
		
		if not entity_isEntityInRange(me, v.n, 1024) then
			entity_setTarget(me, 0)
			entity_setPosition(me, entity_getPosition(v.n))
		end
		
		local cx = entity_x(v.n)
		local cy = entity_y(v.n)
		
		local spd = 0.6
		
		if entity_hasTarget(me) then
			target = entity_getTarget(me)
			if target ~= 0 then
				--[[
				ox, oy = entity_getOffset(target)
				cx = entity_x(target) + ox + entity_velx(target)
				cy = entity_y(target) + oy + entity_vely(target)
				]]--
				cx, cy = entity_getTargetPoint(target, v.tpoint)
				cx = cx + entity_velx(target)
				cy = cy + entity_vely(target)
				dist = 40
			end
			
			--debugLog(string.format("distTimer: %f", v.distTimer))
			v.distTimer = v.distTimer + dt * 0.5
			if v.distTimer > 1 then
				v.distTimer = 0
			end
			
			dist = dist - v.distTimer * 40
			
			if dist < 16 then
				v.shotDrop = v.shotDrop - dt
				if v.shotDrop < 0 then
					createShot("PetPiranha", me, 0, entity_x(me), entity_y(me))
					v.shotDrop = 0.3
					spd = 0.4
				end
			end
		end
		
		if target ~= 0 then
			entity_flipToEntity(me, target)
			entity_rotateToEntity(me, target)
		end
		
		local a = t
		x = x + math.sin(a)*dist
		y = y + math.cos(a)*dist
		entity_setPosition(me, cx+x, cy+y, spd)
		
		--entity_handleShotCollisions(me)
		
		entity_rotateToEntity(me, v.n, 0.1)
		v.lungeDelay = v.lungeDelay - (dt * getPetPower()+1)
		if v.lungeDelay < 0 then
			v.lungeDelay = 2.5
			local ent = entity_getNearestEntity(me, "", 512, ET_ENEMY, DT_AVATAR_PET)
			if ent ~= 0 and entity_isDamageTarget(ent, DT_AVATAR_PETBITE) then
				--[[
				entity_setTarget(me, ent)
				entity_setState(me, STATE_ATTACKPREP, 0.5)
				]]--
				entity_setTarget(me, ent)
				v.tpoint = entity_getRandomTargetPoint(ent)
				--entity_moveTowardsTarget(me, 1, 400)
			end
		end
	end
	if entity_isState(me, STATE_ATTACK) then
		entity_updateMovement(me, dt)

		entity_moveTowardsTarget(me, dt, 5000)
	end
end

function entityDied(me, ent)
	debugLog("Pet_Nautilus: entity died")
	local t = entity_getTarget(me)
	if t ~= 0 then
		debugLog(string.format("target name: %s", entity_getName(t)))
	end
	if ent == entity_getTarget(me) then
		debugLog("Pet_Nautilus: Clearing target")
		entity_setTarget(me, 0)
		entity_setState(me, STATE_FOLLOW)
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
	elseif entity_isState(me, STATE_FOLLOW) then
	elseif entity_isState(me, STATE_ATTACKPREP) then
		entity_setMaxSpeed(me, 0)
		entity_doGlint(me, "Glint", BLEND_ADD)
	elseif entity_isState(me, STATE_ATTACK) then
		v.shotDrop = 0
		entity_enableMotionBlur(me)
		entity_setMaxSpeed(me, 1000)
		entity_moveTowardsTarget(me, 1, 10000)
	end
end

function exitState(me)
	if entity_isState(me, STATE_ATTACKPREP) then
		entity_setState(me, STATE_ATTACK, 0.5)
	elseif entity_isState(me, STATE_ATTACK) then
		entity_disableMotionBlur(me)
		entity_setState(me, STATE_FOLLOW)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function hitSurface(me)
end

function shiftWorlds(me, old, new)
end
