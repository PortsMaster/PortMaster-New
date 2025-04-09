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


function init(me, initDir)
	setupBasicEntity(
	me,
	"Abyss-Spikes",					-- texture
	10,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	90,								-- collideRadius
	STATE_IDLE,						-- initState
	256,							-- sprite width	
	256,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	2000							-- updateCull -1: disabled, default: 4000
	)
	entity_setAllDamageTargets(me, false)
	--entity_setCullRadius(me, 64)
end

function postInit(me)
end

function update(me, dt)
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0.5, 500)
end

function enterState(me)
end

function exitState(me)
end

function hitSurface(me)
end

function activate(me)
end

function damage(me)
	return false
end
