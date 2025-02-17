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

-- MOLOCH

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.fireDelay = 2
v.moveTimer = 0
v.charge = 0

local STATE_CHARGE = 1000
local STATE_DELAY = 1001
v.inited = false

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	6,								-- health
	2,								-- manaballamount
	2,								-- exp
	1,								-- money
	48,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	entity_scale(me, 0.75, 0.75)
	entity_setDropChance(me, 25)
	entity_clampToSurface(me)
	entity_setDeathParticleEffect(me, "PurpleExplode")
	entity_initSkeletal(me, "Moloch")
	v.charge = entity_getBoneByName(me, "Charge")
	bone_alpha(v.charge, 0)
	entity_animate(me, "idle")
	v.inited = true
	
	entity_setEatType(me, EAT_FILE, "HotEnergy")
end

function update(me, dt)
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 0.1)

	if entity_isState(me, STATE_IDLE) then
		entity_moveAlongSurface(me, dt, 140, 6, 10)
		entity_rotateToSurfaceNormal(me, 0.1)

		-- entity_rotateToSurfaceNormal(0.1)
		v.moveTimer = v.moveTimer + dt
		if v.moveTimer > 4 then
			entity_switchSurfaceDirection(me)
			v.moveTimer = 0
		end	
		if not(entity_hasTarget(me)) then
			entity_findTarget(me, 1200)
		else
			if v.fireDelay > 0 then
				v.fireDelay = v.fireDelay - dt
				if v.fireDelay < 0 then
					v.fireDelay = 3
					entity_setState(me, STATE_CHARGE)
				end
			end
		end
	end
	if entity_isState(me, STATE_CHARGE) or entity_isState(me, STATE_DELAY) then
		entity_moveAlongSurface(me, dt, 60, 6, 10)
		entity_rotateToSurfaceNormal(me, 0.1)
	end
	if isObstructed(entity_x(me), entity_y(me)) then
		entity_adjustPositionBySurfaceNormal(me, 1)
	end
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		if v.inited then
			bone_setSegs(entity_getBoneByName(me, "Body"), 2, 16, 0.3, 0.3, -0.028, 0, 6, 1)
		end
	elseif entity_isState(me, STATE_CHARGE) then
		local t = 3
		entity_setStateTime(me, t)
		bone_scale(v.charge)
		bone_scale(v.charge, 1.5, 1.5, t)
		--[[
		bone_offset(v.charge, -5)
		bone_offset(v.charge, 5, 0, 0.5, -1)
		]]--
		bone_alpha(v.charge, 1, 0.5)
		bone_setSegs(entity_getBoneByName(me, "Body"), 2, 16, 0.3, 0.3, -0.058, 0, 12, 1)
	elseif entity_isState(me, STATE_DELAY) then
		entity_setStateTime(me, 1)
	end
end

function exitState(me)
	if entity_isState(me, STATE_CHARGE) then
		local sx, sy = bone_getScale(v.charge)
		if sx > 1.2 then
			bone_alpha(v.charge, 0, 0.2)
			--entity_doGlint(me, "Particles/PurpleFlare")
			--local s = entity_fireAtTarget(me, "", 1.5, 700, 500, 3, 64)
			--shot_setNice(s, "Shots/HotEnergy", "HeatTrail", "HeatHit")
			local s = createShot("HotEnergy", me, entity_getTarget(me), bone_getWorldPosition(v.charge))
		end
		entity_setState(me, STATE_DELAY)
	elseif entity_isState(me, STATE_DELAY) then
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me)
	return true
end

function hitSurface(me)
end
