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
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "CC")
	entity_setAllDamageTargets(me, false)
	
	entity_scale(me, 0.6, 0.6)
	entity_setBlendType(me, BLEND_ADD)
	entity_alpha(me, 0.5)
	entity_alpha(me, 1, 1, -1, 1, 1)
	
	entity_fh(me)
	entity_setState(me, STATE_IDLE)
end

function postInit(me)
	v.n = getNaija()
end

v.done = false
v.inScene = false
local function cutScene(me)
	if v.inScene then return end
	v.done = true
	v.inScene = true
	-- mother arrives, sings song in loop
	entity_idle(v.n)
	cam_toEntity(me)
	
	watch(2)
	
	setControlHint("You've made it to the end of the final IGF submission of Aquaria!")
	
	watch(5)
	
	clearControlHint()
	
	fade(1, 3)
	watch(3)
	watch(2)
	voice("Naija_LiKidnapped")
	watchForVoice()
	
	fadeOutMusic(4)
	watch(4)
	
	jumpState("Title")
	
	--inScene = false
end

function update(me, dt)
	if entity_isEntityInRange(me, v.n, 256) then
		cutScene(me)
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "float", -1)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
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

