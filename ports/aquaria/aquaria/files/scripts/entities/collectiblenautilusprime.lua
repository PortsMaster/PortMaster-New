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

-- song cave collectible

v.n = 0

v.hatchMax = 5
v.hatchTimer = v.hatchMax

v.rollTimer = 0
v.rollMax = 2

v.hint = false

function init(me)
	setupEntity(me, "Collectibles/egg-nautilus")
	loadSound("Pet-Hatch")
	loadSound("Nautilus")
end

function postInit(me)
	v.n = getNaija()
end

function update(me, dt)
	if isFlag(FLAG_PET_NAUTILUS, 1) then
		entity_alpha(me, 0)
	end
	
	if isFlag(FLAG_PET_NAUTILUS, 0) and not v.hint and entity_isEntityInRange(me, v.n, 256) then
		playSfx("secret")
		setControlHint(getStringBank(33), 0, 0, 0, 6, "collectibles/egg-nautilus")
		v.hint = true
	end
	
	if entity_getAlpha(me) == 1 and isFlag(FLAG_PET_NAUTILUS, 0) then
		if entity_isEntityInRange(me, v.n, 300) then
			entity_offset(me, math.random(2)-1, 0)
			v.hatchTimer = v.hatchTimer - dt
			if v.hatchTimer < 0 then
				
				v.hatchTimer = 0
				entity_setState(me, STATE_HATCH)
			end
		else
			entity_offset(me, 0, 0)
			v.hatchTimer = v.hatchTimer + dt*0.5
			if v.hatchTimer > v.hatchMax then
				v.hatchTimer = v.hatchMax
			end
		end
	end
	
	v.rollTimer = v.rollTimer + dt
	if v.rollTimer >= v.rollMax then
		v.rollTimer = 0
		entity_rotate(me, 0)
		if chance(50) then
			entity_rotate(me, -30, 0.2, 3, 1, 1)
		else
			entity_rotate(me, 30, 0.2, 3, 1, 1)
		end
	end
end

function enterState(me, state)
	if entity_isState(me, STATE_HATCH) then
		clearControlHint()
		
		playSfx("Pet-Hatch")
		entity_setStateTime(me, 2)
		
		entity_alpha(me, 0.7, 2)
		entity_scale(me, 1.2, 1.2, 2)
	end
end

function exitState(me, state)
	if entity_isState(me, STATE_HATCH) then
		entity_soundFreq(me, "Nautilus", 1.5)
		entity_soundFreq(me, "Nautilus", 2)
		
		setFlag(FLAG_PET_NAUTILUS, 1)
		local e = setActivePet(FLAG_PET_NAUTILUS)
		
		if e ~= 0 then
			entity_setPosition(e, entity_x(me), entity_y(me))
		end
		
		playSfx("Secret")
		playSfx("Collectible")
	end
end
