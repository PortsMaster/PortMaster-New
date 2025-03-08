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

function init(me)
	v.n = getNaija()
end

function update(me, dt)
	if not isForm(FORM_ENERGY) and node_isEntityIn(me, v.n) then
			playSfx("shield-hit")
		spawnParticleEffect("barrier-hit", entity_x(v.n), entity_y(v.n))
		
		local w, h = node_getSize(me)
		local x, y = 0, 0
		entity_clearVel(v.n)
		if w > h then
			y = entity_y(v.n) - node_y(me)
			if entity_y(v.n) < node_y(me) then
				entity_setPosition(v.n, entity_x(v.n), node_y(me) - (h/2) - 10)
			else
				entity_setPosition(v.n, entity_x(v.n), node_y(me) + (h+10)/2 + 10)
			end
		else
			x = entity_x(v.n) - node_x(me)
		end
		
		
		x, y = vector_setLength(x, y, 10000)
		entity_setMaxSpeedLerp(v.n, 4)
		entity_setMaxSpeedLerp(v.n, 1, 4)
		entity_addVel(v.n, x, y)

		if chance(50) then
			emote(EMOTE_NAIJAUGH)
		end
	end
end
