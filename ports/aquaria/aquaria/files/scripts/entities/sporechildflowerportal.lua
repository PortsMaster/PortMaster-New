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

dofile("scripts/include/sporechildflowertemplate.lua")

v.active = false
v.done = false
function init(me)
	v.commonInit(me, "TubeFlower")
	entity_setName(me, "TubeFlower")
end

function update(me, dt)
	v.commonUpdate(me, dt)
	if entity_isEntityInRange(me, getNaija(), 356) then
		if entity_isFlag(me, 0) then
			pickupGem("tubeflower")
			entity_setFlag(me, 1)
		end
	end
	if v.active and not v.done then
		if entity_isEntityInRange(me, getNaija(), 128) then
			v.done = true
			entity_sound(me, "TubeFlowerSuck")
			if isMapName("Tree02") then
				warpNaijaToSceneNode("Forest04", "FLOWERPORTAL_FROMBOSS")
			elseif isMapName("Forest04") then
				warpNaijaToSceneNode("Tree02", "FLOWERPORTAL_FROMFOREST")
			elseif isMapName("Mithalas02") then
				warpNaijaToSceneNode("Mithalas01", "TUBEFLOWER_FROMMITHALAS02")
			elseif isMapName("Mithalas01") then
				warpNaijaToSceneNode("Mithalas02", "TUBEFLOWER_FROMMITHALAS01")
			else
				-- find the other one
				debugLog(entity_getName(me))
				local e = getFirstEntity()
				while e~=0 do
					if e ~= me and entity_isName(e, "TubeFlower") then
					
						local n = getNaija()
						--debugLog("Warping!")
						entity_idle(n)
						--local dx, dy = entity_getVectorToEntity(me, e)
						cam_toEntity(e)
						watch(1)
						entity_idle(n)
						entity_alpha(n, 0)
						entity_setState(e, STATE_OPEN)
						
						
						--esetv(n, EV_NOINPUTNOVEL, 0)
						local dx, dy = entity_getNormal(e)
						dx, dy = vector_setLength(dx, dy, 32)
						entity_setPosition(n, entity_x(e)+dx, entity_y(e)+dy)
						watch(0.5)
						
					
						local einc = getFirstEntity()
						while einc ~= 0 do
							if eisv(einc, EV_TYPEID, EVT_PET) then
								--debugLog(string.format("petname: %s", entity_getName(einc)))
								entity_setPosition(einc, entity_x(n), entity_y(n))
							end
							einc = getNextEntity()
						end
						
						
						entity_alpha(n, 1, 0.2)
						local dx, dy = vector_setLength(dx, dy, 400)
						entity_addVel(n, dx, dy)
						entity_flipToVel(n)
						cam_toEntity(n)
						entity_idle(n)
						
						--wait(0.5)
						
						
						if hasLi() then
							local li = getLi()
							
							local dx, dy = entity_getNormal(e)
							dx, dy = vector_setLength(dx, dy, 32)
							
							entity_setPosition(li, entity_x(e)+dx, entity_y(e)+dy)
							
							if not isForm(FORM_DUAL) then
								entity_alpha(li, 0)
								entity_alpha(li, 1, 0.2)
							end
							
							dx, dy = vector_setLength(dx, dy, 400)
							entity_addVel(li, dx, dy)
							
							--wait(0.5)
						end
						
					
						
						--watch(0.2)
						
						--esetv(n, EV_NOINPUTNOVEL, 1)
						--entity_idle(n)
						entity_setState(e, STATE_CLOSE)
						
						break
					end
					e = getNextEntity()
				end
				entity_setState(me, STATE_CLOSE)
				v.done = false
			end

		end
	else
		if not (entity_isState(me, STATE_OPEN) or entity_isState(me, STATE_OPENED)) then
			entity_touchAvatarDamage(me, 64, 0, 400)
		end
	end
end

function enterState(me, state)
	v.commonEnterState(me, state)
	if entity_isState(me, STATE_OPENED) then		
		v.active = true
	elseif entity_isState(me, STATE_CLOSE) then
		v.active = false
	elseif entity_isState(me, STATE_OPEN) then
		entity_sound(me, "TubeFlower")
		--entity_sound(me, "TubeFlower")		
	end
end



