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

v.flag = 0
local STATE_BUSTED	= 1001

function init(me)
	setupEntity(me, "Fan", ET_ENEMY)
	entity_setCollideRadius(me, 64)
	entity_setHealth(me, 12)
	if entity_isFlag(me, 1) then
		entity_setState(me, STATE_BUSTED)
	else
		entity_setState(me, STATE_IDLE)
	end
	--[[
	v.flag = f
	if isFlag(f, 1) then
		entity_setState(me, STATE_BUSTED)
	else
		entity_setState(me, STATE_IDLE)
	end
	]]--
end

function enterState(me, state)
	if entity_isState(me, STATE_BUSTED) then
		debugLog("SETTING BUSTED")
		entity_setFlag(me, 1)
		local node = entity_getNearestNode(me)
		node_setActive(node, false)
	end	
end

function exitState(me, state)
end

function update(me, dt)
	entity_handleShotCollisions(me, dt)
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_CRUSH then
		if entity_isState(me, STATE_IDLE) then		
			entity_setState(me, STATE_BUSTED)
		end
	end
	return false
end
