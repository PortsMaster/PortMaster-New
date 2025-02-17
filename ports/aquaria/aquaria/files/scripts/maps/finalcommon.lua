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

local function initFinalSpirit(flag, name)
	if getFlag(flag) > 0 then
		local ent = getEntity(name)
		if ent ~= 0 then
			entity_delete(ent)
		end
	end
	if isFlag(flag, 1) then
		local ent = createEntity(name, "", entity_x(v.n), entity_y(v.n))
		entity_setState(ent, STATE_FOLLOW, -1, true)
	end
end

function v.initFinalSpirits()
	v.n = getNaija()
	initFinalSpirit(FLAG_SPIRIT_ERULIAN, "Erulian-Final")
	initFinalSpirit(FLAG_SPIRIT_KROTITE, "Krotite-Final")
	initFinalSpirit(FLAG_SPIRIT_DRASK, "Drask-Final")
	initFinalSpirit(FLAG_SPIRIT_DRUNIAD, "Druniad-Final")
end
