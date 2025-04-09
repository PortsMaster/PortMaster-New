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
-- PHONOGRAPH
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.activeTimer = 0
v.noteToPlay = 0
v.noteDelay = 0

v.singer = true

v.singTimer = 0

v.bubbles = 0
v.body = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	3,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	16,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	256,							-- sprite width	
	256,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000,							-- updateCull -1: disabled, default: 4000
	0
	)
	
	entity_initSkeletal(me, "Phonograph")
	
	entity_setEntityType(me, ET_NEUTRAL)
	
	entity_animate(me, "idle", -1)
	
	v.bubbles = entity_getBoneByName(me, "Bubbles")
	v.body = entity_getBoneByName(me, "Body")
	
	
	
	--[[
	for i=0,7 do
		loadSound(getNoteName(i, "low-"))
	end
	]]--
end

function postInit(me)
	if v.singer then
		local e = getFirstEntity()
		while e ~= 0 do
			if e ~= me and entity_isName(e, entity_getName(me)) and entity_isEntityInRange(me, e, 1024) then	
				entity_msg(e, "no-sing")
			end
			e = getNextEntity()
		end
	end
end

function songNote(me, note)
	if entity_isEntityInRange(me, getNaija(), 600) then
		v.noteToPlay = note
		v.noteDelay = 0.2
	end
end

function songNoteDone(me, note)
end

function update(me, dt)
	if v.noteDelay > 0 then
		v.noteDelay = v.noteDelay - dt
		if v.noteDelay < 0 then
			if v.singer then
				entity_sound(me, getNoteName(v.noteToPlay, "low-"), 1, 2)
			end
			if v.activeTimer == 0 then
				debugLog("bone segs")
				bone_setSegs(v.body, 2, 8, 0.7, 0.1, -0.018, 0, 10, 1)
			end
			v.activeTimer = 2
		end
	end
	if v.activeTimer > 0 then
		v.singTimer = v.singTimer + dt
		if v.singTimer > 0.8 then
			local x, y = bone_getWorldPosition(v.bubbles)
			spawnParticleEffect("bubble-release", x, y)
			v.singTimer = 0
		end
		v.activeTimer = v.activeTimer - dt
		if v.activeTimer < 0 then
			v.activeTimer = 0
			bone_setSegs(v.body, 2, 8, 0.7, 0.1, -0.018, 0, 2, 1)
		end
	end
	if v.activeTimer == 0 then
		v.singTimer = v.singTimer - dt * 2
		if v.singTimer < 0 then
			v.singTimer = 0
		end
	end
end

function enterState(me)
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function exitState(me)
end

function msg(me, msg)
	if msg == "no-sing" then
		debugLog("no sing")
		v.singer = false
	end
end

