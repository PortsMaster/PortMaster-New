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

v.head = 0
v.leftarm = 0
v.rightarm = 0
v.legs = 0
v.feet = 0
v.chest = 0

v.b = nil
v.cb = 1
v.maxb = 6

v.dad = 0

v.soundDelay = 0.4

function init(me)
	setupEntity(me)
	entity_initSkeletal(me, "ClayStatue")	
	entity_setAllDamageTargets(me, false)
		
	v.b = {}
	v.b[6] = entity_getBoneByName(me, "Head")
	v.b[4] = entity_getBoneByName(me, "LeftArm")
	v.b[5] = entity_getBoneByName(me, "RightArm")
	v.b[2] = entity_getBoneByName(me, "Legs")
	v.b[1] = entity_getBoneByName(me, "Feet")
	v.b[3] = entity_getBoneByName(me, "Chest")
	
	for i=1,v.maxb,1 do
		bone_alpha(v.b[i], 0.04)
	end
	
	entity_setState(me, STATE_IDLE)
	
	loadSound("claystatue-crumble")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	if entity_isState(me, STATE_IDLE) then
		if v.dad == 0 then
			v.dad = entity_getNearestEntity(me, "SunkenDad")
		else
			--debugLog("checking for dad")
			if entity_isEntityInRange(me, v.dad, 500) then
				debugLog("dad in range")
				entity_setState(me, STATE_BREAK)
			end
		end
	elseif entity_isState(me, STATE_BREAK) then
		if v.soundDelay > 0 then
			v.soundDelay = v.soundDelay - dt
			if v.soundDelay <= 0 then
				playSfx("claystatue-crumble")
			end
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_BREAK) then
		
		entity_animate(me, "break")
	end
end

function exitState(me)
end

function msg(me, msg)
	if msg == "p" then
		bone_alpha(v.b[v.cb], 1, 1)
		v.cb = v.cb + 1
		bone_alpha(v.b[v.cb], 1, 1)
		v.cb = v.cb + 1
	end
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

