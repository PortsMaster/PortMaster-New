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

--crying in house
v.n = 0
v.curNote = 1
v.notes = { 1, 3, 4, 5, 1, 3, 4, 2, 1, 3, 4, 0 }

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "CC")	
	entity_setAllDamageTargets(me, false)
		
	entity_scale(me, 0.5, 0.5)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)

	if isFlag(FLAG_SUNKENCITY_BOSS, 1) then
		entity_delete(me)
	elseif getFlag(FLAG_SUNKENCITY_PUZZLE) > 1 then
		local gfNode = getNode("GFGARDEN")
		local gf = createEntity("CC_GF", "", node_x(gfNode), node_y(gfNode))
		entity_delete(me)
	else
		entity_setState(me, STATE_IDLE)
	end	
end

v.done = false
v.inScene = false
local function cutScene(me)
	if v.inScene then return end
	v.done = true
	v.inScene = true
	-- mother arrives, sings song in loop
	msg("You sang the song!")
	entity_idle(v.n)
	cam_toEntity(me)
	watch(1)
	-- girlfriend shows up
	
	local gfNode = getNode("GFAPPEAR")
	local gf = createEntity("CC_GF", "", node_x(gfNode), node_y(gfNode))
	cam_toEntity(gf)
	entity_alpha(gf, 0)
	entity_alpha(gf, 1, 2)
	watch(2)
	entity_moveToNode(gf, getNode("GFGARDEN"), SPEED_NORMAL)
	entity_animate(gf, "float", -1)
	entity_watchForPath(gf)
	entity_animate(gf, "idle", -1)
	watch(1)
	cam_toEntity(v.n)
	
	setFlag(FLAG_SUNKENCITY_PUZZLE, 2)
	cam_toEntity(v.n)
	
	entity_delete(me)
	
	v.inScene = false
end

function update(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "cry", -1)
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
	if isFlag(FLAG_SUNKENCITY_PUZZLE, 1) then
		if v.notes[v.curNote] == note then
			debugLog("note match")
			v.curNote = v.curNote + 1
			if v.curNote >= 13 then
				cutScene(me)
			end
		else
			debugLog("note fail")
			v.curNote = 1
		end
	end
end

function song(me, song)
end

function activate(me)
end

