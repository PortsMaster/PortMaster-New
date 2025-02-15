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

-- energy barrier
v.init_x = 0
v.init_y = 0

v.dist = 700

v.lastRot = -1

v.topy=0
v.btmy=0
v.leftx=0
v.rightx=0

v.halfWidth = 32

v.flicker 		= false
local FLICKER_TIME1 	= 1.2
local FLICKER_TIME2 	= 1.0
v.flickerTimer 	= FLICKER_TIME1
v.orient 			= ORIENT_NONE

function v.commonInit(me)
	setupEntity(me, "EnergyBarrier", 1)
	entity_setActivationType(me, AT_NONE)
	entity_setUpdateCull(me, 1024)
	entity_alpha(me, 0)
	entity_setAllDamageTargets(me, false)
end

function update(me, dt)
	local adjust = 25
	if entity_getRotation(me) ~= v.lastRot then
		v.lastRot = entity_getRotation(me)
		if entity_getRotation(me) < 90 then
			v.topy = findWall(entity_x(me), entity_y(me), 0, -1)
			v.btmy = findWall(entity_x(me), entity_y(me), 0, 1)
			v.leftx = entity_x(me)-v.halfWidth
			v.rightx = entity_x(me)+v.halfWidth
			v.orient = ORIENT_VERTICAL
			v.topy = v.topy + adjust
			v.btmy = v.btmy - adjust			
			entity_setWidth(me, v.rightx-v.leftx)
			entity_setHeight(me, v.btmy-v.topy)

		elseif entity_getRotation(me) < 180 then
			v.leftx = findWall(entity_x(me), entity_y(me), -1, 0)
			v.rightx = findWall(entity_x(me), entity_y(me), 1, 0)
			v.topy = entity_y(me)-v.halfWidth
			v.btmy = entity_y(me)+v.halfWidth
			v.orient = ORIENT_HORIZONTAL
			v.leftx = v.leftx + adjust
			v.rightx = v.rightx - adjust			
			entity_setHeight(me, v.rightx-v.leftx)
			entity_setWidth(me, v.btmy-v.topy)
		end
	end
	
	if entity_isState(me, STATE_PULSE) then
		v.pulseTimer = v.pulseTimer - dt
		if v.pulseTimer < 0 then
			entity_setState(me, STATE_OFF)
		end
	end
	
	if entity_isState(me, STATE_FLICKER) then
		v.flickerTimer = v.flickerTimer - dt
		if v.flickerTimer < 0 then
			if v.flicker == false then
				v.flickerTimer = FLICKER_TIME1
			elseif v.flicker == true then
				v.flickerTimer = FLICKER_TIME2
			end
			if v.flicker then
				entity_alpha(me, 0, 0.1)
				v.flicker = false
				--setSceneColor(1, 1, 1, 0.5)
			else
				entity_playSfx(me, "FizzleBarrier")
				if entity_getRotation(me) == 0 then
					spawnParticleEffect("EnergyBarrierFlicker", entity_x(me), entity_y(me))
				else
					spawnParticleEffect("EnergyBarrierFlicker2", entity_x(me), entity_y(me))
				end
				entity_alpha(me, 1, 0.1)
				v.flicker = true
				--setSceneColor(1, 0.5, 0.5, 0.5)
			end
		end
	end
	
	if entity_isState(me, STATE_IDLE)
	or (entity_isState(me, STATE_FLICKER) and v.flicker==true)
	or entity_isState(me, STATE_PULSE)
	then
		--debugLog("state is idle")
		local e = getFirstEntity()
		while e ~= 0 do
			--debugLog("Found an entity")
			if (entity_getEntityType(e)==ET_ENEMY or entity_getEntityType(e)==ET_AVATAR)
			and not entity_isProperty(e, EP_MOVABLE) and not entity_isDead(e) and entity_getCollideRadius(e) > 0 and not eisv(e, EV_TYPEID, EVT_PET) then
				--debugLog("Found an enemy / the player")
				if entity_x(e) >= v.leftx and entity_x(e) <= v.rightx
				and entity_y(e) >= v.topy and entity_y(e) <= v.btmy then
					if v.orient == ORIENT_VERTICAL then	
						if entity_x(e) > entity_x(me) then
							entity_push(e, 1000, entity_vely(e), 0.5, 1000)
						else
							entity_push(e, -1000, entity_vely(e), 0.5, 1000)
						end
					elseif v.orient == ORIENT_HORIZONTAL then
						if entity_y(e) > entity_y(me) then
							entity_push(e, entity_velx(e), 1000, 0.5, 1000)
						else
							entity_push(e, entity_velx(e), -1000, 0.5, 1000)
						end
					end
					spawnParticleEffect("HitEnergyBarrier", entity_x(e), entity_y(e))
					if entity_getEntityType(e) == ET_AVATAR then
						debugLog("hit avatar")
						entity_damage(e, me, 1)
					else
						entity_damage(e, me, 2)
					end
				end
			end
			e = getNextEntity()
		end
	end
--[[
	if not entity_isState(me, STATE_OPENED) and not entity_isState(me, STATE_OPEN) then
		init_x = entity_x(me)
		init_y = entity_y(me)
	end
	if entity_getState(me)==STATE_OPEN then
		--reconstructGrid()
		if not entity_isInterpolating(me) then
		
		
			entity_setState(me, STATE_OPENED)
		end
	end
	]]--
end

function enterState(me)
	if entity_isState(me, STATE_DISABLED) then
		entity_alpha(me, 0)
	elseif entity_isState(me, STATE_PULSE) then
		entity_alpha(me, 1, 0.1)
		spawnParticleEffect("EnergyBarrierFlicker", entity_x(me), entity_y(me))
		v.pulseTimer = 1

	elseif entity_isState(me, STATE_OFF) then
		entity_alpha(me, 0, 0.1)
	end
--[[
	if entity_isState(me, STATE_OPEN) then
		if entity_getRotation(me)==0 then
			entity_interpolateTo(me, init_x, init_y-dist, 2)
		elseif entity_getRotation(me) == 90 then
			entity_interpolateTo(me, init_x+dist, init_y, 2)
		elseif entity_getRotation(me) == 270 then
			entity_interpolateTo(me, init_x-dist, init_y, 2)			
		end
	elseif entity_isState(me, STATE_OPENED) then
		if entity_getRotation(me)==0 then
			entity_setPosition(me, init_x, init_y-dist)
		elseif entity_getRotation(me) == 90 then
			entity_setPosition(me, init_x+dist, init_y)
		elseif entity_getRotation(me) == 270 then
			entity_setPosition(me, init_x-dist, init_y)			
		end
		reconstructGrid()		
	end
	]]--
end

function exitState(me)
end

function hitSurface(me)
end
