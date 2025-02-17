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
local STATE_BEFOREMEET = 1005

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_setTexture(me, "Li/Helmet")
	entity_setAllDamageTargets(me, false)
	
	entity_setActivationType(me, AT_CLICK)
	
	entity_setState(me, STATE_OFF)
	entity_scale(me, 0.75, 0.75)
end

function postInit(me)
	entity_setTarget(me, v.n)
	
	if isFlag(FLAG_LI, 101) or isFlag(FLAG_LI, 102) then
		if isMapName("licave") or isMapName("vedhacave") then
			local li = getLi()
			if li == 0 then
				li = createEntity("li", "", 0,0)
			end
			local liNode = getNode("LICAVE")
			entity_setPosition(li, node_x(liNode), node_y(liNode))
			setLi(li)
		end
	end
end

function activate(me)
	if entity_isState(me, STATE_ON) then
		if hasSong(SONG_DUALFORM) then
			playSfx("denied")
		else
			entity_idle(getNaija())
			fade(1, 1)
			watch(1)
			watch(0.5)
			
			entity_alpha(me, 0)
			if isMapName("LiCave") or isMapName("vedhacave") then
				debugLog("SETTING 101")
				setFlag(FLAG_LI, 101)
				playSfx("changeclothes1")
			end
			
			local li = getLi()
			if li ~= 0 then
				debugLog("SET BEFORE MEET")
				entity_setState(li, STATE_BEFOREMEET, -1, 1)
				local liNode = getNode("LICAVE")
				entity_setPosition(li, node_x(liNode), node_y(liNode))
			end
			
			watch(0.5)
			
			fade(0, 1)
			watch(1)
			--[[
			li = getLi()
			if li ~= 0 then
				local h = entity_getBoneByName(li, "Helmet")
				bone_alpha(h, 0)
			end
			]]--
			entity_setState(me, STATE_OFF)
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_ON) then
		entity_alpha(me, 1)
		entity_setActivationType(me, AT_CLICK)
	elseif entity_isState(me, STATE_OFF) then
		entity_alpha(me, 0)
		entity_setActivationType(me, AT_NONE)
	end
end

function update(me, dt)
	v.n = getNaija()
	if entity_isState(me, STATE_OFF) then
		if isFlag(FLAG_LI, 100) then
			entity_setState(me, STATE_ON)
		end
	elseif entity_isState(me, STATE_ON) then
		if not isFlag(FLAG_LI, 100) then
			entity_setState(me, STATE_OFF)
		end
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

