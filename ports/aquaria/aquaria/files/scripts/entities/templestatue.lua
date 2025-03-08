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
-- TEMPLE STATUE
-- ================================================================================================

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================


-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

v.bone_head = 0

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	15,								-- health
	2,								-- manaballamount
	2,								-- exp
	1,								-- money
	32,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000,							-- updateCull -1: disabled, default: 4000
	0
	)
	entity_setCull(me, false)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "TempleStatue")
	
	v.bone_head = entity_getBoneByName(me, "Head")
	
	entity_setName(me, "TempleStatue")
	entity_setState(me, STATE_IDLE)
end

function update(me, dt)
	if entity_isState(me, STATE_IDLE) or entity_isState(me, STATE_BREAK) then
		entity_setLookAtPoint(me, bone_getWorldPosition(v.bone_head))
	end
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_animate(me, "idle", LOOP_INF)		
	elseif entity_isState(me, STATE_BREAK) then			
		entity_setStateTime(me, entity_animate(me, "break"))
	elseif entity_isState(me, STATE_BROKEN) then
		esetv(me, EV_LOOKAT, 0)
		entity_animate(me, "broken", LOOP_INF)
	end
end

function animationKey(me, key)
end

function exitState(me)
	if entity_isState(me, STATE_BREAK) then
		esetv(me, EV_LOOKAT, 0)
		--entity_setState(me, STATE_BROKEN)
	end
end

function hitSurface(me)
end
