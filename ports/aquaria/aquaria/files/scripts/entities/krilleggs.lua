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

-- KRILL EGG

v.growTimer = 0
v.scaling = false

function init(me)
	setupBasicEntity(
	me,
	"Krill/KrillEggs",					-- texture
	3,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	32,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	64,								-- sprite width	
	64,								-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	2000,							-- updateCull -1: disabled, default: 4000
	-1
	)
	entity_setAllDamageTargets(me, false)
	entity_setDamageTarget(me, DT_AVATAR_BITE, true)
	v.growTimer = 6 + math.random(3)	
end

function update(me, dt)
	if not v.scaling and not entity_isNearObstruction(me, 1) then
		entity_addVel(me, 0, 98*dt)
		entity_updateCurrents(me, dt)
		entity_updateMovement(me, dt)
	else
		entity_rotateToSurfaceNormal(me)
		if entity_isState(me, STATE_IDLE) then
			v.growTimer = v.growTimer - dt
			if v.growTimer < 2 and not v.scaling then
				v.scaling = true
				--entity_setInternalOffset(me, 0, 0.5, 0.1, -1)
				entity_scale(me, 1.2, 1, 0.2, -1, 1)
				entity_alpha(me, 0.01, 1)
				
				local ent = createEntity("Krill", "", entity_getPosition(me))
				entity_rotate(ent, entity_getRotation(me))
				entity_setState(ent, STATE_GROW)			
			end
			if v.growTimer < 0 then
				entity_delete(me)
				v.growTimer = 999
			end
		end
	end
	if not v.scaling then
		entity_handleShotCollisions(me)
	end
end

function enterState(me)
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		entity_changeHealth(me, -100)
	end
	return true
end

function exitState(me)
end
