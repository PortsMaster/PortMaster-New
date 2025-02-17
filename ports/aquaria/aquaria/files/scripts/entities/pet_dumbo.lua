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

-- P E T  D U M BO

local STATE_ATTACKPREP		= 1000
local STATE_ATTACK			= 1001

v.lungeDelay = 0

v.spinDir = -1

v.rot = 0
v.shotDrop = 0

v.glow = 0

function init(me)
	setupBasicEntity(
	me,
	"",						-- texture
	4,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	4,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1,								-- updateCull -1: disabled, default: 4000
	1
	)
	
	entity_initSkeletal(me, "Dumbo")
	
	entity_setDeathParticleEffect(me, "TinyBlueExplode")

	v.lungeDelay = 1.0
	
	entity_scale(me, 0.6, 0.6)
	
	v.rot = 0
	
	esetv(me, EV_LOOKAT, 0)
	esetv(me, EV_ENTITYDIED, 1)
	esetv(me, EV_TYPEID, EVT_PET)
	
	for i=DT_AVATAR,DT_AVATAR_END do
		entity_setDamageTarget(me, i, false)
	end
	
	--[[
	entity_color(me, 1, 1, 1)
	entity_color(me, 0.6, 0.6, 0.6, 0.5, -1, 1)
	]]--
	

	
	bone_setSegs(entity_getBoneByName(me, "Body"), 2, 16, 0.3, 0.3, -0.03, 0, 6, 1)
	
	entity_initEmitter(me, 0, "DumboGlow")
	entity_startEmitter(me, 0)
	
	entity_setDeathSound(me, "")
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
	
	v.glow = createQuad("Naija/LightFormGlow", 13)
	quad_scale(v.glow, 5 + (getPetPower()*8), 5 + (getPetPower()*8))
	
	if not isInputEnabled() or not entity_isUnderWater(v.n) then
		entity_setPosition(me, entity_x(v.n), entity_y(v.n), 0.3)
		entity_alpha(me, 0, 0.1)
		entity_stopEmitter(me, 0)
		return
	else
		entity_alpha(me, 1, 0.1)
		entity_startEmitter(me, 0)
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
			entity_setPosition(me, entity_getPosition(v.n))
		end
		
		local a = t
		x = x + math.sin(a)*dist
		y = y + math.cos(a)*dist
		if naijaUnder then
			entity_setPosition(me, entity_x(v.n)+x, entity_y(v.n)+y, 0.6)
		end
		
		--entity_handleShotCollisions(me)
	end
	
	if v.glow ~= 0 then
		if entity_isInDarkness(me) then
			quad_alpha(v.glow, 1, 0.5)
		else
			quad_alpha(v.glow, 0, 0.5)
		end
	end
	
	quad_setPosition(v.glow, entity_getPosition(me))
	quad_delete(v.glow, 0.1)
	v.glow = 0
end

function entityDied(me, ent)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_FOLLOW) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_DEAD) then
		if v.glow ~= 0 then
			quad_delete(v.glow)
			v.glow = 0
		end
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
