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

-- COLLECTIBLE ITEM

v.myFlag = 0
v.back = false

v.isCostume = false

function v.commonInit(me, gfx, flag, cst)
	v.myFlag = flag
	setupEntity(me, gfx)
	debugLog("in common init")
	if isFlag(flag, 1) then
		debugLog("setting state collected")
		entity_setState(me, STATE_COLLECTED)
		entity_alpha(me, 0, 0)
	end	
	
	local nd = entity_getNearestNode(me, "layerback")
	if nd ~= 0 and node_isEntityIn(nd, me) then
		entity_setEntityLayer(me, -1)
		v.back = true
	end
	
	v.isCostume = cst or false
end

function v.commonUpdate(me, dt)
	if entity_isState(me, STATE_IDLE) then
		if v.back then
			local e = getFirstEntity()
			while e ~= 0 do
				if eisv(e, EV_TYPEID, EVT_ROCK) then
					if entity_isEntityInRange(me, e, 64) then
						return
					end
				end
				e = getNextEntity()
			end
		end
		if entity_isEntityInRange(me, getNaija(), 96) then
			entity_setState(me, STATE_COLLECT, 6)
		end
	end
end

v.incut = false

function v.commonEnterState(me, state)
	if v.incut then return end
	
	if entity_isState(me, STATE_COLLECT) then
		v.incut = true
		entity_idle(getNaija())
		entity_flipToEntity(getNaija(), me)
		cam_toEntity(me)
		
		overrideZoom(1.2, 7)
		musicVolume(0.1, 3)
		
		setSceneColor(1, 0.9, 0.5, 3)
		
		spawnParticleEffect("treasure-glow", entity_x(me), entity_y(me))
		
		playSfx("low-note1", 0, 0.4)
		playSfx("low-note5", 0, 0.4)
		watch(3)
		
		setFlag(v.myFlag, 1)
		entity_setPosition(me, entity_x(me), entity_y(me)-100, 3, 0, 0, 1)
		entity_scale(me, 1.2, 1.2, 3)
		--playSfx("secret")
		playSfx("Collectible")
		
		
		watch(3)
		
		playSfx("secret", 0, 0.5)
		cam_toEntity(getNaija())
		
		musicVolume(1, 2)
		
		setSceneColor(1, 1, 1, 1)
		
		overrideZoom(0)
		
		if v.isCostume then
			setControlHint(getStringBank(224), 0, 0, 0, 8, "gui/icon-treasures")
		else
			if isFlag(FLAG_HINT_COLLECTIBLE, 0) then
				setControlHint(getStringBank(222), 0, 0, 0, 8)
				setFlag(FLAG_HINT_COLLECTIBLE, 1)
			else
				setControlHint(getStringBank(223), 0, 0, 0, 8, "gui/icon-treasures")
			end
		end
		v.incut = false
	elseif entity_isState(me, STATE_COLLECTED) then	
		debugLog("COLLECTED, fading OUT alpha")
		entity_alpha(me, 0, 1)
	elseif entity_isState(me, STATE_COLLECTEDINHOUSE) then
		debugLog("COLLECTEDINHOUSE.. fading IN")
		entity_alpha(me, 1, 0.1)
	end
end

function v.commonExitState(me, state)
	if entity_isState(me, STATE_COLLECT) then
		entity_alpha(me, 0, 1)
		spawnParticleEffect("Collect", entity_x(me), entity_y(me))
		--clearControlHint()
		entity_setState(me, STATE_COLLECTED)
	end
end
