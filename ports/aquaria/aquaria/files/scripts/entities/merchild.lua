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

local STATE_CHASE		= 1000
local STATE_RUN			= 1001

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "merchild")
	
	entity_setState(me, STATE_IDLE)
	
	entity_scale(me, 0.55, 0.55)
end

function postInit(me)
	v.n = getNaija()
	

	
	local nd = entity_getNearestNode(me, "skin1")
	if nd~=0 and node_isEntityIn(nd, me) then
		entity_initSkeletal(me, "merchild", "merchild-skin1")
	end
	
	local nd = entity_getNearestNode(me, "flip")
	if nd~=0 and node_isEntityIn(nd, me) then
		entity_fh(me)
	end
	
	if not entity_isState(me, STATE_RUN) then
		entity_animate(me, "idle", -1)
	end
	
	local nd = entity_getNearestNode(me, "chase")
	if nd~=0 and node_isEntityIn(nd, me) then
		local ent = entity_getNearestEntity(me, "merchild")
		entity_setTarget(me, ent)
		entity_msg(ent, "run", me)
		entity_setState(me, STATE_CHASE)
		entity_animate(me, "swim", -1)
		entity_setMaxSpeed(me, 300)
		--entity_initSkeletal(me, "merchild", "merchild-skin1")
	end
	
	
end

function update(me, dt)
	entity_updateMovement(me, dt)
	
	if entity_isState(me, STATE_CHASE) then
		entity_moveTowardsTarget(me, dt, 500)
		entity_doCollisionAvoidance(me, dt, 8, 0.5)
		entity_rotateToVel(me)
		entity_flipToVel(me)
	elseif entity_isState(me, STATE_RUN) then
		entity_moveTowardsTarget(me, dt, -800)
		entity_doCollisionAvoidance(me, dt, 8, 0.5)
		entity_rotateToVel(me)
		entity_flipToVel(me)
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		--entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_CHASE) then
		
	end
end

function msg(me, str, val)
	if str == "run" then
		entity_setTarget(me, val)
		entity_setState(me, STATE_RUN, -1, 1)
		entity_setMaxSpeed(me, 350)
		
		entity_animate(me, "swim", -1)
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

