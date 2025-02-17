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
v.spawnedEnemies = false
v.killNode = 0

function init(me)
	setupEntity(me)
	entity_initSkeletal(me, "CC")
	entity_animate(me, "cry", -1)
	
	entity_scale(me, 0.6, 0.6)
end

local function spawnEnemies(me)
	if v.spawnedEnemies then return end
	v.spawnedEnemies = true
	
	entity_idle(v.n)
	debugLog("SPAWNENEMIES: START")

	local ent = getFirstEntity()
	local anEnt = 0
	while ent~=0 do
		if entity_getEntityType(ent) == ET_NEUTRAL and entity_isName(ent, "CC_Kid") then
			anEnt = ent
			entity_animate(ent, "transform")
		end
		ent = getNextEntity()
	end
	
	cam_toEntity(anEnt)
	while entity_isAnimating(anEnt) do
		watch(FRAME_TIME)
	end
	
	ent = getFirstEntity()
	while ent~=0 do
		if entity_getEntityType(ent) == ET_NEUTRAL and entity_isName(ent, "CC_Kid") then
			createEntity("Scavenger", "", entity_getPosition(ent))
			-- play some special animation for spawning
			entity_delete(ent, 0.5)
		end
		ent = getNextEntity()
	end
	
	cam_toEntity(v.n)
	
	debugLog("SPAWNENEMIES: END")
	setFlag(FLAG_SUNKENCITY_PUZZLE, 5)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	if isFlag(FLAG_SUNKENCITY_PUZZLE, 5) then
		spawnEnemies(me)
	elseif isFlag(FLAG_SUNKENCITY_PUZZLE, 6) then
		v.spawnedEnemies = true
	end
	
	v.killNode = getNode("KILL")
end

function update(me, dt)
	if entity_isState(me, STATE_IDLE) then
		if isFlag(FLAG_SUNKENCITY_PUZZLE, 5) then
			local num = node_getNumEntitiesIn(v.killNode, "Scavenger")
			
			if num < 1 then
				setFlag(FLAG_SUNKENCITY_PUZZLE, 6)
				debugLog(msg("You beat the enemies!!!"))
			end
		else
			if not v.spawnedEnemies then
				if entity_isEntityInRange(me, v.n, 128) then
					spawnEnemies(me)
				end
			end
		end
	elseif entity_isState(me, STATE_DONE) then
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "cry", -1)
		entity_setPosition(me, entity_getPosition(me))
	elseif entity_isState(me, STATE_FOLLOW) then
		entity_animate(me, "float", -1)	
	elseif entity_isState(me, STATE_DONE) then
		
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

