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


local STATE_SLEEP			= 1000
local STATE_DANCE			= 1001

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "ForestSprite")	
	
	entity_setEntityLayer(me, 1)
	
	
	entity_setState(me, STATE_IDLE)
	
	entity_scale(me, 0.5, 0.5)
	
	entity_setMaxSpeed(me, 200)
end

function postInit(me)
	local node = entity_getNearestNode(me, "DANCE")
	if node ~= 0 and node_isEntityIn(node, me) then
		entity_setState(me, STATE_DANCE, -1, 1)
	else
		node = entity_getNearestNode(me, "SLEEP")
		if node ~= 0 and node_isEntityIn(node, me) then
			entity_setState(me, STATE_SLEEP, -1, 1)
		end
	end
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

v.seen = false

function update(me, dt)
	if entity_isState(me, STATE_IDLE) then
		entity_updateMovement(me, dt)
		entity_doCollisionAvoidance(me, dt, 8, 0.01)
		entity_flipToVel(me)
	end
	
	if entity_isState(me, STATE_SLEEP) and entity_isEntityInRange(me, v.n, 700) and not v.seen then
		v.seen = true
		emote(EMOTE_NAIJAGIGGLE)
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_SLEEP) then
		entity_animate(me, "sleep", -1)
	elseif entity_isState(me, STATE_DANCE) then
		-- switch off flag
		entity_fh(me)
		if isFlag(FLAG_BOSS_FOREST, 0) then
			entity_setStateTime(me, entity_animate(me, "dance1"))
		else
			entity_setStateTime(me, entity_animate(me, "dance2"))
		end
	end
end

function exitState(me)
	if entity_isState(me, STATE_DANCE) then
		entity_setState(me, STATE_DANCE)
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

