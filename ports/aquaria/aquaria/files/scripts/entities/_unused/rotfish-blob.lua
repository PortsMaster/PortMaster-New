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

-- rotfish-blob

v.fireDelay = 1
v.moveTimer = 0

function init(me)
	setupBasicEntity(
	me,
	"rotfish-blob",					-- texture
	9,								-- health
	2,								-- manaballamount
	2,								-- exp
	1,								-- money
	64,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)

	entity_setDeathParticleEffect(me, "TinyRedExplode")
	entity_clampToSurface(me)
	
	entity_setSegs(me, 8, 8, 0.5, 0.9, 0, -0.02, 8, 1)
end

function update(me, dt)	
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, 48, 1, 0.1)
	
	entity_moveAlongSurface(me, dt, 40, 6, 50)
	entity_rotateToSurfaceNormal(me, 0.1)
	v.moveTimer = v.moveTimer + dt
	if v.moveTimer > 8 then
		entity_switchSurfaceDirection(me)
		v.moveTimer = 0
	end
	
	if not(entity_hasTarget(me)) then
		entity_findTarget(me, 1200)
	else
		if v.fireDelay > 0 then
			v.fireDelay = v.fireDelay - dt
			if v.fireDelay < 0 then
				-- FIXME: obsolete function
				--entity_fireAtTarget(me, "Purple", 1, 400, 10, 3, 64)
				v.fireDelay = 0.5
			end
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_DEAD) then
		createEntity("Rotfish", "", entity_x(me), entity_y(me)-32)
	end
end

function exitState(me)
end

function hitSurface(me)
end
