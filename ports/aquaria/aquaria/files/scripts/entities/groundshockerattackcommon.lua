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
-- G R O U N D   S H O C K E R   A T T A C K
-- ================================================================================================

-- ================================================================================================
-- L O C A L   V A R I A B L E S 
-- ================================================================================================

v.direction = 0
v.life = 0.87

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function v.commonInit(me, dir)
	setupBasicEntity(
	me,
	"GroundShocker/Shell",			-- texture
	7,								-- health
	1,								-- manaballamount
	0,								-- exp
	0,								-- money
	64,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	2000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setDeathParticleEffect(me, "Explode")
	
	entity_setAllDamageTargets(me, false)
	
	esetv(me, EV_WALLOUT, 4)
	esetvf(me, EV_CLAMPTRANSF, 0.2)
	entity_clampToSurface(me)
	
	--entity_scale(me, 0.87, 0.87)
	--entity_alpha(me, 0.87)
	
	entity_alpha(me, 0)
	entity_scale(me, 0)
	
	v.direction = dir
end

function postInit(me)
	entity_setState(me, STATE_IDLE)
	
	-- FLIP HORIZONTALLY
	if v.direction >= 1 then 
		entity_fh(me)
		entity_switchSurfaceDirection(me)
	end
end

function update(me, dt)
	-- DESTROY AFTER TIME
	v.life = v.life - dt
	if v.life <= 0 then
		entity_alpha(me, 0, 0.23)
		entity_scale(me, 0, 0, 0.23)
		entity_delete(me, 0.23)
		spawnParticleEffect("GroundShockerShellDestroy", entity_x(me), entity_y(me))
	end
	
	spawnParticleEffect("GroundShockerAttack", entity_x(me), entity_y(me))

	-- MOVE ALONG SURFACE
	if eisv(me, EV_CLAMPING, 0) then	
		entity_moveAlongSurface(me, dt, 640)
	end
	entity_rotateToSurfaceNormal(me, 0.1)
	
	entity_touchAvatarDamage(me, 64, 0.69, 420)
end

function enterState(me)
	if entity_getState(me) == STATE_IDLE then
		entity_animate(me, "idle", LOOP_INF)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function hitSurface(me)
end
