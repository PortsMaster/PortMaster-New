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

-- get beat up by CC_BeatCat
v.n = 0

local function createKid(node)
--[[
	local x = node_x(node)
	local y = node_y(node)
	]]--
	local ent = createEntity("CC_Kid", "", node_getPosition(node))
	entity_alpha(ent, 0)
	entity_alpha(ent, 1, 2)
end

local function createRockScene(me)
	createKid(getNode("ROCKKID1"))
	createKid(getNode("ROCKKID2"))
	createKid(getNode("ROCKKID3"))
	createEntity("CC_GetRocked", "", node_getPosition(getNode("CCGETROCKED")))
	-- add creator getting whalloped
end

function init(me)
	setupEntity(me)
	entity_initSkeletal(me, "CC_Cat")
		
	entity_setState(me, STATE_IDLE)
	
	entity_scale(me, 0.5, 0.5)
	entity_setActivation(me, AT_CLICK, 64, 512)
	
	if isFlag(FLAG_SUNKENCITY_PUZZLE, 4) or isFlag(FLAG_SUNKENCITY_PUZZLE, 5) then
		createRockScene(me)
	end
	if getFlag(FLAG_SUNKENCITY_PUZZLE)>5 then
		-- delete dude
	end
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	if getForm() == FORM_BEAST and isFlag(FLAG_SUNKENCITY_PUZZLE, 3) then
		entity_setActivationType(me, AT_CLICK)
	elseif getForm() == FORM_BEAST and isFlag(FLAG_SUNKENCITY_PUZZLE, 6) then		
		entity_setActivationType(me, AT_CLICK)
	else
		entity_setActivationType(me, AT_NONE)
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
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

function sporesDropped(me, x, y)
end

function activate(me)
	if isFlag(FLAG_SUNKENCITY_PUZZLE, 3) then
		setFlag(FLAG_SUNKENCITY_PUZZLE, 4)
		createRockScene(me)
	elseif isFlag(FLAG_SUNKENCITY_PUZZLE, 6) then
		setFlag(FLAG_SUNKENCITY_PUZZLE, 7)
		-- create head
		local headNode = getNode("STATUEHEAD")
		local ent = createEntity("CC_StatueHead", "", node_x(headNode), node_y(headNode))		
		entity_alpha(ent, 0)
		entity_alpha(ent, 1, 1)
	end
end

