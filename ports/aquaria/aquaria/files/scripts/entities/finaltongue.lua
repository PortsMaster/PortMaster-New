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

-- energy door
dofile("scripts/entities/doorcommon.lua")

--v.commonInit(me, "Final-Tongue", "TentacleDoor", 4.5, 0)

v.ix = 0
v.iy = 0
v.dist = 4048

function init(me)
	setupEntity(me, "Final-Tongue", -2)
	entity_scale(me, 4.5, 4.5)
	entity_setFillGrid(me, true)
	
	entity_setEntityLayer(me, -3)
	entity_setSegs(me, 2, 32, 0.15, 0.15, -0.018, 0, 6, 1)
	loadSound("tentacledoor")
end

function postInit(me)
	v.ix = entity_x(me)
	v.iy = entity_y(me)
	
	if entity_isFlag(me, 1) then
		entity_setState(me, STATE_OPENED)
	end
end

function update(me, dt)
	if entity_isState(me, STATE_OPEN) then
		--reconstructEntityGrid()
		if not entity_isInterpolating(me) then
			shakeCamera(4, 1)
			entity_setState(me, STATE_OPENED)
		end
	end
end

function enterState(me, state)
	if entity_isState(me, STATE_OPEN) then
		playSfx("tentacledoor")
		entity_alpha(me, 0, 6)
		entity_setPosition(me, v.ix, v.iy + v.dist, 6, 0, 0, 1)
	elseif entity_isState(me, STATE_OPENED) then
		entity_setPosition(me, v.ix, v.iy + v.dist)
		entity_alpha(me, 0)
		reconstructEntityGrid()
		entity_setFlag(me, 1)
	end
end

function exitState(me, state)
	if entity_isState(me, STATE_OPEN) then
		entity_setState(me, STATE_OPENED)
	end
end
