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

function init(me)
	setupBasicEntity(
	me,
	"breakable/energylamp",		-- texture
	1,							-- health
	1,							-- manaballamount
	1,							-- exp
	1,							-- money
	90,							-- collideRadius
	STATE_IDLE,					-- initState
	128,						-- sprite width	
	256,						-- sprite height
	1,							-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,							-- 0/1 hit other entities off/on (uses collideRadius)
	2000						-- updateCull -1: disabled, default: 4000
	)

	loadSound("energylamp-explode")
	entity_setDeathScene(me, true)
	entity_setDeathSound(me, "energylamp-explode")

	entity_setEatType(me, EAT_NONE)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setUpdateCull(me, 3000)
	esetv(me, EV_LOOKAT, 0)
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	entity_handleShotCollisions(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
	elseif entity_isState(me, STATE_DEATHSCENE) then
		spawnParticleEffect("starexplode", entity_x(me)+10, entity_y(me)+50)
		for i=1,3 do
			debugLog("Spawning")
			local e = createEntity("BrokenPiece", "", entity_x(me), entity_y(me))
			local str = string.format("%s-0001", "breakable/energylamp", i)
			--debugLog(str)
			entity_setTexture(e, str)
		end
		entity_setStateTime(me, 0.1)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return true
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

