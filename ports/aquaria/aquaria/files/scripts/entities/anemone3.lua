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
-- A N E M O N E
-- ================================================================================================

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"Anemone-0003",						-- texture
	9,								-- health
	1,								-- manaballamount
	1,								-- exp
	0,								-- money
	48,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	256,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	entity_setSegs(me, 2, 10, 6.0, 4.0, -0.02, 0, 2.5, 1)
	entity_setDeathParticleEffect(me, "AnemoneExplode")
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
	entity_setDamageTarget(me, DT_AVATAR_SHOCK, false)
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	entity_setTargetPriority(me, -1)
end

function update(me, dt)
	entity_handleShotCollisions(me)
	local dmg = 0.5
	if isForm(FORM_NATURE) then
		dmg = 0
	end
	if entity_touchAvatarDamage(me, 48, dmg, 1200) then
		--entity_push(getNaija(), 1200, 1, 0)
	elseif entity_touchAvatarDamage(me, 48, dmg, 1200, 0, 0, -40) then
	elseif entity_touchAvatarDamage(me, 48, dmg, 1200, 0, 0, -80) then
	end
	local range = 1024
	local size = 1.0
	if entity_isEntityInRange(me, getNaija(), range) then
		local dist = entity_getDistanceToEntity(me, getNaija())
		dist = size - (dist/range)*size
		local sz = 1 + dist
		entity_scale(me, 1, sz)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function enterState()
end

function exitState()
end

function hitSurface()
end
