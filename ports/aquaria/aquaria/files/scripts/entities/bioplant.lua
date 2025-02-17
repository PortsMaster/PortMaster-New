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
-- B I O P L A N T
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.glow = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"abyss-plant-0001",					-- texture
	3,							-- health
	2,							-- manaballamount
	2,							-- exp
	10,							-- money
	16,							-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	256,							-- sprite width	
	256,							-- sprite height
	1,							-- particle "explosion" type, 0 = none
	0,							-- 0/1 hit other entities off/on (uses collideRadius)
	4000,							-- updateCull -1: disabled, default: 4000
	0
	)

	entity_setEntityType(me, ET_NEUTRAL)
	local scale_random = math.random(40) * 0.01
	entity_scale(me, 1.5 + scale_random, 1.5 + scale_random)
	entity_setEntityLayer(me, -3)
end

function update(me, dt)
	v.glow = createQuad("Naija/LightFormGlow", 13)
	quad_scale(v.glow, 10, 10)

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

function enterState(me)
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function exitState(me)
end
