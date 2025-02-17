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
v.myWeight = 0
function v.commonInit(me, gfx, r)
	-- note: if you want to add different weight to each rock, then
	-- send it through here
	if r == 0 then
		r = 80
	end
	setupEntity(me, gfx, -1)
	entity_setProperty(me, EP_MOVABLE, true)
	entity_setProperty(me, EP_BLOCKER, true)
	v.myWeight = 400
	entity_setCollideRadius(me, r)
	entity_setBounce(me, 0.2)	
	entity_setCanLeaveWater(me, true)
	
	entity_setAllDamageTargets(me, false)
	
	esetv(me, EV_TYPEID, EVT_ROCK)
end

function postInit(me)
	v.n = getNaija()
end

function v.commonUpdate(me, dt)
	
	--entity_updateCurrents(me)
	entity_updateMovement(me, dt)
	
	if entity_checkSplash(me) then
	end
	if not entity_isUnderWater(me) then
		if not entity_isBeingPulled(me) then
			entity_setWeight(me, v.myWeight*2)
			entity_setMaxSpeedLerp(me, 5, 0.1)
		end
	else
		entity_setMaxSpeedLerp(me, 1, 0.1)
		entity_setWeight(me, v.myWeight)
	end
	
	
	if not entity_isBeingPulled(me) then
		if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0) then
			if avatar_isBursting() and entity_setBoneLock(v.n, me) then
				-- yay!
			else
				--[[
				x, y = entity_getVectorToEntity(me, v.n, 1000)
				entity_addVel(n, x, y)
				]]--
			end
		end
	else
		if entity_getBoneLockEntity(v.n) == me then
			avatar_fallOffWall()
		end
	end
	
	entity_handleShotCollisions(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function enterState(me)
end

function exitState(me)
end

function hitSurface(me)
end

function activate(me)
end
