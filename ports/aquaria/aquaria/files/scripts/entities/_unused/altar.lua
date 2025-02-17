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

v.containedEntity = 0
v.naija = 0
v.button = 0
v.door = 0
v.sacrificed = false

function init(me)	
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "Altar", "")
	--entity_animate(me, "open")
	entity_setEntityLayer(me, 0)
	entity_setState(me, STATE_OPEN)
	
	--entity_generateCollisionMask(me)
	--entity_setPasses(me, 2)
	
	v.naija = getNaija()	
end

function postInit(me)
	v.door = entity_getNearestEntity(me, "EnergyDoor")
	if entity_isFlag(me, 1) then
		entity_setState(v.door, STATE_OPENED)
	end
end

function update(me, dt)
	if v.button == 0 then
		v.button = entity_getNearestEntity(me, "SacrificeButton")
	end
	
	if entity_isState(me, STATE_OPEN) and not entity_isAnimating(me) then
		entity_setState(me, STATE_OPENED)
	end
	if entity_isState(me, STATE_CLOSE) and not entity_isAnimating(me) then
		entity_setState(me, STATE_ON, 5)
	end
	if entity_isState(me, STATE_OFF) and not entity_isInterpolating(me) then
		entity_setState(me, STATE_OPEN)
	end
	if entity_isState(me, STATE_ON) then
	end
	if v.containedEntity ~= 0 then
		entity_setPosition(v.containedEntity, entity_x(me), entity_y(me))
	end
	if entity_isState(me, STATE_OPENED) then
		if v.containedEntity == 0 then
			local victim = entity_getNearestEntity(me, "SacrificeVictim")
			if victim ~=0 then
				--debugLog("victim!")
				if entity_isEntityInRange(me, victim, 128) then					
					v.containedEntity = victim
					entity_stopPull(v.containedEntity)
				end
			end
		end
	end
end

function enterState(me, state)
	if entity_isState(me, STATE_OPEN) then
		entity_setState(v.button, STATE_OPEN)
		entity_animate(me, "open")
		if v.sacrificed then
			if v.door ~= 0 then
				cam_toEntity(v.door)
				entity_setState(v.door, STATE_OPEN)
				watch(1.5)
				cam_toEntity(getNaija())
			end
			v.sacrificed = false
		end
	elseif entity_isState(me, STATE_CLOSE) then
		entity_animate(me, "close")
		entity_setState(v.button, STATE_CLOSE)
	elseif entity_isState(me, STATE_CLOSED) then
	elseif entity_isState(me, STATE_ON) then
		-- uncomment to catch naija
		--[[
		if v.containedEntity == 0 then
			if entity_isEntityInRange(me, v.naija, 128) then
				v.containedEntity = v.naija
			end
		end
		]]--
		entity_move(me, entity_x(me), entity_y(me)+2000, 4, 0, 0, 0, 1)
	elseif entity_isState(me, STATE_OFF) then
		
		entity_move(me, entity_x(me), entity_y(me)-2000, 4, 0, 0, 0, 1)		
	end
end

function exitState(me, state)
	if entity_isState(me, STATE_CLOSE) then
		--entity_setState(me, STATE_ON, 5)
	elseif entity_isState(me, STATE_ON) then
		if v.containedEntity ~= 0 and entity_isName(v.containedEntity, "SacrificeVictim") then
			v.sacrificed = true
			playSfx("HellBeast-Roar")
			shakeCamera(5, 3)
			entity_setFlag(me, 1)
			entity_setState(me, STATE_DELAY, 4)
		else
			entity_setState(me, STATE_DELAY, 2)
		end
		if entity_getEntityType(v.containedEntity) ~= ET_AVATAR then
			entity_setFlag(v.containedEntity, 1)
		end
		v.containedEntity = 0
	elseif entity_isState(me, STATE_DELAY) then
		entity_setState(me, STATE_OFF)
	elseif entity_isState(me, STATE_OFF) then
		--entity_setState(me, STATE_OPEN)		
	end
end

