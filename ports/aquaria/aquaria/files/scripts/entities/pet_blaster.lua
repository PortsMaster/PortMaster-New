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
v.rot2 = 0
v.shotDrop = 0

v.fireDelay = 0
v.shotsFired = 0
v.fig = 1

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
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
	
	entity_initSkeletal(me, "Blaster")
	
	entity_scale(me, 0.5, 0.5)
	
	entity_setDeathParticleEffect(me, "TinyBlueExplode")

	v.lungeDelay = 1.0
	
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
		
		v.rot = v.rot + dt*0.75
		v.rot2 = v.rot2 + dt *0.25
		if v.rot > 1 then
			v.rot = v.rot - 1
			
			if v.fig == 1 then
				v.fig = -1
			else
				v.fig = 1
			end
		end
		if v.rot2 > 1 then
			v.rot2 = v.rot2 - 1
		end
		local dist = 200
		local t = 0
		local t2 = 0
		local x = 0
		local y = 0
		if avatar_isRolling() then
			dist = 90
			v.spinDir = -avatar_getRollDirection()
			t = v.rot * 6.28
			t2 = v.rot2 * 6.28
		else
			t = v.rot * 6.28
			t2 = v.rot2 * 6.28
		end
		
		if not entity_isEntityInRange(me, v.n, 1024) then
			entity_setPosition(me, entity_getPosition(v.n))
		end
		
		x = x + math.cos(t)*dist
		y = y + math.sin(t2)*dist
		
		if naijaUnder then
			entity_setPosition(me, entity_x(v.n)+x, entity_y(v.n)+y, 0.6)
		end
		
		--entity_handleShotCollisions(me)
		
		local ent = entity_getNearestEntity(me, "", 600, ET_ENEMY, DT_AVATAR_ENERGYBLAST)
		if ent~= 0 and not entity_isDamageTarget(ent, DT_AVATAR_PET) then
			ent = 0
		end
		
		local off = 0
		local t = 0.15
		if ent == 0 then
			ent = v.n
			entity_rotateOffset(me, 180)
			t = 0
		else
			
			entity_rotateOffset(me, 0)
		end
		
		if ent ~= 0 then
			entity_rotateToEntity(me, ent, t, off)
		end
		
		v.lungeDelay = v.lungeDelay - dt * (getPetPower()+1)
		if v.lungeDelay < 0 then
			v.fireDelay = v.fireDelay - dt * (getPetPower()+1)
			if v.fireDelay < 0 then			
				if ent ~= 0 and ent ~= v.n then
					local s = createShot("PetBlasterFire", me, ent, entity_x(me), entity_y(me))
					local tx, ty = entity_getTargetPoint(ent, 0)
					local vx = tx - entity_x(me)
					local vy = ty - entity_y(me)
					shot_setAimVector(s, vx, vy)
				end
				v.shotsFired = v.shotsFired + 1
				v.fireDelay = 0.2
			end
			if v.shotsFired >= 3 then
				v.lungeDelay = 3
				v.fireDelay = 0
				v.shotsFired = 0
			end
		end
	end
end

function entityDied(me, ent)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_FOLLOW) then
		entity_animate(me, "idle", -1)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function hitSurface(me)
end

function shiftWorlds(me, old, new)
end
