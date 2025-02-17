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
-- SONG STALK
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.glow = 0
v.activeTimer = 0
v.bulb = 0

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
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000,							-- updateCull -1: disabled, default: 4000
	0
	)
	
	entity_setEntityType(me, ET_NEUTRAL)
	
	entity_initSkeletal(me, "SongStalk")
	v.glow = entity_getBoneByName(me, "Glow")
	v.bulb = entity_getBoneByName(me, "Bulb")	
		
	entity_setState(me, STATE_IDLE)
	
	entity_setCull(me, false)
end

function songNote(me, note)
	if entity_isState(me, STATE_IDLE) then
		entity_setState(me, STATE_ACTIVE)
	end
	v.activeTimer = 3.5
	local transTime = 0.5
	local r,g,b = getNoteColor(note)
	bone_setColor(v.glow, r,g,b, transTime)
end

function update(me, dt)
	if entity_isState(me, STATE_ACTIVE) then
		if v.activeTimer > 0 then
			v.activeTimer = v.activeTimer - dt
			if v.activeTimer <= 0 then
				entity_setState(me, STATE_IDLE)
			end
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then		
		entity_animate(me, "idle")
		if v.glow ~= 0 then
			bone_setSegs(v.bulb, 2, 8, 0.8, 0.1, -0.018, 0, 6, 1)
			bone_setColor(v.glow, 1, 1, 1, 1)
		end
	elseif entity_isState(me, STATE_ACTIVE) then
		bone_setSegs(v.bulb, 2, 8, 0.8, 0.1, -0.018, 0, 20, 1)
		--entity_animate(me, "wave", LOOP_INF)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function exitState(me)
end
